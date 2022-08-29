//SourceUnit: hif_token.sol

/*! market.hif-token.sol | SPDX-License-Identifier: MIT License */

pragma solidity 0.8.6;

abstract contract TRC20 {
    string public name;
    string public symbol;
    uint8 public decimals;

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function _mint(address to, uint256 value) internal virtual {
        totalSupply += value;
        balanceOf[to] += value;

        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint256 value) internal virtual {
        totalSupply -= value;
        balanceOf[from] -= value;

        emit Transfer(from, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) internal virtual {
        allowance[owner][spender] = value;

        emit Approval(owner, spender, value);
    }

    function _transfer(address from, address to, uint256 value) internal virtual {
        balanceOf[from] -= value;
        balanceOf[to] += value;

        emit Transfer(from, to, value);
    }


    function approve(address spender, uint256 value) public virtual returns(bool) {
        _approve(msg.sender, spender, value);

        return true;
    }

    function increaseAllowance(address spender, uint256 value) public virtual returns(bool) {
        _approve(msg.sender, spender, allowance[msg.sender][spender] + value);

        return true;
    }

    function decreaseAllowance(address spender, uint256 value) public virtual returns(bool) {
        _approve(msg.sender, spender, allowance[msg.sender][spender] - value);

        return true;
    }

    function transfer(address to, uint256 value) public virtual returns(bool) {
        _transfer(msg.sender, to, value);

        return true;
    }

    function transferFrom(address from, address to, uint256 value) public virtual returns(bool) {
        if(allowance[from][msg.sender] != type(uint256).max) {
            allowance[from][msg.sender] -= value;
        }

        _transfer(from, to, value);

        return true;
    }
}

abstract contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: ACCESS_DENIED");
        _;
    }

    constructor() {
        _transferOwnership(msg.sender);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = owner;
        owner = newOwner;

        emit OwnershipTransferred(oldOwner, newOwner);
    }


    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: ZERO_ADDRESS");

        _transferOwnership(newOwner);
    }

    function rescue(TRC20 token, address payable to, uint256 amount) public virtual onlyOwner {
        require(to != address(0) && amount > 0, "Regulable: BAD_PARAMS");

        if(address(token) != address(0)) token.transfer(to, amount);
        else to.transfer(amount);
    }
}

abstract contract BlackList is Ownable {
    mapping(address => bool) public blackList;

    event Allow(address indexed member);
    event Deny(address indexed member);

    modifier allowed(address from, address to) {
        require(!blackList[from] && !blackList[to], "BlackList: NOT_ALLOWED");
        _;
    }
    
    function allow(address spender) public virtual onlyOwner {
        require(blackList[spender], "BlackList: SPENDER_ALLOW");

        blackList[spender] = false;

        emit Allow(spender);
    }
    
    function deny(address spender) public virtual onlyOwner {
        require(!blackList[spender], "BlackList: SPENDER_DENY");

        blackList[spender] = true;

        emit Deny(spender);
    }
}

contract HIFToken is TRC20, BlackList {
    event BurnBlackFunds(address indexed member, uint256 amount);

    constructor() {
        name = "HiFloor Marketplace Token";
        symbol = "HIF";
        decimals = 8;
    }

    function transfer(address to, uint256 value) public override allowed(msg.sender, to) returns(bool) {
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public override allowed(from, to) returns(bool) {
        return super.transferFrom(from, to, value);
    }


    function mint(address to, uint256 value) public onlyOwner {
        _mint(to, value);
    }

    function burn(uint256 value) public onlyOwner {
        _burn(msg.sender, value);
    }

    function burnBlackFunds(address from, uint256 value) public onlyOwner {
        require(blackList[from], "Token: NOT_BLOCKED");

        _burn(from, value);

        emit BurnBlackFunds(from, value);
    }
}