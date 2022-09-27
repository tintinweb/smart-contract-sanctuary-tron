//SourceUnit: forwarder.sol

pragma solidity ^0.4.25;

contract owned {
    constructor() public { owner = msg.sender; }
    address owner;
    modifier onlyOwner {
        require(
            msg.sender == owner,
            "Only owner can call this function."
        );
        _;
    }
}

contract Forwarder is owned {
  address public parentAddress;
  event NotifyDeposit(address from, uint value);

  constructor() public {
    parentAddress = msg.sender;
  }

  function() public payable {}

  function forward() public {
    uint contractBalance = address(this).balance;
    require(parentAddress.balance == contractBalance);
    parentAddress.transfer(contractBalance);
    emit NotifyDeposit(address(this), contractBalance);
  }
}