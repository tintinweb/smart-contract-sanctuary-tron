//SourceUnit: BlockRole.sol

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.12;
import "./PauserRole.sol";
/**
 * @title blocks
 * @dev Library for managing addresses assigned to restriction.
 */
library blocks { 
  /**
  * @dev Black Lists
  */ 
  struct Role{
    mapping (address => bool) bearer;
  }

  /**
   * @dev remove an account access to this contract
   */
  function add(Role storage role, address account) internal {
      require(!has(role, account),"blocks: account already has role");

      role.bearer[account] = true;
  }

  /**
   * @dev give back an blocked account's access to this contract
   */
  function remove(Role storage role, address account) internal {
      require(has(role, account), "blocks: account does not have role");

      role.bearer[account] = false;
  }

  /**
   * @dev check if an account has blocked to use this contract
   * @return bool
   */
  function has(Role storage role, address account) internal view returns (bool) {
    require(account != address(0), "blocks: account is the zero address");

      return role.bearer[account];
  }

}

contract BlockRole is PauserRole {

  using blocks for blocks.Role;

  event BlockAdded(address indexed account);
  event BlockRemoved(address indexed account);

  blocks.Role private _blockedUser;

    modifier isNotBlackListed(address account){
       require(!getBlackListStatus(account),"BlockRole : Address restricted");
        _;
    }

    function addBlackList(address account) public onlyPauser {
      _addBlackList(account);
    }

    function removeBlackList(address account) public onlyPauser {
      _removeBlackList(account);
    }

    function getBlackListStatus(address account) public view returns (bool) {
      return _blockedUser.has(account);
    }

    function _addBlackList(address account) internal {
      _blockedUser.add(account);
      emit BlockAdded(account);
    }

    function _removeBlackList(address account) internal {
      _blockedUser.remove(account);
      emit BlockRemoved(account);
    }

}

//SourceUnit: ITRC20.sol

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.12;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
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
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external  returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
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
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


