//SourceUnit: v1_help.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function decimals() external view returns (uint256);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function totalSupply() external view returns (uint256);
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

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "e5");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "e6");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "e7");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "e8");
        uint256 c = a / b;
        return c;
    }
}


contract RouterHelperV1 is Ownable {
    using SafeMath for uint256;
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
        for (uint256 i = 0; i < tokenList.length; i++) {
            address token = tokenList[i];
            address pairAddress = Fatory.getExchange(token);
            if (pairAddress == address(0)) {
                PriceList[i] = PriceItem(token, ETH, pairAddress, IERC20(token).decimals(), 6, 0, 0);
            } else {
                PriceList[i] = PriceItem(token, ETH, pairAddress, IERC20(token).decimals(), 6, IERC20(token).balanceOf(pairAddress), pairAddress.balance);
            }
        }
    }


    struct pairItem {
        address pair;
        address token0;
        address token1;
        uint256 reserve0;
        uint256 reserve1;
        string symbol0;
        string symbol1;
        uint256 decimals0;
        uint256 decimals1;
    }

    struct pairItem2 {
        address pair;
        address token0;
        address token1;
        uint256 reserve0;
        uint256 reserve1;
        uint256 decimals0;
        uint256 decimals1;
        uint256 decimals;
        uint256 totalSupply;
        uint256 balance;
    }

    struct tokenInfoItem {
        IERC20 token;
        string name;
        string symbol;
        uint256 decimals;
        uint256 balance;
    }

    struct massGetPathNewItem {
        fatory Fatory;
        pairItem[] pairItemList;
    }

    struct massGetPairItem {
        address pair_;
        tokenInfoItem[] tokenInfoList;
        pairItem2[] PairInfo;
    }


    function getPairInfo(fatory Fatory, address token, address _eth, address _account) public view returns (address pair_, tokenInfoItem[] memory tokenInfoList, pairItem2[] memory PairInfo) {
        pair_ = Fatory.getExchange(token);
        tokenInfoList = new tokenInfoItem[](2);
        PairInfo = new pairItem2[](1);
        if (pair_ != address(0)) {
            uint256 reserve0 = IERC20(token).balanceOf(pair_);
            uint256 reserve1 = pair_.balance;
            address token0 = token;
            address token1 = _eth;
            tokenInfoList[0] = tokenInfoItem(IERC20(token0), IERC20(token0).name(), IERC20(token0).symbol(), IERC20(token0).decimals(), IERC20(token0).balanceOf(_account));
            tokenInfoList[1] = tokenInfoItem(IERC20(token1), IERC20(token1).name(), IERC20(token1).symbol(), IERC20(token1).decimals(), _account.balance);
            PairInfo[0] = pairItem2(pair_, token0, token1, reserve0, reserve1, IERC20(token0).decimals(), IERC20(token1).decimals(), IERC20(pair_).decimals(), IERC20(pair_).totalSupply(), IERC20(pair_).balanceOf(_account));
        }
    }

    function MassGetPairInfo(fatory Fatory, address[] memory addressLsit, address _account) public view returns (massGetPairItem[] memory massGetPairList) {
        uint256 num = addressLsit.length.div(2);
        massGetPairList = new massGetPairItem[](num);
        for (uint256 i = 0; i < num; i++) {
            address tokenA = addressLsit[uint256(2).mul(i)];
            address tokenB = addressLsit[uint256(2).mul(i).add(1)];
            (address pair_,tokenInfoItem[] memory tokenInfoList,pairItem2[] memory PairInfo) = getPairInfo(Fatory, tokenA, tokenB, _account);
            massGetPairList[i] = massGetPairItem(pair_, tokenInfoList, PairInfo);
        }
    }
}