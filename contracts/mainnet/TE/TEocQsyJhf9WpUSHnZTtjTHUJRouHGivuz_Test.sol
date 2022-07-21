//SourceUnit: Test.sol

contract Test {

    function getChainId() view public returns(uint256) {
        return block.chainid;
    }
}