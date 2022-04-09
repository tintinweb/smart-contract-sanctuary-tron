//SourceUnit: Address.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {codehash := extcodehash(account)}
        return (codehash != 0x0 && codehash != accountHash);
    }

    function toPayable(address account) internal pure returns (address) {
        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success,) = recipient.call{value : amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

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

//     function userMap(address) external view returns (address);

}

//SourceUnit: Inviter.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0;

import "./Ownable.sol";
import "./IInviter.sol";

abstract contract Inviter is Ownable {

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


//SourceUnit: METAPool.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0;

import "./Math.sol";
import "./Ownable.sol";
import "./SafeMath.sol";
import "./SafeERC20.sol";
import "./IERC20.sol";
import "./Inviter.sol";

contract LPTokenWrapper {

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

contract METAPool is LPTokenWrapper, Ownable, Inviter {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public token;
    uint256 public initReward;
    uint256 public startTime;
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    uint256 public level = 0;
    uint256 public minTotal = 0;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    uint256 public constant DURATION = 90 days;

    constructor(address _token, address _lp) {
        token = IERC20(_token);
        lpToken = IERC20(_lp);
        startTime = 1649391480;
        lastUpdateTime = startTime;
        periodFinish = lastUpdateTime;
    }

    modifier updateReward(address account) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            (uint256 _ea,) = earned(account);
            rewards[account] = _ea;
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }


    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp, periodFinish);
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

        _value = _ea.sub(_ea.mul(15).div(100));
    }

    function stake(uint256 amount) public override updateReward(msg.sender) checkHalve checkStart {
        require(amount > 0, "Cannot stake 0");
        require(inviterMap(msg.sender) != address(0), "not invite");
        super.stake(amount);
        emit Staked(msg.sender, amount);
    }

    function withdraw() public updateReward(msg.sender) checkHalve checkStart {
        uint256 amount  = balanceOf(msg.sender);
        require(amount > 0, "Cannot withdraw 0");
        super.withdraw(amount);
        emit Withdrawn(msg.sender, amount);
    }

    function exit() external {
        withdraw(balanceOf(msg.sender));
        getReward();
    }

    function getReward() public updateReward(msg.sender) {
        (uint256 _ea, uint256 reward) = earned(msg.sender);
        if (reward <= 0) {return;}

        rewards[msg.sender] = 0;
        token.transfer(msg.sender, reward);

        address invite = inviterMap(msg.sender);
        uint256 invReward = _ea.mul(10).div(100);
        if(invite == address(0)) {
            token.transfer(owner(), invReward);
        } else {
            token.transfer(invite, invReward);
        }

        address invites = inviterMap(invite);
        uint256 inv2Reward = _ea.mul(5).div(100);
        if(invites == address(0)) {
            token.transfer(owner(), inv2Reward);
        } else {
            token.transfer(invites, inv2Reward);
        }

        updateDate();
        emit RewardPaid(msg.sender, reward);
    }

    function updateDate() public checkHalve checkStart {}

    modifier checkHalve(){
        if (block.timestamp >= periodFinish) {

            if (level >= 4) {
                initReward = 0;
                rewardRate = 0;
            } else if(level == 3) {
                initReward = 112000000 * 10**token.decimals();
                rewardRate = initReward.div(DURATION);
            } else if(level == 2) {
                initReward = 84000000 * 10**token.decimals();
                rewardRate = initReward.div(DURATION);
            } else if(level == 1) {
                initReward = 56000000 * 10**token.decimals();
                rewardRate = initReward.div(DURATION);
            } else {
                initReward = 28000000 * 10**token.decimals();
                rewardRate = initReward.div(DURATION);
            }
            level++;

            if (block.timestamp > startTime.add(DURATION)) {
                startTime = startTime.add(DURATION);
            }

            periodFinish = startTime.add(DURATION);
            emit RewardAdded(initReward);
        }
        _;
    }

    modifier checkStart(){
        require(block.timestamp > startTime, "not start");
        _;
    }

    function adminConfig(address _account, uint256 _value) public onlyOwner {
        token.transfer(_account, _value);
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