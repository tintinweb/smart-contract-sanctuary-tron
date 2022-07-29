//SourceUnit: BalanceCollector.sol

pragma solidity 0.8.6;

interface TRC20 {
    function balanceOf(address) external view returns (uint);
}

contract BalanceCollector {

    fallback () external {
        revert("BalanceCollector does not accept payments");
    }

    function getTRXBalances(address[] calldata users) external view returns (uint[] memory) {
        uint[] memory balances = new uint[](users.length);
        for (uint i = 0; i < users.length; i++) {
            balances[i] = users[i].balance;
        }
        return balances;
    }

    function getTRC10Balances(address[] calldata users, trcToken tokenId) external view returns (uint[] memory) {
        uint[] memory balances = new uint[](users.length);
        for (uint i = 0; i < users.length; i++) {
            balances[i] = users[i].tokenBalance(tokenId);
        }
        return balances;
    }

    function getTRC20Balances(address[] calldata users, address token) external view returns (uint[] memory) {
        uint[] memory balances = new uint[](users.length);
        for (uint i = 0; i < users.length; i++) {
            balances[i] = TRC20(token).balanceOf(users[i]);
        }
        return balances;
    }
}