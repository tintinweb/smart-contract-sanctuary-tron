//SourceUnit: opx.sol

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

interface TRC20 {
    
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Burn(address indexed from, uint256 indexed value);
}


contract ONPALEXPRESS is TRC20 {

    string public constant name = "OnPalExpress";
    string public constant symbol = "OPX";
    address private _owner;
    uint8 public constant decimals = 6;
    
    
    mapping(address => uint256) balances;
    
    mapping(address => mapping (address => uint256)) allowed;
    
    uint256 totalSupply_ = 1000000000000000;
    
    
    constructor(address __owner) {
        balances[__owner] = totalSupply_;
        _owner = __owner;
    }
    
    function totalSupply() public override view returns (uint256) {
        return totalSupply_;
    }
    
    function balanceOf(address tokenOwner) public override view returns (uint256) {
        return balances[tokenOwner];
    }
    
    function transfer(address receiver, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender]-numTokens;
        balances[receiver] = balances[receiver]+numTokens;
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }
    
    function approve(address delegate, uint256 numTokens) public override returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }
    
    function allowance(address owner, address delegate) public override view returns (uint) {
        return allowed[owner][delegate];
    }
    
    function transferFrom(address owner, address buyer, uint256 numTokens) public override returns (bool) {
        require(numTokens <= balances[owner]);
        require(numTokens <= allowed[owner][msg.sender]);
        
        balances[owner] = balances[owner]-numTokens;
        allowed[owner][msg.sender] = allowed[owner][msg.sender]-numTokens;
        balances[buyer] = balances[buyer]+numTokens;
        emit Transfer(owner, buyer, numTokens);
        return true;
    }
    
    function mintToken(uint256 numTokens, address receiver) public returns (bool) {
        require(msg.sender == _owner);
        totalSupply_ += numTokens;
        balances[receiver] += numTokens;
        return true;
    }
    
    function burnToken(uint256 numTokens) public returns (bool) {
        require(balances[msg.sender] >= numTokens);
        totalSupply_ -= numTokens;
        balances[msg.sender] -= numTokens;
        emit Burn(msg.sender, numTokens);
        return true;
    }
}