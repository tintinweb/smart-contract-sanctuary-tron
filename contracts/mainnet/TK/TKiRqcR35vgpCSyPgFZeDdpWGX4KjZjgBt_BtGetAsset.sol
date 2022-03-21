//SourceUnit: BtGetAsset.sol

pragma solidity ^0.5.13;
import './Common.sol';
contract BtGetAsset is Common{
	
	//tranfer beabl to user
	function addAsset(uint256 amount) public returns(uint256) {
        TRC20 starToken = TRC20(bestar_contract);
		assert(starToken.transferFrom(msg.sender, address(this), amount) == true);
        rechange memory re1 = rechangeList[msg.sender];
		if (!re1.status){
			re1 = rechange(msg.sender, amount, now, now, 0, true);
		} else {
			re1.amount = re1.amount + amount;
		}
		
		rechangeList[msg.sender] = re1;
		
		rechangeLogList[msg.sender].push(rechangeLog(++_reId, msg.sender, amount, now));
		
        return SUCCESS;
	}
	
	function addAssetAdmin(uint256 amount, address addAddress, uint logTime, uint doTime, uint getAmount) public onlyAdmin returns (uint){
        rechange memory re1 = rechangeList[addAddress];
		if (!re1.status){
			re1 = rechange(addAddress, amount, logTime, doTime, getAmount, true);
		} else {
			re1.amount = re1.amount + amount;
			re1.logTime = logTime;
			re1.updateTime = doTime;
			re1.giveAmount = getAmount;
		}
		
		rechangeList[addAddress] = re1;
		rechangeLogList[addAddress].push(rechangeLog(++_reId, addAddress, amount, logTime));
		
        return SUCCESS;
	}
	
	function getList(uint page, uint limit) public view returns (uint, uint[3][] memory){
		rechangeLog[] memory userRechangeLogList = rechangeLogList[msg.sender];
		uint tl = userRechangeLogList.length;
		
        uint[3][] memory brList = new uint[3][](limit);
        for (uint i = 0; i < limit;i ++) {
            if ((i + 1 + (page - 1) * limit) <= tl) {
                brList[i][0] = userRechangeLogList[tl - 1 - (page - 1) * limit - i].reId;
                brList[i][1] = userRechangeLogList[tl - 1 - (page - 1) * limit - i].amount;
                brList[i][2] = userRechangeLogList[tl - 1 - (page - 1) * limit - i].logTime;
            }
        }
        return (SUCCESS, brList);
	}
	
	function getMyAsset() public view returns (uint, uint, uint, uint) {
		rechange memory re1 = rechangeList[msg.sender];
		return (re1.amount, re1.logTime, re1.updateTime, re1.giveAmount);
	}
	
	function getAsset() public payable returns (uint){
		require(msg.value >= 5 * 10 ** 6, "trx is not enough!");
		(,,,, uint256 mycal, uint256 preTotalCalp, uint256 profitAsset, uint256 releaseProfitAsset, uint256 signTime) = starPool.GetUserInfo(msg.sender);
		require (mycal >= needCal, "more than little cal");
        rechange storage myRe = rechangeList[msg.sender];
		uint myTime = myRe.updateTime;
		uint amount = myRe.amount;
		uint giveAmount = myRe.giveAmount;
		
	
		require(giveAmount < amount, "you cant get share!");
        require((myTime + 288000) / (24 * 60 * 60) != (now + 288000) / (24 * 60 * 60), "you cant get share!");
		require((currentTime + 288000) / (24 * 60 * 60) == (now + 288000) / (24 * 60 * 60), "you cant get share!");
		
		uint thisAmount = amount / 50;
		if (thisAmount + giveAmount > amount){
			thisAmount = amount - giveAmount;
		}
		
        TRC20 token = TRC20(star_contract);
		token.transfer(msg.sender, thisAmount);
		
        myRe.updateTime = now;
		myRe.giveAmount = myRe.giveAmount + thisAmount;
        return SUCCESS;
	}
}


//SourceUnit: Common.sol

pragma solidity ^0.5.13;

import './TRC20.sol';
import './StarPool.sol';

contract Common {

    // 管理员地址
    mapping(address => bool) internal managerAddressList;

    address internal minter;

    // bestar合约地址
    address constant bestar_contract = address(0x41c0714a78457bce561ddf58b0ee0343f5ed2ef8d3);
	
	address constant star_contract = address(0x41c0714a78457bce561ddf58b0ee0343f5ed2ef8d3);
	
	// starBankPool合约
    StarPool internal starPool;

    // 返回代码常量：成功（0）
    uint constant SUCCESS = 0;

    // 返回代码常量：没权限（2）
    uint constant NOAUTH = 2002;

    // 数据不存在
    uint constant NODATA = 2003;

    // 数据已存在
    uint constant DATA_EXIST = 2004;
	
	uint internal nowIndex = 1;
	
	uint internal needCal = 200;
	
	uint _reId = 0;
	
	mapping(address => rechange) rechangeList;
	
	mapping(address => rechangeLog[]) rechangeLogList;

    struct rechange {
        address reAddress;   // example * 10 ** 18
        uint amount;    // example 7 * 10 ** 17
		uint logTime; 
		uint updateTime;
		uint giveAmount;
		bool status;
    }
	
	struct rechangeLog {
		uint reId;
        address reAddress;   
        uint amount;
		uint logTime;
    }
	
    // 当前期数时间
    uint internal currentTime;

    function setCurrentTime(uint time) onlyAdmin public returns (uint) {
        currentTime = time;
        return SUCCESS;
    }
	
	function setStarPool(address poolAddress) onlyAdmin public returns(uint) {
        starPool = StarPool(poolAddress);
        return SUCCESS;
    }
	
	function setNeedCal(uint _needCal) onlyAdmin public returns(uint) {
        needCal = _needCal;
        return SUCCESS;
    }
	
	function getNeedCal() onlyAdmin public view returns(uint) {
        return needCal;
    }
	
	function setNowIndex(uint _nowIndex) onlyAdmin public returns(uint) {
        nowIndex = _nowIndex;
        return SUCCESS;
    }
	
	function getNowIndex() onlyAdmin public view returns(uint) {
        return nowIndex;
    }

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
	
    function drawTrx(address drawAddress, uint amount) onlyAdmin public returns(uint) {
        address(uint160(drawAddress)).transfer(amount * 10 ** 6);
        return SUCCESS;
    }
	
    function drawCoin(address contractAddress, address drawAddress, uint amount) onlyAdmin public returns(uint) {
        TRC20 token = TRC20(contractAddress);
        uint256 decimal = 10 ** uint256(token.decimals());
        token.transfer(drawAddress, amount * decimal);
        return SUCCESS;
    }

    constructor() public {
        minter = msg.sender;
		starPool = StarPool(address(0x415686b9b6c0d202569709bdb49ea3fe6412aac846));
    }
}


//SourceUnit: StarPool.sol

pragma solidity ^0.5.13;

contract StarPool{
	function GetUserInfo(address _address) public view returns (uint, uint, address, uint, uint, uint, uint, uint, uint);
}


//SourceUnit: TRC20.sol

pragma solidity ^0.5.13;

contract TRC20 {

  function transferFrom(address from, address to, uint value) external returns (bool ok);

  function decimals() public view returns (uint8);

  function transfer(address _to, uint256 _value) public;

  function balanceOf(address account) external view returns (uint256);
}