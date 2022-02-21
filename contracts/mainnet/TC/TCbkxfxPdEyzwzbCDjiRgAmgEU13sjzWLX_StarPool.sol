//SourceUnit: Common.sol

pragma solidity ^0.5.13;

import './TRC20.sol';

contract Common {

    // 管理员地址
    mapping(address => bool) internal managerAddressList;

    // FB合约地址
    address constant fb_contract = address(0x41EAE52337A71DAE5B444916DC0DDA8CBBE50EA5DB);

    // FB提币地址
    address internal fb_draw_address = address(0x412979FE3D26174E48168D9D0285AA9275742E2337);

    address internal minter;

    // 返回代码常量：成功（0）
    uint constant SUCCESS = 0;

    // 返回代码常量：没权限（2）
    uint constant NOAUTH = 2002;

    // 数据不存在
    uint constant NODATA = 2003;

    // 数据已存在
    uint constant DATA_EXIST = 2004;

    modifier onlyAdmin() {
        require(
            msg.sender == minter || managerAddressList[msg.sender],
            "Only admin can call this."
        );
        _;
    }

    // 设置管理员地址
    function setManager(address userAddress) onlyAdmin public returns(uint){
        managerAddressList[userAddress] = true;
        return SUCCESS;
    }

    // 提取trx
    function drawTrx(address drawAddress, uint amount) onlyAdmin public returns(uint) {
        address(uint160(drawAddress)).transfer(amount * 10 ** 6);
        return SUCCESS;
    }

    // 提取其他代币
    function drawCoin(address contractAddress, address drawAddress, uint amount) onlyAdmin public returns(uint) {
        TRC20 token = TRC20(contractAddress);
        uint256 decimal = 10 ** uint256(token.decimals());
        token.transfer(drawAddress, amount * decimal);
        return SUCCESS;
    }

    constructor() public {
        minter = msg.sender;
    }
}


//SourceUnit: IJustswapPrice.sol

pragma solidity ^0.5.13;

contract IJustswapPrice {
    function getTokenPrice(address contractAddress) public view returns (uint256);
}


//SourceUnit: IUser.sol

pragma solidity ^0.5.13;

contract IUser {
    function addTradeAsset(address userAddress, uint amount) public;

    function addTradeList(address userAddress, uint amount, uint tradeType) public;

    function subAsset(address userAddress, uint amount) public;
}


//SourceUnit: SafeMath.sol

pragma solidity ^0.5.13;

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


//SourceUnit: StarPool.sol

pragma solidity ^0.5.13;

import "./SafeMath.sol";
import "./StarStorage.sol";
import './TRC20.sol';

