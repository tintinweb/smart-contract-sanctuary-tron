//SourceUnit: Common.sol

pragma solidity ^0.5.13;

import './TRC20.sol';

contract Common {

    // 管理员地址
    mapping(address => bool) internal managerAddressList;

    address constant swap_contract = address(0x419b3e15f0f55953f8100cbc3ad0a8ba66111ba358);

    address constant coin_address = address(0x41460ffba315092714c1d62f0c1a8d0eba77398a50);

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

  function balanceOf(address account) external view returns (uint256);
}


//SourceUnit: fbstake.sol

pragma solidity ^0.5.13;

import './infostorage.sol';
import './TRC20.sol';
import './SafeMath.sol';
import './Common.sol';

contract btxqstake is Common{

    constructor() public {
        infostorage2 = infostorage(address(0x41dd2278afe0d69c790ca2e139fef1abe9aa5f2ce5));
    }

    uint internal little = 100000000000000000; //最低限额
	
	uint[] internal Backpercent = [70, 85, 90, 100];

    function setLittle(uint _little) public onlyAdmin returns(uint) {
        little = _little;
        return SUCCESS;
    }

    function getLittle() public view returns(uint) {
        return little;
    }
	
	function setOfferPrice(uint256[] memory _backpercent) public onlyAdmin returns(uint256) {
        Backpercent = _backpercent;
        return SUCCESS;
    }

    // 存儲合約
    infostorage internal infostorage2;

    using SafeMath for uint256;

    function staked(uint amount) public returns(uint) {
        TRC20 fbToken = TRC20(swap_contract);
        //fbToken.stake(amount);
        assert(fbToken.transferFrom(msg.sender, address(this), amount) == true);
        infostorage2.subAsset(msg.sender, amount);
        return SUCCESS;
    }

    function refreAll(uint amount) public returns(uint) {
        TRC20 fbToken = TRC20(swap_contract);
		(,,, uint logTime, ) = infostorage2.getUserInfo(msg.sender);
		infostorage2.clearAsset(msg.sender, amount);
		uint percent = 97;
		if (now - logTime <= 7 * 24 * 60 * 60){
			percent = Backpercent[0];
		} else if (now - logTime <= 30 * 24 * 60 * 60) {
			percent = Backpercent[1];
		} else if (now - logTime <= 60 * 24 * 60 * 60) {
			percent = Backpercent[2];
		} else{
			percent = Backpercent[3];
		} 
        
        fbToken.transfer(msg.sender, amount * percent / 100);
        return SUCCESS;
    }

    function getProfit() public returns(uint) {
        uint profit = infostorage2.getAsset(msg.sender);
        require (profit >= little, "more than 0.1");
        infostorage2.setUserInfo(msg.sender, 0, now);
        TRC20 fbToken = TRC20(coin_address);
        fbToken.transfer(msg.sender, profit);
        return SUCCESS;
    }
}


//SourceUnit: infostorage.sol

pragma solidity ^0.5.13;

import "./SafeMath.sol";
import './TRC20.sol';

