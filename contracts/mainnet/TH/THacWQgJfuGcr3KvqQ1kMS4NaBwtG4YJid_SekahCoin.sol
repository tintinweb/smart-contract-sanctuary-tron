//SourceUnit: SekahToken.sol

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode
        return msg.data;
    }
}

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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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

/**
 * TRC20 standard interface.
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

/**
 * @dev Interface for the optional metadata functions from the TRC20 standard.
 */
interface ITRC20Metadata is ITRC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

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
        if(a == 0) {
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
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    /**
     * @dev Returns the minimum value among two unsigned integers. (unsigned integer modulo)
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a < b ? a : b;
    }

    /**
     * @dev Returns the maximum value among two unsigned integers. (unsigned integer modulo)
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a > b ? a : b;
    }
}

contract SafeToken is Ownable {
    address payable _safeManager;

    constructor() {
        _safeManager = payable(_msgSender());
    }

    function setSafeManager(address payable account) public onlyOwner {
        _safeManager = account;
    }

    function withdraw(address contractAddress, uint256 amount) external {
        require(contractAddress != address(this), "SafeToken: call withdrawSKH instead");
        require(_msgSender() == _safeManager, "SafeToken: caller is not the manager");
        ITRC20(contractAddress).transfer(_safeManager, amount);
    }

    function withdrawTRX(uint256 amount) external {
        require(_msgSender() == _safeManager, "SafeToken: caller is not the manager");
        _safeManager.transfer(amount);
    }
}

contract LockToken is Ownable {
    mapping(address => bool) private _blackList;

    modifier open(address account) {
        require(!_blackList[account], "LockToken: caller is blacklisted");
        _;
    }

    function includeToBlackList(address account) external onlyOwner {
        _blackList[account] = true;
    }

    function excludeFromBlackList(address account) external onlyOwner {
        _blackList[account] = false;
    }
}

contract SekahCoin is Ownable, ITRC20, ITRC20Metadata, SafeToken, LockToken {
    using SafeMath for uint256;
    
    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _allowances;
    
    string private _name = "Sekah";
    string private _symbol = "SKH";
    uint8 private _decimals = 6;
    uint256 private _totalSupply = 1000000000 * (10 ** _decimals);
    
    uint256 transferFee = 100;
    uint256 swapFeeForUSDT = 0;
    uint256 swapFeeForSKH = 0;
    uint256 feeDenominator = 10000;
    uint256 swapThreshold = _totalSupply / 20000; // 0.005% of the total supply
    mapping(address => bool) dealerList;
    
    constructor() {
        _balances[address(this)] = _totalSupply;
        
        emit Transfer(address(0), address(this), _totalSupply);
    }
    
    /**
     * @dev Returns the trc20 token owner.
     */
    function getOwner() external view returns (address) {
        return owner();
    }
    
    /**
     * @dev Returns the token name.
     */
    function name() external view override returns (string memory) {
        return _name;
    }
    
    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view override returns (string memory) {
        return _symbol;
    }
    
    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view override returns (uint8) {
        return _decimals;
    }
    
    /**
     * @dev See {TRC20-totalSupply}.
     */
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }
    
    /**
     * @dev See {TRC20-balanceOf}.
     */
    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }
    
    /**
     * @dev See {TRC20-allowance}.
     */
    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }
    
    /**
     * @dev See {TRC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    
    /**
     * @dev See {TRC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    
    /**
     * @dev See {TRC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {TRC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "TRC20: transfer amount exceeds allowance"));
        return true;
    }
    
    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {TRC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(amount));
        return true;
    }
    
    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {TRC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(amount, "TRC20: decreased allowance below zero"));
        return true;
    }
    
    /**
     * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing
     * the total supply.
     *
     * Requirements
     *
     * - `msg.sender` must be the token owner
     */
    function mint(uint256 amount) external onlyOwner returns (bool) {
        _mint(_msgSender(), amount);
        return true;
    }
    
    /**
     * @dev Burns `amount` tokens and assigns them to `msg.sender`, decreasing
     * the total supply.
     *
     * Requirements
     *
     * - `msg.sender` must be the token owner
     */
    function burn(uint256 amount) external onlyOwner returns (bool) {
        _burn(_msgSender(), amount);
        return true;
    }
    
    /**
     * @dev Burns `amount` tokens and assigns them to `from`, decreasing
     * the total supply.
     *
     * Requirements
     *
     * - `from` cannot be the zero address.
     */
    function burnFrom(address from, uint256 amount) external onlyOwner returns (bool) {
        _burnFrom(from, amount);
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
    function _transfer(address sender, address recipient, uint256 amount) internal open(sender) {
        require(sender != address(0), "TRC20: transfer from the zero address");
        require(recipient != address(0), "TRC20: transfer to the zero address");
        require(amount > 0, "TRC20: transfer amount is zero");

        _balances[sender] = _balances[sender].sub(amount, "TRC20: transfer amount exceeds balance");
        uint256 amountReceived = isDealer(recipient) || recipient == address(this) ? amount : takeTransferFee(sender, amount);
        _balances[recipient] = _balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
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
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "TRC20: approve from the zero address");
        require(spender != address(0), "TRC20: approve to the zero address");
        require(amount > 0, "TRC20: approve amount is zero");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
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
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "TRC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "TRC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
    
    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "TRC20: burn amount exceeds allowance"));
        _burn(account, amount);
    }
    
    /**
     * @dev Reduces fee from transfer amount
     * Fee transfers to the smart contract
     *
     */
    function takeTransferFee(address sender, uint256 amount) internal returns (uint256) {
        uint256 feeAmount = amount.mul(transferFee).div(feeDenominator);
        
        _balances[address(this)] = _balances[address(this)].add(feeAmount);
        emit Transfer(sender, address(this), feeAmount);
        
        return amount.sub(feeAmount);
    }
    
    /**
     * @dev Reduces fee from swap amount
     * Fee remains in the smart contract
     *
     */
    function takeSwapFee(uint256 amount, uint256 swapFee) internal view returns (uint256) {
        uint256 feeAmount = amount.mul(swapFee).div(feeDenominator);
        
        return amount.sub(feeAmount);
    }
    
    /**
     * @dev Sets transfer fee percentage value
     *
     */
    function setTransferFee(uint256 _transferFee) external onlyOwner returns (bool) {
        transferFee = _transferFee;
        return true;
    }
    
    /**
     * @dev Sets swap fee percentage value for converting from SKH to USDT
     *
     */
    function setSwapFeeForUSDT(uint256 _swapFee) external onlyOwner returns (bool) {
        swapFeeForUSDT = _swapFee;
        return true;
    }
    
    /**
     * @dev Sets swap fee percentage value for converting from USDT to SKH
     *
     */
    function setSwapFeeForSKH(uint256 _swapFee) external onlyOwner returns (bool) {
        swapFeeForSKH = _swapFee;
        return true;
    }
    
    /**
     * @dev Sets swap amount threshold at once
     *
     */
    function setSwapThreshold(uint256 _swapThreshold) external onlyOwner returns (bool) {
        swapThreshold = _swapThreshold;
        return true;
    }
    
    /**
     * @dev Withdraws SKH to owner
     *
     */
    function withdrawSKH(uint256 amount) external returns (bool) {
        require(amount > 0, "withdraw amount is zero");
        require(_msgSender() == _safeManager, "caller is not safe manager");
        _balances[address(this)] = _balances[address(this)].sub(amount, "withdraw amount exceeds balance");
        _balances[_safeManager] = _balances[_safeManager].add(amount);
        emit Transfer(address(this), _safeManager, amount);
        return true;
    }
    
    /**
     * @dev Checks if an address is dealer or not
     * 
     */
    function isDealer(address account) public view returns (bool) {
        return dealerList[account];
    }
    
    /**
     * @dev Adds an address to the dealer list
     * 
     */
    function includeToDealerList(address account) external onlyOwner returns (bool) {
        dealerList[account] = true;
        return true;
    }
    
    /**
     * @dev Removes an address from the dealer list
     * 
     */
    function excludeFromDealerList(address account) external onlyOwner returns (bool) {
        dealerList[account] = false;
        return true;
    }
    
    /**
     * @dev Moves `amount` tokens to `account` for purchase without transfer fee
     * 
     */
    function purchaseSKH(address account, uint256 amount) external onlyOwner returns (bool) {
        _balances[address(this)] = _balances[address(this)].sub(amount, "purchase amount exceeds pool balance");
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(this), account, amount);
        return true;
    }
    
    /**
     * @dev Implements DEX
     * Swap from SKH to USDT
     * Swap from USDT to SKH
     * Swap from SKH to TRX
     * 
     */
    address private swapAddress;
    bool public canSwapForUSDT;
    bool public canSwapForSKH;
    
    function setSwapAddress(address contractAddress) external onlyOwner returns (bool) {
        swapAddress = contractAddress;
        return true;
    }
    
    function enableSwapToUSDT() external onlyOwner returns (bool) {
        canSwapForUSDT = true;
        return true;
    }
    
    function disableSwapToUSDT() external onlyOwner returns (bool) {
        canSwapForUSDT = false;
        return true;
    }
    
    function enableSwapToSKH() external onlyOwner returns (bool) {
        canSwapForSKH = true;
        return true;
    }
    
    function disableSwapToSKH() external onlyOwner returns (bool) {
        canSwapForSKH = false;
        return true;
    }
    
    function swapToUSDT(uint256 amount) external open(_msgSender()) returns (bool) {
        require(canSwapForUSDT, "swap is disabled");
        require(amount <= swapThreshold, "swap amount exceeds threshold");
        
        uint256 remainedAmount = ITRC20(swapAddress).balanceOf(address(this));
        uint256 receivedAmount = takeSwapFee(amount, swapFeeForUSDT);
        require(receivedAmount <= remainedAmount, "USDT: swap amount exceeds pool balance");
        ITRC20(swapAddress).transfer(_msgSender(), receivedAmount);
        
        _balances[_msgSender()] = _balances[_msgSender()].sub(amount, "SKH: swap amount exceeds balance");
        _balances[address(this)] = _balances[address(this)].add(amount);
        emit Transfer(_msgSender(), address(this), amount);
        return true;
    }
    
    function swapToSKH(uint256 amount) external open(_msgSender()) returns (bool) {
        require(canSwapForSKH, "swap is disabled");
        require(amount <= swapThreshold, "swap amount exceeds threshold");
        
        uint256 allowAmount = ITRC20(swapAddress).allowance(_msgSender(), address(this));
        require(allowAmount >= amount, "USDT: swap amount exceeds allowance");
        ITRC20(swapAddress).transferFrom(_msgSender(), address(this), amount);
        
        uint256 receivedAmount = takeSwapFee(amount, swapFeeForSKH);
        _balances[_msgSender()] = _balances[_msgSender()].add(receivedAmount);
        _balances[address(this)] = _balances[address(this)].sub(receivedAmount, "SKH: swap amount exceeds pool balance");
        emit Transfer(address(this), _msgSender(), receivedAmount);
        return true;
    }
    
    uint256 public priceTRX;
    bool public canSwapForTRX;
    uint256 public swapThresholdForTRX = _totalSupply / 20000; // 0.05% of total supply
    
    function enableSwapToTRX() external onlyOwner returns (bool) {
        canSwapForTRX = true;
        return true;
    }
    
    function disableSwapToTRX() external onlyOwner returns (bool) {
        canSwapForTRX = false;
        return true;
    }
    
    function setPriceTRX(uint256 value) external onlyOwner returns (bool) {
        priceTRX = value;
        return true;
    }
    
    function setSwapThresholdForTRX(uint256 value) external onlyOwner returns (bool) {
        swapThresholdForTRX = value;
        return true;
    }
    
    function swapToTRX(uint256 amount) external open(_msgSender()) returns (bool) {
        require(canSwapForTRX, "swap is disabled");
        require(amount <= swapThresholdForTRX, "swap amount exceeds threshold");
        require(priceTRX > 0, "TRX price is zero");
        
        _balances[address(this)] = _balances[address(this)].add(amount);
        _balances[_msgSender()] = _balances[_msgSender()].sub(amount, "SKH: swap amount exceeds balance");
        emit Transfer(_msgSender(), address(this), amount);
        
        uint256 receivedTRX = amount.mul(feeDenominator).div(priceTRX);
        (bool sent, ) = payable(_msgSender()).call{value: receivedTRX}("");
        require(sent, "DEX: failed to receive TRX");
        
        return true;
    }
}