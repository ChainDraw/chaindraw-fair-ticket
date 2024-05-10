// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title 门票抵押品托管
 * @author Shaw
 * @notice
 */
contract LotteryEscrow is Ownable {
    /**
     * 事件——购票者已缴纳抵押品
     * @param buyer 购票者地址
     * @param money 缴纳金额
     */
    event LotteryEscrow__Deposited(address buyer, uint256 money);
    /**
     * 事件——购票者已被退回抵押品
     * @param buyer 购票者地址
     * @param money 金额
     */
    event LotteryEscrow__Refunded(address buyer, uint256 money);
    /**
     * 事件——抵押品已转给演唱会组织者
     * @param concertId 演唱会id
     * @param ticketType 门票种类
     * @param organizer 组织者钱包地址
     * @param money 金额
     */
    event LotteryEscrow__ClaimedFunds(
        uint256 indexed concertId, uint256 indexed ticketType, address organizer, uint256 money
    );

    address private immutable organizer;
    uint256 private immutable concertId;
    uint256 private immutable ticketType;
    uint256 private immutable ticketPrice;

    mapping(address => uint256) public deposits;

    constructor(address _organizer, uint256 _concertId, uint256 _ticketType, uint256 _ticketPrice)
        Ownable(msg.sender)
    {
        organizer = _organizer;
        concertId = _concertId;
        ticketType = _ticketType;
        ticketPrice = _ticketPrice;
    }

    /**
     * 报名时候缴纳抵押品
     */
    function deposit() public payable {
        require(msg.value > ticketPrice, "Deposit must be greater than ticketPrice");
        deposits[msg.sender] += msg.value;
        emit LotteryEscrow__Deposited(msg.sender, msg.value);
    }

    /**
     * 未中奖者退回抵押品
     * @param participant 未中奖者
     */
    function refund(address participant) public onlyOwner {
        uint256 amount = deposits[participant];
        require(amount > 0, "No deposit to refund");
        deposits[participant] = 0;
        payable(participant).transfer(amount);
        emit LotteryEscrow__Refunded(participant, amount);
    }

    /**
     * 当前抵押品合约的钱打给活动组织者
     */
    function claimFunds() public onlyOwner {
        uint256 amount = address(this).balance;
        // transfer funds to the lottery organizer or for ticket payment
        payable(organizer).transfer(amount);
        emit LotteryEscrow__ClaimedFunds(concertId, ticketType, organizer, amount);
    }
}
