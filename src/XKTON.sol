// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable2Step.sol";

contract XKTON is ERC20, ERC20Burnable, Ownable2Step {
    constructor() ERC20("Darwinia Commitment xKTON", "xKTON") Ownable2Step() {}

    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) external {
        burnFrom(account, amount);
    }
}