contract StarPool is StarStorage {
    using SafeMath for uint256;


    // 获取产品期数
    function GetActivityList() public view returns (uint, uint[] memory, uint[] memory, uint[] memory, uint[] memory, uint[] memory, bool[] memory) {
        uint[] memory idReturn = new uint[](1);
        uint[] memory amountReturn = new uint[](1);
        uint[] memory buyAmountReturn = new uint[](1);
        uint[] memory startTimeReturn = new uint[](1);
        uint[] memory endTimeReturn = new uint[](1);
        bool[] memory openStatus = new bool[](1);

        for (uint i = 0; i < 1; i++) {
            PoolInfo memory pl = poolInfoList[i + 1];
            idReturn[i] = pl._id;
            amountReturn[i] = pl.totalAmount;
            buyAmountReturn[i] = pl.buyAmount;
            startTimeReturn[i] = pl.startTime;
            endTimeReturn[i] = pl.endTime;
            openStatus[i] = (activityIndex == (i + 1));
        }
        return (SUCCESS, idReturn, amountReturn, buyAmountReturn, startTimeReturn, endTimeReturn, openStatus);
    }

    // 获取包信息 
    function GetPackageList() public view returns (uint status, uint[] memory idReturn, int[] memory packageReturn, uint[] memory packageTotalReturn) {
        idReturn = new uint[](6);
        packageReturn = new int[](6);
        packageTotalReturn = new uint[](6);
        for (uint i = 0; i < 6; i++) {
            Package memory pi = poolInfoList[activityIndex].package[i + 1];
            if (pi._id > 0) {
                idReturn[i] = pi._id;
                packageReturn[i] = pi.amount;
                packageTotalReturn[i] = pi.total;
            }
        }
        status = SUCCESS;
    }

    // 购买产品包
    function buyPackage(uint index, address contractAddress, uint packageType) public payable returns (uint) {
        register();
        require(packageType == 3 || supportContractList[contractAddress], "contract is not support");
        UserInfo storage user = userList[msg.sender];
        Package storage package = poolInfoList[activityIndex].package[index];
        require(package.amount != 0, "no enough package");
        uint256 decimal = 6;
        TRC20 fbToken = TRC20(fb_contract);
        uint256 fbPrice = getTokenPrice(fb_contract);
        _userPackageId++;
		
		uint256 getDays = getProfitDays(msg.sender);
		if (getDays > 0) {
			user.signTime = now;
			user.preTotalCalp = user.preTotalCalp + getDays * user.calp;
		}
        if (packageType == 1) {
            TRC20 token = TRC20(contractAddress);
            decimal = 10 ** uint256(token.decimals());
            uint256 price = getTokenPrice(contractAddress);
            require(contractAddress == fb_contract, "is not STAR contract address");
            assert(token.transferFrom(msg.sender, receiver_address, package.total.mul(price).mul(2)) == true);
            user.calp = user.calp.add(package.total * 22 / 10);
            totalCalp = totalCalp.add(package.total * 22 / 10);
            userPackageList[msg.sender][_userPackageId] = UserPackage(_userPackageId, package.total, package._id, contractAddress, package.total.mul(price).mul(2), 0, 2, 0, now);
        } else if (packageType == 2) {
            TRC20 token = TRC20(contractAddress);
            decimal = 10 ** uint256(token.decimals());
            uint256 price = getTokenPrice(contractAddress);
            assert(token.transferFrom(msg.sender, receiver_address, package.total.mul(price)) == true);
            assert(fbToken.transferFrom(msg.sender, receiver_address, package.total.mul(fbPrice)) == true);
            user.calp = user.calp.add(package.total * 2);
            totalCalp = totalCalp.add(package.total * 2);
            userPackageList[msg.sender][_userPackageId] = UserPackage(_userPackageId, package.total, package._id, contractAddress, package.total.mul(price), package.total.mul(fbPrice), 0, 0, now);
        } else if (packageType == 3) {
            uint trxAmount = package.total.mul(getTokenPrice(address(0)));
            require(msg.value >= trxAmount, "trx not enough");
            assert(fbToken.transferFrom(msg.sender, receiver_address, package.total.mul(fbPrice)) == true);
            user.calp = user.calp.add(package.total * 2);
            totalCalp = totalCalp.add(package.total * 2);
            userPackageList[msg.sender][_userPackageId] = UserPackage(_userPackageId, package.total, package._id, contractAddress, msg.value, package.total.mul(fbPrice), 3, 0, now);
        }
        userBuyPackageList[msg.sender].push(_userPackageId);
		
		
        if (package.amount > 0) {
            package.amount = package.amount - 1;
        }
        return SUCCESS;
    }

    // 用户购买列表
    function GetUserPackageList(uint page, uint limit) public view userExist returns (address[] memory, uint[6][] memory) {
        uint pl = userBuyPackageList[msg.sender].length;
        address[] memory _ca = new address[](limit);
        uint[6][] memory arList = new uint[6][](limit);
        for (uint i = 0; i < limit; i ++) {
            if ((i + 1 + (page - 1) * limit) <= pl) {
                UserPackage memory up = userPackageList[msg.sender][userBuyPackageList[msg.sender][pl - 1 - i - (page - 1) * limit]];
                arList[i][0] = up.total;
                arList[i][1] = up._id;
                _ca[i] = up.contractAddress;
                arList[i][2] = up.status;
                arList[i][3] = up.time;
                arList[i][4] = up.amount;
                arList[i][5] = up.fbAmount;
            }
        }
		
        return (_ca, arList);
    }

    // 用户退包
    function backPackage(uint index) public userExist payable returns(uint) {
        address _ad = msg.sender;
        UserPackage storage userPackage = userPackageList[_ad][index];
        Package storage package = poolInfoList[activityIndex].package[userPackage.packageId];
        TRC20 fbToken = TRC20(fb_contract);
        if (userPackage.status == 3) {
            address(uint160(_ad)).transfer(userPackage.amount);
        } else {
            TRC20 token = TRC20(userPackage.contractAddress);
            assert(token.transferFrom(receiver_address, msg.sender, userPackage.amount) == true);
        }
        if (userPackage.status != 1 && userPackage.fbAmount != 0) {
            assert(fbToken.transferFrom(receiver_address, msg.sender, userPackage.fbAmount) == true);
        }
        if (package._id > 0 && package.amount != - 1) {
            package.amount = package.amount + 1;
        }
  
        UserInfo storage user = userList[_ad];
		uint rechangeNum = (userPackage.status == 2)?(userPackage.total * 22 / 10):(userPackage.total * 2);
		if (user.calp >= rechangeNum){
			user.calp = user.calp.sub(rechangeNum);
		} else {
			user.calp = 0;
		}
		
		if (totalCalp >= rechangeNum){
			totalCalp = totalCalp.sub(rechangeNum);
		} else {
			totalCalp = 0;
		}
		
		userPackage.status = 1;
        return SUCCESS;
    }

    function GetUserInfo(address _address) public view returns (uint, uint, address, uint, uint, uint, uint, uint, uint) {
		if (userList[_address].status) {
			UserInfo memory user = userList[_address];
			return (SUCCESS, user._id, user.userAddress, user.asset, user.calp, user.preTotalCalp, user.profitAsset,  user.releaseProfitAsset, user.signTime);
        } 
		return (SUCCESS, 0, address(0), 0, 0, 0, 0, 0, 0);
    }

    // 资产记录列表
    function GetAssetLog(uint page, uint limit) public view userExist returns (uint, uint[] memory, uint[] memory, uint[] memory) {
        AssetLog[] memory al = assetLogList[msg.sender];
        uint[] memory _amountReturn = new uint[](limit);
        uint[] memory _assetTypeReturn = new uint[](limit);
        uint[] memory _timeReturn = new uint[](limit);
        for (uint i = 0; i < limit; i ++) {
            if ((i + 1 + (page - 1) * limit) <= al.length) {
                _amountReturn[i] = al[al.length - (page - 1) * limit - i  - 1].amount;
                _assetTypeReturn[i] = al[al.length - (page - 1) * limit - i - 1].assetType;
                _timeReturn[i] = al[al.length - (page - 1) * limit - i - 1].time;
            }
        }
        return (SUCCESS, _amountReturn, _assetTypeReturn, _timeReturn);
    }

    // 设置管理员地址
    function setManager(address _userAddress) onlyAdmin public {
        managerAddressList[_userAddress] = true;
    }

    // 添加支持的合约
    function addSupportContract(address contractAddress) onlyAdmin public {
        supportContractList[contractAddress] = true;
    }
    /***********************************************************************************************************************
    模式对接方法
    **********************************************************************************************************************/

    // 用户列表
    function GetUserList(uint page, uint limit) public view returns (uint _status, address[] memory userAddressReturn, uint[4][] memory arList) {
        userAddressReturn = new address[](limit);
        arList = new uint[4][](limit);
        for (uint i = 0; i < limit; i ++) {
            if ((i + 1 + (page - 1) * limit) <= _userInfoId) {
                UserInfo memory user  =  userList[userAddressList[i + 1 + (page - 1) * limit]];
                userAddressReturn[i] = user.userAddress;
                arList[i][0] = user.asset;
                arList[i][1] = user.calp;
                arList[i][2] = user.profitAsset;
                arList[i][3] = user.releaseProfitAsset;
            }
        }
        _status = SUCCESS;
    }

    // 资产清算
    function assetClear(uint256 total, address[] memory addressList, uint[] memory amountList, uint[] memory assetTypeList) public onlyAdmin returns (uint){
        require(addressList.length == amountList.length && amountList.length == assetTypeList.length, "data error");
        poolInfoList[activityIndex].buyAmount = poolInfoList[activityIndex].buyAmount.add(total);
        for (uint i = 0; i < addressList.length; i ++) {
            assetLogList[addressList[i]].push(AssetLog(++_assetLogId, amountList[i], addressList[i], assetTypeList[i], now));
            UserInfo storage user = userList[addressList[i]];
            if (assetTypeList[i] == 2) {
                user.asset = user.asset.add(amountList[i]);
                user.releaseProfitAsset = user.releaseProfitAsset.add(amountList[i]);
            } else if (assetTypeList[i] == 1 ) {
                user.profitAsset = user.profitAsset.add(amountList[i]);
                user.preTotalCalp = 0;
                user.signTime = now;
            } else if (assetTypeList[i] == 3 ||  assetTypeList[i] == 4){
				if (user.calp > 0){
					user.asset = user.asset.add(amountList[i]);
				}
			}			
        }
        return SUCCESS;
    }

    function subAsset(address _userAddress, uint amount) onlyAdmin public {
        UserInfo storage user = userList[_userAddress];
        user.asset = user.asset.sub(amount);
    }

    function drawMoney(address drawAddress, uint amount) onlyAdmin public {
        address(uint160(drawAddress)).transfer(amount * 10 ** 6);
    }
	
    function getProfitDays(address _address) internal view returns(uint) {
        uint getDays = ((now + 28800) / (24 * 60 * 60) - (userList[_address].signTime + 28800) / (24 * 60 * 60));
        return getDays;
    }

    // 设置释放的总量和总算力
    function setTotal(uint _totalCalp) public onlyAdmin returns (uint) {
        totalCalp = _totalCalp;
        return SUCCESS;
    }

    // 获取释放的总量和总算力
    function getTotal() public view returns (uint) {
        return (totalCalp);
    }
}


