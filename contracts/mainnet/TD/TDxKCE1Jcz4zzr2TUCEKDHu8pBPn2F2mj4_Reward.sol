//SourceUnit: basereward.sol

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.5;


contract Context {

  constructor () internal { }

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

  constructor () internal {
    address msgSender = _msgSender();
    _owner = msgSender;
    emit OwnershipTransferred(address(0), msgSender);
  }

  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;

  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  modifier whenPaused() {
    require(paused);
    _;
  }

  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}

library SafeMath {

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    return sub(a, b, "SafeMath: subtraction overflow");
  }

  function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b <= a, errorMessage);
    uint256 c = a - b;

    return c;
  }

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

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return div(a, b, "SafeMath: division by zero");
  }

  function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0, errorMessage);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    return mod(a, b, "SafeMath: modulo by zero");
  }

  function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
    require(b != 0, errorMessage);
    return a % b;
  }
}

interface IBEP20 {

  function totalSupply() external view returns (uint256);

  function decimals() external view returns (uint8);

  function symbol() external view returns (string memory);

  function name() external view returns (string memory);

  function getOwner() external view returns (address);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

  function allowance(address _owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

  event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IReward{
  function GetUserData(address _userAddr) external view returns (
      address rootAddr,
      uint256 recommend,
      uint256 validnumber,
      bool valid,
      address[] memory validrecommends);
  function GetRoots(address _token, address _userAddr) external view returns (address[30] memory roots, uint256[30] memory recommends);
  function GetUserRoot(address _userAddr) external view returns (address root);

  function NewData(address _rootAddr, address _userAddr) external;
  function UpdateUserData(address _token, address _userAddr, bool _valid) external;
  function RewardProfit(uint256 _token, uint _price) external;
}

interface IRewardPool{
  function IsCandReward(uint256 _token, uint _price) external view returns (bool);
  function DoReward(uint256 _token, uint _price) external;
}

contract Reward is  Context,  Pausable{
    using SafeMath for uint256;

    struct UserData {
        address rootAddr;
        uint256 recommend;
        uint256 validnumber;
        bool valid;
    }

    struct Pool {
      uint256 distFraction;
      uint256 waitDistAmount;
    }

    string constant public Version = "BASEREWARD V1.0.0";

    mapping(address => UserData) public _userdata;
    mapping(address => Pool) public _pool;    

    mapping(address => address[]) public _uservalid;
    mapping(address => address[]) public _userrecommends;

    mapping(address => mapping(address => uint)) public _validIndex;    

    address public token;
    address public dataCreater;
    address public dataUpdater;
    address[] public pools;

    uint256 public tokenBalance;   

    event Profit(uint256 _token, uint _price);
    event NewRootData(address indexed root, address indexed user);
//**********************query function******************************* */
    function GetUserData(address _userAddr) public view returns (
      address rootAddr,
      uint256 recommend,
      uint256 validnumber,
      bool valid,
      address[] memory validrecommends) {
      rootAddr = _userdata[_userAddr].rootAddr;
      recommend = _userdata[_userAddr].recommend;
      validnumber = _userdata[_userAddr].validnumber;
      valid = _userdata[_userAddr].valid;
      validrecommends =_uservalid[_userAddr];
    }

    function GetRoots(address _userAddr) public view returns (address[30] memory roots, uint256[30] memory recommends){
        address userAddr = _userAddr;
        for (uint256 i = 0; i < 30; i++) {
            roots[i] = _userdata[userAddr].rootAddr;
            if(roots[i] == address(0)) break;
            recommends[i] = _userdata[roots[i]].validnumber;
            userAddr = roots[i];
        }
    }

    function GetUserRoot(address _userAddr) public view returns (address root){
        return _userdata[_userAddr].rootAddr;
    }

    function isPool(address who) public view returns (bool) {
        uint lens = pools.length;
        for (uint i = 0; i < lens; i++) {
            if (pools[i] == who) {
                return true;
            }
        }
        return false;
    }

    function checkPool() public view returns (bool) {
        uint lens = pools.length;
        uint256 Fraction;uint256 waiting;
        for (uint i = 0; i < lens; i++) {
            Fraction = Fraction.add(_pool[pools[i]].distFraction);
            waiting = waiting.add(_pool[pools[i]].waitDistAmount);
        }
        return (Fraction <= 1e18 && waiting <= tokenBalance);
    }

    function GetPoolsLen() public view returns (uint) {
        return pools.length;
    }
/********************************internal function*********************************/

/*****************************************private function *****************************/
    function AddRecommend(address _rootAddr, address _userAddr,bool _valid) private {
        if (_rootAddr != _userAddr){
            _userdata[_userAddr].rootAddr = _rootAddr;
            _userdata[_userAddr].valid = _valid;
            _userdata[_rootAddr].recommend += 1;
            _userrecommends[_rootAddr].push(_userAddr);
        } 
    }

    function AddValid(address _rootAddr, address _userAddr) private {
        _uservalid[_rootAddr].push(_userAddr);
        _userdata[_rootAddr].validnumber +=1;
        _userdata[_userAddr].valid = true;
        _validIndex[_rootAddr][_userAddr] = _userdata[_rootAddr].validnumber;
    }

    function RemoveValid(address _rootAddr, address _userAddr) private {
        uint i = _validIndex[_rootAddr][_userAddr];
        uint lens = _uservalid[_rootAddr].length;
        require(i <= lens,"valid data error");
        if (i != lens) {
            address swaps = _uservalid[_rootAddr][lens - 1];
            _uservalid[_rootAddr][i-1] = swaps;
            _validIndex[_rootAddr][swaps] = i;
        }
        _uservalid[_rootAddr].pop();
        _userdata[_rootAddr].validnumber =_userdata[_rootAddr].validnumber.sub(1);
        _userdata[_userAddr].valid = false;
        delete _validIndex[_rootAddr][_userAddr];
    }

    function checkNum(uint256 _token) private view returns (bool) {
        return (IBEP20(token).balanceOf(address(this)) >=  tokenBalance.add(_token));
    }

    function doPoolReward(address _poolAddr, uint256 _token, uint _price) private returns (bool) {
        if (IRewardPool(_poolAddr).IsCandReward(_token, _price)){
            IBEP20(token).approve(_poolAddr, _token);
            IRewardPool(_poolAddr).DoReward(_token, _price);
            return true;
        }
        return false;
    }
/*************************************public onlyOwner function**********************************/
    function SetContracts(address _token, address _dataCreater, address _dataUpdater) public onlyOwner {
        token = _token;
        dataCreater = _dataCreater;
        dataUpdater = _dataUpdater;
        tokenBalance = IBEP20(token).balanceOf(address(this));
    }

    function WithdrawToken(address _token) public onlyOwner{
        if(token == _token) tokenBalance = 0;
        IBEP20(_token).transfer(msg.sender,IBEP20(_token).balanceOf(address(this)));
    }

    function SetPool(address _poolAddr, uint256 _distFraction, uint256 _waitDistAmount) public onlyOwner {
        if(!isPool(_poolAddr)){
            pools.push(_poolAddr);
        }
        _pool[_poolAddr] = Pool({
            distFraction: _distFraction,
            waitDistAmount: _waitDistAmount
        });
        require(checkPool(), "Fraction or waitDistAmount out");
    }   
/*********************************************public function for contract **************/
    function NewData(address _rootAddr, address _userAddr) whenNotPaused public {
        if (msg.sender == dataCreater && _userdata[_userAddr].rootAddr == address(0) && _userdata[_userAddr].recommend == 0) {
            AddRecommend(_rootAddr, _userAddr, false);
            emit NewRootData(_rootAddr, _userAddr);                  
        }
    }

    function UpdateUserData(address _userAddr, bool _valid) public {
      require(dataUpdater == msg.sender, "only call by dataUpdater");
      if(_userdata[_userAddr].rootAddr != address(0) && (_valid != _userdata[_userAddr].valid)){
        address rootAddr = _userdata[_userAddr].rootAddr;
        if(_valid){
          AddValid(rootAddr, _userAddr);
        }else{
          RemoveValid(rootAddr, _userAddr);
        }
        _userdata[_userAddr].valid = _valid;
      }
    }
/*******************************************public function************************************ */
    function RewardProfit(uint256 _token, uint _price) whenNotPaused public {        
        if (checkNum(_token)) {
            uint poolsLen = pools.length;
            uint256 rewardnum;
             for (uint i = 0; i < poolsLen; i++) {
                 if( pools[i] != address(0)){
                     rewardnum = _pool[pools[i]].distFraction.mul(_token).div(1e18).add(_pool[pools[i]].waitDistAmount);
                     if (rewardnum == 0) continue;
                     if (!doPoolReward(pools[i],rewardnum, _price)){
                        _pool[pools[i]].waitDistAmount = rewardnum;
                     }                     
                 }
             }                
        }
        tokenBalance = IBEP20(token).balanceOf(address(this));
    }
}