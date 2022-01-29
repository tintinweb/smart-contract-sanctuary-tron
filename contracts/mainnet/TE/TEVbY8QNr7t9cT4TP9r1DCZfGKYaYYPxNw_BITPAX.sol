//SourceUnit: trc20_token_BPAX_new.sol

pragma solidity 0.5.10;

contract ERC20Interface {

   function totalSupply() public view returns (uint256);
   function balanceOf(address tokenOwner) public view returns (uint256 balanceRemain);
   function allowance(address tokenOwner, address spender) public view returns (uint256 remaining);
   function transfer(address to, uint256 tokens) public returns (bool success);
   function approve(address spender, uint256 tokens) public returns (bool success);
   function transferFrom(address from, address to, uint256 tokens) public returns (bool success);
      
   event Transfer(address indexed from, address indexed to, uint256 value);
   event Approval(address indexed owner, address indexed spender, uint256 value);  

} 

contract BITPAX is ERC20Interface
{
	using SafeMath for uint256;
	string public name;
    string public symbol;
    uint8 public decimals = 4;
    uint256 public _totalSupply;
	address owner;
	bool public safeGuard = false;
	
	mapping (address => uint256) public _balanceOf;
    mapping (address => mapping (address => uint256)) public _allowance;
    mapping (address => bool) public isBlocked;
  
	event Burn(address indexed from, uint256 value);		
    
    constructor() public 
	{     
		owner = msg.sender;    
        _totalSupply = 820000000 * 10 ** uint256(decimals);  // Update total supply with the decimal amount
        _balanceOf[owner] = _totalSupply;                // Give the creator all initial tokens
        name = 'BITPAX';                                   // Set the name for display purposes
        symbol = 'BPAX';                               // Set the symbol for display purposes
		safeGuard = false;
		emit Transfer(address(0), owner, _totalSupply);
    }    

	function _transfer(address _from, address _to, uint256 _value) internal 
	{       
        require(_from != address(0),"Invalid Transfer From Address");
		require(_to != address(0),"Invalid Transfer To Address");        
        require(_balanceOf[_from] >= _value, "Insufficient Account Balance To Transfer");       
        require(_balanceOf[_to] + _value >= _balanceOf[_to], "Data Validation Failed!, Try Again?");
		require(safeGuard == false,"Safe Guard Protection Is On!");
		require(isBlocked[_from] == false,"Invalid Operation!");
		require(isBlocked[_to] == false,"Invalid Receiver!");
		
        uint256 previousBalances = _balanceOf[_from] + _balanceOf[_to];
        _balanceOf[_from] -= _value;
        _balanceOf[_to] += _value;
        
		emit Transfer(_from, _to, _value);
        
		assert(_balanceOf[_from] + _balanceOf[_to] == previousBalances);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }
	
	function balanceOf(address tokenOwner) public view returns (uint256 balanceRemain) {
       return _balanceOf[tokenOwner];
   }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
		require(safeGuard == false,"Safe Guard Protection Is On!");
		require(isBlocked[_from] == false,"Invalid Operation!");
		require(isBlocked[_to] == false,"Invalid Receiver!");
        require(_value <= _allowance[_from][msg.sender]);     // Check allowance		
        _allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }
    
    function approve(address _spender, uint256 _value) public returns (bool success) 
	{
		require(isBlocked[msg.sender] == false,"Invalid Operation!");
		require(isBlocked[_spender] == false,"Invalid Receiver!");
		require(safeGuard == false,"Safe Guard Protection Is On!");
        _allowance[msg.sender][_spender] = _value;
		emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
	function allowance(address _tokenOwner, address _spender) public view returns (uint256 remaining) {
       return _allowance[_tokenOwner][_spender];
   }
	
    function burn(uint256 _value) public returns (bool success) {
		require(safeGuard == false,"Safe Guard Protection Is On!");
		require(isBlocked[msg.sender] == false,"Invalid Operation!");
        require(_balanceOf[msg.sender] >= _value);   // Check if the sender has enough
        _balanceOf[msg.sender] -= _value;            // Subtract from the sender
        _totalSupply -= _value;                      // Updates totalSupply
        emit Burn(msg.sender, _value);
        return true;
    }
	   
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
		require(safeGuard == false,"Safe Guard Protection Is On!");
		require(isBlocked[msg.sender] == false,"Invalid Operation!");
		require(isBlocked[_from] == false,"Invalid Operation!");
        require(_balanceOf[_from] >= _value);                // Check if the targeted balance is enough
        require(_value <= _allowance[_from][msg.sender]);    // Check allowance
		
        _balanceOf[_from] -= _value;                         // Subtract from the targeted balance
        _allowance[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
        _totalSupply -= _value;                              // Update totalSupply
        emit Burn(_from, _value);
        return true;
    }
	
	
	function transferTRC20Token(address _tokenAddress, uint256 _value) public returns (bool success) 
	{
	   require(msg.sender == owner,"Only Owner Can Transfer");
       return ERC20Interface(_tokenAddress).transfer(owner, _value);
    }
	
	function transferTRC10Token(address payable _toAddress, trcToken _tokenId, uint _value) public  
	{
	   require(msg.sender == owner,"Only Owner Can Transfer");
       msg.sender.transferToken(_value, _tokenId);
    }
	
	function () external payable {
       revert();
   }
   
    function withdrawTRXBalance(uint256 _value) public
	{
	   require(msg.sender == owner,"Only Owner Can Transfer");
	   msg.sender.send(_value);
	}
	
	function setSafeGuard(bool _newStatus) public returns (bool success) 
	{
	   require(msg.sender == owner,"Only Owner Can Transfer");
	   safeGuard = _newStatus;
       return safeGuard;
    }
	
	function blockAccount(address _user) public
	{
	   require(msg.sender == owner,"Only Owner Can Transfer");
	   isBlocked[_user] = true;
    }
	
	function unBlockAccount(address _user) public
	{
	   require(msg.sender == owner,"Only Owner Can Transfer");
	   isBlocked[_user] = false;
    }
	
	function totalSupply() public view returns (uint256) {
       return _totalSupply  - _balanceOf[address(0)];
   }
}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}