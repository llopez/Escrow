// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Escrow} from "../src/Escrow.sol";

contract EscrowLockTest is Test {
    Escrow public escrow;
    address public u1 = vm.addr(1);
    address public u2 = vm.addr(2);

    function setUp() public {
        escrow = new Escrow();
        vm.deal(u1, 1 ether);
    }

    function test_lock_when_deal_is_pending() public {
        uint256 _amount = 0.5 ether;

        // create deal
        vm.prank(u1);
        uint dealId = escrow.createDeal(u1, u2, _amount);

        // lock funds
        vm.prank(u1);
        escrow.lock{value: _amount}(dealId);

        (, , , Escrow.DealState state) = escrow.deals(dealId);

        // check u1 locked funds
        assertEq(escrow.balanceOf(u1), _amount);

        // check deal state
        assertEq(uint8(state), uint8(Escrow.DealState.LOCKED));
    }

    function testReverts_lock_when_wrong_id() public {
        vm.expectRevert("not found");

        // lock funds
        vm.prank(u1);
        escrow.lock{value: 0.5 ether}(0);
    }

    function testReverts_lock_when_deal_is_pending_and_zero_amount() public {
        uint256 _amount = 0.5 ether;

        // create deal
        vm.prank(u1);
        uint dealId = escrow.createDeal(u1, u2, _amount);

        vm.expectRevert("missing payment");

        // lock funds
        vm.prank(u1);
        escrow.lock(dealId);
    }

    function testReverts_lock_when_deal_is_pending_and_wrong_amount() public {
        uint256 _amount = 0.5 ether;

        // create deal
        vm.prank(u1);
        uint dealId = escrow.createDeal(u1, u2, _amount);

        vm.expectRevert("amount missmatch");

        // lock funds
        vm.prank(u1);
        escrow.lock{value: 0.2 ether}(dealId);
    }

    function testReverts_lock_when_deal_is_locked() public {
        uint256 _amount = 0.5 ether;

        // create deal
        vm.prank(u1);
        uint dealId = escrow.createDeal(u1, u2, _amount);

        // lock funds
        vm.prank(u1);
        escrow.lock{value: _amount}(dealId);

        vm.expectRevert("state transition missmatch");

        // lock funds again
        vm.prank(u1);
        escrow.lock{value: _amount}(dealId);
    }

    function testReverts_lock_when_deal_is_unlocked() public {
        uint256 _amount = 0.5 ether;

        // create deal
        vm.prank(u1);
        uint dealId = escrow.createDeal(u1, u2, _amount);

        // lock funds
        vm.prank(u1);
        escrow.lock{value: _amount}(dealId);

        // unlock funds
        vm.prank(u1);
        escrow.unlock(dealId);

        vm.expectRevert("state transition missmatch");

        // lock funds again
        vm.prank(u1);
        escrow.lock{value: _amount}(dealId);
    }

    function testReverts_lock_when_deal_is_claimed() public {
        uint256 _amount = 0.5 ether;

        // create deal
        vm.prank(u1);
        uint dealId = escrow.createDeal(u1, u2, _amount);

        // lock funds
        vm.prank(u1);
        escrow.lock{value: _amount}(dealId);

        // unlock funds
        vm.prank(u1);
        escrow.unlock(dealId);

        // claim funds
        vm.prank(u2);
        escrow.claim(dealId);

        vm.expectRevert("state transition missmatch");

        // lock funds again
        vm.prank(u1);
        escrow.lock{value: _amount}(dealId);
    }
}
