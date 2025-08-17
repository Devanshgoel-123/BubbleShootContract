// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CreatorPool is Ownable {
    mapping(uint256 => address) public creatorTokens;   // Token used for each creator
    mapping(uint256 => uint256) public creatorBalances; // Balance tracking (manual update)

    address public operator;

    event CreatorBalanceUpdated(uint256 indexed creatorId, uint256 newBalance);
    event RewardDistributed(uint256 indexed creatorId, address indexed token, address indexed receiver, uint256 amount);

    constructor(address initialOwner) Ownable(initialOwner) {}

    modifier onlyOperator() {
        require(msg.sender == operator, "Only operator can call");
        _;
    }

    function setOperator(address _operator) external onlyOwner {
        require(_operator != address(0), "Invalid operator address");
        operator = _operator;
    }

    function updateCreatorBalance(uint256 creatorId, address token, uint256 newBalance) external onlyOwner {
        require(token != address(0), "Invalid token address");
        creatorTokens[creatorId] = token;
        creatorBalances[creatorId] = creatorBalances[creatorId] +  newBalance;

        emit CreatorBalanceUpdated(creatorId, newBalance);
    }

    function distributeReward(
        uint256 creatorId,
        address receiver,
        uint256 amount
    ) external onlyOperator {
        require(amount > 0, "Amount must be positive");
        require(receiver != address(0), "Invalid receiver");
        require(creatorTokens[creatorId] != address(0), "No token set for creator");
        require(creatorBalances[creatorId] >= amount, "Insufficient balance");

        address token = creatorTokens[creatorId];
        creatorBalances[creatorId] -= amount;
        bool success = IERC20(token).transfer(receiver, amount);
        require(success, "Token transfer failed");

        emit RewardDistributed(creatorId, token, receiver, amount);
    }

    function getCreatorPoolBalance(uint256 creatorId) external view returns (uint256) {
        return creatorBalances[creatorId];
    }
}
