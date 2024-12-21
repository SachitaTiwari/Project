// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// A simple ERC20 token contract for reward distribution
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MindfulnessMeditationGamification {
    IERC20 public rewardToken;

    // Store user meditation records
    mapping(address => uint256) public meditationCount;
    mapping(address => uint256) public rewardsEarned;

    // Events to log the progress and rewards
    event MeditationCompleted(address indexed user, uint256 newCount);
    event RewardClaimed(address indexed user, uint256 amount);
    event BadgeEarned(address indexed user, string badge);

    // Constructor to initialize the token contract address
    constructor(address _rewardToken) {
        rewardToken = IERC20(_rewardToken);
    }

    // Modifier to check if user has enough balance for claiming rewards
    modifier hasSufficientBalance(uint256 amount) {
        require(rewardToken.balanceOf(address(this)) >= amount, "Insufficient contract balance.");
        _;
    }

    // Function to record a meditation session
    function completeMeditation() external {
        meditationCount[msg.sender] += 1;

        // Emit event when meditation is completed
        emit MeditationCompleted(msg.sender, meditationCount[msg.sender]);

        // Check and award badge if the user has reached a milestone
        if (meditationCount[msg.sender] == 10) {
            emit BadgeEarned(msg.sender, "Mindful Beginner");
        } else if (meditationCount[msg.sender] == 50) {
            emit BadgeEarned(msg.sender, "Zen Master");
        }

        // Reward user with 1 token per meditation
        rewardsEarned[msg.sender] += 1;
    }

    // Function to claim earned rewards (ERC20 tokens)
    function claimRewards() external hasSufficientBalance(rewardsEarned[msg.sender]) {
        uint256 amountToClaim = rewardsEarned[msg.sender];
        rewardsEarned[msg.sender] = 0;

        // Transfer rewards to the user
        rewardToken.transfer(msg.sender, amountToClaim);
        
        // Emit event when rewards are claimed
        emit RewardClaimed(msg.sender, amountToClaim);
    }

    // Function to check the balance of rewards for a user
    function checkRewards(address user) external view returns (uint256) {
        return rewardsEarned[user];
    }

    // Function to withdraw tokens from the contract (only owner)
    address public owner = msg.sender;

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner.");
        _;
    }

    function withdraw(uint256 amount) external onlyOwner {
        rewardToken.transfer(owner, amount);
    }
}
