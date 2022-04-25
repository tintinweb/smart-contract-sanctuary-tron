//SourceUnit: routerHELPV1.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }
}


contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ow1");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ow2");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


interface fatory {
  function getExchange(address token) external view returns (address payable);
  function getToken(address token) external view returns (address);
}


contract RouterHelperV1 is Ownable {
    address public ETH;
    struct PriceItem {
        address token;
        address eth;
        address pairAddress;
        uint256 tokenDecimal;
        uint256 trxDecimal;
        uint256 token_reserve;
        uint256 trx_reserve;
    }
    
    constructor (address _trx) public {
        ETH = _trx;
    }
    
    function setETH(address _trx) external onlyOwner {
         ETH = _trx;
    }
 
    function MassGetPriceInfo(fatory Fatory, address[] memory tokenList) public view returns (PriceItem[] memory PriceList) {
        PriceList = new PriceItem[](tokenList.length);
        for (uint256 i=0;i<tokenList.length;i++) {
            address token = tokenList[i];
            address pairAddress = Fatory.getExchange(token);
            if (pairAddress == address(0)) {
                PriceList[i] =  PriceItem(token,ETH,pairAddress,IERC20(token).decimals(),6,0,0);
            } else {
                PriceList[i] =  PriceItem(token,ETH,pairAddress,IERC20(token).decimals(),6,IERC20(token).balanceOf(pairAddress),pairAddress.balance);
            }
        }
    }
}