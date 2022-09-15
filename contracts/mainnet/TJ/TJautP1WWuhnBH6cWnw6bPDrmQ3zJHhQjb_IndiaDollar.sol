//SourceUnit: indiantrx.sol

// SPDX-License-Identifier: GPLv3
pragma solidity ^0.6.12;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract IndiaDollar {

    address private owner;

    struct User {
      string name;
      uint user_id;
      uint ref_id;
      address user_address;
      bool is_exist;
    }

    using SafeMath for uint256;

    mapping(address => User) public users;
    //mapping (uint8 => uint) public levelPrice;
    //mapping (uint8 => uint) public matrixamt;
    mapping (uint => address) public userList;
    mapping(address => uint) balance;
    event regLevelEvent(uint8 indexed Matrix, address indexed UserAddress, uint UserId, address indexed ReferrerAddress, uint ReferrerId, uint Time);
    event sponsorEarnedEvent(address indexed UserAddress, uint UserId, address indexed Caller, uint CallerId, uint EarnAmount, uint Time);//User[] public users;
    event unilevelEarnedEvent(address indexed UserAddress, uint UserId, address indexed Caller, uint CallerId, uint EarnAmount, uint Time);
    event buyLevelEvent(uint8 indexed Matrix, address indexed UserAddress, uint UserId, string matrixname, uint Time);
    event matrixEarnedEvent(address indexed UserAddress, uint UserId, address indexed Caller, uint CallerId, uint EarnAmount, uint Time);
    event poolmatrixEarnedEvent(string matrixname, address indexed UserAddress, address indexed Caller, uint EarnAmount, uint Time);
    
    constructor() public {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        // matrixamt[1] = 60000000;
        // matrixamt[2] = 100000000;
        // matrixamt[3] = 250000000;
        // matrixamt[4] = 500000000;
        // matrixamt[5] = 1000000000;
    }
   
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    function addUsers(string memory _name, uint _user_id, uint _ref_id, address _ref_address, address _uladd1, address _uladd2, address _uladd3, address _uladd4, address _uladd5, address adminwall) external payable {
        require(users[msg.sender].is_exist == false,  "User Exist");
        require(_ref_id >= 0 && _ref_id <= _user_id, "Incorrect referrerID");
        require(msg.sender.balance>=50000000, "Add more token!");
        /*if(msg.sender.balance<50000000){
            revert("Add more token!");
        }*/
        uint amount = msg.value;
        
        users[msg.sender] = User({
            name: _name,
            user_id: _user_id,
            ref_id: _ref_id,
            user_address: msg.sender,
            is_exist: true
        });

        uint _refshare = amount.div(5).mul(4); /* 80% pay direct sponsor*/
        _workPlanReg(_refshare, _ref_id, _user_id,_ref_address);
        
        uint _share = amount.div(5).div(5); /*4% pay unilevel*/
        if(_uladd1!=0x0000000000000000000000000000000000000000){
            _regUnilevel(_uladd1,_share);
        }else{
            _sendToAdmin(adminwall,_share);
        }
        if(_uladd2!=0x0000000000000000000000000000000000000000){
            _regUnilevel(_uladd2,_share);
        }else{
            _sendToAdmin(adminwall,_share);
        }
        if(_uladd3!=0x0000000000000000000000000000000000000000){
            _regUnilevel(_uladd3,_share);
        }else{
            _sendToAdmin(adminwall,_share);
        }
        if(_uladd4!=0x0000000000000000000000000000000000000000){
            _regUnilevel(_uladd4,_share);
        }else{
            _sendToAdmin(adminwall,_share);
        }
        if(_uladd5!=0x0000000000000000000000000000000000000000){
            _regUnilevel(_uladd5,_share);
        }else{
            _sendToAdmin(adminwall,_share);
        }
    }
    
    function _workPlanReg(uint _refshare, uint _ref_id, uint _user_id,address _ref_address) internal {
        userList[_user_id] = msg.sender;
        if(_ref_address!=0x0000000000000000000000000000000000000000){
            referralpay(_ref_address,_refshare);
        }
        emit regLevelEvent(1, msg.sender, _user_id, userList[_ref_id], _ref_id, now);
    }

    function buylevel(address refaddress, address uladd1, address uladd2, address uladd3, address uladd4, address uladd5, address leveladdress, address adminwall) external payable {
        require(users[msg.sender].is_exist == true,  "User not Exist");
        //require(msg.value == levelPrice[_level], "Incorrect Value");
        require(msg.sender.balance>50000000, "Add more token!");
        /*if(msg.sender.balance<50000000){
            revert("Add more token!");
        }*/
        uint levelPrice = msg.value;
        /*** Referral Pay ***/
        if(refaddress!=0x0000000000000000000000000000000000000000){
            uint share = levelPrice.div(5).mul(2); /*40% use to pay direct*/
            uint refadminamt = share.mul(5).div(100); /*5% admin charge*/
            uint shareamt = share.sub(refadminamt); /*35% direct sponsor*/
            referralpay(refaddress,shareamt);
            _sendToAdmin(adminwall,refadminamt);
        }
        /*** Unilevel Pay ***/
        uint _share = levelPrice.mul(4).div(100); //4%
        if(uladd1!=0x0000000000000000000000000000000000000000){
            _regUnilevel(uladd1,_share);
        }else{
            _sendToAdmin(adminwall,_share);
        }
        if(uladd2!=0x0000000000000000000000000000000000000000){
            _regUnilevel(uladd2,_share);
        }else{
            _sendToAdmin(adminwall,_share);
        }
        if(uladd3!=0x0000000000000000000000000000000000000000){
            _regUnilevel(uladd3,_share);
        }else{
            _sendToAdmin(adminwall,_share);
        }
        if(uladd4!=0x0000000000000000000000000000000000000000){
            _regUnilevel(uladd4,_share);
        }else{
            _sendToAdmin(adminwall,_share);
        }
        if(uladd5!=0x0000000000000000000000000000000000000000){
            _regUnilevel(uladd5,_share);
        }else{
            _sendToAdmin(adminwall,_share);
        }

        /*** placement Level Pay ***/
        uint levelamount = levelPrice.div(5).mul(2); //40%
        uint adminamt = levelamount.mul(5).div(100); //5%
        uint shareamt = levelamount.sub(adminamt);
        if(leveladdress!=0x0000000000000000000000000000000000000000 && levelamount>0){
            commissionlevel(leveladdress,shareamt);
            _sendToAdmin(adminwall,adminamt);
        }else{
            _sendToAdmin(adminwall,levelamount);
        }
    }

    //function buyMatrix(uint8 packid, address incomeaddress, uint share, string memory matrixname, address adminwall) external payable {
    function buyMatrix(uint8 packid, address incomeaddress, string memory matrixname, address adminwall) external payable {
        uint256 price = msg.value;
        require(users[msg.sender].is_exist == true,  "User not Exist");
        //require(msg.sender.balance>=price, "Add more token!");
        /*if(msg.sender.balance>price){
            revert("Add more token!");
        }*/
        emit buyLevelEvent(packid, msg.sender, users[msg.sender].user_id, matrixname, now);
        /*** Pool Matrix Pay ***/
        if(incomeaddress!=0x0000000000000000000000000000000000000000){
            //matrixpay(incomeaddress,price,matrixname);
            payable(incomeaddress).transfer(price);
            emit poolmatrixEarnedEvent(matrixname, incomeaddress, msg.sender, price, now);
        }else{
            payable(adminwall).transfer(price);
            //_sendToAdmin(adminwall,price);
        }
    }

    function _sendToAdmin(address _to, uint256 _value) internal {
        payable(_to).transfer(_value);
    }

    // function matrixpay(address incomeaddress, uint256 share,  string memory matrixname) internal {
    //     payable(incomeaddress).transfer(share);
    //     emit poolmatrixEarnedEvent(matrixname, incomeaddress, users[incomeaddress].user_id, msg.sender, users[msg.sender].user_id, share, now);
    // }

    function commissionlevel(address send_to, uint levelamount) internal{
        payable(send_to).transfer(levelamount);
        emit matrixEarnedEvent(send_to, users[send_to].user_id, msg.sender, users[msg.sender].user_id, levelamount, now);
    }

    function _regUnilevel(address _unilevels, uint _share) internal {
        payable(_unilevels).transfer(_share);
        emit unilevelEarnedEvent(_unilevels, users[_unilevels].user_id, msg.sender, users[msg.sender].user_id, _share, now);
    }
    
    function referralpay(address send_to, uint _share) internal {
        payable(send_to).transfer(_share);
        emit sponsorEarnedEvent(send_to, users[send_to].user_id, msg.sender, users[msg.sender].user_id, _share, now);
    }

    function getUserBalance(address _owner) external view returns (uint) {
        return address(_owner).balance;
    }

}