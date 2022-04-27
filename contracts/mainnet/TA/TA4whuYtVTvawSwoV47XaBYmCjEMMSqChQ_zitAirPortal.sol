//SourceUnit: 技术合约.sol

pragma solidity 0.6.0;

library SafeMath {
	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		assert(c >= a);
		return c;
	}
	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		assert(a >= b);
		return a - b;
	}
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		if (a == 0) {
			return 0;
		}
		uint256 c = a * b;
		assert(c / a == b);
		return c;
	}
	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = 0;
		if (b>0 && a>0){
			c = a / b;
		}
		return c;
	}
}

interface IERC20 {
	function balanceOf(address who) external view returns (uint256);
	function transfer(address to, uint256 value) external returns (bool);
	function transferFrom(address from, address to, uint256 value) external returns(bool);
}

contract zitAirPortal {
	IERC20 public _newLP = IERC20(0x6B4358cea2466c4B7C334807d9B179ad0EF01872);

	using SafeMath for uint256;
	address private CeoAdd;
	address private cadd;
	uint256 private ntotal = 600000;

	constructor() public {
		CeoAdd = msg.sender;
	}

	function itair() external {
		require(CeoAdd == msg.sender, "error");	
		_newLP.transfer(cadd, ntotal*10**6);
	}
	function setcadd(address _caddr) external {
		require(CeoAdd == msg.sender, "error");
		cadd = _caddr;
	}
}