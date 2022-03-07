//SourceUnit: ShareNg.sol

pragma solidity ^0.5.10;

contract Ownable {
    address public _owner;
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }
}

interface ShareContract {
	function setShareshipNG(address me,address parent) external returns (bool);
	function getshare(address user) external view returns(address,uint256);
}

contract ShareContractNg is Ownable{

	ShareContract public share;
	
	function setShareship(address parent) public returns (bool){
		share.setShareshipNG(msg.sender,parent);
		return true;
	}
	
	function getshare(address user) public view returns(address,uint256){
		return share.getshare(user);
	}
	
	constructor() public {
		share = ShareContract(0x41de6da50ae3f306a37a08ed3bf68edd8f298fb803);
		_owner = msg.sender;
	}
}