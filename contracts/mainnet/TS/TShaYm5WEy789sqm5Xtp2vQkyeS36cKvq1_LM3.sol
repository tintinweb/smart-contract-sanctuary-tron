//SourceUnit: lm3.sol

// SPDX-License-Identifier: MIT
pragma solidity =0.6.12;
pragma experimental ABIEncoderV2;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
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
        require(_owner == _msgSender(), "e0");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "e0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "e0");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, 'e0');
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "e0");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "e0");
        uint256 c = a / b;
        return c;
    }
}

contract LM3 is Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 public minSupply;
    uint256 public maxSupply;
    uint256 public tradeBurnRatio;
    uint256 public tradeFeeRatio;
    address public team;
    mapping(address => bool) public minerList;
    mapping(address => bool) public whiteList;


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed user, uint256 value);
    event Burn(address indexed user, uint256 value);
    event ChangeTeam(address oldTeam, address newTeam);

    constructor (string memory name, string memory symbol, uint256 _minSupply, uint256 _maxSupply, uint256 _preSupply, uint256 _tradeBurnRatio, uint256 _tradeFeeRatio, address _team) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
        _totalSupply = _preSupply.mul(1e18);
        _balances[_msgSender()] = _preSupply.mul(1e18);
        maxSupply = _maxSupply.mul(1e18);
        minSupply = _minSupply.mul(1e18);
        tradeBurnRatio = _tradeBurnRatio;
        tradeFeeRatio = _tradeFeeRatio;
        team = _team;
        addMiner(msg.sender);
        addWhiteList(msg.sender);
        addWhiteList(_team);
        addWhiteList(address(0));
        addWhiteList(address(1));
        emit Transfer(address(0), _msgSender(), _preSupply.mul(1e18));
    }

    function addMiner(address _address) public onlyOwner {
        minerList[_address] = true;
    }

    function removeMiner(address _address) external onlyOwner {
        minerList[_address] = false;
    }

    function isMiner(address _address) external view returns (bool) {
        return minerList[_address];
    }


    function addWhiteList(address _address) public onlyOwner {
        whiteList[_address] = true;
    }

    function removeWhiteList(address _address) external onlyOwner {
        whiteList[_address] = false;
    }

    function isWhiteList(address _address) external view returns (bool) {
        return whiteList[_address];
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function rSupply() public view returns (uint256) {
        uint256 amount0 = balanceOf(address(0));
        uint256 amount1 = balanceOf(address(1));
        return _totalSupply.sub(amount0).sub(amount1);
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return maxSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "e0");
        require(recipient != address(0), "e1");
        _beforeTokenTransfer(sender, recipient, amount);
        _balances[sender] = _balances[sender].sub(amount);

        bool useFee = true;
        uint256 burnAmount = amount.mul(tradeBurnRatio).div(100);
        if (whiteList[sender] || whiteList[recipient] || rSupply().sub(burnAmount) < minSupply) {
            useFee = false;
            tradeBurnRatio = 0;
            tradeFeeRatio = 0;
        }
        burnAmount = amount.mul(tradeBurnRatio).div(100);
        uint256 feeAmount = amount.mul(tradeFeeRatio).div(100);
        if (tradeBurnRatio > 0 && rSupply().sub(burnAmount) >= minSupply && useFee) {
            _balances[address(1)] = _balances[address(1)].add(burnAmount);
            emit Transfer(sender, address(1), burnAmount);
        }
        if (tradeFeeRatio > 0 && rSupply().sub(burnAmount) >= minSupply && useFee) {
            _balances[team] = _balances[team].add(feeAmount);
            emit Transfer(sender, team, feeAmount);
        }
        uint256 newAmount;
        if (useFee && rSupply().sub(burnAmount) >= minSupply && tradeBurnRatio > 0) {
            newAmount = amount.sub(burnAmount).sub(feeAmount);
        } else {
            newAmount = amount;
        }
        _balances[recipient] = _balances[recipient].add(newAmount);
        emit Transfer(sender, recipient, newAmount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "e0");
        require(spender != address(0), "e1");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function mint(address _to, uint256 _amount) external returns (bool){
        require(minerList[msg.sender], "NOT_OWNER");
        require(_totalSupply.add(_amount) <= maxSupply, "k0");
        _balances[_to] = _balances[_to].add(_amount);
        _totalSupply = _totalSupply.add(_amount);
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {}
}