//SourceUnit: TestRet.sol

pragma solidity ^0.5.4;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


contract Ownable {
    //address public owner;
    address payable public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}


contract TestRet is Ownable {
    using SafeMath for uint256;

    constructor() public {
        owner = msg.sender;
    }

    event Withdrawn(address indexed user, uint256 amount, uint _time);  

    function() external payable {
    }


    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }
     

    function transferPayout(address _receiver, uint _amount) internal {
        if (_amount > 0 && _receiver != address(0)) {
          uint contractBalance = address(this).balance;

            if (contractBalance > 0) {
                uint payout = _amount > contractBalance ? contractBalance : _amount;

                msg.sender.transfer(payout);
                emit Withdrawn(msg.sender, payout, now);
            }
        }
    }  
 
}