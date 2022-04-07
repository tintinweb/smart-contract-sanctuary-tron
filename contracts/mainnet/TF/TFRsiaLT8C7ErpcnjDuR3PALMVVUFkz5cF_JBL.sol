//SourceUnit: JBL.sol

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

contract JBL is IERC20, Ownable {

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;
    uint256 public minRefNum = 1;
    mapping (address => address) public uplines;
    mapping (uint256 => uint256) public refRewardRate;
    mapping (address => bool) public exclude;
    uint256 public stopBurnAmount = 6300*10**18;
    address public pair;
    address public fund;
    
    constructor(address first, address _fund) public {
        refRewardRate[1] = 3;
        refRewardRate[2] = 1;
        fund = _fund;
        uint256 total = 663000*10**18;
        _balances[first] = total;
        _totalSupply = total;
        emit Transfer(address(0), first, total);
        exclude[first] = true;
    }

    function symbol() external pure returns (string memory) {
        return "JBL";
    }

    function name() external pure returns (string memory) {
        return "JBL Token";
    }

    function decimals() external pure returns (uint8) {
        return 18;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
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
        if(uplines[recipient]==address(0) && amount >= minRefNum && sender != recipient && !exclude[recipient]) {
            uplines[recipient] = sender;
        }
        address pair_ = pair;
        if(sender != pair_ && recipient != pair_){
            _balances[recipient] += amount;
            emit Transfer(sender, recipient, amount);
            return;
        }
        uint256 poolAmount = amount/20;
        _balances[pair_] += poolAmount;
        emit Transfer(sender, pair_, poolAmount);
        uint256 fundAmount = amount*3/100;
        _balances[fund] += fundAmount;
        emit Transfer(sender, fund, fundAmount);
        uint256 receiveAmount = amount - poolAmount - fundAmount - amount*7/100;
        uint256 burnRate = 3;
        if(recipient == pair_){
            burnRate += _refPayout(sender, sender, amount);
        }else{
            burnRate += _refPayout(sender, recipient, amount);
        }
        if(totalSupply() > stopBurnAmount) {
            uint256 delta = _totalSupply - stopBurnAmount;
            uint256 burnAmount = amount*burnRate/100;
            uint256 burnReal;
            if (delta > burnAmount){
                _totalSupply -= burnAmount;
                burnReal = burnAmount; 
            }else{
                _totalSupply = stopBurnAmount;
                burnReal = delta;
            }
            emit Transfer(sender, address(0), burnReal);
            receiveAmount += burnAmount - burnReal;
        }else{
            receiveAmount += amount*burnRate/100;
        }
        _balances[recipient] += receiveAmount;
        emit Transfer(sender, recipient, receiveAmount);
    }

    function _refPayout(address sender, address addr, uint256 amount) private returns(uint256){
        address up = uplines[addr];
        uint256 totalRate = 0;
        amount = amount/100;
        for(uint8 i = 1; i < 3; i++) {
            if(up == address(0)) break;
            totalRate += refRewardRate[i];
            uint256 reward = amount*refRewardRate[i];
            _balances[up] += reward;
            emit Transfer(sender, up, reward);
            up = uplines[up];
        }
        return 4 - totalRate;
    }

    function setPair(address _pair) external onlyOwner {
        pair = _pair;
    }
    
    function setMinRefNum(uint256 newMinRefNum) external onlyOwner {
        minRefNum = newMinRefNum;
    }
}