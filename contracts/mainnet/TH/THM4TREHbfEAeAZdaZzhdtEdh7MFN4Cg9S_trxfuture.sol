//SourceUnit: trxfuture.sol

pragma solidity ^0.5.10;

contract trxfuture {
  uint storedData;
  
  function set(uint x) public {
    storedData = x;
  }
  
  function get() public view returns (uint) {
    return storedData;
  }
}