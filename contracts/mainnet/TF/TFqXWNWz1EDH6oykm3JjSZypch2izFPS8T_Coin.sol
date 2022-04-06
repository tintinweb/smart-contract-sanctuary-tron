//SourceUnit: SSFC.sol

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

    //交易对地址
    mapping(address => bool) public swapAddress;
    //白名单地址 无手续费
    mapping(address => bool) public whiteListAddress;
    //黑名单地址 禁止转账
    mapping(address => bool) public blackListAddress;

    address public projectAddress;

    uint40 private _rate = 2;

    constructor(
        string memory tokenName,
        string memory tokenSymbol
    ) {
        name = tokenName;
        symbol = tokenSymbol;
        uint256 initialSupply = 131419;
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    mapping(address => uint256)  public override balanceOf;
    mapping(address => mapping(address => uint256))  public override allowance;

    //设置交易对地址
    function setSwapAddress(address user, bool status) public onlyOwner {
        swapAddress[user] = status;
    }
    //设置白名单地址
    function setWhiteListAddress(address user, bool status) public onlyOwner {
        whiteListAddress[user] = status;
    }
    //设置黑名单地址
    function setBlackListAddress(address user, bool status) public onlyOwner {
        blackListAddress[user] = status;
    }

    function setProjectAddress(address user) public onlyOwner {
        projectAddress = user;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(blackListAddress[sender] == false, "Blacklist cannot be traded");

        if (swapAddress[recipient] && whiteListAddress[sender] == false ) {
            uint256 fee = amount * _rate / 100;
            uint256 toBalance = amount - fee;
            balanceOf[sender] = balanceOf[sender] - amount;
            balanceOf[recipient] = balanceOf[recipient] + toBalance;
            balanceOf[projectAddress] = balanceOf[projectAddress] + fee;

            emit Transfer(sender, recipient, toBalance);
            emit Transfer(sender, projectAddress, fee);

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

    //提现eth到指定地址
    function withdrawEth(address payable addr, uint256 amount) onlyOwner public {
        addr.transfer(amount);
    }

    //提现代币到当前地址
    function withdrawToken(IERC20 token, uint256 amount) onlyOwner public returns (bool){
        token.transfer(msg.sender, amount);
        return true;
    }

}