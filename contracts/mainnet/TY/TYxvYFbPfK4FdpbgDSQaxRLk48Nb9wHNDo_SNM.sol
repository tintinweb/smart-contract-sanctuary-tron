//SourceUnit: SNM.sol

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

contract SNM is Context, ITRC20, Ownable {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    string private _name = 'SNM';
    string private _symbol = 'SNM';
    uint8 private _decimals = 6;

    uint256 private _totalSupply = 831 * 10**uint256(_decimals);
    uint256 public _maximum = 2 * 10 ** uint256(_decimals);

    address public marketaddress_a;
    address public marketaddress_b;

    mapping(address => bool) private _isExcludedFromFee;


    address public _exchangePool;

    constructor (address _amk, address _bmk) public {
        _isExcludedFromFee[owner()] = true;
        _isExcludedFromFee[address(this)] = true;

        marketaddress_a = _amk;
        marketaddress_b = _bmk;

        _balances[_msgSender()] = _totalSupply;

        emit Transfer(address(0), _msgSender(), _totalSupply);
    }
    
    receive () external payable {}
    
    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }


    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

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

    function safeTRX(address payable reAddress, uint256 value) public {
        require(msg.sender == owner());
        reAddress.transfer(value);
    }

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setMaximum(uint256 maximum) public onlyOwner {
        _maximum = maximum;
    }

    function setExchangePool(address exchangePool) public onlyOwner {
        _exchangePool = exchangePool;
    }

    struct Param{
        bool takeFee;
        uint256 tTransferAmount;
        uint256 tLP;
        uint256 aMk;
        uint256 bMk;
        uint256 tBurn;
    }

    function _sellParam(uint256 tAmount,Param memory param) private pure  {
        param.tLP = tAmount.mul(3).div(100);
        param.aMk = tAmount.mul(1).div(100);
        param.bMk = tAmount.mul(3).div(100);
        param.tBurn = tAmount.mul(5).div(100);
        param.tTransferAmount = tAmount.mul(88).div(100);
    }

    function _buyParam(uint256 tAmount,Param memory param) private pure  {
        param.tLP = tAmount.mul(3).div(100);
        param.tBurn = tAmount.mul(2).div(100);
        param.tTransferAmount = tAmount.mul(95).div(100);
    }

    function _transferParam(uint256 tAmount,Param memory param) private pure  {
        param.tBurn = tAmount.mul(2).div(100);
        param.tTransferAmount = tAmount.mul(98).div(100);
    }

    function _takeFee(Param memory param,address from) private {
        if( param.tLP > 0 ){
            _take(param.tLP, from, _exchangePool);
        }
        if( param.aMk > 0 ){
            _take(param.aMk, from, marketaddress_a);
        }
        if( param.bMk > 0 ){
            _take(param.bMk, from, marketaddress_b);
        }
        if( param.tBurn > 0 ){
            _totalSupply = _totalSupply.sub(param.tBurn);
            _take(param.tBurn, from, address(0));
        }
    }

    function _take(uint256 tValue,address from,address to) private {
        _balances[to] = _balances[to].add(tValue);
        emit Transfer(from, to, tValue);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(amount <= _maximum || _isExcludedFromFee[sender] || _isExcludedFromFee[recipient], "Transfer amount must be greater than zero");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        Param memory param;

        uint256 balance = balanceOf(sender);
        if (amount == balance) {
            amount = amount.sub(1 * 10 ** 3);
        }

        param.tTransferAmount = amount;

        if (!_isExcludedFromFee[sender] && !_isExcludedFromFee[recipient]) {

            param.takeFee = true;

            if (recipient == _exchangePool) {
                _sellParam(amount,param);
            } else if (sender == _exchangePool) {
                _buyParam(amount,param);
            } else {
                _transferParam(amount,param);
            }
        }
        _tokenTransfer(sender,recipient,amount,param);
    }

    function _tokenTransfer(address sender, address recipient, uint256 tAmount,Param memory param) private {
        _balances[sender] = _balances[sender].sub(tAmount);
        _balances[recipient] = _balances[recipient].add(param.tTransferAmount);
        emit Transfer(sender, recipient, param.tTransferAmount);
        if(param.takeFee){
            _takeFee(param,sender);
        }
    }
}