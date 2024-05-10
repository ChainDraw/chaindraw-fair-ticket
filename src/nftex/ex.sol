// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {ReentrancyGuard} from "openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

contract NFTExchange is ReentrancyGuard{
    error NFTExchange__NoEnoughMoney();
    error NFTExchange__NoEnoughAllowance();
    error NFTExchange__TransferFailed();
    error NFTExchange__TicketUsed();
    error NFTExchange__NotTicketOwner();

    event NFTExchange__SuccessPriced(address indexed nftAddress, uint256 indexed tokenId, uint256 price);
    event NFTExchange__SuccessExchange(address indexed nftAddress, uint256 indexed tokenId, address seller, address buyer, uint256 price);
    // 票nft的合约地址
    ConcertTicket private i_nft;
    IERC20 private immutable i_erc20;
    mapping(uint256 tokenId => uint256 sellPrice) private s_tokenPrices;

    constructor(address _nftAddress, address i_erc20Address) {
        i_nft = ConcertTicket(_nftAddress);
        i_erc20 = IERC20(i_erc20Address);
    }
    // todo modifier 非重入
    function buyTicket(uint256 tokenId) public nonReentrant  {
        address buyer = msg.sender;
        // 1. 获取票的信息
        Ticket memory ticket = i_nft.getTicket(tokenId);
        uint256 sellPrice = s_tokenPrices[tokenId];
        // 2. 判断票的合法性
        address seller = i_nft.tokenOwner(tokenId);
        require(seller == ticket.owner, "The seller is not the owner of the ticket");
        // 3. 检查买家的授权余额
        if (sellPrice > i_erc20.allowance(buyer)) {
            revert NFTExchange__NoEnoughAllowance();
        }
        // 4. 转钱  这一步之前需要让buyer approve erc20
        bool success = i_erc20.transferFrom(buyer, seller, sellPrice);
        if (!success) {
            revert NFTExchange__TransferFailed();
        }
        // 5. 修改票的拥有者
        i_nft.changeOwner(tokenId, buyer);
        emit NFTExchange__SuccessExchange(address(i_nft), tokenId, seller, buyer, sellPrice);
    }

    function orderTicket(uint256 tokenId, uint256 sellPrice) public nonReentrant  {
        address seller = msg.sender;
        // 1. 获取票的信息
        Ticket memory ticket = i_nft.getTicket(tokenId);
        if ( ticket.owner != seller) {
            revert NFTExchange__NotTicketOwner();
        }
        // 检查票是不是被使用了
        if (ticket.used) {
            revert NFTExchange__TicketUsed();
        }
        // 2. 售卖信息存到合约中
        s_tokenPrices[tokenId] = sellPrice;
        emit NFTExchange__SuccessPriced(i_nft, tokenId, sellPrice);
    }
}