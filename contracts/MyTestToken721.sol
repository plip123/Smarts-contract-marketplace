//SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
// import '@openzeppelin/contracts/presets/ERC721PresetMinterPauserAutoId.sol';

contract MyTestToken721 is ERC721{

    constructor() ERC721("MyTestToken721", "MT2"){

    }

    function createItem(address to, uint id) public {
        _safeMint(to, id);
    }

}