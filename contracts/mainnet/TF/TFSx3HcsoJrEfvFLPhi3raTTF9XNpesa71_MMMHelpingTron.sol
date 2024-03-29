//SourceUnit: MMMHelpingTron.sol

pragma solidity ^0.4.25;

contract MMMHelpingTron {

    address owner;    // current owner of the contract

    function MMMHelpingTron() public {
        owner = msg.sender;
    }

    function withdraw() public {
        require(owner == msg.sender);
        msg.sender.transfer(address(this).balance);
    }

    function deposit(uint256 amount) public payable {
        require(msg.value == amount);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}