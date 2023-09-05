// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Escrow} from "../src/Escrow.sol";

contract EscrowUnlockTest is Test {
    Escrow public escrow;
    address public u1 = vm.addr(1);
    address public u2 = vm.addr(2);

    function setUp() public {
        escrow = new Escrow();
        vm.deal(u1, 1 ether);
    }

    function test_unlock_when_deal_is_locked() public {
        uint256 _amount = 0.5 ether;

        // create deal
        vm.prank(u1);
        uint dealId = escrow.createDeal(u1, u2, _amount);

        // lock funds
        vm.prank(u1);
        escrow.lock{value: _amount}(dealId);

        // unlock
        vm.prank(u1);
        escrow.unlock(dealId);

        (, , , Escrow.DealState state) = escrow.deals(dealId);

        // check deal state
        assertEq(uint8(state), uint8(Escrow.DealState.UNLOCKED));
    }

    function testReverts_unlock_when_deal_is_pending() public {
        uint256 _amount = 0.5 ether;

        // create deal (pending)
        vm.prank(u1);
        uint dealId = escrow.createDeal(u1, u2, _amount);

        vm.expectRevert("state transition missmatch");

        // unlock
        vm.prank(u1);
        escrow.unlock(dealId);
    }

    function testReverts_unlock_when_deal_is_unlocked() public {
        uint256 _amount = 0.5 ether;

        // create deal (pending)
        vm.prank(u1);
        uint dealId = escrow.createDeal(u1, u2, _amount);

        // lock funds
        vm.prank(u1);
        escrow.lock{value: _amount}(dealId);

        // unlock
        vm.prank(u1);
        escrow.unlock(dealId);

        vm.expectRevert("state transition missmatch");

        // unlock
        vm.prank(u1);
        escrow.unlock(dealId);
    }
}
