// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

contract Escrow {
    enum DealState {
        PENDING,
        LOCKED,
        UNLOCKED,
        CLAIMED
    }

    struct Deal {
        address from;
        address to;
        uint256 amount;
        DealState state;
    }

    uint256 public dealsCount = 0;

    mapping(uint256 => Deal) public deals;
    mapping(address => uint256) public balanceOf;

    function createDeal(
        address from,
        address to,
        uint256 amount
    ) external returns (uint) {
        require(amount > 0, "amount missmatch");
        require(from != to, "from / to missmatch");

        Deal memory deal = Deal(from, to, amount, DealState.PENDING);
        deals[dealsCount] = deal;

        uint id = dealsCount;

        dealsCount += 1;

        return id;
    }

    function lock(uint dealId) external payable {
        require(msg.value != 0, "missing payment");

        Deal storage deal = deals[dealId];

        require(deal.amount != 0, "not found");

        require(deal.state == DealState.PENDING, "state transition missmatch");

        require(msg.value == deal.amount, "amount missmatch");

        balanceOf[msg.sender] += msg.value;

        deal.state = DealState.LOCKED;
    }

    function unlock(uint dealId) external {
        Deal storage deal = deals[dealId];

        require(deal.amount != 0, "not found");

        require(deal.state == DealState.LOCKED, "state transition missmatch");

        require(msg.sender == deal.from, "from missmatch");

        deal.state = DealState.UNLOCKED;
    }

    function claim(uint dealId) external payable {
        Deal storage deal = deals[dealId];

        require(deal.amount != 0, "not found");

        require(msg.sender == deal.to, "recipient missmatch");

        require(deal.state == DealState.UNLOCKED, "state transition missmatch");

        payable(msg.sender).transfer(deal.amount);

        deal.state = DealState.CLAIMED;

        balanceOf[deal.from] -= deal.amount;
    }
}
