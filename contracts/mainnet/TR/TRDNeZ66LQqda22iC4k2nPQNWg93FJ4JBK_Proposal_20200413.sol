//SourceUnit: Proposal_20200413.sol

contract Proposal_20200413{

    //mom TWZwRiw7ZoCkg3Q4cYk68mZGnQDfjMfPnG
    address public momAddr=address(0x41E1F412BCF7D60783FAB61B639E9C9ED8FE0C9EFC);
    //new pep TBQe518r7hR3SHhERNB2xajgzB6rxAsNNs
    address public arg =address(0x410FC77356CD7F9616C8C22D2FE0E131D317CA753E);

    bool public first = true;

    function callMom() public returns (bool){
        require(first, "not first");
        require(verifyPrice(), "error price");

        first = false;
        Mom(momAddr).setPep(arg);

        return true;
    }

    function verifyPrice() public view returns (bool){
        return uint256(Pep(arg).read())==uint256(3000000000000000);
    }
}

interface Mom{
    function setPep(address pep_) external;
}

interface Pep{
    function read() external returns (bytes32);
}