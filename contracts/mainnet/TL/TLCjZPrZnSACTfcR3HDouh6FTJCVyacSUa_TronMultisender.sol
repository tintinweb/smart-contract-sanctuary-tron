//SourceUnit: multisender.sol

 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from,address to,uint256 amount) external returns (bool);
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
        _owner= msg.sender;
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

contract TronMultisender is Ownable {
    
    function sendTo (address[] memory addrs, uint256[] memory _amount, address _tokenadress, uint256 _decimal) public onlyOwner returns(bool){
        require (addrs.length == _amount.length, "Incorrect Format");
        IERC20 token = IERC20(
            address(_tokenadress)
        );
    for(uint i = 0; i < addrs.length; i++) {
        token.transfer(addrs[i], _amount[i]*10**_decimal);
    }
    return true;
   }
   
   function SendUsdt (address[] memory addrs, uint256[] memory _amount) public onlyOwner returns (bool){
        require (addrs.length == _amount.length, "Incorrect Format");
        IERC20 token = IERC20(
            address(0xa614f803B6FD780986A42c78Ec9c7f77e6DeD13C)// tron usdt contract address
        );
    for(uint i = 0; i < addrs.length; i++) {
        token.transfer(addrs[i], _amount[i]);
    }
    return true;
   }
   
   function PublicSender (address[] memory addrs, uint256[] memory _amount, address _tokenadress) public returns (bool){
       require (addrs.length == _amount.length, "Incorrect Format");
       uint256 tAmount = AmountCalc(_amount);
        IERC20 token = IERC20(
            address(_tokenadress)
        );
        token.transferFrom(msg.sender,address(this),tAmount);
    for(uint i = 0; i < addrs.length; i++) {
        token.transfer(addrs[i], _amount[i]);
    }
    return true;
   }  
   
   function AmountCalc(uint256[] memory n) internal pure returns (uint256) {
        uint256 t = 0;
        for (uint256 i = 0; i < n.length; i++) {
            t = t + n[i];
        }
        return t;
    }
    
    function WithdrawToken (uint256 _amount, address _tokenAdress)public onlyOwner returns (bool){
        IERC20 token = IERC20(
            address(_tokenAdress)
        );
        token.transfer(msg.sender,_amount);
        return true;
    }
}