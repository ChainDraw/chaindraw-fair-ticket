// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";
import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {VRFV2WrapperConsumerBase} from "@chainlink/contracts/src/v0.8/VRFV2WrapperConsumerBase.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

error LotteryEscrowError__alreadyJoin();
error LotteryEscrowError__DepositTimeOut();

/**
 * @title 门票抵押品托管及门票抽选
 * @author Shaw
 * @notice
 */
contract LotteryEscrow is ERC721, ERC721URIStorage, ConfirmedOwner, ReentrancyGuard, VRFV2WrapperConsumerBase {
    event LotteryEscrow__Deposited(uint256 indexed concertId, uint256 indexed ticketType, address buyer, uint256 money);
    event LotteryEscrow__Refunded(uint256 indexed concertId, uint256 indexed ticketType, address buyer, uint256 money);
    event LotteryEscrow__ClaimedFund(
        uint256 indexed concertId, uint256 indexed ticketType, address organizer, address winner, uint256 money
    );
    event LotteryEscrow__NonWinner(
        uint256 indexed concertId, uint256 indexed ticketType, address nonWinner, uint256 money
    );
    event LotteryEscrow__Winner(uint256 indexed concertId, uint256 indexed ticketType, address winner);
    event LotteryEscrow__CompleteDraw(address lotteryAddress);
    event ChainlinkVrf__RequestSent(uint256 requestId, uint32 numWords);
    event ChainlinkVrf__RequestFulfilled(uint256 requestId, uint256[] randomWords, uint256 payment);

    uint256 private _nextTokenId;
    address public immutable Factory;
    address public immutable organizer;
    uint256 public immutable concertId;
    uint256 public immutable ticketType;
    uint256 public immutable price;
    string public url;
    uint256 public ddl;
    uint256 public ticketCount;
    address[] public allBuyer;
    address private linkAddress = 0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06;
    address private wrapperAddress = 0x699d428ee890d55D56d5FC6e26290f3247A762bd;
    uint256[] public requestIds;
    uint256 public lastRequestId;
    uint32 callbackGasLimit = 2000000;
    uint16 requestConfirmations = 3;
    bool private lotteryEnded;
    bool public completeDraw;
    uint32 public remainingTicketCount;
    uint256 private constant LINK_FEE = 1e18; // 1 LINK
    LinkTokenInterface public linkToken;

    struct RequestStatus {
        uint256 paid;
        bool fulfilled;
        uint256[] randomWords;
    }

    mapping(address => uint256) public deposits;
    mapping(uint256 => RequestStatus) public s_requests;
    mapping(address => bool) public isWinner;
    //交易记录数据结构

    constructor(
        address _organizer,
        uint256 _concertId,
        uint256 _ticketType,
        string memory _typeName,
        string memory _name,
        uint256 _price,
        string memory _url,
        uint256 _ticketCount,
        uint256 _ddl
    ) ERC721(_name, _typeName) VRFV2WrapperConsumerBase(linkAddress, wrapperAddress)  ConfirmedOwner(msg.sender){
        Factory = msg.sender;
        organizer = _organizer;
        concertId = _concertId;
        ticketType = _ticketType;
        price = _price;
        url = _url;
        ticketCount = _ticketCount;
        ddl = _ddl;
        remainingTicketCount = uint32(_ticketCount);
        linkToken = LinkTokenInterface(linkAddress);
    }

    modifier checkTimeOut(uint256 _ddl) {
        if (block.timestamp > _ddl) {
            revert LotteryEscrowError__DepositTimeOut();
        }
        _;
    }

    function withdrawLink(uint256 _amount) external onlyOwner {
        require(linkToken.transfer(msg.sender, _amount), "Transfer failed");
    }

    function deposit() public payable checkTimeOut(ddl) {
        require(msg.value == price, "Deposit must be eq ticketPrice");
        if (deposits[msg.sender] > 0) {
            revert LotteryEscrowError__alreadyJoin();
        }
        allBuyer.push(msg.sender);
        deposits[msg.sender] += msg.value;
        emit LotteryEscrow__Deposited(concertId, ticketType, msg.sender, msg.value);
    }

    function refund(address participant) external {
        uint256 depositAmount = deposits[participant];
        require(depositAmount > 0, "No deposit to refund");
        require(completeDraw, "The lottery is in progress");
        deposits[participant] = 0;
        payable(participant).transfer(depositAmount);

        emit LotteryEscrow__Refunded(concertId, ticketType, participant, depositAmount);
    }

    function startLottery() external nonReentrant {
        require(block.timestamp > ddl, "Lottery not started yet");
        require(!lotteryEnded, "Lottery has already ended");
        require(allBuyer.length > 0, "No participants in the lottery");
        uint256 linkBalance = linkToken.balanceOf(address(this));
        require(linkBalance >= LINK_FEE, "Not enough LINK");
        if (allBuyer.length > ticketCount) {
            requestNextRandomWords();
        } else {
            allBuyerShorterThanTicketCount();
        }
    }

    function allBuyerShorterThanTicketCount() private {
        for (uint256 i = 0; i < allBuyer.length; i++) {
            address winner = allBuyer[i];
            emit LotteryEscrow__Winner(concertId, ticketType, winner);
            deposits[winner] = 0;
            isWinner[winner] = true;
            payable(organizer).transfer(price);
            mintTicketNft(winner);
            emit LotteryEscrow__ClaimedFund(concertId, ticketType, organizer, winner, price);
        }
        remainingTicketCount == 0;
        lotteryEnded = true;
        completeDraw = true;
    }

    function requestNextRandomWords() private returns (uint256 requestId) {
        uint32 numWords = (remainingTicketCount > 10) ? 10 : remainingTicketCount;

        requestId = requestRandomness(callbackGasLimit, requestConfirmations, numWords);
        s_requests[requestId] = RequestStatus({
            paid: VRF_V2_WRAPPER.calculateRequestPrice(callbackGasLimit),
            randomWords: new uint256[](10),
            fulfilled: false
        });

        requestIds.push(requestId);
        lastRequestId = requestId;
        remainingTicketCount -= numWords;
        if (remainingTicketCount == 0) {
            lotteryEnded = true;
        }
        emit ChainlinkVrf__RequestSent(requestId, numWords);
        return requestId;
    }

    function mintTicketNft(address winner) private {
        uint256 tokenId = _nextTokenId++;
        _mint(winner, tokenId);
        _setTokenURI(tokenId, url);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal override {
        require(s_requests[_requestId].paid > 0, "Request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        uint256 winnersCount = _randomWords.length;
        for (uint256 i = 0; i < winnersCount; i++) {
            uint256 winnerIndex = _randomWords[i] % allBuyer.length;
            address winner = allBuyer[winnerIndex];
            emit LotteryEscrow__Winner(concertId, ticketType, winner);
            deposits[winner] = 0;
            isWinner[winner] = true;
            payable(organizer).transfer(price);
            mintTicketNft(winner);
            emit LotteryEscrow__ClaimedFund(concertId, ticketType, organizer, winner, price);
        }
        if (remainingTicketCount == 0) {
            completeDraw = true;
        }
        emit ChainlinkVrf__RequestFulfilled(_requestId, _randomWords, s_requests[_requestId].paid);

        // 简化非赢家退款逻辑
       // refundNonWinners();
    }

    function refundNonWinners() internal {
        for (uint256 i = 0; i < allBuyer.length; i++) {
            if (deposits[allBuyer[i]] > 0) {
                uint256 depositAmount = deposits[allBuyer[i]];
                deposits[allBuyer[i]] = 0;
                payable(allBuyer[i]).transfer(depositAmount);
                emit LotteryEscrow__NonWinner(concertId, ticketType, allBuyer[i], depositAmount);
            }
        }
    }

    receive() external payable {
        revert("Direct payments not allowed");
    }
}
