// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract ConcertTicket is ERC721, Ownable {

    event ConcertTicket__CreatedTicketNFT(uint256 concertId,uint256 ticketType,address belongs, uint256 timeStamp);
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
        TransferRecord transferRecord;
    }

    struct TransferRecord {
        address from;
        address to;
        uint256 timeStamp;
    }

    TicketInfo private ticketInfo;

    constructor(
        uint256 _concertId,
        uint256 _ticketType,
        string memory _typeName,
        uint256 _ticketId,
        string memory _name,
        uint256 _price,
        string memory _url,
        address _belongs,
        bool _used,
        address _from,
        address _to,
        uint256 _timeStamp
    ) ERC721(_name, _typeName) Ownable(_belongs) {
        ticketInfo = TicketInfo({
            concertId: _concertId,
            ticketType: _ticketType,
            typeName: _typeName,
            ticketId: 0,
            name: _name,
            price: _price,
            url: _url,
            belongs: _belongs,
            used: false,
            transferRecord: TransferRecord({from: _from, to: _to, timeStamp: _timeStamp})
        });
    }


        function mintTicketNft() public {
        uint256 ticketId = ticketInfo.ticketId;
        _safeMint(msg.sender, ticketId);
        ticketInfo.ticketId = ticketInfo.ticketId + 1;
        emit ConcertTicket__CreatedTicketNFT(ticketInfo.concertId,ticketInfo.ticketType,ticketInfo.belongs,ticketInfo.transferRecord.timeStamp);
    }
}
