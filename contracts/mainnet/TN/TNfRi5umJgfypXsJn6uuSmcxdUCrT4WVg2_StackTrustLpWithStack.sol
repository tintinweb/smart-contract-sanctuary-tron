//SourceUnit: ITRC20.sol

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.0;

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
    function burnFrom(address sender, uint256 amount) external   returns (bool);
    function burn(uint256 amount) external  returns (bool);
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


//SourceUnit: InetDB.sol

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.0;

interface InetDB
{
    function setUserInfo(address user,uint idx,uint256 val) external;
    function subUserInfo(address user,uint idx,uint256 val) external;
    function addUserInfo(address user,uint idx,uint256 val) external;
    function getUserInfo(address user,uint idx) external view returns(uint256);
    function getParent(address user) external view returns (address);

}
 

//SourceUnit: Ownable.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


//SourceUnit: SafeMath.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.4.0;

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
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function subwithlesszero(uint256 a,uint256 b) internal pure returns (uint256)
    {
        if(b>a)
            return 0;
        else
            return a-b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
     *
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
        require(c / a == b, 'SafeMath: multiplication overflow');

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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}


//SourceUnit: StackTrustLpWithStack.sol

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.0;

import "./Ownable.sol";
import "./ITRC20.sol";
import "./TransferHelper.sol";
import "./SafeMath.sol";
import "./InetDB.sol";

