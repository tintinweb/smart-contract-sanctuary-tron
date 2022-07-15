//SourceUnit: tbas_stake_new_migrate.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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



// abstract contract  RewardsDistributionRecipient is Ownable {

//     address public rewardsDistribution;

//     function notifyRewardAmount(uint256 reward, uint index) external virtual;

//     modifier onlyRewardsDistribution() {
//         require(msg.sender == rewardsDistribution, "Caller is not RewardsDistribution contract");
//         _;
//     }

//     function setRewardsDistribution(address _rewardsDistribution) external onlyOwner {
//         rewardsDistribution = _rewardsDistribution;
//     }
// }

// interface IStakingRewards {
//     // Views

//     function balanceOf(address account) external view returns (uint256);

//     function earned(address account) external view returns (uint256);

//     function getRewardForDuration() external view returns (uint256);

//     function lastTimeRewardApplicable() external view returns (uint256);

//     function rewardPerToken() external view returns (uint256);

//     function totalSupply() external view returns (uint256);

//     // Mutative

//     function exit() external;

//     function getReward() external;

//     function stake(uint256 amount, address recommender) external;

//     function withdraw(uint256 amount) external;
// }

library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}


interface IERC20 {
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
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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


library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }


    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }


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


    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }


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


interface Stake {
    function balanceOf(address account, uint index) external  view returns (uint256);
}



