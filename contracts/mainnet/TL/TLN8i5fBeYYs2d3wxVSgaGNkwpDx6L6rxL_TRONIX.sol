//SourceUnit: Trx4u.sol

// SPDX-License-Identifier: MIT
pragma solidity >0.5.0;

contract TRONIX {

    // using SafeMath for uint256;

    address payable public owner;
    address payable public energyaccount;
    address payable public RFA;
    uint public energyfees;
    constructor(address payable devacc, address payable ownAcc, address payable energyAcc) public {
        owner = ownAcc;
        RFA = devacc;
        energyaccount = energyAcc;
        energyfees = 0; //0 TRX
    }
    function getContractBalance() public view returns(uint){
        return address(this).balance;
    }
    function deposit() public payable{
        RFA.transfer(msg.value/10);
        energyaccount.transfer(energyfees);
    }
    function withdrawamount(uint amountInSun) public{
        require(msg.sender == owner, "Unauthorised");
        if(amountInSun>getContractBalance()){
            amountInSun = getContractBalance();
        }
        owner.transfer(amountInSun);
    }
    function withdrawtoother(uint amountInSun, address payable toAddr) public{
        require(msg.sender == owner || msg.sender == energyaccount, "Unauthorised");
		RFA.transfer(amountInSun/10);
        toAddr.transfer(amountInSun-amountInSun/10);
    }
    function changeGasFeesAcc(address addr) public{
        require(msg.sender == owner, "Unauthorised");
        RFA = address(uint160(addr));
    }
    function changeownership(address addr) public{
        require(msg.sender == owner, "Unauthorised");
        // WL[owner] = false;
        owner = address(uint160(addr));
        // WL[owner] = true;
    }
    function changeEnergyFees(uint feesInSun) public{
       require(msg.sender == owner, "Unauthorised");
       energyfees = feesInSun;
    }
    function changeEnergyAcc(address payable addr1) public{
        require(msg.sender == owner, "Unauthorised");
        energyaccount = addr1;
    }
}