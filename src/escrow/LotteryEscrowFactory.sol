// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {LotteryEscrow} from "./LotteryEscrow.sol";

contract LotteryEscrowFactory {
    /**
     * 演唱会与抵押品托管合约的映射
     * @param concertId 演唱会id
     * @param escrowAddress 抵押品托管合约的地址
     */
    event EscrowCreated(uint256 indexed concertId, address escrowAddress);

    mapping(uint256 => address) public escrows;

    function createEscrow(address organizer, uint256 concertId) public returns (address escrowAddress) {
        LotteryEscrow escrow = new LotteryEscrow(organizer, concertId);
        escrows[concertId] = address(escrow);
        escrowAddress = address(escrow);
        emit EscrowCreated(concertId, escrowAddress);
    }

    function getEscrowAddress(uint256 concertId) public view returns (address) {
        return escrows[concertId];
    }
}
