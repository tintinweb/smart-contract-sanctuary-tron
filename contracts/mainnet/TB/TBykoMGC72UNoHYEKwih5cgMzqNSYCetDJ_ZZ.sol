//SourceUnit: zz.sol

pragma solidity 0.6.0;
interface token{
     function balanceOf(address account) external view returns (uint256);
} 
contract ZZ{
    address public tokenaddr ;
    constructor(address a) public {
      tokenaddr = a;
    }
    function balanceOf(address a) public view returns (uint256){
      return token(tokenaddr).balanceOf(a);
    }
}