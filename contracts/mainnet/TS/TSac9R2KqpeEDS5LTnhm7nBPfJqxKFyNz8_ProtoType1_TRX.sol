//SourceUnit: ProtoType1_TRX.sol

pragma solidity >=0.4.0 <0.7.0;
/* Contract : ProtoType1_TRX */
contract ProtoType1_TRX {
mapping (address => uint256) private AccountBalance;
function readContractAddress() public view returns(address) {
return address(this);
}
function readContractBalance() public view returns(uint256) {
return address(this).balance;
}
function readAccountBalance() public view returns(uint256) {
return AccountBalance[msg.sender];
}
function () external payable {}
function writeAccountDeposit() external payable returns(uint256) {
AccountBalance[msg.sender] += msg.value;
return msg.value;
}
function writeAccountWithdraw() public returns(uint256) {
uint256 Amount = AccountBalance[msg.sender] / 2;
AccountBalance[msg.sender] = AccountBalance[msg.sender] / 2;
msg.sender.transfer(Amount);
return Amount;
}
}