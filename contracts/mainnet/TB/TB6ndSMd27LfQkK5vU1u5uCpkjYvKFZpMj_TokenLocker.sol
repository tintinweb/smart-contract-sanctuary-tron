//SourceUnit: ITRC20.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface of the TRC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {TRC20Detailed}.
 */
interface ITRC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


//SourceUnit: Ownable.sol

pragma solidity ^0.5.0;

contract Ownable {
    address private _owner;

    constructor () internal {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
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


//SourceUnit: TokenLocker.sol

pragma solidity ^0.5.0;

import "./ITRC20.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
/*
* WNBA ??????????????????
* WNBA contract address :
*/
contract TokenLocker is Ownable{
    using SafeMath for uint256;
    // ???????????????
    address private _beneficiary;
    // TRC20??????
    ITRC20 private _token;
    // ??????????????????
    uint256 private _startTime;
    // ????????????
    uint256 private _interval;
    // ??????????????????
    uint256 private _eachRelease;
    // ????????????
    uint256 private _releaseAmount;
    // ????????????
    uint256 private _releaseTimes;
    // ????????????
    event TokenReleased(address beneficiary,uint256 amount);
    /**
    * @param token trc20 address    ????????????
    * @param beneficiary            ?????????
    * @param startTime              ??????????????????
    * @param beneficiary            ??????????????????
    * @param interval               ??????????????????
    * @param eachRelease            ??????????????????
    */
    constructor(ITRC20 token,address beneficiary,uint256 startTime,uint256 interval,uint256 eachRelease)public{
        _beneficiary = beneficiary;
        _token = token;
        _startTime = startTime;
        _interval = interval;
        _eachRelease = eachRelease;
    }
    // ?????????
    function beneficiary() public view returns (address) {
        return _beneficiary;
    }
    // ??????
    function token() public view returns (ITRC20){
        return _token;
    }
    // ??????
    function balance() public view returns (uint256){
        return token().balanceOf(address(this));
    }
    // ???????????????
    function releaseAmount() public view returns (uint256){
        return _releaseAmount;
    }
    // ???????????????
    function releaseTimes() public view returns (uint256){
        return _releaseTimes;
    }
    // ??????
    function release() public onlyOwner returns (uint256){
        // ?????????????????????????????????????????????amountTs
        // ????????????????????????
        if(block.timestamp <= _startTime){
            return 0;
        }else if(balance() <= 0){
            return 0;
        }
        uint256 _needReleaseIdx = (block.timestamp.sub(_startTime).div(_interval)).add(1);
        // ?????????????????????
        uint256 _needReleaseTotal = _needReleaseIdx.mul(_eachRelease);
        // ??????????????????
        uint256 _needReleaseAmount = _needReleaseTotal.sub(_releaseAmount);
        // ??????????????????????????????????????????
        if(_needReleaseAmount <= 0){
            return 0;
        }
        // ?????????????????????????????????????????????????????????
        if(_needReleaseAmount > balance()){
            _needReleaseAmount = balance();
        }
        // ??????????????????
        token().transfer(beneficiary(),_needReleaseAmount);
        // ????????????
        emit TokenReleased(beneficiary(),_needReleaseAmount);
        // ??????????????????
        _releaseAmount = _releaseAmount.add(_needReleaseAmount);
        // ??????????????????
        _releaseTimes = _releaseTimes.add(1);
        return _needReleaseAmount;
    }
}