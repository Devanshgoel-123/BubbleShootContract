// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract BubbleCoin is ERC20 {
    uint8 private _customDecimals;

    constructor(
        address initialHolder,
        uint256 initialSupply
    ) ERC20("Bubble Coin", "BUB") {
        _customDecimals = 18; // standard decimals
        if (initialSupply > 0 && initialHolder != address(0)) {
            _mint(initialHolder, initialSupply);
        }
    }

    function decimals() public view override returns (uint8) {
        return _customDecimals;
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    function burnFrom(address from, uint256 amount) external {
        _spendAllowance(from, msg.sender, amount);
        _burn(from, amount);
    }
}
