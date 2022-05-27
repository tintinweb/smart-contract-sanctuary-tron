//SourceUnit: heyue2.sol

/**
 *Submitted for verification at BscScan.com on 2022-04-26
*/

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

contract Ownable {
    address public _owner;

   
    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
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

contract ZX is IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) private _rOwned;
    
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    uint256 private _tTotal;
    uint256 private _burnTotal;
    uint256 private _burnTotalend;
    uint256 private _tFeeTotal;
    string private _name;
    string private _symbol;
    uint256 private _decimals;
    uint256 public _baseFee = 1000;
   
  
    uint256 public _lpFee = 20;
    uint256 public _markFee = 10;
    uint256 public _burnFee = 20;

     uint256 public _lpFee2 = 30;
    uint256 public _markFee2 = 20;
    uint256 public _burnFee2 = 30;


    address private _destroyAddress = address(0);
    IERC20 usdt;
    uint256 public tradingEnabledTimestamp = 1650459043; //2022-04-20   
    
    mapping(address => address) public inviter;
    mapping(address => bool) public _isBlacklisted;
    mapping(address => bool) public leader;
  
    address public uniswapV2Pair;
	address public uniswapV2Pair2;
	address public uniswapV2Pair3;
	address public uniswapV2Pair4;
    address public _fundAddressA;
    address public _fundAddressB;
	address public _fundAddressC;
	address public _fundAddressD;
	
    constructor(address tokenOwner,address fundAddressA,address fundAddressB) {
        _name = "ZX";
        _symbol = "ZX";
        _decimals = 9;
        _tTotal = 9999 * 10**_decimals; 
        _burnTotal = _tTotal;
        _burnTotalend = 1 * 10**_decimals;
       
        _rOwned[tokenOwner] = _tTotal;
        _isExcludedFromFee[tokenOwner] = true;
        _fundAddressA = fundAddressA;//marker
        _fundAddressB = fundAddressB;//super
      
    
        _owner = msg.sender;
        //_owner=tokenOwner;
        emit Transfer(address(0), tokenOwner, _tTotal);
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
        return _burnTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        //return tokenFromReflection(_rOwned[account]);
        return _rOwned[account];
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

    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

 
    receive() external payable {}

  
    function claimTokens() public onlyOwner {
        payable(_owner).transfer(address(this).balance);
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
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
       
        require(!_isBlacklisted[from], "Blacklisted address"); 

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(balanceOf(from)>=amount,"YOU HAVE insuffence balance");
       

        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            _tokenTransfer(from, to, amount);
        }else{
			if(from == uniswapV2Pair){
				_tokenTransferBuy(from, to, amount);
			}else if(to == uniswapV2Pair){
				_tokenTransferSell(from, to, amount);
			}else if(from == uniswapV2Pair2){
				_tokenTransferBuy(from, to, amount);
			}else if(to == uniswapV2Pair2){
				_tokenTransferSell(from, to, amount);
			}else if(from == uniswapV2Pair3){
				_tokenTransferBuy(from, to, amount);
			}else if(to == uniswapV2Pair3){
				_tokenTransferSell(from, to, amount);
			}else if(from == uniswapV2Pair4){
				_tokenTransferBuy(from, to, amount);
			}else if(to == uniswapV2Pair4){
				_tokenTransferSell(from, to, amount);
			}else{
                
				_tokenTransfer(from, to, amount);
			}
        }
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        
        bool shouldSetInviter = 
            inviter[recipient] == address(0) &&
            sender != uniswapV2Pair&&
            sender != uniswapV2Pair2&&
            sender != uniswapV2Pair3&&
            sender != uniswapV2Pair4&&
            tAmount >= 9 * 10 **2&&
            tAmount <= 1 * 10 **5;
            
        if (shouldSetInviter) {
            inviter[recipient] = sender;
        }
       
        uint256 rAmount = tAmount;
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        _rOwned[recipient] = _rOwned[recipient].add(rAmount);
        emit Transfer(sender, recipient, tAmount);
    }


    function _tokenTransferBuy(
        address sender,
        address recipient,
        uint256 tAmount
        
		
    ) private {

        bool tradingIsEnabled = getTradingIsEnabled();
        require(tradingIsEnabled, "Time is not up");

        if (
            tradingIsEnabled &&                  //start time
           block.timestamp <= tradingEnabledTimestamp + 9 seconds) {  //bot 
            addBot(recipient);                                 //add black
        }

       
         
        uint256 rAmount = tAmount;
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
 
		_takeTransfer(
			sender,
			_fundAddressA,
			tAmount.div(_baseFee).mul(_markFee)
			
		);
      
		_takeTransfer(
			sender,
			_fundAddressB,
			tAmount.div(_baseFee).mul(_lpFee)//lpfee
			
		);
      

        uint256 sumsellfee;
      
            _takeTransfer(
                sender,
                _destroyAddress,
                tAmount.div(_baseFee).mul(_burnFee)
                
            );
            _burnTotal=_burnTotal-tAmount.div(_baseFee).mul(_burnFee);
            sumsellfee=_baseFee-_burnFee-_lpFee-_markFee;
      
        
            _rOwned[recipient] = _rOwned[recipient].add(
                tAmount.div(_baseFee).mul(sumsellfee)
            );
            emit Transfer(sender, recipient, tAmount.div(_baseFee).mul(sumsellfee));


    }
    

    function _tokenTransferSell(
        address sender,
        address recipient,
        uint256 tAmount
       
		
    ) private {

        bool tradingIsEnabled = getTradingIsEnabled();
        require(tradingIsEnabled, "Time is not up");

        if (
            tradingIsEnabled &&                  //start time
           block.timestamp <= tradingEnabledTimestamp + 9 seconds) {  //bot 
            addBot(recipient);                                 //add black
        }

       
         
        uint256 rAmount = tAmount;
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
 
		_takeTransfer(
			sender,
			_fundAddressA,
			tAmount.div(_baseFee).mul(_markFee2)
			
		);
      
		_takeTransfer(
			sender,
			_fundAddressB,
			tAmount.div(_baseFee).mul(_lpFee2)//lpfee
			
		);
      

        uint256 sumsellfee;
      
            _takeTransfer(
                sender,
                _destroyAddress,
                tAmount.div(_baseFee).mul(_burnFee2)
                
            );
            _burnTotal=_burnTotal-tAmount.div(_baseFee).mul(_burnFee2);
            sumsellfee=_baseFee-_burnFee2-_lpFee2-_markFee2;
      
        
            _rOwned[recipient] = _rOwned[recipient].add(
                tAmount.div(_baseFee).mul(sumsellfee)
            );
            emit Transfer(sender, recipient, tAmount.div(_baseFee).mul(sumsellfee));


    }



    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
       
    ) private {
        uint256 rAmount = tAmount;
        _rOwned[to] = _rOwned[to].add(rAmount);
        emit Transfer(sender, to, tAmount);
    }

    function changeRouter(address router) public onlyOwner {
        uniswapV2Pair = router;
    }
	function changeRouter2(address router) public onlyOwner {
        uniswapV2Pair2 = router;
    }
	function changeRouter3(address router) public onlyOwner {
        uniswapV2Pair3 = router;
    }
	function changeRouter4(address router) public onlyOwner {
        uniswapV2Pair4 = router;
    }
    function changeA(address _AddressA) public onlyOwner {
        _fundAddressA = _AddressA;
    }
    function changeB(address _AddressB) public onlyOwner {
        _fundAddressB = _AddressB;
    }
 
    function getfater(address _my) public view returns (address) {
     return inviter[_my];
    }
     function getTradingIsEnabled() public view returns (bool) {
        return block.timestamp >= tradingEnabledTimestamp;
    }

     function setplanastart_end(uint256 _time)  public onlyOwner(){
         tradingEnabledTimestamp=_time;
    }

    function set_lp_marker_fee(uint256 lpfee,uint256 markfee)  public onlyOwner(){
         _lpFee=lpfee;
         _markFee=markfee;
    }
   
    function setburnfee(uint256 burnfee)  public onlyOwner(){
         _burnFee=burnfee;
    }
  
    
    function blacklistAddress(address account, bool value) external onlyOwner {
        _isBlacklisted[account] = value;   //true is black
    }
    function addBot(address recipient) private {
        if (!_isBlacklisted[recipient]) _isBlacklisted[recipient] = true;
    }
 

}