//SourceUnit: basetoken.sol

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.5;

interface IBEP20 {

  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address _owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Context {

  constructor () internal { }

  function _msgSender() internal view returns (address payable) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; 
    return msg.data;
  }
}

library SafeMath {

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

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

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

contract Ownable is Context {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor () internal {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}


interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint256
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair);

    function allPairs(uint256) external view returns (address pair);

    function allPairsLength() external view returns (uint256);

    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

interface RewardContract{
  function NewData(address _rootAddr, address _userAddr) external;
  function RewardProfit(uint256 _token, uint _price) external;
}

contract BEP20Token is  Context, IBEP20, Ownable {
  using SafeMath for uint256;

  string constant public Version = "BASETOKEN V1.0.0";

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowances;

  uint256 private _totalSupply;
  uint8 public _decimals;
  string public _symbol;
  string public _name;

  uint private _lastblocknum;
  uint private perblocknum = 28800; //BSC per 3 seconds 1 block. 28800*3 = 86400s (1day)
  uint private basenum;
  bool private initialized;
  bool public createData;  

  IUniswapV2Router02 public uniswapV2Router;
  address private priceToken;
  address private rewardcontract;

  mapping (address => bool) private _isExcludedFromFees;
  mapping (address => bool) private _isNeedFees;
  address public deadWallet = 0x000000000000000000000000000000000000dEaD;   //T9yD14Nj9j7xAB4dbGeiX9h8upfCg3PBbY,41000000000000000000000000000000000000dEaD
  address public marketingWallet;
  uint256 public marketingFee;
  uint256 public deadFee;

  event ExcludeFromFees(address indexed account, bool isExcluded);

  constructor() public {
    initialize();
  }

  modifier isinitialized() {
        require(!initialized, "Contract instance has already been initialized");
        _;
    }

  function initialize() public isinitialized {
    _name = "CV";
    _symbol = "CV";
    _decimals = 18;
    _totalSupply = 13000000 * 10 **18;
    _balances[msg.sender] = _totalSupply;
    initialized = true;
    emit Transfer(address(0), msg.sender, _totalSupply);
    address msgSender = _msgSender();
    _transferOwnership(msgSender);
    emit OwnershipTransferred(address(0), msgSender);
  }
/*********************************owner function ************************************/
  function initReward(address _reward, address _priceToken, uint _perBlockNum, uint _baseNum, bool _createData) public onlyOwner returns (bool) {
    require(_lastblocknum == 0,"only init form _lastBlockNum=0"); 
    require(_perBlockNum > 0,"_perBlockNum Must non-zero");    
    rewardcontract = _reward;
    priceToken = _priceToken;
    perblocknum = _perBlockNum;
    basenum = _baseNum;
    _lastblocknum = block.number;
    if(createData != _createData) createData = _createData;
    return true;
  }

  function setReward(address _reward, address _priceToken, bool _createData) public onlyOwner returns (bool) {    
    rewardcontract = _reward;
    priceToken = _priceToken;
    if(createData != _createData) createData = _createData;
    return true;
  }

  function setRewardBase(uint _perBlockNum, uint _baseNum) public onlyOwner returns (bool) { 
    require(_perBlockNum > 0,"_perBlockNum Must non-zero");   
    perblocknum = _perBlockNum;
    basenum = _baseNum;
    return true;
  }

  function setSwapV2Router(address _uniswapV2RouterAddr ) public onlyOwner returns (bool) {    
    uniswapV2Router = IUniswapV2Router02(_uniswapV2RouterAddr);
    return true;
  }

  function openswap(address _uniswapV2RouterAddr, address _token) public onlyOwner returns (address) {    
    return IUniswapV2Factory(IUniswapV2Router02(_uniswapV2RouterAddr).factory())
            .createPair(address(this), _token);
  }

  function excludeFromFees(address account, bool excluded) public onlyOwner {
    if(_isExcludedFromFees[account] != excluded){
        _isExcludedFromFees[account] = excluded;
        emit ExcludeFromFees(account, excluded);
      }
  }

  function setMarketingWallet(address payable wallet) external onlyOwner{
    marketingWallet = wallet;
  }

  function setDeadWallet(address addr) public onlyOwner {
    deadWallet = addr;
  }

  function setNeedFees(address account, bool excluded) public onlyOwner {
    if(_isNeedFees[account] != excluded){
      _isNeedFees[account] = excluded;
    }
  }

  function setFees(uint256 _marketingFee, uint256 _deadFee) public onlyOwner {
    require((_marketingFee + _deadFee) < 1000,"Too Big");
    marketingFee = _marketingFee;
    deadFee = _deadFee;
  }

  function mint(uint256 amount) public onlyOwner returns (bool) {
    _mint(_msgSender(), amount);
    return true;
  }
/*************************view function ******************************************/
  function getOwner() external view override returns (address) {
    return owner();
  }

  function decimals() external view override returns (uint8) {
    return _decimals;
  }

  function symbol() external view override returns (string memory) {
    return _symbol;
  }

  function name() external view override returns (string memory) {
    return _name;
  }

  function totalSupply() external view override returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address account) external view override returns (uint256) {
    return _balances[account];
  }

  function getRewardInfo() public view returns (address _rewardAddr, address _priceToken,uint _perBlockNum, uint _baseNum, uint _lastBlockNum, bool _createData) {
    return (rewardcontract, priceToken, perblocknum, basenum, _lastblocknum, createData);
  }
/***********************************external function ***********************************/
  function transfer(address recipient, uint256 amount) external override returns (bool) {
    _transfer(_msgSender(), recipient, amount);
    if (isCanReward()){
        _lastblocknum = _lastblocknum.add(perblocknum);
        _mint(rewardcontract, basenum);
        uint256 price = getPrice();
        RewardContract(rewardcontract).RewardProfit(basenum, price);
    }
    return true;
  }

  function allowance(address owner, address spender) external view override returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) external override returns (bool) {
    _approve(_msgSender(), spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "BEP20: transfer amount exceeds allowance"));
    return true;
  }
