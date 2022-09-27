//SourceUnit: bet4c.sol

pragma solidity ^0.5.9;

contract Bet4c{
   
    using SafeMath for uint;
    uint amount;
    uint totalInvestment;
    uint totalWithdrawal;
    uint totalBalance;
    uint adminCharge = 5;
    uint investmentAmt;
    uint adminShare;
    uint depAmt;
    address payable public owner;
    address payable admin;
    
    struct User{
        address payable userid;
        uint balances;
        uint investment;
        uint tranxAmt;
        uint timestamp;
        uint bheight;
        string remark;
    }
    
    mapping (address => User) internal users;
    
    modifier strict(){
        require(msg.sender == owner,"You are not authorized owner.");
        _;
    }
    
    function changeOwner(address payable newOwner) public strict{
        owner = newOwner;
    }
    
    function checkWallet(address addr) public view returns(uint){
        User storage user = users[addr];
        return user.balances;
    }
    
    event Deposit(address indexed _from, uint _admin, uint _value);
    event Withdraw(address indexed _from, uint _value);
    event Income(address indexed _from, uint _value);
   
    constructor(address payable _admin) payable public{
        owner = address(this);
        admin = _admin;
        investmentAmt = 1000000;
    }
   
    function() payable external{
        
    }
    
    function getContractBalance() view public returns(uint){
       return address(this).balance;
        
    }
    
    function deposit() payable public returns(uint){  
        User storage user = users[msg.sender];
        require(msg.value == investmentAmt,"Invalid Investment Amount"); 
        totalInvestment = totalInvestment.add(msg.value);
        totalBalance = totalBalance.add(msg.value);
        user.userid = msg.sender;
        user.investment = user.investment.add(msg.value);
        adminShare = amount.mul(adminCharge).div(100);
        admin.transfer(adminShare);
        depAmt = amount-adminShare;
        user.balances = user.balances.add(depAmt);
        user.tranxAmt = msg.value;
        user.remark = "User Deposited";
        user.timestamp = now;
        user.bheight = block.number;
        
        emit Deposit(msg.sender, adminShare, msg.value);
        amount = msg.value;
        
    }  
    
    function reward(address winner, uint incAmt) external{
        addIncome(winner,incAmt);
    }
    
    function addIncome(address receiver, uint incAmt) internal returns(uint){  
        User storage user = users[receiver];
        totalInvestment = totalInvestment.add(incAmt);
        totalBalance = totalBalance.add(incAmt);
        user.balances = user.balances.add(incAmt);
        user.tranxAmt = incAmt;
        user.remark = "Income Added";
        user.timestamp = now;
        
        emit Income(receiver,incAmt);
        return incAmt;
    }  
      
    function withdraw(uint _amount, uint location) payable public{
        User storage user = users[msg.sender];
        amount = _amount;
        require(location == user.bheight,"Missing location token.");
        require(user.balances > 0 && user.balances >= amount,"Withdraw amount exhausted.");
       
        totalInvestment = totalInvestment.sub(amount);
        totalWithdrawal = totalWithdrawal.add(amount);
        totalBalance = totalBalance.sub(amount);
        user.investment = user.investment.sub(amount);
        user.balances = user.balances.sub(amount);
        user.timestamp = now;
        user.remark = "User Withdraw";
        emit Withdraw(msg.sender, amount);
        msg.sender.transfer(amount);
    }
    
    function singleSendTRX(uint _amount) public payable returns(bool){
        amount = _amount;
        sendEqualAmt(owner,amount);
        return true;
    }
    
    function multiSendTRX(address[] memory  _receivers, uint _amount) public payable returns(bool){
        amount = _amount;
        uint256 amtToSend = amount/_receivers.length;
        sendEqualAmt(_receivers[0],amtToSend);
        sendEqualAmt(_receivers[1],amtToSend);
        sendEqualAmt(_receivers[2],amtToSend);
        return true;
    }
    
    function sendEqualAmt(address recipient, uint amtToSend) internal returns(bool){
        address payable receiver = address(uint160(recipient));
        receiver.transfer(amtToSend);
    }
   
}

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }
    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}