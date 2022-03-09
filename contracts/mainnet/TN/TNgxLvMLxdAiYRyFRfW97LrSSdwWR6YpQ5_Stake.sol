//SourceUnit: ERC20.sol

pragma solidity ^0.5.0;

import "./IERC20.sol";
import "./SafeMath.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20Mintable}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `value`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

     /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
     * @dev Destoys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}

//SourceUnit: ERC20Detailed.sol

pragma solidity ^0.5.0;

import "./IERC20.sol";

/**
 * @dev Optional functions from the ERC20 standard.
 */
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}



//SourceUnit: IERC20.sol

pragma solidity ^0.5.0;

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


//SourceUnit: Ownable.sol

pragma solidity 0.5.10;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;
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
        require(msg.sender == owner, 'erronlyOwnererr');
        _;
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}


//SourceUnit: SafeMath.sol

pragma solidity ^0.5.0;

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
        require(b <= a, "SafeMath: subtraction overflow");
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
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
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


//SourceUnit: Stake.sol

// 0.5.1-c8a2
// Enable optimization
pragma solidity ^0.5.10;

import "./ERC20.sol";
import "./ERC20Detailed.sol";
import "./SafeMath.sol";
import "./Ownable.sol";
import "./Token.sol";


contract Stake is Ownable {
    using SafeMath for uint256;

    address public destroyAddress = address(0x0000000000000000000000000000000000000001);

    struct PoolInfo {
        address master;
        address slaver;
        address awardToken;
        uint scale;
        uint rate;
        uint base;
        uint maxTime;
        uint totalDeposit;
        uint master_destroy;
        uint slaver_destroy;
    }

    uint public period = 1 days;

    struct NodeInfo {
        bool active;
        uint count;
        address referrer;
        mapping(uint => address) nodes;
    }

    struct UserInfo {
        uint amount;
        uint start;
        uint time;
        uint award;
        uint award_pending;
        uint static_award;
    }

    uint public maxId = 0;

    mapping(uint => mapping (address => UserInfo)) public userInfo;
    mapping(address => NodeInfo) public nodeInfo;
    mapping(uint => PoolInfo) public poolInfo;
    uint public poolAmount = 1;

    mapping(uint8 => uint) public awardRate;
    mapping(uint8 => uint) public awardRequire;
    mapping(uint8 => uint) public levelRequire;
    uint public rateBase = 1000;

    event Deposit(address indexed user, uint256 amount);
    event Harvest(uint indexed pid, address indexed user, uint256 amount);
    event Award(address indexed user, address indexed upline, uint256 amount, uint g);
  
    constructor (address _master, address _slaver, address _awardToken) public {
        awardRate[0] = 60;
        awardRate[1] = 50;
        awardRate[2] = 40;
        awardRate[3] = 30;
        awardRate[4] = 30;
        awardRate[5] = 30;
        awardRate[6] = 30;
        awardRate[7] = 30;

        awardRequire[0] = 50 * 1e18;
        awardRequire[1] = 50 * 1e18;
        awardRequire[2] = 100 * 1e18;
        awardRequire[3] = 100 * 1e18;
        awardRequire[4] = 300 * 1e18;
        awardRequire[5] = 300 * 1e18;
        awardRequire[6] = 500 * 1e18;
        awardRequire[7] = 500 * 1e18;

        levelRequire[0] = 50 * 1e18;
        levelRequire[1] = 100 * 1e18;
        levelRequire[2] = 300 * 1e18;
        levelRequire[3] = 500 * 1e18;

        nodeInfo[msg.sender].active = true;

        PoolInfo storage pool = poolInfo[0];

        pool.master = _master;
        pool.slaver = _slaver;
        pool.awardToken = _awardToken;
        pool.scale = 10;
        pool.rate = 5000000000000000000;
        pool.base = 10;
        pool.maxTime = 120 days;
        pool.master_destroy = 100;
        pool.slaver_destroy = 70;
    }

    function setUint(uint _index, uint _value) public onlyOwner {
        if(_index == 0) {
            
        }else if(_index == 1) {
            period = _value;
        }else if(_index == 2) {
            poolAmount = _value;
        }
    }

    function claimToken(address token, uint amount) public onlyOwner {
        ERC20(token).transfer(msg.sender, amount);
    }


    function setUintArray(uint _index, uint8 _key, uint _value) public onlyOwner {
        if(_index == 0) {
            awardRate[_key] = _value;
        }else if(_index == 1) {
            awardRequire[_key] = _value;
            levelRequire[_key/2] = _value;
        }
    }

    function getNode(address addr, uint index) public view returns(address) {
        return nodeInfo[addr].nodes[index];
    }

    function getLevel(uint pid, address addr) public view returns(uint8) {
        UserInfo storage user = userInfo[pid][addr];
        if(user.amount >= levelRequire[3]) {
            return 4;
        }else if(user.amount >= levelRequire[2]) {
            return 3;
        }else if(user.amount >= levelRequire[1]) {
            return 2;
        }else if(user.amount >= levelRequire[0]) {
            return 1;
        }else{
            return 0;
        }
    }

    /*
        address master;
        address slaver;
        address awardToken;
        uint scale;
        uint rate;
        uint base;
        uint maxTime;
        uint totalDeposit;
        uint master_destroy;
        uint slaver_destroy;
    */
    function setPool(uint _pid, address _master, address _slaver, address _awardToken, uint _base, uint _scale, uint _rate) public onlyOwner {
        PoolInfo storage pool = poolInfo[_pid];
        pool.master = _master;
        pool.slaver = _slaver;
        pool.awardToken = _awardToken;
        pool.base = _base;
        pool.scale = _scale;
        pool.rate = _rate;
    }

    function setPool2(uint _pid, uint _maxTime, uint _totalDeposit, uint _master_destroy, uint _slaver_destroy) public onlyOwner {
        PoolInfo storage pool = poolInfo[_pid];
        pool.maxTime = _maxTime;
        pool.totalDeposit = _totalDeposit;
        pool.master_destroy = _master_destroy;
        pool.slaver_destroy = _slaver_destroy;
    }

    function getSlaverAmount(uint _pid, uint _amount) view public returns (uint) {
        PoolInfo storage pool = poolInfo[_pid];
        uint amount_slaver = _amount.mul(pool.scale).div(pool.base);
        return amount_slaver;
    }

    function deposit(uint _pid, address _referrer, uint _amount) external payable {        
        UserInfo storage user = userInfo[_pid][msg.sender];
        PoolInfo storage pool = poolInfo[_pid];
        NodeInfo storage node = nodeInfo[msg.sender];

        //未激活
        if(node.active == false) {
            require(nodeInfo[_referrer].active, 'errupline must activederr');
            node.active = true;
            node.referrer = _referrer;
            nodeInfo[_referrer].nodes[nodeInfo[_referrer].count] = msg.sender;
            nodeInfo[_referrer].count += 1;
        }
        
        //结算
        _harvest(msg.sender, _pid);
    
        //判断余额
        require(_amount <= ERC20(pool.master).balanceOf(msg.sender), 'errbalanceerr');
        require(_amount <= ERC20(pool.master).allowance(msg.sender, address(this)), 'errallowanceerr');

        //支付主币
        ERC20(pool.master).transferFrom(address(msg.sender), address(this), _amount);
        //销毁
        ERC20(pool.master).transfer(destroyAddress, _amount.mul(pool.master_destroy).div(100));
    
        uint amount_slaver = _amount.mul(pool.scale).div(pool.base);
        //从币支付
        if(amount_slaver > 0) {
            require(amount_slaver <= ERC20(pool.slaver).balanceOf(msg.sender), 'errbalance2err');
            ERC20(pool.slaver).transferFrom(address(msg.sender), address(this), amount_slaver);
            //销毁
            ERC20(pool.slaver).transfer(destroyAddress, amount_slaver.mul(pool.slaver_destroy).div(100));
        }  
        
        user.amount += _amount;
        pool.totalDeposit += _amount;
        if(user.start == 0) {
            user.start = now;
        }
        user.time = now;

        doAward(_pid, amount_slaver, msg.sender);
     
        emit Deposit(msg.sender, _amount);
    }

    function doAward(uint _pid, uint amount, address addr) private {
        // PoolInfo storage pool = poolInfo[_pid];

        for(uint8 g = 0; g < 8;) {
            NodeInfo storage node = nodeInfo[addr];
            UserInfo storage upUser = userInfo[_pid][node.referrer];
            // NodeInfo storage upNode = nodeInfo[node.referrer];
            
            if(node.referrer != address(0)) {
                if(upUser.amount >= awardRequire[g]) {
                    uint award = amount.mul(awardRate[g]).div(rateBase);

                    // ERC20(pool.awardToken).transfer(node.referrer, award);
                    upUser.award_pending += award;

                    emit Award(addr, node.referrer, award, g);
                    g += 1;
                }
            }else{
                break;
            }

            addr = node.referrer;
        }
    }

    function pending(address addr, uint _pid) view public returns(uint) {
        UserInfo storage user = userInfo[_pid][addr];
        PoolInfo storage pool = poolInfo[_pid];
        uint end = now;
        if(user.start + pool.maxTime < now ) {
            end = user.start + pool.maxTime;
        }
        uint time = end.sub(user.time);
        if(pool.totalDeposit == 0) {
            return 0;
        }
        uint award = user.amount.mul(time).mul(pool.rate).div(pool.base).div(period).div(pool.totalDeposit);
        return award;
    }

    function claimAward(uint pid) public returns(bool) {
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];
        require(user.award_pending > 0, 'errawardpendingerr');
        uint pend = user.award_pending;
        user.award = user.award.add(user.award_pending);
        user.award_pending = 0;
        ERC20(pool.awardToken).transfer(msg.sender, pend);
        return true;
    }

    function harvest(uint _pid) public {
        _harvest(msg.sender, _pid);
    }
    
    function _harvest(address addr, uint _pid) private {
        UserInfo storage user = userInfo[_pid][addr];
        PoolInfo storage pool = poolInfo[_pid];

        //奖
        uint award = pending(addr, _pid);
        if(award > 0) {
            safeAward(pool.awardToken, address(addr), award);
            user.static_award += award;
        }

        user.time = now;
    }

    function safeAward(address token, address to, uint amount) internal {
        uint ba = ERC20(token).balanceOf(address(this));
        if(ba < amount) {
            ERC20(token).transfer(to, ba);
        }else{
            ERC20(token).transfer(to, amount);
        }
    }
}


