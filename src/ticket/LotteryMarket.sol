// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IFactory {
    function isRegistered(address lotteryAddress) external view returns (bool);
}

interface ILottery {
    function price() external view returns (uint256);
}

contract LotteryMarket is ReentrancyGuard, Ownable {
    struct Listing {
        address seller;
        address lotteryAddress;
        uint256 tokenId;
        uint256 price;
    }
    address public factoryAddress;
    mapping(address => mapping(uint256 => Listing)) public listings;
    event NFTListed(
        address indexed seller,
        address indexed lotteryAddress,
        uint256 indexed tokenId,
        uint256 price
    );
    event NFTSold(
        address indexed buyer,
        address indexed lotteryAddress,
        uint256 indexed tokenId,
        uint256 price
    );
    event NFTDelisted(
        address indexed seller,
        address indexed lotteryAddress,
        uint256 indexed tokenId
    );

    constructor(address _factoryAddress) Ownable(msg.sender) {
        factoryAddress = _factoryAddress;
    }

    modifier onlyRegistered(address lotteryAddress) {
        require(
            IFactory(factoryAddress).isRegistered(lotteryAddress),
            "Lottery contract not registered"
        );
        _;
    }

    // 上架
    function listNFT(
        address lotteryAddress,
        uint256 tokenId,
        uint256 price
    ) external nonReentrant onlyRegistered(lotteryAddress) {
        IERC721 token = IERC721(lotteryAddress);
        require(token.ownerOf(tokenId) == msg.sender, "Not the owner");
        ILottery lottery = ILottery(lotteryAddress);
        require(price <= lottery.price(), "Price exceeds lottery price");
        token.safeTransferFrom(msg.sender, address(this), tokenId);
        listings[lotteryAddress][tokenId] = Listing({
            seller: msg.sender,
            lotteryAddress: lotteryAddress,
            tokenId: tokenId,
            price: price
        });
        emit NFTListed(msg.sender, lotteryAddress, tokenId, price);
    }

    // 购买
    function buyNFT(
        address lotteryAddress,
        uint256 tokenId
    ) external payable nonReentrant {
        Listing memory listing = listings[lotteryAddress][tokenId];
        require(listing.price > 0, "NFT not listed for sale");
        require(msg.value == listing.price, "Incorrect value sent");
        payable(listing.seller).transfer(listing.price);
        IERC721(lotteryAddress).safeTransferFrom(
            address(this),
            msg.sender,
            tokenId
        );
        delete listings[lotteryAddress][tokenId];

        emit NFTSold(msg.sender, lotteryAddress, tokenId, listing.price);
    }

    // 下架
    function delistNFT(
        address lotteryAddress,
        uint256 tokenId
    ) external nonReentrant {
        Listing memory listing = listings[lotteryAddress][tokenId];
        require(listing.seller == msg.sender, "Not the seller");
        IERC721(lotteryAddress).safeTransferFrom(
            address(this),
            listing.seller,
            tokenId
        );
        delete listings[lotteryAddress][tokenId];
        emit NFTDelisted(msg.sender, lotteryAddress, tokenId);
    }

    receive() external payable {
        revert("Direct payments not allowed");
    }
}
