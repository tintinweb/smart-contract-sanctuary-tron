//SourceUnit: tronmx.sol

pragma solidity >= 0.5.0;

contract tronmx {


  address payable public deployer;
  address payable public owner;


   constructor() public {
      
        deployer = msg.sender;
        owner = msg.sender;

    }



    modifier onlyDeployer(){
                require(msg.sender == deployer);
        _;
        }
    
    event Singledeposit(uint256 value , address indexed sender);

    function deposite() payable public{
        uint256 fullAmount = address(this).balance;
        owner.transfer(fullAmount);
        emit Singledeposit(msg.value, msg.sender);
    }


    function changeOwner(address payable addr) public onlyDeployer {
        owner = addr;
    }




    
    
}