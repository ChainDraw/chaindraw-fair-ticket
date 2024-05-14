// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract ConcertTicket is ERC721, Ownable {
    event ConcertTicket__CreatedTicketNFT(uint256 concertId, uint256 ticketType, address belongs);
    /**
     * struct  门票{
     * 演唱会唯一标识符
     * 票种类唯一键
     * 门票类型名称
     * 门票唯一标识符
     * 门票名称
     * 价格
     * 封面url
     * 所有者
     * 验票状态
     * 二手交易历史
     * }
     */

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

    struct TransferRecord {
        address from;
        address to;
        uint256 timeStamp;
    }

/**
 * @notice 门票信息
 */
    mapping(uint256 ticketId => TicketInfo) public ticketInfos;

    constructor(string memory _name, string memory _typeName) ERC721(_name, _typeName) Ownable(msg.sender) {}

    function mintTicketNft(TicketInfo memory ticketInfo) public {
        uint256 ticketId = ticketInfo.ticketId;
        _safeMint(msg.sender, ticketId);
        //记录每张门票nft状态
       // 创建一个新的TicketInfo存储实例
        TicketInfo storage newTicketInfo = ticketInfos[ticketId];
        newTicketInfo.concertId = ticketInfo.concertId;
        newTicketInfo.ticketType = ticketInfo.ticketType;
        newTicketInfo.typeName = ticketInfo.typeName;
        newTicketInfo.ticketId = ticketId;
        newTicketInfo.name = ticketInfo.name;
        newTicketInfo.price = ticketInfo.price;
        newTicketInfo.url = ticketInfo.url;
        newTicketInfo.belongs = ticketInfo.belongs;
        newTicketInfo.used = ticketInfo.used;
        // 复制TransferRecord数组
        for (uint256 i = 0; i < ticketInfo.transferRecords.length; i++) {
            newTicketInfo.transferRecords.push(ticketInfo.transferRecords[i]);
        }
        emit ConcertTicket__CreatedTicketNFT(ticketInfo.concertId, ticketInfo.ticketType, ticketInfo.belongs);
    }
}
