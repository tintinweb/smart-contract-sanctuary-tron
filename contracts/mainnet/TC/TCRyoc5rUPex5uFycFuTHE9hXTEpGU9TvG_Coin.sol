//SourceUnit: xfsh.sol

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8;

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

contract owned {
    address public owner;
    constructor() {
        owner = msg.sender;
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}


contract Coin is IERC20, owned {
    string public name;
    string public symbol;
    uint8 public decimals = 8;

    uint256  public override totalSupply;

    receive() external payable {}
    mapping(address => bool) public swapAddress;
    mapping(address => bool) public whiteListAddress;
    mapping(address => bool) public blackListAddress;
    uint40 private _burnRate = 25;
    uint40 private _backflowRate = 10;
    uint40 private _rate = 1000;
    address private deadAddress = 0x000000000000000000000000000000000000dEaD;
    address public backflowAddress;
    uint256 private _minTotalSupply;

    event Backflow(uint256 value);

    constructor(
        string memory tokenName,
        string memory tokenSymbol
    ) {
        name = tokenName;
        symbol = tokenSymbol;
        uint256 initialSupply = 10000000;
        totalSupply = initialSupply * 10 ** uint256(decimals);
        _minTotalSupply = totalSupply / 10;
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    mapping(address => uint256)  public override balanceOf;
    mapping(address => mapping(address => uint256))  public override allowance;

    function setSwapAddress(address user, bool status) public onlyOwner {
        swapAddress[user] = status;
    }
    function setWhiteListAddress(address user, bool status) public onlyOwner {
        whiteListAddress[user] = status;
    }
    function setBlackListAddress(address user, bool status) public onlyOwner {
        blackListAddress[user] = status;
    }

    function setBackflowAddress(address user) public onlyOwner {
        backflowAddress = user;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(blackListAddress[sender] == false, "Blacklist cannot be traded");

        if (swapAddress[recipient] && whiteListAddress[sender] == false && totalSupply - balanceOf[deadAddress] >= _minTotalSupply) {
            uint256 burnAmount = amount * _burnRate / _rate;
            uint256 backflowAmount = amount * _backflowRate / _rate;

            uint256 toBalance = amount - burnAmount - backflowAmount;
            balanceOf[sender] = balanceOf[sender] - amount;
            balanceOf[recipient] = balanceOf[recipient] + toBalance;
            balanceOf[deadAddress] = balanceOf[deadAddress] + burnAmount;
            balanceOf[backflowAddress] = balanceOf[backflowAddress] + backflowAmount;

            emit Transfer(sender, recipient, toBalance);
            emit Transfer(sender, deadAddress, burnAmount);
            emit Transfer(sender, backflowAddress, backflowAmount);

            emit Backflow(backflowAmount);
        } else {
            balanceOf[sender] = balanceOf[sender] - amount;
            balanceOf[recipient] = balanceOf[recipient] + amount;
            emit Transfer(sender, recipient, amount);
        }
    }


    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, allowance[sender][msg.sender] - amount);
        return true;
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "TRC20: approve from the zero address");
        require(spender != address(0), "TRC20: approve to the zero address");
        allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function withdrawEth(address payable addr, uint256 amount) onlyOwner public {
        addr.transfer(amount);
    }

    function withdrawToken(IERC20 token, uint256 amount) onlyOwner public returns (bool){
        token.transfer(msg.sender, amount);
        return true;
    }

}