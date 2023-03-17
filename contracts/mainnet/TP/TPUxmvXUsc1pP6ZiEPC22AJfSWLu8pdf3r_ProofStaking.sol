//SourceUnit: auction.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

contract ProofStaking{ 
    address public owner;
    
    struct Deposit{
        uint amount;
        uint timestamp;
    }
    
    struct Withdraw{
        uint amount;
        uint timestamp;
    }

    mapping(address => uint) balanceGHs;
    mapping(address => Deposit[]) userDeposits;
    mapping(address => Withdraw[]) userWithdraws;
    
    uint constant WITHDRAW_FEE = 7;

    event MakeDeposit(address indexed _to, uint _amount, uint _timestamp);
    event MakeWithdraw(address indexed _to, uint _amount, uint _timestamp);
    event Bonus(address indexed _to, uint _amount, uint _timestamp);

    constructor(){
        owner = msg.sender;
    }

    receive () external payable { }

    modifier onlyOwner() {
        require(msg.sender == owner, "Function accessible only by the owner!");
        _;
    }

    function deposit() external payable {
        balanceGHs[msg.sender] += msg.value;
        
        Deposit memory currentDeposit;

        currentDeposit.amount = msg.value;
        currentDeposit.timestamp = block.timestamp;
            
        userDeposits[msg.sender].push(currentDeposit);
        
        emit MakeDeposit(msg.sender, msg.value, block.timestamp);
    }

    function withdraw(uint _amount) external {
        require(balanceGHs[msg.sender] >= _amount, "You don't have enough money!");

        uint fee  = (_amount * WITHDRAW_FEE) / 100;
        uint send = _amount - fee;
        balanceGHs[msg.sender] -= _amount;
        
        payable(msg.sender).transfer(send);
        
        Withdraw memory currentWithdraw;

        currentWithdraw.amount = send;
        currentWithdraw.timestamp = block.timestamp;
            
        userWithdraws[msg.sender].push(currentWithdraw);
        
        emit MakeWithdraw(msg.sender, _amount, block.timestamp);
    }

    function bonusGHs(address _to, uint _amount) external onlyOwner{
        balanceGHs[_to] += _amount;
        emit Bonus(_to, _amount, block.timestamp);
    }

    function getBalance(address _address) external view returns(uint){
        return balanceGHs[_address];
    }
    
    function getDeposits() external view returns(Deposit[] memory){
        return userDeposits[msg.sender];
    }
    
    function getWithdraws() external view returns(Withdraw[] memory){
        return userWithdraws[msg.sender];
    }


}