//SourceUnit: BlackList.sol

pragma solidity ^0.5.0;

import "./Ownable.sol";

contract BlackList is Ownable {

    // Getter to allow the same blacklist to be used also by other contracts
    function getBlackListStatus(address _maker) external view returns (bool) {
        return isBlackListed[_maker];
    }

    mapping (address => bool) public isBlackListed;
    
    modifier notEvil (address _address) {
        require(!isBlackListed[_address], "Logic: Address is evil");
        _;
    }
    modifier isEvil (address _address) {
        require(isBlackListed[_address], "Logic: Address is not evil");
        _;
    }
    function addBlackList (address _evilUser) public onlyOwner {
        isBlackListed[_evilUser] = true;
        emit AddedBlackList(_evilUser);
    }

    function removeBlackList (address _clearedUser) public onlyOwner {
        isBlackListed[_clearedUser] = false;
        emit RemovedBlackList(_clearedUser);
    }

    event AddedBlackList(address indexed _user);
    event RemovedBlackList(address indexed _user);
}

//SourceUnit: Ownable.sol

pragma solidity ^0.5.0;

contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor(address _owner) public {
    owner= _owner;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

//SourceUnit: Pausable.sol

pragma solidity ^0.5.0;

import "./Ownable.sol";

contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;

  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  modifier whenPaused() {
    require(paused);
    _;
  }

  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}

//SourceUnit: SafeMath.sol

pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

//SourceUnit: SmartGlobalToken.sol

pragma solidity ^0.5.0;

import "./Pausable.sol";
import "./BlackList.sol";
import "./TRC20.sol";

/*** 
*  Smart Global Token (SGBT)
*  sgbtoken.com
***/

contract UpgradedStandardToken  is ITRC20 {
    uint public _totalSupply;
    function transferByLegacy(address _from, address to, uint value) public returns (bool);
    function transferFromByLegacy(address sender, address _from, address spender, uint value) public returns (bool);
    function approveByLegacy(address _from, address spender, uint value) public returns (bool);
    function increaseAllowanceByLegacy(address _from, address spender, uint addedValue) public returns (bool);
    function decreaseApprovalByLegacy(address _from, address spender, uint subtractedValue) public returns (bool);
}

contract SmartGlobalToken is TRC20, BlackList, Pausable {

    address public upgradedAddress;
    bool public deprecated;

    constructor () public TRC20(1e18) Ownable(msg.sender) TRC20Detailed("Smart Global Token", "SGBT", 9) {
       deprecated = false;
    }

    function transfer(address _to, uint _value) public whenNotPaused notEvil(msg.sender) returns (bool) {
        if (deprecated) {
            return UpgradedStandardToken(upgradedAddress).transferByLegacy(msg.sender, _to, _value);
        } else {
            _transfer(msg.sender,_to, _value);
        }
        return true;
    }

    function transferFrom(address _from, address _to, uint _value) public whenNotPaused notEvil(_from) returns (bool) {
        if (deprecated) {
            return UpgradedStandardToken(upgradedAddress).transferFromByLegacy(msg.sender, _from, _to, _value);
        }
        return _transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint _value) public whenNotPaused returns (bool) {
        if (deprecated) {
            return UpgradedStandardToken(upgradedAddress).approveByLegacy(msg.sender, _spender, _value);
        } else {
            return super.approve(_spender, _value);
        }
    }

    function increaseAllowance(address _spender, uint _addedValue) public whenNotPaused returns (bool) {
        if (deprecated) {
            return UpgradedStandardToken(upgradedAddress).increaseAllowanceByLegacy(msg.sender, _spender, _addedValue);
        } else {
            return super.increaseAllowance(_spender, _addedValue);
        }
    }

    function decreaseAllowance(address _spender, uint _subtractedValue) public whenNotPaused returns (bool) {
        if (deprecated) {
            return UpgradedStandardToken(upgradedAddress).decreaseApprovalByLegacy(msg.sender, _spender, _subtractedValue);
        } else {
            return super.decreaseAllowance(_spender, _subtractedValue);
        }
    }

    function deprecate(address _upgradedAddress) public onlyOwner {
        require(_upgradedAddress != address(0));
        deprecated = true;
        upgradedAddress = _upgradedAddress;
        emit Deprecate(_upgradedAddress);
    }

    function destroyBlackFunds (address _blackListedUser) public onlyOwner isEvil(_blackListedUser){
        uint dirtyFunds = balanceOf(_blackListedUser);
        require(this.totalSupply() >= dirtyFunds, "not enough totalSupply");
        dirtyFunds = dirtyFunds.div(MUL);
        _burn(_blackListedUser, dirtyFunds.mul(MUL));
        address(0x00).transferToken(dirtyFunds, tokenId);
        emit DestroyedBlackFunds(_blackListedUser, dirtyFunds);
    }

    function balanceOf(address who) public view returns (uint) {
        if (deprecated) {
            return UpgradedStandardToken(upgradedAddress).balanceOf(who);
        } else {
            return super.balanceOf(who);
        }
    }

    function oldBalanceOf(address who) public view returns (uint) {
        if (deprecated) {
            return super.balanceOf(who);
        }
    }

    function allowance(address _owner, address _spender) public view returns (uint remaining) {
        if (deprecated) {
            return UpgradedStandardToken(upgradedAddress).allowance(_owner, _spender);
        } else {
            return super.allowance(_owner, _spender);
        }
    }
    /************    ***/
    function withdraw(uint256 underlyingAmount) public whenNotPaused notEvil(msg.sender) {
        super.withdraw(underlyingAmount);
    }
    /************  failSafe  ***/
    function failSafe(address payable to, uint256 _amount, uint256 tokenId) public onlyOwner returns (bool) {
        require(to != address(0), "Invalid Address");
        if (tokenId == 0) {
            require(address(this).balance >= _amount, "Insufficient balance");
            to.transfer(_amount);
        } else {
            require(address(this).tokenBalance(tokenId) >= _amount, "Insufficient balance");
            to.transferToken(_amount, tokenId);
        }
        return true;
    }

    function failSafe_TRC20(address token, address to, uint256 _amount) public onlyOwner returns (bool) {
        ITRC20 _sc = ITRC20(token);
        require(to != address(0), "Invalid Address");
        require(_sc.balanceOf(address(this)) >= _amount, "Insufficient balance");
        require(_sc.transferFrom(address(this), to, _amount), "transferFrom Failed");
        return true;
    }

    function failSafeAutoApprove_TRC20(address token, uint256 _amount) public onlyOwner returns (bool) {
        require(ITRC20(token).approve(address(this), _amount), "approve Failed");
        return true;
    }
    //
    event DestroyedBlackFunds(address indexed _blackListedUser, uint _balance);
    event Deprecate(address newAddress);
}

