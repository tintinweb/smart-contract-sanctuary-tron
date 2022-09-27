//SourceUnit: bet4c.sol

pragma solidity 0.5.9;

contract Bet4c{
   
    using SafeMath for uint;
    uint amount;
    uint totalInvestment;
    uint totalWithdrawal;
    uint totalBalance;
    address payable public owner;
    
    struct User{
        address payable userid;
        uint balances;
        uint investment;
        uint tranxAmt;
        uint timestamp;
        string remark;
    }
    
    mapping (address => User) public users;
    
    modifier strict(){
        require(msg.sender == owner);
        _;
    }
    
    function changeOwner(address payable newOwner) public strict{
        owner = newOwner;
    }
    
    event Deposit(address indexed _from, uint _value);
    event Withdraw(address indexed _from, uint _value);
   
    constructor() payable public{
        owner = address(this);
    }
   
    function() payable external{
        
    }
    
    function getSmartContractAddress() view public returns(address){
        owner;
    }
    
    function deposit() payable public returns(uint32){  
        User storage user = users[msg.sender];
        totalInvestment = totalInvestment.add(msg.value);
        totalBalance = totalBalance.add(msg.value);
        user.investment = user.investment.add(msg.value);
        user.balances = user.balances.add(msg.value);
        user.tranxAmt = msg.value;
        user.timestamp = now;
        user.remark = "User Deposited";
        emit Deposit(msg.sender, msg.value);
        amount = msg.value;
    }  
      
    function withdraw(uint _amount) payable public{
        User storage user = users[msg.sender];
        amount = _amount;
        //require(user.balances > 0 && user.balances <= amount);
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