//SourceUnit: Token.sol

// 0.5.1-c8a2
// Enable optimization
pragma solidity ^0.5.0;

import "./ERC20.sol";
import "./ERC20Detailed.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

/**
 * @title SimpleToken
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `ERC20` functions.
 */
contract Token is ERC20, ERC20Detailed, Ownable {
    using SafeMath for uint256;

    address public pairAddress = 0x0000000000000000000000000000000000000000;

    address public destroyAddress = 0x0000000000000000000000000000000000000001;

    mapping(address => bool) public whiteList;

    uint public feePercent = 1000;
    uint public transFees = 50;
    uint public sellFees = 100;
    address public feeTo;

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint _total) public ERC20Detailed(_name, _symbol, _decimals) {
        _mint(msg.sender, _total * (10 ** uint256(decimals())));
        feeTo = owner;
    }

    function setFeeTo(address _addr) public onlyOwner {
        feeTo = _addr;
    }

    function setPairAddress(address _pairAddress) public onlyOwner {
        pairAddress = _pairAddress;
    }

    function setWhiteList(address _addr, bool _v) public onlyOwner {
        whiteList[_addr] = _v;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        if(!whiteList[sender] && !whiteList[recipient]) {
            uint fees = 0;
            if (recipient == pairAddress) {
                fees = amount.mul(sellFees).div(feePercent);
                super._transfer(sender, feeTo, fees);
                amount = amount.sub(fees);
            }else if(sender != pairAddress) {
                fees = amount.mul(transFees).div(feePercent);
                super._transfer(sender, feeTo, fees);
                amount = amount.sub(fees);
            }
        }

        super._transfer(sender, recipient, amount);
    }
}