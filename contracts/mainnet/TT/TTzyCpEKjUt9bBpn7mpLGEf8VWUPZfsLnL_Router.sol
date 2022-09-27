//SourceUnit: Router_flattened.sol

pragma solidity ^0.5.4;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable{
    /**
     * @dev Emitted when the pause is triggered by `account`.
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by `account`.
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state.
     */
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Triggers stopped state.
     *
     * Requirements:
     *
     * - The contract must not be paused.
     */
    function _pause() internal whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev Returns to normal state.
     *
     * Requirements:
     *
     * - The contract must be paused.
     */
    function _unpause() internal whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}



pragma solidity ^0.5.4;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address payable private _owner;
    mapping(address => bool) private _owners;
    event OwnershipGiven(address indexed newOwner);
    event OwnershipTaken(address indexed previousOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() public {
        address payable msgSender = msg.sender;
        _addOwnership(msgSender);
        _owner = msgSender;
        emit OwnershipGiven(msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() private view returns (address payable) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner 1");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _owners[msg.sender];
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function addOwnership(address payable newOwner) public onlyOwner {
        _addOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _addOwnership(address payable newOwner) private {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipGiven(newOwner);
        _owners[newOwner] = true;
    }

    function _removeOwnership(address payable __owner) private {
        _owners[__owner] = false;
        emit OwnershipTaken(__owner);
    }

    function removeOwnership(address payable __owner) public onlyOwner {
        _removeOwnership(__owner);
    }
}


pragma solidity ^0.5.4;




contract Sender is Ownable, Pausable {
    function sendTRX(
        address payable _to,
        uint256 _amount,
        uint256 _gasForTransfer
    ) external whenPaused onlyOwner {
        _to.call.value(_amount).gas(_gasForTransfer)("");
    }

    function sendTRC20(
        address payable _to,
        uint256 _amount,
        ITRC20 _token
    ) external whenPaused onlyOwner {
        _token.transfer(_to, _amount);
    }
}




pragma solidity ^0.5.4;


/**
 * @title TRC20 interface (compatible with ERC20 interface)
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 */
interface ITRC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


pragma solidity ^0.5.4;


contract ITRC20List is Ownable {
    event EnableToken(address token_, uint256 ratio_);
    event DisableToken(address token_);
    function enableToken(address token_, uint256 ratio_) public;
    function disableToken(address token_) public;
    function getRationDecimals() public view returns (uint256);
    function isTokenEnabled(address token_) public view returns (bool);
    function getRatioTrx(address token_) public view returns (uint256);
    function getElementOfEnabledList(uint index_) public view returns (address);
    function getSizeOfEnabledList() public view returns (uint256);
    function tokenToSun(address token_, uint256 amount_) public view returns (uint256);
}

pragma solidity ^0.5.4;




contract TRC20Holder is Ownable {
    ITRC20List whiteList;

    function setTRC20List(address whiteList_) public onlyOwner {
        whiteList = ITRC20List(whiteList_);
    }

    function getTRC20List() external view returns (address) {
        return address(whiteList);
    }

    modifier onlyEnabledToken(address token_) {
        require(address(whiteList) != address(0), "You must set address of token");
        require(whiteList.isTokenEnabled(token_), "This token not enabled");
        _;
    }

    function getTokens(address token_, uint256 amount_) internal onlyEnabledToken(token_) {
        require(ITRC20(token_).allowance(msg.sender, address(this)) >= amount_, "Approved less than need");
        bool res = ITRC20(token_).transferFrom(msg.sender, address(this), amount_);
        require(res);
    }

    function withdrawToken(address receiver_, address token_, uint256 amount_) internal onlyEnabledToken(token_) {
        require(ITRC20(token_).balanceOf(address(this)) >= amount_, "Can't make withdraw with this amount");
        bool res = ITRC20(token_).transfer(receiver_, amount_);
        require(res);
    }
}




pragma solidity ^0.5.4;



contract TRC20List is Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private enabled;
    mapping(address => uint256) private ratioTrx;
    address [] private whiteList;
    uint256 private ratioDecimals;

    event EnableToken(address token_, uint256 ratio_);
    event DisableToken(address token_);

    constructor() public {
        ratioDecimals = 1000 * 1000 * 1000;
    }

    /**
    For enable new token or update existing
    token_  address of TRC20 smart contract
    ratio_  multiplier for determine amount of Trx corresponding this token
     */
    function enableToken(address token_, uint256 ratio_) public onlyOwner {
        require(token_ != address(0), "You must set address");
        if (enabled[token_] == 0) {
            enabled[token_] = 1;
            whiteList.push(token_);
        }
        ratioTrx[token_] = ratio_;
        emit EnableToken(token_, ratio_);
    }

    function disableToken(address token_) public onlyOwner {
        require(token_ != address(0), "You must set address");
        enabled[token_] = 0;
        removeTokenFromList(token_);
        emit DisableToken(token_);
    }

    function getRationDecimals() public view returns (uint256) {
        return ratioDecimals;
    }

    function isTokenEnabled(address token_) public view returns (bool) {
        return enabled[token_] != 0;
    }

    function getRatioTrx(address token_) public view returns (uint256) {
        require(enabled[token_] != 0, "Token not enabled");
        return ratioTrx[token_];
    }

    function removeTokenFromList(address token_) private {
        uint i = 0;
        while (whiteList[i] != token_) {
            i++;
        }
        bool found = i < whiteList.length;
        while (i < whiteList.length - 1) {
            whiteList[i] = whiteList[i + 1];
            i++;
        }
        if (found)
            whiteList.length--;
    }

    function getWhiteListAt(uint index_) public view returns (address) {
        require(whiteList.length > 0 && index_ < whiteList.length, "Index above that exist");
        return whiteList[index_];
    }

    function getWhiteListSize() public view returns (uint256) {
        return whiteList.length;
    }

    function tokenToSun(address token_, uint256 amount_) public view returns (uint256)
    {
        return amount_.mul(getRationDecimals()).div(getRatioTrx(token_));
    }
}

pragma solidity ^0.5.4;


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
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
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


pragma solidity ^0.5.4;






/**
This contract is main contract of our ecosystem
Every game play runs lose or win function
everyday we trigger tick function and that runs winr tick function
and distribute user rewards
user referral system also in this contract
 */

interface IWINR {
    function tick() external payable;

    function mine(
        address to,
        uint256 wager,
        uint256 dailyCoef,
        uint256 totalWagered
    ) external;

    function getMultiplier(address) external view returns (uint8);

    function setTopPlayers(
        address top1,
        address top2,
        address top3
    ) external;

    function setTopPlayersMultipliers(
        uint8 top1multiplier,
        uint8 top2multiplier,
        uint8 top3multiplier
    ) external;

    function getActiveRound()
        external
        view
        returns (
            uint16 allocation,
            uint256 amount,
            uint16 payout,
            uint256 minted
        );
}

contract Router is Sender, TRC20Holder {
    using SafeMath for uint256;

    address payable _winrContract;
    address payable _lotteryContract;
    uint256 private _lastTick;
    DailyStats private _yesterday;
    DailyStats private _today;
    DailyStats private _averageStats;
    DailyStats private _totalStats;
    uint256 private _tickId;

    event Tick(
        uint256 profit,
        uint256 revenue,
        uint256 lose,
        uint256 win,
        uint256 wager,
        uint256 sharedProfit,
        uint256 dailyCoefficient
    );

    mapping(address => address payable) public refParent;
    mapping(address => uint256) public playerRefCount;
    mapping(address => address payable) public refDisabledTo;
    mapping(address => uint256) private lastWagers;
    uint256 public lastTopPlayersRewardDistributionAt;
    uint256 private TOP_PLAYERS_MULTIPLY_TIME = 300;

    mapping(address => bool) private _games;

    struct DailyStats {
        uint256 profit;
        uint256 revenue;
        uint256 lose;
        uint256 won;
        uint256 sentBack;
        uint256 wagered;
        uint256 sharedProfit;
        uint256 dailyCoefficient;
    }

    event AddReferral(address indexed parent, address indexed child);

    struct Ref {
        address payable parent;
        address payable child;
        uint256 tickId;
    }

    constructor() public {
        _tickId = 0;
        _lastTick = now;
        lastTopPlayersRewardDistributionAt = now;
    }

    function() external payable {}

    modifier onceADay(uint256 baseTime) {
        require(now >= baseTime + 1 days, "This function can run once a day");
        _;
    }

    modifier onlyGame() {
        require(isGame(msg.sender), "Game Auth: Only games can do this");
        _;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function isGame(address addr) public view returns (bool) {
        return _games[addr];
    }

    function addGame(address payable _game) external onlyOwner {
        _games[_game] = true;
    }

    function removeGame(address payable _game) external onlyOwner {
        _games[_game] = false;
    }

    function getLastTick() public view returns (uint256 lastTick) {
        lastTick = _lastTick;
    }

    function getAverageStats()
        public
        view
        returns (
            uint256 wager,
            uint256 calculatedProfit,
            uint256 lose,
            uint256 win,
            uint256 revenue
        )
    {
        wager = _averageStats.wagered;
        calculatedProfit = _today.revenue.mul(_today.revenue).div(_averageStats.revenue);
        lose = _averageStats.lose;
        win = _averageStats.won;
        revenue = _averageStats.revenue;
    }

    function getDay()
        public
        view
        returns (
            uint256 wager,
            uint256 lose,
            uint256 win,
            uint256 sentBack,
            uint256 revenue,
            uint256 dailyCoefficient
        )
    {
        wager = _today.wagered;
        lose = _today.lose;
        win = _today.won;
        revenue = _today.revenue;
        sentBack = _today.sentBack;
        dailyCoefficient = _today.dailyCoefficient;
    }

    function getYesterday()
        public
        view
        returns (
            uint256 wager,
            uint256 lose,
            uint256 win,
            uint256 sentBack,
            uint256 revenue,
            uint256 dailyCoefficient
        )
    {
        wager = _yesterday.wagered;
        lose = _yesterday.lose;
        win = _yesterday.won;
        revenue = _yesterday.revenue;
        sentBack = _yesterday.sentBack;
        dailyCoefficient = _yesterday.dailyCoefficient;
    }

    function addReference(address payable _parent, address payable _child)
        internal
        whenNotPaused
        onlyGame
    {
        if (refParent[_child] != address(0)) {
            return;
        }
        if (_parent == _child) {
            return;
        }
        if (refDisabledTo[_child] != address(0)) {
            _parent = refDisabledTo[_child];
            refDisabledTo[_child] = address(0);
        }

        refParent[_child] = _parent;
        playerRefCount[_parent] = playerRefCount[_parent].add(1);
        emit AddReferral(_parent, _child);
    }


    function deleteReferences(address[] calldata _children) external onlyOwner {
        for (uint256 i = 0; i < _children.length; i++) {
            address parent = refParent[_children[i]];
            playerRefCount[parent] = playerRefCount[parent].sub(1);
            refParent[_children[i]] = address(0);
            refDisabledTo[_children[i]] = address(0);
        }
    }

    function disableReferences(address[] calldata _children)
        external
        onlyOwner
    {
        for (uint256 i = 0; i < _children.length; i++) {
            address payable parent = refParent[_children[i]];
            playerRefCount[parent]--;
            refParent[_children[i]] = address(0);
            refDisabledTo[_children[i]] = parent;
        }
    }

    function refMultiplier(address payable player)
        public
        view
        returns (uint256 multiplier)
    {
        uint256 refCnt = playerRefCount[player];
        multiplier = 100;
        if (refCnt > 25) multiplier = 200;
        else if (refCnt > 20) multiplier = 180;
        else if (refCnt > 15) multiplier = 160;
        else if (refCnt > 10) multiplier = 140;
        else if (refCnt > 5) multiplier = 120;
    }

    function processGameResult(
        bool win,
        address token,
        uint256 wager,
        uint256 reward,
        address payable player,
        address refAddr
    ) public whenNotPaused onlyGame {
        _today.wagered += wager;
        uint256 trxEquivalent = 0;
        if (token == address(0)) {
            trxEquivalent = wager;
            if (win) {
                _today.won = _today.won.add(reward);
                _today.sentBack = _today.sentBack.add(wager);
                player.transfer(reward);
            } else {
                _today.lose = _today.lose.add(wager);
            }
        } else {
            trxEquivalent = whiteList.tokenToSun(token, wager);
            if (win) {
                _today.won = _today.won.add(whiteList.tokenToSun(token, reward));
                withdrawToken(player, token, reward);
            } else {
                _today.lose = _today.lose.add(whiteList.tokenToSun(token, wager));
            }
        }
        trxEquivalent = trxEquivalent.mul(refMultiplier(player)).div(100);
        IWINR(_winrContract).mine(player, trxEquivalent, getDailyCoef(),_yesterday.wagered);
        addReference(address(uint160(refAddr)), player);
    }

    function getDailyCoef() public view returns (uint256 coef) {
        if (_yesterday.wagered == 0 || _yesterday.revenue == 0) {
            coef = 1;
        } else {
            coef = _yesterday
                .sharedProfit
                .mul(_yesterday.sharedProfit)
                .mul(_yesterday.sentBack)
                .div(_yesterday.wagered)
                .div(_yesterday.revenue);
            coef = coef == 0 ? 1 : coef;
        }
    }

    function totalStats() public view returns (uint256, uint256) {
        return (
            (_totalStats.wagered + _today.wagered),
            (_totalStats.won + _today.won)
        );
    }


    function getWinrContract() public view returns (address payable) {
        return _winrContract;
    }

    function setWinrContract(address payable _contract) external onlyOwner {
        _winrContract = _contract;
    }

    function setLottery(address payable _lottery) external onlyOwner {
        _lotteryContract = _lottery;
    }

    function distributeProfit(
        uint256 _amount,
        uint256[] calldata _amountsTRC20,
        ITRC20[] calldata _tokens
    ) external onlyOwner {

        if (_today.wagered <= _today.won) _today.revenue = 0;
        else _today.revenue = _today.wagered - _today.won;

        _tickId += 1;
        _totalStats.wagered += _today.wagered;
        _totalStats.won += _today.won;
        _averageStats.wagered += (_today.wagered + _averageStats.wagered) / 2;
        _averageStats.revenue += (_today.revenue + _averageStats.revenue) / 2;

        _lastTick = now;
        _today.profit = _today.revenue;
        require(
            _amount <= address(this).balance,
            "Can't send more than current contract's balance"
        );
        require(
            _amountsTRC20.length == _tokens.length,
            "tokens amounts list length must be equal to the tokens addresses list length"
        );
        address(_lotteryContract).transfer(_amount.mul(2).div(10));
        IWINR(_winrContract).tick.value(_amount.mul(8).div(10))();
        for (uint256 i = 0; i < _tokens.length; i++) {
            _tokens[i].transfer(
                _lotteryContract,
                _amountsTRC20[i].mul(2).div(10)
            );
            _tokens[i].transfer(_winrContract, _amountsTRC20[i].mul(8).div(10));
        }

        _today.sharedProfit = _amount;

        emit Tick(
            _today.profit,
            _today.revenue,
            _today.lose,
            _today.won,
            _today.wagered,
            _today.sharedProfit,
            _today.dailyCoefficient
        );

        _yesterday = _today;

        _today.wagered = 0;
        _today.profit = 0;
        _today.revenue = 0;
        _today.won = 0;
        _today.lose = 0;
        _today.sharedProfit = 0;

        (, , uint256 roundPayout, ) = IWINR(_winrContract).getActiveRound();
        _today.dailyCoefficient = getDailyCoef().mul(roundPayout).div(_yesterday.wagered).div(1000);
    }

    function setTopPlayers(
        address top1,
        address top2,
        address top3
    ) external onlyOwner {
        IWINR(_winrContract).setTopPlayers(top1, top2, top3);
    }

    function setTopPlayersMultipliers(
        uint8 top1multiplier,
        uint8 top2multiplier,
        uint8 top3multiplier
    ) external onlyOwner {
        IWINR(_winrContract).setTopPlayersMultipliers(
            top1multiplier,
            top2multiplier,
            top3multiplier
        );
    }
}