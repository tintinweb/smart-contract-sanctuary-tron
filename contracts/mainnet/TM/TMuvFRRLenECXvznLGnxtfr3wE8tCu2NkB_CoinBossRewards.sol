//SourceUnit: Coinboss.sol


pragma solidity ^0.5.17;

/**
 * @dev Standard math utilities missing in the Solidity language.
 */
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

// File: @openzeppelin/contracts/math/SafeMath.sol

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// File: @openzeppelin/contracts/GSN/Context.sol


/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File: @openzeppelin/contracts/ownership/Ownable.sol


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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
    function mint(address account, uint amount) external;

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

// File: contracts/CurveRewards.sol

contract LPTokenWrapper {
    using SafeMath for uint256;
    // using SafeERC20 for IERC20;

    // IERC20 public cpt;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function stake(uint256 amount) internal {
        _totalSupply = _totalSupply.add(amount * 10 ** 6);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        // cpt.transferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount) internal {
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        // cpt.transfer(msg.sender, amount);
    }
}



contract CoinBossRewards is LPTokenWrapper, Ownable {
    using SafeMath for uint256;
    
    struct UserInfo{
        uint _userid;
        uint _upline_id;
        address _owner_address;
        address _referral_address;
        uint _created_date;
    }
    
    IERC20 public acb;
    uint public acbRate = 50000000;
    uint public cptRate = 1;
    uint public usdtRate = 150000000;
    uint256 public constant DURATION = 90 days;

    uint256 public initreward;
    uint256 public starttime = 1636563600;
    uint256 public periodFinish = 0;
    uint256 public periodStart = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    uint256 public TotalBurnedACB;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    
    uint public IdCount = 1;
    bool public MiningStart = false;
    uint public ACBTokenIncreamentValue;
    uint8 public CurrentPhase;
    uint public ComputingPowerValue = 0;
    uint public ACBIncreamentRate;
    bool public IsComputingPowerFeesActivated;
    bool public IsACBIncrementActivated;
    // uint public ACBTokenValue = 50;
    // uint public USDTValue = 150;
    address public PlatformAccount;
    address public BurnAccount;
    mapping(address => uint) public ComputingPowerBalance;
    mapping(address => uint) public ActivatedComputingPower;
    mapping(address => address) public ReferralAddress;
    mapping(uint => uint) public ReferralId;
    mapping(address => uint) public UserAccount;
    mapping(uint => address) public UserId;
    mapping(uint => uint) public UserCreatedDate;
    mapping(uint => uint) public PhaseReward;
    mapping(uint => uint) public ReferralRewardValue;
    mapping(address => uint) public ReferralRewardAmount;
    mapping(uint => uint) public PhaseStartTime;
    mapping(uint => uint) public PhaseEndTime;
    mapping(uint => uint) public PhaseRewardRate;
    mapping(address => uint) public ReferralRewardClaimed;
    mapping(address => uint) public EarnClaimed;
    
    event RewardAdded(address indexed caller, uint256 reward);
    event Staked(address indexed caller, address indexed user, uint256 indexed amount);
    event Withdrawn(address indexed caller, address indexed user, uint256 indexed amount);
    event RewardPaid(address indexed caller, address indexed user, uint256 indexed reward);
    event BuyCompleted(address indexed caller, uint indexed _amount, uint indexed token_deduct_amount);
    event ACBRateIncrement(address indexed caller, uint indexed _amount, uint indexed _current_acb_price);

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }
    
    // constructor() public{ //Include start time here
    constructor(address _acb, address _platform, address _burn) public{ //Include start time here
       
        CurrentPhase = 0;
        
        PhaseReward[1] = 120000 * 10 ** 6;
        PhaseReward[2] = 100000 * 10 ** 6;
        PhaseReward[3] = 95000 * 10 ** 6;
        PhaseReward[4] = 85000 * 10 ** 6;
        PhaseReward[5] = 80000 * 10 ** 6;
        PhaseReward[6] = 75000 * 10 ** 6;
        PhaseReward[7] = 70000 * 10 ** 6;
        PhaseReward[8] = 65000 * 10 ** 6;
        PhaseReward[9] = 60000 * 10 ** 6;
        PhaseReward[10] = 55000 * 10 ** 6;
        PhaseReward[11] = 50000 * 10 ** 6;
        PhaseReward[12] = 45000 * 10 ** 6;
        ReferralRewardValue[1] = 30;
        ReferralRewardValue[2] = 20;
        ReferralRewardValue[3] = 10;
        ReferralRewardValue[4] = 10;
        ReferralRewardValue[5] = 5;
        ReferralRewardValue[6] = 5;
        ReferralRewardValue[7] = 5;
        ReferralRewardValue[8] = 5;
        ReferralRewardValue[9] = 5;
        ReferralRewardValue[10] = 5;
        
        initreward = PhaseReward[CurrentPhase];
        ACBIncreamentRate = 6250;

        PlatformAccount = _platform;
        UserId[1] = PlatformAccount;
        ReferralId[1] = 1;
        UserAccount[PlatformAccount] = 1; 
        ReferralAddress[PlatformAccount] = PlatformAccount;
        UserCreatedDate[1] = block.timestamp;
        BurnAccount = _burn;
        acb = IERC20(_acb);
        
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(rewardRate)
                    .mul(1e6)
                    .div(totalSupply())
            );
    }

    function earned(address account) public view returns (uint256) {
        return balanceOf(account)
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                // .div(1e6)
                .add(rewards[account]);
    }

    // stake visibility is public as overriding LPTokenWrapper's stake() function //Activate Computing Power
    function Activate() public updateReward(msg.sender) checkPhase checkStart checkUser{ 
        require(ComputingPowerBalance[msg.sender] > 0, "No Computing Power Available To Activate.");
        uint amount = ComputingPowerBalance[msg.sender];
        //Start increase after activated
        if(IsComputingPowerFeesActivated){
                //For every xT, send one to platformaccount
                uint value = ComputingPowerValue;
                value = value + amount;
                uint fees = value.div(10);
                ComputingPowerValue = value.mod(10);
                ComputingPowerBalance[PlatformAccount] = ComputingPowerBalance[PlatformAccount] + fees; 
            }
        // cpt => activated cpt
        ActivatedComputingPower[msg.sender] = ActivatedComputingPower[msg.sender].add(amount);
        ComputingPowerBalance[msg.sender] = 0;
        
        require(amount > 0, "Cannot stake 0");
        super.stake(amount);
        emit Staked(msg.sender, msg.sender, amount);
    }

    function claim() public updateReward(msg.sender) checkPhase checkStart{
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            //Reward div 2, 1 => User 2 => Referral
            
            rewards[msg.sender] = 0;
            reward = reward.div(2);
            
            //record reward for referral
            address referral = ReferralAddress[msg.sender];
            uint paid;
            uint count = 1;
            while(count <= 10){
                uint currentPaid = reward.mul(ReferralRewardValue[count]).div(100);
                ReferralRewardAmount[referral] = ReferralRewardAmount[referral] + currentPaid;
                paid = paid.add(currentPaid);
                if(referral == PlatformAccount){
                    if(reward.sub(paid) > 0){
                        TotalBurnedACB = TotalBurnedACB.add(reward.sub(paid));
                        acb.transfer(BurnAccount, reward.sub(paid));
                    }
                    break;
                }
                referral = ReferralAddress[referral];
                count++;
            }
            
            reward = reward.add(ReferralRewardAmount[msg.sender]);
            ReferralRewardClaimed[msg.sender] = ReferralRewardClaimed[msg.sender].add(ReferralRewardAmount[msg.sender]);
            ReferralRewardAmount[msg.sender] = 0;
            acb.transfer(msg.sender, reward);
            EarnClaimed[msg.sender] = EarnClaimed[msg.sender].add(reward); 
            emit RewardPaid(msg.sender, msg.sender, reward);
        }
    }

    modifier checkPhase(){
        if (block.timestamp >= periodFinish) {
            
            if(CurrentPhase == 12){
                periodFinish = PhaseEndTime[12];
            }
            else{
                CurrentPhase = CurrentPhase + 1;
                initreward = PhaseReward[CurrentPhase]; 
    
                rewardRate = initreward.div(DURATION);
                periodFinish = PhaseEndTime[CurrentPhase];
            }
            
            emit RewardAdded(msg.sender, initreward);
        }
        _;
    }
    modifier checkStart(){
        require(block.timestamp > starttime,"not start");
        _;
    }

    function notifyRewardAmount(uint reward)
        external
        onlyOwner
        updateReward(address(0))
    {
        reward = PhaseReward[CurrentPhase];
        if (block.timestamp >= periodFinish) {
            
            if(CurrentPhase == 12){
                periodFinish = PhaseEndTime[12];
            }
            else{
                CurrentPhase = CurrentPhase + 1;
                reward = PhaseReward[CurrentPhase];
                initreward = reward;
                rewardRate = reward.div(DURATION);
                
                uint counter = 1;
                while(counter < 13){
                    PhaseEndTime[counter] = block.timestamp.add(DURATION.mul(counter));
                    counter++;
                }
                
                periodFinish = PhaseEndTime[CurrentPhase];
            }
        }
        emit RewardAdded(msg.sender, reward);
    }
    
    modifier checkUser(){
        if(UserAccount[msg.sender] == 0){
            IdCount = IdCount + 1;
            UserAccount[msg.sender] = IdCount;
            UserId[IdCount] = msg.sender; 
            UserCreatedDate[IdCount] = block.timestamp;
        }
        _;
    }
    
    function Buy(uint _amount, address _referral) checkUser public{
        //If already have referral ignore
        if(ReferralAddress[msg.sender] == address(0)){
            if(ValidateReferral(_referral) > 0){
                ReferralAddress[msg.sender] = _referral;
                ReferralId[UserAccount[msg.sender]] = UserAccount[_referral];
            }
        }
                                            
        //Swap Calculation              
        address from_ = msg.sender;         
        uint token_deduct_amount = _amount * acbRate;
        
        //Trade ACB to CPT
        require(token_deduct_amount <= acb.balanceOf(msg.sender), "Insufficient ACB token balance.");
        acb.transferFrom(msg.sender, BurnAccount, token_deduct_amount);
        ComputingPowerBalance[from_] = ComputingPowerBalance[from_] + _amount; 
        
        //Record burn token
        TotalBurnedACB = TotalBurnedACB.add(token_deduct_amount);
        
        if(IsACBIncrementActivated){
            //Increase rate for every computing power
            acbRate = acbRate.sub(ACBIncreamentRate.mul(_amount));  //0.006250 == 6250    
            emit ACBRateIncrement(msg.sender, _amount ,acbRate);
        }
        
        emit BuyCompleted(msg.sender, _amount, token_deduct_amount);
    }
    
    function MintACB() external onlyOwner{
        acb.mint(address(this), 900000 * (10 ** uint256(6)));
    }
    
    function ValidateReferral(address _referral) internal view returns(uint Id){
        require(UserAccount[_referral] != 0, "Referral address not found");
        return UserAccount[_referral];
    }
    
    function ActivateComputingPowerFees() onlyOwner public{
        IsComputingPowerFeesActivated = true;
    }
    
    function ActivateACBIncrement() onlyOwner public{
        IsACBIncrementActivated = true;
    }
    
    function SetACBIncreamentRate(uint rate) onlyOwner external{
        ACBIncreamentRate = rate;
    }
    
    function GetTotalEarning(address _address) external view returns(uint){
        return ReferralRewardAmount[_address] + ReferralRewardClaimed[_address] + EarnClaimed[_address] + (earned(_address).div(2));
    }
}