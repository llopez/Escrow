// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Escrow} from "../src/Escrow.sol";

contract EscrowTest is Test {
    Escrow public escrow;
    address public u1 = vm.addr(1);
    address public u2 = vm.addr(2);

    function setUp() public {
        escrow = new Escrow();
        vm.deal(u1, 1 ether);
    }

    function test_lock_for_already_created_deal() public {
        uint256 _amount = 0.5 ether;

        // create deal
        vm.prank(u1);
        uint dealId = escrow.createDeal(u1, u2, _amount);

        // deposit and lock funds
        vm.prank(u1);
        escrow.lock{value: _amount}(dealId);

        (, , , Escrow.DealState state) = escrow.deals(dealId);

        // check u1 locked funds
        assertEq(escrow.balanceOf(u1), _amount);

        // check deal state
        assertEq(uint8(state), uint8(Escrow.DealState.LOCKED));
    }

    function test_claim_for_already_created_unlocked_deal() public {
        uint256 _amount = 0.5 ether;

        // create deal
        vm.prank(u1);
        uint dealId = escrow.createDeal(u1, u2, _amount);

        // deposit and lock funds
        vm.prank(u1);
        escrow.lock{value: _amount}(dealId);

        // unlock funds
        vm.prank(u1);
        escrow.unlock(dealId);

        // claim funds
        vm.prank(u2);
        escrow.claim(dealId);

        (, , , Escrow.DealState state) = escrow.deals(dealId);

        // check u1 locked funds
        assertEq(escrow.balanceOf(u1), 0);

        // check deal state
        assertEq(uint8(state), uint8(Escrow.DealState.CLAIMED));

        // check recipient new balance
        assertEq(u2.balance, _amount);
    }

    function test_createDeal() public {
        uint256 _amount = 0.5 ether;

        // create deal
        vm.prank(u1);
        escrow.createDeal(u1, u2, _amount);

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
}
