//SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import './MyTestToken20.sol';
import './MyTestToken721.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';

contract Marketplace{

    struct Item {
        string name;
        address owner;
        uint price;
        uint index;
        bool exist;
    }

    MyTestToken20 private token = new MyTestToken20();
    MyTestToken721 private itemsToken = new MyTestToken721();
    address owner;
    mapping (uint => Item) allItems;
    uint itemsCount = 0;

    constructor(){
        owner = msg.sender;
    }

    function open() public pure returns (string memory){
        return "Marketplace is open";
    }

    function getValues() public view returns (string memory, string memory, uint, uint){
        return (token.name(),token.symbol(), token.totalSupply(), token.balanceOf(msg.sender));
    }

    function getValues2() public view returns (string memory, string memory, uint, uint){
        return (itemsToken.name(),itemsToken.symbol(), itemsToken.totalSupply(), itemsToken.balanceOf(msg.sender));
    }

    function assignCredit(address to, uint amount) public {
        require(msg.sender == owner);
        token.giveCredit(to, amount);
    }

    function getBalance() public view returns (uint){
        return token.balanceOf(msg.sender);
    }

    function getItemOwner721(uint index) public view returns(address){
        return itemsToken.ownerOf(index);
    }

    function getItemOwner(uint index) public view returns(address){
        return allItems[index].owner;
    }

    function publishItem(string memory name, uint price) public {
        itemsToken.createItem(msg.sender,itemsCount);
        Item memory newOne = Item({name: name, owner: msg.sender, price: price, index: itemsCount, exist: true});
        allItems[itemsCount] = newOne;
        itemsCount++;

        // new event
    }

    function buyItem(uint index) public{
        Item storage item = allItems[index];
        address buyer = msg.sender;

        require(item.exist);
        require(token.balanceOf(buyer) >= item.price);

        uint buyerBalance = token.balanceOf(buyer);
        uint sellerBalance = token.balanceOf(item.owner);

        token.buy(buyer, item.owner, item.price);

        require(token.balanceOf(buyer) <= SafeMath.sub(buyerBalance,item.price));
        require(token.balanceOf(item.owner) >= SafeMath.add(sellerBalance,item.price));

        itemsToken.transferOwnership(item.owner, buyer, index);
        item.owner = buyer;
        // new event
    }

}