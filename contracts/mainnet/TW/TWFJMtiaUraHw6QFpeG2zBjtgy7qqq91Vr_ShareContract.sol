//SourceUnit: SHARECONTRCT.sol

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


contract ShareContract is Ownable{

	mapping (address => address) private _shareship;
	mapping (address => uint256) private _sharenumship;
	
	function setShareship(address parent) public returns (bool){
		_setShareship(msg.sender,parent);
		return true;
	}
	
	function setShareshipNG(address me,address parent) public onlyOwner returns (bool){
		_setShareship(me,parent);
		return true;
	}
	
	function _setShareship(address me,address parent) private{
		require(_shareship[me] == address(0));
		_shareship[me] = parent;
		_sharenumship[parent] += 1;
	}
	
	function getshare(address user) public view returns(address,uint256){
		return (_shareship[user],_sharenumship[user]);
	}
	
	constructor() public {
		_owner = msg.sender;
	}
}