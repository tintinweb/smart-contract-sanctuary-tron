//SourceUnit: BSCswap.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

import "./SafeMath.sol";
import "./IERC20.sol";

contract BSCswap {
    using SafeMath for uint256; 
    IERC20 public usdt;
    uint256 private constant baseDivider = 10000;
    uint256 private constant feePercents = 300; 
    uint256 private constant starPercents = 30;
    uint256 private constant managerPercents = 20;
    uint256 private constant dayPerCycle = 15 days; 
    uint256 private constant maxAddFreeze = 45 days;
    uint256 private constant timeStep = 1 days;
    uint256 private constant minDeposit = 50e6;
    uint256 private leaderStart = 0;
    uint256 private managerStart = 0;
    
    struct UserInfo {
        address referrer;
        uint256 refNo;
        uint256 myLastDeposit;
        uint256 totalIncome;
        uint256 totalWithdraw;
        uint256 isLeader;
        uint256 isManager;
        uint256 split;
        uint256 splitAct;
        uint256 splitTrnx;
        uint256 myRegister;
        mapping(uint256 => uint256) levelTeam;
        mapping(uint256 => uint256) incomeArray;
        mapping(uint256 => uint256) directBuz;
    }
    mapping(address=>UserInfo) public userInfo;
    
    struct UserDept{
        uint256 amount;
        uint256 depTime;
        uint256 unfreeze; 
        bool isUnfreezed;
    }
    mapping(address => UserDept[]) public userDepts;
    
    address payable feeReceivers;
    address public defaultRefer;
    uint256 public startTime;
    
    mapping(uint256 => uint256) reward;
    mapping(uint256 => uint256) manager_reward;
    address [] reward_array;
    address [] manager_array;
    
    event Register(address user, address referral);
    event Deposit(address user, uint256 amount);
    event DepositBySplit(address user, uint256 amount);
    event TransferBySplit(address user, address receiver, uint256 amount);
    
    uint[] level_bonuses = [500, 100, 200, 300, 100, 200, 100, 100, 100, 100, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50]; 
    
    constructor(address _usdt, address payable _feeReceiver) public {
        usdt = IERC20(_usdt);
        feeReceivers = _feeReceiver;
        startTime = block.timestamp;
        defaultRefer = msg.sender;
    }
    
    function contractInfo() public view returns(uint256 balance, uint256 init){
       return (usdt.balanceOf(address(this)),startTime);
    }
    
    function register(address _referral) external {
        require(userInfo[_referral].myLastDeposit > 0 || _referral == defaultRefer, "invalid refer");
        UserInfo storage user = userInfo[msg.sender];
        require(user.referrer == address(0), "referrer bonded");
        user.referrer = _referral;
        user.refNo = userInfo[_referral].myRegister;
        userInfo[_referral].myRegister++;
        emit Register(msg.sender, _referral);
    }
    
    function deposit(uint256 _amount) external {
        usdt.transferFrom(msg.sender, address(this), _amount);
        _deposit(msg.sender, _amount,0);
        emit Deposit(msg.sender, _amount);
    }
    function _deposit(address _user, uint256 _amount, uint8 _isReDept) private {
        require(_amount>=minDeposit, "Minimum 50 USDT");
        
        require(userInfo[_user].referrer != address(0), "register first");
        require(_amount>=userInfo[_user].myLastDeposit, "Amount greater than previous Deposit");
        
        userInfo[_user].myLastDeposit=_amount;
        
        _distributeDeposit(_amount);
        
        uint256 addFreeze = (userDepts[_user].length.div(2)).mul(timeStep);
        if(addFreeze > maxAddFreeze){
            addFreeze = maxAddFreeze;
        }
        uint256 unfreezeTime = block.timestamp.add(dayPerCycle).add(addFreeze);
        userDepts[_user].push(UserDept(
            _amount,
            block.timestamp,
            unfreezeTime,
            false
        ));
        
        _setReferral(_user,userInfo[_user].referrer,_amount,_isReDept);
        unfreezeDepts(_user);
        
        uint256 totalDays=getCurDay();
        reward[totalDays]+=_amount.mul(starPercents).div(baseDivider);
        manager_reward[totalDays]+=_amount.mul(managerPercents).div(baseDivider);
        if(reward_array.length>0){
            updateLeader(totalDays);
        }
        if(manager_array.length>0){
            updateManager(totalDays);
        }
    }
    function _setReferral(address _user,address _referral, uint256 _refAmount, uint8 _isReDept) private {
        for(uint8 i = 0; i < level_bonuses.length; i++) {
            if(_isReDept==0){
                userInfo[_referral].levelTeam[i]+=1;
            }
            userInfo[_referral].directBuz[userInfo[_user].refNo]+=_refAmount;
            if(userInfo[_referral].isLeader==0 || userInfo[_referral].isManager==0){
                (uint256 lt,uint256 lbA, uint256 lbB)=teamBuzInfo(_referral);
                if(userInfo[_referral].isLeader==0 && lt>=50 && userInfo[_referral].myLastDeposit>=1000e6 && lbA>=10000e6 && lbB>=10000e6){
                   userInfo[_referral].isLeader=1;
                   reward_array.push(_referral);
                }
                if(userInfo[_referral].isManager==0 && lt>=200 && userInfo[_referral].myLastDeposit>=1000e6 && lbA>=50000e6 && lbB>=50000e6){
                   userInfo[_referral].isManager=1;
                   manager_array.push(_referral);
                }
            }
            uint256 levelOn=_refAmount;
            if(_refAmount>userInfo[_referral].myLastDeposit){
                levelOn=userInfo[_referral].myLastDeposit;
            }
            if(i==0){
                userInfo[_referral].totalIncome+=levelOn.mul(level_bonuses[i]).div(baseDivider);
                userInfo[_referral].incomeArray[2]+=levelOn.mul(level_bonuses[i]).div(baseDivider);
            }else if(i>0 && i<3){
                if(userInfo[_referral].levelTeam[0]>=5){
                    userInfo[_referral].totalIncome+=levelOn.mul(level_bonuses[i]).div(baseDivider);
                    userInfo[_referral].incomeArray[3]+=levelOn.mul(level_bonuses[i]).div(baseDivider);
                }
            }else{
                if(userInfo[_referral].isLeader==1 && i < 5){
                    userInfo[_referral].totalIncome+=levelOn.mul(level_bonuses[i]).div(baseDivider);
                    userInfo[_referral].incomeArray[4]+=levelOn.mul(level_bonuses[i]).div(baseDivider);
                }else if(userInfo[_referral].isManager==1 && i >= 5){
                    userInfo[_referral].totalIncome+=levelOn.mul(level_bonuses[i]).div(baseDivider);
                    userInfo[_referral].incomeArray[5]+=levelOn.mul(level_bonuses[i]).div(baseDivider);
                }
            }
            
           _user = _referral;
           _referral = userInfo[_referral].referrer;
            if(_referral == address(0)) break;
        }
    }
    
    function _distributeDeposit(uint256 _amount) private {
        uint256 fee = _amount.mul(feePercents).div(baseDivider);
        usdt.transfer(feeReceivers,fee);
    }
    
    function depositBySplit(uint256 _amount) external {
        require(_amount >= minDeposit && _amount.mod(minDeposit) == 0, "amount err");
        require(userInfo[msg.sender].myLastDeposit == 0, "actived");
        uint256 splitLeft = userInfo[msg.sender].split.sub(userInfo[msg.sender].splitAct).sub(userInfo[msg.sender].splitTrnx);
        require(splitLeft >= _amount, "insufficient split");
        userInfo[msg.sender].splitAct = userInfo[msg.sender].splitAct.add(_amount);
        _deposit(msg.sender, _amount,1);
        emit DepositBySplit(msg.sender, _amount);
    }

    function transferBySplit(uint256 _amount,address _receiver) external {
        require(_amount >= minDeposit && _amount.mod(minDeposit) == 0, "amount err");
        uint256 splitLeft = userInfo[msg.sender].split.sub(userInfo[msg.sender].splitAct).sub(userInfo[msg.sender].splitTrnx);
        require(splitLeft >= _amount, "insufficient income");
        userInfo[msg.sender].splitTrnx = userInfo[msg.sender].splitTrnx.add(_amount);
        userInfo[_receiver].split = userInfo[_receiver].split.add(_amount);
        emit TransferBySplit(msg.sender, _receiver, _amount);
    }
    function unfreezeDepts(address _addr) private {
        uint8 isdone;
        for(uint i=0;i<userDepts[_addr].length;i++){
            UserDept storage pl = userDepts[_addr][i];
            if(pl.isUnfreezed==false && block.timestamp>=pl.unfreeze && isdone==0){
                pl.isUnfreezed=true;
                userInfo[_addr].totalIncome+=pl.amount;
                userInfo[_addr].totalIncome+=pl.amount.mul(225).div(1000);
                userInfo[_addr].incomeArray[0]+=pl.amount;
                userInfo[_addr].incomeArray[1]+=pl.amount.mul(225).div(1000);
                isdone=1;
                address _referral = userInfo[_addr].referrer;
                for(uint8 j = 0; j < level_bonuses.length; j++) {
                    userInfo[_referral].directBuz[userInfo[_addr].refNo]-=pl.amount;
                    _addr = _referral;
                   _referral = userInfo[_referral].referrer;
                    if(_referral == address(0)) break;
                }
                break;
            }
        }
    }
    function teamBuzInfo(address _addr) view private returns(uint256 lt,uint256 lbA,uint256 lbB) {
        uint256 lbATemp;
        uint256 lb;
        for(uint8 i=0;i<20;i++){
            lt+=userInfo[_addr].levelTeam[i];
        }
        for(uint256 i=0;i<userInfo[_addr].levelTeam[0];i++){
            lb+=userInfo[_addr].directBuz[i];
            if(lbATemp==0 || userInfo[_addr].directBuz[i]>lbATemp){
               lbATemp=userInfo[_addr].directBuz[i]; 
            }
        }
        lbB=lb-lbATemp;
        return (
           lt,
           lbATemp,
           lbB
        );
    }
    
    function updateLeader(uint256 totalDays) private {
        if(leaderStart==0){
            uint256 distLAmount;
            for(uint256 i=0; i < totalDays; i++){
                distLAmount+=reward[i];
                reward[i]=0;
            }
            distLAmount=distLAmount.div(reward_array.length);
            for(uint8 i = 0; i < reward_array.length; i++) {
                userInfo[reward_array[i]].totalIncome+=distLAmount;
                userInfo[reward_array[i]].incomeArray[6]+=distLAmount;
            }
            leaderStart=1;
        }else if(leaderStart>0 && reward[totalDays-1]>0){
            uint256 distLAmount=reward[totalDays-1].div(reward_array.length);
            for(uint8 i = 0; i < reward_array.length; i++) {
                userInfo[reward_array[i]].totalIncome+=distLAmount;
                userInfo[reward_array[i]].incomeArray[6]+=distLAmount;
            }
            reward[totalDays-1]=0;
        }
    }
    function updateManager(uint256 totalDays) private {
        if(managerStart==0){
            uint256 distAmount;
            for(uint256 i=0; i < totalDays; i++){
                distAmount+=manager_reward[i];
                manager_reward[i]=0;
            }
            distAmount=distAmount.div(manager_array.length);
            for(uint8 i = 0; i < manager_array.length; i++) {
                userInfo[manager_array[i]].totalIncome+=distAmount;
                userInfo[manager_array[i]].incomeArray[7]+=distAmount;
            }
            managerStart=1;
            
        }else if(managerStart>0 && manager_reward[totalDays-1]>0){
            uint256 distAmount=manager_reward[totalDays-1].div(manager_array.length);
            for(uint8 i = 0; i < manager_array.length; i++) {
                userInfo[manager_array[i]].totalIncome+=distAmount;
                userInfo[manager_array[i]].incomeArray[7]+=distAmount;
            }
            manager_reward[totalDays-1]=0;
        }
    }
    function getCurDay() public view returns(uint256) {
        return (block.timestamp.sub(startTime)).div(timeStep);
    }
    function leaderPool() view external returns(uint256 lp,uint256 lr,uint256 lpTeam,uint256 mp,uint256 mr,uint256 mpTeam) {
        uint256 totalDays=getCurDay();
        if(reward_array.length==0){
            for(uint256 i=0; i <= totalDays; i++){
                lp+=reward[i];
            }
            lr=lp-reward[totalDays-1];
        }else{
            lp=reward[totalDays];
            lr=reward[totalDays-1];
        }
        if(manager_array.length==0){
            for(uint256 i=0; i <= totalDays; i++){
                mp+=manager_reward[i];
            }
            mr=mp-manager_reward[totalDays-1];
        }else{
            mp=manager_reward[totalDays];
            mr=manager_reward[totalDays-1];
        }
        return (lp,lr,reward_array.length,mp,mr,manager_array.length);
    }
    function incomeDetails(address _addr) view external returns(uint256[8] memory p) {
        for(uint8 i=0;i<8;i++){
            p[i]=userInfo[_addr].incomeArray[i];
        }
        return (
           p
        );
    }
    function userDetails(address _addr) view external returns(address ref,uint256 lt,uint256 lbA,uint256 lbB,uint256 myDirect) {
        UserInfo storage player = userInfo[_addr];
        
        uint256 lbATemp;
        uint256 lb;
        for(uint8 i=0;i<20;i++){
            lt+=userInfo[_addr].levelTeam[i];
        }
        for(uint256 i=0;i<player.levelTeam[0];i++){
            lb+=player.directBuz[i];
            if(lbATemp==0 || player.directBuz[i]>lbATemp){
               lbATemp=player.directBuz[i]; 
            }
        }
        lbB=lb-lbATemp;
        return (
           player.referrer,
           lt,
           lbATemp,
           lbB,
           userInfo[_addr].levelTeam[0]
        );
    }
    
    function withdraw(uint256 _amount) public{
        require(_amount >= 10e6, "Minimum 10 need");
        UserInfo storage player = userInfo[msg.sender];
        uint256 bonus;
        bonus=player.totalIncome-player.totalWithdraw;
        
        require(_amount<=bonus,"Amount exceeds withdrawable");
        player.totalWithdraw+=_amount;
        uint256 tempSplit=(bonus-player.incomeArray[0]).mul(30).div(100);
        player.split+=tempSplit;
        uint256 wamount=_amount.sub(tempSplit);
        player.incomeArray[0]=0;
        player.incomeArray[1]=0;
        player.incomeArray[2]=0;
        player.incomeArray[3]=0;
        player.incomeArray[4]=0;
        player.incomeArray[5]=0;
        player.incomeArray[6]=0;
        player.incomeArray[7]=0;
        usdt.transfer(msg.sender, wamount);
        
    }
 
}

//SourceUnit: IERC20.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

//SourceUnit: SafeMath.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
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