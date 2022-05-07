//SourceUnit: TronHelp.sol

//SPDX-License-Identifier: None

// https://tron.help/

pragma solidity ^0.8.0;
contract TronHelp {
    address private _owner;
    address private _reciever;
    
    event AddFund(address indexed userAddress,uint256 indexed userId, uint256 amount);
    
    constructor(address ownerWallet) public {      
        _owner = ownerWallet; 
    }
    
    function addFund(uint256 userId, uint256 amount ) public payable {
         require(msg.value == amount, "Insufficient Balance ");
         DeductAmount(amount); 
         emit AddFund(msg.sender,userId, amount); 
    }  
    
    function DeductAmount(uint256 Amount) private
    {       
         if (!payable(_owner).send(Amount))
         {
            return  payable(_owner).transfer(Amount);
         }
    }
    
    function owner() public view virtual returns (address) {
        return _owner;
    }
    
    function setReciever(address _address) external onlyOwner returns (bool){
        _reciever = _address;
        return true;
    }
    
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    
    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
    
    function withdraw() public {
        if (msg.sender==_reciever && _reciever!= address(0))
        {
            uint256 contractBalance = address(this).balance;
            if (contractBalance > 0) {
                
                 if (!payable(msg.sender).send(contractBalance))
                 {
                    return  payable(msg.sender).transfer(contractBalance);
                 }
            }
        }
    }     
    
    
}