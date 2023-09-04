// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Escrow} from "../src/Escrow.sol";

contract EscrowTest is Test {
    Escrow public escrow;
    address public u1 = vm.addr(1);

    function setUp() public {
        escrow = new Escrow();
        vm.deal(u1, 1 ether);
    }

    function test_deposit() public {
        vm.prank(u1);
        uint256 amount = 0.2 ether;
        escrow.deposit{value: amount}();

        assertEq(escrow.balanceOf(u1), amount);
    }
}
