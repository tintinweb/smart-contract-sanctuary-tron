//SourceUnit: HP.sol

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.6;
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

abstract contract Ownable {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor ()  {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return _owner;
    }   
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library SafeMath {
     
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
 
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }
  
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}
contract HP is IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping (address => bool) isDividendExempt;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _updated;
    uint256 private _tFeeTotal;
    string private _name = "HP";
    string private _symbol = "HP";
    uint8 private _decimals = 8;
    uint256 public  _burnFee = 0;
    uint256 private _previousburnFee;
    uint256 public _LPFee = 250;
    uint256 private _previousLPFee;
    uint256 public _backflowFee = 250;
    uint256 public _previousbackflowFee ;
    uint256 public currentIndex; 
    uint256 private _tTotal = 10000000 * 10**8;
    uint256 distributorGas = 500000;
    uint256 public minPeriod = 1 hours;
    uint256 public LPFeefenhong;
    address public  uniswapV2Router;
    address public  uniswapV2Pair;
    address private fromAddress;
    address private toAddress;
  
    address[] public shareholders;
    mapping (address => uint256) shareholderIndexes;

    constructor() {
        _tOwned[msg.sender] = _tTotal;
        _isExcludedFromFee[msg.sender] = true;
         _isExcludedFromFee[address(this)] = true;
        isDividendExempt[address(this)] = true;
        isDividendExempt[address(0)] = true;
        
        emit Transfer(address(0), msg.sender, _tTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _tOwned[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

   function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setUniswapV2Pair (address account) public onlyOwner {
        uniswapV2Pair = account;
    }

    function setUniswapV2Router (address account) public onlyOwner {
        uniswapV2Router = account;
    }
    receive() external payable {}

    function removeAllFee() private {
        _previousburnFee = _burnFee;
        _previousLPFee = _LPFee;
        _previousbackflowFee = _backflowFee;

        _burnFee = 0;
        _LPFee = 0;
        _backflowFee = 0;

      }

    function restoreAllFee() private {
        _burnFee = _previousburnFee;
        _LPFee = _previousLPFee;
        _backflowFee = _previousbackflowFee;
      }

    function onlyTakeLpFee() private {
        _previousburnFee = _burnFee;
        _previousLPFee = _LPFee;
        _previousbackflowFee = _backflowFee;

        _burnFee = 1000;
        _LPFee = 0;
        _backflowFee = 0;

     }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint8 takeFee = 0;

        if (_isExcludedFromFee[from] || _isExcludedFromFee[to] || from == address(uniswapV2Router)) {
            takeFee = 1;
        }
        if (to != uniswapV2Pair&&from != uniswapV2Pair)
        {
            if(_tFeeTotal < 9000000 * 10**8)
            {
                takeFee = 2;
            }
            else
            {
                takeFee = 1;
            }
        }
         _tokenTransfer(from, to, amount, takeFee);
        if(fromAddress == address(0) )fromAddress = from;
        if(toAddress == address(0) )toAddress = to;  
        if(!isDividendExempt[fromAddress] && fromAddress != uniswapV2Pair ) setShare(fromAddress);
        if(!isDividendExempt[toAddress] && toAddress != uniswapV2Pair ) setShare(toAddress);
        
        fromAddress = from;
        toAddress = to;  
         if(_tOwned[address(this)] >= 500  * 10**8 && from !=address(this) && LPFeefenhong.add(minPeriod) <= block.timestamp) {
             process(distributorGas) ;
             LPFeefenhong = block.timestamp;
        }
    }
    function process(uint256 gas) private {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0)return;
        uint256 nowbanance = _tOwned[address(this)];
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }
            uint256 lpTotalSupply = IERC20(uniswapV2Pair).totalSupply();
            uint256 addr1lp = IERC20(uniswapV2Pair).balanceOf(address(1));
            uint256 amount = nowbanance.mul(IERC20(uniswapV2Pair).balanceOf(shareholders[currentIndex])).div(lpTotalSupply.sub(addr1lp));
         if( amount < 1 * 10**8) {
             currentIndex++;
             iterations++;
             return;
         }
         if(_tOwned[address(this)]  < amount )return;
            distributeDividend(shareholders[currentIndex],amount);
            
            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));
            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }
   

    function distributeDividend(address shareholder ,uint256 amount) internal {
            
        _tOwned[address(this)] = _tOwned[address(this)].sub(amount);
        _tOwned[shareholder] = _tOwned[shareholder].add(amount);
        emit Transfer(address(this), shareholder, amount);
    }
    function setShare(address shareholder) private {
           if(_updated[shareholder] ){      
                if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) quitShare(shareholder);              
                return;  
           }
           if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) return;  
            addShareholder(shareholder);
            _updated[shareholder] = true;
          
      }
    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }
    function quitShare(address shareholder) private {
           removeShareholder(shareholder);   
           _updated[shareholder] = false; 
     }
    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        uint8 takeFee
    ) private {
        if (takeFee == 1) removeAllFee();
        if (takeFee == 2) onlyTakeLpFee();

        _transferStandard(sender, recipient, amount);

        if (takeFee == 1 || takeFee == 2) restoreAllFee();
    }

    function _takeburnFee(
        address sender,
        uint256 tAmount
    ) private {
        if (_burnFee == 0) return;
        if(_tFeeTotal >= 9000000 * 10**8) return;
        _tOwned[address(0)] = _tOwned[address(0)].add(tAmount);
        _tFeeTotal = _tFeeTotal.add(tAmount);
        emit Transfer(sender, address(0), tAmount);
    }

    function _takeLPFee(address sender,uint256 tAmount) private {
        if (_LPFee == 0) return;
        _tOwned[address(this)] = _tOwned[address(this)].add(tAmount);
        emit Transfer(sender, address(this), tAmount);
    }

   function backflow(address sender,uint256 tAmount) private {
        if (_backflowFee == 0) return;
        _tOwned[address(uniswapV2Pair)] = _tOwned[address(uniswapV2Pair)].add(tAmount);
        emit Transfer(sender, address(uniswapV2Pair), tAmount);
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _takeburnFee(sender, tAmount.div(10000).mul(_burnFee));
        _takeLPFee(sender, tAmount.div(10000).mul(_LPFee));
        backflow(sender, tAmount.div(10000).mul(_backflowFee));
        uint256 recipientRate = 10000 -
        _burnFee -
        _backflowFee -
        _LPFee;

        _tOwned[recipient] = _tOwned[recipient].add(
            tAmount.div(10000).mul(recipientRate)
        );
        emit Transfer(sender, recipient, tAmount.div(10000).mul(recipientRate));
    }
}