// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

interface TokenInterface {
    function mint(address account, uint256 amount) external;
}

contract TokenShop {
    AggregatorV3Interface internal priceFeed;
    TokenInterface public minter;
    uint256 public tokenPrice = 200;
    address public owner;

    constructor(address tokenAddress) {
        minter = TokenInterface(tokenAddress);
        // network: Seopila
        // Aggregator: ETH/USD
        // Address: 

        priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        owner = msg.sender;
    }

    // Returns the latest answer

    function getChainlinkDataFeedLatestAnswer() public view returns (int) {
        (
           /*uint80 roundID*/,
           int price,
           /*uint startedAt*/,
           /*uint timeStamp*/,
           /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return price;
    }

    function tokenAmount(uint256 amountETH) public view returns (uint256) {
        uint256 ethUsd = uint256(getChainlinkDataFeedLatestAnswer());
        uint256 amountUSD = amountETH * ethUsd / 10**18;
        uint256 amountToken = amountUSD / tokenPrice / 10**(8/2);
        return amountToken;
    }

    receive() external  payable { 
        uint256 amountToken = tokenAmount(msg.value);
        minter.mint(msg.sender, amountToken);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this funnction");
        _;
    }

    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

}