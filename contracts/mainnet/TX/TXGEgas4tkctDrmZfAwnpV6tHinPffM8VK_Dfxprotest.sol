//SourceUnit: Dfxpro.sol

pragma solidity >=0.4.0 <0.8.0;


contract Dfxprotest {
  address public manager;
   
    function Dfxprotest1() public {
        manager = msg.sender;
        
    }
   
    uint[] public members;
    
    function membersget() public {
        members.push(1);
        members.push(10);
        members.push(20);
        
    }
    

    function getmemberarrylen() public view returns(uint) {
        return members.length;
    }
       function getfirstmember() public view returns(uint) {
        return members[0];
    }
    
}