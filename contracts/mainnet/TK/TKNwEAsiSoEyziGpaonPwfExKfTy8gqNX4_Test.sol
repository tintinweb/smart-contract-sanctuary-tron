//SourceUnit: Test.sol

pragma solidity ^0.5.16;


library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }
}


// erc20
interface IERC20 {
    function balanceOf(address _address) external view returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


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

    // 计算价格
    function getTrxToTokenInputPrice(uint256 trx_sold) external view returns (uint256);
    function getTokenToTrxInputPrice(uint256 tokens_sold) external view returns (uint256);
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
        // 把合约全部的trx余额进行兑换
    }

    // token兑换trx
    // 参数1：token地址
    // 参数2：LP地址
    // 参数3：固定的token数量
    // 参数4：最少可接收的trx数量
    // 参数5：接收者地址
    function tokenSwapTrx(
        address _tokenAddress,
        address _lpAddress,
        uint256 tokens_sold,
        uint256 min_trx,
        address _to
    ) public returns(bool) {
        // 用户先把token给到本合约===
        // 把用户的token转给本合约。
        // TransferHelper.safeTransferFrom(_tokenAddress, msg.sender, address(this), tokens_sold);

        // 本合约授权token给LP合约
        TransferHelper.safeApprove(_tokenAddress, _lpAddress, tokens_sold);
        // 把本合约一定数量的token进行兑换。

        // 开始兑换
        IJustswapExchange(_lpAddress).tokenToTrxTransferInput(tokens_sold, min_trx, block.timestamp+300, _to);
        return true;
    }

    // 添加池子
    // 参数1：token地址
    // 参数2：LP地址
    // 参数3：接收的最少LP数量
    // 参数4：最多给出去的token数量，多了会返回
    // 参数5：接收者地址
    function addLp(
        address _tokenAddress,
        address _lpAddress,
        uint256 min_liquidity,
        uint256 max_tokens
    ) public payable returns(bool) {
        // 用户先把token给到本合约==========
        // 把用户的token转给本合约。
        // TransferHelper.safeTransferFrom(_tokenAddress, msg.sender, address(this), max_tokens);
        // 本合约授权token给LP合约
        TransferHelper.safeApprove(_tokenAddress, _lpAddress, max_tokens);
        // 把本合约一定数量的token进行添加。

        // 开始添加
        IJustswapExchange(_lpAddress).addLiquidity.value(address(this).balance)(min_liquidity, max_tokens, block.timestamp+300);
        // 多出的token转给用户
        // uint256 _thisTokenBalance = IERC20(_tokenAddress).balanceOf(address(this));
        // if(_thisTokenBalance > 0) {
        //     TransferHelper.safeTransfer(_tokenAddress, msg.sender, _thisTokenBalance);
        // }
        // 再把全部的LP给到用户
        uint256 _thisLpBalance = IERC20(_lpAddress).balanceOf(address(this));
        if(_thisLpBalance > 0) {
            TransferHelper.safeTransfer(_lpAddress, msg.sender, _thisLpBalance);
        }
        return true;
    }

    // 计算波场价格
    // 参数1：LP地址
    // 参数2：trx数量
    function getTrxPrice(address _lpAddress, uint256 trx_sold) public view returns (uint256) {
        return IJustswapExchange(_lpAddress).getTrxToTokenInputPrice(trx_sold);
    }

    // 计算token价格
    // 参数1：LP地址
    // 参数2：token数量
    function getTokenPrice(address _lpAddress, uint256 tokens_sold) public view returns (uint256) {
        return IJustswapExchange(_lpAddress).getTokenToTrxInputPrice(tokens_sold);
    }
    


}