//SourceUnit: Tronwage.sol


// File: contracts/libraries/Utils.sol

/**
 * Math liberary for decimal operation
 *
 * Created Date: 5/22/2021
 * Author: Tronwage
 */

pragma solidity 0.5.10;

contract Utils {
    uint256 internal unique_id_counter = 0;

    function getUniqueID() internal returns (uint256) {
        return unique_id_counter += 1;
    }
}

// File: contracts/libraries/openzeppelin/math/SafeMath.sol

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
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
        return div(a, b, "SafeMath: division by zero");
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
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
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
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
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
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
// File: contracts/libraries/UDMath.sol

/**
 * Math liberary for decimal operation
 *
 * Created Date: 5/18/2021
 * Author: Tronwage
 */

pragma solidity 0.5.10;


library UDMath {
    using SafeMath for uint256;

    uint256 public constant UNIT = 1e18;

    function unit() external pure returns (uint256) {
        return UNIT;
    }

    function div(uint256 x, uint256 y) internal pure returns (uint256) {
        return SafeMath.div(x.mul(UNIT), y);
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256) {
        return x.mul(y) / UNIT;
    }
}
// File: contracts/Tronwage.sol

/**
 * Tronwage Smart Contract
 * 
 * Created Date: 4/22/2021
 * Author: Tronwage
 */
 
pragma solidity 0.5.10;



