//SourceUnit: Forwarder.sol

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
  event ForwarderDeposited(address from, uint value, bytes data);
  event ForwarderStarted(address parent);
  constructor() public payable {
    parentAddress = msg.sender;
    emit ForwarderStarted(parentAddress);
  }

  function() public payable {
    parentAddress.transfer(msg.value);
    emit ForwarderDeposited(msg.sender, msg.value, msg.data);
  }
  function sweep() payable public onlyOwner {
      parentAddress.transfer(msg.value);
      emit ForwarderDeposited(msg.sender,  msg.value, msg.data);
  }

}