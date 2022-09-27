//SourceUnit: Forwarder.sol

pragma solidity ^0.4.23;

interface ITRC20 {

    function transfer(address to, uint256 value) external returns (bool);
    function balanceOf(address who) external view returns (uint256);
}

contract Forwarder {
  address public parentAddress;
  event ForwarderDeposited(address from, uint value, bytes data);

  constructor() public {
    parentAddress = msg.sender;
  }
  modifier onlyParent {
    if (msg.sender != parentAddress) {
      revert();
    }
    _;
  }
  function() payable public {
    parentAddress.transfer(this.balance);
    emit ForwarderDeposited(msg.sender, msg.value, msg.data);
  }
  function flushTokens(address tokenContractAddress) public onlyParent {
    ITRC20 instance = ITRC20(tokenContractAddress);
    var forwarderAddress = address(this);
    var forwarderBalance = instance.balanceOf(forwarderAddress);
    if (forwarderBalance == 0) {
      return;
    }
    if (!instance.transfer(parentAddress, forwarderBalance)) {
      revert();
    }
  }
}