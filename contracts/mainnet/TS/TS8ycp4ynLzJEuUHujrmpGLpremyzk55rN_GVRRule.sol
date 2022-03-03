//SourceUnit: gvrrule.sol

pragma solidity 0.6.0;
interface Itoken {
  function totalSupply() external view returns (uint256);
  function balanceOf(address a) external view returns (uint256);
  function setBalance(address a,uint256 am)  external returns (bool);
  function setSupply(uint256 a)  external returns (bool);
  function setTransferEvent(address a,address b,uint256 am)  external;
}
contract GVRRule {
    uint256 public _tBurnTotal=0;
    uint256 public _stopBurn=100000000 * 10**18;
    address public _burnPool = address(0);
    address public _uniswapV2Pair=address(0x416B8F020F2D428FB92CA43EABAFDED2AE0D9FEEBC);
    address public _tokenAddr=address(0x41873CF7A1697BA3E6B087607A6EAEB1CF0275A6F4);
    function check( address from,address to, uint256 amount) external returns(uint256 sy) {
        require(msg.sender==_tokenAddr && amount > 0);
        if((to == _uniswapV2Pair || from == _uniswapV2Pair) && Itoken(_tokenAddr).totalSupply()>_stopBurn){
                uint256 bamount = amount*3/100;
                if(bamount>0){
                    Itoken(_tokenAddr).setBalance(_burnPool,Itoken(_tokenAddr).balanceOf(_burnPool)+bamount);
                    Itoken(_tokenAddr).setSupply(Itoken(_tokenAddr).totalSupply()-bamount);
                    _tBurnTotal=_tBurnTotal+bamount;
                    Itoken(_tokenAddr).setTransferEvent(from,_burnPool,bamount);
                    return amount-bamount;
                }
        }
        return amount;
    }
}