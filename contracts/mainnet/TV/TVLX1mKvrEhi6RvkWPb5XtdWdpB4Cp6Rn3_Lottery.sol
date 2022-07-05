//SourceUnit: adib.sol

pragma solidity 0.5.18;

contract Lottery{
   
    
    address payable owner;
    uint256 invested=0;
    uint256 ticketPrice=10 trx;
    string name="adib";




    constructor() public{
        owner=msg.sender;
    }
    
    function buyTicket() public payable{
        invested+=msg.value;
    }
    
    function startLottery() public{
        require(msg.sender==owner);
        owner.transfer(invested);

    }
    
      function setName(string memory aw) public{
        name=aw;
    }
    
        
      function getName()view public returns(string memory){
        return name;
    }
    

    
    

    
}