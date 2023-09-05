// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Escrow} from "../src/Escrow.sol";

contract EscrowCreateDealTest is Test {
    Escrow public escrow;
    address public u1 = vm.addr(1);
    address public u2 = vm.addr(2);

    function setUp() public {
        escrow = new Escrow();
        vm.deal(u1, 1 ether);
    }

    function test_createDeal() public {
        uint256 _amount = 0.5 ether;

        // create deal
        vm.prank(u1);
        uint id = escrow.createDeal(u1, u2, _amount);

        // check return deal id
        assertEq(id, 0);

        // check deals quantity
        assertEq(escrow.dealsCount(), 1);

        (
            address from,
            address to,
            uint256 amount,
            Escrow.DealState state
        ) = escrow.deals(0);

        // check deal from
        assertEq(from, u1);

        // check deal to
        assertEq(to, u2);

        // check deal amount
        assertEq(amount, _amount);

        // check deal state
        assertEq(uint8(state), uint8(Escrow.DealState.PENDING));
    }

    function testReverts_createDeal_with_zero_amount() public {
        vm.expectRevert("amount missmatch");

        // create deal
        vm.prank(u1);
        escrow.createDeal(u1, u2, 0);
    }

    function testReverts_createDeal_with_from_and_to_the_same() public {
        vm.expectRevert("from / to missmatch");

        // create deal
        vm.prank(u1);
        escrow.createDeal(u1, u1, 0.5 ether);
    }
}
