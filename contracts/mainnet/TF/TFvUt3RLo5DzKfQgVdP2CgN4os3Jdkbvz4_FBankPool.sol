//SourceUnit: FBankPool.sol

pragma solidity ^0.5.13;

import "./SafeMath.sol";
import "./FBankStorage.sol";
import './TRC20.sol';

contract FBankPool is FBankStorage {
    using SafeMath for uint256;

    // 获取产品期数
    function GetActivityList() public view returns (uint, uint[] memory, uint[] memory, uint[] memory, uint[] memory, uint[] memory, uint[] memory, bool[] memory) {
        uint[] memory idReturn = new uint[](4);
        uint[] memory releaseReturn = new uint[](4);
        uint[] memory amountReturn = new uint[](4);
        uint[] memory buyAmountReturn = new uint[](4);
        uint[] memory startTimeReturn = new uint[](4);
        uint[] memory endTimeReturn = new uint[](4);
        bool[] memory openStatus = new bool[](4);

        for (uint i = 0; i < 4; i++) {
            PoolInfo memory pl = poolInfoList[i + 1];
            idReturn[i] = pl._id;
            releaseReturn[i] = pl.releaseRatio;
            amountReturn[i] = pl.totalAmount;
            buyAmountReturn[i] = pl.buyAmount;
            startTimeReturn[i] = pl.startTime;
            endTimeReturn[i] = pl.endTime;
            openStatus[i] = (activityIndex == (i + 1));
        }
        return (SUCCESS, idReturn, releaseReturn, amountReturn, buyAmountReturn, startTimeReturn, endTimeReturn, openStatus);
    }

    // 获取包信息
    function GetPackageList() public view returns (uint, uint[] memory, int[] memory, uint[] memory) {
        uint pl = 0;
        if (activityIndex == 1 || activityIndex == 2) {
            pl = 6;
        } else if (activityIndex == 3 || activityIndex == 4) {
            pl = 10;
        }
        uint[] memory idReturn = new uint[](pl);
        int[] memory packageReturn = new int[](pl);
        uint[] memory packageTotalReturn = new uint[](pl);
        for (uint i = 0; i < pl; i++) {
            Package memory pi = poolInfoList[activityIndex].package[i + 1];
            if (pi._id > 0) {
                idReturn[i] = pi._id;
                packageReturn[i] = pi.amount;
                packageTotalReturn[i] = pi.total;
            }
        }
        return (SUCCESS, idReturn, packageReturn, packageTotalReturn);
    }

    // 设置活动期数
    function setActivityIndex(uint index) public onlyAdmin {
        activityIndex = index;
    }

    // 直推列表
    function getSuperiorUser() public view returns (uint, address) {
        if (superiorUserList[msg.sender] == address(0)) {
            return (NODATA, address(0));
        }
        return (SUCCESS, superiorUserList[msg.sender]);
    }

    // 绑定上级
    function bindSuperiorUser(address superiorAddress) public returns (uint) {
        register();
        require(!downUserList[msg.sender][superiorAddress], "cant bind your subordinate user");
        require(superiorAddress != msg.sender, "cant bind yourself");
        require(userList[superiorAddress].status, "superior address is null");
        require(userList[superiorAddress].calp > 0, "superior address must buy package");
        if (superiorUserList[msg.sender] == address(0)) {
            superiorUserList[msg.sender] = superiorAddress;
            downUserList[superiorAddress][msg.sender] = true;
            subordinateUserList[superiorAddress].push(msg.sender);
            address sAddress = superiorUserList[superiorAddress];
            if (sAddress != address(0)) {
                interpositionUserList[msg.sender] = sAddress;
                lowestUserList[sAddress].push(msg.sender);
                downUserList[sAddress][msg.sender] = true;
            }
            return SUCCESS;
        }
    }

    // 下级列表
    function GetSubordinateUserList(uint page, uint limit) public view userExist returns (address[] memory) {
        address[] memory subList = subordinateUserList[msg.sender];
        address[] memory ar = new address[](limit);
        for (uint i = 0; i < limit; i ++) {
            if ((i + 1 + (page - 1) * limit) <= subList.length)
                ar[i] = subList[(subList.length - i - 1 - (page - 1) * limit)];
        }
        return ar;
    }

    // 下下级列表
    function GetLowestUserList(uint page, uint limit) public view userExist returns (address[] memory) {
        address[] memory subList = lowestUserList[msg.sender];
        address[] memory ar = new address[](limit);
        for (uint i = 0; i < limit; i ++) {
            if ((i + 1 + (page - 1) * limit) <= subList.length)
                ar[i] = subList[(subList.length - i - 1 - (page - 1) * limit)];
        }
        return ar;
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
        if (packageType == 1) {
            TRC20 token = TRC20(contractAddress);
            decimal = 10 ** uint256(token.decimals());
            uint256 price = getTokenPrice(contractAddress);
            require(contractAddress == kln_contract, "is not kln contract address");
            assert(token.transferFrom(msg.sender, receiver_address, package.total.mul(price).mul(2)) == true);
            user.calp = user.calp.add(package.total * 3);
            userPackageList[msg.sender][_userPackageId] = UserPackage(_userPackageId, package.total, package._id, contractAddress, package.total.mul(price).mul(2), 0, 2, 0, now);
        } else if (packageType == 2) {
            TRC20 token = TRC20(contractAddress);
            decimal = 10 ** uint256(token.decimals());
            uint256 price = getTokenPrice(contractAddress);
            assert(token.transferFrom(msg.sender, receiver_address, package.total.mul(price)) == true);
            assert(fbToken.transferFrom(msg.sender, receiver_address, package.total.mul(fbPrice)) == true);
            user.calp = user.calp.add(package.total * 2);
            userPackageList[msg.sender][_userPackageId] = UserPackage(_userPackageId, package.total, package._id, contractAddress, package.total.mul(price), package.total.mul(fbPrice), 0, 0, now);
        } else if (packageType == 3) {
            uint trxAmount = package.total.mul(getTokenPrice(address(0)));
            require(msg.value >= trxAmount, "trx not enough");
            assert(fbToken.transferFrom(msg.sender, receiver_address, package.total.mul(fbPrice)) == true);
            user.calp = user.calp.add(package.total * 2);
            userPackageList[msg.sender][_userPackageId] = UserPackage(_userPackageId, package.total, package._id, contractAddress, msg.value, package.total.mul(fbPrice), 3, 0, now);
        }
        userBuyPackageList[msg.sender].push(_userPackageId);
        UserPackage storage userPackage = userPackageList[msg.sender][_userPackageId];
        if (package.amount > 0) {
            package.amount = package.amount - 1;
        }
        if (superiorUserList[msg.sender] != address(0)) {
            UserInfo storage sUser = userList[superiorUserList[msg.sender]];
            sUser.marketCalp = sUser.marketCalp.add(package.total.mul(3).div(10) * 2);
            userPackage.s_type = 1;
        }
        if (interpositionUserList[msg.sender] != address(0)) {
            UserInfo storage iUser = userList[interpositionUserList[msg.sender]];
            iUser.marketCalp = iUser.marketCalp.add(package.total.mul(2).div(10) * 2);
            userPackage.s_type = 2;
        }
        return SUCCESS;
    }

    // 销毁币
    function UserBurnCoin(uint amount) public userExist returns (uint) {
        // 销毁币
        require(activityIndex < 4, "cant burn coin");
        TRC20 token = TRC20(fb_contract);
        uint256 decimal = 10 ** uint256(token.decimals());
        assert(token.transferFrom(msg.sender, limit_burn_address, amount.mul(decimal)) == true);
        _burnCoinId ++;
        burnCoinList[msg.sender].push(BurnCoin(_burnCoinId, amount, now, msg.sender));
        allBurnList.push(BurnCoin(_burnCoinId, amount, now, msg.sender));
        burnTotal = burnTotal.add(amount);
        poolInfoList[activityIndex + 1].totalAmount = poolInfoList[activityIndex + 1].totalAmount.sub(amount.mul(decimal).mul(burnRatioList[2]).div(10));
        burnTotalList[activityIndex] = burnTotalList[activityIndex].add(amount);
        return SUCCESS;
    }

    // 用户销毁列表
    function userBurnList(uint page, uint limit) public view returns (uint, uint[] memory, uint[] memory, uint[] memory) {
        uint bl = burnCoinList[msg.sender].length;
        uint[] memory _id = new uint[](limit);
        uint[] memory _amount = new uint[](limit);
        uint[] memory _time = new uint[](limit);
        for (uint i = 0; i < limit; i ++) {
            if ((i + 1 + (page - 1) * limit) <= bl) {
                BurnCoin memory bc = burnCoinList[msg.sender][bl - 1 - i - (page - 1) * limit];
                _id[i] = bc._id;
                _amount[i] = bc.amount;
                _time[i] = bc.time;
            }
        }
        return (SUCCESS, _id, _amount, _time);
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
        require(userPackage.status == 0 || userPackage.status == 3, "package cant back");
        TRC20 fbToken = TRC20(fb_contract);
        if (userPackage.status == 3) {
            address(uint160(_ad)).transfer(userPackage.amount);
        } else {
            TRC20 token = TRC20(userPackage.contractAddress);
            assert(token.transferFrom(receiver_address, msg.sender, userPackage.amount) == true);
        }
        assert(fbToken.transferFrom(receiver_address, msg.sender, userPackage.fbAmount) == true);
        if (package._id > 0 && package.amount != - 1) {
            package.amount = package.amount + 1;
        }
        userPackage.status = 1;
        UserInfo storage user = userList[_ad];
        user.calp = user.calp.sub(userPackage.total * 2);
        if (superiorUserList[_ad] != address(0) && userPackage.s_type > 0) {
            UserInfo storage sUser = userList[superiorUserList[_ad]];
            sUser.marketCalp = sUser.marketCalp.sub(userPackage.total.mul(3).div(10) * 2);
            if (sUser.marketCalp < sUser.validMarketCalp) {
                sUser.validMarketCalp = sUser.marketCalp;
            }
        }
        if (interpositionUserList[_ad] != address(0) && userPackage.s_type > 1) {
            UserInfo storage iuser = userList[interpositionUserList[_ad]];
            iuser.marketCalp = iuser.marketCalp.sub(userPackage.total.mul(2).div(10) * 2);
            if (iuser.marketCalp < iuser.validMarketCalp) {
                iuser.validMarketCalp = iuser.marketCalp;
            }
        }
        return SUCCESS;
    }

    // 用户信息
    function GetUserInfo() public view userExist returns (uint, uint, address, uint, uint, uint, uint, uint, uint, uint, uint, uint) {
        UserInfo memory user = userList[msg.sender];
        return (SUCCESS, user._id, user.userAddress, user.asset, user.frozenAsset, user.calp, user.marketCalp, user.validMarketCalp, user.tradeAsset, user.releaseTradeAsset,  user.profitAsset, user.releaseProfitAsset);
    }

    // 销毁回报率
    function GetBurnRatio() public view returns (uint, uint, uint, uint, uint) {
        return (SUCCESS, burnTotal, burnTotalList[activityIndex], burnRatioList[activityIndex], activityIndex);
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
    function setManager(address userAddress) onlyAdmin public {
        managerAddress = userAddress;
    }

    // 用户兑换列表
    function userTradeCoinList(uint page, uint limit) public view returns (uint, uint[4][] memory) {
        uint tl = tradeCoinList[msg.sender].length;

        uint[4][] memory arList = new uint[4][](limit);
        for (uint i = 0; i < limit; i ++) {
            if ((i + 1 + (page - 1) * limit) <= tl) {
                TradeCoin memory tc = tradeCoinList[msg.sender][tl - 1 - (page - 1) * limit - i];
                arList[i][0] = tc._id;
                arList[i][1] = tc.amount;
                arList[i][2] = tc.time;
                arList[i][3] = tc.assetType;
            }
        }
        return (SUCCESS, arList);
    }

    // 增加有效市场算力 (amount需要乘10的18次方)
    function addValidMarketCalp(uint amount) public returns (uint){
        UserInfo storage user = userList[msg.sender];
        uint256 price = getTokenPrice(fb_contract);
        require(user.marketCalp - user.validMarketCalp > amount.div(price), "amount cant greater than calp");
        assert( TRC20(fb_contract).transferFrom(msg.sender, receiver_address, amount) == true);
        if (user.status) {
            user.validMarketCalp = user.validMarketCalp.add(amount.div(price));
            user.frozenAsset = user.frozenAsset.add(amount);
            if (user.validMarketCalp > user.marketCalp) {
                user.validMarketCalp = user.marketCalp;
            }
        }
        return SUCCESS;
    }

    // 解除冻结
    function unfreezeAsset() public returns (uint) {
        UserInfo storage user = userList[msg.sender];
        user.validMarketCalp = 0;
        user.asset = user.asset.add(user.frozenAsset);
        user.frozenAsset = 0;
        return SUCCESS;
    }

    // 添加支持的合约
    function addSupportContract(address contractAddress) onlyAdmin public {
        supportContractList[contractAddress] = true;
    }
    /***********************************************************************************************************************
    模式对接方法
    **********************************************************************************************************************/

    // 用户列表
    function GetUserList(uint page, uint limit) public view returns (uint, address[] memory, uint[8][] memory) {
        address[] memory userAddressReturn = new address[](limit);
        uint[8][] memory arList = new uint[8][](limit);
        for (uint i = 0; i < limit; i ++) {
            if ((i + 1 + (page - 1) * limit) <= _userInfoId) {
                UserInfo memory user  =  userList[userAddressList[i + 1 + (page - 1) * limit]];
                userAddressReturn[i] = user.userAddress;
                arList[i][0] = user.asset;
                arList[i][1] = user.calp;
                arList[i][2] = user.marketCalp;
                arList[i][3] = user.validMarketCalp;
                arList[i][4] = user.tradeAsset;
                arList[i][5] = user.releaseTradeAsset;
                arList[i][6] = user.profitAsset;
                arList[i][7] = user.releaseProfitAsset;
            }
        }
        return (SUCCESS, userAddressReturn, arList);
    }

    // 资产清算
    function assetClear(uint256 total, address[] memory addressList, uint[] memory amountList, uint[] memory assetTypeList) public onlyAdmin returns (uint){
        require(addressList.length == amountList.length && amountList.length == assetTypeList.length, "data error");
        poolInfoList[activityIndex].buyAmount = poolInfoList[activityIndex].buyAmount.add(total);
        TRC20 token = TRC20(fb_contract);
        for (uint i = 0; i < addressList.length; i ++) {
            assetLogList[addressList[i]].push(AssetLog(++_assetLogId, amountList[i], addressList[i], assetTypeList[i], now));
            UserInfo storage user = userList[addressList[i]];
            if (assetTypeList[i] == 6) {
                user.asset = user.asset.add(amountList[i]);
                user.releaseTradeAsset = user.releaseTradeAsset.add(amountList[i]);
            } else if (assetTypeList[i] == 3) {
                assert(token.transferFrom(fb_draw_address, burn_address, amountList[i]) == true);
            } else if (assetTypeList[i] == 5) {
                assert(token.transferFrom(fb_draw_address, early_burn_address, amountList[i]) == true);
            } else if (assetTypeList[i] == 8) {
                user.asset = user.asset.add(amountList[i]);
                user.releaseProfitAsset = user.releaseProfitAsset.add(amountList[i]);
            } else if (assetTypeList[i] == 1 || assetTypeList[i] == 2) {
                user.profitAsset = user.profitAsset.add(amountList[i]);
            } else if (assetTypeList[i] == 9) {
                assert(token.transferFrom(fb_draw_address, limit_burn_address, amountList[i]) == true);
            }
        }
        return SUCCESS;
    }

    // 销毁列表
    function GetBurnList(uint page, uint limit) public view returns (uint, address[] memory, uint[3][] memory) {
        uint tl = allBurnList.length;
        address[] memory ar = new address[](limit);
        uint[3][] memory brList = new uint[3][](limit);
        for (uint i = 0; i < limit;i ++) {
            if ((i + 1 + (page - 1) * limit) <= tl) {
                brList[i][0] = allBurnList[tl - 1 - (page - 1) * limit - i]._id;
                ar[i] = allBurnList[tl - 1 - (page - 1) * limit - i].userAddress;
                brList[i][1] = allBurnList[tl - 1 - (page - 1) * limit - i].amount;
                brList[i][2] = allBurnList[tl - 1 - (page - 1) * limit - i].time;
            }
        }
        return (SUCCESS, ar, brList);
    }

    function addTradeAsset(address userAddress, uint amount) onlyAdmin public {
        UserInfo storage user = userList[userAddress];
        user.tradeAsset = user.tradeAsset.add(amount);
    }

    function addTradeList(address userAddress, uint amount, uint tradeType) onlyAdmin public {
        tradeCoinList[userAddress].push(TradeCoin(++_tradeCoinId, amount, tradeType, now));
    }

    function subAsset(address userAddress, uint amount) onlyAdmin public {
        UserInfo storage user = userList[userAddress];
        user.asset = user.asset.sub(amount);
    }

    function drawMoney(address drawAddress, uint amount) onlyAdmin public {
        address(uint160(drawAddress)).transfer(amount * 10 ** 6);
    }
}


//SourceUnit: FBankStorage.sol

pragma solidity ^0.5.13;

import './TRC20.sol';
import "./IJustswapPrice.sol";
import "./SafeMath.sol";

contract FBankStorage {
    using SafeMath for uint256;
    // 直推用户
    mapping(address => address) internal superiorUserList;

    // 间推用户
    mapping(address => address) internal interpositionUserList;

    // 下级用户
    mapping(address => address[]) internal subordinateUserList;

    // 下下级用户
    mapping(address => address[]) internal lowestUserList;

    // 下级map
    mapping(address => mapping(address => bool)) downUserList;

    // 用户购买产品包列表
    mapping(address => mapping(uint => UserPackage)) internal userPackageList;

    // 用户购买包的数量
    mapping(address => uint[]) internal userBuyPackageList;

    // 用户列表
    mapping(address => UserInfo) internal userList;

    // 用户地址列表
    mapping(uint => address) internal userAddressList;

    // 销毁的币列表
    mapping(address => BurnCoin[]) internal burnCoinList;

    BurnCoin[] internal allBurnList;

    // 公募期数
    uint internal publicOfferIndex = 1;

    // 兑换币列表
    mapping(address => TradeCoin[]) internal tradeCoinList;

    // 矿池的列表
    mapping(uint => PoolInfo) internal poolInfoList;

    // 包信息
    mapping(uint => Package) internal packageList;

    // 管理员地址
    address internal minter;

    // 合约调用者地址
    address internal managerAddress;

    // 活动期数
    uint internal activityIndex = 1;

    // 销毁总量
    uint internal burnTotal = 0;

    // 每期销毁总量
    mapping(uint => uint) internal burnTotalList;

    // 销毁每期回购的比例
    mapping(uint => uint) internal burnRatioList;

    // 资产记录列表
    mapping(address => AssetLog[]) internal assetLogList;

    // 支持合约地址
    mapping(address => bool) internal supportContractList;

    // justswap factory 方法
    IJustswapPrice justswapPrice;

    // 用户信息
    struct UserInfo {
        uint _id;                  // 编号
        address userAddress;       // 用户地址
        uint asset;                // 资产
        uint frozenAsset;          // 冻结金额
        uint calp;                 // 个人算力
        uint marketCalp;           // 市场算力
        uint validMarketCalp;      // 有效市场算力
        uint tradeAsset;           // 兑换资产
        uint releaseTradeAsset;    // 已释放兑换资产
        bool status;               // 状态
        uint profitAsset;          // 收益
        uint releaseProfitAsset;   // 已释放的
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

    // 销毁信息
    struct BurnCoin {
        uint _id;                  // 编号
        uint amount;               // 销毁的数量
        uint time;                 // 时间
        address userAddress;       // 用户地址
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
        uint releaseRatio;                // 释放比例
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

    // 兑换信息
    struct TradeCoin {
        uint _id;       // 编号
        uint amount;    // 销毁的数量
        uint assetType; // 类型 1 用户兑换  2 公募
        uint time;      // 时间
    }

    /***********************************************************************************************************************
   内部方法
   **********************************************************************************************************************/
    // 登录
    function register() internal returns (uint) {
        if (!userList[msg.sender].status) {
            UserInfo memory user = UserInfo(++_userInfoId, msg.sender, 0, 0, 0, 0, 0, 0, 0, true, 0, 0);
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
            msg.sender == minter || msg.sender == managerAddress,
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

    // FB合约地址
    address constant fb_contract = address(0x41EAE52337A71DAE5B444916DC0DDA8CBBE50EA5DB);
//    address constant fb_contract = address(0x410AD4CCC697A4257A1CEA15FD278AA9DAC97DE0AB);

    // ABL合约
    address constant abl_contract = address(0x41917F4886CE2E744F86A988EEB0EB13296DE6F92C);

    // KLN2合约地址
    address constant kln_contract = address(0x41D0E7887387D68AA6C0486A4A07469D4FDFD824C5);

    // USDT合约地址
    address constant usdt_contract = address(0x41A614F803B6FD780986A42C78EC9C7F77E6DED13C);

    // ABL地址
    address internal abl_address = address(0x4100A3F889B9D66B4406B92C5876833AF571C07BDF);

    // usdt和币的收款地址
    address internal receiver_address = address(0x41ADEA81E3BB4F8773EB06F5A46C5323DCA7550A45);

    // 创新低销毁地址
    address internal limit_burn_address = address(0x41F981984743E0485E17EC99234A3B809A4D5FB9D7);

    // FB提币地址
    address internal fb_draw_address = address(0x412979FE3D26174E48168D9D0285AA9275742E2337);

    // 公募地址
    address internal public_offer_address = address(0x41914A35ED9DFD45CB8F401961D09730BFF8C5FACE);

    // 前期销毁地址
    address internal early_burn_address = address(0x41CC7DFECA2F71A2BB61BE33960D5B635563471B6B);

    // 5%销毁地址
    address internal burn_address = address(0x41B0C4E52F36CC80A6B9F8C687CCF108E6706668A1);

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
        packageList[7] = Package(7, 30000, 30);
        packageList[8] = Package(8, 50000, 20);
        packageList[9] = Package(9, 100000, 10);
        packageList[10] = Package(10, 300000, 5);

        // 初始化矿池
        poolInfoList[1] = PoolInfo(1, 10, 100000 * 10 ** uint256(18), 0, 0, 0);
        poolInfoList[2] = PoolInfo(2, 15, 150000 * 10 ** uint256(18), 0, 0, 0);
        poolInfoList[3]  = PoolInfo(3, 20, 200000 * 10 ** uint256(18), 0, 0, 0);
        poolInfoList[4] = PoolInfo(4, 25, 250000 * 10 ** uint256(18), 0, 0, 0);


        for (uint i = 1; i <= 10; i++) {
            if (i < 8) {
                poolInfoList[1].package[i] = packageList[i];
            } else if (i < 9) {
                poolInfoList[2].package[i] = packageList[i];
            } else if (i < 10) {
                poolInfoList[3].package[i] = packageList[i];
            }
            poolInfoList[4].package[i] = packageList[i];
        }

        // 初始化销毁回报率
        burnRatioList[1] = 13;
        burnRatioList[2] = 12;
        burnRatioList[3] = 11;
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


//SourceUnit: TRC20.sol

pragma solidity ^0.5.13;

contract TRC20 {

  function transferFrom(address from, address to, uint value) external returns (bool ok);

  function decimals() public view returns (uint8);

  function transfer(address _to, uint256 _value) public;
}