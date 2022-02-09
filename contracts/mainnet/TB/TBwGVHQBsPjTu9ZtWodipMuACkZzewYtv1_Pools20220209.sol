//SourceUnit: 质押收费质押池.sol

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'e0');
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'e0');
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, 'e0');
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'e0');
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}


interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    //     function transfer(address recipient, uint256 amount) external returns (bool);
    // function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);
}


library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, 'e0');
        (bool success,) = recipient.call{value : amount}('');
        require(success, 'e1');
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, 'e0');
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, 'e0');
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, 'e0');
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), 'e0');
        (bool success, bytes memory returndata) = target.call{value : weiValue}(data);
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
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

library SafeBEP20 {
    using SafeMath for uint256;
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

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, 'e0');
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), 'e1');
        }
    }
}

contract Context {
    constructor() internal {}
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), 'e0');
        _;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'e0');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface Token {
    function mint(address _to, uint256 _amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "e3");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}

interface pair {
    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

contract Pools20220209 is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
    using SafeBEP20 for IERC20;
    uint256 stakingrate = 1;

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    struct PoolInfoItem {
        uint256 pid;
        string poolname;
        IERC20 lpToken;
        uint256 allocPoint;
        uint256 lastRewardBlock;
        uint256 accCakePerShare;
        bool pool_status;
        uint256 staking_stock_length;
        uint256 withdrawrate;
        uint256 rewardrate;
        uint256 refererrate;
    }

    struct pairReservesItem {
        address token0;
        address token1;
        uint256 reserve0;
        uint256 reserve1;
        uint256 decimals0;
        uint256 decimals1;
        string symbol0;
        string symbol1;
        string name0;
        string name1;
    }

    Token public cake;
    address public devaddr;
    uint256 public cakePerBlock;
    uint256 public BONUS_MULTIPLIER = 1;
    uint256 public poolLength = 0;
    mapping(uint256 => PoolInfoItem) poolInfo;
    mapping(uint256 => mapping(address => UserInfo)) public userInfo;
    uint256 public totalAllocPoint = 0;
    uint256 public startBlock;

    event Deposit(address indexed user, uint256 indexed pid, uint256 amount, uint256 unlockTime);
    event Withdraw(address indexed user, uint256 indexed pid, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 indexed pid, uint256 amount);

    mapping(uint256 => mapping(address => uint256)) public staking_time;
    mapping(uint256 => mapping(address => uint256)) public unlock_time;
    mapping(uint256 => uint256) public stakingNumForPool;
    mapping(uint256 => mapping(address => uint256)) public pending_list;
    mapping(uint256 => mapping(address => uint256)) public allrewardList;
    mapping(address => bool) public white_list;
    mapping(address => address) public referer_list;
    mapping(address => bool) public not_first_staking;

    constructor(
    ) public {
        devaddr = msg.sender;
        startBlock = block.timestamp;
        totalAllocPoint = 0;
    }

    function setWhiteList(address[] memory _address_list) public onlyOwner {
        for (uint256 i = 0; i < _address_list.length; i++) {
            white_list[_address_list[i]] = true;
        }
    }

    function removeWhiteList(address[] memory _address_list) public onlyOwner {
        for (uint256 i = 0; i < _address_list.length; i++) {
            white_list[_address_list[i]] = false;
        }
    }

    function setStartBlock(uint256 _startBlock) public onlyOwner {
        startBlock = _startBlock;
    }

    function setStakingRate(uint256 _stakingrate) public onlyOwner {
        stakingrate = _stakingrate;
    }

    function setCakePerBlockAndCake(uint256 _cakePerBlock, Token _cake) public onlyOwner {
        cake = _cake;
        cakePerBlock = _cakePerBlock;
    }

    function updateMultiplier(uint256 multiplierNumber) public onlyOwner {
        BONUS_MULTIPLIER = multiplierNumber;
    }

    function addPool(string memory _poolname, uint256 _allocPoint, IERC20 _lpToken, bool _withUpdate, uint256 _staking_stock_length, uint256 _widthdrawrate, uint256 _rewardrate, uint256 _refererrate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.timestamp > startBlock ? block.timestamp : startBlock;
        totalAllocPoint = totalAllocPoint.add(_allocPoint);
        poolInfo[poolLength] = PoolInfoItem({
        pid : poolLength,
        poolname : _poolname,
        lpToken : _lpToken,
        allocPoint : _allocPoint,
        lastRewardBlock : lastRewardBlock,
        accCakePerShare : 0,
        pool_status : true,
        staking_stock_length : _staking_stock_length,
        withdrawrate : _widthdrawrate,
        rewardrate : _rewardrate,
        refererrate : _refererrate
        });
        poolLength = poolLength.add(1);
    }

