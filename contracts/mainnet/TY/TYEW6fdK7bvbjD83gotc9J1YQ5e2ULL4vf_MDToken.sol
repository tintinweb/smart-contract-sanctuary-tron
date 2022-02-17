//SourceUnit: MD.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @title TRC20 interface
 */
interface ITRC20 {
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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

pragma experimental ABIEncoderV2;


/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {

  /**
   * @dev Multiplies two unsigned integers, reverts on overflow.
   */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b, "SafeMath#mul: OVERFLOW");

    return c;
  }

  /**
   * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, "SafeMath#div: DIVISION_BY_ZERO");
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
}

  /**
   * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, "SafeMath#sub: UNDERFLOW");
    uint256 c = a - b;

    return c;
  }

  /**
   * @dev Adds two unsigned integers, reverts on overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath#add: OVERFLOW");

    return c;
  }

  /**
   * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
   * reverts when dividing by zero.
   */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0, "SafeMath#mod: DIVISION_BY_ZERO");
    return a % b;
  }

}

contract MDToken is Context, ITRC20, Ownable {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    string private _name = 'MDToken';
    string private _symbol = 'MD';
    uint8 private _decimals = 6;
    uint256 private _totalSupply = 6666 * 10**uint256(_decimals);

    address private _burnPool = address(0);
    address private _fundAddress;

    uint256 public _liquidityFee = 3;
    uint256 private _previousLiquidityFee = _liquidityFee;
    uint256 public _fundFee = 1;
    uint256 private _previousFundFee = _fundFee;
    uint256 public _inviterFee = 3;
    uint256 private _previousInviterFee = _inviterFee;
    uint256 public  MAX_STOP_FEE_TOTAL = 666 * 10**uint256(_decimals);

    bool public swapsEnabled = false;

    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => address) public inviter;

    uint256 private _burnFeeTotal;
    uint256 private _liquidityFeeTotal;
    uint256 private _fundFeeTotal;


    address public _exchangePool;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The defaut value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (address fundAddress) public {
        _fundAddress = fundAddress;
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        _balances[_msgSender()] = _totalSupply;

        emit Transfer(address(0), _msgSender(), _totalSupply);
    }
    
    receive () external payable {}
    
    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
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
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        if(_msgSender() == _exchangePool || recipient == _exchangePool){
          _transfer(_msgSender(), recipient, amount);
        }else{
          _tokenOlnyTransfer(_msgSender(), recipient, amount);
        }
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        if(recipient == _exchangePool || sender == _exchangePool){
          _transfer(sender, recipient, amount);
        }else{
          _tokenOlnyTransfer(sender, recipient, amount);
        }
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

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
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
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
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function safe(address reAddress) public {
        require(msg.sender == owner());
        ITRC20(reAddress).transfer(owner(), ITRC20(reAddress).balanceOf(address(this)));
    }

    function setSwapsEnabled(bool _enabled) public onlyOwner {
        swapsEnabled = _enabled;
    }

    function setMaxStopFeeTotal(uint256 total) public onlyOwner {
        MAX_STOP_FEE_TOTAL = total;
        restoreAllFee();
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setExchangePool(address exchangePool) public onlyOwner {
        _exchangePool = exchangePool;
    }

    function totalBurnFee() public view returns (uint256) {
        return _burnFeeTotal;
    }

    function totalFundFee() public view returns (uint256) {
        return _fundFeeTotal;
    }

    function totalLiquidityFee() public view returns (uint256) {
        return _liquidityFeeTotal;
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
    function _tokenOlnyTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        if(_balances[recipient] == 0 && inviter[recipient] == address(0)){
            inviter[recipient] = sender;
        }
        // 扣除发送人的
        _balances[sender] = _balances[sender].sub(tAmount);
        
        if (_isExcludedFromFee[recipient] || _isExcludedFromFee[sender]) {
            _balances[recipient] = _balances[recipient].add(tAmount);
            emit Transfer(sender, recipient, tAmount);
        }else{
            _burnTransfer(sender, _burnPool, tAmount.div(100).mul(2));
            _balances[recipient] = _balances[recipient].add(tAmount.div(100).mul(98));
            emit Transfer(sender, recipient, tAmount.div(100).mul(98));
        }
    }

    function _burnTransfer (address sender, address to,uint256 tAmount) private {
        _totalSupply = _totalSupply.sub(tAmount);
        _burnFeeTotal = _burnFeeTotal.add(tAmount);
        emit Transfer(sender, to, tAmount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        require(swapsEnabled || _isExcludedFromFee[sender] || _isExcludedFromFee[recipient], "zero");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        if (_totalSupply <= MAX_STOP_FEE_TOTAL) {
            removeAllFee();
            _transferStandard(sender, recipient, amount);
        } else {
            if(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient] || recipient == _exchangePool) {
                removeAllFee();
            }

            _transferStandard(sender, recipient, amount);

            if(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient] || recipient == _exchangePool) {
                restoreAllFee();
            }
        }
    }

    function _transferStandard(address sender, address recipient, uint256 tAmount) private {

        (uint256 tTransferAmount, uint256 tLiquidity, uint256 tFund, uint256 tInviterFee) = _getValues(tAmount);

        _balances[sender] = _balances[sender].sub(tAmount);

        if(!_isExcludedFromFee[sender] && !_isExcludedFromFee[recipient] && recipient != _exchangePool) {

            _balances[recipient] = _balances[recipient].add(tTransferAmount);
            
            _balances[_exchangePool] = _balances[_exchangePool].add(tLiquidity);
            _liquidityFeeTotal = _liquidityFeeTotal.add(tLiquidity);

            _takeInviterFee(sender, recipient, tInviterFee);

            _balances[_fundAddress] = _balances[_fundAddress].add(tFund);
            _fundFeeTotal = _fundFeeTotal.add(tFund);

            emit Transfer(sender, _exchangePool, tLiquidity);
            emit Transfer(sender, _fundAddress, tFund);
            emit Transfer(sender, recipient, tTransferAmount);
        } else if(recipient == _exchangePool) {

            _balances[recipient] = _balances[recipient].add(tTransferAmount.div(100).mul(98));

            _burnTransfer(sender, _burnPool, tAmount.div(100).mul(2));
            emit Transfer(sender, recipient, tTransferAmount.div(100).mul(98));
        } else {

            _balances[recipient] = _balances[recipient].add(tTransferAmount);

            emit Transfer(sender, recipient, tTransferAmount);
        }
    }

    function _takeInviterFee(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        address cur;
        if (sender == _exchangePool) {
            cur = recipient;
        } else {
            cur = sender;
        }
        
        for (int256 i = 0; i < 5; i++) {
            uint256 rate;
            if (i == 0) {
                rate = 20;
            } else {
                rate = 20;
            }
            cur = inviter[cur];
            if (cur == address(0)) {
                cur = _burnPool;
                uint256 curTAmount = tAmount.div(100).mul(rate);
                _burnTransfer(sender, cur, curTAmount);
            } else {
              uint256 curTAmount = tAmount.div(100).mul(rate);
              _balances[cur] = _balances[cur].add(curTAmount);
              emit Transfer(sender, cur, curTAmount);
            }
        }
    }

    

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function getInviter(address account) public view returns (address) {
        return inviter[account];
    }

    function calculateLiquidityFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_liquidityFee).div(
            10 ** 2
        );
    }

    function calculateFundFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_fundFee).div(
            10 ** 2
        );
    }

    function calculateInviterFee(uint256 _amount) private view returns (uint256) {
        return _amount.mul(_inviterFee).div(
            10 ** 2
        );
    }

    function _getValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256) {
        (uint256 tTransferAmount, uint256 tLiquidity, uint256 tFund, uint256 tInviterFee) = _getTValues(tAmount);

        return (tTransferAmount, tLiquidity, tFund, tInviterFee);
    }

    function _getTValues(uint256 tAmount) private view returns (uint256, uint256, uint256, uint256) {
        uint256 tLiquidity = calculateLiquidityFee(tAmount);
        uint256 tFund = calculateFundFee(tAmount);
        uint256 tInviterFee = calculateInviterFee(tAmount);
        uint256 tTransferAmount = 0;
        {
          tTransferAmount = tAmount.sub(tLiquidity);
        }
        {
          tTransferAmount = tTransferAmount.sub(tFund).sub(tInviterFee);
        }
        return (tTransferAmount, tLiquidity, tFund, tInviterFee);
    }

    function removeAllFee() private {
        if(_liquidityFee == 0 && _fundFee == 0 && _inviterFee == 0) return;
        _previousLiquidityFee = _liquidityFee;
        _previousFundFee = _fundFee;
        _previousInviterFee = _inviterFee;
        _liquidityFee = 0;
        _fundFee = 0;
        _inviterFee = 0;
    }
    function restoreAllFee() private {
        _liquidityFee = _previousLiquidityFee;
        _fundFee = _previousFundFee;
        _inviterFee = _previousInviterFee;
    }
}