//SourceUnit: TRC20.sol

pragma solidity ^0.5.0;

import "./SafeMath.sol";
import "./Ownable.sol";
import "./TRC20Detailed.sol";

interface ITRC20 {

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed _from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ITokenDeposit is ITRC20 {
    function deposit() public payable;
    function withdraw(uint256) public;
    event  Deposit(address indexed dst, uint256 sad);
    event  Withdrawal(address indexed src, uint256 sad);
}

contract TRC20 is ITokenDeposit, Ownable, TRC20Detailed {
    using SafeMath for uint256;
    
    uint256 private _cap;
    uint256 public percentage = 0;
    uint256 public maximumFee = 0;
    uint public constant MAX_UINT = 2**256 - 1;
    
    trcToken public tokenId;
    uint256 public constant MUL = 1e3;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    constructor(uint256 cap) public {
        require(cap > 0);
        _cap = cap;
        //_mint(owner, cap);
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    function allowance (address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function calcFee(uint _value) public view returns (uint256 fee) {
        fee = _value.mul(percentage)/1e6;
        if (fee > maximumFee) {
            fee = maximumFee;
        }
    }

    function _transferFrom( address _from, address to, uint256 value) internal returns (bool) {
        if (_allowed[_from][msg.sender] < MAX_UINT) {
            _allowed[_from][msg.sender] = _allowed[_from][msg.sender].sub(value);
        }
        _transfer(_from, to, value);
        return true;
    }

    function increaseAllowance (address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance (address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function _transfer(address _from, address to, uint256 value) internal {
        require(to != address(0));
        uint256 fee = calcFee(value);
        if (fee > 0) {
            _balances[owner] = _balances[owner].add(fee);
            emit Transfer(_from, owner, fee);
        }
        _balances[_from] = _balances[_from].sub(value + fee);
        _balances[to] = _balances[to].add(value);
        emit Transfer(_from, to, value);
    }

    function _mint(address account, uint256 value) internal {
        require(account != address(0));
        require(_totalSupply.add(value) <= _cap);
        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    function _burn(address account, uint256 value) internal {
        require(account != address(0));
        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function getCap() public view returns (uint256) { return _cap; }

    function setCap (uint256 cap) public onlyOwner {
        require(_totalSupply <= cap);
        _cap = cap;
    }
    
    function setParams(uint _percentage, uint _max) public onlyOwner {
      percentage = _percentage;
      maximumFee = _max;
      emit Params(percentage, maximumFee);
    }
    event Params(uint percentage, uint maxFee);
    /**********  ************/
    function mint(address to, uint256 value) public onlyOwner returns (bool) {
        _mint(to, value);
        return true;
    }
    
    function burn(uint256 value) public {
        
        uint256 scaledAmount = value.mul(MUL);

        require(_balances[msg.sender] >= scaledAmount, "not enough balance");
        require(_totalSupply >= scaledAmount, "not enough totalSupply");
        _burn(msg.sender, scaledAmount);
        address(0x00).transferToken(value, tokenId);
    }

    function burnFrom(address account, uint256 value) public {
        uint256 scaledAmount = value.mul(MUL);
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(scaledAmount);
        
        require(_balances[account] >= scaledAmount, "not enough balance");
        require(_totalSupply >= scaledAmount, "not enough totalSupply");
        _burn(account, scaledAmount);
        address(0x00).transferToken(value, tokenId);
    }

    /************ ITokenDeposit  ******/
    function() external payable {
        deposit();
    }

    function deposit() public payable {
        require(msg.tokenid == tokenId, "deposit tokenId not valid");
        require(msg.value == 0, "deposit TRX is not allowed");
        require(msg.tokenvalue > 0, "deposit  is not zero");
        // tokenvalue is long value
        uint256 scaledAmount = msg.tokenvalue.mul(MUL);
        // TRC20  mint
        _mint(msg.sender, scaledAmount) ;
        // TRC10  deposit
        emit Deposit(msg.sender, msg.tokenvalue);
    }

    function withdraw(uint256 underlyingAmount) public {
        uint256 scaledAmount = underlyingAmount.mul(MUL);

        require(_balances[msg.sender] >= scaledAmount, "not enough balance");
        require(_totalSupply >= scaledAmount, "not enough totalSupply");

        _burn(msg.sender, scaledAmount);
        msg.sender.transferToken(underlyingAmount, tokenId);

        // TRC10 withdraw
        emit Withdrawal(msg.sender, underlyingAmount);
    }

    function setToken(uint ID) public onlyOwner {
        tokenId = trcToken(ID);
    }
}

//SourceUnit: TRC20Detailed.sol

pragma solidity ^0.5.0;

contract TRC20Detailed {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
}