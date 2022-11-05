//SourceUnit: Context.sol

pragma solidity >=0.5.0;

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

//SourceUnit: ITRC20.sol

pragma solidity >=0.5.0;

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

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

import "./Context.sol";
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    
    address private _owner;

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    
    /**=====================================================
     * EVENTS
     *======================================================*/

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}

//SourceUnit: POR.sol

pragma solidity >=0.5.0;

import "./SafeMath.sol";

/**
 * @dev Optional functions from the TRC20 standard.
 */
contract POR {

    using SafeMath for uint256;

    uint8 private BASIS_POINT = 4;

    uint256 private BUY_FEES;

    uint256 private SELL_FEES;

    uint256 private LAUNCH_TIME;

    /**
     * @dev Sets the values for `basisPoint`, `buyFees`, `sellFees`, `maxFees` and `minFees`. Out of these five, three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    constructor (uint256 LAUNCHTIME) internal {
        LAUNCH_TIME = LAUNCHTIME;
        _calibrateFees();
    }

    /*************************************************************
     *  MODIFIER METHODS
    **************************************************************/

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyIfLaunched() {
        require(now >= LAUNCH_TIME, "ProofOfReserve: Launchpad in progress. Complete contract not yet Launched!");
        _;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyIfNotLaunched() {
        require(now < LAUNCH_TIME, "ProofOfReserve: Launchpad has ended. Complete contract Launched!");
        _;
    }

    /*************************************************************
     *  READ METHODS
    **************************************************************/

    /**
     * @dev Returns the amount of asset tokens in the contracts reserve.
     */
    function reserve() public view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev Returns the number of basis Points used by the contract as ratio representation.
     * For example, if `basisPoint` equals `3`, a `buyFees` of `25` represents a
     * deposit fee of 2.5% (per cent or percentage) and should
     * be displayed to a user as `2.5%` by the formula (FeePoints * 100/ (10 ** basisPoint)).     
     */
    function basisPoint() public view returns (uint8) {
        return BASIS_POINT;
    }

    /**
     * @dev Returns the buyFees of the contract.
     * For example, if `basisPoint` equals `3`, a `buyFees` of `25` represents a
     * deposit fee of 2.5% (per cent or percentage) and should
     * be displayed to a user as `2.5%` by the formula (buyFees * 100/ (10 ** basisPoint)).
     */
    function buyFees() public view returns (uint256) {
        return BUY_FEES;
    }

    /**
     * @dev Returns the sellFees of the contract.
     * For example, if `basisPoint` equals `3`, a `sellFees` of `25` represents a
     * withdraw fee of 2.5% (per cent or percentage) and should
     * be displayed to a user as `2.5%` by the formula (sellFees * 100/ (10 ** basisPoint)).
     */
    function sellFees() public view returns (uint256) {
        return SELL_FEES;
    }
    
    /*************************************************************
     *  INTERNAL METHODS
    **************************************************************/

    /**
     * @dev Checks the reserve and Updates the fees of the contract.
     */
    function _calibrateFees() internal {
        if (reserve() >= 0 && reserve() < 1 * (10 ** 6)) {
            _updateBuyFees(100);
            _updateSellFees(1000);
        } else if (reserve() >= 1 * (10 ** 6) && reserve() < 10 * (10 ** 6)) {            
            _updateBuyFees(90);
            _updateSellFees(900);
        } else if (reserve() >= 10 * (10 ** 6) && reserve() < 100 * (10 ** 6)) {            
            _updateBuyFees(80);
            _updateSellFees(800);
        } else if (reserve() >= 100 * (10 ** 6) && reserve() < 1000 * (10 ** 6)) {            
            _updateBuyFees(70);
            _updateSellFees(700);
        } else if (reserve() >= 1000 * (10 ** 6) && reserve() < 10_000 * (10 ** 6)) {            
            _updateBuyFees(60);
            _updateSellFees(600);
        } else if (reserve() >= 10_000 * (10 ** 6) && reserve() < 100_000 * (10 ** 6)) {            
            _updateBuyFees(50);
            _updateSellFees(500);
        } else if (reserve() >= 100_000 * (10 ** 6) && reserve() < 1_000_000 * (10 ** 6)) {            
            _updateBuyFees(40);
            _updateSellFees(400);
        } else if (reserve() >= 1_000_000 * (10 ** 6) && reserve() < 10_000_000 * (10 ** 6)) {            
            _updateBuyFees(30);
            _updateSellFees(300);
        } else if (reserve() >= 10_000_000 * (10 ** 6) && reserve() < 100_000_000 * (10 ** 6)) {            
            _updateBuyFees(20);
            _updateSellFees(200);
        } else if (reserve() >= 100_000_000 * (10 ** 6) && reserve() < 1_000_000_000 * (10 ** 6)) {            
            _updateBuyFees(10);
            _updateSellFees(100);
        } else if (reserve() >= 1_000_000_000 * (10 ** 6)) {            
            _updateBuyFees(9);
            _updateSellFees(90);
        }
    }

    /**
     * @dev Updates the `buyFees` of the contract.
     */
    function _updateBuyFees(uint256 FEE_POINTS) internal {
        BUY_FEES = FEE_POINTS;
    }

    /**
     * @dev Updates the `sellFees` of the contract.
     */
    function _updateSellFees(uint256 FEE_POINTS) internal {
        SELL_FEES = FEE_POINTS;
    }
        
    /*************************************************************
     *  EVENT METHODS
    **************************************************************/

    /**
     * @dev Emitted when `value` of reserve-asset (TRX) are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event AssetTransfer(address indexed from, address indexed to, uint256 value);
}

//SourceUnit: SafeMath.sol

pragma solidity >=0.5.0;

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


//SourceUnit: TRC20.sol

pragma solidity >=0.5.0;

import "./ITRC20.sol";
import "./SafeMath.sol";
import "./Ownable.sol";

/**
 * @dev Implementation of the {ITRC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {TRC20Mintable}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
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
contract TRC20 is Ownable, ITRC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _circulatingSupply;
    
    /**
     * @dev Returns the sum of amount of tokens in contract-user's accounts.
     */
    function circulatingSupply() public view returns (uint256) {
        return _circulatingSupply;
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
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
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
        _approve(_msgSender(), spender, value);
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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount));
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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
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
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue));
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

        _circulatingSupply = _circulatingSupply.add(amount);
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

        _circulatingSupply = _circulatingSupply.sub(value);
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
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount));
    }
}


