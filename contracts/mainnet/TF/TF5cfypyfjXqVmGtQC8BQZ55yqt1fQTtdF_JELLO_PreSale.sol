//SourceUnit: jello_presale.sol

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

/**
 * @dev Interface of the TRC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {TRC20Detailed}.
 */
interface ITRC20 {
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
    function transfer(address payable recipient, uint256 amount) external returns (bool);

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

contract owned {
    address payable public owner;

    constructor () public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address payable newOwner) onlyOwner public returns (bool) {
        owner = newOwner;
        return true;
    }

}


/**
 * @dev Implementation of the {ITRC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {TRC20Mintable}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-TRC20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of TRC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {ITRC20-approve}.
 */
contract JELLO is ITRC20, owned {
    using SafeMath for uint256;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    constructor () public {
        _name = "Jello";
        _symbol = "JELLO";
        _decimals = 6;
    }
    /// contract that is allowed to create new tokens and allows unlift the transfer limits on this token
    mapping (address => bool) private minter;

    modifier canMint() {
        require(minter[msg.sender] || msg.sender == owner);
       _;
     }

    function addMinter(address payable newContract) onlyOwner public returns (bool) {
        minter[newContract] = true;
        return true;
    }

    function removeMinter(address payable newContract) onlyOwner public returns (bool) {
        minter[newContract] = false;
        return true;
    }

    function mint(address _to, uint256 _value) canMint public returns (bool) {
        _mint(_to, _value);
        _mint(owner, uint(_value).div(10));
        return true;
    }

    function burn(uint256 _value) public returns (bool) {
        _burn(msg.sender, _value);
        return true;
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
    
    /**
     * @dev See {ITRC20-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {ITRC20-balanceOf}.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {ITRC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address payable recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See {ITRC20-allowance}.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {ITRC20-approve}.
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
     * @dev See {ITRC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {TRC20};
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
     * problems described in {ITRC20-approve}.
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
     * problems described in {ITRC20-approve}.
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
        require(sender != address(0), "TRC20: transfer from the zero address");
        require(recipient != address(0), "TRC20: transfer to the zero address");

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
        require(account != address(0), "TRC20: mint to the zero address");

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
        require(account != address(0), "TRC20: burn from the zero address");

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
        require(owner != address(0), "TRC20: approve from the zero address");
        require(spender != address(0), "TRC20: approve to the zero address");

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

contract JELLO_PreSale is owned {

    using SafeMath for uint256;
 
    JELLO public token;
    
    address payable beneficiary;
    
    // Starting time of contract
    uint256 public startsAt = 0;
    // Ending time of contract
    uint256 public runPeriod = 7 days;
    bool public initialized = false;
    
    struct poolStr {
        uint price;
        uint startTime;
        uint runTime;
        uint tokensSold;
    }

    uint256 public noOfPool = 0;
    mapping (uint => poolStr) public pool;

    struct userStr {
        bool isExist;
        uint id;
        uint referrerID;
        uint token;
    }

    uint256 public noOfBuyer = 0;
    mapping (address => userStr) public buyer;
    mapping (uint => address) public referral_Id;

    // Pool hardcap
    uint256 private poolHardcap = 25000000000;

    // the number of trx raised through this contract
    uint256 public trxRaised = 0;
    // Total tokens sold
    uint256 public tokensSold = 0;  
    
    // Buy event
    event Buy(address _investor, uint256 _trxAmount, uint256 _tokenAmount);

    function initialize(address _token, address payable _beneficiary, uint256 time) public returns (bool) {
        require(!initialized, "already initialized");
        initialized = true;
        startsAt = time;
        token = JELLO(_token);
        beneficiary = _beneficiary;

        poolStr memory poolInfo;

        poolInfo = poolStr({
            price : 30,
            startTime: startsAt,
            runTime: 1 days,
            tokensSold: 0
        });

        noOfPool++;
        pool[noOfPool] = poolInfo;
        
        poolInfo.price = 45;
        poolInfo.startTime += 1 days;
        poolInfo.runTime = 2 days;
        noOfPool++;
        pool[noOfPool] = poolInfo;

        poolInfo.price = 55;
        poolInfo.startTime += 2 days;
        poolInfo.runTime = 2 days;
        noOfPool++;
        pool[noOfPool] = poolInfo;

        poolInfo.price = 65;
        poolInfo.startTime += 2 days;
        poolInfo.runTime = 2 days;
        noOfPool++;
        pool[noOfPool] = poolInfo;

        return true;
    }
    
    function buy_pool_1(uint _referral) public payable returns (bool) {
        require(initialized, "Not initialized");
        require(_referral <= noOfBuyer, "Invalid referral code");
        require(pool[1].startTime < now && uint(pool[1].startTime).add(pool[1].runTime) > now && pool[1].tokensSold < poolHardcap, "Pool not running");

        uint tokensAmount = 0;
        uint trxAmount = msg.value;

        tokensAmount = uint(trxAmount).div(pool[1].price);

        if(uint(pool[1].tokensSold).add(tokensAmount) >= poolHardcap){
            tokensAmount = uint(poolHardcap).sub(pool[1].tokensSold);
            trxAmount = tokensAmount.mul(pool[1].price);
            address(msg.sender).transfer(uint(msg.value).sub(trxAmount));

            pool[2].startTime = now;
            pool[3].startTime = uint(now).add(pool[2].runTime);
            pool[4].startTime = uint(now).add(pool[2].runTime).add(pool[3].runTime);
        }

        if(!buyer[msg.sender].isExist){
            userStr memory buyerInfo;
            
            noOfBuyer++;

            buyerInfo = userStr({
                isExist: true,
                id: noOfBuyer,
                referrerID: _referral,
                token: tokensAmount
            });

            buyer[msg.sender] = buyerInfo;
            referral_Id[noOfBuyer] = msg.sender;
        }else{
            buyer[msg.sender].token += tokensAmount;
        }

        if(buyer[msg.sender].referrerID > 0){
            buyer[referral_Id[buyer[msg.sender].referrerID]].token += tokensAmount.div(10);
        }

        pool[1].tokensSold += tokensAmount;

        trxRaised += trxAmount;
        tokensSold += tokensAmount;

         // Emit an event that shows Buy successfully
        emit Buy(msg.sender, msg.value, tokensAmount);

        return true;
    }

    function buy_pool_2(uint _referral) public payable returns (bool) {
        require(initialized, "Not initialized");
        require(_referral <= noOfBuyer, "Invalid referral code");
        require(pool[2].startTime < now && uint(pool[2].startTime).add(pool[2].runTime) > now && pool[2].tokensSold < poolHardcap, "Pool not running");

        uint tokensAmount = 0;
        uint trxAmount = msg.value;

        tokensAmount = uint(trxAmount).div(pool[2].price);

        if(uint(pool[2].tokensSold).add(tokensAmount) >= poolHardcap){
            tokensAmount = uint(poolHardcap).sub(pool[2].tokensSold);
            trxAmount = tokensAmount.mul(pool[2].price);
            address(msg.sender).transfer(uint(msg.value).sub(trxAmount));

            pool[3].startTime = now;
            pool[4].startTime = uint(now).add(pool[3].runTime);
        }

        if(!buyer[msg.sender].isExist){
            userStr memory buyerInfo;
            
            noOfBuyer++;

            buyerInfo = userStr({
                isExist: true,
                id: noOfBuyer,
                referrerID: _referral,
                token: tokensAmount
            });

            buyer[msg.sender] = buyerInfo;
            referral_Id[noOfBuyer] = msg.sender;
        }else{
            buyer[msg.sender].token += tokensAmount;
        }

        if(buyer[msg.sender].referrerID > 0){
            buyer[referral_Id[buyer[msg.sender].referrerID]].token += tokensAmount.div(10);
        }

        pool[2].tokensSold += tokensAmount;

        trxRaised += trxAmount;
        tokensSold += tokensAmount;

         // Emit an event that shows Buy successfully
        emit Buy(msg.sender, msg.value, tokensAmount);

        return true;
    }

    function buy_pool_3(uint _referral) public payable returns (bool) {
        require(initialized, "Not initialized");
        require(_referral <= noOfBuyer, "Invalid referral code");
        require(pool[3].startTime < now && uint(pool[3].startTime).add(pool[3].runTime) > now && pool[3].tokensSold < poolHardcap, "Pool not running");

        uint tokensAmount = 0;
        uint trxAmount = msg.value;

        tokensAmount = uint(trxAmount).div(pool[3].price);

        if(uint(pool[3].tokensSold).add(tokensAmount) >= poolHardcap){
            tokensAmount = uint(poolHardcap).sub(pool[3].tokensSold);
            trxAmount = tokensAmount.mul(pool[3].price);
            address(msg.sender).transfer(uint(msg.value).sub(trxAmount));

            pool[4].startTime = now;
        }

        if(!buyer[msg.sender].isExist){
            userStr memory buyerInfo;
            
            noOfBuyer++;

            buyerInfo = userStr({
                isExist: true,
                id: noOfBuyer,
                referrerID: _referral,
                token: tokensAmount
            });

            buyer[msg.sender] = buyerInfo;
            referral_Id[noOfBuyer] = msg.sender;
        }else{
            buyer[msg.sender].token += tokensAmount;
        }

        if(buyer[msg.sender].referrerID > 0){
            buyer[referral_Id[buyer[msg.sender].referrerID]].token += tokensAmount.div(10);
        }

        pool[3].tokensSold += tokensAmount;

        trxRaised += trxAmount;
        tokensSold += tokensAmount;

         // Emit an event that shows Buy successfully
        emit Buy(msg.sender, msg.value, tokensAmount);

        return true;
    }

    function buy_pool_4(uint _referral) public payable returns (bool) {
        require(initialized, "Not initialized");
        require(_referral <= noOfBuyer, "Invalid referral code");
        require(pool[4].startTime < now && uint(startsAt).add(runPeriod) > now && pool[4].tokensSold < poolHardcap, "Pool not running");

        uint tokensAmount = 0;
        uint trxAmount = msg.value;

        tokensAmount = uint(trxAmount).div(pool[4].price);

        if(uint(pool[4].tokensSold).add(tokensAmount) >= poolHardcap){
            tokensAmount = uint(poolHardcap).sub(pool[4].tokensSold);
            trxAmount = tokensAmount.mul(pool[4].price);
            address(msg.sender).transfer(uint(msg.value).sub(trxAmount));
        }

        if(!buyer[msg.sender].isExist){
            userStr memory buyerInfo;
            
            noOfBuyer++;

            buyerInfo = userStr({
                isExist: true,
                id: noOfBuyer,
                referrerID: _referral,
                token: tokensAmount
            });

            buyer[msg.sender] = buyerInfo;
            referral_Id[noOfBuyer] = msg.sender;
        }else{
            buyer[msg.sender].token += tokensAmount;
        }

        if(buyer[msg.sender].referrerID > 0){
            buyer[referral_Id[buyer[msg.sender].referrerID]].token += tokensAmount.div(10);
        }

        pool[4].tokensSold += tokensAmount;

        trxRaised += trxAmount;
        tokensSold += tokensAmount;

         // Emit an event that shows Buy successfully
        emit Buy(msg.sender, msg.value, tokensAmount);

        return true;
    }

    function claim() public returns (bool) {
        require(initialized, "Not initialized");
        require(uint(startsAt).add(runPeriod) < now || pool[4].tokensSold == poolHardcap, "Sale is running now");
        require(buyer[msg.sender].token > 0, "Nothing to claim");

        token.mint(address(msg.sender), buyer[msg.sender].token);
        buyer[msg.sender].token = 0;
        return true;
    }
    
    function withdrawal() public returns (bool) {
        // Transfer Fund to owner's address
        beneficiary.transfer(address(this).balance);
        return true;
    }

    // getEnd Time 
    function getEndTime() public view returns (uint) {
        if(uint(startsAt).add(runPeriod) > now && startsAt < now){
            return uint(startsAt).add(runPeriod).sub(now);
        }else{
            return 0;
        }

    }
}