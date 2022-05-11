//SourceUnit: ISunswapV2Router01.sol

interface ISunswapV2Router01 {

    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[]
    memory amounts);


}

//SourceUnit: Test.sol

pragma solidity ^0.5.0;

import "./ISunswapV2Router01.sol";

contract  Test {
    ISunswapV2Router01 router;
    address a;
    address b;

    constructor(ISunswapV2Router01 _router,address _a,address _b) public  {
        router = _router;
        a = _a;
        b = _b;

    }


    function getTokenPrice() private view returns (uint[] memory amount1){

        address[] memory  path;

        path[0] = address(a);
        path[1] = address(b);

        amount1 = router.getAmountsOut(uint256(1000000),path);

        return amount1;
    }
}