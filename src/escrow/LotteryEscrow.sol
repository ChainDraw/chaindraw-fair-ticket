// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ConcertTicketNFT} from "../ticket/ConcertTicketNFT.sol";
import {VRFV2WrapperConsumerBase} from "@chainlink/contracts/src/v0.8/VRFV2WrapperConsumerBase.sol";
import {TicketStruct} from "../ticket/TicketStruct.sol";
/**
 * @title 门票抵押品托管及门票抽选
 * @author Shaw
 * @notice
 */

contract LotteryEscrow is Ownable, VRFV2WrapperConsumerBase {

/**
 *  错误————订阅抽票超时
 */
    error DepositTimeOut();

    /**
     * 事件——购票者已缴纳抵押品
     * @param buyer 购票者地址
     * @param money 缴纳金额
     */
    event LotteryEscrow__Deposited(uint256 indexed concertId, uint256 indexed ticketType, address buyer, uint256 money);
    /**
     * 事件——购票者已被退回抵押品
     * @param buyer 购票者地址
     * @param money 金额
     */
    event LotteryEscrow__Refunded(uint256 indexed concertId, uint256 indexed ticketType, address buyer, uint256 money);
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

    /**
     * 事件——未中奖者
     * @param concertId 演唱会id
     * @param ticketType 票种类型唯一键
     * @param nonWinner 未中奖者地址
     * @param money 退款
     */
    event LotteryEscrow__NonWinner(
        uint256 indexed concertId, uint256 indexed ticketType, address nonWinner, uint256 money
    );

    /**
     * 事件——中奖者
     * @param concertId 演唱会id
     * @param ticketType 票种类型唯一键
     * @param winner 中奖者地址
     */
    event LotteryEscrow__Winner(uint256 indexed concertId, uint256 indexed ticketType, address winner);

    /**
     * 事件——chainlinkvrf请求发送
     * @param requestId 参数
     * @param numWords 随机数的个数
     */
    event ChainlinkVrf__RequestSent(uint256 requestId, uint32 numWords);
    /**
     * 事件———chainlinkvrf已经使用
     * @param requestId 参数
     * @param randomWords 随机数的个数
     * @param payment 支付金额
     */
    event CHainlinkVrf__RequestFulfilled(uint256 requestId, uint256[] randomWords, uint256 payment);

    address private immutable organizer;
    uint256 private immutable concertId;
    uint256 private immutable ticketType;
    string private typeName;
    string private name;
    uint256 private immutable price;
    string private url;
    uint256 private ticketCount;
    //订阅抽选结束时间，定时器抽奖时间晚于这个时间就行
    uint256 private ddl;
    // 抽选队列
    address[] private allBuyer;

    //门票实例：一场演唱会的一种门票对应一个门票实例
    ConcertTicketNFT private concertTicketNFT;

    //购票者与缴纳抵押品价值 映射
    mapping(address => uint256) public deposits;


 modifier checkTimeOut(uint256 _ddl) {
        if (block.timestamp > _ddl) {
            revert DepositTimeOut();
        }
        _;
    }
    ///////////////////
    // chainlink vrf相关
    ///////////////////
    address private linkAddress = 0x779877A7B0D9E8603169DdbD7836e478b4624789;
    address private wrapperAddress = 0xab18414CD93297B0d12ac29E63Ca20f515b3DB46;

    uint256[] public requestIds;
    uint256 public lastRequestId;
    uint32 callbackGasLimit = 100000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 1;

    struct RequestStatus {
        uint256 paid; // amount paid in link
        bool fulfilled; // whether the request has been successfully fulfilled
        uint256[] randomWords;
    }

    mapping(uint256 => RequestStatus) public s_requests; /* requestId --> requestStatus */

    constructor(
        address _organizer,
        uint256 _concertId,
        uint256 _ticketType,
        string memory _typeName,
        string memory _name,
        uint256 _price,
        string memory _url,
        uint256 _ticketCount,
        uint256 _ddl,
        ConcertTicketNFT _ticket
    ) VRFV2WrapperConsumerBase(linkAddress, wrapperAddress) Ownable(_organizer) {
        organizer = _organizer;
        concertId = _concertId;
        ticketType = _ticketType;
        typeName = _typeName;
        name = _name;
        price = _price;
        url = _url;
        ticketCount = _ticketCount;
        ddl = _ddl;
        concertTicketNFT = _ticket;
    }

    /**
     * 报名时候缴纳抵押品并加入抽选队列
     */
    function deposit() public checkTimeOut(ddl) payable {
        require(msg.value > price, "Deposit must be greater than ticketPrice");
        if (deposits[msg.sender] == 0) {
            allBuyer.push(msg.sender); // 如果是新存款者，添加到数组中，相当于enterRaffle了
        }
        deposits[msg.sender] += msg.value;
        emit LotteryEscrow__Deposited(concertId, ticketType, msg.sender, msg.value);
    }

    /**
     * 退回抵押品
     * @param participant 地址
     */
    function refund(address participant) public {
        uint256 amount = deposits[participant];
        require(amount > 0, "No deposit to refund");
        deposits[participant] = 0;
        payable(participant).transfer(amount);
        emit LotteryEscrow__Refunded(concertId, ticketType, participant, amount);
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

    function getAllBuyer() public view returns (address[] memory) {
        return allBuyer;
    }

    function getTicketPrice()public view returns(uint256){
        return price;
    }

    function requestRandomWords() external onlyOwner returns (uint256 requestId) {
        requestId = requestRandomness(callbackGasLimit, requestConfirmations, numWords);
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit ChainlinkVrf__RequestSent(requestId, numWords);
        return requestId;
    }

    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal override {
        uint256 participants = allBuyer.length;
        if (participants > ticketCount) {
            require(s_requests[_requestId].paid > 0, "request not found");
            s_requests[_requestId].fulfilled = true;
            s_requests[_requestId].randomWords = _randomWords;
            emit CHainlinkVrf__RequestFulfilled(_requestId, _randomWords, s_requests[_requestId].paid);
            // 使用Fisher-Yates洗牌算法对抽选者数组进行随机排序
            for (uint256 i = 0; i < participants - 1; i++) {
                uint256 j = i + (_randomWords[0] % (participants - i));
                (allBuyer[i], allBuyer[j]) = (allBuyer[j], allBuyer[i]);
            }

            //未中奖者退回抵押品
            for (uint256 n = ticketCount; n < participants; n++) {
                address nonWinner = allBuyer[n];
                uint256 money = deposits[nonWinner];
                this.refund(nonWinner);
                emit LotteryEscrow__NonWinner(concertId, ticketType, nonWinner, money);
            }
        }
        // 选出前ticketCount个地址作为中奖者
        for (uint256 k = 0; k < ticketCount && k < participants; k++) {
            address winner = allBuyer[k];
            uint256 ticketId = k + 1;

            // 创建一个新的 TicketInfo 实例
            TicketStruct.TicketInfo memory newTicketInfo = TicketStruct.TicketInfo({
                concertId: concertId,
                ticketType: ticketType,
                typeName: typeName,
                ticketId: ticketId,
                name: name,
                price: price,
                url: url,
                belongs: winner,
                used: false,
                transferRecords: new  TicketStruct.TransferRecord[](0)
            });
            
            // 发放门票逻辑
            concertTicketNFT.mintTicketNft(newTicketInfo);
        }
    }
}
