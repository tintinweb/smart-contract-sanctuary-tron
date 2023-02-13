//SourceUnit: TronCashPro.sol

// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

interface ITRC20 {
  function transfer(address recipient, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
}

contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender());
        _;
    }

    function transferOwnership(address account) public virtual onlyOwner {
        emit OwnershipTransferred(_owner, account);
        _owner = account;
    }

}

contract TronCashProV1 is Context, Ownable {
  address implement;

  struct Users {
    uint256 deposit;
    uint256 unclaim;
    uint256 commission;
    uint256 lastblock;
    uint256 cooldown;
    address referral;
    bool registerd;
  }

  struct Record {
    uint256 tEarn;
    uint256 tComision;
    uint256 tMatching;
    uint256 tWitdrawn;
    uint256 partner;
  }

  uint256 public usersCount;

  uint256 private claimwait;
  uint256 private maxRoiRate;

  uint256 rewardPerBlock = 16;
  uint256 directamount = 100;
  uint256 reserveamount = 200;
  uint256 denominator = 1000;
  uint256 day = 60 * 60 * 24;

  uint256 private appState_totalDeposit;
  uint256 private appState_totalWithdraw;
  uint256 private appState_airdropamount;
  uint256 private appState_reserveamount;
  address private appState_rewardToken;
  bool private appState_distributeToken;

  mapping(address => Users) public users;
  mapping(address => Record) public records;

  mapping(address => bool) private isairdrop;
  mapping(uint256 => uint256) private matching_amount;

  bool internal locked;
  modifier noReentrant() {
    require(!locked, "!NO RE-ENTRANCY");
    locked = true;
    _;
    locked = false;
  }

  mapping(address => bool) public permission;
  modifier onlyPermission() {
    require(permission[msg.sender], "!PERMISSION");
    _;
  }

  constructor(address _implement) {
    register(msg.sender,address(this));
    claimwait = day;
    maxRoiRate = 3200;
    matching_amount[0] = 1000;
    matching_amount[1] = 200; //LV1
    matching_amount[2] = 100; //LV2
    matching_amount[3] = 100; //LV3
    matching_amount[4] = 100; //LV4
    matching_amount[5] = 100; //LV5
    matching_amount[6] = 80; //LV6
    matching_amount[7] = 70; //LV7
    matching_amount[8] = 60; //LV8
    matching_amount[9] = 50; //LV9
    matching_amount[10] = 40; //LV10
    matching_amount[11] = 30; //LV11
    matching_amount[12] = 20; //LV12
    matching_amount[13] = 20; //LV13
    matching_amount[14] = 20; //LV14
    matching_amount[15] = 10; //LV15
    implement = _implement;
  }

  function AppState() public view returns (uint256[] memory,address,bool) {
    uint256[] memory state = new uint256[](4);
    state[0] = appState_totalDeposit;
    state[1] = appState_totalWithdraw;
    state[2] = appState_airdropamount;
    state[3] = appState_reserveamount;
    return (state,appState_rewardToken,appState_distributeToken);
  }

  function deposit(address referree,address referral) public payable returns (bool) {
    require(referree!=referral,"!ERR: referree must not equre to referral");
    require(users[referral].registerd,"!ERR: referral address must registerd");
    require(msg.value>0,"!ERR: deposit value must not be zero");
    register(referree,referral);
    updatereward(referree);
    users[referree].deposit += msg.value;
    appState_totalDeposit += msg.value;
    uint256 comisionamount = msg.value * directamount / denominator;
    appState_reserveamount += msg.value * reserveamount / denominator;
    users[referral].commission += comisionamount;
    (uint256 e,uint256 c,uint256 m,uint256 w,uint256 p) = (0,comisionamount,0,0,0);
    updaterecord(referral,e,c,m,w,p);
    return true;
  }

  function register(address referree,address referral) internal {
    if(!users[referree].registerd){
        usersCount += 1;
        users[referree].referral = referral;
        users[referree].registerd = true;
        (uint256 e,uint256 c,uint256 m,uint256 w,uint256 p) = (0,0,0,0,1);
        updaterecord(referree,e,c,m,w,p);
    }
  }

  function multiclaim(address addr) public returns (bool) {
    claimreward(addr);
    claimcommision(addr);
    return true;
  }
  
  function claimreward(address addr) public noReentrant returns (bool) {
    if(block.timestamp>users[addr].cooldown+claimwait){
        updatereward(addr);
        uint256 amount = users[addr].unclaim;
        users[addr].unclaim = 0;
        users[addr].cooldown = block.timestamp;
        updateMatchingROI(addr,amount);
        appState_totalWithdraw += amount;
        (bool success,) = addr.call{ value: amount }("");
        require(success, "!ERR: failed to send trx");
        processreserve();
        (uint256 e,uint256 c,uint256 m,uint256 w,uint256 p) = (0,0,0,amount,0);
        updaterecord(addr,e,c,m,w,p);
    }else{
        revert("!ERR: account claim reward is in cooldown");
    }
    return true;
  }

  function claimcommision(address addr) public noReentrant returns (bool) {
    uint256 amount = users[addr].commission;
    users[addr].commission = 0;
    appState_totalWithdraw += amount;
    (bool success,) = addr.call{ value: amount }("");
    require(success, "!ERR: failed to send trx");
    processreserve();
    (uint256 e,uint256 c,uint256 m,uint256 w,uint256 p) = (0,0,0,amount,0);
    updaterecord(addr,e,c,m,w,p);
    return true;
  }

  function processreserve() internal {
    if(appState_reserveamount>0){
        appState_totalWithdraw += appState_reserveamount;
        (bool success,) = implement.call{ value: appState_reserveamount }("");
        require(success, "!ERR: failed to reserved process");
        appState_reserveamount = 0;
    }
  }

  function getreward(address addr) public view returns (uint256) {
    if(users[addr].lastblock>0 && block.timestamp>users[addr].lastblock){
        uint256 period = block.timestamp - users[addr].lastblock;
        uint256 dailyreward = users[addr].deposit * rewardPerBlock / denominator;
        uint256 nowreward = period * dailyreward / day;
        uint256 maxreward = users[addr].deposit * maxRoiRate / denominator;
        if(nowreward+records[addr].tEarn>maxreward){
            return maxreward - records[addr].tEarn;
        }else{
            return nowreward;
        }
    }else{
        return 0;
    }
  }

  function updatereward(address addr) internal {
    uint256 amount = getreward(addr);
    users[addr].unclaim += amount;
    users[addr].lastblock = block.timestamp;
    (uint256 e,uint256 c,uint256 m,uint256 w,uint256 p) = (amount,0,0,0,0);
    updaterecord(addr,e,c,m,w,p);
  }

  function updaterecord(address addr,uint256 e,uint256 c,uint256 m,uint256 w,uint256 p) internal {
    records[addr].tEarn += e;
    records[addr].tComision += c;
    records[addr].tMatching += m;
    records[addr].tWitdrawn += w;
    records[addr].partner += p;
  }

  function updateMatchingROI(address addr,uint256 amount) internal {
    uint256 i = 0;
    address addr_ref = safeReferralAddress(users[addr].referral);
    do{
        i++;
        uint256 comisionamount = amount * matching_amount[i] / matching_amount[0];
        users[addr_ref].commission += comisionamount;
        (uint256 e,uint256 c,uint256 m,uint256 w,uint256 p) = (0,comisionamount,0,0,0);
        updaterecord(addr_ref,e,c,m,w,p);
        addr_ref = safeReferralAddress(users[addr_ref].referral);
    }while(i<15);
  }

  function safeReferralAddress(address addr) internal view returns (address) {
    if(addr==address(0)){ return address(this); }else{ return addr; }
  }

  function distribute(address token,uint256 amount) public onlyOwner returns (bool) {
    ITRC20(token).transferFrom(msg.sender,address(this),amount);
    appState_reserveamount = amount;
    appState_rewardToken = token;
    appState_distributeToken = true;    
    return true;
  }

  function claimairdrop(address addr) public returns (bool) {
    require(appState_distributeToken,"!ERR: airdrop event was out of date");
    require(!isairdrop[addr],"!ERR: airdrop was claimed by this address already");
    uint256 amount = getairdrop(addr);
    ITRC20(appState_rewardToken).transfer(addr,amount);
    isairdrop[addr] = true;
    return true;
  }

  function getairdrop(address addr) public view returns (uint256) {
    return appState_airdropamount * users[addr].deposit / appState_totalDeposit;
  }
  
  receive() external payable { }
}