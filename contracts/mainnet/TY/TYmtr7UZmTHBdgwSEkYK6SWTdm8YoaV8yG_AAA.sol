//SourceUnit: AAA.sol

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

contract AAA is IERC20, Ownable {
    using SafeMath for uint256;
    string public symbol;
    string public name;
    uint8 public decimals;
    uint256 private _totalSupply;
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) public allowed;
    address private FUNDER;
    address private DESTROY;
    address private GH;
    address private JJ;
    address private CZ;
    address private LP;

    address private SWAP;
    bool private flag;
    mapping(address => bool) private whitelist;
    
  
    constructor(address fn,address ds,address gh,address jj,address cz,address lp) public {
        symbol = "AAA";
        name = "AAA";
        decimals = 8;
        _totalSupply = 210000000*1e8;

        FUNDER = fn;
        DESTROY = ds;
        GH = gh;
        JJ = jj;
        CZ = cz;
        LP = lp;

        balances[FUNDER] = _totalSupply;
        flag = false;
        emit Transfer(address(0), FUNDER, _totalSupply);
    }
    
    function totalSupply() public view returns(uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address tokenOwner) public view returns(uint256 balance) {
        return balances[tokenOwner];
    }
    
    function transfer(address _to, uint256 _value) public returns (bool) {
        
        _burnTransfer(msg.sender, _to, _value);
        return true;
    }
    
    function approve(address spender, uint256 tokens) public returns(bool success) 
    {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool success) {
        require(_to != address(0), "address is null");
        require(_value <= balances[_from], "Insufficient balance");
        require(_value <= allowed[_from][msg.sender], "Insufficient allowed.");

        _burnTransfer(msg.sender, _to, _value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        return true;
    }
    
    function allowance(address tokenOwner, address spender) public view returns(uint256 remaining) {
        return allowed[tokenOwner][spender];
    }
    
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        balances[sender] = balances[sender].sub(amount);
        balances[recipient] = balances[recipient].add(amount);
    }
    
    function _burnTransfer(address _from, address _to, uint256 _value) internal {
        require(_from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");
        if(flag){
            require(msg.sender != SWAP && _to != SWAP, "swap closed");
        }

        if(whitelist[_from] || whitelist[_to]){
            _transfer(msg.sender, _to, _value);
        }else{
            balances[_from] = balances[_from].sub(_value);
            uint256 destroy = _value.mul(2).div(100);
            balances[DESTROY] = balances[DESTROY].add(destroy);
            emit Transfer(_from, DESTROY, destroy);

            uint256 gh = _value.mul(2).div(100);
            balances[GH] = balances[GH].add(gh);
            emit Transfer(_from, GH, gh);

            uint256 jj = _value.mul(2).div(100);
            balances[JJ] = balances[JJ].add(jj);
            emit Transfer(_from, JJ, jj);

            uint256 cz = _value.mul(2).div(100);
            balances[CZ] = balances[CZ].add(cz);
            emit Transfer(_from, CZ, cz);

            uint256 lp = _value.mul(2).div(100);
            balances[LP] = balances[LP].add(lp);
            emit Transfer(_from, LP, lp);

            uint256 realValue = _value.mul(90).div(100);
            balances[_to] = balances[_to].add(realValue);
            emit Transfer(_from, _to, realValue);
        }
    }
    
    function setWhitelist(address _addr,uint8 _type) public onlyOwner {
        if(_type == 1){
            require(!whitelist[_addr], "Candidate must not be whitelisted.");
            whitelist[_addr] = true;
        }else{
            require(whitelist[_addr], "Candidate must not be whitelisted.");
            whitelist[_addr] = false;
        }
    }
    
     function getWhitelist(address _addr) public view onlyOwner returns(bool) {
        return whitelist[_addr];
    }

    function setFlag() public onlyOwner {
        flag = !flag;
    }
    
     function getFlag() public view onlyOwner returns(bool) {
        return flag;
    }

    function setSwap(address _addr) public onlyOwner {
       SWAP = _addr;
    }
    
     function getSwap() public view onlyOwner returns(address) {
        return SWAP;
    }
    
}