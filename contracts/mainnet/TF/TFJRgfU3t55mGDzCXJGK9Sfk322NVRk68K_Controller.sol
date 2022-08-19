//SourceUnit: coinwallet.sol

pragma solidity ^0.5.0;

contract UserWallet{

    AbstractSweeperList sweeperList;

    constructor (address _sweeperlist) public {
        sweeperList = AbstractSweeperList(_sweeperlist);
    }

    function () external payable {
        sweeperList.sweeperOf().transfer(msg.value);
        sweeperList.emit_ethLog(msg.sender, address(this),msg.value);
    }
}

contract AbstractSweeperList {
    function sweeperOf() public returns (address payable);
    function emit_ethLog(address from, address to, uint256 amount) public; 
}

contract Controller is AbstractSweeperList{
    address public owner;
    //목적지
    address payable public destination;
    //정지여부
    bool public halted;
    
    event LogNewWallet(address receiver);
    event ethLog(address indexed from, address indexed to, uint256 indexed amount); 
    event LogSweep(address indexed from, address to, address indexed token, uint indexed amount);

    modifier onlyOwner() {
        require(msg.sender == owner,"YOUR NOT OWNER"); 
        _;
    }

    modifier stopngo(){
        require(!halted,"contract stop");
        _;
    }

    constructor () public {
        owner = msg.sender;
        destination = msg.sender;
    }

    // 목적지바꾸기.. 오너만 가능
    function changeDestination(address payable _dest) onlyOwner stopngo public{
        destination = _dest;
    }

    // 오너 바꾸기.. 오너만 가능
    function changeOwner(address _owner) onlyOwner public{
        owner = _owner;
    }

    // 지갑만들기
    function makeWallet() onlyOwner stopngo public returns (address wallet)  {
        wallet = address(new UserWallet(address(this)));
        emit LogNewWallet(wallet);
    }

    // 중지하기
    function halt() onlyOwner public{
        halted = true;
    }

    // 시작하기
    function start() onlyOwner public{
        halted = false;
    } 

    function sweeperOf() public returns (address payable){
        return destination;
    }

    function emit_ethLog(address from, address to, uint256 amount) public{
        emit ethLog(from, to,amount); 
    }
}