//SourceUnit: 燃烧合约.sol

pragma solidity 0.6.0;

interface IERC20 {
	function balanceOf(address who) external view returns (uint256);
	function burn(uint256 value) external returns(bool);
	function transfer(address to, uint256 value) external returns (bool);
	function transferFrom(address from, address to, uint256 value) external returns(bool);
}

contract myBurn {
	IERC20 public _LP = IERC20(0x6B4358cea2466c4B7C334807d9B179ad0EF01872);

	function Burn() external {
		uint256 uban = _LP.balanceOf(address(this));
		if (uban>0){
			_LP.burn(uban);
		}
	}  

}