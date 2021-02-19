//SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract Marketplace is Ownable{

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    //EVENTS
    event SellItem(address seller, uint price, uint id);
    event BuyItem(address buyer, address seller, uint id, uint price);

    struct Item {
        address seller;
        uint price;
        uint id;
        bool available;
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
        // user can not buy his own item
        require(itemsToken.ownerOf(id) == msg.sender, "This is not your item");

        // the marketplace should have been approved to sell the item
        require(itemsToken.getApproved(id) == address(this), "Not allowed to sell");

        Item memory newOne = Item({seller: msg.sender, price: price, id: id, available: true});
        allItems[id] = newOne;

        emit SellItem(msg.sender, price, id);
    }

    /**
        @notice The user must have previously approved the marketplace to use his ERC20 token
        @dev User buys an item from the marketplace
    */
    function buyItem(uint id) public {
        require(itemsToken.ownerOf(id) != msg.sender, "This is your own item");

        Item storage item = allItems[id];

        require(item.available, "Item already sold");
        item.available = false;

        // get current buyer/seller balances
        uint buyerBalance = token.balanceOf(msg.sender);
        uint sellerBalance = token.balanceOf(itemsToken.ownerOf(id));
        
        // execute ERC20 transfer
        token.safeTransferFrom(msg.sender, itemsToken.ownerOf(id), item.price);

        // validate transfer success
        require(token.balanceOf(msg.sender) <= buyerBalance.sub(item.price) && token.balanceOf(itemsToken.ownerOf(id)) >= sellerBalance.add(item.price), "Transfer did not succeed");
        
        // execute ERC721 transfer
        itemsToken.safeTransferFrom(itemsToken.ownerOf(id), msg.sender, id);

        emit BuyItem(msg.sender, item.seller, id, item.price);

        item.price = 0;
        // new event
    }

}