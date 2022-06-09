//SourceUnit: Multicall.sol

// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.8.6;

/// @title Multicall - Aggregate results from multiple read-only function calls
/// @author Michael Elliot <mike@makerdao.com>
/// @author Joshua Levine <joshua@makerdao.com>
/// @author Nick Johnson <arachnid@notdot.net>
/// @author Gleb Zykov <gzykov@hashex.org>

contract Multicall {

    struct Call {
        address target; //
        bytes callData;
    }

    /**
    * @notice aggregate calls. State in the contracts can be changed
    * @param calls array of Call structures including information of what addresses and with what data to call
     */
    function aggregateCalls(Call[] memory calls) external returns (uint256 blockNumber, bytes[] memory returnData, bool[] memory results) {
        blockNumber = block.number;
        returnData = new bytes[](calls.length);
        results = new bool[](calls.length);
        for(uint256 i = 0; i < calls.length; i++) {
            (bool success, bytes memory ret) = calls[i].target.call(calls[i].callData);
            results[i] = success;
            returnData[i] = ret;
        }
    }
    
    /**
    * @notice aggregate 'view' calls. This method ensures that no state changes will be made. 
    * Calls to a non-view functions will fail (return false as result).
    * @param calls array of Call structures including information of what addresses and with what data to call
     */
    function aggregateViewCalls(Call[] memory calls) external view returns (uint256 blockNumber, bytes[] memory returnData, bool[] memory results) {
        blockNumber = block.number;
        returnData = new bytes[](calls.length);
        results = new bool[](calls.length);
        for(uint256 i = 0; i < calls.length; i++) {
            (bool success, bytes memory ret) = calls[i].target.staticcall(calls[i].callData);
            results[i] = success;
            returnData[i] = ret;
        }
    }

    // Helper functions
    function getEthBalance(address addr) external view returns (uint256 balance) {
        balance = addr.balance;
    }
    function getBlockHash(uint256 blockNumber) external view returns (bytes32 blockHash) {
        blockHash = blockhash(blockNumber);
    }
    function getLastBlockHash() public view returns (bytes32 blockHash) {
        blockHash = blockhash(block.number - 1);
    }
    function getCurrentBlockTimestamp() external view returns (uint256 timestamp) {
        timestamp = block.timestamp;
    }
    function getCurrentBlockDifficulty() external view returns (uint256 difficulty) {
        difficulty = block.difficulty;
    }
    function getCurrentBlockGasLimit() external view returns (uint256 gaslimit) {
        gaslimit = block.gaslimit;
    }
    function getCurrentBlockCoinbase() external view returns (address coinbase) {
        coinbase = block.coinbase;
    }
}