    function MassAddPool(string memory _poolname, uint256 _allocPoint, IERC20 _lpToken, bool _withUpdate, uint256[] memory _staking_stock_length_list, uint256 _withdrawrate, uint256[] memory _rewardrate_list, uint256 _refererrate, bool[] memory _pool_status_list) public onlyOwner {
        require(_staking_stock_length_list.length == _rewardrate_list.length);
        uint256 _staking_stock_length;
        uint256 _rewardrate;
        for (uint256 i = 0; i < _staking_stock_length_list.length; i++)
        {
            _staking_stock_length = _staking_stock_length_list[i];
            _rewardrate = _rewardrate_list[i];
            if (_withUpdate) {
                massUpdatePools();
            }
            uint256 lastRewardBlock = block.timestamp > startBlock ? block.timestamp : startBlock;
            totalAllocPoint = totalAllocPoint.add(_allocPoint);
            poolInfo[poolLength] = PoolInfoItem({
            pid : poolLength,
            poolname : _poolname,
            lpToken : _lpToken,
            allocPoint : _allocPoint,
            lastRewardBlock : lastRewardBlock,
            accCakePerShare : 0,
            pool_status : _pool_status_list[i],
            staking_stock_length : _staking_stock_length,
            withdrawrate : _withdrawrate,
            rewardrate : _rewardrate,
            refererrate : _refererrate
            });
            poolLength = poolLength.add(1);
        }
    }

    function setPool(string memory _poolname, uint256 _pid, uint256 _allocPoint, IERC20 _lpToken, bool _withUpdate, uint256 _staking_stock_length, uint256 _widthdrawrate, uint256 _rewardrate, uint256 _refererrate) public onlyOwner {
        if (_withUpdate) {
            massUpdatePools();
        }
        totalAllocPoint = totalAllocPoint.sub(poolInfo[_pid].allocPoint).add(_allocPoint);
        poolInfo[_pid].poolname = _poolname;
        poolInfo[_pid].allocPoint = _allocPoint;
        poolInfo[_pid].lpToken = _lpToken;
        poolInfo[_pid].staking_stock_length = _staking_stock_length;
        poolInfo[_pid].withdrawrate = _widthdrawrate;
        poolInfo[_pid].rewardrate = _rewardrate;
        poolInfo[_pid].refererrate = _refererrate;
    }

    function enablePool(uint256 _pid) public onlyOwner {
        poolInfo[_pid].pool_status = true;
    }

