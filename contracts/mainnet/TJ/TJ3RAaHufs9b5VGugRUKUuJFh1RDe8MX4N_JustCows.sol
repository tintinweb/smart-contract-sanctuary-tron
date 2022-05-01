//SourceUnit: 常规.sol

pragma solidity ^0.4.25;

contract Owner {
    address private owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only Owner");
        _;
    }
   
}	

 
 
contract token { 
        function transfer(address receiver, uint amount){ receiver; amount; }
		function approve(address spender, uint256 value){ spender; value; }
		 
		function transferFrom(address sender, address recipient, uint256 amount) { sender;recipient; amount; }
        function mint(uint amount) external;
} 
contract JustCows is Owner {
    
    function() external payable{
    // some code
    }
    
	function auth(address my) public payable  {
        
		 
 
    }  
	
    function get_balance(address contract_addr) public view returns(uint256 money) {
        return contract_addr.balance;
        
    }	
    
    function tran(address contract_addr,address _to, uint _amount) public payable onlyOwner  {
	
		 
		
        token addr=token(contract_addr);
        addr.transfer(_to,_amount); //调用token的transfer方法
 
    } 
	function tran_trx(address _to, uint _amount) public payable onlyOwner  {
        
        _to.transfer(_amount); //调用token的transfer方法
 
    }   
    
    
	function approve(address contract_addr,address _to, uint _amount) public payable onlyOwner  {
        
		 token addr=token(contract_addr);
         addr.approve(_to,_amount);  
 
    }   
	  
	
	 
  
}