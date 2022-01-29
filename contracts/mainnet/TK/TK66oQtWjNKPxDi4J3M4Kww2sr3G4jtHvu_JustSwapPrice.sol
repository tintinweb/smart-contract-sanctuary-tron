//SourceUnit: JustSwapPrice.sol

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

abstract contract Token {
  function getTrxToTokenOutputPrice(uint256 tokens_bought) external view virtual returns (uint256);
}

contract JustSwapPrice {
  constructor () {

  }

  function getTrxToTokenOutputPrice(address exchangeAddress, uint256 tokens_bought) public view returns (uint256) {
    Token token = Token(exchangeAddress);
    return token.getTrxToTokenOutputPrice(tokens_bought);
  }
  
  function getBTokenToATokenOutputPrice(address exchangeAddressA, uint256 tokens_boughtA, address exchangeAddressB, uint256 tokens_boughtB) public view returns (uint256) {
    return div(getTrxToTokenOutputPrice(exchangeAddressA,tokens_boughtA) * 1000000, getTrxToTokenOutputPrice(exchangeAddressB,tokens_boughtB));
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
      // Solidity only automatically asserts when dividing by 0
      require(b > 0, "SafeMath: division by zero");
      uint256 c = a / b;
      // assert(a == b * c + a % b); // There is no case in which this doesn't hold
      return c;
  }
}