    function disablePool(uint256 _pid) public onlyOwner {
        poolInfo[_pid].pool_status = false;
    }

    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        return _to.sub(_from).mul(BONUS_MULTIPLIER);
    }

    function pendingCake(uint256 _pid, address _user) public view returns (uint256) {
        PoolInfoItem storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][_user];
        uint256 accCakePerShare = pool.accCakePerShare;
        uint256 lpSupply = stakingNumForPool[_pid];
        if (block.timestamp > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.timestamp);
            uint256 cakeReward = multiplier.mul(cakePerBlock).mul(pool.allocPoint).div(totalAllocPoint);
            accCakePerShare = accCakePerShare.add(cakeReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accCakePerShare).div(1e12).sub(user.rewardDebt);
    }

    function massUpdatePools() public {
        for (uint256 pid = 0; pid < poolLength; ++pid) {
            updatePool(pid);
        }
    }

    function updatePool(uint256 _pid) public {
        PoolInfoItem storage pool = poolInfo[_pid];
        if (block.timestamp <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = stakingNumForPool[_pid];
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.timestamp;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.timestamp);
        uint256 cakeReward = multiplier.mul(cakePerBlock).mul(pool.allocPoint).div(totalAllocPoint);
        cake.mint(address(this), cakeReward);
        pool.accCakePerShare = pool.accCakePerShare.add(cakeReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.timestamp;
    }

    function isContract(address _address) public view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(_address)
        }
        return size > 0;
    }

    function deposit(uint256 _pid, uint256 _amount, address _referer) public nonReentrant {
        if (!not_first_staking[msg.sender] && _referer != address(0)) {
            referer_list[msg.sender] = _referer;
            not_first_staking[msg.sender] = true;
        }
        require(!isContract(msg.sender), "k0");
        require(_amount > 0, "k01");
        require(poolInfo[_pid].pool_status, 'e0');
        PoolInfoItem storage pool = poolInfo[_pid];
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accCakePerShare).div(1e12).sub(user.rewardDebt);
            if (pending > 0) {
                pending_list[_pid][msg.sender] = pending_list[_pid][msg.sender].add(pending);
            }
        }
        if (_amount > 0) {
            uint256 oldAmount = pool.lpToken.balanceOf(address(this));
            uint256 depositrate = uint256(100).sub(stakingrate);
            pool.lpToken.safeTransferFrom(address(msg.sender), devaddr, _amount.mul(stakingrate).div(100));
            pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount.mul(depositrate).div(100));
            uint256 newAmount = pool.lpToken.balanceOf(address(this));
            uint256 addAmount = newAmount.sub(oldAmount);
            stakingNumForPool[_pid] = stakingNumForPool[_pid].add(addAmount);
            uint256 oldStaking = user.amount;
            uint256 newStaking = oldStaking.add(newAmount).sub(oldAmount);
            user.amount = newStaking;
            uint256 oldUnlockTime;
            uint256 newUnlockTime;
            if (unlock_time[_pid][msg.sender] == 0) {
                oldUnlockTime = block.timestamp.add(pool.staking_stock_length);
            } else {
                oldUnlockTime = unlock_time[_pid][msg.sender];
            }
            if (oldUnlockTime >= block.timestamp) {
                newUnlockTime = oldStaking.mul(oldUnlockTime.sub(block.timestamp)).add(addAmount.mul(pool.staking_stock_length)).div(newStaking);
            } else {
                newUnlockTime = addAmount.mul(pool.staking_stock_length).div(newStaking);
            }
            unlock_time[_pid][msg.sender] = block.timestamp.add(newUnlockTime);
            staking_time[_pid][msg.sender] = block.timestamp;
        }
        user.rewardDebt = user.amount.mul(pool.accCakePerShare).div(1e12);
        emit Deposit(msg.sender, _pid, _amount, unlock_time[_pid][msg.sender]);
    }

    function getReward(uint256 _pid) public nonReentrant {
        require(!isContract(msg.sender), "k0");
        PoolInfoItem storage pool = poolInfo[_pid];
        if (!white_list[msg.sender]) {
            require(block.timestamp > unlock_time[_pid][msg.sender], 'time limit');
        }
        UserInfo storage user = userInfo[_pid][msg.sender];
        updatePool(_pid);
        if (user.amount > 0) {
            uint256 pending = user.amount.mul(pool.accCakePerShare).div(1e12).sub(user.rewardDebt);
            if (pending > 0) {
                pending_list[_pid][msg.sender] = pending_list[_pid][msg.sender].add(pending);
            }
        }
        user.rewardDebt = user.amount.mul(pool.accCakePerShare).div(1e12);
        require(pending_list[_pid][msg.sender] > 0, 'e0');
        uint256 leftrate;
        uint256 rewardrate = pool.rewardrate;
        uint256 refererrate = pool.refererrate;
        if (referer_list[msg.sender] != address(0)) {
            leftrate = uint256(100).sub(rewardrate).sub(refererrate);
        } else {
            leftrate = uint256(100).sub(rewardrate);
        }
        allrewardList[_pid][msg.sender] = allrewardList[_pid][msg.sender].add(pending_list[_pid][msg.sender].mul(leftrate).div(100));
        safeCakeTransfer(msg.sender, pending_list[_pid][msg.sender].mul(leftrate).div(100));
        safeCakeTransfer(address(1), pending_list[_pid][msg.sender].mul(rewardrate).div(100));
        if (referer_list[msg.sender] != address(0)) {
            safeCakeTransfer(referer_list[msg.sender], pending_list[_pid][msg.sender].mul(refererrate).div(100));
        }
        pending_list[_pid][msg.sender] = 0;
    }

    function withdraw(uint256 _pid, uint256 _amount) public nonReentrant {
        require(!isContract(msg.sender), "k0");
        uint256 unlockTime = unlock_time[_pid][msg.sender];
        PoolInfoItem storage pool = poolInfo[_pid];
        uint256 withdrawrate = pool.withdrawrate;
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 allAmount = _amount;
        uint256 fee = allAmount.mul(withdrawrate).div(100);
        uint256 left = allAmount.sub(fee);
        require(user.amount >= _amount, "e0");
        updatePool(_pid);
        uint256 pending = user.amount.mul(pool.accCakePerShare).div(1e12).sub(user.rewardDebt);
        if (pending > 0) {
            pending_list[_pid][msg.sender] = pending_list[_pid][msg.sender].add(pending);
        }
        if (_amount > 0) {
            user.amount = user.amount.sub(_amount);
            if (block.timestamp >= unlockTime) {
                pool.lpToken.safeTransfer(address(msg.sender), allAmount);
            } else {
                pool.lpToken.safeTransfer(address(msg.sender), left);
                pool.lpToken.safeTransfer(devaddr, fee);
            }
        }
        user.rewardDebt = user.amount.mul(pool.accCakePerShare).div(1e12);
        stakingNumForPool[_pid] = stakingNumForPool[_pid].sub(_amount);
        emit Withdraw(msg.sender, _pid, _amount);
    }

    function emergencyWithdraw(uint256 _pid) public nonReentrant {
        require(!isContract(msg.sender), "k0");
        PoolInfoItem storage pool = poolInfo[_pid];
        uint256 withdrawrate = pool.withdrawrate;
        UserInfo storage user = userInfo[_pid][msg.sender];
        uint256 allAmount = user.amount;
        uint256 fee = allAmount.mul(withdrawrate).div(100);
        uint256 left = allAmount.sub(fee);
        uint256 unlockTime = unlock_time[_pid][msg.sender];
        if (block.timestamp < unlockTime) {
            pool.lpToken.safeTransfer(devaddr, fee);
            pool.lpToken.safeTransfer(address(msg.sender), left);
        } else {
            pool.lpToken.safeTransfer(address(msg.sender), allAmount);
        }
        emit EmergencyWithdraw(msg.sender, _pid, allAmount);
        stakingNumForPool[_pid] = stakingNumForPool[_pid].sub(allAmount);
        user.amount = 0;
        user.rewardDebt = 0;
    }

    function safeCakeTransfer(address _to, uint256 _amount) internal {
        uint256 cakeBal = cake.balanceOf(address(this));
        if (_amount > cakeBal) {
            cake.transfer(_to, cakeBal);
        } else {
            cake.transfer(_to, _amount);
        }
    }

    function setdev(address _devaddr) public {
        require(msg.sender == devaddr || msg.sender == owner(), "e0");
        devaddr = _devaddr;
    }

    struct getInfoForUserItem {
        PoolInfoItem poolinfo;
        UserInfo userinfo;
        uint256 unlockTime;
        uint256 stakingTime;
        uint256 pendingAmount;
        uint256 pendingCake;
        uint256 allPendingReward;
        uint256 stakingNumAll;
        uint256 allreward;
        uint256 lpTokenBalance;
        uint256 totalAllocPoint;
    }

    function getInfoForUser(uint256 _pid, address _user) public view returns (getInfoForUserItem memory getInfoForUserInfo) {
        getInfoForUserInfo.poolinfo = poolInfo[_pid];
        getInfoForUserInfo.userinfo = userInfo[_pid][_user];
        getInfoForUserInfo.unlockTime = unlock_time[_pid][_user];
        getInfoForUserInfo.stakingTime = staking_time[_pid][_user];
        getInfoForUserInfo.pendingAmount = pending_list[_pid][_user];
        uint256 pending = pendingCake(_pid, _user);
        getInfoForUserInfo.pendingCake = pending;
        getInfoForUserInfo.allPendingReward = pending_list[_pid][_user].add(pending);
        getInfoForUserInfo.stakingNumAll = stakingNumForPool[_pid];
        getInfoForUserInfo.allreward = allrewardList[_pid][_user];
        getInfoForUserInfo.lpTokenBalance = poolInfo[_pid].lpToken.balanceOf(_user);
        getInfoForUserInfo.totalAllocPoint = totalAllocPoint;
    }

    function MassGetInfoForUser(address _user) external view returns (getInfoForUserItem[] memory getInfoForUserInfoList) {
        getInfoForUserInfoList = new getInfoForUserItem[](poolLength);
        for (uint256 i = 0; i < poolLength; i++) {
            getInfoForUserInfoList[i] = getInfoForUser(i, _user);
        }
    }

    function getTokensReserves(address[] memory _pairList) public view returns (pairReservesItem[] memory pairReservesList) {
        pairReservesList = new pairReservesItem[](_pairList.length);
        for (uint256 i = 0; i < _pairList.length; i++)
        {
            address _pair = _pairList[i];
            address token0 = pair(_pair).token0();
            address token1 = pair(_pair).token1();
            (uint256 reserve0, uint256 reserve1,) = pair(_pair).getReserves();
            pairReservesList[i] = pairReservesItem(token0, token1, reserve0, reserve1, IERC20(token0).decimals(), IERC20(token1).decimals(), IERC20(token0).symbol(), IERC20(token1).symbol(), IERC20(token0).name(), IERC20(token1).name());
        }
    }
}