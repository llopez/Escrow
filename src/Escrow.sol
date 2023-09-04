// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

contract Escrow {
    mapping(address => uint256) public balanceOf;

    function deposit() external payable {
        require(msg.value != 0, "no payment");

        balanceOf[msg.sender] += msg.value;
    }
}
