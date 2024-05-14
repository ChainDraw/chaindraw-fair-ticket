// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {LotteryEscrow} from "./LotteryEscrow.sol";
import {ConcertTicketNFT} from "../ticket/ConcertTicketNFT.sol";

/**
 * @title 抵押品工厂
 * @author Shaw
 * @notice
 */
contract LotteryEscrowFactory {
    /**
     * 事件——抵押品已创建
     * @param concertId 演唱会id
     * @param ticketType 票种类唯一键
     * @param escrowAddress 抵押品合约地址
     */
    event EscrowCreated(
        uint256 indexed concertId, uint256 indexed ticketType, address escrowAddress, address ticketAddress
    );

    /**
     * @notice key票种类唯一键，value 抵押品合约地址
     */
    mapping(uint256 ticketType => address escrow) public escrows;

/**
 * @notice 抵押品合约地址与门票合约地址映射
 */
    mapping(address escrow => address ticket) public escrowsMapTickets;

    function createEscrow(
        address _organizer,
        uint256 _concertId,
        uint256 _ticketType,
        string memory _typeName,
        string memory _name,
        uint256 _price,
        string memory _url,
          uint256 _ticketCount,
        uint256 _ddl
      
    ) public returns (address escrowAddress, address ticketAddress) {
        //新建一个门票实例
        ConcertTicketNFT ticket = new ConcertTicketNFT(_name, _typeName);
        //新建一个抵押品实例
        LotteryEscrow escrow =
            new LotteryEscrow(_organizer, _concertId, _ticketType, _typeName, _name, _price, _url,_ticketCount, _ddl, ticket);
        //记录门票类型唯一键值与抵押品合约地址映射
        escrows[_ticketType] = address(escrow);
        escrowAddress = address(escrow);
        //记录抵押品合约地址和门票合约地址映射
        escrowsMapTickets[escrowAddress] = address(ticket);
        ticketAddress = address(ticket);
        emit EscrowCreated(_concertId, _ticketType, escrowAddress, ticketAddress);
    }

    function getEscrowAddressByTicketType(uint256 ticketType) public view returns (address) {
        return escrows[ticketType];
    }
}
