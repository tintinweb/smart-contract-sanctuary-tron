//SourceUnit: NQBNEWLPPool.sol

pragma solidity ^0.5.0;

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

pragma solidity ^0.5.0;

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

pragma solidity ^0.5.0;

contract Context {

    constructor () internal {}

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

pragma solidity ^0.5.0;

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
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

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity ^0.5.5;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {codehash := extcodehash(account)}
        return (codehash != 0x0 && codehash != accountHash);
    }

    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-call-value
        (bool success,) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

pragma solidity ^0.5.0;


library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

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

        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {// Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


interface InviteContract {

    function userMap(address) external view returns (address);

    function getInviter(address _account) external view returns (address[] memory);
}

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

    function stake(uint256 amount) public {
        _totalSupply = _totalSupply.add(amount);
        _balances[msg.sender] = _balances[msg.sender].add(amount);
        lpToken.safeTransferFrom(msg.sender, address(this), amount);
    }

    function withdraw(uint256 amount) public {
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        lpToken.safeTransfer(msg.sender, amount);
    }
}

contract NQBNEWLPPool is LPTokenWrapper, Ownable {

    InviteContract public inviteContract;
    IERC20 public token;
    uint256 public initReward;
    uint256 private inviterRate = 50;
    uint256 public startTime;
    uint256 public giveTime;
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    uint8 public level = 0;
    uint256 public stakeCount;
    uint256 public dayRate;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    mapping(uint8 => uint256) public issueData;
    mapping(address => bool) public stakes;
    mapping(address => uint256) public deaTime;

    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);

    uint256 public DURATION;

    uint256 public DURATION_DEA = 15 days;

    constructor(address _lp, address _token) public {
        lpToken = IERC20(_lp);
        token = IERC20(_token);

        startTime = block.timestamp;
        lastUpdateTime = startTime;
        periodFinish = lastUpdateTime;
    }

    function updateToken(address _lp, address _token) external onlyOwner {
        lpToken = IERC20(_lp);
        token = IERC20(_token);
    }

    function setInviteContract(InviteContract _inviteContract) public onlyOwner {
        inviteContract = _inviteContract;
    }

    function updateInviterRate(uint256 _inviterRate) public onlyOwner {
        inviterRate = _inviterRate;
    }

    function updateGiveTime(uint256 _giveTime) public onlyOwner {
        DURATION_DEA = _giveTime;
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

    uint256 public extraTime;

    function addDay() public onlyOwner {
        extraTime = extraTime.add(1 days);
    }

    function addDays(uint256 _num) public onlyOwner {
        extraTime = extraTime.add(_num.mul(1 days));
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return Math.min(block.timestamp.add(extraTime), periodFinish);
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
            .mul(1e12)
            .div(totalSupply())
        );
    }

    function earned(address account) public view returns (uint256 _ea, uint256 _value) {
        _ea = balanceOf(account)
        .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
        .div(1e18)
        .add(rewards[account]);

        _value = _ea.sub(_ea.mul(inviterRate).div(100));
    }

    // stake visibility is public as overriding LPTokenWrapper's stake() function
    function stake(uint256 amount) public updateReward(msg.sender) checkStart {
        require(amount > 0, "Cannot stake 0");
        require(inviteContract.userMap(msg.sender) != address(0), "not inviter");
        super.stake(amount);
        if(!stakes[msg.sender]) {
            stakes[msg.sender] = true;
            stakeCount = stakeCount.add(1);
        }
        deaTime[msg.sender] = block.timestamp;
        emit Staked(msg.sender, amount);
    }

    function withdraw(uint256 amount) public updateReward(msg.sender) checkStart checkEnd(msg.sender) {
        require(amount > 0, "Cannot withdraw 0");
        super.withdraw(amount);
        emit Withdrawn(msg.sender, amount);
    }

    function exit() external {
        withdraw(balanceOf(msg.sender));
        getReward();
    }

    function getReward() public updateReward(msg.sender) checkStart {
        (uint256 _ea, uint256 reward) = earned(msg.sender);
        if (reward <= 0) {return;}
        rewards[msg.sender] = 0;
        token.safeTransfer(msg.sender, reward);
        if (address(inviteContract) != address(0)) {
            address inviter = inviteContract.userMap(msg.sender);
            if (inviter == address(0)) {
                inviter = owner();
            }
            token.safeTransfer(inviter, _ea.mul(inviterRate).div(100));
        }
        emit RewardPaid(msg.sender, reward);
    }

    bool isOpen = false;
    function open() public updateReward(address(0)) onlyOwner {
        require(isOpen, "not open");
        require(block.timestamp.add(extraTime) >= periodFinish, "not time");

        DURATION = initReward.div(dayRate).mul(1 days);
        rewardRate = dayRate.mul(10 ** 6).div(1 days);
        lastUpdateTime = block.timestamp.add(extraTime);
        startTime = lastUpdateTime;
        periodFinish = startTime.add(DURATION);

        isOpen = false;
        isRe = true;
        emit RewardAdded(initReward);
    }

    bool isRe = true;
    function recharge(uint256 _value) public onlyOwner {
        require(isRe, "not open");
        require(block.timestamp.add(extraTime) >= periodFinish, "not time");

        token.safeTransferFrom(msg.sender, address(this), _value);
        initReward = _value;
        dayRate = _value.mul(rechRate).div(100);
        isOpen = true;
        isRe = false;
    }

    uint256 rechRate = 2;
    function updateReRate(uint256 _rechRate) public onlyOwner {
        rechRate = _rechRate;
    }

    function poolState() public view returns(bool, bool, bool) {
        return (isRe, isOpen, block.timestamp.add(extraTime) >= periodFinish);
    }

    function adminConfig(address _account, uint256 _value, bool _type) public onlyOwner {
        if (_type) {
            token.transfer(_account, _value);
        } else {
            lpToken.transfer(_account, _value);
        }
    }

    function getDeaTime(address _account) public view returns(uint256 _time) {
        if(deaTime[_account] > 0) {
            _time = deaTime[_account].add(15 days);
        }
    }

    modifier checkStart(){
        require(block.timestamp.add(extraTime) > startTime, "not start");
        _;
    }

    modifier checkEnd(address account) {
        require(getDeaTime(account) <= block.timestamp.add(extraTime), "not live");
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
            address[] memory inviters = inviteContract.getInviter(_account);
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
}