//SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract MyTestToken20 is ERC20{

    constructor() ERC20("MyTestToken20", "MT1"){

    }

    function giveCredit(address to, uint amount) public {
        _mint(to, amount);
    }

    function buy(address from, address to, uint amount) public {
        _transfer(from, to, amount);
    }

}