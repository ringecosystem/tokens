// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IKTON.sol";

contract XKTONLockBox {
    IKTON public immutable KTON;
    IERC20 public immutable XKTON;

    event Deposit(address indexed dst, uint256 wad);
    event Withdrawal(address indexed src, uint256 wad);

    constructor(address kton, address xkton) {
        KTON = IKTON(kton);
        XKTON = IERC20(xkton);
    }

    function deposit(uint256 amount) external {
        _deposit(msg.sender, amount);
    }

    function withdraw(uint256 amount) external {
        _withdraw(msg.sender, amount);
    }

    function depositFor(address to, uint256 amount) external {
        _deposit(to, amount);
    }

    function withdrawTo(address to, uint256 amount) external {
        _withdraw(to, amount);
    }

    function _deposit(address to, uint256 amount) internal {
        XKTON.transferFrom(msg.sender, address(this), amount);
        KTON.mint(to, amount);
        emit Deposit(to, amount);
    }

    function _withdraw(address to, uint256 amount) internal {
        KTON.burn(msg.sender, amount);
        XKTON.transfer(to, amount);
        emit Withdrawal(to, amount);
    }
}
