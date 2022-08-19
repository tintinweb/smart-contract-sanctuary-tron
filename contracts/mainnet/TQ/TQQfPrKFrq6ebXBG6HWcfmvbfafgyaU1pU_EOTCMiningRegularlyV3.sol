//SourceUnit: Context.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


//SourceUnit: EOTCMiningRegularlyStorageV3.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract EOTCMiningRegularlyStorageV3 {

    // 投资天数(年)
    // TODO 记录一年12月
    uint256 internal constant year = 12;

    // 释放时间总长(月)
    // TODO 记录1/30天时间戳
    uint256 internal constant thirtyDaysTime = 2592000;
    uint256 internal constant oneDayTime = 86400;

    // 投资天数(月)
    uint256[] internal stage;

    // 周期-年化率映射
    mapping(uint256 => uint256) public investYearRate;

    struct Pledge {
        uint256 id;         // 订单ID
        uint256 cycle;      // 质押周期
        uint256 startTime;  // 质押时间
        uint256 amount;     // 质押数量
        uint256 reward;     // 质押收获
        uint256 isStop;     // 质押到期
    }

    // 质押记录
    mapping(address => mapping(uint256 => Pledge[])) internal _pledge;

    struct TotalInterest {
        uint256 amount;     // 质押数量
        uint256 interest;   // 应计利息
    }
    // 总质押本金、利息
    mapping(uint256 => TotalInterest) public accrueInterest;

    // 总质押利息
    uint256 public totalInterest;

    // 总EOTC质押记录
    uint256 public totalEOTC;

    // 总利息储备金
    uint256 public totalReserves;

    // 总收获本金
    uint256 public totalAmount;

    // 总奖励
    uint256 public totalReward;
}


//SourceUnit: EOTCMiningRegularlyV3.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./IERC20.sol";
import "./SafeMath.sol";
import "./EOTCMiningRegularlyStorageV3.sol";


