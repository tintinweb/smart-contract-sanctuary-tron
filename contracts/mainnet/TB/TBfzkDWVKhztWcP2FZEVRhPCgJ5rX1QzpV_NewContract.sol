//SourceUnit: trc.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint value);


    event Approval(address indexed owner, address indexed spender, uint value);


    function totalSupply() external view returns (uint);


    function balanceOf(address account) external view returns (uint);


    function transfer(address to, uint amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint amount
    ) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    constructor() {
        _transferOwnership(_msgSender());
    }


    modifier onlyOwner() {
        _checkOwner();
        _;
    }


    function owner() public view virtual returns (address) {
        return _owner;
    }


    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }


    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }


    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }


    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract NewContract is Ownable {
    IERC20 public USDT;

    constructor(address _usdt){
        USDT = IERC20(_usdt);
    }

    uint USDT_amount;

    function getUSDT() external view returns(uint){
        return USDT.balanceOf(address(this));
    }

    function getTRON() external view returns(uint){
        return address(this).balance;
    }
    
    function depositUSDT(uint _amount) external {
        require(_amount != 0, "Zero value");
        USDT.transferFrom(msg.sender, address(this), _amount);

    }

    function depositTRON() external payable {}

    function withdrawUSDT(address _to, uint _amount) external onlyOwner{
        require(_amount != 0, "Zero value");
        USDT.transfer(_to, _amount);
    }

    function withdrawTRON(address _to, uint _amount) external onlyOwner {
        require(_amount != 0, "Zero value");
        payable(_to).transfer(_amount);
    }
}