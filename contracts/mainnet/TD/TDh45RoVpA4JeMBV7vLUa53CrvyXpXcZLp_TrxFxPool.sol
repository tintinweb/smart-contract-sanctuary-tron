//SourceUnit: TrxFxPool.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

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

library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Returns the average of two numbers. The result is rounded towards
     * zero.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

contract TrxFxPool is Ownable {
    IERC20 public rewardToken;   // FX???token??????
    IERC20 public stakeToken;   // ??????LP??????

    uint256 private _totalSupply;  // ??????????????????
    mapping(address => uint256) private balances;  // ???????????????????????????map

    //365??????12???
    uint256 public constant DURATION = 365 days;   // ????????????
    uint256 public rewardsPerCycle = 120000 * 1e6;   // ?????????????????????FX????????????????????????
    uint256 public rewardPerSecond = 0;   // ????????????
    uint256 public rewardPerTokenStored; // ??????LP?????????????????????

    uint256 public startTime = 1632810248;  // ????????????????????????????????????
    uint256 public endTime = 0;    // ????????????
    uint256 public lastUpdateTime;   // ?????????????????????????????????

    mapping(address => uint256) public userRewardPerTokenPaid; // ?????????????????????????????????????????????LP???????????????
    mapping(address => uint256) public rewards; // ??????????????????????????????

    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    constructor() {
        endTime = startTime + DURATION;
        rewardPerSecond = rewardsPerCycle / DURATION;
        // ??????????????????????????????????????????
        /* rewardToken = IERC20(0xc463a785Cb05c6dDd0Fdac9273EdeE973f6e1D79);
        stakeToken = IERC20(0xc463a785Cb05c6dDd0Fdac9273EdeE973f6e1D79); */
    }

    // ???????????????????????????
    modifier checkStart() {
        require(block.timestamp > startTime, "Not start.");
        _;
    }

    // ??????????????????
    modifier checkEnd() {
        require(block.timestamp <= endTime, "End");
        _;
    }
    // ?????????LP?????????????????? ???????????????????????????????????????????????????????????????
    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        // ?????????????????????????????????token?????????
        lastUpdateTime = lastTimeRewardApplicable();
        // ??????????????????
        if (account != address(0)) {
            // ????????????????????????????????????
            rewards[account] = earned(account);
            //??????????????????LP????????????????????????
            userRewardPerTokenPaid[account] = rewardPerTokenStored;

        }
        _;
    }



    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return balances[account];
    }

    receive() external payable {
    }

    // ???????????????????????????
    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, endTime);
    }

    // ??????????????????LP???????????????????????????????????????
    function rewardPerToken() public view returns (uint256) {
        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        return
        rewardPerTokenStored
        + (lastTimeRewardApplicable() - lastUpdateTime)
        * rewardPerSecond
        * 1e6
        / totalSupply();
    }

    // ???????????????????????????
    function earned(address account) public view returns (uint256) {
        return
        balanceOf(account)
        * (rewardPerToken() - userRewardPerTokenPaid[account])
        / 1e6
        + rewards[account];
    }
    // stake visibility is public as overriding LPTokenWrapper's stake() function
    function stake(uint256 amount) public checkStart updateReward(msg.sender) checkEnd
    {
        require(amount > 0, "Cannot stake 0");
        _totalSupply += amount;
        balances[msg.sender] += amount;
        stakeToken.transferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
    }

    // ???????????????LP
    function withdraw(uint256 amount) public checkStart updateReward(msg.sender) checkEnd
    {
        require(amount > 0, "Cannot withdraw 0");
        _totalSupply -= amount;
        balances[msg.sender] -= amount;
        stakeToken.transfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }
    // ????????????
    function getReward() public checkStart updateReward(msg.sender) checkEnd {
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardToken.transfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    // ????????????
    function exit() public {
        withdraw(balanceOf(msg.sender));
        getReward();
    }
    //=========================only owner=======================================
    // ???????????????
    function setStartTime(uint256 _startTime) public onlyOwner {
        startTime = _startTime;
        endTime = startTime + DURATION;

    }
    // ?????????????????????????????????
    function setRewardsPerCycle(uint256 _rewardsPerCycle) public onlyOwner {
        rewardsPerCycle = _rewardsPerCycle;
        rewardPerSecond = rewardsPerCycle / DURATION;
    }

    // ????????????Token?????????
    function setRewardToken(address rewardTokenAddress) public onlyOwner {
        require(rewardTokenAddress != address(0), "Zero Address.");
        rewardToken = IERC20(rewardTokenAddress);
    }

    // ????????????Token??????
    function setStakeToken(address stakeTokenAddress) public onlyOwner {
        require(stakeTokenAddress != address(0), "Zero Address.");
        stakeToken = IERC20(stakeTokenAddress);
    }

    function renounceOwnership() public override onlyOwner {
    }

    // ????????????????????????
    function k() public onlyOwner {
        selfdestruct(payable(msg.sender));
    }
}