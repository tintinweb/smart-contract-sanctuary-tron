//SourceUnit: trxworld.sol

pragma solidity 0.5.10;
/**
* https://trxworld.in/
**/

contract TRX_World {
    address public owner;
    address payable public admin;
    address payable public platform_fee;
    
    event Registration(address indexed user, address indexed referrer);
    event Upgrade(address indexed user, uint256 amount);
    
    constructor() public {
        owner=msg.sender;
        admin=0x647DA701D4bF212E0DE62A52B1005493be45055c;
        platform_fee =0xcB149b3D0b970cF19422C5077ceBB106ab8eA2AA;
    }
    function buyLevel(address payable _upline) external payable {
		uint256 _amount = msg.value;
        admin.transfer(_amount*15/100);
        platform_fee.transfer(_amount*5/100);
        _upline.transfer(_amount*45/100);
		emit Upgrade(msg.sender,_amount);
    }
    function withdraw(address payable _receiver, uint256 _amount) public {
		if (msg.sender != owner) {revert("Access Denied");}
		_receiver.transfer(_amount);  
    }
    function setPayoutAccount(address payable _platform_fee) public {
        if (msg.sender != owner) {revert("Access Denied");}
		platform_fee=_platform_fee;
    }
    function registrationExt(address payable _upline) public payable {
        uint256 _amount = msg.value;
        admin.transfer(_amount*15/100);
        platform_fee.transfer(_amount*5/100);
        _upline.transfer(_amount*45/100);
        emit Registration(msg.sender,_upline);
    }
}