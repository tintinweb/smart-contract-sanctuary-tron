//SourceUnit: BBB.sol

pragma solidity ^0.5.9;

library SafeMath {
  function add(uint a, uint b) internal pure returns(uint c) {
    c = a + b;
    require(c >= a);
  }
  function sub(uint a, uint b) internal pure returns(uint c) {
    require(b <= a);
    c = a - b;
  }
  function mul(uint a, uint b) internal pure returns(uint c) {
    c = a * b;
    require(a == 0 || c / a == b);
  }
  function div(uint a, uint b) internal pure returns(uint c) {
    require(b > 0);
    c = a / b;
  }
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

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
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


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BBB is IERC20, Ownable {
    using SafeMath for uint256;
    string public _name;
    string public _symbol;
    uint8 public _decimals;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;

    address private FUNDER;
    address public DESTROY;
    address public GH;
    address public JJ;
    address public CZ;
    address public LP;

    bool private flag;
    
    constructor(address fn,address ds,address gh,address jj,address cz,address lp) public {
        _symbol = "BBB";
        _name = "BBB";
        _decimals = 8;
        _totalSupply = 210000000*1e8;

        FUNDER = fn;
        DESTROY = ds;
        GH = gh;
        JJ = jj;
        CZ = cz;
        LP = lp;

        _balances[FUNDER] = _totalSupply;
        flag = false;
        emit Transfer(address(0), FUNDER, _totalSupply);
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

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }


    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
    
    function _transfer(address _from, address _to, uint256 _value) internal {
        require(_from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");
        if(flag){
            require(isContract(_from) && isContract(_to), "swap closed");
        }

        _balances[_from] = _balances[_from].sub(_value);
        if(_from == FUNDER || _to == FUNDER || isContract(_to)){
            _balances[_to] = _balances[_to].add(_value);
            emit Transfer(_from, _to, _value);
        }else{
            
            uint256 destroy = _value.mul(2).div(100);
            _balances[DESTROY] = _balances[DESTROY].add(destroy); 

            uint256 gh = _value.mul(2).div(100);
            _balances[GH] = _balances[GH].add(gh);

            uint256 jj = _value.mul(2).div(100);
            _balances[JJ] = _balances[JJ].add(jj);
           
            uint256 cz = _value.mul(2).div(100);
            _balances[CZ] = _balances[CZ].add(cz);    

            uint256 lp = _value.mul(2).div(100);
            _balances[LP] = _balances[LP].add(lp);

            uint256 realValue = _value.mul(90).div(100);
            _balances[_to] = _balances[_to].add(realValue);

            emit Transfer(_from, _to, realValue);
            emit Transfer(_from, DESTROY, destroy);
            emit Transfer(_from, GH, gh);
            emit Transfer(_from, JJ, jj);
            emit Transfer(_from, CZ, cz);
            emit Transfer(_from, LP, lp);
           
        }
    }

    function setFlag() public onlyOwner {
        flag = !flag;
    }
    
     function getFlag() public view onlyOwner returns(bool) {
        return flag;
    }
    
}