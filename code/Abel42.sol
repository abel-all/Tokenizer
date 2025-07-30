// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.0/contracts/token/ERC20/ERC20.sol";

contract Abel42 is ERC20 {
    constructor(uint256 initialSupply) ERC20("Abel42", "ABL42") {
        _mint(msg.sender, initialSupply * (10**18));
    }
}