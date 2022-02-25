//SourceUnit: StarRelation.sol

pragma solidity ^0.5.13;

import "./StarRelationStorage.sol";
import './TRC20.sol';

contract StarRelation is StarRelationStorage{

    // 直推列表
    function getSuperiorUser(address _address) public view returns (uint, address) {
        if (superiorUserList[msg.sender] == address(0)) {
            return (NODATA, address(0));
        }
        return (SUCCESS, superiorUserList[_address]);
    }

    // 绑定上级
    function bindSuperiorUser(address superiorAddress) public returns (uint) {
        require(!downUserList[msg.sender][superiorAddress], "cant bind your subordinate user");
        require(superiorAddress != msg.sender, "cant bind yourself");
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
    function GetSubordinateUserList(address _address, uint page, uint limit) public view returns (address[] memory) {
        address[] memory subList = subordinateUserList[_address];
        address[] memory ar = new address[](limit);
        for (uint i = 0; i < limit; i ++) {
            if ((i + 1 + (page - 1) * limit) <= subList.length)
                ar[i] = subList[(subList.length - i - 1 - (page - 1) * limit)];
        }
        return ar;
    }

    // 下下级列表
    function GetLowestUserList(address _address, uint page, uint limit) public view returns (address[] memory) {
        address[] memory subList = lowestUserList[msg.sender];
        address[] memory ar = new address[](limit);
        for (uint i = 0; i < limit; i ++) {
            if ((i + 1 + (page - 1) * limit) <= subList.length)
                ar[i] = subList[(subList.length - i - 1 - (page - 1) * limit)];
        }
        return ar;
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
}


//SourceUnit: StarRelationStorage.sol

pragma solidity ^0.5.13;

contract StarRelationStorage {

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


    // 返回代码常量：成功（0）
    uint constant SUCCESS = 0;

    // 数据不存在
    uint constant NODATA = 2003;

    // 数据已存在
    uint constant DATA_EXIST = 2004;

    // 管理员地址
    mapping(address => bool) internal managerAddressList;

    address internal minter;

    modifier onlyAdmin() {
        require(
            msg.sender == minter || managerAddressList[msg.sender],
            "Only admin can call this."
        );
        _;
    }

    constructor() public {
        minter = msg.sender;
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