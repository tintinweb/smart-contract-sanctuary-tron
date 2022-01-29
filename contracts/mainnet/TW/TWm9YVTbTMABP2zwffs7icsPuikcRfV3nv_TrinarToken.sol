//SourceUnit: trinartoken.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c=a+b;
        require(c>=a,"addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b<=a,"subtraction overflow");
        uint256 c=a-b;
        return c;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a==0) return 0;
        uint256 c=a*b;
        require(c/a==b,"multiplication overflow");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b>0,"division by zero");
        uint256 c=a/b;
        return c;
    }
}

contract TRC20 {
    using SafeMath for uint256;
    string public symbol;
    string public name;
    uint8 public decimals;
    uint256 public totalSupply;
    mapping (address=>uint256) balances;
    mapping (address=>mapping (address=>uint256)) allowed;
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function balanceOf(address _owner) public view returns (uint256 balance) {return balances[_owner];}

    function transfer(address _to, uint256 _amount) public returns (bool success) {
        require (balances[msg.sender]>=_amount&&_amount>0);
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(msg.sender,_to,_amount);
        return true;
    }

    function transferFrom(address _from,address _to,uint256 _amount) public returns (bool success) {
        require (balances[_from]>=_amount&&allowed[_from][msg.sender]>=_amount&&_amount>0);
        balances[_from] = balances[_from].sub(_amount);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        balances[_to]  = balances[_to].add(_amount);
        emit Transfer(_from, _to, _amount);
        return true;
    }

    function approve(address _spender, uint256 _amount) public returns (bool success) {
        allowed[msg.sender][_spender]=_amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }
}

contract TrinarToken is TRC20{
    using SafeMath for uint256;
    uint256 public fee;
    uint256 public max;
    address payable owner;
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    event Mint(address indexed _to, uint256 _value);

    constructor() public {
        symbol = "TRT";
        name = "Trinar Token";
        decimals = 6;
        totalSupply = 0;
        fee = 10*10**6;
        max = 1000*10**uint256(decimals);
        owner = msg.sender;
    }

    receive() external payable {
        revert();
    }

    function mint(address _user, uint256 _value) public payable returns(bool){
        require(_user!=address(0)&&_value<=max&&msg.value>=fee);
        balances[_user]+=_value;
        totalSupply+=_value;
        owner.transfer(msg.value);
        emit Mint(_user,_value);
        return true;
    }
}