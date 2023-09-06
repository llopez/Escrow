// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Escrow} from "../src/Escrow.sol";

contract EscrowClaimTest is Test {
    Escrow public escrow;
    address public u1 = vm.addr(1);
    address public u2 = vm.addr(2);

    function setUp() public {
        escrow = new Escrow();
        vm.deal(u1, 1 ether);
    }

    function testReverts_claim_when_wrong_id() public {
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

        vm.expectRevert("not found");

        // claim funds
        vm.prank(u2);
        escrow.claim(1);
    }

    function test_claim_when_unlocked_deal() public {
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

        // check contract balance
        assertEq(escrow.totalBalance(), 0);

        // check deal state
        assertEq(uint8(state), uint8(Escrow.DealState.CLAIMED));

        // check recipient new balance
        assertEq(u2.balance, _amount);
    }

    function testRevert_claim_when_unlocked_deal_called_by_from() public {
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

        vm.expectRevert("recipient missmatch");

        // claim funds called by from
        vm.prank(u1);
        escrow.claim(dealId);
    }

    function testReverts_claim_when_locked_deal() public {
        uint256 _amount = 0.5 ether;

        // create deal
        vm.prank(u1);
        uint dealId = escrow.createDeal(u1, u2, _amount);

        // deposit and lock funds
        vm.prank(u1);
        escrow.lock{value: _amount}(dealId);

        vm.expectRevert("state transition missmatch");

        // claim funds
        vm.prank(u2);
        escrow.claim(dealId);
    }

    function testReverts_claim_when_pending_deal() public {
        uint256 _amount = 0.5 ether;

        // create deal
        vm.prank(u1);
        uint dealId = escrow.createDeal(u1, u2, _amount);

        vm.expectRevert("state transition missmatch");

        // claim funds
        vm.prank(u2);
        escrow.claim(dealId);
    }

    function testReverts_claim_when_claimed_deal() public {
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

        vm.expectRevert("state transition missmatch");

        // claim funds
        vm.prank(u2);
        escrow.claim(dealId);
    }
}
