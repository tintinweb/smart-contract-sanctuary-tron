//SourceUnit: NoxxtonPro.sol

//SPDX-License-Identifier: None
pragma solidity ^0.8.0;

contract NoxxtonPro {
    address payable public owner = payable(0xa7867C1ef31DE4187e94282506d56ABA47975a68);
    address dev;
    uint ownerPercentage = 20;
    
    constructor() {
        dev = msg.sender;
    }

    fallback() external payable {}

    receive() external payable {}

    function Invest(address sponsorAddress, uint256 packageId) public payable {
        owner.transfer(msg.value*ownerPercentage/100);
    }

    function Reinvest(uint256 packageId) public payable {
        owner.transfer(msg.value*ownerPercentage/100);
    }

    function Withdraw(address userAddress, uint amount) public payable {
        require(dev == msg.sender, "You are not allowed!");
        payable(userAddress).transfer(amount);
    }
}