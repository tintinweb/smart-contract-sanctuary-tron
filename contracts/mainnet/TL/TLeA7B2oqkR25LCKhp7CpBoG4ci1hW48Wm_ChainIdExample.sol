//SourceUnit: ChainID.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract ChainIdExample {

    // after solidity_v0.8.0
    function getChainId() public view returns(bytes32,uint256) {
        uint256 chainId = block.chainid & 0xffffffff;
        return (bytes32(chainId), chainId);
    }

    // before solidity_v0.8.0
    function getChainIdAssembly() public view returns(bytes32,uint256) {
        uint256 chainId;
        assembly {
            chainId := and(chainid(), 0xffffffff)
        }
        return (bytes32(chainId), chainId);
    }
}