// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {LotteryEscrow} from "./LotteryEscrow.sol";

/**
 * @title 抵押品工厂
 * @author Shaw
 * @notice 
 */
contract LotteryEscrowFactory {
   
   /**
    * 事件——抵押品已创建
    * @param concertId 演唱会id
    * @param ticketType 票种类
    * @param escrowAddress 抵押品合约地址
    * @param ticketPrice 票价
    */
    event EscrowCreated(uint256 indexed concertId,uint256 indexed  ticketType,address escrowAddress,uint256 ticketPrice);

/**
 * @notice key票种类，value 抵押品合约地址
 */
    mapping(uint256 => address) public escrows;

    function createEscrow(address _organizer,uint256 _concertId,uint256 _ticketType,uint256 _ticketPrice  ) public returns (address escrowAddress) {
        LotteryEscrow escrow = new LotteryEscrow(_organizer, _concertId,_ticketType,_ticketPrice);
        escrows[_ticketType] = address(escrow);
        escrowAddress = address(escrow);
        emit EscrowCreated(_concertId,_ticketType, escrowAddress,_ticketPrice);
    }

     function getEscrowAddressByTicketType(uint256 ticketType) public view returns (address) {
        return escrows[ticketType];
    }
}
