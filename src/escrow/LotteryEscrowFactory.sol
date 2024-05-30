// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {LotteryEscrow} from "./LotteryEscrow.sol";

error TicketTypeAlreadyExists();

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
        string  concertId,
        uint256 indexed ticketType,
        address escrowAddress
    );
    /**
     * @notice key票种类唯一键，value 抵押品合约地址
     */
    address[] public allEscrows;
    mapping(uint256 => address) public escrows;
    mapping(address => bool) public isRegistered;
    modifier checkTicketType(uint256 _ticketType) {
        if (escrows[_ticketType] != address(0)) {
            revert TicketTypeAlreadyExists();
        }
        _;
    }

    function createEscrow(
        address _organizer,
        string memory _concertId,
        uint256 _ticketType,
        string memory _typeName,
        string memory _name,
        uint256 _price,
        string memory _url,
        uint256 _ticketCount,
        uint256 _ddl
    ) public checkTicketType(_ticketType) returns (address escrowAddress) {
        //新建一个抵押品实例
        LotteryEscrow escrow = new LotteryEscrow(
            _organizer,
            _concertId,
            _ticketType,
            _typeName,
            _name,
            _price,
            _url,
            _ticketCount,
            _ddl
        );
        //记录门票类型唯一键值与抵押品合约地址映射
        escrows[_ticketType] = address(escrow);
        escrowAddress = address(escrow);
        isRegistered[escrowAddress] = true;
        allEscrows.push(escrowAddress);
        emit EscrowCreated(_concertId, _ticketType, escrowAddress);
    }

    function getEscrowAddressByTicketType(
        uint256 ticketType
    ) public view returns (address) {
        return escrows[ticketType];
    }

    receive() external payable {
        revert("Direct payments not allowed");
    }
}
