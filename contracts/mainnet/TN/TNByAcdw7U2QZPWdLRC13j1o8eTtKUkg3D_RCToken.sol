//SourceUnit: RCToken.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint c = a / b;

        return c;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract Context {
    constructor () {}
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
}

contract ERC20 is Context,IERC20 {
    using SafeMath for uint;
    mapping (address => uint) private _balances;
    mapping (address => mapping (address => uint)) private _allowances;

    uint private _totalSupply;
    uint public maxSupply = 81000000 * 1e18;

    function totalSupply() public view override(IERC20) returns(uint){
        return _totalSupply;
    }

    function balanceOf(address account) public view override(IERC20) returns(uint){
        return _balances[account];
    }

    function _transfer(address sender,address recipient,uint amount) internal {
        require(sender != address(0),"ERC20: transfer from the zero address");
        require(recipient != address(0),"ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount,"ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender,recipient,amount);
    }

    function transfer(address recipient,uint256 amount) public override(IERC20) returns(bool){
        _transfer(_msgSender(),recipient,amount);
        return true;
    }

    function allowance(address owner,address spender) public view override(IERC20) returns(uint256){
        return _allowances[owner][spender];
    }

    function _approve(address owner,address spender,uint amount) internal {
        require(owner != address(0),"ERC20: approve from the zero address");
        require(spender != address(0),"ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner,spender,amount);
    }

    function approve(address spender,uint256 amount) public override(IERC20) returns(bool){
        _approve(_msgSender(),spender,amount);
        return true;
    }

    function transferFrom(address sender,address recipient,uint256 amount) public override(IERC20) returns(bool){
        _transfer(sender,recipient,amount);
        _approve(sender,_msgSender(),_allowances[sender][_msgSender()].sub(amount,"ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender,uint addedValue) public returns(bool){
        _approve(_msgSender(),spender,_allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender,uint subtractedValue) public returns(bool){
        _approve(_msgSender(),spender,_allowances[_msgSender()][spender].sub(subtractedValue,"ERC20: decreased allowance below zero"));
        return true;
    }

    function _mint(address account,uint amount) internal {
        require(account != address(0),"ERC20: mint to the zero address");
        require(_totalSupply.add(amount) <= maxSupply, "ERC20: cannot mint over max supply");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0),account,amount);
    }

    function _burn(address account,uint amount) internal {
        require(account != address(0),"ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount,"ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account,address(0),amount);
    }
}

abstract contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory mname,string memory msymbol,uint8 mdecimals) {
        _name = mname;
        _symbol = msymbol;
        _decimals = mdecimals;
    }

    function name() public view returns(string memory) {
        return _name;
    }
    function symbol() public view returns(string memory) {
        return _symbol;
    }
    function decimals() public view returns(uint8) {
        return _decimals;
    }
}

contract Governance is Context{
    using Address for address;
    
    address public governance;
    
    constructor () {
        governance = _msgSender();
    }
    
    modifier onlyGovernance {
        require(_msgSender() == governance,"!governance");
        _;
    }
}

contract RCToken is ERC20,ERC20Detailed,Governance {
    using Address for address;
    using SafeMath for uint;

    mapping (address => bool) public minters;
    uint constant SCALE = 1e18;

    uint public ico = 6170000 * SCALE;
    mapping (string => bool) public icoStatus;
    
    uint public development = 4050000 * SCALE;
    uint public developmentMonths = 0;
    
    uint public community = 2430000 * SCALE;
    
    uint public fund = 64800000 * SCALE;
    mapping (string => bool) public fundStatus;
    
    uint public time = block.timestamp;
    uint public fundTime = time + 360 days;
    uint public developmentTime = time + (360 days * 2);
    
    constructor () ERC20Detailed("RC Token","RC",18){ 
        _mint(msg.sender,3550000 * SCALE);
    }

    function setGovernance(address _governance) onlyGovernance public {
        governance = _governance;
    }

    function controlMinter(address _minter,bool bol) public onlyGovernance {
        minters[_minter] = bol;
    }
    
    function mintIco(address account) public onlyGovernance {
        require(ico > 0,"!ico");
        require(minters[msg.sender],"!minter");
        uint freezeIco = 6170000 * SCALE;
        if (block.timestamp >= time + 90 days){
            require(icoStatus["ninetyDays"] == false,"Ninety days time is invalid");
            ico = ico.sub(freezeIco * 40/100);
            _mint(account,freezeIco * 40/100);
            icoStatus["ninetyDays"] = true;
        }else if (block.timestamp >= time + 60 days){
            require(icoStatus["sixtyDays"] == false,"sixty days time is invalid");
            ico = ico.sub(freezeIco * 30/100);
            _mint(account,freezeIco * 30/100);
            icoStatus["sixtyDays"] = true;
        }else if (block.timestamp >= time + 30 days){
            require(icoStatus["thirtyDays"] == false,"thirty days time is invalid");
            ico = ico.sub(freezeIco * 20/100);
            _mint(account,freezeIco * 20/100);
            icoStatus["thirtyDays"] = true;
        }else {
            require(icoStatus["release"] == false,"release is invalid");
            ico = ico.sub(freezeIco * 10/100);
            _mint(account,freezeIco * 10/100);
            icoStatus["release"] = true;
        }
    }

    function mintDevelopment(address account) public onlyGovernance {
        require(minters[msg.sender],"!minter");
        require(development > 0,"!development");

        require(block.timestamp > time + 360 days * 2,"It's not event two years");

        require(block.timestamp > developmentTime + 30 days,"Development no release time");

        require(developmentMonths < 12,"Development complete release");
        uint freezeDevelopment = 4050000 * SCALE;
        
        development = development.sub(freezeDevelopment / 12);
        _mint(account,freezeDevelopment / 12);
        developmentMonths += 1;
        developmentTime += 30 days; 
    }

    function mintCommunity(address account) public onlyGovernance {
        require(minters[msg.sender],"!minter");
        require(community > 0,"!community");
        _mint(account,community);
        community = community.sub(community);
    }

    function mintFund(address account) public onlyGovernance {
        require(minters[msg.sender],"!minter");
        require(fund > 0,"!fund bonus");
        require(block.timestamp > fundTime,"It's not even one years");
        uint freezeFund = 64800000 * SCALE;
        
        if (block.timestamp > fundTime + 1080 days){
            require(fundStatus["1080days"] == false,"1080 days time is invalid");
            fund = fund.sub(freezeFund * 40/100);
            _mint(account,freezeFund * 40/100);
            fundStatus["1080days"] = true;
        }else if (block.timestamp > fundTime + 720 days) {
            require(fundStatus["720days"] == false,"720 days time is invalid");
            fund = fund.sub(freezeFund * 30/100);
            _mint(account,freezeFund * 30/100);
            fundStatus["720days"] = true;
        }else if (block.timestamp > fundTime + 360 days) {
            require(fundStatus["360days"] == false,"360 days time is invalid");
            fund = fund.sub(freezeFund * 20/100);
            _mint(account,freezeFund * 20/100);
            fundStatus["360days"] = true;
        }else {
            require(fundStatus["release"] == false,"release time is invalid");
            fund = fund.sub(freezeFund * 10/100);
            _mint(account,freezeFund * 10/100);
            fundStatus["release"] = true;
        }
    }
    

}