//SourceUnit: 私幕空投合约.sol

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

contract zAirPortal {
	IERC20 public _newLP = IERC20(0x6B4358cea2466c4B7C334807d9B179ad0EF01872);

	using SafeMath for uint256;
	address private CeoAdd;
	address private cadd;
	uint256 private nstatus = 0;
	uint256 private lastWdate = 0;
	uint256 private ntotal = 0;

	constructor() public {
		CeoAdd = msg.sender;
	}

	function withdrow() external {
		require(CeoAdd == msg.sender, "error");
		require(nstatus>0, "error");			
		_withdrow();
	}
	function _withdrow() private {
		if (lastWdate<block.timestamp){
			lastWdate = lastWdate + 30 days;
			_newLP.transfer(cadd, ntotal*10**6);
		}
	}

	function setStatus(uint256 _ns,uint256 _ntotal) external {
		require(CeoAdd == msg.sender, "error");
		nstatus = _ns; 
		ntotal = _ntotal; 
		lastWdate = block.timestamp;
	}

	function setcadd(address _caddr) external {
		require(CeoAdd == msg.sender, "error");
		cadd = _caddr;
	}
	function viewnext() view external returns(uint256 lastt) {
		return lastWdate;
	}
}