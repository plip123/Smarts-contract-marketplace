//SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract MyToken721 is ERC721, Ownable{

    constructor() ERC721("MyToken721", "MT7") {
    }

    function createItem(address to, uint tokenId) public onlyOwner {
        require(!_exists(tokenId), "Item already exists");
        _safeMint(to, tokenId);
    }

}