//SourceUnit: TRC20Detailed.sol

pragma solidity >=0.5.0;

import "./ITRC20.sol";

/**
 * @dev Optional functions from the TRC20 standard.
 */
contract TRC20Detailed is ITRC20 {
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
     * eg. BTC is the symbol of Bitcoin.
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
     * {ITRC20-balanceOf} and {ITRC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}



//SourceUnit: TRC20Hodl.sol

pragma solidity >=0.5.0;

import "./SafeMath.sol";
import "./TRC20.sol";

/**
 * @dev Implementation of the {ITRC20Hodl} interface.
 */
contract TRC20Hodl {
    
    using SafeMath for uint256;

    uint256 private CLAIM_PERIOD;

    mapping (address => uint256) private _prevClaim;
    
    uint256 private _hodlSupply;

    /**
     * @dev Sets the values for `claimPeriod`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    constructor (uint256 claim_Period) internal {
        CLAIM_PERIOD = claim_Period;
    }

    /*************************************************************
     *  READ METHODS
    **************************************************************/

    /**
     * @dev Returns the total amount of tokens in hodler pool of the contract.
     */
    function hodlSupply() public view returns (uint256) {
        return _hodlSupply;
    }

    /**
     * @dev Returns the base time period for claim rewards.
     */
    function claimPeriod() public view returns (uint256) {
        return CLAIM_PERIOD;
    }
    
    /**
     * @dev Returns the timestamp of previous call to `claimRewards` of `account`.
     */
    function prevClaimOf(address account) public view returns (uint256) {
        return _prevClaim[account];
    }

    /*************************************************************
     *  WRITE METHODS
    **************************************************************/

    /*************************************************************
     *  INTERNAL METHODS
    **************************************************************/

    /**
     * @dev Updates the timestamp of the previous
     * claim for `account` to `now`.
     */
    function _updatePrevClaimOf(address account) internal {
        require(account != address(0), "ProofOfReserve: account is the zero address.");

        _prevClaim[account] = now;
    }

    /** @dev Creates `amount` tokens to hodl Supply, increasing
     * the hodl supply.
     *
     * Emits a {HodlTransfer} event with `from` set to the zero address and
     * `to` set to the contract address.
     */
    function _mintHodl(uint256 amount) internal {
        _hodlSupply = _hodlSupply.add(amount);
        emit HodlTransfer(address(0), address(this), amount);
    }

    /**
     * @dev Destroys `amount` tokens from hodl Supply, reducing the
     * hodl Supply.
     *
     * Emits a {HodlTransfer} event with `to` set to the zero address and
     * `from` set to the contract address.
     */
    function _burnHodl(uint256 amount) internal {
        _hodlSupply = _hodlSupply.sub(amount);
        emit HodlTransfer(address(this), address(0), amount);
    }
        
    /*************************************************************
     *  EVENT METHODS
    **************************************************************/

    /**
     * @dev Emitted when `value` hodl Supply tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event HodlTransfer(address indexed from, address indexed to, uint256 value);

}

//SourceUnit: Token.sol

// 0.5.1-c8a2
// Enable optimization
pragma solidity >=0.5.0;

import "./TRC20.sol";
import "./TRC20Detailed.sol";
import "./TRC20Hodl.sol";
import "./POR.sol";

/**
 * @title BasicToken
 * @dev Very basic TRC20 Token, without the optional requirements of the TRC20 standards.
 * All tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `TRC20` functions.
 * Note Initial Supply can be set to zero in case where a miniting mechanism is defined
 * in deriving contracts.
 */
contract BasicToken is TRC20 {
    /**
     * @dev Constructor that gives _msgSender() all of existing tokens.
     */
    constructor(uint256 TRC20InitialSupply) public {
        _mint(_msgSender(), TRC20InitialSupply);
    }
}








/**
 * @title StandardToken
 * @dev The Standard TRC20 Token, with the optional requirements of the TRC20 standards.
 */
contract StandardToken is BasicToken, TRC20Detailed {
    /**
     * @dev Constructor that gives _msgSender() all of existing tokens.
     */
    constructor(string memory TRC20DetailedTokenName, string memory TRC20DetailedTokenSymbol, uint8 TRC20DetailedTokenDecimals, uint256 BasicTokenInitialSupply) public TRC20Detailed(TRC20DetailedTokenName, TRC20DetailedTokenSymbol, TRC20DetailedTokenDecimals) BasicToken(BasicTokenInitialSupply * (10 ** uint256(TRC20DetailedTokenDecimals))) {

    }
}








/**
 * @title StandardTokenWithHodl
 * @dev The Standard TRC20 Token, with the hodler's pool.
 */
contract StandardTokenWithHodl is StandardToken, TRC20Hodl {
    /**
     * @dev Constructor that gives _msgSender() all of existing tokens.
     */
    constructor(string memory StandardTokenTokenName, string memory StandardTokenTokenSymbol, uint8 StandardTokenTokenDecimals, uint256 StandardTokenInitialSupply, uint256 TRC20HodlClaimPeriod) public TRC20Hodl(TRC20HodlClaimPeriod) StandardToken(StandardTokenTokenName, StandardTokenTokenSymbol, StandardTokenTokenDecimals, StandardTokenInitialSupply) {
        
    }

    /*************************************************************
     *  READ METHODS
    **************************************************************/

    function totalSupply() public view returns (uint256) {
        return circulatingSupply().add(hodlSupply());
    }

    /*************************************************************
     *  WRITE METHODS
     **************************************************************/

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _claimReward(_msgSender());
        _claimReward(recipient);
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _claimReward(sender);
        _claimReward(recipient);
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), allowance(sender, _msgSender()).sub(amount));
        return true;
    }

    function claimReward() public returns (bool) {
        _claimReward(_msgSender());
        return true;
    }

    function donateReward(uint256 amount) public returns (bool) {
        _burn(_msgSender(), amount);
        _mintHodl(amount);
        return true;
    }

     /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     */
    function burn(uint256 amount) public returns (bool) {
        _claimReward(_msgSender());
        _burn(_msgSender(), amount);
        return true;
    }

    /*************************************************************
     *  INTERNAL METHODS
     **************************************************************/

    function _claimReward(address account) internal {
        require(account != address(0), "ProofOfReserve: account is the zero address.");

        if (prevClaimOf(account) == 0) {
            _updatePrevClaimOf(account);
        } else {
            uint256 duration = now.sub(prevClaimOf(account));
            uint256 reward = duration.mul(balanceOf(account));
            reward = reward.mul(hodlSupply());
            reward = reward.div(claimPeriod());
            reward = reward.div(totalSupply());

            uint256 inflation = reward.div(10000);

            //Reward overflow check.
            if (reward >= hodlSupply()) {
                _burnHodl(hodlSupply());
                _mint(account, hodlSupply().add(inflation));
            } else {
                _burnHodl(reward);
                _mint(account, reward.add(inflation));
            }
            _updatePrevClaimOf(account);
        }
    }
}

