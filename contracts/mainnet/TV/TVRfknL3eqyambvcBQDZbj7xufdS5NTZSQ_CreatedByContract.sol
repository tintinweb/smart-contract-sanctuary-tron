//SourceUnit: test.sol

pragma solidity >= 0.8.6;

contract ImmutableTest {
    uint256 immutable asdf;
    
    event TestPOIUPOIYioasnfdkjhasfhas(uint256 b);
    
    constructor(uint256 _a) {
        asdf = _a;
        emit TestPOIUPOIYioasnfdkjhasfhas(_a);
    }
    
    function createEvent(uint256 _a) external {
        emit TestPOIUPOIYioasnfdkjhasfhas(_a);
    }
}

contract ImmutableTestFactory {
    function createContract(uint256 _a) external {
        new ImmutableTest(_a);
    }
}