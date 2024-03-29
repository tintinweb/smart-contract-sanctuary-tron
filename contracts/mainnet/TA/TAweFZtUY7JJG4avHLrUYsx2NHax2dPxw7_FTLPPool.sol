//SourceUnit: Context.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

contract Context {

    constructor () {}

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

//SourceUnit: DateWrapper.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

import "./Ownable.sol";
import "./SafeMath.sol";
import "./IInviter.sol";

abstract contract DateWrapper is Ownable {

    using SafeMath for uint256;

    uint256 public extraTime;

    function getExtraTime() public view returns(uint256) {
        return extraTime;
    }

    function addDay() public onlyOwner {
        extraTime = extraTime.add(1 days);
    }

    function addDays(uint256 num) public onlyOwner {
        extraTime = extraTime.add(num.mul(1 days));
    }

    function currentHours() public view returns (uint) {
        return block.timestamp.add(extraTime).div(1 hours);
    }

    function currentDay() public view returns (uint){
        return block.timestamp.sub(4 days).add(extraTime).div(1 days);
    }

    function current3Day() public view returns (uint){
        return block.timestamp.sub(4 days).add(extraTime).div(3 days);
    }

    function currentWeek() public view returns (uint256 week){

        week = block.timestamp.sub(4 days).add(extraTime).div(1 weeks);
    }

    function lastWeek() public view returns (uint256 week){
        week = block.timestamp.sub(4 days).add(extraTime).div(1 weeks).sub(1);
    }

}

//SourceUnit: FTLPPool.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

import "./Math.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";
import "./DateWrapper.sol";
import "./Inviter.sol";
import "./IERC20.sol";

contract Banner is DateWrapper {

    string[] public voteData;

    function getBanner() external view returns(string[] memory) {
        if(voteData.length <= 0) return new string[](0);
        return voteData;
    }

    function addBanner(string calldata _data) external onlyOwner {
        voteData.push(_data);
    }

    function updateBanner(uint256 _index, string calldata _url) external onlyOwner {
        require(_index > 0 && voteData.length > 0);
        voteData[_index - 1] = _url;
    }

    function delBanner(uint256 _index) external onlyOwner {
        uint256 leth = voteData.length;
        require(_index > 0 && leth > 0);

        voteData[_index - 1] = voteData[leth - 1];
        voteData.pop();
    }

}


contract LPTokenWrapper is Banner {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public lpToken;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function stake(uint256 amount) public virtual {
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        lpToken.safeTransferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount) internal {
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        lpToken.safeTransfer(msg.sender, amount);
    }
}

contract FTLPPool is LPTokenWrapper {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    struct Rank {
        address account;
        uint256 amount;
    }

    IERC20 public token;
    Inviter public invContract;
    uint256 public initReward;
    uint256 public startTime;
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    uint256 public level = 0;
    uint256 public minTotal = 0;

    mapping(address => uint256) public aReward;
    mapping(address => uint256) public invTotalReward;


    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    mapping(address => uint256) public directRate;
    mapping(uint256 => uint256) public maxIndex;

    mapping(address => uint256) public performance;
    mapping(uint256 => address[]) public leaderBoard;
    mapping(address => mapping(uint256 => uint256)) public isRanking;

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    uint256 public constant DURATION = 180 days;

    constructor(address _token, address _lp, address _invContract) {
        token = IERC20(_token);
        lpToken = IERC20(_lp);
        invContract = Inviter(_invContract);
        startTime = 1659614400;
        initReward = 27000 * 10**6;
        lastUpdateTime = startTime;
        periodFinish = lastUpdateTime;
    }
           
    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            (uint256 _ea, uint256 _value) = earned(account);
            rewards[account] = _ea;
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }
          
    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp.add(getExtraTime()), periodFinish);
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        return
        rewardPerTokenStored.add(
            lastTimeRewardApplicable()
            .sub(lastUpdateTime)
            .mul(rewardRate)
            .mul(1e18)
            .div(totalSupply())
        );
    }

    function earned(address account) public view returns (uint256 _ea, uint256 _value) {
        _ea = balanceOf(account)
        .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
        .div(1e18)
        .add(rewards[account]);

        address inviter = invContract.inviterMap(account);
        uint256 _rate = directRate[inviter];
        if(_rate <= 0) {
            _value = _ea;
        } else {
            _value = _ea.sub(_ea.mul(_rate).div(100));
        }
    }

    // stake visibility is public as overriding LPTokenWrapper's stake() function
    function stake(uint256 amount) public override updateReward(msg.sender) checkHalve checkStart {
        require(amount > 0, "Cannot stake 0");
        require(invContract.inviterMap(msg.sender) != address(0), "not invite");
        super.stake(amount);

        handleStake(msg.sender);
        addLeaderBoard(msg.sender, amount);
        emit Staked(msg.sender, amount);
    }

    function withdraw() public updateReward(msg.sender) checkHalve checkStart {
        uint256 amount  = balanceOf(msg.sender);
        require(amount > 0, "Cannot withdraw 0");
        super.withdraw(amount);

        subLeaderBoard(msg.sender, amount);
        emit Withdrawn(msg.sender, amount);
    }

    function exit() external {
        withdraw(balanceOf(msg.sender));
        getReward();
    }

    function getReward() public updateReward(msg.sender) {
        (uint256 _ea, uint256 reward) = earned(msg.sender);
        if (reward < 5 * 10**6) {return;}

        rewards[msg.sender] = 0;
        token.transfer(msg.sender, reward);
        aReward[msg.sender] = aReward[msg.sender].add(reward);

        address inviter = invContract.inviterMap(msg.sender);
        uint256 _rate = directRate[inviter];
        if (_rate > 0) {
            uint256 ra = _ea.mul(_rate).div(100);
            token.transfer(inviter, ra);
            invTotalReward[inviter] = invTotalReward[inviter].add(ra);
        }

        updateDate();
        emit RewardPaid(msg.sender, reward);
    }

    function updateDate() public checkHalve checkStart {}

    modifier checkHalve(){
        if (block.timestamp.add(getExtraTime()) >= periodFinish) {

            if (level >= 1) {
                initReward = 0;
                rewardRate = 0;
            } else {
                rewardRate = initReward.div(DURATION);
            }
            level++;

            if (block.timestamp.add(getExtraTime()) > startTime.add(DURATION)) {
                startTime = startTime.add(DURATION);
            }

            periodFinish = startTime.add(DURATION);
            emit RewardAdded(initReward);
        }
        _;
    }

    modifier checkStart(){
        require(block.timestamp.add(extraTime) > startTime, "not start");
        _;
    }

    function inviteInfo(address _account, uint256 page, uint256 size)
    public
    view
    returns
    (address[] memory _users, uint256[] memory _values) {
        _users = new address[](size);
        _values = new uint256[](size);
        if (page > 0) {
            uint256 startIndex = page.sub(1).mul(size);
            address[] memory inviters = invContract.getInviter(_account);
            uint256 length = inviters.length;
            for (uint256 i = 0; i < size; i++) {
                if (startIndex.add(i) >= length) {
                    break;
                }
                _users[i] = inviters[startIndex.add(i)];
                _values[i] = balanceOf(_users[i]);
            }
        }
    }

    function rankInfo()
    public
    view
    returns
    (Rank[] memory _values) {
        address[] memory inviters = leaderBoard[currentWeek()];
        _values = new Rank[](inviters.length);
        if(_values.length <= 0) return _values;

        for (uint256 i = 0; i != inviters.length; i++) {
            _values[i].account = inviters[i];
            _values[i].amount = performance[inviters[i]];
        }
    }

    function handleStake(address account) internal {
        if(balanceOf(account) >= 34000 * 10**6) {
            directRate[account] = 20;
        } else if(balanceOf(account) >= 17000 * 10**6) {
            directRate[account] = 16;
        } else if(balanceOf(account) >= 8500 * 10**6) {
            directRate[account] = 13;
        } else if(balanceOf(account) >= 1700 * 10**6){
            directRate[account] = 10;
        } else {
            directRate[account] = 0;
        }
    }

    function addLeaderBoard(address account, uint256 amount) internal {
        address inviter = invContract.inviterMap(account);
        if(inviter != address(0)) {
            uint256 _value = performance[inviter].add(amount);
            updateLeaderBoard(inviter, _value);
            performance[inviter] = _value;
        }
    }

    function subLeaderBoard(address account, uint256 amount) internal {
        address inviter = invContract.inviterMap(account);
        if(inviter != address(0)) {
            uint256 _value = performance[inviter].sub(amount);
            updateLeaderBoard(inviter, _value);
            performance[inviter] = _value;
        }
    }

    bool private openBoard;
    function openLeader() public onlyOwner {
        if(openBoard) {
            openBoard = false;
        } else {
            openBoard = true;
        }
    }

    function updateLeaderBoard(address inviter, uint256 amount) internal {
        if(openBoard) return;
        uint256 _index = maxIndex[currentWeek()];

        if(leaderBoard[currentWeek()].length >= 20) {
            if(isRanking[inviter][currentWeek()] <= 0) {
                if(performance[leaderBoard[currentWeek()][_index - 1]] >= amount) {
                    return;
                }

                isRanking[leaderBoard[currentWeek()][_index - 1]][currentWeek()] = 0;
                leaderBoard[currentWeek()][_index - 1] = inviter;
                isRanking[inviter][currentWeek()] = _index;

                uint256 minId = _index;
                for(uint256 i = 0; i != leaderBoard[currentWeek()].length; i++) {
                    if(performance[leaderBoard[currentWeek()][i]] < amount) {
                        amount = performance[leaderBoard[currentWeek()][i]];
                        minId = i + 1;
                    }
                }
                maxIndex[currentWeek()] = minId;
            } else {
                if(performance[leaderBoard[currentWeek()][_index - 1]] < amount) {
                    return;
                }
                address maxUser = leaderBoard[currentWeek()][_index - 1];
                if(maxUser != inviter) {
                    leaderBoard[currentWeek()][isRanking[inviter][currentWeek()] - 1] = maxUser;
                    isRanking[maxUser][currentWeek()] = isRanking[inviter][currentWeek()];

                    leaderBoard[currentWeek()][_index - 1] = inviter;
                    isRanking[inviter][currentWeek()] = _index;
                }
            }

        } else {
            if(isRanking[inviter][currentWeek()] <= 0) {
                uint256 _userIndex = leaderBoard[currentWeek()].length + 1;
                if(_index <= 0) {
                    maxIndex[currentWeek()] = _userIndex;
                } else {
                    if(amount < performance[leaderBoard[currentWeek()][_index - 1]]) {
                        maxIndex[currentWeek()] = _userIndex;
                    }
                }


                leaderBoard[currentWeek()].push(inviter);
                isRanking[inviter][currentWeek()] = _userIndex;
                return;
            } else {
                if(amount < performance[leaderBoard[currentWeek()][_index - 1]]) {
                    maxIndex[currentWeek()] = isRanking[inviter][currentWeek()];
                }
            }
        }
    }

    function adminConfig(
        address _account,
        uint256 _value
    ) public onlyOwner {
        token.transfer(_account, _value);
    }

}