/**
 * @title StandardToken
 * @dev Very basic TRC20 Token, with the optional requirements of the TRC20 standards.
 * All tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `TRC20` functions.
 */
contract PORToken is StandardTokenWithHodl, POR {
    /**
     * @dev Constructor that gives _msgSender() all of existing tokens.
     */
    constructor(string memory STWHTokenName, string memory STWHTokenSymbol, uint8 STWHTokenDecimals, uint256 STWHInitialSupply, uint256 STWHClaimPeriod, uint256 PORLaunchTime) public POR(PORLaunchTime) StandardTokenWithHodl(STWHTokenName, STWHTokenSymbol, STWHTokenDecimals, STWHInitialSupply, STWHClaimPeriod) {}

    /*************************************************************
     *  READ METHODS
     **************************************************************/

    /**
     * @dev Returns the current amount of tokens in the contracts reserve.
     */
    function exchangeValue(uint256 TRXamount) public view returns (uint256) {
        return totalSupply().mul(TRXamount).div(reserve());
    }

    /*************************************************************
     *  WRITE METHODS
     **************************************************************/

    function airDropClaim() public onlyIfNotLaunched returns (bool) {
        _claimReward(_msgSender());
        _mint(_msgSender(), 21 * (10 ** 6) * (10 ** uint256(decimals())));
        return true;
    }

    function buy() public payable onlyIfLaunched returns (bool) {
        _claimReward(_msgSender());
        _buy(_msgSender(), msg.value);
        return true;
    }

    function sell(uint256 amount) public onlyIfLaunched returns (bool) {
        _claimReward(_msgSender());
        _sell(_msgSender(), amount);
        return true;
    }

    /*************************************************************
     *  INTERNAL METHODS
     **************************************************************/

    function _buy(address account, uint256 amount) internal {
        require(account != address(0), "ProofOfReserve: account is the zero address.");
        require(amount <= reserve(), "ProofOfReserve: Insufficient TRX Reserve!");

        uint256 INITIAL_ASSET_RESERVE = reserve().sub(amount);
        uint256 INITIAL_TOKEN_SUPPLY = totalSupply();
        uint256 FINAL_ASSET_RESERVE = reserve();
        uint256 FINAL_TOKEN_SUPPLY = INITIAL_TOKEN_SUPPLY.mul(FINAL_ASSET_RESERVE).div(INITIAL_ASSET_RESERVE);
        uint256 WEIGHT_PRICE_VOL = FINAL_TOKEN_SUPPLY.sub(INITIAL_TOKEN_SUPPLY);

        uint256 FEE = WEIGHT_PRICE_VOL.mul(buyFees());
        FEE = FEE.div(1 * (10**uint256(basisPoint())));

        uint256 PROCESSED_VOL = WEIGHT_PRICE_VOL.sub(FEE);

        if(amount.mod(108 * (10 ** 6)) == 0) {
            PROCESSED_VOL = PROCESSED_VOL.mul(101).div(100);
        }

        _mint(account, PROCESSED_VOL);
        if (owner() != address(0)) {
            _claimReward(owner());
            _mint(owner(), FEE.mul(3).div(5));
        }
        _mintHodl(FEE.div(5));
        _calibrateFees();
        emit AssetTransfer(account, address(this), amount);
    }

    function _sell(address account, uint256 amount) internal {
        require(account != address(0), "ProofOfReserve: account is the zero address.");

        uint256 FEE = amount.mul(sellFees());
        FEE = FEE.div(1 * (10**uint256(basisPoint())));

        uint256 PROCESSED_VOL = amount.sub(FEE);

        uint256 INITIAL_ASSET_RESERVE = reserve();
        uint256 INITIAL_TOKEN_SUPPLY = totalSupply();
        uint256 FINAL_TOKEN_SUPPLY = INITIAL_TOKEN_SUPPLY.sub(PROCESSED_VOL);
        uint256 FINAL_ASSET_RESERVE = FINAL_TOKEN_SUPPLY.mul(INITIAL_ASSET_RESERVE).div(INITIAL_TOKEN_SUPPLY);
        uint256 WITHDRAW_AMT = INITIAL_ASSET_RESERVE.sub(FINAL_ASSET_RESERVE);

        uint256 BURN_VOL = FEE.mul(2).div(5);
        BURN_VOL = BURN_VOL.add(PROCESSED_VOL);

        if (owner() != address(0)) {
            _claimReward(owner());
            _transfer(account, owner(), FEE.mul(3).div(5));
        } else {
            BURN_VOL = amount;
        }
        _burn(account, BURN_VOL);
        _mintHodl(FEE.div(5));

        address payable PAY_ACCOUNT = address(uint160(account));
        PAY_ACCOUNT.transfer(WITHDRAW_AMT);
        _calibrateFees();
        emit AssetTransfer(address(this), account, WITHDRAW_AMT);
    }
}

/**
 * @title UpDawg
 * @dev The UpDawg Token, is a proof of reserve token type with the TRC20 standards.
 */
contract UpDawg is PORToken {
    /**
     * @dev Constructor that gives _msgSender() all of existing tokens.
     */
    constructor(string memory TokenName, string memory TokenSymbol, uint8 TokenDecimals, uint256 InitialSupply, uint256 ClaimPeriod, uint256 LaunchTime) public payable PORToken(TokenName, TokenSymbol, TokenDecimals, InitialSupply, ClaimPeriod, LaunchTime) {

    }

}