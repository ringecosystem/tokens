// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {Chains} from "create3-deploy/script/Chains.sol";
import {XKTON} from "../src/XKTON.sol";
import {XKTONLockBox} from "../src/XKTONLockBox.sol";

contract XKTONLockBoxTest is Test {
    using Chains for uint256;

    KTON kton = KTON(0x9F284E1337A815fe77D2Ff4aE46544645B20c5ff);
    XKTON xKTON;
    XKTONLockBox lockbox;

    address guy;
    address him;

    function setUp() public {
        uint256 chainId = Chains.Ethereum;
        vm.createSelectFork(chainId.toChainName());

        xKTON = new XKTON();
        lockbox = new XKTONLockBox(address(kton), address(xKTON));

        guy = address(new Guy());
        him = address(new Guy());
        mint_xkton_to(guy, 1);
        mint_kton_to(him, 1);

        xKTON.mint(address(lockbox), kton.totalSupply());
        address[] memory allowList = new address[](1);
        allowList[0] = address(lockbox);
        address authority = address(new KTONAuthority(allowList));
        vm.prank(kton.owner());
        kton.setAuthority(authority);
    }

    function test_contructor_args() public {
        assertEq(xKTON.name(), "Darwinia Commitment xKTON");
        assertEq(xKTON.symbol(), "xKTON");
        assertEq(xKTON.decimals(), 18);
    }

    function invariant_totalSupply() public {
        assertEq(xKTON.balanceOf(address(lockbox)), kton.totalSupply());
    }

    function test_deposit() public {
        assertEq(kton.balanceOf(guy), 0);
        assertEq(xKTON.balanceOf(guy), 1);
        deposit(guy, 1);
        assertEq(kton.balanceOf(guy), 1);
        assertEq(xKTON.balanceOf(guy), 0);
    }

    function test_deposit_for_self() public {
        assertEq(kton.balanceOf(guy), 0);
        assertEq(xKTON.balanceOf(guy), 1);
        deposit_for(guy, guy, 1);
        assertEq(kton.balanceOf(guy), 1);
        assertEq(xKTON.balanceOf(guy), 0);
    }

    function test_deposit_for_other() public {
        assertEq(kton.balanceOf(him), 1);
        assertEq(xKTON.balanceOf(guy), 1);
        deposit_for(guy, him, 1);
        assertEq(kton.balanceOf(him), 2);
        assertEq(xKTON.balanceOf(guy), 0);
    }

    function test_withdraw() public {
        assertEq(kton.balanceOf(him), 1);
        assertEq(xKTON.balanceOf(him), 0);
        withdraw(him, 1);
        assertEq(kton.balanceOf(him), 0);
        assertEq(xKTON.balanceOf(him), 1);
    }

    function test_withdraw_to_self() public {
        assertEq(kton.balanceOf(him), 1);
        assertEq(xKTON.balanceOf(him), 0);
        withdraw_to(him, him, 1);
        assertEq(kton.balanceOf(him), 0);
        assertEq(xKTON.balanceOf(him), 1);
    }

    function test_withdraw_to_other() public {
        assertEq(kton.balanceOf(him), 1);
        assertEq(xKTON.balanceOf(guy), 1);
        withdraw_to(him, guy, 1);
        assertEq(kton.balanceOf(him), 0);
        assertEq(xKTON.balanceOf(guy), 2);
    }

    function test_transfer() public {
        assertEq(xKTON.balanceOf(guy), 1);
        assertEq(xKTON.balanceOf(him), 0);
        vm.prank(guy);
        xKTON.transfer(him, 1);
        assertEq(xKTON.balanceOf(guy), 0);
        assertEq(xKTON.balanceOf(him), 1);
    }

    function mint_kton_to(address account, uint256 amount) internal {
        vm.prank(kton.owner());
        kton.mint(account, amount);
    }

    function mint_xkton_to(address account, uint256 amount) internal {
        vm.prank(xKTON.owner());
        xKTON.mint(account, amount);
    }

    function deposit(address account, uint256 amount) internal {
        vm.startPrank(account);
        xKTON.approve(address(lockbox), amount);
        lockbox.deposit(amount);
        vm.stopPrank();
    }

    function deposit_for(address from, address to, uint256 amount) internal {
        vm.startPrank(from);
        xKTON.approve(address(lockbox), amount);
        lockbox.depositFor(to, amount);
        vm.stopPrank();
    }

    function withdraw(address account, uint256 amount) internal {
        vm.startPrank(account);
        kton.approve(address(lockbox), amount);
        lockbox.withdraw(amount);
        vm.stopPrank();
    }

    function withdraw_to(address from, address to, uint256 amount) internal {
        vm.startPrank(from);
        kton.approve(address(lockbox), amount);
        lockbox.withdrawTo(to, amount);
        vm.stopPrank();
    }
}

contract Guy {}

contract KTONAuthority {
    mapping(address => bool) public allowList;

    constructor(address[] memory _allowlists) {
        for (uint256 i = 0; i < _allowlists.length; i++) {
            allowList[_allowlists[i]] = true;
        }
    }

    function canCall(address _src, address, bytes4 _sig)
        public
        view
        returns (bool)
    {
        return (
            allowList[_src]
                && _sig == bytes4(keccak256("mint(address,uint256)"))
        )
            || (
                allowList[_src]
                    && _sig == bytes4(keccak256("burn(address,uint256)"))
            );
    }
}

interface KTON {
    function approve(address _spender, uint256 _amount)
        external
        returns (bool success);
    function balanceOf(address src) external view returns (uint256);
    function owner() external view returns (address);
    function mint(address _guy, uint256 _wad) external;
    function setAuthority(address authority_) external;
    function totalSupply() external view returns (uint256);
}
