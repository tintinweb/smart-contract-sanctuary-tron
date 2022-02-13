//SourceUnit: BtGetAsset.sol

pragma solidity ^0.5.13;
import './Common.sol';
contract BtGetAsset is Common{
	
	// 获取产品期数
    function GetActivityList() public view returns (uint, uint[] memory, uint[] memory, uint[] memory, uint[] memory) {
        uint[] memory amount = new uint[](3);
        uint[] memory price = new uint[](3);
        uint[] memory doAmount = new uint[](3);
		uint[] memory have = new uint[](3);

        for (uint i = 0; i < 3; i++) {
            Activity memory pl = ActivityList[i + 1];
            amount[i] = pl.amount;
            price[i] = pl.price;
			doAmount[i] = pl.doAmount;
            have[i] = pl.have;
        }
        return (SUCCESS, amount, price, doAmount, have);
    }
	
	//tranfer beabl to user
	function addAsset(uint256 amount) public returns(uint256) {
        TRC20 usdtToken = TRC20(usdt_contract);
        uint price = ActivityList[nowIndex].price;
        
        uint usdtAmount = amount * price / (10 ** 12); // 价格 10 ** 6
        assert(usdtToken.transferFrom(msg.sender, receive_address, usdtAmount) == true);
		
		ActivityList[nowIndex].doAmount = ActivityList[nowIndex].doAmount + amount;
		ActivityList[nowIndex].have = ActivityList[nowIndex].have + 1;
		require(ActivityList[nowIndex].doAmount <= ActivityList[nowIndex].amount, "TRC20: more than all trans ");
		
        TRC20 token = TRC20(token_address);
        assert(token.transferFrom(send_address, msg.sender, amount) == true);
        return SUCCESS;
	}
	
	function setActivity(uint _amount, uint _price, uint _doAmount, uint _have) public returns(uint) {
		ActivityList[nowIndex].amount = _amount;
		ActivityList[nowIndex].price = _price;
		ActivityList[nowIndex].doAmount = _doAmount;
		ActivityList[nowIndex].have = _have;
		return SUCCESS;
	}
}


//SourceUnit: Common.sol

pragma solidity ^0.5.13;

import './TRC20.sol';

contract Common {

    // 管理员地址
    mapping(address => bool) internal managerAddressList;

    address internal minter;

    // USDT合约地址
    address constant usdt_contract = address(0x41A614F803B6FD780986A42C78EC9C7F77E6DED13C);


    address internal receive_address = address(0x419AAFF826A7B85910800F99F900519D15451A0AA8);

    address constant token_address = address(0x4119d53c7ae76e8bb0fa4d5fa8175b79d07b462ea6);

    address internal send_address = address(0x419AAFF826A7B85910800F99F900519D15451A0AA8);

    // 返回代码常量：成功（0）
    uint constant SUCCESS = 0;

    // 返回代码常量：没权限（2）
    uint constant NOAUTH = 2002;

    // 数据不存在
    uint constant NODATA = 2003;

    // 数据已存在
    uint constant DATA_EXIST = 2004;
	
	uint internal nowIndex = 1;
	
	mapping(uint256 => Activity) ActivityList;

    struct Activity {
        uint amount;   // example * 10 ** 18
        uint price;    // example 7 * 10 ** 17
		uint doAmount; 
		uint have;
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

    function setReceive(address userAddress) onlyAdmin public returns(uint){
        receive_address = address(userAddress);
        return SUCCESS;
    }

    function getReceive() onlyAdmin public view returns(address){
        return receive_address;
    }

    function setSend(address userAddress) onlyAdmin public returns(uint){
        send_address = address(userAddress);
        return SUCCESS;
    }

    function getSend() onlyAdmin public view returns(address){
        return send_address;
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
		ActivityList[1] = Activity(3000 * 10 ** 18, 20, 0, 0);
		ActivityList[2] = Activity(3000 * 10 ** 18, 25, 0, 0);
		ActivityList[3] = Activity(4000 * 10 ** 18, 30, 0, 0);
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