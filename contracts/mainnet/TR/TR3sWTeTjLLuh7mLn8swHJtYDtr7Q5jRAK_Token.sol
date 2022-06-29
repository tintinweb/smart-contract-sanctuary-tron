//SourceUnit: ERC20.sol

pragma solidity ^0.5.0;

import "./IERC20.sol";
import "./SafeMath.sol";

contract ERC20 is IERC20 {
    using SafeMath for uint256;

    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;

    address public admin = msg.sender;

    mapping (address => address) public _parents;
    address[] public _members;
    
    mapping (address => uint256 ) public _lpAddress;
    mapping (address => uint256 ) public _whiteAddress;
    mapping (address => uint256 ) public _blackAddress;

    uint256 public _fundRate = 4;       // 分红比例
    uint256 public _firstfundRate = 2;       // 分红比例
    uint256 public _secondfundRate = 1;       // 分红比例
    uint256 public _thirdfundRate = 1;       // 分红比例
    uint256 public _blackRate = 2;      // 黑洞销毁
    uint256 public _transRate = 3;      // 交易销毁
    uint256 public _limitTrans = 99;  // 交易最多金额占比

    address public _fundAddress =0x4b3d98e17A33f130C95D30D0241b5dECF6ac4e5E;       // 用于手动添加parent
    address public _lpBounsAddress =0x4b3d98e17A33f130C95D30D0241b5dECF6ac4e5E;       // 分红地址
    address public _blackholeAddress = 0x0000000000000000000000000000000000000000;

    // uint256 public _doorBuy = 0; //买入开关
    // uint256 public _buyLimit = 500; //买入限制
    // address public _usdtAddress =0x4b3d98e17A33f130C95D30D0241b5dECF6ac4e5E;       // 指定地址
    // address private _lpAddress111 =0x4b3d98e17A33f130C95D30D0241b5dECF6ac4e5E;       // 指定地址
    // IERC20 token = IERC20(_usdtAddress); //USDT


    modifier adminer{
        require(msg.sender == admin);
        _;
    }

     function renounceOwnership() public adminer {
        emit OwnershipTransferred(admin, address(0));
        admin = address(0);
    }

    // function chdoorBuy(uint256 doorBuy)public adminer returns(bool){
    //     _doorBuy = doorBuy;
    //     return true;
    // }
    // function chbuyLimit(uint256 buyLimit)public adminer returns(bool){
    //     _buyLimit = buyLimit;
    //     return true;
    // }

    // function chUSDTAddress(address usdtaddress) public adminer returns(bool){
    //     _usdtAddress = usdtaddress;
        
    //     return true;
    // }


    function chFundAddress(address fund) public adminer returns(bool){
        _fundAddress = fund;
        return true;
    }

    function chLPbounsAddress(address lpbounsAddress) public adminer returns(bool){
        _lpBounsAddress = lpbounsAddress;
        return true;
    }

    function chlp(address lpAddress,uint256 _a)public adminer returns(bool){

        _lpAddress[lpAddress] = _a;
        // _lpAddress111 = lpAddress;
        return true;
    }

    function chwhite(address whiteAddress,uint256 _a)public adminer returns(bool){

        _whiteAddress[whiteAddress] = _a;
        return true;
    }

    function chblack(address blackAddress,uint256 _a)public adminer returns(bool){

        _blackAddress[blackAddress] = _a;
        return true;
    }

    function chbili(uint256 fundRate,uint256 firstfundRate, uint256 secondfundRate,uint256 thirdfundRate,uint256 blackRate,uint256 transRate, uint256 limitTrans)public adminer returns(bool){

        _fundRate = fundRate;       // 分红比例
        _firstfundRate = firstfundRate;       // 分红比例
        _secondfundRate = secondfundRate;       // 分红比例
        _thirdfundRate = thirdfundRate;       // 分红比例
        _blackRate = blackRate;      // 黑洞销毁
        _transRate = transRate;      // 交易销毁
        _limitTrans = limitTrans;  // 交易最多金额占比
        return true;
    }

    function addParent(address parent) public returns(bool){
        address p = _parents[msg.sender];
        if(p == _blackholeAddress)
        {
            _parents[msg.sender] = parent;
            _members.push(msg.sender);
            return true;
        }
        else{
            return false;
        }
    }

    function getParent(address child) public view returns(address ){
        return _parents[child];    
    }

    function addParent(address child, address parent) public returns(bool){
        require(msg.sender != _fundAddress, "ERC20: has no rights");
        address p = _parents[child];
        if(p == _blackholeAddress)
        {
            _parents[child] = parent;
            _members.push(child);
            return true;
        }
        else{
            return false;
        }
    }

    function getMembers() public view returns(address[] memory){
        return _members;
    }

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
        require(amount<= _balances[sender]*_limitTrans/100, "ERC20: exceed to max count limit");
        // token = IERC20(usdtaddress);

        if(_whiteAddress[sender]==1 || _whiteAddress[recipient]==1)
        {
            _balances[sender] = _balances[sender].sub(amount);
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount);
        }
        else if(_lpAddress[sender]==1 || _lpAddress[recipient]==1){
            // trade           
            require(_blackAddress[sender]!=1, "ERC20: address is in blacklist"); 
            require(_blackAddress[recipient]!=1, "ERC20: address is in blacklist");           
            if(_lpAddress[sender]==1 )
            {
                // uint256 uamount = token.balanceOf(_lpAddress111);
                // uint256 wamount = _balances[_lpAddress111];  
                // if( _doorBuy == 0)
                // {
                //     require(uamount*(_balances[recipient] + amount )<= _buyLimit * wamount, "ERC20: exceed buy-count limit");
                // }

                // 买入
                _balances[sender] = _balances[sender].sub(amount);
                _balances[_blackholeAddress] = _balances[_blackholeAddress].add(amount * _blackRate / 100); 
                _fundTrans(recipient, amount);
                _balances[recipient] = _balances[recipient].add(amount * (100-_blackRate-_fundRate) / 100);
                _totalSupply = _totalSupply.sub(amount * _blackRate/100) ;

                // emit Transfer(sender, _fundAddress, amount * _fundRate / 100); 
                emit Transfer(sender, _blackholeAddress, amount * _blackRate / 100); 
                emit Transfer(sender, recipient, amount * (100-_fundRate-_blackRate) / 100); 
            }else{
                // 卖出
                _balances[sender] = _balances[sender].sub(amount);
                _balances[recipient] = _balances[recipient].add(amount);
                emit Transfer(sender, recipient, amount);
                // _balances[sender] = _balances[sender].sub(amount);
                // _balances[_blackholeAddress] = _balances[_blackholeAddress].add(amount * _blackRate / 100); 
                // // _fundTrans(sender, amount);
                // _balances[_lpBounsAddress] = _balances[_lpBounsAddress].add(amount * _fundRate / 100); 

                // _balances[recipient] = _balances[recipient].add(amount * (100-_blackRate-_fundRate) / 100);
                // _totalSupply = _totalSupply.sub(amount * _blackRate / 100);

                // emit Transfer(sender, _lpBounsAddress, amount * _fundRate / 100); 
                // emit Transfer(sender, _blackholeAddress, amount * _blackRate / 100); 
                // emit Transfer(sender, recipient, amount * (100-_blackRate-_fundRate) / 100); 
            }
            
        }
        else{
            // trans
            _balances[sender] = _balances[sender].sub(amount);
            _balances[_blackholeAddress] = _balances[_blackholeAddress].add(amount * _transRate / 100);             
            _balances[recipient] = _balances[recipient].add(amount * (100-_transRate) / 100);
            _totalSupply = _totalSupply.sub(amount * _transRate / 100);

            emit Transfer(sender, _blackholeAddress, amount * _transRate / 100); 
            emit Transfer(sender, recipient, amount * (100-_transRate) / 100); 
            
        }
    }

    // 分红
    function _fundTrans(address sender, uint256 amount) internal{
        address par1 = _parents[sender];
        if(par1 == _blackholeAddress)
        {
            _balances[_blackholeAddress] = _balances[_blackholeAddress].add(amount*(_firstfundRate+_secondfundRate+_thirdfundRate)/100);
            _totalSupply = _totalSupply.sub(amount * (_firstfundRate+_secondfundRate+_thirdfundRate)) ;
            emit Transfer(sender, _blackholeAddress, amount*(_firstfundRate+_secondfundRate+_thirdfundRate)/100); 
            return;
        }
        _balances[par1] = _balances[par1].add(amount*_firstfundRate/100);
        emit Transfer(sender, par1, amount*_firstfundRate/100);

        address par2 = _parents[par1];
        if(par2 == _blackholeAddress)
        {
            _balances[_blackholeAddress] = _balances[_blackholeAddress].add(amount*(_secondfundRate+_thirdfundRate)/100);
            _totalSupply = _totalSupply.sub(amount * (_secondfundRate+_thirdfundRate)) ;
            emit Transfer(sender, _blackholeAddress, amount*(_secondfundRate+_thirdfundRate)/100); 
            return;
        }
        _balances[par2] = _balances[par2].add(amount*_secondfundRate/100);
        emit Transfer(sender, par2, amount*_secondfundRate/100);

        address par3 = _parents[par2];
        if(par3 == _blackholeAddress)
        {
            _balances[_blackholeAddress] = _balances[_blackholeAddress].add(amount*(_thirdfundRate)/100);
            _totalSupply = _totalSupply.sub(amount * (_thirdfundRate)) ;
            emit Transfer(sender, _blackholeAddress, amount*(_thirdfundRate)/100); 
            return;
        }
        _balances[par3] = _balances[par3].add(amount*_thirdfundRate/100);
        emit Transfer(sender, par3, amount*_thirdfundRate/100);
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
    // function _burn(address account, uint256 value) internal {
    //     require(account != address(0), "ERC20: burn from the zero address");

    //     _totalSupply = _totalSupply.sub(value);
    //     _balances[account] = _balances[account].sub(value);
    //     emit Transfer(account, address(0), value);
    // }

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
    // function _burnFrom(address account, uint256 amount) internal {
    //     _burn(account, amount);
    //     _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    // }
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


//SourceUnit: Token.sol

pragma solidity ^0.5.0;

import "./ERC20.sol";
import "./ERC20Detailed.sol";


contract Token is ERC20, ERC20Detailed {

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor () public ERC20Detailed("Wealth","Wealth",6) {
       _mint(msg.sender, 99990000 * (10 ** uint256(decimals())));
    }
}