contract StackTrustLpWithStack  is Ownable
{
    address _fcnaddress=0x7dD3835ffCc194356f5Ea5Cf12e45658972BAC6a;
    address _trxtrade=0xA2726afbeCbD8e936000ED684cEf5E2F5cf43008;
    address _trustaddress=0xd77Aef4B7752304d31Ee6Be4C068bD9Ba6d46c01;
    address _usdtaddress=0xa614f803B6FD780986A42c78Ec9c7f77e6DeD13C;
    address _trusttrade=0xEcbfd5c9d71951f9B5081db5995e4985f6486D31;

    using SafeMath for uint256;
    using TransferHelper for address;
    mapping(address=>address) _parentcache;
    mapping(address=>uint256) public _totalRewarded;
    mapping(address=>uint256) _userPower;
    mapping(address=>uint256) public _pendingUser;
    mapping(address=>uint256) public _taked;
    mapping(address=>uint256) public takeBackTime;
    mapping(address=>uint256) _userStackCount;
    mapping(address=>uint256) _dynamicPower;


    InetDB _netdb;
    uint256 _onecut;
    uint256  _oneblockreward;
 
    address _totalLpPower;
    address _feeowner;
    uint256 _lastuptime;
    uint256 _totalhash;
    uint16[8] _dcreditpct;

    constructor(address db)
    {
        _feeowner = msg.sender;
        _netdb=InetDB(db);
        _dcreditpct= [500,250,120,60,30,10,10,10];
        uint256 p= 48 * 1e18;
        _oneblockreward= p/ 86400;
    }
    
    function setOneBlockReward(uint256 rw) public  onlyOwner
    {
        _oneblockreward=rw;
    }

    function setFeeOwner(address user) public onlyOwner
    {
        _feeowner=user;
    }

    function getCanTakeBackTime(address user) public view returns(uint256)
    {
        if(takeBackTime[user] > block.timestamp)
            return takeBackTime[user] - block.timestamp;
        return 0;
    }

     function getTrustLpPower(uint256 amount) public view returns(uint256)
    {
        uint256 totalsupply = ITRC20(_trusttrade).totalSupply();
        uint256 totalusdt = ITRC20(_usdtaddress).balanceOf(_trusttrade);
        return amount.mul(2e18).mul(totalusdt).div(totalsupply).div(5e17);
    }

    function takeOutErrorTransfer(address tokenaddress,address target,uint256 amount) public onlyOwner
    {
        ITRC20(tokenaddress).transfer(target,amount);
    }

    function getPendingCoin(address user) public view returns(uint256)
    {
        return _getPendingCoin(user,getOneShareNowA());
    }

    function _getPendingCoin(address user,uint256 oneshare) public view returns(uint256)
    {
 
        uint256 selfhash=getUserSelfHash(user);
        if(selfhash==0)
            return _pendingUser[user];

         selfhash += getUserTeamHash(user);
        if(selfhash > 0)
        {
            uint256 cashed=_taked[user];
            uint256 newp =0;
            if(oneshare > cashed)
               newp = selfhash.mul(oneshare.subwithlesszero(cashed));

            return _pendingUser[user].add(newp);
        }
        else
        {
            return _pendingUser[user];
        }
    }

    function getuserStackCount(address user) public view returns(uint256)
    {
        return _userStackCount[user];
    }

    function withDrawCredit() public 
    {
        address user=msg.sender;
        uint256 oneshare=getOneShareNowA();
        uint256 pending = _getPendingCoin(user,oneshare);
        if(pending > 0)
        {
            _taked[user]= oneshare;
            _pendingUser[user]=0;
            uint256 fee=pending.div(100);
            _trustaddress.safeTransfer(user, pending.sub(fee));
            _trustaddress.safeTransfer(_feeowner, fee);
        }
    }

    function getUserSelfHash(address user) public view returns(uint256)
    {
        return _userPower[user];
    }

    function getUserTeamHash(address user ) public view returns(uint256)
    {
        return _dynamicPower[user];
    }

    function getTotalHash() public view returns(uint256)
    {
        return _totalhash;
    }

    function getOneShareNowA() public view returns(uint256)
    {
        uint256 oneshare=_onecut;
         
         if(_lastuptime>0 && _totalhash>0)
         {
            if(block.timestamp >= _lastuptime)
            {
                oneshare= oneshare.add(_oneblockreward.div(_totalhash).mul(block.timestamp.sub(_lastuptime)));
            }
         }
         return oneshare;
    }

    function fixUserHash(address user,uint256 ahash,bool add) public onlyOwner
    {
        uint256 oneshare=getOneShareNowA();
        _userHashChanged(user,ahash,add,oneshare);
        LogCheckPoint(ahash,add,oneshare);
    }

    function fixTeamHash(address user,uint256 ahash,bool add) public onlyOwner
    {
        uint256 oneshare=getOneShareNowA();
        _teamHashChanged(user,ahash,add,oneshare);
        LogCheckPoint(ahash,add,oneshare);
    }

    function _teamHashChanged(address user,uint256 ahash,bool add,uint256 oneshare) private
    {
 
        if(getUserSelfHash(user) > 0)
            _pendingUser[user] = _getPendingCoin(user,oneshare);
 
            if(add)
            {
                _dynamicPower[user] = _dynamicPower[user].add(ahash);
            }else
            {
                _dynamicPower[user] = _dynamicPower[user].subwithlesszero(ahash);
            }

        _taked[user] = oneshare;
    }

    function _userHashChanged(address user,uint256 ahash,bool add,uint256 oneshare) private
    {
 
        if(_userPower[user].add(_dynamicPower[user]) > 0)
            _pendingUser[user] = _getPendingCoin(user,oneshare);
         
        if(add)
            {
                _userPower[user] = _userPower[user].add(ahash);
            }
            else
            {
                _userPower[user] = _userPower[user].subwithlesszero(ahash);
            }
        _taked[user] = oneshare;
    }

    function LogCheckPoint(uint256 phash,bool add,uint256 oneshare) private
    {
        if(block.timestamp > _lastuptime)
        {
            _onecut=oneshare;
            _lastuptime=block.timestamp;
        }
        
        if (add) {
            _totalhash = _totalhash.add(phash);
        } else {
            _totalhash = _totalhash.subwithlesszero(phash);
        }
    }
  
    function stack(uint256 amount) public
    {
        address user= msg.sender;
 
        uint256 oneshare=getOneShareNowA();
        _trusttrade.safeTransferFrom(msg.sender, address(this), amount);
        _userStackCount[user] = _userStackCount[user].add(amount);
        uint256 ahash= getTrustLpPower(amount);
        _userHashChanged(user,ahash,true,oneshare);
        uint256 totaldiff = ahash;
        address parent=user;
        for(uint i=0;i<8;i++)
        {
             parent = _MappingParent(parent);
            if(parent == owner() || parent == address(2)|| parent==address(0))
                break;

             if(getUserSelfHash(parent) >=2e8)
                 {
                     uint256 givehash = ahash.div(2).mul(_dcreditpct[i]).div(1000);
                    _teamHashChanged(parent, givehash, true,oneshare);
                    totaldiff=totaldiff.add(givehash);
                 }
        }
        takeBackTime[user] = block.timestamp + (90 * 86400);
        LogCheckPoint(totaldiff, true,oneshare);
    }

    function _MappingParent(address user) internal returns(address)
    {
        address parent=_parentcache[user];
        if(parent == address(0))
        {
            parent= _netdb.getParent(user);
            _parentcache[user]=parent;
        }

        return parent;
    }

    function TakeBackTrustLp(uint256 pct) public
    {
        
        address user= msg.sender;
        require(block.timestamp >=takeBackTime[user],"Must stack 90days");
        uint256 tackbackcount = _userStackCount[user].mul(pct).div(10000);
        uint256 dechash = _userPower[user].mul(pct).div(10000);
        uint256 oneshare=getOneShareNowA();
        _userStackCount[user]=_userStackCount[user].sub(tackbackcount);
        _userHashChanged(user, dechash, false,oneshare);
        uint256 totaldiff = dechash;
        address parent=user;
        for(uint i=0;i<8;i++)
        {
            parent = _MappingParent(parent);
            if(parent == owner() || parent == address(2)|| parent==address(0))
                break;
 
            uint256 givehash = dechash.div(2).mul(_dcreditpct[i]).div(1000);
            uint256 parentpower = getUserTeamHash(parent);
            if(parentpower < givehash)
                givehash=parentpower;
            _teamHashChanged(parent, givehash, false,oneshare);
            totaldiff=totaldiff.add(givehash);
        }

        uint256 fee= tackbackcount.div(100);
        _trusttrade.safeTransfer(user, tackbackcount.sub(fee));
        _trusttrade.safeTransfer(_feeowner, fee);
        LogCheckPoint(totaldiff, false,oneshare);
    }

}

//SourceUnit: TransferHelper.sol

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.5.0;

// helper methods for interacting with BEP20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferBNB(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper: BNB_TRANSFER_FAILED');
    }
}