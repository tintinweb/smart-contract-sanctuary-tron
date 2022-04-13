//SourceUnit: LockLGT2.sol

pragma solidity 0.6.12;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address _to, uint _value) external returns (bool);
    function transferFrom(address _from, address _to, uint _value) external returns (bool);
}

contract LockLGT2 {

    IERC20 public c_erc20;
   
    address public fundAddress;
    uint256 public startReleaseTime = 1651680000; 
    
    uint256 public interval = 30*24*60*60;
    uint256 public intervalAmount = 17900000000;
    uint256 public withdrawnAmount;
    
    constructor(IERC20 _erc20, address _fund) public {
        c_erc20 = _erc20;
        fundAddress = _fund;
    }

    function getRelease() external {
        require(block.timestamp > startReleaseTime, "release time error");
        uint256 num = (block.timestamp - startReleaseTime)/interval;
        num++;
        
        num = intervalAmount*num;

        require(num > withdrawnAmount, "no release");
        num -= withdrawnAmount;

        uint256 b = c_erc20.balanceOf(address(this));
        if(num > b){
            num = b;
        }
        c_erc20.transfer(fundAddress, num);
        withdrawnAmount += num;
    }

    function userInfo() external view returns(uint256, uint256) {
        if (block.timestamp <= startReleaseTime) {
            return (0, withdrawnAmount);
        }
        uint256 num = (block.timestamp - startReleaseTime)/interval;
        num++;
        num = intervalAmount*num;
        num -= withdrawnAmount;
        uint256 b = c_erc20.balanceOf(address(this));
        if(num > b){
            num = b;
        }
        return (num, withdrawnAmount);
    }
}