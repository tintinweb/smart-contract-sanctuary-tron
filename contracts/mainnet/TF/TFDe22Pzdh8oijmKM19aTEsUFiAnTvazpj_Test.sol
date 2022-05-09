//SourceUnit: Test.sol

pragma solidity ^0.5.16;

interface IJustswapExchange {
    // trx兑换token。确定的trx数量兑换尽量多的token。
    // min_tokens=最少可接收数量。deadline=到期时间，recipient=接收币的地址。
    function trxToTokenTransferInput(uint256 min_tokens, uint256 deadline, address recipient) external payable returns(uint256);
    // token兑换trx。确定的token数量兑换尽量多的trx。
    // tokens_sold=固定数量的token，min_trx=最少可接收的trx数量。deadline=到期时间。recipient=接收币的地址。
    function tokenToTrxTransferInput(uint256 tokens_sold, uint256 min_trx, uint256 deadline, address recipient) external returns (uint256);

    // 添加池子
    // min_liquidity=接收的最少LP数量。max_tokens=最多给出的token数量，多了会返回。deadline=到期时间。
    function addLiquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline) external payable returns (uint256);
    // 移除池子
    // amount=移除的流动性数量。min_trx=最少可接收的trx数量。min_tokens=最少可接收的token数量。deadline=到期时间。
    // function removeLiquidity(uint256 amount, uint256 min_trx, uint256 min_tokens, uint256 deadline) external returns (uint256, uint256);
}


contract Test {
    uint256 public a = 100;

    // trx兑换token
    // 参数1：LP地址
    // 参数2：最少可接收数量
    // 参数3：接收者地址
    function trxSwapToken(
        address _lpAddress,
        uint256 min_tokens,
        address _to
    ) public payable returns(bool) {
        IJustswapExchange(_lpAddress).trxToTokenTransferInput.value(address(this).balance)(min_tokens, block.timestamp+300, _to);
        return true;
    }

    // token兑换trx
    // 参数1：LP地址
    // 参数2：固定的token数量
    // 参数3：最少可接收的trx数量
    // 参数4：接收者地址
    function tokenSwapTrx(
        address _lpAddress,
        uint256 tokens_sold,
        uint256 min_trx,
        address _to
    ) public returns(bool) {
        IJustswapExchange(_lpAddress).tokenToTrxTransferInput(tokens_sold, min_trx, block.timestamp+300, _to);
        return true;
    }

    // 添加池子
    // 参数1：LP地址
    // 参数2：接收的最少LP数量
    // 参数3：最多给出去的token数量，多了会返回
    // 参数4：接收者地址
    function addLp(
        address _lpAddress,
        uint256 min_liquidity,
        uint256 max_tokens
    ) public payable returns(bool) {
        IJustswapExchange(_lpAddress).addLiquidity.value(address(this).balance)(min_liquidity, max_tokens, block.timestamp+300);
        return true;
    }


}