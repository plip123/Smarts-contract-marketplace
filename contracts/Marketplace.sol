//SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

import 'hardhat/console.sol';

contract Marketplace is Ownable{

    using SafeMath for uint256;

    //EVENTS
    event SellItem(uint price, uint id, bool isAvailable);
    event BuyItem(address buyer, address seller, uint id);

    struct Item {
        uint price;
        uint id;
        bool isAvailable;
    }

    IERC20 token;
    IERC721 itemsToken;

    mapping (uint => Item) public allItems;
    uint itemsCount = 0;  

    constructor(IERC20 _token, IERC721 _itemsToken){
        token = _token;
        itemsToken = _itemsToken;
    }
    /**
        @notice The user must have previously approved the marketplace to use his ERC721 token
        @dev User creates item in the marketplace to sell it
    */
    function sellItem(uint id, uint price) public {
        // itemsToken.approve(address(this),id);
        Item memory newOne = Item({price: price, id: id, isAvailable: true});
        allItems[id] = newOne;

        emit SellItem(price, id, true);
        // new event
    }

    /**
        @notice The user must have previously approved the marketplace to use his ERC20 token
        @dev User buys an item from the marketplace
    */
    function buyItem(uint id) public{
        Item storage item = allItems[id];

        require(token.balanceOf(msg.sender) >= item.price, "Not enough balance to buy this item");
        // token.approve(address(this), item.price);

        require(itemsToken.ownerOf(id) != msg.sender, "This is your own item");
        require(token.allowance(msg.sender, address(this)) >= item.price, "Not enough allowance");

        uint buyerBalance = token.balanceOf(msg.sender);
        uint sellerBalance = token.balanceOf(itemsToken.ownerOf(id));

        token.transferFrom(msg.sender, itemsToken.ownerOf(id), item.price);

        require(token.balanceOf(msg.sender) <= buyerBalance.sub(item.price), "Transfer did not succeed");
        require(token.balanceOf(itemsToken.ownerOf(id)) >= sellerBalance.add(item.price), "Transfer did not succeed");
        
        itemsToken.safeTransferFrom(itemsToken.ownerOf(id), msg.sender, id);

        emit BuyItem(msg.sender, itemsToken.ownerOf(id), id);
        // new event
    }

}