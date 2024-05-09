// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {LotteryEscrow} from "./LotteryEscrow.sol";

contract LotteryEscrowFactory {
   
    event EscrowCreated(uint256 indexed concertId,uint256 indexed  ticketType,address escrowAddress,uint256 ticketPrice);

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
