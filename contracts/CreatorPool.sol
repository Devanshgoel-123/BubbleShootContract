// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CreatorPool is Ownable {
    mapping(uint256 => address) public creatorTokens; // This is the creator ID and the address of their coin
    mapping(uint256 => uint256) public creatorBalances; // The amount of tokens we have from each creator
    mapping(uint256 => address) public creatorOwners;  

    address public treasury; // The treasury wallet to earn commission in the game
    address public operator;

    event CreatorDeposit(uint256 indexed creatorId, address token, uint256 amount);
    event RewardsDistributedToPlayer(uint256 indexed creatorId, address indexed winner, uint256 amount);
    
    constructor(address initialOwner) Ownable(initialOwner) {}

    function setTreasuryAddress(address _treasury) external onlyOwner {
        require(_treasury != address(0), "Invalid treasury address");
        treasury = _treasury;
    }

    function setOperator(address _operator) external onlyOwner {
        require(_operator != address(0), "Invalid operator address");
        operator = _operator;
    }

    function depositCreatorTokens(uint256 creatorId, address token, uint256 amount) external {
        require(amount > 0, "Amount must be positive");
        require(token != address(0), "Invalid token address");

        if (creatorTokens[creatorId] == address(0)) {
            creatorTokens[creatorId] = token;
            creatorOwners[creatorId] = msg.sender;
        } else {
            require(creatorTokens[creatorId] == token, "Token mismatch");
        }

        IERC20(token).transferFrom(msg.sender, address(this), amount);
        creatorBalances[creatorId] += amount;

        emit CreatorDeposit(creatorId, token, amount);
    }

    function getCreatorPoolBalance(uint256 creatorId) external view returns (uint256) {
        return creatorBalances[creatorId];
    }

    function distributeDailyRewards(uint256 creatorId, address[] calldata winners, uint256[] calldata amounts) external {
        require(msg.sender == operator, "Only operator can call");
        require(creatorTokens[creatorId] != address(0), "No pool for creator");
        require(treasury != address(0), "Treasury not set");
        require(winners.length == amounts.length, "Winners and amounts length mismatch");
        require(winners.length > 0, "No winners provided");

        uint256 balance = creatorBalances[creatorId];
        require(balance > 0, "No balance in pool");

        uint256 winnersTotal = (balance * 2) / 100; // 2%
        uint256 treasuryAmount = (balance ) / 1000; // 0.1%

        if (winnersTotal == 0) {
            revert("No rewards available to distribute");
        }

        uint256 sumAmounts = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            sumAmounts += amounts[i];
        }
        require(sumAmounts == winnersTotal, "Sum of amounts does not match winners total");

        address token = creatorTokens[creatorId];
        creatorBalances[creatorId] = balance - winnersTotal - treasuryAmount;
        for (uint256 i = 0; i < winners.length; i++) {
            bool sucess = IERC20(token).transfer(winners[i], amounts[i]);
            if (sucess) {
                emit RewardsDistributedToPlayer(creatorId, winners[i], amounts[i]);
            }
        }

        IERC20(token).transfer(treasury, treasuryAmount);
    }

    function withdrawCreatorFunds(uint256 creatorId, uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be positive");

        uint256 balance = creatorBalances[creatorId];
        require(amount <= balance, "Insufficient balance");

        address token = creatorTokens[creatorId];

        creatorBalances[creatorId] = balance - amount;
        IERC20(token).transfer(treasury, amount);
    }
}