//SourceUnit: StarStorage.sol

pragma solidity ^0.5.13;

import './TRC20.sol';
import "./IJustswapPrice.sol";
import "./SafeMath.sol";

contract StarStorage {
    using SafeMath for uint256;

    // 用户购买产品包列表
    mapping(address => mapping(uint => UserPackage)) internal userPackageList;

    // 用户购买包的数量
    mapping(address => uint[]) internal userBuyPackageList;

    // 用户列表
    mapping(address => UserInfo) internal userList;

    // 用户地址列表
    mapping(uint => address) internal userAddressList;

    // 矿池的列表
    mapping(uint => PoolInfo) internal poolInfoList;

    // 包信息
    mapping(uint => Package) internal packageList;

    // 管理员地址
    address internal minter;

    // 活动期数
    uint internal activityIndex = 1;

    // 资产记录列表
    mapping(address => AssetLog[]) internal assetLogList;

    // 支持合约地址
    mapping(address => bool) internal supportContractList;
	
    mapping(address => bool) internal managerAddressList;
    // justswap factory 方法
    IJustswapPrice justswapPrice;

    uint256 internal totalCalp;

    // 用户信息
    struct UserInfo {
        uint _id;                  // 编号
        address userAddress;       // 用户地址
        uint asset;                // 资产
        uint calp;                 // 个人算力
        uint preTotalCalp;         // 之前未领取的算力
        bool status;               // 状态
        uint profitAsset;          // 收益
        uint releaseProfitAsset;   // 已释放的
		uint signTime;             // 签到时间
    }

    // 用户购买产品包
    struct UserPackage {
        uint _id;                 // 编号
        uint total;               // 包的价值
        uint packageId;           // 包的ID
        address contractAddress;  // 合约地址
        uint amount;              // 冻结数量
        uint fbAmount;            // fb数量
        uint status;              // 0 购买状态  1 取消 2 库里南
        uint s_type;              // 1 补贴上级  2 补贴上级和上上级
        uint time;                // 时间
    }

    // 包信息
    struct Package {
        uint _id;        // 编号
        uint total;      // 价值
        int amount;      // 包的数量 -1 表示无限量
    }

    // 矿池信息
    struct PoolInfo {
        uint _id;                         // 编号
        uint totalAmount;                 // 总量
        uint buyAmount;                   // 购买数量
        uint startTime;                   // 开始时间
        uint endTime;                     // 结束时间
        mapping(uint => Package) package; // 开放包列表
    }

    // 资产记录
    struct AssetLog {
        uint _id;               // 编号
        uint amount;            // 冻结数量
        address userAddress;    // 地址
        uint assetType;         // 类型
        uint time;              // 时间
    }

    /***********************************************************************************************************************
   内部方法
   **********************************************************************************************************************/
    // 登录
    function register() internal returns (uint) {
        if (!userList[msg.sender].status) {
            UserInfo memory user = UserInfo(++_userInfoId, msg.sender, 0, 0, 0, true, 0, 0, 0);
            userList[msg.sender] = user;
            userAddressList[_userInfoId] = msg.sender;
        }
    }

    function getTokenPrice(address contractAddress) internal view returns (uint256){
        return justswapPrice.getTokenPrice(contractAddress);
//        return 10 ** 6;
    }

    modifier onlyAdmin() {
        require(
            msg.sender == minter || managerAddressList[msg.sender],
            "Only admin can call this."
        );
        _;
    }

    modifier userExist() {
        require(userList[msg.sender].status, "user not exist");
        _;
    }

    /***********************************************************************************************************************
                                                        全局常量
     **********************************************************************************************************************/

    uint _userInfoId = 0;

    uint _burnCoinId = 0;

    uint _userPackageId = 0;

    uint _assetLogId = 0;

    uint _tradeCoinId = 0;

    // 返回代码常量：成功（0）
    uint constant SUCCESS = 0;

    // 数据不存在
    uint constant NODATA = 2003;

    // 数据已存在
    uint constant DATA_EXIST = 2004;

    // star合约地址
    address constant fb_contract = address(0x41573578059f13c009bf8edea3e66c48199ef788ba);

    // bestar合约
    address constant abl_contract = address(0x4119d53c7ae76e8bb0fa4d5fa8175b79d07b462ea6);

    // USDT合约地址
    address constant usdt_contract = address(0x41A614F803B6FD780986A42C78EC9C7F77E6DED13C);

    // usdt和币的收款地址
    address internal receiver_address = address(0x4122e4dd9f7e4e746104c935fe0c3db44fbc556a0d);

    // star提币地址
    address internal fb_draw_address = address(0x419aaff826a7b85910800f99f900519d15451a0aa8);


    /***********************************************************************************************************************
                                                       内部方法
    **********************************************************************************************************************/
    constructor() public {
        minter = msg.sender;
        justswapPrice = IJustswapPrice(address(0x415761CBAEA309505A9DF4F1A9AE8F65ABDC53BDD6));
        // 初始化产品包
        packageList[1] = Package(1, 100, - 1);
        packageList[2] = Package(2, 500, - 1);
        packageList[3] = Package(3, 1000, 300);
        packageList[4] = Package(4, 2000, 200);
        packageList[5] = Package(5, 5000, 100);
        packageList[6] = Package(6, 10000, 50);

        // 初始化矿池
        poolInfoList[1] = PoolInfo(1, 90000 * 10 ** uint256(18), 0, 0, 0);

        for (uint i = 1; i <= 6; i++) {
            poolInfoList[1].package[i] = packageList[i];  
        }
    }
}


//SourceUnit: TRC20.sol

pragma solidity ^0.5.13;

contract TRC20 {

  function transferFrom(address from, address to, uint value) external returns (bool ok);

  function decimals() public view returns (uint8);

  function transfer(address _to, uint256 _value) public;

  function balanceOf(address account) external view returns (uint256);
}