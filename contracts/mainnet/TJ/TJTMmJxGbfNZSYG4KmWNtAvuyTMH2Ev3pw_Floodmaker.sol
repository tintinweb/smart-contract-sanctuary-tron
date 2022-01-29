//SourceUnit: floodmaker.sol

pragma solidity 0.5.8;

contract Hourglass {
    function buy(address _referredBy) external payable returns (uint256);
    function exit() external;
    
    function reinvest() public {}
    function myTokens() public view returns(uint256) {}
    function myDividends(bool) public view returns(uint256) {}
}

contract Floodmaker {
    Hourglass D1VS;
    address public hourglassAddress;
    
    uint public mark;
    uint public timesFlooded;
    
    event FundsReceived(address _sender, uint _amount, uint _timestamp);
    event FloodTriggered(address _caller, uint _timestamp);
    
    constructor(address _hourglass) public {
        D1VS = Hourglass(_hourglass);
        mark = 10e18;
        hourglassAddress = _hourglass;
    }
    
    function () payable external {
        emit FundsReceived(msg.sender, msg.value, now);
    }
    
    function makerData() public view returns (uint _timesFlooded, uint _markToReach) {
        return (timesFlooded, mark);
    }
    
    function triggerFlood() public returns (bool _success) {
        if (D1VS.myTokens() > mark) {
            D1VS.exit();
            D1VS.buy.value(address(this).balance)(msg.sender);
            
            mark += ((mark / 100) * 50);
            timesFlooded += 1;
            
            emit FloodTriggered(msg.sender, now);
            return true;
        }
        return false;
    }
    
    function myTokens() public view returns(uint256) {
        return D1VS.myTokens();
    }
    
    function myDividends() public view returns(uint256) {
        return D1VS.myDividends(true);
    }
}