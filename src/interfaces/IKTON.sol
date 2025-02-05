// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IKTON {
    function balanceOf(address src) external view returns (uint256);
    function burn(address _guy, uint256 _wad) external;
    function mint(address _guy, uint256 _wad) external;
}
