//SourceUnit: Trc20bridge.sol

pragma solidity 0.5.10;

interface ITRON20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint256);
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
  function _msgSender() internal view returns (address payable) { return msg.sender; }
  function _msgData() internal view returns (bytes memory) { this; return msg.data; }
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
    require(b > 0, errorMessage);
    uint256 c = a / b;
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

  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract TRC20BridgeV1 is Context, Ownable {
  using SafeMath for uint256;

  event Bridge(address indexed _trc20wallet, string _bep20wallet, uint256 _amount, uint256 _blockstamp, uint256 _bridgeid);

  uint256 public bridgeid;
  address public TokenBridge;
  uint256 public TxFeeBridge;
  mapping(string => uint256) public bep20amount;

  constructor() public {}

  function setTokenBridge(address _token,uint256 _txfee) external onlyOwner {
    TokenBridge = _token;
    TxFeeBridge = _txfee;
  }

  function deposit(string calldata _bep20wallet,uint256 _amount) external payable returns (bool) {
    require(TokenBridge != address(0),"Not found bridge token");
    require(msg.value >= TxFeeBridge,"Revert by tx bridge fee");
    ITRON20 token = ITRON20(TokenBridge);
    token.transferFrom(msg.sender,address(this),_amount);
    bridgeid = bridgeid.add(1);
    bep20amount[_bep20wallet] = bep20amount[_bep20wallet].add(_amount);
    emit Bridge(msg.sender,_bep20wallet,_amount,block.timestamp,bridgeid);
    return true;
  }

  function rescue(address tron20,uint256 amount) external onlyOwner {
    ITRON20 token = ITRON20(tron20);
    token.transfer(msg.sender,amount);
  }

  function withdraw(uint256 amount) external onlyOwner {
    address(uint160(msg.sender)).transfer(amount);
  }

  function purge() external onlyOwner {
    address(uint160(msg.sender)).transfer(address(this).balance);
  }

}