contract infostorage {
    using SafeMath for uint256;

    // 用户列表
    mapping(address => UserInfo) internal userList;

    // 生成合约的地址
    address internal minter;

    uint internal profitRatio = 1012321;

    address constant swap_contract = address(0x419b3e15f0f55953f8100cbc3ad0a8ba66111ba358);
	
	address internal storeAddress = address(0x41953f13951173452f7ef8acea5cc3b9f71c4c439f);

    uint internal giveCoin = 130000000000000000000;

    uint internal little = 10000000000000; // 最低限额
	
	// 用户地址列表
    mapping(uint => address) internal userAddressList;
	
    // 下级用户
    mapping(address => address[]) internal subordinateUserList;

    // 下级map
    mapping(address => mapping(address => bool)) downUserList;

    // 用户信息
    struct UserInfo {
        uint _id;                  // 编号
        address userAddress;       // 用户地址
        uint calp;                 // 个人算力
        uint subordinateNumber;    // 下级数量
        bool status;               // 状态
        uint have; // 剩余数量
        uint time; // 记录的时间基数
		uint logTime; //记录LP存入的时间 结算退包比例
        address preAddress;  // 上级地址
    }

    // 绑定上级
    function bindSuperiorUser(address superiorAddress) payable public returns (uint) {
        require(!downUserList[msg.sender][superiorAddress], "cant bind your subordinate user");
        require(superiorAddress != msg.sender, "cant bind yourself");
        if (!userList[msg.sender].status) {
            UserInfo memory user = UserInfo(++_userInfoId, msg.sender,  0, 0, true, 0, 0, 0, address(0));
            userList[msg.sender] = user;
        }
        if (userList[msg.sender].preAddress == address(0)) {
            userList[msg.sender].preAddress = superiorAddress;
            downUserList[superiorAddress][msg.sender] = true;
            subordinateUserList[superiorAddress].push(msg.sender);
        }
        return SUCCESS;
    }

    // 下级列表
    function getSubordinateUserList(address userAddress, uint page, uint limit) public view returns (address[] memory) {
        address[] memory subList = subordinateUserList[userAddress];
        address[] memory ar = new address[](limit);
        for (uint i = 0; i < limit; i ++) {
            if ((i + 1 + (page - 1) * limit) <= subList.length)
                ar[i] = subList[(subList.length - i - 1 - (page - 1) * limit)];
        }
        return ar;
    }

    // 直推列表
    function getSuperiorUser() public view returns (uint, address) {
        if (userList[msg.sender].preAddress == address(0)) {
            return (NODATA, address(0));
        }
        return (SUCCESS, userList[msg.sender].preAddress);
    }
	
	/***********************************************************************************************************************
    模式对接方法
    **********************************************************************************************************************/

    // 用户列表
    function GetUserList(uint page, uint limit) public view returns (uint, address[] memory, address[] memory, uint[] memory) {
        address[] memory userAddressReturn = new address[](limit);
		address[] memory userPreAddressReturn = new address[](limit);
        uint[] memory arList = new uint[](limit);
        for (uint i = 0; i < limit; i ++) {
            if ((i + 1 + (page - 1) * limit) <= _userInfoId) {
                address userAddress = userAddressList[i + 1 + (page - 1) * limit];
                (arList[i],,,,userPreAddressReturn[i]) = getUserInfo(userAddress);
                userAddressReturn[i] = userAddress;
            }
        }
        return (SUCCESS, userAddressReturn, userPreAddressReturn, arList);
    }


    // 管理员地址
    mapping(address => bool) internal managerAddressList;

    function setProfitRatio(uint _profitRatio) public onlyAdmin returns(uint) {
        profitRatio = _profitRatio;
        return SUCCESS;
    }

    function getProfitRatio() public view returns(uint) {
        return profitRatio;
    }

    function setGiveCoin(uint _giveCoin) public onlyAdmin returns(uint) {
        giveCoin = _giveCoin;
        return SUCCESS;
    }

    function getGiveCoin() public view returns(uint) {
        return giveCoin;
    }

    function setLittle(uint _little) public onlyAdmin returns(uint) {
        little = _little;
        return SUCCESS;
    }

    function getLittle() public view returns(uint) {
        return little;
    }
	
	function setStore(address _address) public onlyAdmin returns(uint) {
        storeAddress = _address;
        return SUCCESS;
    }

    function getStore() public view returns(address) {
        return storeAddress;
    } 

    function subAsset(address userAddress, uint amount) onlyAdmin public {
        if (!userList[userAddress].status) {
            UserInfo memory user = UserInfo(++_userInfoId, userAddress,  0, 0, true, 0, 0, 0, address(0));
            userList[userAddress] = user;
            userAddressList[user._id] = userAddress;
        
        }
        UserInfo storage userInfo = userList[userAddress];
        TRC20 token = TRC20(swap_contract);
        uint myToken = token.balanceOf(storeAddress);
        if (myToken < little){
            myToken = little;
        }
        uint profit = userInfo.calp * giveCoin * (now - userInfo.time) / myToken  / (24 * 60 * 60)  + userInfo.have;
        userInfo.time = now;
        userInfo.have = profit;
        userInfo.calp = userInfo.calp.add(amount);
		userInfo.logTime = now;
    }

    function clearAsset(address userAddress, uint amount) onlyAdmin public {
        UserInfo storage user = userList[userAddress];
        TRC20 token = TRC20(swap_contract);
        uint myToken = token.balanceOf(storeAddress);
        if (myToken < little){
            myToken = little;
        }
        uint profit = user.calp * giveCoin * (now - user.time) / myToken  / (24 * 60 * 60)  + user.have;
        user.calp = user.calp.sub(amount);
        user.time = now;
        user.have = profit;
    }

    function getAsset(address userAddress) public view returns(uint) {
        require (userList[userAddress].status, "user not exist");
        TRC20 token = TRC20(swap_contract);
        uint myToken = token.balanceOf(storeAddress);
        if (myToken < little){
            myToken = little;
        }
        UserInfo memory userInfo = userList[userAddress];
        uint profit = userInfo.calp * giveCoin * (now - userInfo.time) / myToken  / (24 * 60 * 60)  + userInfo.have;
        return profit;
    }

    function getTrueProlist()  public view returns(uint) {
        TRC20 token = TRC20(swap_contract);
        uint myToken = token.balanceOf(storeAddress);
        if (myToken < little){
            myToken = little;
        }
        return myToken;
    }

    // 设置管理员地址
    function setManager(address userAddress, bool status) onlyAdmin public returns(uint){
        managerAddressList[userAddress] = status;
        return SUCCESS;
    }

    function setUserInfo(address _userAddress, uint _have, uint _time) onlyAdmin public returns(uint) {
        UserInfo storage userInfo = userList[_userAddress];
        require(userInfo.status, "user not exist");
        userInfo.have = _have;
        userInfo.time = _time;
        return SUCCESS;
    }
	
	function setLogTime(address _userAddress, uint _logTime) onlyAdmin public returns(uint) {
        UserInfo storage userInfo = userList[_userAddress];
        userInfo.logTime = _logTime;
        return SUCCESS;
    }

    function getUserInfo(address _userAddress) view public returns(uint _calp, uint _have, uint _time, uint _logTime, address _preAddress) {
        UserInfo memory userInfo = userList[_userAddress];
        _calp = userInfo.calp;
        _have = userInfo.have;
        _time = userInfo.time;
		_logTime = userInfo.logTime;
        _preAddress = userInfo.preAddress;
    }

    function modifyCalp(address _userAddress, uint _calp) onlyAdmin public returns(uint) {
        UserInfo storage userInfo = userList[_userAddress];
        require(userInfo.status, "user not exist");
        userInfo.calp = _calp;
        return SUCCESS;
    }

    modifier onlyAdmin() {
        require(
            msg.sender == minter || managerAddressList[msg.sender],
            "Only admin can call this."
        );
        _;
    }

    // 返回代码常量：成功（0）
    uint constant SUCCESS = 0;

    // 数据不存在
    uint constant NODATA = 2003;

    // 数据已存在
    uint constant DATA_EXIST = 2004;

    uint _userInfoId = 0;

    constructor() public {
        minter = msg.sender;
    }
}