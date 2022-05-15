//SourceUnit: DaoPool.sol

pragma solidity 0.6.12;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
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
        require(c / a == b, 'SafeMath: multiplication overflow');
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

    function div(uint256 a,uint256 b,string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    function mod(uint256 a,uint256 b,string memory errorMessage) internal pure returns (uint256) {
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

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable {
    address private _owner;

    constructor() internal {
        _owner = msg.sender;
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, 'Ownable: caller is not the owner');
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _owner = newOwner;
    }
}

contract DaoPool is Ownable {
    using SafeMath for uint256;
    
    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
        uint256 downlineAmount;
        uint256 withdrawn;
    }

    struct User {
        uint256 id;
        address upline;
    }
    mapping(address => User) public users;
    mapping(uint256 => address) public id2Address;
    uint256 public nextUserId = 2;

    struct PoolInfo {
        IERC20 lpToken;
        uint256 allocPoint;  
        uint256 lastRewardBlock;
        uint256 accdaoPerShare;
    }

    IERC20 public dao;
    uint256 public daoPerBlock;
    uint256 public daoStakeAmount;

    PoolInfo[] public poolInfo;
    mapping (uint256 => mapping (address => UserInfo)) public userInfo;

    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;
    uint256 public refRate = 0;
    uint256 public minDepositRefAmount = 100*10**6;
    uint256 public totalLP;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);

    constructor(IERC20 _dao, uint256 _daoPerBlock, uint256 _startBlock, address _first) public {
        dao = _dao;
        daoPerBlock = _daoPerBlock;
        startBlock = _startBlock;

        poolInfo.push(PoolInfo({
            lpToken: _dao,
            allocPoint: 0,
            lastRewardBlock: startBlock,
            accdaoPerShare: 0
        }));

        id2Address[1] = _first;
        users[_first].id = 1;
    }

    function register(address up) external {
        require(isUserExists(up), "up not exist");
        require(!isUserExists(msg.sender), "user exist");
        
        uint256 id = nextUserId++;
        users[msg.sender].id = id;
        users[msg.sender].upline = up;
        id2Address[id] = msg.sender;
    }

    function add(uint256 _allocPoint, IERC20 _lpToken, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo.push(PoolInfo({
            lpToken: _lpToken,
            allocPoint: _allocPoint,
            lastRewardBlock: lastRewardBlock,
            accdaoPerShare: 0
        }));
    }

    function set(uint256 _pid, uint256 _allocPoint, bool _withUpdate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].allocPoint = _allocPoint;
    }

    function setR(uint256 r) public onlyOwner {
        refRate = r;
    }

    function setRA(uint256 ra) public onlyOwner {
        minDepositRefAmount = ra;
    }

    function setPer(uint256 p) public onlyOwner {
        massUpdatePools();
        daoPerBlock = p;
    }

    function massUpdatePools() public {
        uint256 length = poolInfo.length;
        for (uint256 pid = 0; pid < length; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public {
        PoolInfo storage pool = poolInfo[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if(_pid == 0) {
            lpSupply = daoStakeAmount;
        }
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 blockNum = block.number.sub(pool.lastRewardBlock);
        uint256 daoReward = blockNum.mul(daoPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        pool.accdaoPerShare = pool.accdaoPerShare.add( daoReward.mul(1e12).div(lpSupply) );
        pool.lastRewardBlock = block.number;
    }

    function deposit(uint256 _pid, uint256 _amount) public {
        require(isUserExists(msg.sender), "user not exist");
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];

        _addGen(msg.sender, _pid, _amount);
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accdaoPerShare).div(1e12).sub(user.rewardDebt);
            payout(_pid, msg.sender, pending);
        }
        if (_amount > 0) {
            pool.lpToken.transferFrom(address(msg.sender), address(this), _amount);
            user.amount = user.amount.add(_amount);
            if(_pid == 0) {
                daoStakeAmount = daoStakeAmount.add(_amount);
            }
            totalLP = totalLP.add(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accdaoPerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount);
    }

    function _addGen(address addr, uint256 pid, uint256 amount) private {
        address up = users[addr].upline;
        for(; up != address(0);) {
            userInfo[pid][up].downlineAmount = userInfo[pid][up].downlineAmount.add(amount);
            up = users[up].upline;
        }
    }

    function withdraw(uint256 _pid, uint256 _amount) public {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        require(user.amount >= _amount, "withdraw: not good");

        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accdaoPerShare).div(1e12).sub(user.rewardDebt);
        payout(_pid, msg.sender, pending);

        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.transfer(msg.sender, _amount);
            if(_pid == 0) {
                daoStakeAmount = daoStakeAmount.sub(_amount);
            }
            _removeGen(msg.sender, _pid, _amount);
            totalLP = totalLP.sub(_amount);
        }
        user.rewardDebt = user.amount.mul(pool.accdaoPerShare).div(1e12);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function _removeGen(address addr, uint256 pid, uint256 amount) private {
        address up = users[addr].upline;
        for(; up != address(0);) {
            userInfo[pid][up].downlineAmount = userInfo[pid][up].downlineAmount.sub(amount);
            up = users[up].upline;
        }
    }

    function payout(uint256 _pid, address addr, uint256 pending) private {
        if(pending > 0) {
            dao.transfer(addr, pending);
            userInfo[_pid][addr].withdrawn += pending;
            address up = users[addr].upline;
            if(up != address(0) && refRate > 0) {
                UserInfo memory upInfo = userInfo[_pid][up];
                if(upInfo.amount >= minDepositRefAmount){
                    uint256 reward = pending*refRate/100;
                    dao.transfer(up, reward);
                    userInfo[_pid][up].withdrawn += reward;
                }
            }
        }
    }

    function emergencyWithdraw(uint256 _pid) external {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        pool.lpToken.transfer(address(msg.sender), user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    function isUserExists(address addr) public view returns (bool) {
        return users[addr].id != 0;
    }

    function poolLength() external view returns (uint256) {
        return poolInfo.length;
    }

    function pendingdao(uint256 _pid, address _user) external view returns (uint256) {
        PoolInfo storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accdaoPerShare = pool.accdaoPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if(_pid == 0) {
            lpSupply = daoStakeAmount;
        }
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 blockNum = block.number.sub(pool.lastRewardBlock);
            uint256 daoReward = blockNum.mul(daoPerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accdaoPerShare = accdaoPerShare.add(daoReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accdaoPerShare).div(1e12).sub(user.rewardDebt);
    }

    function userInfoById(uint256 userid, uint256 pid) external view returns (address, address, uint256, uint256, uint256) {
        address addr = id2Address[userid];
        return userInfoByAddr(addr, pid);
    }

    function userInfoByAddr(address addr, uint256 pid) public view returns (address, address, uint256, uint256, uint256) {
        UserInfo storage o = userInfo[pid][addr];
        return (addr, users[addr].upline, o.amount, o.downlineAmount, o.withdrawn);
    }
}