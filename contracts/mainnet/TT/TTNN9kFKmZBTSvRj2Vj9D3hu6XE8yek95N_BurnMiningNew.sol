//SourceUnit: BurnMiningTest.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor () internal { }

    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


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
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
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
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
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
     *
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
     *
     * - Subtraction cannot overflow.
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
     *
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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
interface IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function mint(address _to, uint256 _amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface IOracle {
    function consultAveragePrice(address token, uint256 interval) external view returns (uint256);
}

// txToken: 0x7BACABB0B39C29B890CD9DB2DF9F9450972B7B89
// genesisUser: 0xB3DDBE2A15E722D56FEC480AABB65AD15BE053FE
// BurnMiningNew: 0x52EDF0178C4F87150FED4FD95C4F200A43C0AEE5/0xBEDB57E2850130BC58A14083722B8D508619540A
// Lands: 0xD46C1BB0410EDDEC4E11BA7C8AAF2C73B3A322A6
contract BurnMiningNew is Ownable {
    using SafeMath for uint256;

    enum Level { BORN, PEOPLE, LAND, SKY }

    // ?????????????????????????????????????????????????????????token?????????????????????????????????????????????????????????????????????24h????????????????????????
    event BurnAddPower(address user, uint256 value, uint256 tokenValue, uint256 burnedToUSDT, uint256 burnPower, uint256 price, address referrer);
    // ?????????????????????????????????????????????
    event Registration(address user, address referer);
    // ??????????????????
    event ChangeLevel(address user, Level oldLevel, Level newLevel);
    // ????????????
    event StartSettling(uint256 blockNum, uint256 price);
    // ????????????
    event EndSettling(uint256 blockNum);
    // ????????????????????????????????????????????????????????????????????????????????????????????????????????????token?????????????????????token?????????
    event DistributeReward(address user, uint256 costBurnedToUSDT, uint256 costBurnedToPower, uint256 rewardNum, uint256 newRewardNum, uint256 poolReward, uint256 rankReward, uint256 publicityReward, uint256 teamReward);
    // ????????????
    event ClaimReward(address user, uint256 userReward);
    // ??????????????????
    event ClaimPoolReward(address user, uint256 reward);
    // ??????????????????
    event ClaimPublicityReward(address user, uint256 reward);
    // ??????????????????
    event ClaimTeamReward(address user, uint256 reward);

    struct UserInfo {
        // ????????????
        address user;
        // ????????????
        bool isExisted;
        // ??????id
        uint256 id;
        // ??????????????????
        uint256 lastBurnedTimestamp;

        // ??????????????????U?????????
        uint256 burnedToUSDT;

        // ??????????????????U?????????= ???????????? + ????????????
        uint256 mintTokenPower;

        // ????????????????????????U?????????
        uint256 lastBurnedValue;
        // ?????????
        address referrer;
        // ??????
        Level level;
        // ?????????Token??????
        uint256 pendingReward;
    }


    // ************************ Config ************************
    // ????????????
    uint256 public epochAmount;
    // ????????????
    uint256 public miningMultiple = 3;
    // ????????????
    uint256 public powerMultiple = 2;
    // Oracle
    IOracle public oracle;
    // txToken
    IERC20 public txToken;
    // ????????????
    address public genesisUser;

    // ???????????????????????????token
    uint256 public pendingPoolReward;
    // ??????????????????
    address public feeToPool;
    // ???????????????????????????token
    uint256 public pendingPublicityReward;
    // ??????????????????
    address public feeToPublicity;
    // ?????????????????????????????????
    uint256 public pendingTeamReward;
    // ??????????????????
    address public feeToTeam;
    // ?????????????????????????????????
    uint256 public pendingRankReward;

    // ************************ State ************************
    // ???????????????
    uint256 public totalPower;
    // ??????????????????
    address[] public allUser;
    // ???????????????????????????
    bool public isSettling;
    // ??????????????????
    uint256 public settlingPrice;
    // ?????????????????????
    uint256 public lastBlockNum;
    // ??????????????????
    uint256 public burnedInterval = 24 hours;

    // ????????????
    mapping(address => UserInfo) public addressUserInfo;
    // ??????id => ??????address
    mapping(uint256 => address) public userIdAddress;
    // ?????? => ??????
    mapping(Level => uint256) public levelMultiple;


    modifier running() {
        require(!isSettling, "BurnMing: IS_SETTLING");
        _;
    }

    modifier settling() {
        require(isSettling, "BurnMing: IS_RUNNING");
        _;
    }

    constructor(
        IERC20 _txToken,
        IOracle _oracle,
        address _genesisUser
    ) public {
        require(address(_txToken) != address(0), "BurnMing: TOKEN_ZERO_ADDRESS");
        require(address(_oracle) != address(0), "BurnMing: ORACLE_ZERO_ADDRESS");
        require(address(_genesisUser) != address(0), "BurnMing: FIRST_USER_ZERO_ADDRESS");
        txToken = _txToken;
        oracle = _oracle;
        genesisUser = _genesisUser;

        // ??????????????????
        UserInfo storage userInfo = addressUserInfo[_genesisUser];
        userInfo.user = _genesisUser;
        userInfo.isExisted = true;
        userInfo.level = Level.BORN;
        userInfo.id = allUser.length;
        userIdAddress[userInfo.id] = genesisUser;
        allUser.push(genesisUser);

        // ????????????????????? 2/3/5/10
        levelMultiple[Level.BORN] = uint256(2);
        levelMultiple[Level.PEOPLE] = uint256(3);
        levelMultiple[Level.LAND] = uint256(5);
        levelMultiple[Level.SKY] = uint256(10);

        // ?????????????????????????????????????????????
        lastBlockNum = block.number;
    }

    /**
    * @notice ??????Token 24h??????????????????usdt??????????????????usdt??????
    * @return ??????
    */
    function getTokenAveragePrice() public pure returns (uint256) {
        // uint256 price = oracle.consultAveragePrice(address(txToken), 24 hours);
        uint256 price = 500000;
        return price;
    }

    // ?????????????????????
    function _register(address _referrer) internal returns (bool success) {
        if (msg.sender == genesisUser) {
            return true;
        }
        // ????????????????????????0
        require(_referrer != address(0), "BurnMing???ZERO_ADDRESS");
        // ??????????????????????????????
        require(msg.sender != _referrer, "BurnMing???CALLER_NOT_SAME_AS_REFERER");

        // ?????????????????????
        UserInfo storage refererInfo = addressUserInfo[_referrer];
        // ????????????????????????
        UserInfo storage userInfo = addressUserInfo[msg.sender];
        // ???????????????????????????
        require(refererInfo.isExisted, "BurnMing???REFERER_NOT_REGISTRATION");
        // ???????????????????????????????????????
        if(!userInfo.isExisted) {
            userInfo.user = msg.sender;
            // ??????????????????????????????
            userInfo.isExisted = true;
            // ???????????????
            userInfo.referrer = _referrer;
            // ???????????????
            userInfo.level = Level.BORN;
            // ??????id??????0????????????
            userInfo.id = allUser.length;
            // ????????????id?????????????????????
            userIdAddress[userInfo.id] = msg.sender;
            // ??????????????????
            allUser.push(msg.sender);

            // ??????????????????
            emit Registration(msg.sender, _referrer);
        }
        return true;
    }

    /**
    * @notice ??????????????????
    * @param userInfo ????????????
    * @param _value ??????????????????U?????????
    * @return ?????????????????????
    */
    function _burnAddPower(UserInfo storage userInfo, uint256 _value) internal returns(uint256, uint256) {
        // ????????????????????????????????????????????????
        require(_value > userInfo.lastBurnedValue, "BurnMing: BURN_MUST_BE_BIGGER_THEN_LAST");
        // ??????????????????????????????????????????
        require(block.timestamp.sub(burnedInterval) >= userInfo.lastBurnedTimestamp, "BurnMing: MUST_BIGGER_THEN_INTERVAL");

        // ????????????????????????????????????
        userInfo.lastBurnedValue = _value;
        // ????????????????????????????????????
        userInfo.lastBurnedTimestamp = block.timestamp;

        // ?????????????????? = ???????????? * ??????????????????(3)
        uint256 _burnedToUSDT = _value.mul(miningMultiple);
        // ???????????????????????? += ????????????
        userInfo.burnedToUSDT = userInfo.burnedToUSDT.add(_burnedToUSDT);

        // ?????????????????? = ???????????? * ??????????????????(2)
        uint256 _burnPower = _value.mul(powerMultiple);
        // ???????????????????????? += ????????????
        userInfo.mintTokenPower = userInfo.mintTokenPower.add(_burnPower);
        // ??????????????????
        totalPower = totalPower.add(_burnPower);

        return (_burnedToUSDT, _burnPower);
    }

    /**
    * @notice ?????????????????????
    * @param refererInfo ???????????????
    * @param _value ??????????????????
    * @return ????????????????????????
    */
    function _updateRefererPower(
        UserInfo storage refererInfo,
        uint256 _value
    ) internal returns(uint256) {
        // ??????????????????????????????
        uint256 refererAddedPower = _value.mul(levelMultiple[refererInfo.level]) > refererInfo.burnedToUSDT ?
        refererInfo.burnedToUSDT: _value.mul(levelMultiple[refererInfo.level]);

        // ??????????????????????????? += ????????????
        refererInfo.mintTokenPower = refererInfo.mintTokenPower.add(refererAddedPower);
        // ??????????????????
        totalPower = totalPower.add(refererAddedPower);

        return refererAddedPower;
    }

    /**
    * @notice ??????????????????????????????
    * @param user ????????????
    * @return ??????????????????
    */
    function canBurn(address user) public view returns(bool) {
        // ????????????????????????
        UserInfo storage userInfo = addressUserInfo[user];
        require(userInfo.isExisted, "BurnMing: NOT_REGISTER");

        // ??????????????????????????????????????????
        if (block.timestamp.sub(burnedInterval) >= userInfo.lastBurnedTimestamp) {
            return true;
        } else {
            return false;
        }
    }

    /**
    * @notice ??????
    * @param _value ??????????????????U?????????
    * @param _referer ???????????????
    * @return success
    */
    function burn(uint256 _value, address _referer) public running returns (bool success) {
        // ?????????????????????100u
        require(_value > 100 * 1e6, "BurnMing: VALUE_MUST_BE_BIGGER_THEN_ONE_HUNDRED");

        // 1????????????????????????????????????????????????????????????
        _register(_referer);

        // 2????????????token????????????????????????
        // ??????????????????
        uint256 price = getTokenAveragePrice();
        // ????????????token??????
        uint256 tokenValue = _value.mul(1e20).div(price).div(1e12);
        // ????????????
        require(txToken.balanceOf(msg.sender) >= tokenValue, "BurnMing: INSUFFICIENT_BALANCE");
        // ??????
        txToken.transferFrom(msg.sender, address(this), tokenValue);

        // 3?????????token??????????????????????????????????????????
        UserInfo storage userInfo = addressUserInfo[msg.sender];
        (uint256 burnedToUSDT, uint256 burnPower) = _burnAddPower(userInfo, _value);

        // ???????????????????????????????????????
        if(msg.sender != genesisUser) {
            UserInfo storage refererInfo = addressUserInfo[userInfo.referrer];
            // 4????????????????????????
            _updateRefererPower(refererInfo, _value);
        }

        // 5?????????????????????????????????
        emit BurnAddPower(msg.sender, _value, tokenValue, burnedToUSDT, burnPower, price, userInfo.referrer);

        return true;
    }

    /**
    * @notice ??????????????????
    */
    function claimReward() public running {
        // ??????????????????
        UserInfo storage userInfo = addressUserInfo[msg.sender];
        require(userInfo.isExisted, "BurnMing: NOT_REGISTER");

        // ?????????????????????????????????
        uint256 rewardNum = userInfo.pendingReward;
        require(rewardNum > uint256(0), "BurnMing: ZERO_REWARD");
        // ???????????????????????????
        userInfo.pendingReward = 0;
        // ??????????????????
        txToken.transfer(msg.sender, rewardNum);
        // ?????????????????????????????????????????????
        emit ClaimReward(msg.sender, rewardNum);
    }

    /**
    * @notice ?????????????????????
    */
    function claimFeeReward() public running {
        if (msg.sender == feeToPool) {
            txToken.transfer(msg.sender, pendingPoolReward);
            emit ClaimPoolReward(msg.sender, pendingPoolReward);
            pendingPoolReward = 0;
        } else if (msg.sender == feeToTeam) {
            txToken.transfer(msg.sender, pendingTeamReward);
            emit ClaimTeamReward(msg.sender, pendingTeamReward);
            pendingTeamReward = 0;
        } else if (msg.sender == feeToPublicity) {
            txToken.transfer(msg.sender, pendingPublicityReward);
            emit ClaimPublicityReward(msg.sender, pendingPublicityReward);
            pendingPublicityReward = 0;
        }
    }

    /**
    * @notice ??????????????????token?????????
    */
    function multiTransferRanking(address[] memory users, uint256[] memory rewards) public running onlyOwner {
        require(users.length == rewards.length, "BurnMing: NOT_SAME");
        uint256 _pendingRankReward = pendingRankReward;
        for(uint256 i; i < users.length; i++) {
            txToken.transfer(users[i], rewards[i]);
            _pendingRankReward = _pendingRankReward.sub(rewards[i]);
        }
        pendingRankReward = _pendingRankReward;
    }

    // ****************** Owner ******************

    /**
    * @notice ??????????????????
    * @param user ????????????
    * @param newLevel ?????????
    */
    function changeLevel(address user, Level newLevel) public onlyOwner {
        require(levelMultiple[newLevel] > uint256(0), "BurnMing: LEVEL_NOT_EXIST");
        // ????????????????????????
        UserInfo storage userInfo = addressUserInfo[user];
        require(userInfo.isExisted, "BurnMing: NOT_REGISTER");

        // ??????????????????
        Level oldLevel = userInfo.level;
        userInfo.level = newLevel;

        emit ChangeLevel(user, oldLevel, newLevel);
    }

    /**
    * @notice ????????????/??????????????????????????????
    * @param _isSettling ??????
    */
    function setSettling(bool _isSettling) public onlyOwner {
        if(isSettling != _isSettling) {
            isSettling = _isSettling;
            // ???????????????????????????????????????24h??????
            if(_isSettling) {
                // ????????????24h??????
                uint256 _price = getTokenAveragePrice();
                // ????????????????????????
                settlingPrice = _price;
                emit StartSettling(block.number, _price);
            } else {
                // ????????????????????????????????????????????????
                lastBlockNum = block.number;
                emit EndSettling(block.number);
            }
        }
    }

    function _distributeFeeReward(uint256 rewardNum) internal returns(uint256, uint256, uint256, uint256, uint256) {
        // ?????????????????????
        uint256 poolReward = rewardNum.mul(30).div(1000);
        // ?????????????????????
        uint256 rankReward = rewardNum.mul(12).div(1000);
        // ?????????????????????
        uint256 publicityReward = rewardNum.mul(6).div(1000);
        // ?????????????????????
        uint256 teamReward = rewardNum.mul(2).div(1000);

        pendingPoolReward = pendingPoolReward.add(poolReward);
        pendingRankReward = pendingRankReward.add(rankReward);
        pendingPublicityReward = pendingPublicityReward.add(publicityReward);
        pendingTeamReward = pendingTeamReward.add(teamReward);

        // avoid stack too deep
        rewardNum = rewardNum.sub(pendingPoolReward);
        rewardNum = rewardNum.sub(pendingRankReward);
        rewardNum = rewardNum.sub(pendingPublicityReward);
        rewardNum = rewardNum.sub(pendingTeamReward);

        return (rewardNum, poolReward, rankReward, publicityReward, teamReward);
    }

    /**
    * @notice ????????????
    * @param user ????????????
    * @param costBurnedToUSDT ?????????????????????
    * @param costBurnedToPower ???????????????
    * @param rewardNum ??????token??????
    */
    // ?????????????????????????????????????????????????????????????????????????????????????????????U
    function distributeReward(address user, uint256 costBurnedToUSDT, uint256 costBurnedToPower, uint256 rewardNum) public settling onlyOwner {
        // ????????????????????????
        UserInfo storage userInfo = addressUserInfo[user];
        require(userInfo.isExisted, "BurnMing: NOT_REGISTER");

        // ????????????????????????????????????
        if(costBurnedToUSDT > userInfo.burnedToUSDT){
            costBurnedToUSDT = userInfo.burnedToUSDT;
        }
        // ???????????????????????????
        userInfo.burnedToUSDT = userInfo.burnedToUSDT.sub(costBurnedToUSDT);
        // ???????????????????????????
        userInfo.mintTokenPower = userInfo.mintTokenPower.sub(costBurnedToPower);

        (uint256 newRewardNum, uint256 poolReward, uint256 rankReward, uint256 publicityReward, uint256 teamReward) = _distributeFeeReward(rewardNum);
        // ??????????????????token????????????
        userInfo.pendingReward = userInfo.pendingReward.add(newRewardNum);

        // ???????????????
        totalPower = totalPower.sub(costBurnedToPower);
        emit DistributeReward(user, costBurnedToUSDT, costBurnedToPower, rewardNum, newRewardNum, poolReward, rankReward, publicityReward, teamReward);
    }

    // ???????????????????????????
    function setLevelMultiple(Level level, uint256 multiple) public onlyOwner {
        require(multiple > uint256(0), "BurnMing: MULTIPLE_MUST_BE_BIGGER_THEN_ZERO");
        levelMultiple[level] = multiple;
    }

    // ??????oracle
    function setOracle(IOracle _oracle) public onlyOwner {
        require(address(_oracle) != address(0), "BurnMing: ZERO_ADDRESS");
        oracle = _oracle;
    }

    // ??????TxToken
    function setTxToken(IERC20 _txToken) public onlyOwner {
        require(address(_txToken) != address(0), "BurnMing: ZERO_ADDRESS");
        txToken = _txToken;
    }

    // ????????????????????????
    function setFeeToPool(address _feeToPool) public onlyOwner {
        require(_feeToPool != address(0), "BurnMing: ZERO_ADDRESS");
        feeToPool = _feeToPool;
    }

    // ????????????????????????
    function setFeeToPublicity(address _feeToPublicity) public onlyOwner {
        require(_feeToPublicity != address(0), "BurnMing: ZERO_ADDRESS");
        feeToPublicity = _feeToPublicity;
    }

    // ????????????????????????
    function setFeeToTeam(address _feeToTeam) public onlyOwner {
        require(_feeToTeam != address(0), "BurnMing: ZERO_ADDRESS");
        feeToTeam = _feeToTeam;
    }

    // ??????????????????????????????
    function setEpochAmount(uint256 _epochAmount) public onlyOwner {
        require(_epochAmount > uint256(0), "BurnMing: AMOUNT_MUST_BE_BIGGER_THEN_ZERO");
        epochAmount = _epochAmount;
    }

    // ????????????????????????
    function setMiningMultiple(uint256 _miningMultiple) public onlyOwner {
        require(_miningMultiple > uint256(0), "BurnMing: MULTIPLE_MUST_BE_BIGGER_THEN_ZERO");
        miningMultiple = _miningMultiple;
    }

    // ????????????????????????
    function setPowerMultiple(uint256 _powerMultiple) public onlyOwner {
        require(_powerMultiple > uint256(0), "BurnMing: POWER_MULTIPLE_MUST_BE_BIGGER_THEN_ZERO");
        powerMultiple = _powerMultiple;
    }

    // ????????????????????????
    function setBurnedInterval(uint256 _burnedInterval) public onlyOwner {
        burnedInterval = _burnedInterval;
    }

    // ????????????
    function emergencyWithdraw(address _token) public onlyOwner {
        require(IERC20(_token).balanceOf(address(this)) > 0, "BurnMing: INSUFFICIENT_BALANCE");
        IERC20(_token).transfer(msg.sender, IERC20(_token).balanceOf(address(this)));
    }
}