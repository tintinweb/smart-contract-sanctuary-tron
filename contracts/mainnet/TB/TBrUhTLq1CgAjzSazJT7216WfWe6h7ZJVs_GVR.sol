//SourceUnit: gvr.sol

pragma solidity 0.6.12;

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

contract Ownable {
    address public owner;

    constructor () public{
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}

contract GVR is IERC20, Ownable {

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;
    address public pair;
    uint256 public burnRate =3;

    constructor() public {
        uint256 total = 10000000000*10**6;
        _balances[msg.sender] = total;
        _totalSupply = total;
        emit Transfer(address(0), msg.sender, total);
    }

    function symbol() external pure returns (string memory) {
        return "GVR";
    }

    function name() external pure returns (string memory) {
        return "GVR Token";
    }

    function decimals() external pure returns (uint8) {
        return 6;
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply - _balances[address(0)];
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, msg.sender, currentAllowance - amount);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;

        uint256 receiveAmount = amount;
        uint256 burnAmount = 0;
        if (sender == pair || recipient==pair) {
            burnAmount = amount*burnRate/100;
            receiveAmount = amount - burnAmount;
            _totalSupply -= burnAmount;
            emit Transfer(sender, address(0), burnAmount);
        }

        _balances[recipient] += receiveAmount;
        emit Transfer(sender, recipient, receiveAmount);
    }

    function setPair(address _pair) external onlyOwner {
        pair = _pair;
    }

    function setRate(uint256 r) external onlyOwner {
        burnRate = r;
    }
}