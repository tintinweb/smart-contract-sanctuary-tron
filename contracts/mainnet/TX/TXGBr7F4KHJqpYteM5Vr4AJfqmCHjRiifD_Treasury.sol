//SourceUnit: treasury_fixed.sol

// SPDX-License-Identifier: NO LICENSE
pragma solidity ^0.8.0;

interface ITRC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function balanceOf(address who) external view returns (uint256);
}

contract Treasury{
  
    address payable public owner;
    // uint balance;

    constructor() {
        owner = payable(msg.sender);
    }

    function depositWYZTH() payable public returns(uint){
        require(msg.value > 0, "Invalid amount");
        // balance += msg.value;
        return msg.value;
    } 

    function Withdraw(uint256 amount) payable public{
        require(address(this).balance >= amount, "Invalid amount");
        owner.transfer(amount);
    }

    function WithdrawToken(ITRC20 _tokenAddress, uint256 _amount) public{
        ITRC20 tokenAddress = ITRC20(_tokenAddress);
        tokenAddress.transfer(owner, _amount);
    }

    function contractBalance() public view returns(uint){
        // return balance; 
        return address(this).balance;
    }

    function contractTokenBalance(address _token) public view returns(uint){
        return ITRC20(_token).balanceOf(address(this)) ; 
    }
}