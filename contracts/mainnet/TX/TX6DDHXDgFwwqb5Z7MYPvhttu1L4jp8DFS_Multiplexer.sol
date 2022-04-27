//SourceUnit: Multiplexer.sol

pragma solidity ^0.4.16;

contract TRC20 {
    function transferFrom( address from, address to, uint value) returns (bool ok);
}

contract Multiplexer {

    function sendToken(address _tokenAddress, address[] _to, uint256[] _value) returns (bool _success) {
        assert(_to.length == _value.length);
        assert(_to.length <= 255);
        TRC20 token = TRC20(_tokenAddress);
        for (uint8 i = 0; i < _to.length; i++) {
            assert(token.transferFrom(msg.sender, _to[i], _value[i]) == true);
        }
        return true;
    }
}