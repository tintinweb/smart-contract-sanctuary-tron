//SourceUnit: bankoftron24.sol

pragma solidity ^0.5.0;

/**
*                                                        
* BankofTron24
* 
* 
**/

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Ownable {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
   }

contract BankofTron24 is Ownable{
    
    using SafeMath for uint256;

    uint totalInvestment = 0;
    uint totalInvestors = 0;
    uint minInvestment = 50 ;
    uint specialMininumInvestment = 10000;
    uint walletPercent = 6000;
    
    uint private contractDeployStart;
    uint private contractDeployEnd;

    address payable private walletAddress;
    address payable private poolAddress;

    struct Plan{
        address user;
        string name;
        uint percent;
        uint planDays;
        uint investmentValue;
        uint realInvestment;
        uint createDate;
    }
    
    struct Investor{
        bool registered;
        
        address referer;
        uint referralLevel1;
        uint referralLevel2;
        uint referralLevel3;
        uint referralLevel4;
        uint balanceRef;
        uint totalRef;
        uint withdrawn;
        
        uint investment;
        
        // Plan[] plans;
    }
    
    mapping (address => uint) userPlanCount;
    mapping (uint => address) planToUser;
    
    mapping (address => Plan) planByUser;
    mapping (address => Investor) investors;
    mapping (address => uint) balanceOf;
    
    Plan[] public plans;
    uint[] public refRewards;
    
    event Invested(uint id, string name, uint amount);
    event onWithdraw(address investor, uint256 amount);
    
    constructor(address payable _walletAddress) public {
        contractDeployStart = now;
        contractDeployEnd = now.add(365 days);
        walletAddress = _walletAddress;
        poolAddress = address(uint(address(this)));
        
        for (uint i=4; i>=1; i--){
            if (i == 2){
                refRewards.push(1);
            }
            else{
                refRewards.push(i);
            }
        }
    }
    
    
    
    function register(address _referer) public{
        if( !investors[msg.sender].registered){
            //new investor
            investors[msg.sender].registered = true;
            totalInvestors = totalInvestors.add(1);
        }
        
        if (investors[_referer].registered && _referer != msg.sender){
            investors[msg.sender].referer = _referer;
        }
        
        if (_referer != msg.sender){
            address rec = _referer; 
            for (uint i=0; i<refRewards.length; i++){
                if (!investors[rec].registered){
                    break;
                }
                if (i == 0){
                    investors[rec].referralLevel1 = investors[rec].referralLevel1.add(1);
                }
                if (i == 1){
                    investors[rec].referralLevel2 = investors[rec].referralLevel2.add(1);
                }
                if (i == 2){
                    investors[rec].referralLevel3 = investors[rec].referralLevel3.add(1);
                }
                if (i == 3){
                    investors[rec].referralLevel4 = investors[rec].referralLevel4.add(1);
                }
                rec = investors[rec].referer;
            }
        }
    }
    
    
    function referralReward(uint _amount, address _referer) public{
        address rec = _referer;
        for (uint i = 0; i < refRewards.length; i++) {
          if (!investors[rec].registered) {
            break;
          }
          
          uint referalPercent = _amount * refRewards[i] / 100;
          investors[rec].balanceRef += referalPercent;
          investors[rec].totalRef += referalPercent;
          
          rec = investors[rec].referer;
        }
    }
    
    function Invest(string memory _name, uint _percent, uint _planDays, uint _amount, address _referer) public payable returns (bool){
        require(now <= contractDeployEnd, "Contract is expired");
         if (keccak256(abi.encodePacked(_name)) == keccak256(abi.encodePacked('special'))) {
            require(_amount >= specialMininumInvestment, "Minimnun value for investment is 10000 TRX");
        }
        else{
            require(_amount >= minInvestment, "Minimnun value for investment is 50 TRX");    
        }
        
        register(_referer);
        referralReward(_amount, investors[msg.sender].referer);
        
        uint realInvestment = _amount.sub(calculateWage(_amount));
        Plan memory myPlan = Plan(msg.sender, _name, _percent, (now + (_planDays * 1 days)), _amount, realInvestment, now);
        uint id = plans.push(myPlan) -1;
        planByUser[msg.sender] = myPlan;
        planToUser[id] = msg.sender;
        
        userPlanCount[msg.sender] = userPlanCount[msg.sender].add(1);
        
        investors[msg.sender].investment = investors[msg.sender].investment.add(_amount);
        // investors[msg.sender].plans.push(myPlan);
        uint walletValue = calculatePercent(_amount);
        uint poolValue = _amount.sub(walletValue);
        
        balanceOf[walletAddress] = balanceOf[walletAddress].add(walletValue);
        balanceOf[poolAddress] = balanceOf[poolAddress].add(poolValue);
        
        totalInvestment = totalInvestment.add(_amount);
        
        
        sendToWallet();
        sendToPool();
        emit Invested(id, _name, _amount);
        return true;
    }
    
    function sendToWallet() public payable returns(bool){
        walletAddress.transfer((msg.value * walletPercent) / 10000);
        return true;
    }
    
    function sendToPool() public payable{}

    function withdraw(uint _value) public{
        require(_value > 2);
        
        require(now <= contractDeployEnd, "Contract is expired");
        require(userPlanCount[msg.sender] != 0, "No any investments");
        require(balanceOf[poolAddress] > _value);
        
        for (uint i=0; i<plans.length; i ++){
            if (plans[i].user == msg.sender){
                require (now <= plans[i].planDays);
                plans[i].createDate = now;
            } 
        }
        uint withdrawAmount = _value.sub(calculateWage(_value));
        balanceOf[poolAddress] = balanceOf[poolAddress].sub(withdrawAmount);
        
        investors[msg.sender].withdrawn = investors[msg.sender].withdrawn.add(_value);
        investors[msg.sender].balanceRef = 0;
        
        msg.sender.transfer(withdrawAmount * 1000000);
        
        emit onWithdraw(msg.sender, withdrawAmount);
        
    }
    
    
    function getWalletBalance() view public returns(uint){
        return walletAddress.balance;
    }
    
    function getPoolBalance() external view returns(uint){
        return address(this).balance;
    }
    
    function getreferralInfo(address _investor) view public returns(uint, uint, uint, uint, uint, uint){
        return (investors[_investor].referralLevel1, investors[_investor].referralLevel2, investors[_investor].referralLevel3, 
        investors[_investor].referralLevel4, investors[_investor].balanceRef, investors[_investor].totalRef);
    }
    
    function getInvestor(address _investor) view public returns(uint, uint){
        return (investors[_investor].investment, investors[_investor].withdrawn);
    }
    
    function getTotalInvestment() view public returns(uint){
        return totalInvestment;
    }

    
    function getTotalInvesters() view public returns (uint){
        return totalInvestors;
    }
    
    function getPlansByOwner(address _user) external view returns (uint256[] memory){
        uint256[] memory result = new uint256[](userPlanCount[_user]);
        uint256 counter = 0;
        for (uint256 i = 0; i < plans.length; i++) {
            if (planToUser[i] == _user) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }

    function getDeployTime() view public returns(uint){
        require(now <= contractDeployEnd);
        return contractDeployStart;
    }
    
    function calculatePercent(uint256 _amount) internal view returns (uint256) {
        return (_amount * walletPercent) / 10000;
    }

    function calculateWage(uint256 _amount) internal pure returns (uint) {
        uint wage = 0;
        require(_amount >= 3);
        if (_amount >= 3 && _amount <= 1000) {
            wage = 2;
        }else if (_amount >= 1001 && _amount <= 10000) {
            wage = 3;
        } else {
            wage = 4;
        }
        return wage;
    }
}