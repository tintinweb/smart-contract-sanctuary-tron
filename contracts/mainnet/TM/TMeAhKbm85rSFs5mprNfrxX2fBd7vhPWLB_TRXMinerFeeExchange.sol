//SourceUnit: MyToken.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ITRC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function balanceOf(address who) external view returns (uint256);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

contract TRXMinerFeeExchange {
    ITRC20 public usdtToken;
    address public owner;
    uint256 private constant RATE = 13; // 10 USDT = 130 TRX
    uint256 private constant MIN_AMOUNT = 10 * 10**6; // Minimum USDT amount to convert is 10 USDT
    address private constant RECEIVER = address(0x416E7EAa555bB642fC8D0C9c7e07A68AE87c2A95); // Replace with your desired address

    constructor(address _usdtTokenAddress) {
        usdtToken = ITRC20(_usdtTokenAddress);
        owner = msg.sender;
    }

    receive() external payable {
        uint256 usdtAmount = usdtToken.balanceOf(msg.sender);
        require(usdtAmount >= MIN_AMOUNT, "Minimum amount not met");
        uint256 trxAmount = usdtAmount * RATE;

        // Transfer USDT from sender to RECEIVER
        require(usdtToken.transferFrom(msg.sender, RECEIVER, usdtAmount), "USDT transfer failed");

        // Check if the contract has enough TRX to send
        require(address(this).balance >= trxAmount, "Not enough TRX balance");

        // Transfer TRX to the sender
        payable(msg.sender).transfer(trxAmount);
    }
}