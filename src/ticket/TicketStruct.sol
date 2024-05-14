// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract TicketStruct {
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
    //门票信息数据结构
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

    //交易记录数据结构
    struct TransferRecord {
        address from;
        address to;
        uint256 timeStamp;
    }
}
