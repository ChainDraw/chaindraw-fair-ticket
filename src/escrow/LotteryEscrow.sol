// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

/**
 * @title 门票抵押品托管
 * @author Shaw
 * @notice
 */
contract LotteryEscrow {
    mapping(address => uint256) public deposits;
    address private immutable organizer;
    uint256 private immutable concertId;
     
     constructor(address _organizer,uint256 _concertId){
        organizer = _organizer;
        concertId = _concertId;
     }

    /**
     * 报名时候缴纳抵押品
     */
    function deposit() public payable {
        require(msg.value > 0, "Deposit must be greater than 0");
        deposits[msg.sender] += msg.value;
    }

    /**
     * 未中奖者退回抵押品
     * @param participant 未中奖者
     */
    function refund(address participant) public {
        uint256 amount = deposits[participant];
        require(amount > 0, "No deposit to refund");
        deposits[participant] = 0;
        payable(participant).transfer(amount);
    }

    /**
     * 当前合约的钱打给活动组织者
     */
    function claimFunds() public {
        uint256 amount = address(this).balance;
        // transfer funds to the lottery organizer or for ticket payment
        payable(organizer).transfer(amount);
    }
}