/***********************************public function *********************************************/
  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "BEP20: decreased allowance below zero"));
    return true;
  }

  function burn(uint256 amount) public returns (bool) {
    _burn(_msgSender(), amount);
    return true;
  }

  function rewardBase() public returns (bool) {
    if (isCanReward()){
        _lastblocknum = _lastblocknum.add(perblocknum);
        _mint(rewardcontract, basenum);
        uint256 price = getPrice();
        RewardContract(rewardcontract).RewardProfit(basenum, price);
    }
    return true;
  }
/*************************************internal functiion ********************************/
  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "BEP20: transfer from the zero address");
    require(recipient != address(0), "BEP20: transfer to the zero address");

    if (!_isExcludedFromFees[sender] &&
    !_isExcludedFromFees[recipient] &&
    (_isNeedFees[sender] || _isNeedFees[recipient])){
      uint256 Mfee = amount.mul(marketingFee).div(1000);
      uint256 Dfee = amount.mul(deadFee).div(1000);
      if (Mfee > 0){
        _standardtransfer(sender, marketingWallet, Mfee);
        amount = amount.sub(Mfee);
      }
      if (Dfee > 0){
        _standardtransfer(sender, deadWallet, Dfee);
        amount = amount.sub(Dfee);
      }
    }

    _standardtransfer(sender, recipient, amount);

    if (createData && rewardcontract != address(0) && !Address.isContract(sender) && !Address.isContract(recipient) ){
      RewardContract(rewardcontract).NewData(sender, recipient);
    }
  }

  function _standardtransfer(address sender, address recipient, uint256 amount) internal {
    _balances[sender] = _balances[sender].sub(amount, "BEP20: transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(amount);
    emit Transfer(sender, recipient, amount);
  }

  function _mint(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: mint to the zero address");

    _totalSupply = _totalSupply.add(amount);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount);
  }

  function _burn(address account, uint256 amount) internal {
    require(account != address(0), "BEP20: burn from the zero address");

    _balances[account] = _balances[account].sub(amount, "BEP20: burn amount exceeds balance");
    _totalSupply = _totalSupply.sub(amount);
    emit Transfer(account, address(0), amount);
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "BEP20: approve from the zero address");
    require(spender != address(0), "BEP20: approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }

  function _burnFrom(address account, uint256 amount) internal {
    _burn(account, amount);
    _approve(account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "BEP20: burn amount exceeds allowance"));
  }

  function getPrice() internal view returns (uint) {
        address[] memory path = new address[](2);
        path[1] = priceToken; path[0] = address(this);
        uint[] memory _price = uniswapV2Router.getAmountsOut(1e18, path);
        return _price[1];
  }

  function isCanReward() internal view returns (bool) {
        return !(_lastblocknum == 0 || rewardcontract == address(0) || block.number < _lastblocknum.add(perblocknum) || basenum == 0);
  }
}