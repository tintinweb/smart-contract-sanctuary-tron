//SourceUnit: Token.sol

pragma solidity ^0.6.0;

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
 * @title SimpleToken
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `ERC20` functions.
 */
contract Token is ITRC20 {
    using SafeMath for uint256;

    string private _name;
    string private _symbol;
    uint8 private _decimals;
    
    address public owner;
    
    uint256 public _burnRatio = 20;//
    
    uint256 public _mintRatio = 14;//

    uint256 public _nodeRatio = 6;//

    uint256 public _asiaRatio = 4;//

    uint256 public _communityRatio = 2;//

    uint256 public _projectRatio = 1;//

    address private burnAddress = address(0);//

    address private mintAddress;//

    address private nodeAddress;//

    address private asiaAddress;//

    address private communityAddress;//

    address private projectAddress;//

    uint256 private burnMax = 8888 * 10 **0 * 10 ** 8; //
    
    uint256 private burnAmount;//

    mapping (address => uint256) private _balances;
    
    
    mapping (address => bool) private _turnIn;//
    
    mapping (address => bool) private _turnOut;//
    
    uint256 private turnInNum;
    
    uint256 private turnOutNum;
    
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    uint256 private _MaxtotalSupply = 8888 * 10 **0 * 10 ** 8;//
    
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);


    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor () public{
        
        _name = "SAI TOKEN";
        _symbol = "SAI";
        _decimals = 8;
        owner = msg.sender;
        _mint(msg.sender,8888 * 10 ** 0 * 10 ** 8);
        
    }
    
    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
    
    function setOwner(address _owner) public {
        require(msg.sender == owner);
        emit OwnerChanged(owner, _owner);
        owner = _owner;
    }
    
    function setBurnRatio(uint256 burnRatio) public onlyOwner {
        _burnRatio = burnRatio;
    }
    
    function setMintRatio(uint256 mintRatio) public onlyOwner {
        _mintRatio = mintRatio;
    }
    
    function setNodeRatio(uint256 nodeRatio) public onlyOwner {
        _nodeRatio = nodeRatio;
    }
    
    function setAsiaRatio(uint256 asiaRatio) public onlyOwner {
        _asiaRatio = asiaRatio;
    }
    
    function setCommunityRatio(uint256 communityRatio) public onlyOwner {
        _communityRatio = communityRatio;
    }
    
    
    function setProjectRatio(uint256 projectRatio) public onlyOwner {
        _projectRatio = projectRatio;
    }
    
    function setBurnAddress(address account) public onlyOwner {
        burnAddress = account;
    }
    
    function setMintAddress(address account) public onlyOwner {
        mintAddress = account;
    }
    
    function setNodeAddress(address account) public onlyOwner {
        nodeAddress = account;
    }
    
    function setAsiaAddress(address account) public onlyOwner {
        asiaAddress = account;
    }
    
    function setCommunityAddress(address account) public onlyOwner {
        communityAddress = account;
    }

    function setProjectAddress(address account) public onlyOwner {
        projectAddress = account;
    }
    
    function setTurnIn(address account,bool isEnable) public onlyOwner {
        if(isEnable && !_turnIn[account] && turnInNum < 4){
            turnInNum++;
            _turnIn[account] = true;
        }
        
        if(!isEnable && _turnIn[account]){
            turnInNum--;
            _turnIn[account] = false;
        }
    }
    
    
    function setTurnOut(address account,bool isEnable) public onlyOwner {
        if(isEnable && !_turnOut[account] && turnOutNum < 4){
            turnOutNum++;
            _turnOut[account] = true;
        }
        
        if(!isEnable && _turnOut[account]){
            turnOutNum--;
            _turnOut[account] = false;
        }
    }
    
    function mint(address recipient,uint256 amount) public onlyOwner {
        _mint(recipient,amount);
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
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() override public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) override public view returns (uint256) {
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
    function transfer(address recipient, uint256 amount) override public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        if(_totalSupply.add(amount) >= _MaxtotalSupply){
            amount = _MaxtotalSupply.sub(_totalSupply);
        }
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
    
    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) override public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) override public returns (bool) {
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
    function transferFrom(address sender, address recipient, uint256 amount) override public returns (bool) {
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
        
        
         _balances[sender] = _balances[sender].sub(amount);
        
        if( !_turnOut[sender] && !_turnIn[recipient]){
            
            uint256 feeAmount = 0;
            
            feeAmount += _takeBurnRateTransfer(sender, burnAddress, amount, _burnRatio);
            
            feeAmount += _takeRateTransfer(sender, mintAddress, amount, _mintRatio);
            
            feeAmount += _takeRateTransfer(sender, nodeAddress, amount, _nodeRatio);
            
            feeAmount += _takeRateTransfer(sender, asiaAddress, amount, _asiaRatio);
            
            feeAmount += _takeRateTransfer(sender, communityAddress, amount, _communityRatio);
            
            feeAmount += _takeRateTransfer(sender, projectAddress, amount, _projectRatio);
            
            amount = amount.sub(feeAmount);
        }
        
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    
    
    function _takeRateTransfer(
        address sender,
        address to,
        uint256 amount,
        uint256 rate
    ) private returns (uint256){
        uint256 rateAmount = amount.mul(rate).div(200);
        _balances[to] = _balances[to].add(rateAmount);
        emit Transfer(sender, to, rateAmount);
        
        return rateAmount;
    }
    
    
    function _takeBurnRateTransfer(
        address sender,
        address to,
        uint256 amount,
        uint256 rate
    ) private returns (uint256){
        if(burnAmount >= burnMax){
            return 0;
        }
        uint256 rateAmount = amount.mul(rate).div(200);
        if(burnAmount.add(rateAmount) >= burnMax){
            rateAmount = burnMax.sub(burnAmount);
        }
        _balances[to] = _balances[to].add(rateAmount);
        burnAmount = burnAmount.add(rateAmount);
        emit Transfer(sender, to, rateAmount);
        
        return rateAmount;
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
}