// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {TicketStruct} from "../ticket/TicketStruct.sol";

contract ConcertTicketNFT is ERC721, Ownable {
    event ConcertTicket__CreatedTicketNFT(uint256 concertId, uint256 ticketType, address belongs);

    /**
     * @notice 门票信息
     */
    mapping(uint256 ticketId => TicketStruct.TicketInfo) public ticketInfos;

    constructor(string memory _name, string memory _typeName) ERC721(_name, _typeName) Ownable(msg.sender) {}

    function mintTicketNft(TicketStruct.TicketInfo memory _ticketInfo) public {
        uint256 ticketId = _ticketInfo.ticketId;
        _safeMint(msg.sender, ticketId);
        //记录每张门票nft状态
        TicketStruct.TicketInfo storage newTicketInfo = ticketInfos[ticketId];
        // 复制TransferRecord数组
        for (uint256 i = 0; i < _ticketInfo.transferRecords.length; i++) {
            newTicketInfo.transferRecords.push(_ticketInfo.transferRecords[i]);
        }
        emit ConcertTicket__CreatedTicketNFT(_ticketInfo.concertId, _ticketInfo.ticketType, _ticketInfo.belongs);
    }
}
