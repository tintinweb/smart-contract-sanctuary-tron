//SourceUnit: basepowerpool.sol

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

library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
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
  function GetRoots(address _userAddr) external view returns (address[30] memory roots, uint256[30] memory recommends);
  function UpdateUserData(address _userAddr, bool _valid) external;
}

interface IPowerPool {
    function tatolpower() external view returns (uint256);
    function otherProfit() external view returns (uint256);
    function composerAddr() external view returns (address);
    function token() external view returns (address);
    function rewardAddr() external view returns (address);
    function other() external view returns (address);
    function MintProfitIndex() external view returns (uint);
    function users(uint) external view returns (address);
    function GetUser(address who) external view returns (uint256 power, uint256 powerUsed, uint256 profit, uint256 recommendProfit, uint256 powerProfit);
    function GetMintProfit(uint _index) external view returns (uint256 nowtatolpower, uint256 subtatolpower, uint256 profittoken, uint profitprice, uint blocknumber);

    function AddPowerOnly(address _user, uint256 _power) external;
    function AddPowerAndProfit(address _composer, uint256 _power, uint256 _token, uint256 _busd, uint _price) external;
}

contract PowerContract is  Context,  Pausable{
    using SafeMath for uint256;

    struct UserPower {
        uint256 power;
        uint256 powerUsed;
        uint256 profit;
        uint256 recommendProfit;
        uint256 powerProfit;
    }

    struct UserTips {
        uint index;
        bool updated;
    }

    struct UserRProfit {
        uint256 profit;
        uint256 subpower;
    }

    struct MintProfit {
        uint256 nowtatolpower;
        uint256 subtatolpower;
        uint256 profittoken;
        uint profitprice;
        uint blocknumber;
    }

    struct MintProfitFraction {
        uint256 powerFraction;
        uint256 average;
        uint resetIndex;
    }
    string constant public Version = "BASEPOWERPOOL V1.0.0";

    mapping(uint => MintProfit) private _mintProfit;
    mapping(uint => MintProfitFraction) public _mintProfitFraction;
    mapping(address => UserPower) public _userpower;
    mapping (address => UserTips) private _usertips;
    mapping (address => UserRProfit) private _userRp;

    address public composerAddr;
    address public token;
    address public rewardAddr;
    address public other;
    address[] public users;

    uint public MintProfitIndex;
    uint256 public tatolpower;
    uint256 public otherProfit;
    uint256 public limitBusd = 200 * 10**18;
    uint256 public validPower = 200;
    uint256[] public recommendpoint = [30,5,5,5,5,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2];
    bool public canUpdate;

    event Profit(uint256 _token, uint _price);
//**********************query function******************************* */
    function isUser(address who) public view returns (bool) {
       
        for (uint256 i = 0; i < users.length; i++) {
            if (users[i] == who) {
                return true;
            }
        }
        return false;
    }

    function GetUserLen() public view returns (uint) {
        return users.length;
    }

    function GetMintProfit(uint _index) public view returns (
        uint256 nowtatolpower,
        uint256 subtatolpower,
        uint256 profittoken,
        uint profitprice,
        uint blocknumber
    ) { 
      nowtatolpower = _mintProfit[_index].nowtatolpower;
      subtatolpower = _mintProfit[_index].subtatolpower;
      profittoken = _mintProfit[_index].profittoken;
      profitprice = _mintProfit[_index].profitprice;
      blocknumber = _mintProfit[_index].blocknumber;
    }

    function GetUser(address who) public view returns (
        uint256 power,
        uint256 powerUsed,
        uint256 profit,
        uint256 recommendProfit,
        uint256 powerProfit
    ) { 
        (power, powerUsed, profit, recommendProfit, powerProfit) = getUserRawData(who);
        uint index = getUserRawTips(who);
        uint256 _pUsed; uint256 _pf;

        if(index < MintProfitIndex){
          (_pUsed, _pf) = getProfitAndUsed(power, index);
          power = power.sub(_pUsed);
          powerProfit = powerProfit.add(_pf);
          profit = profit.add(_pf);
          powerUsed = powerUsed.add(_pUsed);
        }

        if(_userRp[who].profit > 0 && power != 0){
          (_pUsed, _pf) = getUserRpAndUsed(who, power);
          power = power.sub(_pUsed);
          profit = profit.add(_pf);
          recommendProfit = recommendProfit.add(_pf);
          powerUsed = powerUsed.add(_pUsed);
        }
        return (power, powerUsed, profit, recommendProfit, powerProfit);
    }

    function GetUserTips(address who) public view returns (uint index, bool updated) { 
        return (_usertips[who].index,updated = _usertips[who].updated);
    }

    function getFraction(uint index) public view  returns (uint256 powerFraction, uint256 profitFraction) {
      if(index >= MintProfitIndex) {
        return (0,0);
      } 
      uint lastIndex = getLastIndex(_mintProfitFraction[index].resetIndex,MintProfitIndex); 
      require(index <= lastIndex, "index data error");
      if(_mintProfitFraction[lastIndex].resetIndex == index){
        powerFraction = _mintProfitFraction[lastIndex].powerFraction;
        profitFraction = _mintProfitFraction[lastIndex].average;
      } else{
        powerFraction =(_mintProfitFraction[lastIndex].powerFraction.sub(_mintProfitFraction[index].powerFraction))
          .mul(1e18).div(uint256(1e18).sub(_mintProfitFraction[index].powerFraction)); //can be zero
        uint256 usedp = _mintProfitFraction[index].powerFraction.mul(1e18).div(_mintProfitFraction[lastIndex].powerFraction);//can be zero
        uint256 usedps = _mintProfitFraction[lastIndex].average.sub(usedp.mul(_mintProfitFraction[index].average).div(1e18));
        profitFraction = usedps.mul(1e18).div(uint256(1e18).sub(usedp));
      } 
      return (powerFraction,profitFraction);             
    }

    function getLastIndex(uint index,uint lastIndex) public view  returns (uint newIndex) {
      if(index < _mintProfitFraction[lastIndex].resetIndex) {
        return getLastIndex(index,_mintProfitFraction[lastIndex].resetIndex);
      }else{
        return lastIndex;
      }
    }

    function IsCandReward(uint256 _token, uint _price) public view returns (bool) {     
      if (tatolpower == 0) return true;
      uint256 new_sub = _token.mul(_price).div(1e18);
      if(new_sub > tatolpower){
        _token = _token.mul(tatolpower).div(new_sub);
        new_sub = tatolpower;
      }
      uint256 new_pf = new_sub.mul(1e18).div(tatolpower);
      return (new_pf >= 1e9 && new_sub <= 1e56);
    }
/********************************internal function*********************************/
    function getProfit(uint256 _token, uint256 _i) internal view  returns (uint256 _profit) {
      if (_i < recommendpoint.length){
        return _token.mul(recommendpoint[_i]).div(100);
      }else {
        return 0;
      }
    }

    function getUserRawData(address who) internal view  returns (uint256 power, uint256 powerUsed, uint256 profit, uint256 recommendProfit,uint256 powerProfit) {
        powerProfit = _userpower[who].powerProfit;
        powerUsed = _userpower[who].powerUsed;
        power = _userpower[who].power;
        profit = _userpower[who].profit;
        recommendProfit = _userpower[who].recommendProfit;
        return (power, powerUsed, profit, recommendProfit, powerProfit);      
    }

    function getUserRawTips(address who) internal view  returns (uint index) {
        return _usertips[who].index;
    }

    function getProfitAndUsed(uint256 power,uint index) internal view  returns (uint256 powerUsed, uint256 profit) {
      if(power == 0 || index >= MintProfitIndex) {
        return (0,0);
      }
      (uint256 powerFraction, uint256 profitFraction) = getFraction(index);             
      powerUsed = power.mul(powerFraction).div(1e18);
      profit = powerUsed.mul(profitFraction).div(1e18);
    }

    function getUserRpAndUsed(address who, uint256 power) internal view  returns (uint256 powerUsed, uint256 profit) {     
      if(power < _userRp[who].subpower){
        profit = _userRp[who].profit.mul(power).div(_userRp[who].subpower);
        powerUsed = power;
      }else{
        profit = _userRp[who].profit;
        powerUsed = _userRp[who].subpower;
      }
    }
/*****************************************private function fraction*****************************/
    function updateUser(address who) private {
      (uint256 power, uint256 powerUsed, uint256 profit, uint256 recommendProfit,uint256 powerProfit) = GetUser(who);
      if (_userpower[who].powerUsed != powerUsed || !_usertips[who].updated){
        _userpower[who] = UserPower({
          power: power,
          powerUsed: powerUsed,
          profit: profit,
          recommendProfit: recommendProfit,
          powerProfit: powerProfit
        });
      }

      if (!_usertips[who].updated){
          _usertips[who].updated = true;
          _usertips[who].index = MintProfitIndex;
          users.push(who);
      }
      if(_usertips[who].index < MintProfitIndex) _usertips[who].index = MintProfitIndex;

      if(_userRp[who].profit > 0){
          if(power > 0 ){
            tatolpower = tatolpower.sub(_userRp[who].subpower);
          }else{
            otherProfit = otherProfit.add(_userRp[who].profit);
          }        
          delete  _userRp[who];
      }     
    }

    function UpdateUserData(address _userAddr) private {
        if (!canUpdate) return;
        bool valid = true;
        if( _userpower[_userAddr].power < validPower){
            valid = false;
        }
        IReward(rewardAddr).UpdateUserData(_userAddr, valid);
    }

/*************************************public onlyOwner function**********************************/
    function SetContracts(address _composerAddr, address _token, address _rewardAddr, address _other) public onlyOwner {
        composerAddr = _composerAddr;
        token = _token;
        rewardAddr = _rewardAddr;
        other = _other;
    }

    function SetValidPower(uint256 _validPower, bool _canUpdate) public onlyOwner {
        if(canUpdate != _canUpdate) canUpdate = _canUpdate;
        validPower = _validPower;
    }

    function SetLimitBusd(uint256 _limitBusd) public onlyOwner {
        limitBusd = _limitBusd;
    }

    function SetRecommendPoint(uint256[] memory _recommendpoint) public onlyOwner {
      uint256 all = 0;
      for(uint i = 0; i < _recommendpoint.length; i++){
        all += _recommendpoint[i];
      }
      require(all <= 100, "all big than 100");
      recommendpoint = _recommendpoint;
    }

    function WithdrawToken(address _token) public whenPaused onlyOwner{
        uint256 tokenvalue = IBEP20(_token).balanceOf(address(this));
        require(tokenvalue > 0, "no token");
        IBEP20(_token).transfer(msg.sender,tokenvalue);
    }

    function ReplaceUser(address who, uint256 power, uint256 powerUsed, uint256 profit, uint256 recommendProfit,uint256 powerProfit) public onlyOwner {
        _userpower[who] = UserPower({
          power: power,
          powerUsed: powerUsed,
          profit: profit,
          recommendProfit: recommendProfit,
          powerProfit: powerProfit
        });
        if (!_usertips[who].updated){
          _usertips[who].updated = true;
          users.push(who);
        }
        _usertips[who].index = MintProfitIndex;
        if(_userRp[who].profit > 0){
          if(power > 0 ){
            tatolpower = tatolpower.sub(_userRp[who].subpower);
          }else{
            otherProfit = otherProfit.add(_userRp[who].profit);
          }        
          delete  _userRp[who];
      }
    }    
/*********************************************public function for contract **************/
    function AddPowerOnly(address _user, uint256 _power) whenNotPaused public {
        require(msg.sender == composerAddr, "only call by composer-contract");
        updateUser(_user);
        _userpower[_user].power = _userpower[_user].power.add(_power);
        tatolpower = tatolpower.add(_power);
        UpdateUserData(_user);
    }

    function AddPowerAndProfit(address _composer, uint256 _power, uint256 _token, uint256 _busd, uint _price) whenNotPaused public {
        require(msg.sender == composerAddr, "only call by composer-contract");
        updateUser(_composer);
        _userpower[_composer].power = _userpower[_composer].power.add(_power);
        tatolpower = tatolpower.add(_power);
        UpdateUserData(_composer);
        uint256 retoken;
        if (_busd >= limitBusd){
          address[30] memory roots; uint256[30] memory recommends;
          uint256 _subrootpower;uint256 _rootprofit;
          (roots,recommends) = IReward(rewardAddr).GetRoots(_composer);
          for (uint i = 0; i < 30; i++){
            if (roots[i] == address(0)) break;
            if (recommends[i] > i){              
              _rootprofit = getProfit(_token,i);
              _subrootpower = _rootprofit.mul(_price).div(1e18);
              _userRp[roots[i]].profit = _userRp[roots[i]].profit.add(_rootprofit);
              _userRp[roots[i]].subpower = _userRp[roots[i]].subpower.add(_subrootpower);
              retoken = retoken.add(_rootprofit);
            }
          }
        }
        if(_token > retoken){
          otherProfit = otherProfit.add(_token.sub(retoken));
        }
        emit Profit(_token, _price);
    }
/*******************************************public function************************************ */
    function DoReward(uint256 _token, uint _price) whenNotPaused public {
      IBEP20(token).transferFrom(msg.sender, address(this), _token);
      if (tatolpower == 0){
        otherProfit = otherProfit.add(_token);
        return;
      }

      uint256 new_sub = _token.mul(_price).div(1e18);
      if(new_sub > tatolpower){
        _token = _token.mul(tatolpower).div(new_sub);
        new_sub = tatolpower;
      }
      require(new_sub <= 1e56, "subpower too big");
      uint256 new_pf = new_sub.mul(1e18).div(tatolpower);
      require(new_pf >= 1e9, "BaseFraction too small");
      uint256 new_ave = uint256(1e36).div(_price);
      uint new_re = MintProfitIndex;
      if(MintProfitIndex != 0 && _mintProfitFraction[MintProfitIndex].powerFraction != 1e18){
        new_pf = _mintProfitFraction[MintProfitIndex].powerFraction.mul(uint256(1e18).sub(new_pf)).div(1e18).add(new_pf);
        require(new_pf > _mintProfitFraction[MintProfitIndex].powerFraction, "Fraction too small");
        uint256 old_pa = _mintProfitFraction[MintProfitIndex].powerFraction.mul(1e18).div(new_pf);
        new_ave = (old_pa.mul(_mintProfitFraction[MintProfitIndex].average).add((uint256(1e18).sub(old_pa)).mul(new_ave))).div(1e18);
        new_re = _mintProfitFraction[MintProfitIndex].resetIndex;
      }
      if(new_pf > 1e18) new_pf = 1e18;

      MintProfitIndex +=1;

      _mintProfitFraction[MintProfitIndex] =MintProfitFraction({
          powerFraction: new_pf,
          average: new_ave,
          resetIndex: new_re
        });

      _mintProfit[MintProfitIndex] = MintProfit({
        nowtatolpower: tatolpower,
        subtatolpower: new_sub,
        profittoken: _token,
        profitprice: _price,
        blocknumber: block.number
        });

      tatolpower = tatolpower.sub(new_sub);
      emit Profit(_token, _price);
    }

    function WithdrawProfit(address who) whenNotPaused public {
        updateUser(who);
        uint256 _profits = _userpower[who].powerProfit.add(_userpower[who].recommendProfit);
        require(_profits > 0, "no Profit");
        _userpower[who].powerProfit = 0;
        _userpower[who].recommendProfit = 0;

        UpdateUserData(who);

        IBEP20(token).transfer( who,_profits);
    }

    function WithdrawOtherProfit() public{
        require(otherProfit > 0, "no Profit");
        uint256 _otherProfit = otherProfit;
        otherProfit = 0;
        IBEP20(token).transfer( other,_otherProfit);
    }

    function ToUpdate(address who) public {
      updateUser(who);
      UpdateUserData(who);
    }

    function ToUpdateOnly(address who) public {
      updateUser(who);
    }
}