//SourceUnit: Nonces.sol

pragma solidity ^0.5.0;

contract Nonces {
    mapping(address => uint256) nonces;
    
    function add(address user) public {
        nonces[user]++;
    }

    function getNonce(address user) public view returns(uint256) {
        return nonces[user];
    }
}