contract Tronwage is Utils {
    // constants and variables
    uint256 constant SUN = 1e6; // 1000000
    uint256 constant MATH_BASE_UNIT = 1e18; // UDMath.unit();
    uint256 constant SECONDS_IN_DAY = 864e20; // 86400 * MATH_BASE_UNIT
    uint256 internal STAKE_MIN_AMOUNT = 1e8; // 100 TRX
    uint256 internal STAKE_MAX_AMOUNT = 1e11; // 100,000 TRX
    uint256 constant STAKE_FEE = 3; // 3%
    uint256 constant WITHDRAW_FEE = 10; // 10%
    uint256 constant REFERRAL_PERCENT = 2; // 2%
    mapping(uint8 => uint256) internal stake_durations;
    mapping(uint8 => uint256) internal stake_percents;
    mapping(address => bool) internal locked;
    address internal admin_address;
    uint256 internal tw_earn_balance;
    uint256 internal current_stake_balance; // total TRX users stake in this contract
    uint256 internal total_trx_deposited;
    uint256 internal total_trx_withdrawn;
    
    struct StakeBalance {
        address user;
        uint256 amount; // user's unsettled amount after stake is due
    }
    
    mapping(uint256 => StakeBalance) internal stake_queues; // FIFO data structure that hold unsettled amount
    uint256 internal stake_queue_first = 1;
    uint256 internal stake_queue_last = 0;
    
    struct UserAccount {
        uint256 balance; // user's available TRX
        uint256 remaining_earn; // unclaimed TRX
        uint256 total_deposit; // total TRX deposited to this account
        uint256 total_withdraw; // total TRX withdrawn from this account
        uint256 referral_count; // number of users you referred. 
        address referred_by; // the address of the user that referred you
        bool no_referral; // if set to true you can't be referred
    }
    
    // users' account
    mapping(address => UserAccount) internal accounts;
    
    struct Stake {
        uint256 id;
        bool cap; // capitalisation
        uint256 staked;
        uint256 total_earn;
        uint256 start_time;
        uint256 due_time;
        uint256 prev_claim_time;
        uint256 next_claim_time; // claim happens every 24 hours if cap is not set.
    }
    
    // users' list of active stack
    mapping(address => Stake[]) internal userStakes;
    
    // event that will be fired when some state changed
    event AmountStaked(address user, uint8 package, bool cap, uint256 amount, uint256 fee);
    event Deposited(address user, uint256 amount);
    event Withdrawn(address user, uint256 amount, uint256 fee);
    
    // give access to administrator
    modifier onlyAdmin() {
        require(
            admin_address == msg.sender, 
            "Access denied."
        );
        _;
    }
    
    // this modifier validate user's stake min and max amount
    modifier validateStakeAmount(uint256 amount) {
        require(
            amount >= STAKE_MIN_AMOUNT && amount <= STAKE_MAX_AMOUNT, 
            "Amount is not within staking allowed range."
        );
        _;
    }
    
    // check if user deposited amount is not zero
    modifier depositNotZero() {
        require(
            msg.value > 0, 
            "Amount can't be deposited." 
        );
        _;
    }
    
    // check if user have such amount available
    modifier isAmountAvailable(uint256 amount) {
        require(
            amount <= accounts[msg.sender].balance && amount > 0, 
            "Your balance is insufficient."
        );
        _;
    }
    
    constructor() public {
        admin_address = msg.sender;

        // initialise stake duration map
        stake_durations[1] = 14e18; // 14 days * MATH_BASE_UNIT
        stake_durations[2] = 21e18; // 21 days * MATH_BASE_UNIT
        stake_durations[3] = 28e18; // 28 days * MATH_BASE_UNIT
        stake_durations[4] = 35e18; // 35 days * MATH_BASE_UNIT

        // initialise stake percentage map
        stake_percents[1] = 5e18; // 5% * MATH_BASE_UNIT
        stake_percents[2] = 75e17; // 7.5% * MATH_BASE_UNIT
        stake_percents[3] = 10e18; // 10% * MATH_BASE_UNIT
        stake_percents[4] = 125e17; // 12.5% * MATH_BASE_UNIT
    }
    
    function() external payable {
        // donate to the community
        require(msg.value > 0);
        current_stake_balance += msg.value;
    }

    // check if queue is empty
    function stakeIsEmpty() internal view returns (bool) {
        return stake_queue_last < stake_queue_first;
    }
    
    // add stake balance to back of the queue
    function stakeEnqueue(address user, uint256 balance) internal {
        stake_queue_last += 1;
        stake_queues[stake_queue_last].user = user;
        stake_queues[stake_queue_last].amount = balance;
    }

    // remove the head of the queue
    function stakeRemove() internal {
        // check if queue is not empty
        if (stake_queue_last >= stake_queue_first) {
            delete stake_queues[stake_queue_first];
            stake_queue_first += 1;
        }
    }
    
    /**
     * @dev This function calculate total TRX user can earn by staking 
     * for a period of time. 
     *
     * @param amount Total TRX (in sun unit) user want to stake.
     * @param percent Earn percent everyday (unit in 1e18, e.g 1 percent is equal to 1e18)
     * @param duration Stake duration (unit in 1e18)
     * @param cap Value is either 1.5 or 1 (unit in 1e18, e.g 1.5 is equal to 15e17)
     * @return uint256 Unit is sun.
     */
    function calcTotalEarn(
        uint256 amount, 
        uint256 percent, 
        uint256 duration, 
        uint256 cap
    ) internal pure returns (uint256) {
        uint256 coefficient = 5e15; // 0.005
        uint256 map_amount = UDMath.div(amount, 1e10); // amount / 10000
        uint256 rd_amount = UDMath.mul(amount, UDMath.mul(coefficient, UDMath.mul(map_amount, map_amount))); // amount * x**2
        uint256 profit = UDMath.mul(UDMath.mul(UDMath.mul(amount, UDMath.div(percent, 1e20)), duration), cap);
        return profit - rd_amount;
    }
    
    /**
     * @dev Get total amount deposited into this contract. 
     *
     * @return uint256. 
     */
    function getTotalDeposit() external view returns (uint256) {
        return total_trx_deposited;
    }
    
    /**
     * @dev Get total amount withdrawn from this contract. 
     *
     * @return uint256.
     */
    function getTotalWithdraw() external view returns (uint256) {
        return total_trx_withdrawn;
    }

    /**
     * @dev Check if user can be referred or not. 
     *
     * @return bool. 
     */
    function getUserReferralState() external view returns(bool) {
        return accounts[msg.sender].no_referral;
    }
    
    /**
     * @dev Link user to there referral.
     *
     * @param referral The address of the referral. 
     */
    function setUserReferral(address referral) external {
        UserAccount storage account = accounts[msg.sender];
        
        // check if user has been referred or can't be reffered 
        require(!account.no_referral);
        
        // check if user is referring itself
        require(msg.sender != referral);
        
        // check if referral exist
        require(accounts[referral].no_referral);
        
        // increment referral counter
        accounts[referral].referral_count += 1;
        
        // link user to their referral
        account.referred_by = referral;
        account.no_referral = true; // set to true so that user can't be referred again
    }
    
    /**
     * @dev User is not referred by anyone. 
     */
    function setUserNoReferral() external {
        accounts[msg.sender].no_referral = true;
    }

    /**
     * @dev Get user's stake. 
     *
     * @param stake_id ID of user's active stake.
     * @return (uint256, uint256, uint256, uint256, uint256, uint256, uint256). 
     */
    function getUserStake(uint256 stake_id) 
        external 
        view 
        returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256) 
    {
        Stake[] storage user_stakes = userStakes[msg.sender];
        bool found = false;
        uint256 i = 0;

        // find the stake
        for (; i < user_stakes.length; i++) {
            if (user_stakes[i].id == stake_id) {
                found = true;
                break; // exit the loop
            }
        }

        // stake found
        if (found) {
            return (
                user_stakes[i].cap ? 1 : 0,
                user_stakes[i].staked,
                user_stakes[i].total_earn,
                user_stakes[i].start_time,
                user_stakes[i].due_time,
                user_stakes[i].prev_claim_time,
                user_stakes[i].next_claim_time
            );
        }

        // stake not found
        return (0, 0, 0, 0, 0, 0, 0);
    }
    
    /**
     * @dev Get user's stake list. 
     *
     * @return uint256[][]. 
     */
    function getUserStakeList() external view returns (uint256[8][] memory) {
        Stake[] storage user_stakes = userStakes[msg.sender];
        uint256[8][] memory stake_list = new uint256[8][](user_stakes.length);

        // populate the array
        for (uint256 i = 0; i < user_stakes.length; i++) {
            stake_list[i][0] = user_stakes[i].id;
            stake_list[i][1] = uint256(user_stakes[i].cap ? 1 : 0);
            stake_list[i][2] = user_stakes[i].staked;
            stake_list[i][3] = user_stakes[i].total_earn;
            stake_list[i][4] = user_stakes[i].start_time;
            stake_list[i][5] = user_stakes[i].due_time;
            stake_list[i][6] = user_stakes[i].prev_claim_time;
            stake_list[i][7] = user_stakes[i].next_claim_time;
        }

        return stake_list;
    }
    
    /**
     * @dev Get user's account information. 
     *
     * @return (uint256, uint256, uint256, uint256, uint256). 
     */
    function getUserAccountInfo() 
        external 
        view 
        returns (uint256, uint256, uint256, uint256, uint256) 
    {
        return (
            accounts[msg.sender].balance, 
            accounts[msg.sender].remaining_earn, 
            accounts[msg.sender].total_deposit, 
            accounts[msg.sender].total_withdraw, 
            accounts[msg.sender].referral_count
        );
    }
    
    /**
     * @dev Get user's account balance. 
     *
     * @return uint256. 
     */
    function getUserAccountBalance() external view returns (uint256) {
        return accounts[msg.sender].balance;
    }
    
    /**
     * @dev Get Tronwage earn balance. 
     *
     * @return uint256. 
     */
    function getTWEarnBalance() 
        external 
        view 
        onlyAdmin 
        returns (uint256) 
    {
        return tw_earn_balance;
    }

    /**
     * @dev Get Tronwage current stake balance. 
     *
     * @return uint256. 
     */
    function getCurrentStakeBalance() 
        external 
        view 
        onlyAdmin 
        returns (uint256) 
    {
        return current_stake_balance;
    }

    /**
     * @dev Get minimum stake amount. 
     *
     * @return uint256. 
     */
    function getMinStakeAmount() external view returns (uint256) {
        return STAKE_MIN_AMOUNT;
    }

    /**
     * @dev Get maximum stake amount. 
     *
     * @return uint256. 
     */
    function getMaxStakeAmount() external view returns (uint256) {
        return STAKE_MAX_AMOUNT;
    }
    
    /**
     * @dev This function is called to stake TRX. Before you call this
     * function you must fund your account first. 
     *
     * @param package Value range from 1 to 4.
     * @param cap Stake using capitalisation. Value is true or false. 
     * @param amount TRX to stake. value is in sun.
     *
     */
    function stake(uint8 package, bool cap, uint256 amount) 
        external 
        validateStakeAmount(amount) 
        isAmountAvailable(amount) 
    {
        // check if pass in package is valid
        require(package > 0 && package  < 5, "Argument package is out of bounds.");

        uint256 stake_duration = stake_durations[package];
        uint256 stake_percent = stake_percents[package];
        uint256 stake_total_earn;
        uint256 capitalisation;
        uint256 earn_claim_time; // time for first claim
        uint256 current_time = now * MATH_BASE_UNIT;
        uint256 stake_fee = (amount * (STAKE_FEE + REFERRAL_PERCENT)) / 100;
        uint256 stake_amount = amount - stake_fee; // deduct stake fee

        // check if user is referred by another user
        if (accounts[msg.sender].referred_by != address(0)) { // referred by user
            // calculate the amount the referral earn
            uint256 referral_earn_amount = (amount * REFERRAL_PERCENT) / 100; 
            
            // add the amount to referral balance
            accounts[accounts[msg.sender].referred_by].balance += referral_earn_amount;

            // add to Tronwage earn balance
            tw_earn_balance += stake_fee - referral_earn_amount;
            
        } else { // not referred by anyone
            // add to Tronwage earn balance
            tw_earn_balance += stake_fee;
        }

        {
            address queue_user;
            uint256 queue_balance;
            uint256 available_amount = stake_amount;

            // check if there is stake balance in queue and iterate the queue
            while (!stakeIsEmpty()) {
                // get stake balance in queue
                queue_user = stake_queues[stake_queue_first].user;
                queue_balance = stake_queues[stake_queue_first].amount;

                // check if user's new stake can clear the balance
                if (available_amount >= queue_balance) {
                    // add to user's balance
                    accounts[queue_user].balance += queue_balance;
                    accounts[queue_user].remaining_earn -= queue_balance;

                    // remove stake balance from queue
                    stakeRemove();

                    available_amount -= queue_balance;

                } else { // can't clear the balance
                    // add to user's balance
                    accounts[queue_user].balance += available_amount;
                    accounts[queue_user].remaining_earn -= available_amount;

                    // update the stake balance
                    stake_queues[stake_queue_first].amount = queue_balance - available_amount;
                    
                    available_amount = 0;

                    // stop the queue iteration
                    break;
                }
            }

            // add the remaining to current stake balance 
            if (available_amount > 0) {
                current_stake_balance += available_amount;
            }
        }
            
        if (cap) { // stake with capitalisation
            capitalisation = 15e17; // 1.5
            earn_claim_time = current_time + UDMath.mul(stake_duration, SECONDS_IN_DAY);
        
        } else { // no capitalisation
            capitalisation = 1e18; // 1
            earn_claim_time = current_time + SECONDS_IN_DAY;
        }
        
        stake_total_earn = calcTotalEarn(
            stake_amount, 
            stake_percent, 
            stake_duration, 
            capitalisation // capitalisation
        );
        
        // stake and add it to user's stake list
        userStakes[msg.sender].push(Stake({
            id: getUniqueID(), 
            cap: cap, 
            staked: stake_amount, 
            total_earn: stake_total_earn, 
            start_time: current_time, 
            due_time: current_time + UDMath.mul(stake_duration, SECONDS_IN_DAY), 
            prev_claim_time: current_time, 
            next_claim_time: earn_claim_time
        }));
        
        // remove stake amount from user's balance
        accounts[msg.sender].balance -= amount;
        
        emit AmountStaked(
            msg.sender, 
            package, 
            cap, 
            amount,
            stake_fee
        );
    }
    
    /**
     * @dev This function claim user's stake profit and remove the 
     * stake if it has reach it due time.
     *
     * @param stake_id The id of the stake you want to claim.
     */
    function claimStakeProfit(uint256 stake_id) external {
        UserAccount storage account = accounts[msg.sender];
        Stake[] storage user_stakes = userStakes[msg.sender];
        Stake memory user_stake;
        uint256 stake_index = 0;
        bool stake_exist = false;
        uint256 current_time = now * MATH_BASE_UNIT;
        uint256 claim_amount;
        
        // find the stake user want to claim
        for (; stake_index < user_stakes.length; stake_index++) {
            if (user_stakes[stake_index].id == stake_id) {
                user_stake = user_stakes[stake_index];
                stake_exist = true;
                break; // exit the loop
            }
        }
        
        // check if it has reached the time to claim profit
        require(
            stake_exist && current_time >= user_stake.next_claim_time, 
            "Time to claim stake haven't been reached or stake doesn't exist."
        );

        // check if is a last claim
        if (current_time > user_stake.due_time) {
            claim_amount = UDMath.div(
                UDMath.mul(
                    user_stake.due_time - user_stake.prev_claim_time, 
                    user_stake.total_earn
                ), 
                user_stake.due_time - user_stake.start_time
            );

            // add the staked amount
            claim_amount += user_stake.staked;
            
            // delete the stake from list
            if (user_stakes.length == 1 || stake_index == user_stakes.length - 1) {
                user_stakes.pop();
                
            } else {
                user_stakes[stake_index] = user_stakes[user_stakes.length - 1];
                user_stakes.pop();
            }
            
        } else { // not the last claim
            claim_amount = UDMath.div(
                UDMath.mul(
                    current_time - user_stake.prev_claim_time, 
                    user_stake.total_earn
                ), 
                user_stake.due_time - user_stake.start_time
            );

            // check if next claim is the due time
            if (current_time + SECONDS_IN_DAY > user_stake.due_time) {
                // reset some stake properties
                user_stakes[stake_index].prev_claim_time = current_time;
                user_stakes[stake_index].next_claim_time = user_stake.due_time;

            } else {
                // reset some stake properties
                user_stakes[stake_index].prev_claim_time = current_time;
                user_stakes[stake_index].next_claim_time = current_time + SECONDS_IN_DAY;
            }
        }
        
        // add the claimed amount to user's balance
        if (claim_amount <= current_stake_balance) {
            account.balance += claim_amount;
            current_stake_balance -= claim_amount;
            
        } else { // stake balance is insufficient
            uint256 remaining_balance = claim_amount - current_stake_balance;
            
            // add the leftover to user's balance
            account.balance += current_stake_balance;
            
            // set the stake balance to zero
            current_stake_balance = 0;
            
            // update user's remaining earn
            account.remaining_earn += remaining_balance;
            
            // add the remaining balance to queue
            stakeEnqueue(msg.sender, remaining_balance);
        }
    }
    
    /**
     * @dev Call this function to deposit TRX into your account. 
     */
    function deposit() external depositNotZero payable {
        // update user's account
        accounts[msg.sender].balance += msg.value;
        accounts[msg.sender].total_deposit += msg.value;
        
        total_trx_deposited += msg.value;
        emit Deposited(msg.sender, msg.value);
    }
    
    /**
     * @dev User can call this function to withdraw their balance. 
     *
     * @param amount Amount of TRX in sun. 
     */
    function withdraw(uint256 amount) external isAmountAvailable(amount) {
        require(!locked[msg.sender], "Function still executing.");
        locked[msg.sender] = true;
        
        UserAccount storage account = accounts[msg.sender];
        uint256 withdraw_fee = (amount * WITHDRAW_FEE) / 100;
        uint256 withdraw_amount = amount - withdraw_fee;
        
        if (msg.sender.send(withdraw_amount)) { // transfer is successfully
            account.balance -= amount;
            account.total_withdraw += amount;
            total_trx_withdrawn += withdraw_amount;
            
            tw_earn_balance += withdraw_fee; // add to Tronwage balance
            locked[msg.sender] = false;
            emit Withdrawn(msg.sender, amount, withdraw_fee);

        } else {
            locked[msg.sender] = false;
        }
    }
    
    /**
     * @dev Withdraw Tronwage earn balance. 
     *
     * @param amount Amount of TRX in sun. 
     */
    function withdrawTWEarn(uint256 amount) external onlyAdmin {
        // check if requested amount is available
        require(
            amount <= tw_earn_balance && amount > 0, 
            "Earn balance is insufficient."
        );
    
        require(!locked[msg.sender], "Function still executing.");
        locked[msg.sender] = true;
        
        if (msg.sender.send(amount)) { // transfer is successfully
            tw_earn_balance -= amount;
            total_trx_withdrawn += amount;
            
            locked[msg.sender] = false;
            emit Withdrawn(msg.sender, amount, 0);

        } else {
            locked[msg.sender] = false;
        }
    }

    /**
     * @dev Change the minimun stake amount.
     *
     * @param value Minimum stake amount in sun.
     */

    function changeMinStakeAmount(uint256 value) external onlyAdmin {
        require(
            value >= SUN && value < STAKE_MAX_AMOUNT,
            "Invalid minimum stake amount."
        );

        STAKE_MIN_AMOUNT = value;
    }

    /**
     * @dev Change the maximun stake amount.
     *
     * @param value Maximum stake amount in sun.
     */

    function changeMaxStakeAmount(uint256 value) external onlyAdmin {
        require(
            value > STAKE_MIN_AMOUNT && value <= 1e11,
            "Invalid maximum stake amount."
        );

        STAKE_MAX_AMOUNT = value;
    }
}