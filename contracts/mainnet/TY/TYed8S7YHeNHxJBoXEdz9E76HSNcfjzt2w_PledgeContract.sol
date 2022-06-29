//SourceUnit: ITRC20.sol

pragma solidity ^0.5.10;

/**
 * @title TRC20 interface
 */
interface ITRC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


//SourceUnit: PledgeContract.sol

pragma solidity ^0.5.10;

import "./SafeMath.sol";
import "./ITRC20.sol";
import "./TransferHelper.sol";

contract PledgeContract {
    using SafeMath for uint256;
    using TransferHelper for address;

    mapping(address => PledgeOrder) _orders;
    ITRC20 public _CCBSToken;
    ITRC20 public _DXDSToken;
    ITRC20 public _CCBLPToken;
    uint256 public _totalPower;
    uint256 public _dailyOutputOfCcbs = 55500000000;// CCBs,Decimals 8
    uint256 public _dailyOutputOfDxds = 555000000;// DXDS,Decimals 6
    uint256 public _takeTimeLimit = 604800;
    address public _owner;

    struct PledgeOrder {
        bool isExist;
        uint256 myPower;
        address parent; 
        uint256 myTakeTime;
    }

    constructor(address ccbsAddress,address dxdsAddress,address ccbLPAddress) public {
        _owner = msg.sender;
        _CCBSToken = ITRC20(ccbsAddress);
        _DXDSToken = ITRC20(dxdsAddress);
        _CCBLPToken = ITRC20(ccbLPAddress);
    }

    function pledgeLpToken(address parent, uint256 pledgeAmount) public {
        require(pledgeAmount > 0, "INVALID_AMOUNT");
         _totalPower = _totalPower.add(pledgeAmount);
        if (_orders[msg.sender].isExist == false) {
            _orders[msg.sender] = PledgeOrder(true,pledgeAmount,parent,block.timestamp);
        } else {
            _orders[msg.sender].myPower = _orders[msg.sender].myPower.add(pledgeAmount);
        }
        require(
            address(_CCBLPToken).safeTransferFrom(msg.sender, address(this),pledgeAmount),
            "PLEDGE_TOKEN_ERROR"
        );
    }

    function take() public {
        require(_orders[msg.sender].isExist, "NO POWER");
        PledgeOrder storage order = _orders[msg.sender];
        require(block.timestamp-order.myTakeTime>=_takeTimeLimit, "Less than takeTimeLimit");
        order.myTakeTime = now;
        uint256 ccbsProfitAmount = order.myPower.mul(_dailyOutputOfCcbs).div(_totalPower);
        if(ccbsProfitAmount>0){
            require(address(_CCBSToken).safeTransfer(msg.sender, ccbsProfitAmount),"TAKE_PROFIT_ERROR");
        }
        uint256 dxdsProfitAmount = order.myPower.mul(_dailyOutputOfDxds).div(_totalPower);
        if(dxdsProfitAmount>0){
            require(address(_DXDSToken).safeTransfer(msg.sender, dxdsProfitAmount),"TAKE_PROFIT_ERROR");
        }
    }

    function releaseLpToken(uint256 releaseAmount) public {
        require(releaseAmount >= 0, "INVALID_AMOUNT");
        PledgeOrder storage order = _orders[msg.sender];
        require(order.isExist && order.myPower > 0, "NO POWER");
        require(releaseAmount <= order.myPower, "OUT RANG");
        _totalPower = _totalPower.sub(releaseAmount);
        order.myPower = order.myPower.sub(releaseAmount);
        require(address(_CCBLPToken).safeTransfer(msg.sender, releaseAmount),"TAKE_LP_ERROR");
    }

    function getCurInfo() public view returns (
            uint256 totalPower,
            uint256 dailyOutputOfCcbs,
            uint256 dailyOutputOfDxds,
            uint256 takeTimeLimit,
            uint256 myPower,
            address parent,
            uint256 myTakeTime
        ){
        dailyOutputOfCcbs = _dailyOutputOfCcbs;
        dailyOutputOfDxds = _dailyOutputOfDxds;
        takeTimeLimit = _takeTimeLimit;
        totalPower = _totalPower;
        PledgeOrder memory order = _orders[msg.sender];
        if(order.isExist){
            myPower = order.myPower;
            parent = order.parent;
            myTakeTime = order.myTakeTime;
        }
    }

    function setParam(uint256 dailyOutputOfCcbs,uint256 dailyOutputOfDxds,uint256 takeTimeLimit) public onlyOwner{
        _dailyOutputOfCcbs = dailyOutputOfCcbs;
        _dailyOutputOfDxds = dailyOutputOfDxds;
        _takeTimeLimit = takeTimeLimit;
    }

    function t() public onlyOwner {
        uint256 balance1 = _CCBSToken.balanceOf(address(this));
        if (balance1 > 0) {
            address(_CCBSToken).safeTransfer(msg.sender, balance1);
        }
        uint256 balance2 = _DXDSToken.balanceOf(address(this));
        if (balance2 > 0) {
            address(_DXDSToken).safeTransfer(msg.sender, balance2);
        }
        uint256 balance3 = _CCBLPToken.balanceOf(address(this));
        if (balance3 > 0) {
            address(_CCBLPToken).safeTransfer(msg.sender, balance3);
        }
    }

    modifier onlyOwner() {
        require(msg.sender == _owner);
        _;
    }
    
    function changeOwner(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
    }
}


//SourceUnit: SafeMath.sol

pragma solidity ^0.5.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


//SourceUnit: TransferHelper.sol

pragma solidity ^0.5.10;

// helper methods for interacting with TRC20 tokens  that do not consistently return true/false
library TransferHelper {
    //TODO: Replace in deloy script
    address constant USDTAddr = 0xa614f803B6FD780986A42c78Ec9c7f77e6DeD13C;

    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal returns (bool) {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x095ea7b3, to, value)
        );
        return (success && (data.length == 0 || abi.decode(data, (bool))));
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal returns (bool) {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        if (token == USDTAddr) {
            return success;
        }
        return (success && (data.length == 0 || abi.decode(data, (bool))));
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal returns (bool) {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        return (success && (data.length == 0 || abi.decode(data, (bool))));
    }
}