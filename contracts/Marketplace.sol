//SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import "hardhat/console.sol";

contract Marketplace is Ownable{    
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    IERC20 token;
    IERC721 itemToken;

    struct Item {
        uint256 id;
        address vendor;
        uint price;
        bool available;
    }

    mapping(uint256 => Item) public items;
    //mapping(address => Item[]) public getItemsByVendor;
    event SellItem (address vendor, uint256 id, uint price);
    event BuyItem (address vendor, address seller, uint256 id, uint price);

    constructor (IERC20 _token, IERC721 _itemToken) {
        token = _token;
        itemToken = _itemToken;
    }

    function sellItems (uint256 tokenId, uint price) public {
        require(itemToken.ownerOf(tokenId) == msg.sender, "You are not the owner of this item.");
        require(price > 0, "Price must be greater than 0.");
        require(itemToken.getApproved(tokenId) == address(this), "This item has not yet been approved.");

        items[tokenId] = Item(tokenId, msg.sender, price, true);
        emit SellItem(msg.sender, tokenId, price);
    }


    function buyItem (uint256 tokenId) public payable {
        require(itemToken.getApproved(tokenId) == address(this), "This item has not yet been approved.");
        require(itemToken.ownerOf(tokenId) != msg.sender, "You are the owner of this item.");
        Item storage item = items[tokenId];

        require(item.available, "This item was sold.");
        item.available = false;
        uint ownerBalance = token.balanceOf(msg.sender);
        uint vendorBalance = token.balanceOf(item.vendor);
        token.safeTransferFrom(msg.sender, item.vendor, item.price);

        require(token.balanceOf(msg.sender) <= ownerBalance.sub(item.price) && token.balanceOf(item.vendor) >= vendorBalance.add(item.price), "The transfer has not been processed");

        itemToken.safeTransferFrom(item.vendor, msg.sender, tokenId);

        require(itemToken.ownerOf(tokenId) == msg.sender, "Item transfer was not completed.");

        emit BuyItem(item.vendor, msg.sender, tokenId, item.price);
    }
}