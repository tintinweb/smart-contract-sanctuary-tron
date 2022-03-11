//SourceUnit: gvrpool.sol

pragma solidity 0.6.0;
interface token{
     function transfer(address a, uint256 am) external returns (bool success);
} 
contract GVRPool{
    address public tokenaddr;
    address public owner;
    address public admin;

    constructor() public {
      owner = msg.sender;
      admin = msg.sender;
    }
    function setToken(address a) public {
      require(msg.sender==owner);
      tokenaddr = a;
    }
   
    function setAdmin(address a) public {
      require(msg.sender==owner);
      admin = a;
    }
   function tokenTransfer(address t,uint256 am) public  returns (bool success){
        require(msg.sender==owner || msg.sender==admin);
        return token(tokenaddr).transfer(t,am);
    }
}