contract EOTCMiningRegularlyV3 is Ownable, EOTCMiningRegularlyStorageV3{

    // 铸造Token
    event MintedToken(address account, uint256 amount, uint256 month, uint256 startTime);
    // 存款质押
    event Deposit(address account, uint256 amount, uint256 month, uint256 startTime);
    // 添加储备金
    event AddReserves(address token, address from, address to, uint256 value);
    // 收获
    event Reward(address account, uint256 deposit, uint256 reward);
    // 移除周期年化率
    event RemoveInvestYearRate(uint256 cycle, uint256 yearRate);
    // 设置周期年化率
    event SetInvestYearRate(uint256 cycle, uint256 yearRate);

    address public immutable _EOTC;

    using SafeMath for uint256;

    // 构造函数
    constructor(address _eotc) public {
        _EOTC = _eotc;
    }

    // 查询当前合约EOTC余额
    function eotc() public view returns(uint256){
        return IERC20(_EOTC).balanceOf(address(this));
    }

    // 设置投资年化率
    function setInvestYearRate(uint256 cycle, uint256 yearRate) external onlyOwner {
        require(yearRate > 0, "Annualized rate is less than zero");
        investYearRate[cycle] = yearRate;
        stage.push(cycle);
        emit SetInvestYearRate(cycle, yearRate);
    }

    // 移除投资年化率
    function removeInvestYearRate(uint256 cycle) external onlyOwner {
        uint256 yearRate = investYearRate[cycle];
        require(yearRate > 0, "Investment cycle does not exist");
        delete investYearRate[cycle];

        // 移除周期数组
        uint len = stage.length;
        uint index = len;
        for (uint i = 0; i < stage.length; i++) {
            if (stage[i] == cycle) {
                index = i;
                break;
            }
        }
        stage[index] = stage[len - 1];
        stage.pop();
        emit RemoveInvestYearRate(cycle, yearRate);
    }


    function invest(address account, uint256 amount, uint256 investType) internal returns(uint256){
        // 校验周期
        uint256 rate = investYearRate[investType];
        require(rate > 0, "Wrong type of investment");
        // 计算利息
        uint256 multiple = investType.mul(1e6).div(year);
        rate = rate.mul(multiple).div(1e6);
        uint256 profit = amount.mul(rate).div(1e6);
        // 校验储备金是否充足
        require(totalInterest + profit <= totalReserves, "Insufficient liquidity reserves");

        TotalInterest storage ti = accrueInterest[investType];
        ti.amount += amount;
        ti.interest += profit;

        totalInterest += profit;

        // 保存质押记录
        uint256 accrueInterestTime = block.timestamp - oneDayTime;
        Pledge[] storage order = _pledge[account][investType];
        uint256 length = order.length;
        Pledge memory vars;
        vars.id = length += 1;
        vars.cycle = investType;
        vars.startTime = accrueInterestTime;
        vars.amount = amount;
        vars.reward = profit;
        vars.isStop = 0;

        order.push(vars);
        return accrueInterestTime;
    }

    // 铸造凭证
    function minted(address account, uint256 amount, uint256 investType) external onlyOwner {
        require(account != address(0), "Cannot be zero address");
        // 质押记录
        uint256 startTime = invest(account, amount, investType);
        // 质押转账
        IERC20(_EOTC).transferFrom(msg.sender, address(this), amount);
        totalEOTC += amount;
        emit MintedToken(account, amount, investType, startTime);
    }

    // 批量铸造凭证
    function mintedBatch(address[] memory account, uint256[] memory amount, uint256 investType) external onlyOwner{
        require(account.length > 0, "Arrays length mismatch");

        uint256 sum;
        for (uint j = 0; j < amount.length; j++) {
            sum += amount[j];
        }
        uint256 balance = IERC20(_EOTC).balanceOf(msg.sender);
        require(balance >= sum, "Insufficient balance");

        for(uint i = 0; i < account.length; i++){
            uint256 startTime = invest(account[i], amount[i], investType);

            emit MintedToken(account[i], amount[i], investType, startTime);
        }
        IERC20(_EOTC).transferFrom(msg.sender, address(this), sum);
        totalEOTC += sum;
    }

    // 减少储备
    /*function reduceReserves(uint256 value) external onlyOwner{
        if(value <= 0){
            value = IERC20(_EOTC).balanceOf(address(this));
        }
        IERC20(_EOTC).transfer(owner(), value);
        emit ReduceReserves(_EOTC, address(this), owner(), value);
    }*/

    // 添加储备
    function addReserves(uint256 value) external onlyOwner{
        require(value > 0, "Cannot be zero");

        IERC20(_EOTC).transferFrom(msg.sender, address(this), value);
        totalReserves += value;
        emit AddReserves(_EOTC, address(this), msg.sender, value);
    }

    // 存款质押
    function deposit(uint256 amount, uint256 investType) external {
        require(amount > 0, "Must be greater than zero");

        uint256 startTime = invest(msg.sender, amount, investType);
        IERC20(_EOTC).transferFrom(msg.sender, address(this), amount);

        totalEOTC += amount;
        emit Deposit(msg.sender, amount, investType, startTime);
    }

    // 收获
    function reward(uint256 investType, uint256 orderId) external {
        Pledge[] memory orders = _pledge[msg.sender][investType];
        uint256 index = orderId - 1;
        uint256 amount = orders[index].amount;
        uint256 rewards = orders[index].reward;
        require(amount > 0, "Order does not exist");
        require(orders[index].isStop == 0, "The order has expired and redeemed");

        // 当前时间
        uint256 currentTime = block.timestamp;
        // 校验是否到期
        uint256 time = thirtyDaysTime.mul(investType);
        uint256 maturityTime = orders[index].startTime.add(time);
        require(currentTime >= maturityTime, "The current order pledge has not expired");

        // 校验质押奖励是否充足
        uint256 actualReward = amount + rewards;
        uint256 eotcAmount = eotc();
        require(actualReward <= eotcAmount, "The deposit amount does not match the deposit amount");

        // 领取 收获 = 本金 + 利息
        IERC20(_EOTC).transfer(msg.sender, actualReward);

        totalInterest -= rewards;
        totalReserves -= rewards;
        totalAmount += amount;
        totalReward += rewards;

        TotalInterest storage ti = accrueInterest[investType];
        ti.amount -= amount;
        ti.interest -= rewards;
        Pledge[] storage pl = _pledge[msg.sender][investType];
        pl[index].isStop = 1;
        emit Reward(msg.sender, amount, rewards);
    }

    // 重塑利润
    function replantSeeds(uint256 investType, uint256 orderId) external {
        Pledge[] memory orders = _pledge[msg.sender][investType];
        uint256 index = orderId - 1;
        uint256 amount = orders[index].amount;
        uint256 rewards = orders[index].reward;
        require(amount > 0, "Order does not exist");
        require(orders[index].isStop == 0, "The order has expired and redeemed");

        // 当前时间
        uint256 currentTime = block.timestamp;
        // 校验是否到期
        uint256 time = thirtyDaysTime.mul(investType);
        uint256 maturityTime = orders[index].startTime.add(time);
        require(currentTime >= maturityTime, "The current order pledge has not expired");

        // 领取
        totalInterest -= rewards;
        totalReserves -= rewards;
        totalAmount += amount;
        totalReward += rewards;

        TotalInterest storage ti = accrueInterest[investType];
        ti.amount -= amount;
        ti.interest -= rewards;

        Pledge[] storage pl = _pledge[msg.sender][investType];
        pl[index].isStop = 1;
        emit Reward(msg.sender, amount, rewards);

        // 二次质押
        uint256 actualReward = amount + rewards;
        uint256 startTime = invest(msg.sender, actualReward, investType);

        totalEOTC += actualReward;
        emit Deposit(msg.sender, actualReward, investType, startTime);
    }

    // 预估收益1
    function depositEstimateReward(uint256 amount, uint256 investType) external view returns(uint256, uint256){
        uint256 rate = investYearRate[investType];
        require(rate > 0, "Wrong type of investment");
        // 总收益
        uint256 multiple = investType.mul(1e6).div(year);
        rate = rate.mul(multiple).div(1e6);
        uint256 totalIncome = amount.mul(rate).div(1e6);

        // 计算日收益
        uint256 totalDay = investType.mul(30);
        uint256 dailyIncome = totalIncome.div(totalDay);
        return (totalIncome, dailyIncome);
    }

    // 查询单周期质押到期订单
    function expiresOrders(address account, uint256 investType) external view returns(uint256, uint256[][] memory){
        Pledge[] memory orders = _pledge[account][investType];

        uint256 length = orders.length;
        Pledge[] memory pl = new Pledge[](length);
        uint256 currentTime = block.timestamp;
        uint256 index;
        if(orders.length > 0){
            uint256 time = thirtyDaysTime.mul(investType);
            for(uint i = 0; i < orders.length; i++){
                if(orders[i].isStop == 0){
                    uint256 current = orders[i].startTime.add(time);
                    if(currentTime >= current){
                        pl[index] = orders[i];
                        index += 1;
                    }
                }
            }
        }

        uint256 len;
        uint256[][] memory order = new uint256[][](index);
        for (uint x = 0; x < pl.length; x++){
            if (pl[x].amount > 0){
                uint256[] memory list = new uint256[](6);
                list[0] = pl[x].id;
                list[1] = pl[x].cycle;
                list[2] = pl[x].startTime;
                list[3] = pl[x].amount;
                list[4] = pl[x].reward;
                list[5] = pl[x].isStop;
                order[len] = list;
                len += 1;
            }
        }
        return (currentTime, order);
    }

    // 查询全部质押到期订单
    function allExpiresOrders(address account) external view returns(uint256, uint256[][] memory){

        uint256 length;
        for(uint y = 0; y < stage.length; y++){
            Pledge[] memory pl = _pledge[account][stage[y]];
            length += pl.length;
        }

        Pledge[] memory pledges = new Pledge[](length);
        uint256 currentTime = block.timestamp;
        uint256 index;
        uint256 time;
        uint256 current;
        for(uint i = 0; i < stage.length; i++){
            time = thirtyDaysTime.mul(stage[i]);
            Pledge[] memory order = _pledge[account][stage[i]];
            for(uint j = 0; j < order.length; j++){
                if(order[j].isStop == 0){
                    current = order[j].startTime.add(time);
                    if(currentTime >= current){
                        pledges[index] = order[j];
                        index += 1;
                    }
                }
            }
        }

        uint256 len;
        uint256[][] memory orders = new uint256[][](index);
        for (uint x = 0; x < pledges.length; x++){
            if (pledges[x].amount > 0){
                uint256[] memory list = new uint256[](6);
                list[0] = pledges[x].id;
                list[1] = pledges[x].cycle;
                list[2] = pledges[x].startTime;
                list[3] = pledges[x].amount;
                list[4] = pledges[x].reward;
                list[5] = pledges[x].isStop;
                orders[len] = list;
                len += 1;
            }
        }
        return (currentTime, orders);
    }

    // 获取项目方需要划转的利息
    function estimateInterest() external view returns(uint256, uint256){
        uint256 total;
        uint256 income;
        for (uint i = 0; i < stage.length; i++) {
            total += accrueInterest[stage[i]].amount;
            income += accrueInterest[stage[i]].interest;
        }
        // 本金，利息
        return (total, income);
    }

    // 用户质押记录
    function pledge(address account, uint256 investType) external view returns(uint256, uint256[][] memory){
        uint256 currentTime = block.timestamp;
        Pledge[] memory pl = _pledge[account][investType];

        uint256[][] memory two = new uint256[][](pl.length);
        for (uint i = 0; i < pl.length; i++){
            uint256[] memory list = new uint256[](6);
            list[0] = pl[i].id;
            list[1] = pl[i].cycle;
            list[2] = pl[i].startTime;
            list[3] = pl[i].amount;
            list[4] = pl[i].reward;
            list[5] = pl[i].isStop;
            two[i] = list;
        }
        return (currentTime, two);
    }

    // 全部质押记录
    function allPledge(address account) external view returns(uint256, uint256[][] memory){
        uint256 currentTime = block.timestamp;

        uint256 length;
        for (uint y = 0; y < stage.length; y++) {
            Pledge[] memory pl = _pledge[account][stage[y]];
            length += pl.length;
        }

        uint256[][] memory two = new uint256[][](length);
        uint256 index;
        for (uint i = 0; i < stage.length; i++) {
            Pledge[] memory pledges = _pledge[account][stage[i]];
            for(uint j = 0; j < pledges.length; j++){
                uint256[] memory list = new uint256[](6);
                list[0] = pledges[j].id;
                list[1] = pledges[j].cycle;
                list[2] = pledges[j].startTime;
                list[3] = pledges[j].amount;
                list[4] = pledges[j].reward;
                list[5] = pledges[j].isStop;
                two[index] = list;
                index += 1;
            }
        }
        return (currentTime, two);
    }

    // 质押数量
    function pledgeAmount(address account) external view returns(uint256, uint256[] memory){
        uint256 amount;
        uint256[] memory list = new uint256[](stage.length);
        for (uint i = 0; i < stage.length; i++) {
            Pledge[] memory pl = _pledge[account][stage[i]];
            uint256 cycleAmount;
            for (uint j = 0; j < pl.length; j++) {
                if(pl[j].isStop == 0){
                    amount += pl[j].amount;
                    cycleAmount += pl[j].amount;
                }
            }
            list[i] = cycleAmount;
        }
        return (amount, list);
    }

    // 全部投资年化率
    function allYearRate() external view returns(uint256[][] memory){
        uint256 length = stage.length;
        uint256[][] memory two = new uint256[][](length);
        for (uint i = 0; i < stage.length; i++) {
            uint256[] memory list = new uint256[](2);
            list[0] = stage[i];
            list[1] = investYearRate[stage[i]];
            two[i] = list;
        }
        return two;
    }

}


//SourceUnit: IERC20.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}


//SourceUnit: Ownable.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "./Context.sol";

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


//SourceUnit: SafeMath.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

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
        return a + b;
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
        return a - b;
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
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
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
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
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
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
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
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
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
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}