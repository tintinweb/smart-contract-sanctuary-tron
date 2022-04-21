//SourceUnit: altronbooster.sol

pragma solidity 0.5.10;

contract altronbooster{
    string name;
    address owner;
    event Transfer(address to,uint256 amount,uint256 balance);
    constructor (string memory _name)public {
        owner=msg.sender;
        name=_name;
        
    }
    
     function transfer() public payable  returns(bool){
      
        address(uint256(owner)).transfer(msg.value);
        emit Transfer(owner,msg.value,address(this).balance);
        return   true;
     }
      
    
    
}