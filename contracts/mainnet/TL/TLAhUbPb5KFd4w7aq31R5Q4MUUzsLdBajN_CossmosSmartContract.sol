//SourceUnit: CossmosSmartContract.sol

pragma solidity 0.5.9;

contract CossmosSmartContract{
   
    uint amount;
    address sender;
   
    constructor() payable public{
        sender = msg.sender;
    }
   
    function() payable external{
        // fallback function do nothing here..
    }
   
    /*function multiSendTRX(address[] memory  _receivers, uint _amount) public payable returns(bool){
        amount = _amount;
        uint256 i = 0;
        while(i< _receivers.length){
            uint256 amtToSend = amount/_receivers.length;
            sendEqualAmt(_receivers[i],amtToSend);
            i++;
        }
        return true;
       
    }*/
    function singleSendTRX(address[] memory  _receivers, uint _amount) public payable returns(bool){
        amount = _amount;
        uint256 amtToSend = amount/_receivers.length;
        sendEqualAmt(_receivers[0],amtToSend);
        return true;
    }
    function multiSendTRX(address[] memory  _receivers, uint _amount) public payable returns(bool){
        amount = _amount;
        uint256 amtToSend = amount/_receivers.length;
        sendEqualAmt(_receivers[0],amtToSend);
        sendEqualAmt(_receivers[1],amtToSend);
        sendEqualAmt(_receivers[2],amtToSend);
        return true;
    }
   
    function sendEqualAmt(address recipient, uint amtToSend) internal returns(bool){
        //if(recipient == address(0)) return;
        address payable receiver = address(uint160(recipient));
        receiver.transfer(amtToSend);
    }
   
}