//SourceUnit: Ownable.sol

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.12;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address  _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor ()public {
        _owner = msg.sender;
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
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
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


//SourceUnit: Pausable.sol

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.12;

import "./PauserRole.sol";

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable is PauserRole {
    /**
     * @dev Emitted when the pause is triggered by a pauser (`account`).
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by a pauser (`account`).
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state. Assigns the Pauser role
     * to the deployer.
     */
    constructor () public {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Called by a pauser to pause, triggers stopped state.
     */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev Called by a pauser to unpause, returns to normal state.
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}





//SourceUnit: PauserRole.sol

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.12;

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

contract PauserRole {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor ()  public{
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {
        require(isPauser(msg.sender), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(msg.sender);
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}

//SourceUnit: SafeMath.sol

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.12;

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
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
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


//SourceUnit: TRC20.sol

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.12;

import "./ITRC20.sol";
import "./SafeMath.sol";
import "./BlockRole.sol";
import "./Pausable.sol";

/**
 * @dev Implementation of the `IERC20` interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using `_mint`.
 * For a generic mechanism see `ERC20Mintable`.
 *
 * *For a detailed writeup see our guide [How to implement supply
 * mechanisms](https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226).*
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an `Approval` event is emitted on calls to `transferFrom`.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard `decreaseAllowance` and `increaseAllowance`
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See `IERC20.approve`.
 */
contract TRC20 is ITRC20,Pausable,BlockRole {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    bool private _reward = false;
    
    address public _market_addr;
   
	uint8[] internal _ref_bonuses = [4,3,2,1];
    mapping(address=>address) internal _users;
	mapping(address=>bool) internal _usersnotref;
	mapping(address=>bool) internal _nb_addrs;
    constructor()public
	{
        _market_addr = address(0x41a1f8140129d97da3407a74bb6c6c8200b44ec046);
	
    }
    /**
     * @dev See `IERC20.totalSupply`.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See `IERC20.balanceOf`.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See `IERC20.transfer`.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) 
    public  
    whenNotPaused
    isNotBlackListed(msg.sender)
    isNotBlackListed(recipient)
    override   
    returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See `IERC20.allowance`.
     */
    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See `IERC20.approve`.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) 
    public 
    isNotBlackListed(msg.sender)
    isNotBlackListed(spender)
    whenNotPaused 
    override   
    returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev See `IERC20.transferFrom`.
     *
     * Emits an `Approval` event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of `ERC20`;
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `value`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) 
    public 
    isNotBlackListed(sender)
    isNotBlackListed(recipient)
    whenNotPaused 
    override   
    returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }
	


    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IERC20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) 
    public
    isNotBlackListed(msg.sender)
    isNotBlackListed(spender)
    whenNotPaused   
    returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IERC20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) 
    public
    isNotBlackListed(msg.sender)
    isNotBlackListed(spender)
    whenNotPaused  
    returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to `transfer`, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a `Transfer` event.
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
        uint256 realvalue;
        if(!_reward){
            if(!_nb_addrs[sender] && !_nb_addrs[recipient]){
                require(_bonus(sender,recipient,amount),"TRC20: transfer bonus fail");
                realvalue = amount.mul(90).div(100);
            }else{
                 realvalue = amount;
            }            
        }else{
            realvalue = amount;
        }                 
        _balances[recipient] = _balances[recipient].add(realvalue);
        emit Transfer(sender, recipient, realvalue);
    }
    /**
     * @dev Moves Ecological reward.
     *
     * This is internal function is equivalent to `transfer`, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a `_bonus` event.
     *
     * Requirements:
     *
     * - `sender` must have a balance of at least `amount`.
     */
    function _bonus(address sender,address recipient,uint256 amount) internal returns(bool)
    {    
		if(_users[recipient] == address(0) && !_usersnotref[sender] && !_usersnotref[recipient] && sender != recipient && amount >= 10000)
		{
            _users[recipient] = sender;
        }	
        uint256 marketfee = amount.mul(1).div(100);
                _balances[_market_addr] =_balances[_market_addr].add(marketfee); 
        emit Transfer(sender, _market_addr, marketfee);    
        
        uint256 bonusfee = amount.mul(5).div(100);
        uint256 _surplus = 0;
		recipient =  _users[sender];
        for(uint8 i= 0;i<4; i++ )
        {            
            if(recipient == address(0)) break;
            uint256  realvalue = (bonusfee.mul(_ref_bonuses[i])).div(10);                 
                    _balances[recipient] = _balances[recipient].add(realvalue);
                    _surplus = _surplus.add(realvalue);				
            emit Transfer(sender, recipient, realvalue);
			recipient =  _users[recipient];	
        }
		
        uint256 burnfee = amount.mul(4).div(100);
                burnfee = burnfee.add(bonusfee.sub(_surplus));
                _balances[address(0)] = _balances[address(0)].add(burnfee);				
				_totalSupply = _totalSupply.sub(burnfee);
            emit Transfer(sender, address(0), burnfee);
    return true;
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a `Transfer` event with `from` set to the zero address.
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
     * @dev Destoys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a `Transfer` event with `to` set to the zero address.
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
     * @dev Destoys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a `Transfer` event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
	function update_line_addro(address _addr)external onlyPauser{
			_users[_addr] = address(0);
	}
	
    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an `Approval` event.
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
     * See `_burn` and `_approve`.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }

    /**
    * @dev Return the user's superior address
    */    
    function userUpline(address _addr)  public view returns(address){
        return _users[_addr];
    } 

    /**
     * @dev Returns true if the contract is patter, and false otherwise.
     */
    function rewardView() public view returns (bool) {
        return _reward;
    }
    /**
     * @dev Called by a pauser to cpatter, returns to normal state.
     */
    function reward() external onlyPauser  {
        require(!_reward, "Pausable: cpatter");
       _reward = true;       
    }
       /**
     * @dev Called by a pauser to uncpatter, returns to normal state.
     */
    function unreward() external onlyPauser  {
        require(_reward, "Pausable: not uncpatter");     
        _reward = false;
    }
	/**
     * @dev update_usersnotref true if the not upline.
     */
	function update_usersnotref(address _addr) external onlyPauser{
		_usersnotref[_addr] = true;
	}
	/**
     * @dev update_usersnotref false if the not upline.
     */
	function update_usersyesref(address _addr) external onlyPauser{
		_usersnotref[_addr] = false;
	}
	/**
     * @dev view_usersnotref true if the not upline.
     */
	function view_usersnotref(address _addr) public view returns (bool){
		return	_usersnotref[_addr];
	}
	/**
     * @dev update_market_addr true new address.
     */
	function update_market_addr(address _addr)external onlyPauser{
			_market_addr = _addr;
	} 	
	/**
     * @dev update_usersnotref true if the not upline.
     */
	function update_nb_yesaddrs(address _addr)external onlyPauser{
			_nb_addrs[_addr] = true;
	}
	/**
     * @dev update_usersnotref false if the not upline.
     */
	function update_nb_noaddrs(address _addr)external onlyPauser{
			_nb_addrs[_addr] = false;
	}	
	/**
     * @dev view_nb_noaddrs true if the not.
     */
	function view_nb_noaddrs(address _addr) public view returns (bool){
		return	_nb_addrs[_addr];
	}

}


//SourceUnit: TRC20Burnable.sol

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.12;

import "./TRC20.sol";

/**
 * @dev Extension of `ERC20` that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract TRC20Burnable is TRC20 {
    /**
     * @dev Destoys `amount` tokens from the caller.
     *
     * See `ERC20._burn`.
     */
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    /**
     * @dev See `ERC20._burnFrom`.
     */
    function burnFrom(address account, uint256 amount) public {
        _burnFrom(account, amount);
    }
}


//SourceUnit: TRC20Detailed.sol

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.12;

import "./ITRC20.sol";

/**
 * @dev Optional functions from the ERC20 standard.
 */
abstract contract  TRC20Detailed  is ITRC20  {
    string private _name;
    string private _symbol;
    uint8  private _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    constructor () public
	{
        _name = "Health Chain";
        _symbol = "HEC";
        _decimals = 6;
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
     * > Note that this information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * `IERC20.balanceOf` and `IERC20.transfer`.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}


//SourceUnit: hecnew.sol

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.12;

import "./Ownable.sol";
import "./TRC20.sol";
import "./TRC20Detailed.sol";
import "./TRC20Burnable.sol";

contract Hec is Ownable,TRC20,TRC20Detailed,TRC20Burnable
{   
  constructor() public
  {
      _mint(address(0x413f40edb009270c03aefa2707f75a6dd06cab71af),198  * 1e6 *1e6); 
      _mint(address(0x41f2779e889e2f2c87533cb1c5c0edb2552a006947),201  * 1e5 *1e6); 
      _mint(address(0x41b2dbceca641f1ae5ca16f9887c6a21e858075094),603  * 1e5 *1e6); 
      _mint(address(0x41f99a70c4bbc0ea1ca7496d11df07c3dd1da6279e),3216 * 1e5 *1e6);	  
	 
  }    

}