contract Tba2StakingRewards is  Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /* ========== STATE VARIABLES ========== */

    IERC20[3] public rewardsToken;
    IERC20[3] public stakingToken;


    uint256[3] public periodFinish = [0, 0, 0];
    uint256[3] public rewardRate = [0, 0, 0];
    uint256[3] public rewardsDuration = [60 days, 60 days, 60 days];
    uint256[3] public lastUpdateTime;
    uint256[3] public rewardPerTokenStored;

    mapping(address => uint256[3]) public userRewardPerTokenPaid;
    mapping(address => uint256[3]) public rewards;

    uint256[3] private _totalSupply;
    mapping(address => uint256[3]) private _balances;

    address[3] public defaultRecommender;
    mapping(address => address[3]) public recommender;
    uint[2][3] recommenderRate = [[6, 4], [6, 4], [6, 4]];


    mapping(address => bool[3]) public isWhite;


    mapping(address => uint256[3]) public withdrawTime;


    mapping(address => uint256[3]) public userRewarded;

    uint[3] otherRate = [40, 40, 40];
    address[] private others;


    Stake private st;
    mapping(address => bool) public isMigrate;


    /* ========== CONSTRUCTOR ========== */

    constructor(
        address[] memory _rewardsToken,
        address[] memory _stakingToken,
        address[] memory _defaultRecommender,
        address _st
    ) {
        rewardsToken = [IERC20(_rewardsToken[0]), IERC20(_rewardsToken[1]), IERC20(_rewardsToken[2])];
        stakingToken = [IERC20(_stakingToken[0]), IERC20(_stakingToken[1]), IERC20(_stakingToken[2])];
        defaultRecommender = [_defaultRecommender[0], _defaultRecommender[1], _defaultRecommender[2]];
        st = Stake(_st);
    }

    /* ========== VIEWS ========== */

    function totalSupply(uint index) external view returns (uint256) {
        return _totalSupply[index];
    }

    function balanceOf(address account, uint index) external  view returns (uint256) {
        return _balances[account][index];
    }

    function lastTimeRewardApplicable(uint index) public view  returns (uint256) {
        return  block.timestamp < periodFinish[index] ? block.timestamp : periodFinish[index];
    }

    function rewardPerToken(uint index) public view  returns (uint256) {
        if (_totalSupply[index] == 0) {
            return rewardPerTokenStored[index];
        }
        return
            rewardPerTokenStored[index].add(
                lastTimeRewardApplicable(index).sub(lastUpdateTime[index]).mul(rewardRate[index]).mul(1e18).div(_totalSupply[index])
            );
    }

    function earned(address account, uint index) public  view returns (uint256) {
        return _balances[account][index].mul(rewardPerToken(index).sub(userRewardPerTokenPaid[account][index])).div(1e18).add(rewards[account][index]);
    }


    function getEarned(address account, uint index) external view returns (uint256) {
        uint _earned = earned(account, index);

        uint _reward = 0;

        address _recommender_first = recommender[account][index];
        if(0 < _balances[_recommender_first][index]){
            _reward += _earned.mul(recommenderRate[index][0]).div(100);
        }

        address _recommender_second = recommender[_recommender_first][index];
        if(0 < _balances[_recommender_second][index]){
            _reward += _earned.mul(recommenderRate[index][1]).div(100);
        }

        if(0 < others.length){
            _reward += _earned.mul(otherRate[index]).div(100);
        }

        return _earned.sub(_reward);
    }

    function getRewardForDuration(uint index) external view returns (uint256) {
        return rewardRate[index].mul(rewardsDuration[index]);
    }

    function getOthers() external view returns (address[] memory) {
        return others;
    }

    function isOthers(address _address) public view returns (bool) {
        for(uint i = 0; i < others.length; i++){
            if(_address == others[i]){
                return true;
            }
        }
        return false;
    }

    /* ========== MUTATIVE FUNCTIONS ========== */



    function stake(uint index, uint256 amount) external  updateRecommender(index,  recommender[msg.sender][index]) updateReward(index, msg.sender) {
        require(amount > 0, "Cannot stake 0");
        _totalSupply[index] = _totalSupply[index].add(amount);
        _balances[msg.sender][index] = _balances[msg.sender][index].add(amount);
        stakingToken[index].safeTransferFrom(msg.sender, address(this), amount);
        emit Staked(address(stakingToken[index]), msg.sender, amount);

        withdrawTime[msg.sender][index] = block.timestamp.add(rewardsDuration[index]);

    }

    function withdraw(uint256 amount, uint index) public  updateReward(index, msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        require(amount <= _balances[msg.sender][index], "Cannot withdraw: amount must less or equals stake amount");
        if(!isWhite[msg.sender][index]){
            require(block.timestamp > withdrawTime[msg.sender][index], 'It is not time to release the pledge');
        }
        _totalSupply[index] = _totalSupply[index].sub(amount);
        _balances[msg.sender][index] = _balances[msg.sender][index].sub(amount);
        stakingToken[index].safeTransfer(msg.sender, amount);
        emit Withdrawn(address(stakingToken[index]), msg.sender, amount);
    }

    function getReward(uint index) public  updateReward(index, msg.sender) {
        uint256 reward = rewards[msg.sender][index];
        if (reward > 0) {
            rewards[msg.sender][index] = 0;
            rewardsToken[index].safeTransfer(msg.sender, reward);
            userRewarded[msg.sender][index] = userRewarded[msg.sender][index].add(reward);
            emit RewardPaid(address(rewardsToken[index]), msg.sender, reward);
        }
    }

    function exit(uint index) external  {
        withdraw(_balances[msg.sender][index], index);
        getReward(index);
    }



    function migrate(uint index) external {
        address sender = _msgSender();
        require(!isMigrate[sender], 'can not migrate');

        uint balance = st.balanceOf(sender, index);
        _balances[sender][index] += balance;
        _totalSupply[index] = _totalSupply[index].add(balance);

        isMigrate[sender] = true;

    }


    function bindRecommenderr(uint index, address _recommender) external updateRecommender(index, _recommender) {

    }


    function resetRewardPerTokenStored(uint index) external onlyOwner {
        rewardPerTokenStored[index] = 0;
    }

    function resetStakeToken(address _address, uint index) external onlyOwner {
       stakingToken[index] = IERC20(_address);
    }

    function resetDefRecommender(address _address, uint index) external onlyOwner {
       defaultRecommender[index] = _address;
    }



    function setWhiteAddress(address _address, uint256 index) external onlyOwner {
        isWhite[_address][index] = !isWhite[_address][index];
    }








    /* ========== RESTRICTED FUNCTIONS ========== */

    function notifyRewardAmount(uint256 reward, uint index) external  onlyOwner updateReward(index, address(0)) {
        if (block.timestamp >= periodFinish[index]) {
            rewardRate[index] = reward.div(rewardsDuration[index]);
        } else {
            uint256 remaining = periodFinish[index].sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardRate[index]);
            rewardRate[index] = reward.add(leftover).div(rewardsDuration[index]);
        }

        uint balance = rewardsToken[index].balanceOf(address(this));
        require(rewardRate[index] <= balance.div(rewardsDuration[index]), "Provided reward too high");

        lastUpdateTime[index] = block.timestamp;
        periodFinish[index] = block.timestamp.add(rewardsDuration[index]);
        emit RewardAdded(address(rewardsToken[index]), reward);
    }


    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOwner {
        //require(tokenAddress != address(stakingToken[index]), "Cannot withdraw the staking token");
        IERC20(tokenAddress).safeTransfer(owner(), tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }

    function setRewardsDuration(uint256 _rewardsDuration, uint index) external onlyOwner {
        require(
            block.timestamp > periodFinish[index],
            "Previous rewards period must be complete before changing the duration for the new period"
        );
        rewardsDuration[index] = _rewardsDuration;
        emit RewardsDurationUpdated(address(rewardsToken[index]),rewardsDuration[index]);
    }



    function resetOthers(address[] memory _othersAddress) external onlyOwner {
        delete others;
        others = _othersAddress;
    }


    function _rewardRecommeder(address account, uint _earned, uint index) private returns(uint){

        uint _recommender_reward = 0;

        address _recommender_first = recommender[account][index];
        if(0 < _balances[_recommender_first][index]){
            uint _recommender_first_reward = _earned.mul(recommenderRate[index][0]).div(100);
            _recommender_reward += _recommender_first_reward;
            rewards[_recommender_first][index] += _recommender_first_reward;
        }

        address _recommender_second = recommender[_recommender_first][index];
        if(0 < _balances[_recommender_second][index]){
            uint _recommender_second_reward = _earned.mul(recommenderRate[index][1]).div(100);
            _recommender_reward += _recommender_second_reward;
            rewards[_recommender_second][index] += _recommender_second_reward;
        }

        return _recommender_reward;
    }


    function _rewardOthers(uint _earned, uint index) private returns(uint){

        if(0 < others.length){
            uint rewardAmounts = _earned.mul(otherRate[index]).div(100);
            uint rewardAmount = rewardAmounts.div(others.length);
            for(uint i = 0; i < others.length; i++){
                rewards[others[i]][index] = rewards[others[i]][index].add(rewardAmount);
            }

            return rewardAmounts;
        }

        return 0;
    }


    /* ========== MODIFIERS ========== */

    modifier updateReward(uint index, address account) {
        rewardPerTokenStored[index] = rewardPerToken(index);
        lastUpdateTime[index] = lastTimeRewardApplicable(index);
        if (account != address(0)) {
            uint _earned = earned(account, index);
            if(0 < _earned){
                if(isOthers(account)){
                    rewards[account][index] = _earned;
                }else{
                    uint reward_recommender = _rewardRecommeder(account, _earned, index);
                    uint reward_others = _rewardOthers(_earned, index);

                    rewards[account][index] = _earned.sub(reward_recommender).sub(reward_others);
                }
            }

            userRewardPerTokenPaid[account][index] = rewardPerTokenStored[index];
        }
        _;
    }



    modifier updateRecommender(uint index, address _recommender) {

        if(recommender[msg.sender][index] == address(0)){
            require(msg.sender != _recommender, "Recommender can not to be same");
            recommender[msg.sender][index] = _recommender;
        }else{
            require(recommender[msg.sender][index] == _recommender, "Recommender already exits");
        }
        _;
    }

    /* ========== EVENTS ========== */

    event RewardAdded(address indexed token, uint256 reward);
    event Staked(address indexed token, address indexed user, uint256 amount);
    event Withdrawn(address indexed token, address indexed user, uint256 amount);
    event RewardPaid(address indexed token, address indexed user, uint256 reward);
    event RewardsDurationUpdated(address indexed token, uint256 newDuration);
    event Recovered(address token, uint256 amount);
}