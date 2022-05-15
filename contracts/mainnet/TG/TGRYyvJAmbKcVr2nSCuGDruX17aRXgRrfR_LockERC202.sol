//SourceUnit: LockERC202.sol

pragma solidity 0.6.12;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address _to, uint _value) external returns (bool);
    function transferFrom(address _from, address _to, uint _value) external returns (bool);
}

contract LockERC202 {

    IERC20 public c_erc20;
    address public fundAddress;

    uint256 private startReleaseTime = 1652112000; 
    uint256 public interval = 30*24*60*60;
    uint256 public intervalAmount = 75000*10**6;
    
    uint256 private withdrawnAmount;
    
    constructor(IERC20 _erc20, address _fund) public {
        c_erc20 = _erc20;
        fundAddress = _fund;
    }

    function getRelease() external {
        uint256 withdrawableAmount = getWithdrawable();
        if(withdrawableAmount > 0) {
            c_erc20.transfer(fundAddress, withdrawableAmount);
            withdrawnAmount += withdrawableAmount;
        }
    }

    function getWithdrawable() public view returns(uint256) {
        if (block.timestamp < startReleaseTime) {
            return 0;
        }

        uint256 num = (block.timestamp - startReleaseTime)/interval;
        num++;
        num = intervalAmount*num;

        num -= withdrawnAmount;
        uint256 b = c_erc20.balanceOf(address(this));
        if(num > b){
            num = b;
        }
        return num;
    }

    function userInfo() external view returns(uint256, uint256, uint256) {
        uint256 withdrawableAmount = getWithdrawable();
        return (startReleaseTime, withdrawableAmount, withdrawnAmount);
    }
}