// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ConcertTicket} from "../ticket/ConcertTicket.sol";
import {VRFConsumerBase} from "@chainlink/contracts/src/v0.8/dev/VRFCaonsumerBase.sol";

/**
 * @title 门票抵押品托管及门票抽选
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
    string private typeName;
    string private name;
    uint256 private immutable price;
    string private url;
    //订阅抽选结束时间，定时器抽奖时间晚于这个时间就行
    uint256 private ddl;
    // 抽选队列
    address[] private allBuyer;
    //门票实例：一场演唱会的一种门票对应一个门票实例
    ConcertTicket private concertTicket;

    //门票信息数据结构
    struct TicketInfo {
        uint256 concertId;
        uint256 ticketType;
        string typeName;
        uint256 ticketId;
        string name;
        uint256 price;
        string url;
        address belongs;
        bool used;
        TransferRecord[] transferRecords;
    }
    //交易记录数据结构

    struct TransferRecord {
        address from;
        address to;
        uint256 timeStamp;
    }
    /**
     * @notice 购票者与缴纳抵押品价值 映射
     */

    mapping(address => uint256) public deposits;

    constructor(
        address _organizer,
        uint256 _concertId,
        uint256 _ticketType,
        string memory _typeName,
        string memory _name,
        uint256 _price,
        string memory _url,
        uint256 _ddl,
        ConcertTicket _ticket
    ) Ownable(_organizer) {
        organizer = _organizer;
        concertId = _concertId;
        ticketType = _ticketType;
        typeName = _typeName;
        name = _name;
        price = _price;
        url = _url;
        ddl = _ddl;
        concertTicket = _ticket;
    }

    /**
     * 报名时候缴纳抵押品并加入抽选队列
     */
    function deposit() public payable {
        require(msg.value > price, "Deposit must be greater than ticketPrice");
        if (deposits[msg.sender] == 0) {
            allBuyer.push(msg.sender); // 如果是新存款者，添加到数组中，相当于enterRaffle了
        }
        deposits[msg.sender] += msg.value;
        emit LotteryEscrow__Deposited(msg.sender, msg.value);
    }

    /**
     * 未中奖者退回抵押品
     * @param participant 未中奖者
     */
    function refund(address participant) public {
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

    function getAllBuyer() private view returns (address[] memory) {
        return allBuyer;
    }
}
