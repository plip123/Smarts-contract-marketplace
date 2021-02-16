//SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';

contract MyTestToken721 is ERC721{

    constructor() ERC721("MyTestToken721", "MT2"){

    }

    function createItem(address to, uint index) public {
        _safeMint(to, index);
    }

    function transferOwnership(address from, address to, uint index) public {
        require(_exists(index));
        _safeTransfer(from, to, index, "");
    }

}