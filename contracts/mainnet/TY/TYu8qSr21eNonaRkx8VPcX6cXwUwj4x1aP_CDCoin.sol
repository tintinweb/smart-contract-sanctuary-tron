//SourceUnit: CDCoin_v1.6.sol

pragma solidity 0.5.4;

library SafeMath {

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;
    return c;
  }
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
    return c;
  }
}

contract Owned {
    address public owner;
  
    function owned() public  {
        owner = msg.sender;
    }
    constructor() payable public {
        owner = msg.sender;
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    address public newOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyNewOwner() { 
      require(msg.sender != address(0)); 
      require(msg.sender == newOwner); 
      _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
      require(_newOwner != address(0)); 
      newOwner = _newOwner;
    }

    function acceptOwnership() public onlyNewOwner {
      owner = newOwner;
      emit OwnershipTransferred(owner, newOwner);
    }
}

contract Pausable is Owned {
  event Pause();
  event Unpause();

  bool public paused = false;

  modifier whenNotPaused() {
    if (paused) revert();
    _;
  }

  modifier whenPaused {
    if (!paused) revert();
    _;
  }

  function pause() onlyOwner public whenNotPaused returns (bool) {
    paused = true;
    emit Pause();
    return true;
  }

  function unpause() onlyOwner public whenPaused returns (bool) {
    paused = false;
    emit Unpause();
    return true;
  }
}

contract BlackList is Owned{

    function getBlackListStatus(address _maker) external view returns (bool) {
        return isBlackListed[_maker];
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    mapping (address => bool) public isBlackListed;
    
    function addBlackList (address _evilUser) public onlyOwner returns (bool success){
        isBlackListed[_evilUser] = true;
        emit AddedBlackList(_evilUser);
        return true;
    }

    function removeBlackList (address _clearedUser) public onlyOwner returns (bool success){
        isBlackListed[_clearedUser] = false;
        emit RemovedBlackList(_clearedUser);
        return true;
    }

    event DestroyedBlackFunds(address _blackListedUser, uint _balance);

    event AddedBlackList(address _user);

    event RemovedBlackList(address _user);

}

contract TRC20Interface {
  uint public totalSupply;
  function balanceOf(address _owner)  external view returns (uint);
  function transfer(address _to, uint256 _value) external payable returns (bool);
  function transferFrom(address _from, address _to, uint256 _value) external payable returns (bool);
  function allowance(address _owner, address _spender) external view returns (uint);
  function approve(address _spender, uint256 _value) external returns (bool);
  function issue(address _to, uint256 _value) external payable  returns (bool);
  function burn(address _to, uint256 _value) external payable returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

}

contract TRC20 is Owned, TRC20Interface, Pausable, BlackList {
  using SafeMath for uint;

  mapping(address => uint256) public balances;
  mapping (address => mapping (address => uint256)) public allowed;

  function allowance(address _owner, address _spender) public view returns (uint remaining) {
    return allowed[_owner][_spender];
  }

  function balanceOf(address _owner) public view returns (uint balance) {
    require(_owner != address(0));
    return balances[_owner];
  }

  function _transfer(address _from, address _to, uint256 _value) internal { 
    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) whenNotPaused public payable returns (bool success) { 
    require(!isBlackListed[_from]);
    require(!isBlackListed[_to]);
    require(_from != address(0)); 
    require(_to != address(0)); 
    require(_value <= balances[_from]); 
    require(_value <= allowed[_from][msg.sender]); 
    _transfer(_from, _to, _value); 
    return true; 
  }

 function transfer(address _to, uint256 _value) whenNotPaused public payable returns (bool) { 
    require(!isBlackListed[msg.sender]);
    require(_to != address(0)); 
    require(_value <= balances[msg.sender]);
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value); 
    return true; 
  }

  function destroyBlackFunds (address _blackListedUser) public onlyOwner payable returns (bool){
    require(isBlackListed[_blackListedUser]);
    uint dirtyFunds = balanceOf(_blackListedUser);
    balances[_blackListedUser] = 0;
    balances[owner] = balances[owner].add(dirtyFunds); 
    emit DestroyedBlackFunds(_blackListedUser, dirtyFunds);
    return true;
  }
  
}


contract TRC20Token is Owned, TRC20 {

  mapping (address => mapping (address => uint)) public allowed;

  function approve(address _spender, uint _value) public returns (bool success){
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function issue(address _to, uint256 _value) public payable onlyOwner returns (bool success) {
    totalSupply = totalSupply.add(_value);
    balances[_to] = balances[_to].add(_value);
    emit Issue(_value);
    return true;
  }

  function burn(address _to, uint256 _value) public payable onlyOwner returns (bool success)  {
    totalSupply = totalSupply.sub(_value);
    balances[_to] = balances[_to].sub(_value);
    emit Burn(_value);
    return true;
  }

  event Issue(uint _value);
  event Burn(uint _value);

}


contract CDCoin is TRC20Token {
    string public constant name = "CDCoin";
    string public constant symbol = "CDCoin";
    uint public constant decimals = 18;

    constructor () public  {
        totalSupply = 10000000 * (10 ** decimals);
        balances[msg.sender] = totalSupply;
	      emit Transfer(address(0x0), msg.sender, totalSupply);
    }
    
    function () external payable {
        revert();
    }
    
}