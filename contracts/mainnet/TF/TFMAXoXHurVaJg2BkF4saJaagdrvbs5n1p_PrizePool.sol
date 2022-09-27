//SourceUnit: PrizePool.sol

pragma solidity ^0.5.10;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }


    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {



        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }


    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;


        return c;
    }


    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }


    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract PrizePool{
    
    using SafeMath for uint256;
    
    mapping(address=>uint256) public balanceOf;
    mapping(address=>uint256) public debts;
    
    mapping (address => mapping (address => uint256)) public prizes;
    
    
    event Deposit(address indexed userAddress,uint256 amount);
    
    event AllotPrize(address indexed userAddress,uint256 amount);
    
    event Withdraw(address indexed userAddress,uint256 amount);
    
    event ClearPrize(address indexed userAddress,uint256 amount);
    

    function() external payable {
        deposit(msg.sender);
    }

    
    function deposit(address userAddress) public payable  {
        require(msg.value>0,"It's not allowed to be zero");
        balanceOf[userAddress] = balanceOf[userAddress].add(msg.value);
        emit Deposit(tx.origin,msg.value);
    }
    
    
    function allotPrize(address lucky, uint256 amount) external  {
        
        require(lucky != address(0), "zero address");
        if(availableBalance(msg.sender)>=amount){
            debts[msg.sender] = debts[msg.sender].add(amount);
            prizes[msg.sender][lucky] = prizes[msg.sender][lucky].add(amount);
            emit AllotPrize(lucky,amount);
        }
        
    }
    
    function clearPrize(address lucky) external  {
        uint256 debt = prizes[msg.sender][lucky];
        debts[msg.sender] = debts[msg.sender].sub(debt);
        prizes[msg.sender][lucky] = 0;
        
        emit ClearPrize(msg.sender,debt);
    }
    
    function withdraw(address payable lucky,uint256 amount) external  returns (uint256) {
        require(prizes[msg.sender][lucky]>=amount,"error");
        
        
        debts[msg.sender] = debts[msg.sender].sub(prizes[msg.sender][lucky]);
        prizes[msg.sender][lucky] = 0;
        
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(amount);
        lucky.transfer(amount);
        
        emit Withdraw(lucky,amount);
    }

    
    function availableBalance(address userAddress) public view returns(uint256){
        
        if(balanceOf[userAddress]>debts[userAddress]){
            return balanceOf[userAddress].sub(debts[userAddress]);
        }
        
    }
    
}