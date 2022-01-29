//SourceUnit: routerhelper.sol

pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;
// SPDX-License-Identifier: MIT

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
}

interface pair {
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

contract RouterHelper {
    struct pairReservesItem {
       address token0;
       address token1;
       uint256 reserve0;
       uint256 reserve1;
       uint256 decimals0;
       uint256 decimals1;
       string symbol0;
       string symbol1;
       string name0;
       string name1;
    }
    
    function getTokensReserves(address[] memory _pairList) public view returns (pairReservesItem[] memory pairReservesList) {
        pairReservesList = new pairReservesItem[](_pairList.length);
        for (uint256 i=0;i<_pairList.length;i++)
        {
            address _pair = _pairList[i];
            address token0 = pair(_pair).token0();
            address token1 = pair(_pair).token1();
            (uint256 reserve0, uint256 reserve1,) =  pair(_pair).getReserves();
            pairReservesList[i] = pairReservesItem(token0,token1,reserve0,reserve1,IERC20(token0).decimals(),IERC20(token1).decimals(),IERC20(token0).symbol(),IERC20(token1).symbol(),IERC20(token0).name(),IERC20(token1).name());
        }
    }
    
}