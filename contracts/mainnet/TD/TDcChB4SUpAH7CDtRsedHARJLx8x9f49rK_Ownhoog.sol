//SourceUnit: right.sol

// pragma  solidity  ^0.5.8;

contract SafeMath {
    function safeMul(uint256 a, uint256 b) public pure returns (uint256)  {
        uint256 c = a * b;
        _assert(a == 0 || c / a == b);
        return c;
    }

    function safeDiv(uint256 a, uint256 b) public pure returns (uint256)  {
        _assert(b > 0);
        uint256 c = a / b;
        _assert(a == b * c + a % b);
        return c;
    }

    function safeSub(uint256 a, uint256 b) public pure returns (uint256)  {
        _assert(b <= a);
        return a - b;
    }

    function safeAdd(uint256 a, uint256 b) public pure returns (uint256)  {
        uint256 c = a + b;
        _assert(c >= a && c >= b);
        return c;
    }

    function _assert(bool assertion) public pure {
        if (!assertion) {
            revert();
        }
    }
}

contract Ownhoog  {
    address  public  _owner;
    address  public  _coo;
    address  public  _cfo;
    bool public paused = false;
    event  OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public payable{
        _owner  =  msg.sender;
    }

    function owner() public view returns (address)  {
        return  _owner;
    }

    modifier onlyOwner(){
        require(msg.sender  ==  _owner);
        _;
    }

    modifier onlyCOO(){
        require(msg.sender  ==  _coo);
        _;
    }

    modifier onlyCFO(){
        require(msg.sender  ==  _cfo);
        _;
    }

    function setCoo(address  cooAddress)  public onlyOwner{
        _coo  =  cooAddress;
    }

    function setCfo(address  cfoAddress)  public onlyOwner{
        _cfo  =  cfoAddress;
    }

    function transferOwnership(address  newOwner)  public onlyOwner{
        require(newOwner  !=  address(0));
        emit  OwnershipTransferred(_owner,  newOwner);
        _owner  =  newOwner;
    }

    modifier whenNotPaused(){
        require(!paused);
        _;
    }

    modifier whenPaused{
        require(paused);
        _;
    }

    function pause() external onlyCOO  whenNotPaused{
        paused  =  true;
    }

    function unPause() public onlyCOO  whenPaused  {
        paused  =  false;
    }
}