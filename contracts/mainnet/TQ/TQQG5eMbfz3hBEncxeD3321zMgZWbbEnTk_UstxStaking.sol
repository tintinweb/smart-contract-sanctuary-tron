//SourceUnit: IERC20.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.3.2 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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


//SourceUnit: Roles.sol

// Roles.sol
// Based on OpenZeppelin contracts v2.5.1
// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity ^0.8.0;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}


//SourceUnit: UstxStakingMulti.sol

// Staking.sol
// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./Roles.sol";


/// @title Up Stable Token eXperiment Staking contract
/// @author USTX Team
/// @dev This contract implements the interswap (USTX DEX <-> SunSwap) functionality for the USTX token.
// solhint-disable-next-line
contract UstxStaking {
	using Roles for Roles.Role;

	/***********************************|
	|        Variables && Events        |
	|__________________________________*/


	//Variables
	bool private _notEntered;			//reentrancyguard state
	Roles.Role private _administrators;
	uint256 private _numAdmins;
	uint256 private _minAdmins;

    IERC20 public stakingToken;

    uint256 public currentEpoch;

    uint256 private _totalStakedFree;
    uint256 private _totalStakedL1;
    uint256 private _totalStakedL2;
    uint256 private _totalStakedL3;
    uint256 private _totalStakedL4;

    uint256 private _totalRewards;
    uint256 private _paidRewards;
    uint256 private _taxes;
    uint256 private _tax;               //% per epoch

    uint256 private _maxIter;
    uint256 private _lock1Duration;
    uint256 private _lock2Duration;
    uint256 private _lock3Duration;
    uint256 private _lock4Duration;

    uint256 private _stakeFreeEnable;
    uint256 private _stakeL1Enable;
    uint256 private _stakeL2Enable;
    uint256 private _stakeL3Enable;
    uint256 private _stakeL4Enable;

    uint256 private _maxPerAccountL4;
    uint256 private _maxTotalL4;

    mapping(address => uint256) private _balancesFree;
    mapping(address => uint256) private _lastUpdateFree;
    mapping(address => uint256) private _rewardsFree;

    mapping(address => uint256) private _balancesL1;
    mapping(address => uint256) private _lastUpdateL1;
    mapping(address => uint256) private _rewardsL1;
    mapping(address => uint256) private _lockedTillL1;

    mapping(address => uint256) private _balancesL2;
    mapping(address => uint256) private _lastUpdateL2;
    mapping(address => uint256) private _rewardsL2;
    mapping(address => uint256) private _lockedTillL2;

    mapping(address => uint256) private _balancesL3;
    mapping(address => uint256) private _lastUpdateL3;
    mapping(address => uint256) private _rewardsL3;
    mapping(address => uint256) private _lockedTillL3;

    mapping(address => uint256) private _balancesL4;
    mapping(address => uint256) private _lastUpdateL4;
    mapping(address => uint256) private _rewardsL4;
    mapping(address => uint256) private _lockedTillL4;

    mapping(uint256 => uint256) private _rewardRatesFree;
    mapping(uint256 => uint256) private _rewardRatesL1;
    mapping(uint256 => uint256) private _rewardRatesL2;
    mapping(uint256 => uint256) private _rewardRatesL3;
    mapping(uint256 => uint256) private _rewardRatesL4;

	// Events
    event NewEpoch(uint256 epoch, uint256 reward, uint256 rateFree, uint256 rateL1, uint256 rateL2, uint256 rateL3, uint256 rateL4);
    event Staked(address indexed user, uint256 amount, uint256 stakeType);
    event Withdrawn(address indexed user, uint256 amount, uint256 stakeType);
    event RewardPaid(address indexed user, uint256 reward, uint256 stakeType);
    event AdminAdded(address indexed account);
    event AdminRemoved(address indexed account);

	/**
	* @dev costructor
	*
	*/
    constructor() {
        _notEntered = true;
        _numAdmins=0;
		_addAdmin(msg.sender);		//default admin
		_minAdmins = 2;					//at least 2 admins in charge
        currentEpoch = 0;
        _totalRewards = 0;
        _paidRewards = 0;
        _maxIter = 52;      //maximum loop depth for rewards calculation
        _lock1Duration = 13;  //3 months lock for L1
        _lock2Duration = 26;  //6 months lock for L2
        _lock3Duration = 39;  //9 months lock for L3
        _lock4Duration = 52;  //12 months lock for L4
        _tax = 10;            //Tax 1% per epoch remaining (in 1000s)
        _stakeFreeEnable=1;
        _stakeL1Enable=1;
        _stakeL2Enable=1;
        _stakeL3Enable=1;
        _stakeL4Enable=1;
        _maxPerAccountL4 = 10000000000;     //10000 USTX per account max in L4
        _maxTotalL4 = 500000000000;         //500000 USTX max total in L4
    }


	/***********************************|
	|        AdminRole                  |
	|__________________________________*/

	modifier onlyAdmin() {
        require(isAdmin(msg.sender), "AdminRole: caller does not have the Admin role");
        _;
    }

    function isAdmin(address account) public view returns (bool) {
        return _administrators.has(account);
    }

    function addAdmin(address account) public onlyAdmin {
        _addAdmin(account);
    }

    function renounceAdmin() public {
        require(_numAdmins>_minAdmins, "There must always be a minimum number of admins in charge");
        _removeAdmin(msg.sender);
    }

    function _addAdmin(address account) internal {
        _administrators.add(account);
        _numAdmins++;
        emit AdminAdded(account);
    }

    function _removeAdmin(address account) internal {
        _administrators.remove(account);
        _numAdmins--;
        emit AdminRemoved(account);
    }

	/***********************************|
	|        ReentrancyGuard            |
	|__________________________________*/

	/**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_notEntered, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _notEntered = false;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _notEntered = true;
    }

    /* ========== VIEWS ========== */

    function totalStaked() public view returns (uint256, uint256, uint256, uint256, uint256) {
        return (_totalStakedFree, _totalStakedL1, _totalStakedL2, _totalStakedL3, _totalStakedL4);
    }

    function getBalances() public view returns(uint256, uint256, uint256, uint256) {
        uint256 temp = _totalStakedFree + _totalStakedL1 + _totalStakedL2 + _totalStakedL3 + _totalStakedL4;
        return (stakingToken.balanceOf(address(this)), temp, _taxes, _totalRewards-_paidRewards);
    }

    function allRewards() public view returns (uint256,uint256,uint256) {
        return (_totalRewards, _paidRewards, _totalRewards-_paidRewards);       //total, paid, pending
    }

    function balanceOf(address account) public view returns (uint256, uint256, uint256,uint256, uint256) {
        return (_balancesFree[account],_balancesL1[account],_balancesL2[account],_balancesL3[account],_balancesL4[account]);
    }

    function lastUpdate(address account) public view returns (uint256,uint256,uint256,uint256,uint256) {
        return (_lastUpdateFree[account],_lastUpdateL1[account],_lastUpdateL2[account],_lastUpdateL3[account],_lastUpdateL4[account]);
    }

    function getStakeEnable() public view returns (uint256,uint256,uint256,uint256,uint256) {
        return (_stakeFreeEnable, _stakeL1Enable, _stakeL2Enable, _stakeL3Enable, _stakeL4Enable);
    }

    function getTax() public view returns (uint256) {
        return (_tax);
    }

    function earned(address account) public view returns (uint256, uint256, uint256, uint256, uint256) {
        uint256 temp=0;
        uint256 rFree=0;
        uint256 rL1=0;
        uint256 rL2=0;
        uint256 rL3=0;
        uint256 rL4=0;
        uint256 i;

        for (i=_lastUpdateFree[account];i<currentEpoch;i++) {
            temp += _rewardRatesFree[i];
        }
        rFree = _rewardsFree[account] + temp*_balancesFree[account]/1e18;

        temp = 0;
        for (i=_lastUpdateL1[account];i<currentEpoch;i++) {
            temp += _rewardRatesL1[i];
        }
        rL1 = _rewardsL1[account] + temp*_balancesL1[account]/1e18;

        temp = 0;
        for (i=_lastUpdateL2[account];i<currentEpoch;i++) {
            temp += _rewardRatesL2[i];
        }
        rL2 = _rewardsL2[account] + temp*_balancesL2[account]/1e18;

        temp = 0;
        for (i=_lastUpdateL3[account];i<currentEpoch;i++) {
            temp += _rewardRatesL3[i];
        }
        rL3 = _rewardsL3[account] + temp*_balancesL3[account]/1e18;

        temp = 0;
        for (i=_lastUpdateL4[account];i<currentEpoch;i++) {
            temp += _rewardRatesL4[i];
        }
        rL4 = _rewardsL4[account] + temp*_balancesL4[account]/1e18;

        return (rFree, rL1, rL2, rL3, rL4);
    }

    function getRates(uint256 epoch) public view returns (uint256,uint256,uint256,uint256,uint256) {
        return (_rewardRatesFree[epoch], _rewardRatesL1[epoch], _rewardRatesL2[epoch], _rewardRatesL3[epoch], _rewardRatesL4[epoch]);
    }

    function getLock(address account) public view returns (uint256, uint256, uint256, uint256, uint256) {
        uint256 lock1 = 0;
        uint256 lock2 = 0;
        uint256 lock3 = 0;
        uint256 lock4 = 0;

        if (currentEpoch <= _lockedTillL1[account]) {
            lock1 = _lockedTillL1[account]-currentEpoch + 1;
        }
        if (currentEpoch <= _lockedTillL2[account]) {
            lock2 = _lockedTillL2[account]-currentEpoch + 1;
        }
        if (currentEpoch <= _lockedTillL3[account]) {
            lock3 = _lockedTillL3[account]-currentEpoch + 1;
        }
        if (currentEpoch <= _lockedTillL4[account]) {
            lock4 = _lockedTillL4[account]-currentEpoch + 1;
        }

        return (0,lock1,lock2,lock3,lock4);
    }

    function getLimitsL4() public view returns (uint256, uint256) {
        return (_maxPerAccountL4, _maxTotalL4);
    }

    function calcRewardFromAPY(uint256 APYFree, uint256 APYL1, uint256 APYL2, uint256 APYL3, uint256 APYL4) public view returns (uint256, uint256, uint256, uint256, uint256) {
        uint256 rFree;
        uint256 rL1;
        uint256 rL2;
        uint256 rL3;
        uint256 rL4;

        rFree = _calcRewardFree(APYFree);
        rL1 = _calcRewardL1(APYL1);
        rL2 = _calcRewardL2(APYL2);
        rL3 = _calcRewardL3(APYL3);
        rL4 = _calcRewardL4(APYL4);

        return (rFree, rL1, rL2, rL3, rL4);
    }

    function _calcRewardFree(uint256 APY) internal view returns (uint256) {
        uint256 temp;
        uint256 reward;

        temp = APY *1e15 / 52;      //normalized yield per epoch. APY in 1000s
        reward = temp * _totalStakedFree / 1e18;

        return (reward);
    }

    function _calcRewardL1(uint256 APY) internal view returns (uint256) {
        uint256 temp;
        uint256 reward;

        temp = APY *1e15 / 52;      //normalized yield per epoch. APY in 1000s
        reward = temp * _totalStakedL1 / 1e18;

        return (reward);
    }

    function _calcRewardL2(uint256 APY) internal view returns (uint256) {
        uint256 temp;
        uint256 reward;

        temp = APY *1e15 / 52;      //normalized yield per epoch. APY in 1000s
        reward = temp * _totalStakedL2 / 1e18;

        return (reward);
    }

    function _calcRewardL3(uint256 APY) internal view returns (uint256) {
        uint256 temp;
        uint256 reward;

        temp = APY *1e15 / 52;      //normalized yield per epoch. APY in 1000s
        reward = temp * _totalStakedL3 / 1e18;

        return (reward);
    }

    function _calcRewardL4(uint256 APY) internal view returns (uint256) {
        uint256 temp;
        uint256 reward;

        temp = APY *1e15 / 52;      //normalized yield per epoch. APY in 1000s
        reward = temp * _totalStakedL4 / 1e18;

        return (reward);
    }

    /* ========== STAKE FUNCTIONS ========== */

    function stakeFree(uint256 amount) public nonReentrant updateRewardFree(msg.sender) {
        require(amount > 0, "Cannot stake 0");
        require(_stakeFreeEnable > 0, "Free staking is not open");
        _totalStakedFree = _totalStakedFree + amount;

        _balancesFree[msg.sender] += amount;
        stakingToken.transferFrom(msg.sender, address(this), amount);

        emit Staked(msg.sender, amount, 0);
    }

    function stakeLock1(uint256 amount) public nonReentrant updateRewardL1(msg.sender) {
        require(amount > 0, "Cannot stake 0");
        require(_stakeL1Enable > 0, "L1 Staking is not open");
        _totalStakedL1 = _totalStakedL1 + amount;

        if (_balancesL1[msg.sender] == 0) {
            _lockedTillL1[msg.sender] = currentEpoch + _lock1Duration;
        }
        _balancesL1[msg.sender] += amount;
        stakingToken.transferFrom(msg.sender, address(this), amount);

        emit Staked(msg.sender, amount, 1);
    }

    function stakeLock2(uint256 amount) public nonReentrant updateRewardL2(msg.sender) {
        require(amount > 0, "Cannot stake 0");
        require(_stakeL2Enable > 0, "L2 Staking is not open");
        _totalStakedL2 = _totalStakedL2 + amount;

        if (_balancesL2[msg.sender] == 0) {
            _lockedTillL2[msg.sender] = currentEpoch + _lock2Duration;
        }
        _balancesL2[msg.sender] += amount;
        stakingToken.transferFrom(msg.sender, address(this), amount);

        emit Staked(msg.sender, amount, 2);
    }

    function stakeLock3(uint256 amount) public nonReentrant updateRewardL3(msg.sender) {
        require(amount > 0, "Cannot stake 0");
        require(_stakeL3Enable > 0, "L3 Staking is not open");
        _totalStakedL3 = _totalStakedL3 + amount;

        if (_balancesL3[msg.sender] == 0) {
            _lockedTillL3[msg.sender] = currentEpoch + _lock3Duration;
        }
        _balancesL3[msg.sender] += amount;
        stakingToken.transferFrom(msg.sender, address(this), amount);

        emit Staked(msg.sender, amount, 3);
    }

    function stakeLock4(uint256 amount) public nonReentrant updateRewardL4(msg.sender) {
        require(amount > 0, "Cannot stake 0");
        require(_stakeL4Enable > 0, "L4 Staking is not open");
        _totalStakedL4 = _totalStakedL4 + amount;
        require(_totalStakedL4 < _maxTotalL4, "Maximum total stake reached");

        if (_balancesL4[msg.sender] == 0) {
            _lockedTillL4[msg.sender] = currentEpoch + _lock4Duration;
        }
        _balancesL4[msg.sender] += amount;
        require(_balancesL4[msg.sender] < _maxPerAccountL4, "Maximum stake balance per account reached");

        stakingToken.transferFrom(msg.sender, address(this), amount);

        emit Staked(msg.sender, amount, 4);
    }

    /* ========== COMPOUND FUNCTION ========== */
    function compoundFree() public nonReentrant updateRewardFree(msg.sender) {
        uint256 reward = _rewardsFree[msg.sender];
        if (reward > 0) {
            _paidRewards += reward;
            _rewardsFree[msg.sender] = 0;
            emit RewardPaid(msg.sender, reward, 0);
            _totalStakedFree = _totalStakedFree + reward;
            _balancesFree[msg.sender] += reward;
            emit Staked(msg.sender, reward, 0);
        }
    }
/*
    function compoundL1() public nonReentrant updateRewardL1(msg.sender) {
        require(currentEpoch > _lockedTillL1[msg.sender], "Rewards are locked, compounding not allowed");
        uint256 reward = _rewardsL1[msg.sender];
        if (reward > 0) {
            _paidRewards += reward;
            _rewardsL1[msg.sender] = 0;
            emit RewardPaid(msg.sender, reward, 1);
            _totalStakedL1 = _totalStakedL1 + reward;
            _balancesL1[msg.sender] += reward;
            emit Staked(msg.sender, reward, 1);
        }
    }

    function compoundL2() public nonReentrant updateRewardL2(msg.sender) {
        require(currentEpoch > _lockedTillL2[msg.sender], "Rewards are locked, compounding not allowed");
        uint256 reward = _rewardsL2[msg.sender];
        if (reward > 0) {
            _paidRewards += reward;
            _rewardsL2[msg.sender] = 0;
            emit RewardPaid(msg.sender, reward, 2);
            _totalStakedL2 = _totalStakedL2 + reward;
            _balancesL2[msg.sender] += reward;
            emit Staked(msg.sender, reward, 2);
        }
    }

    function compoundL3() public nonReentrant updateRewardL3(msg.sender) {
        require(currentEpoch > _lockedTillL3[msg.sender], "Rewards are locked, compounding not allowed");
        uint256 reward = _rewardsL3[msg.sender];
        if (reward > 0) {
            _paidRewards += reward;
            _rewardsL3[msg.sender] = 0;
            emit RewardPaid(msg.sender, reward, 3);
            _totalStakedL3 = _totalStakedL3 + reward;
            _balancesL3[msg.sender] += reward;
            emit Staked(msg.sender, reward, 3);
        }
    }

    function compoundL4() public nonReentrant updateRewardL4(msg.sender) {
        require(currentEpoch > _lockedTillL4[msg.sender], "Rewards are locked, compounding not allowed");
        uint256 reward = _rewardsL4[msg.sender];
        if (reward > 0) {
            _paidRewards += reward;
            _rewardsL4[msg.sender] = 0;
            emit RewardPaid(msg.sender, reward, 4);
            _totalStakedL4 = _totalStakedL4 + reward;
            _balancesL4[msg.sender] += reward;
            emit Staked(msg.sender, reward, 4);
        }
    }
    */
		
    /* ========== UNSTAKE FUNCTIONS ========== */
    function unstakeFree(uint256 amount) public nonReentrant updateRewardFree(msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        require(amount <= _balancesFree[msg.sender], "Amount exceeds balance");

        _totalStakedFree = _totalStakedFree - amount;
        _balancesFree[msg.sender] -= amount;
        stakingToken.transfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount, 0);
    }

    function unstakeL1(uint256 amount) public nonReentrant updateRewardL1(msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        require(amount <= _balancesL1[msg.sender], "Amount exceeds balance");
        uint256 part = 0;
        uint256 tax = 0;

        if (currentEpoch <= _lockedTillL1[msg.sender]) {
            part = amount * 1e6 / _balancesL1[msg.sender];      //fraction of balance to unstake
            tax = _rewardsL1[msg.sender]*part/1e6;             //rewards lost
            _taxes += tax;
            _totalRewards -= tax;
            _rewardsL1[msg.sender] = _rewardsL1[msg.sender]-tax;   //remaining rewards
            tax = (_lockedTillL1[msg.sender]-currentEpoch + 1)*_tax;   //in 1000s
            tax = tax * part * _balancesL1[msg.sender] / 1e9;      //taxes
        }
        _totalStakedL1 = _totalStakedL1 - amount;
        _balancesL1[msg.sender] -= amount;

        _taxes += tax;
        stakingToken.transfer(msg.sender, amount-tax);

        emit Withdrawn(msg.sender, amount, 1);
    }

    function unstakeL2(uint256 amount) public nonReentrant updateRewardL2(msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        require(amount <= _balancesL2[msg.sender], "Amount exceeds balance");
        uint256 part = 0;
        uint256 tax = 0;

        if (currentEpoch <= _lockedTillL2[msg.sender]) {
            part = amount * 1e6 / _balancesL2[msg.sender];      //fraction of balance to unstake
            tax = _rewardsL2[msg.sender]*part/1e6;             //rewards lost
            _taxes += tax;
            _totalRewards -= tax;
            _rewardsL2[msg.sender] = _rewardsL2[msg.sender]-tax;   //remaining rewards
            tax = (_lockedTillL2[msg.sender]-currentEpoch + 1)*_tax;   //in 1000s
            tax = tax * part * _balancesL2[msg.sender] / 1e9;      //taxes
        }
        _totalStakedL2 = _totalStakedL2 - amount;
        _balancesL2[msg.sender] -= amount;

        _taxes += tax;
        stakingToken.transfer(msg.sender, amount-tax);

        emit Withdrawn(msg.sender, amount, 2);
    }

    function unstakeL3(uint256 amount) public nonReentrant updateRewardL3(msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        require(amount <= _balancesL3[msg.sender], "Amount exceeds balance");
        uint256 part = 0;
        uint256 tax = 0;

        if (currentEpoch <= _lockedTillL3[msg.sender]) {
            part = amount * 1e6 / _balancesL3[msg.sender];      //fraction of balance to unstake
            tax = _rewardsL3[msg.sender]*part/1e6;             //rewards lost
            _taxes += tax;
            _totalRewards -= tax;
            _rewardsL3[msg.sender] = _rewardsL3[msg.sender]-tax;   //remaining rewards
            tax = (_lockedTillL3[msg.sender]-currentEpoch + 1)*_tax;   //in 1000s
            tax = tax * part * _balancesL3[msg.sender] / 1e9;      //taxes
        }
        _totalStakedL3 = _totalStakedL3 - amount;
        _balancesL3[msg.sender] -= amount;

        _taxes += tax;
        stakingToken.transfer(msg.sender, amount-tax);

        emit Withdrawn(msg.sender, amount, 3);
    }

    function unstakeL4(uint256 amount) public nonReentrant updateRewardL4(msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        require(amount <= _balancesL4[msg.sender], "Amount exceeds balance");
        uint256 part = 0;
        uint256 tax = 0;

        if (currentEpoch <= _lockedTillL4[msg.sender]) {
            part = amount * 1e6 / _balancesL4[msg.sender];      //fraction of balance to unstake
            tax = _rewardsL4[msg.sender]*part/1e6;             //rewards lost
            _taxes += tax;
            _totalRewards -= tax;
            _rewardsL4[msg.sender] = _rewardsL4[msg.sender]-tax;   //remaining rewards
            tax = (_lockedTillL4[msg.sender]-currentEpoch + 1)*_tax;   //in 1000s
            tax = tax * part * _balancesL4[msg.sender] / 1e9;      //taxes
        }
        _totalStakedL4 = _totalStakedL4 - amount;
        _balancesL4[msg.sender] -= amount;

        _taxes += tax;
        stakingToken.transfer(msg.sender, amount-tax);

        emit Withdrawn(msg.sender, amount, 4);
    }

    /* ========== REWARDS FUNCTIONS ========== */
    function getRewardFree() public nonReentrant updateRewardFree(msg.sender) {
        uint256 reward = _rewardsFree[msg.sender];
        if (reward > 0) {
            _paidRewards += reward;
            _rewardsFree[msg.sender] = 0;
            stakingToken.transfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward, 0);
        }
    }

    function getRewardL1() public nonReentrant updateRewardL1(msg.sender) {
        require(currentEpoch > _lockedTillL1[msg.sender], "Rewards are locked");
        uint256 reward = _rewardsL1[msg.sender];
        if (reward > 0) {
            _paidRewards += reward;
            _rewardsL1[msg.sender] = 0;
            stakingToken.transfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward, 1);
        }
    }

    function getRewardL2() public nonReentrant updateRewardL2(msg.sender) {
        require(currentEpoch > _lockedTillL2[msg.sender], "Rewards are locked");
        uint256 reward = _rewardsL2[msg.sender];
        if (reward > 0) {
            _paidRewards += reward;
            _rewardsL2[msg.sender] = 0;
            stakingToken.transfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward, 2);
        }
    }

    function getRewardL3() public nonReentrant updateRewardL3(msg.sender) {
        require(currentEpoch > _lockedTillL3[msg.sender], "Rewards are locked");
        uint256 reward = _rewardsL3[msg.sender];
        if (reward > 0) {
            _paidRewards += reward;
            _rewardsL3[msg.sender] = 0;
            stakingToken.transfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward, 3);
        }
    }

    function getRewardL4() public nonReentrant updateRewardL4(msg.sender) {
        require(currentEpoch > _lockedTillL4[msg.sender], "Rewards are locked");
        uint256 reward = _rewardsL4[msg.sender];
        if (reward > 0) {
            _paidRewards += reward;
            _rewardsL4[msg.sender] = 0;
            stakingToken.transfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward, 4);
        }
    }

    /* ========== EXIT FUNCTIONS ========== */
    function exitFree() public nonReentrant updateRewardFree(msg.sender) {
        _totalStakedFree -= _balancesFree[msg.sender];
        uint256 balance = _balancesFree[msg.sender];
        _balancesFree[msg.sender] = 0;

        uint256 reward = _rewardsFree[msg.sender];
        _rewardsFree[msg.sender] = 0;
        _paidRewards += reward;
        require(reward+balance>0,"Nothing to withdraw");
        stakingToken.transfer(msg.sender, reward+balance);

        emit RewardPaid(msg.sender, reward, 0);
        emit Withdrawn(msg.sender, balance, 0);
    }

    function exitL1() public nonReentrant updateRewardL1(msg.sender) {
        _totalStakedL1 -= _balancesL1[msg.sender];
        uint256 balance = _balancesL1[msg.sender];
        _balancesL1[msg.sender] = 0;

        uint256 tax = 0;
        if (currentEpoch <= _lockedTillL1[msg.sender]) {
            _taxes += _rewardsL1[msg.sender];
            _totalRewards -= _rewardsL1[msg.sender];
            _rewardsL1[msg.sender] = 0;
            tax = balance * _tax * (_lockedTillL1[msg.sender] - currentEpoch + 1) / 1e3;
            _taxes += tax;
        }
        uint256 reward = _rewardsL1[msg.sender];
        _rewardsL1[msg.sender] = 0;
        _paidRewards += reward;
        require(reward+balance-tax>0,"Nothing to withdraw");
        stakingToken.transfer(msg.sender, reward+balance-tax);

        emit RewardPaid(msg.sender, reward, 1);
        emit Withdrawn(msg.sender, balance-tax, 1);
    }

     function exitL2() public nonReentrant updateRewardL2(msg.sender) {
        _totalStakedL2 -= _balancesL2[msg.sender];
        uint256 balance = _balancesL2[msg.sender];
        _balancesL2[msg.sender] = 0;

        uint256 tax = 0;
        if (currentEpoch <= _lockedTillL2[msg.sender]) {
            _taxes += _rewardsL2[msg.sender];           //all rewards are lost
            _totalRewards -= _rewardsL2[msg.sender];
            _rewardsL2[msg.sender] = 0;
            tax = balance * _tax * (_lockedTillL2[msg.sender] - currentEpoch + 1) / 1e3;
            _taxes += tax;
        }
        uint256 reward = _rewardsL2[msg.sender];
        _rewardsL2[msg.sender] = 0;
        _paidRewards += reward;
        require(reward+balance-tax>0,"Nothing to withdraw");
        stakingToken.transfer(msg.sender, reward+balance-tax);

        emit RewardPaid(msg.sender, reward, 2);
        emit Withdrawn(msg.sender, balance-tax, 2);
    }

    function exitL3() public nonReentrant updateRewardL3(msg.sender) {
        _totalStakedL3 -= _balancesL3[msg.sender];
        uint256 balance = _balancesL3[msg.sender];
        _balancesL3[msg.sender] = 0;

        uint256 tax = 0;
        if (currentEpoch <= _lockedTillL3[msg.sender]) {
            _taxes += _rewardsL3[msg.sender];
            _totalRewards -= _rewardsL3[msg.sender];
            _rewardsL3[msg.sender] = 0;
            tax = balance * _tax * (_lockedTillL3[msg.sender] - currentEpoch + 1) / 1e3;
            _taxes += tax;
        }
        uint256 reward = _rewardsL3[msg.sender];
        _rewardsL3[msg.sender] = 0;
        _paidRewards += reward;
        require(reward+balance-tax>0,"Nothing to withdraw");
        stakingToken.transfer(msg.sender, reward+balance-tax);

        emit RewardPaid(msg.sender, reward, 3);
        emit Withdrawn(msg.sender, balance-tax, 3);
    }

    function exitL4() public nonReentrant updateRewardL4(msg.sender) {
        _totalStakedL4 -= _balancesL4[msg.sender];
        uint256 balance = _balancesL4[msg.sender];
        _balancesL4[msg.sender] = 0;

        uint256 tax = 0;
        if (currentEpoch <= _lockedTillL4[msg.sender]) {
            _taxes += _rewardsL4[msg.sender];
            _totalRewards -= _rewardsL4[msg.sender];
            _rewardsL4[msg.sender] = 0;
            tax = balance * _tax * (_lockedTillL4[msg.sender] - currentEpoch + 1) / 1e3;
            _taxes += tax;
        }
        uint256 reward = _rewardsL4[msg.sender];
        _rewardsL4[msg.sender] = 0;
        _paidRewards += reward;
        require(reward+balance-tax>0,"Nothing to withdraw");
        stakingToken.transfer(msg.sender, reward+balance-tax);

        emit RewardPaid(msg.sender, reward, 4);
        emit Withdrawn(msg.sender, balance-tax, 4);
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function newEpoch(uint256 rFree, uint256 rL1, uint256 rL2, uint256 rL3, uint256 rL4) public onlyAdmin {
        require(rFree+rL1+rL2+rL3+rL4 > 0,"Reward must be > 0");

        _rewardRatesFree[currentEpoch] = rFree * 1e18 / _totalStakedFree;   //current epoch APY
        _totalRewards += rFree;

        _rewardRatesL1[currentEpoch] = rL1 * 1e18 / _totalStakedL1;   //current epoch APY
        _totalRewards += rL1;

        _rewardRatesL2[currentEpoch] = rL2 * 1e18 / _totalStakedL2;   //current epoch APY
        _totalRewards += rL2;

        _rewardRatesL3[currentEpoch] = rL3 * 1e18 / _totalStakedL3;   //current epoch APY
        _totalRewards += rL3;

        _rewardRatesL4[currentEpoch] = rL4 * 1e18 / _totalStakedL4;   //current epoch APY
        _totalRewards += rL4;

        stakingToken.transferFrom(msg.sender, address(this), rFree+rL1+rL2+rL3+rL4);

        emit NewEpoch(currentEpoch, rFree+rL1+rL2+rL3+rL4, _rewardRatesFree[currentEpoch], _rewardRatesL1[currentEpoch], _rewardRatesL2[currentEpoch], _rewardRatesL3[currentEpoch], _rewardRatesL4[currentEpoch]);

        currentEpoch++;
    }

    function setMaxIter(uint256 maxIter) public onlyAdmin {
        _maxIter = maxIter;
    }

    function setLockDuration(uint256 lock1Weeks, uint256 lock2Weeks, uint256 lock3Weeks, uint256 lock4Weeks) public onlyAdmin {
        require(lock1Weeks < 26, "Reduce L1 duration");
        require(lock2Weeks < 52, "Reduce L2 duration");
        require(lock3Weeks < 75, "Reduce L3 duration");
        require(lock4Weeks < 100, "Reduce L4 duration");

        _lock1Duration = lock1Weeks;
        _lock2Duration = lock2Weeks;
        _lock3Duration = lock3Weeks;
        _lock4Duration = lock4Weeks;

    }

	/**
	* @dev Function to set Token address (only admin)
	* @param tokenAddress address of the traded token contract
	*/
	function setTokenAddr(address tokenAddress) public onlyAdmin {
	    require(tokenAddress != address(0), "INVALID_ADDRESS");
		stakingToken = IERC20(tokenAddress);
	}

	/**
	* @dev Function to set taxes (only admin)
	* @param tax taxation percentage for lock1
    *
	*/
	function setTaxes(uint256 tax) public onlyAdmin {
	    require(tax <= 10, "Taxation needs to be lower than 1% per epoch");
        _tax = tax;
	}

	/**
	* @dev Function to set limits for L4 (only admin)
	* @param maxPerAccount limit per account for lock4
    * @param maxTotal total limit for lock4
	*/
	function setTaxes(uint256 maxPerAccount, uint256 maxTotal) public onlyAdmin {
        _maxPerAccountL4 = maxPerAccount;
        _maxTotalL4 = maxTotal;
	}

	/**
	* @dev Function to enable/disable staking (only admin)
	* @param enableFree free staking enable
    * @param enableL1 lock1 staking enable
    * @param enableL2 lock2 staking enable
    * @param enableL3 lock3 staking enable
    * @param enableL4 lock4 staking enable
	*/
	function setStakeEnable(uint256 enableFree, uint256 enableL1, uint256 enableL2, uint256 enableL3, uint256 enableL4) public onlyAdmin {
        _stakeFreeEnable = enableFree;
        _stakeL1Enable = enableL1;
        _stakeL2Enable = enableL2;
        _stakeL3Enable = enableL3;
        _stakeL4Enable = enableL4;
	}

    /**
	* @dev Function to withdraw lost tokens balance (only admin)
	* @param tokenAddr Token address
	*/
	function withdrawToken(address tokenAddr) public onlyAdmin returns(uint256) {
	    require(tokenAddr != address(0), "INVALID_ADDRESS");
		require(tokenAddr != address(stakingToken), "Cannot withdraw staked tokens");

		IERC20 token = IERC20(tokenAddr);

		uint256 balance = token.balanceOf(address(this));

		token.transfer(msg.sender,balance);

		return balance;
	}

    /**
	* @dev Function to withdraw taxes (only admin)
	*
	*/
	function withdrawTaxes() public onlyAdmin returns(uint256) {
        uint256 temp;

        stakingToken.transfer(msg.sender,_taxes);
        temp = _taxes;
        _taxes = 0;

		return temp;
	}

	/**
	* @dev Function to withdraw TRX balance (only admin)
	*/
    function withdrawTrx() public onlyAdmin returns(uint256){
        uint256 balance = address(this).balance;
		address payable rec = payable(msg.sender);
		(bool sent, ) = rec.call{value: balance}("");
		require(sent, "Failed to send TRX");
		return balance;
    }

    /* ========== MODIFIERS ========== */

    modifier updateRewardFree(address account) {
        uint256 temp=0;
        uint256 loopEnd = currentEpoch;
        if ((loopEnd-_lastUpdateFree[account]) > _maxIter) {
            loopEnd = _lastUpdateFree[account]+_maxIter;
        }
        for (uint i=_lastUpdateFree[account];i<loopEnd;i++) {
            temp += _rewardRatesFree[i];
        }
        _rewardsFree[account]+=temp*_balancesFree[account]/1e18;
        _lastUpdateFree[account] = loopEnd;
        _;
    }

    modifier updateRewardL1(address account) {
        uint256 temp=0;
        uint256 loopEnd = currentEpoch;
        if ((loopEnd-_lastUpdateL1[account]) > _maxIter) {
            loopEnd = _lastUpdateL1[account]+_maxIter;
        }
        for (uint i=_lastUpdateL1[account];i<loopEnd;i++) {
            temp += _rewardRatesL1[i];
        }
        _rewardsL1[account]+=temp*_balancesL1[account]/1e18;
        _lastUpdateL1[account] = loopEnd;
        _;
    }

    modifier updateRewardL2(address account) {
        uint256 temp=0;
        uint256 loopEnd = currentEpoch;
        if ((loopEnd-_lastUpdateL2[account]) > _maxIter) {
            loopEnd = _lastUpdateL2[account]+_maxIter;
        }
        for (uint i=_lastUpdateL2[account];i<loopEnd;i++) {
            temp += _rewardRatesL2[i];
        }
        _rewardsL2[account]+=temp*_balancesL2[account]/1e18;
        _lastUpdateL2[account] = loopEnd;
        _;
    }

    modifier updateRewardL3(address account) {
        uint256 temp=0;
        uint256 loopEnd = currentEpoch;
        if ((loopEnd-_lastUpdateL3[account]) > _maxIter) {
            loopEnd = _lastUpdateL3[account]+_maxIter;
        }
        for (uint i=_lastUpdateL3[account];i<loopEnd;i++) {
            temp += _rewardRatesL3[i];
        }
        _rewardsL3[account]+=temp*_balancesL3[account]/1e18;
        _lastUpdateL3[account] = loopEnd;
        _;
    }

    modifier updateRewardL4(address account) {
        uint256 temp=0;
        uint256 loopEnd = currentEpoch;
        if ((loopEnd-_lastUpdateL4[account]) > _maxIter) {
            loopEnd = _lastUpdateL4[account]+_maxIter;
        }
        for (uint i=_lastUpdateL4[account];i<loopEnd;i++) {
            temp += _rewardRatesL4[i];
        }
        _rewardsL4[account]+=temp*_balancesL4[account]/1e18;
        _lastUpdateL4[account] = loopEnd;
        _;
    }
}