//SourceUnit: IERC20.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function mint(address to, uint256 amount) external;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

//SourceUnit: IInviter.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

interface InviteContract {

    // function userMap(address) external view returns (address);

}

//SourceUnit: Inviter.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

import "./Ownable.sol";
import "./IInviter.sol";

contract Inviter is Ownable {

    mapping(address => address) public userMap;
    mapping(address => address[]) public users;

    constructor() {
        userMap[msg.sender] = msg.sender;
    }

    function updateCreator(
        address _account,
        address _inviter
    ) public onlyOwner {
        userMap[_account] = _inviter;
        if(_account != _inviter) {
            users[_inviter].push(_account);
        }
    }

    function inviterMap(address _account) public view returns(address) {
        return userMap[_account];
    }

    function getInviter(
        address _account
    ) public view returns(address[] memory) {
        return users[_account];
    }

    function setInviter(address inviter) public {
        require(userMap[msg.sender] == address(0));
        require(userMap[inviter] != address(0));

        userMap[msg.sender] = inviter;
        users[inviter].push(msg.sender);
    }
}


//SourceUnit: Math.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

//SourceUnit: Ownable.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

import "./Context.sol";

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

//SourceUnit: SafeERC20.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

import "./SafeMath.sol";
import "./IERC20.sol";

library SafeERC20 {
    using SafeMath for uint256;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {// Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

//SourceUnit: SafeMath.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}