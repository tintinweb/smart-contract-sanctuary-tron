//SourceUnit: ITRC20.sol

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.0;

/**
 * @dev Interface of the TRC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {TRC20Detailed}.
 */
interface ITRC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function burnFrom(address sender, uint256 amount) external   returns (bool);
    function burn(uint256 amount) external  returns (bool);
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


//SourceUnit: Ownable.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


//SourceUnit: ReleaseAirDrop.sol

// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.5.0;
import "./ITRC20.sol";
import "./TransferHelper.sol";
import "./SafeMath.sol";
import "./Ownable.sol";
 
interface AirDrop
{
    function getTotalAirDropCount(address user) external view returns(uint256);
    function getParent(address user) external view returns (address);
}

interface IRouter
{
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);

    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

interface Union
{
    function _userIndex(address user) external view returns(uint256);
}

interface OldAir
{
    function _totalUnion() external view returns(uint256);
    function _oneLpShareB() external view returns(uint256);
    function _onecut() external view returns(uint256);
    function _lastuptime() external view returns(uint256);
    function _totalhash() external view returns(uint256);
    function _unLockedAir(address user) external view returns(uint256);
    function _pendingAir(address user) external view returns(uint256);
    function _withDrawedAir(address user) external view returns(uint256);
    function _startReleaseTime(address user) external view returns(uint256);
    function _isactive(address user) external view returns(bool);
    function _inviteCount(address user) external view returns(uint256);
    function _withdrawedUnion(address user) external view returns(uint256);
    function _withdrawedB(address user) external view returns(uint256);
    function _userStackCount(address user) external view returns(uint256);
    function _userPower(address user) external view returns(uint256);
    function _pendingUser(address user) external view returns(uint256);
    function _taked(address user) external view returns(uint256);
    function _withdrawedUnionMdao(address user) external view returns(uint256);
    function _dynamicPower(address user) external view returns(uint256);
}

contract ReleaseMdao is Ownable
{
    AirDrop _air;
    Union _union;
    OldAir _oldair;
    address _mdao=0x2fE932ab8D15FD345601aEBc54f47b43F3AB6F2d;
    address public _feeowner=0x8C6285BC93b5c9C913db523824326b9B54ac2660;
    address _stock=0x9586daa996761EeC964097046b39C13AD5992d9a;
    address _router=0xF2a1A42A33fC34a9BaF428Fe63F9dE77290e0353;
    address _mdaoTrade=0x48553C086a48a88dCBa352D6578768e4019caAc7;
    address _trustaddress=0xd77Aef4B7752304d31Ee6Be4C068bD9Ba6d46c01;
    address _usdtaddress=0xa614f803B6FD780986A42c78Ec9c7f77e6DeD13C;
    address _trusttrade=0xEcbfd5c9d71951f9B5081db5995e4985f6486D31;
    mapping(address=>uint256) public _unLockedAirA;
    mapping(address=>uint256) public _pendingAirA;
    mapping(address=>uint256) public _startReleaseTimeA;
    mapping(address=>uint256) public _withDrawedAirA;
    mapping(address=>bool) public _isactiveA;
    mapping(address=>uint256) public _inviteCountA;
    mapping(address=>address) _parents;
    mapping(address=>uint256) public _withdrawedUnionA;
    mapping(address=>uint256) public _withdrawedUnionTrust;
    mapping(address=>uint256) public _withdrawedBA;
    mapping(address=>uint256) public _userStackCountA;
    mapping(address=>uint256) public _userPowerA;
    mapping(address=>uint256) public _pendingUserA;
    mapping(address=>uint256) public _takedA;
    mapping(address=>uint256) public _withdrawedUnionMdaoA;
    mapping(address=>uint256) public _dynamicPowerA;
    mapping(address=>bool) _mapped;

    uint256 public _totalUnion;
    uint256 public _totalUnionTrust;
    uint256 public _oneLpShareB;
    uint256 public _onecut;
    uint256 public _lastuptime;
    uint256 public _totalhash;
    uint256 public _onesecondReward;
    

    using SafeMath for uint256;
    using TransferHelper for address;

    function MappinDataFromOld() public onlyOwner 
    {
        _totalUnion=_oldair._totalUnion();
        _oneLpShareB= _oldair._oneLpShareB();
        _onecut=_oldair._onecut();
        _lastuptime= _oldair._lastuptime();
        _totalhash= _oldair._totalhash();
    }

    function MappingUserFromOld(address user) public
    {
        if(_mapped[user])
            return;

        _unLockedAirA[user]= _oldair._unLockedAir(user);
        _pendingAirA[user]=_oldair._pendingAir(user);
        _startReleaseTimeA[user]=_oldair._startReleaseTime(user);
        _withDrawedAirA[user]=_oldair._withDrawedAir(user);
        _isactiveA[user]= _oldair._isactive(user);
        _inviteCountA[user]= _oldair._inviteCount(user);
        _withdrawedUnionA[user]= _oldair._withdrawedUnion(user);
        _withdrawedBA[user]=_oldair._withdrawedB(user);
        _userStackCountA[user]= _oldair._userStackCount(user);
        _userPowerA[user]= _oldair._userPower(user);
        _takedA[user] = _oldair._taked(user);
        _withdrawedUnionMdaoA[user]= _oldair._withdrawedUnionMdao(user);
        _dynamicPowerA[user]= _oldair._dynamicPower(user);
        _mapped[user]=true;
    }

    constructor(address air,address union,address oldAir)
    {
        _air=AirDrop(air);
        _union=Union(union);
        _oldair = OldAir(oldAir);
        _onesecondReward= 10000000;
        _onesecondReward =  _onesecondReward.mul(1e18).div(86400);
 
        ITRC20(_mdao).approve(_router, 1e40);
        ITRC20(_trustaddress).approve(_router, 1e40);
    }
 
    function setOnesecondReward(uint256 reward,address feeowner) public onlyOwner
    {
        _onesecondReward=reward;
        _feeowner=feeowner;
    }

     function _unLockedAir(address user) public view returns(uint256)
     {
        if(_mapped[user])
            return _unLockedAirA[user];
        else
            return _oldair._unLockedAir(user);
     }
    function _pendingAir(address user) public view returns(uint256)
    {
        if(_mapped[user])
            return _pendingAirA[user];
        else
            return _oldair._pendingAir(user);
    }

    function _withDrawedAir(address user) public view returns(uint256)
    {
        if(_mapped[user])
            return _withDrawedAirA[user];
        else
            return _oldair._withDrawedAir(user);
    }
    function _startReleaseTime(address user) public view returns(uint256)
    {
        if(_mapped[user])
            return _startReleaseTimeA[user];
        else
            return _oldair._startReleaseTime(user);
    }


    function _isactive(address user) public view returns(bool)
    {
        if(_mapped[user])
            return _isactiveA[user];
        else
            return _oldair._isactive(user);
    }
    function _inviteCount(address user) public view returns(uint256)
    {
        if(_mapped[user])
            return _inviteCountA[user];
        else
            return _oldair._inviteCount(user);
    }
    function _withdrawedUnion(address user) public view returns(uint256)
    {
        if(_mapped[user])
            return _withdrawedUnionA[user];
        else
            return _oldair._withdrawedUnion(user);
    }
    function _withdrawedB(address user) public view returns(uint256)
    {
        if(_mapped[user])
            return _withdrawedBA[user];
        else
            return _oldair._withdrawedB(user);
    }
    function _userStackCount(address user) public view returns(uint256)
    {
        if(_mapped[user])
            return _userStackCountA[user];
        else
            return _oldair._userStackCount(user);
    }
    function _userPower(address user) public view returns(uint256)
    {
         if(_mapped[user])
            return _userPowerA[user];
        else
            return _oldair._userPower(user);
    }
    function _pendingUser(address user) public view returns(uint256)
    {
        if(_mapped[user])
            return _pendingUserA[user];
        else
            return _oldair._pendingUser(user);
    }
    function _taked(address user) public view returns(uint256)
    {
         if(_mapped[user])
            return _takedA[user];
        else
            return _oldair._taked(user);
    }
    function _withdrawedUnionMdao(address user) public view returns(uint256)
    {
        if(_mapped[user])
            return _withdrawedUnionMdaoA[user];
        else
            return _oldair._withdrawedUnionMdao(user);
    }
    function _dynamicPower(address user) public view returns(uint256)
    {
        if(_mapped[user])
            return _dynamicPowerA[user];
        else
            return _oldair._dynamicPower(user);
    }
 
    function getParent(address user) public returns(address)
    {
        if(_parents[user] != address(0))
            return _parents[user];
        else
        {
            address parent= _air.getParent(user);
            _parents[user]= parent;
            return parent;
        }
    }

    function setActive(address user,bool ok) private 
    {
        if(_isactive(user)==ok)
            return;
        address parent= getParent(user);
        MappingUserFromOld(user);
        if(ok)
            _inviteCountA[parent]++;
        else
            _inviteCountA[parent]--;
        _isactiveA[user]=ok;
    }

    function UnLockMyAir(uint256 amount) public
    {
        address user=msg.sender;
        MappingUserFromOld(user);
        uint256 totalAir= _air.getTotalAirDropCount(user);
        uint256 torelease = totalAir.subwithlesszero(_unLockedAir(user));
        require(amount <= torelease,"nomore");
        uint256 onepct= amount.div(2000);
        ITRC20(_mdao).transferFrom(user, address(this), amount.div(2));
        ITRC20(_mdao).burn(onepct.mul(800));
        for(uint i=0;i<10;i++)
        {
            address parent = getParent(user);
            if(parent== address(0))
                break;
            if(_isactive(parent) && _inviteCount(parent)>=i)
                ITRC20(_mdao).transfer(parent, onepct.mul(4));
        }

        ITRC20(_mdao).transfer(_stock, onepct.mul(40));
        _oneLpShareB += onepct.mul(1e8).div(_totalhash);
        _totalUnion = _totalUnion.add(onepct.mul(20));
        _unLockedAirA[user]= _unLockedAirA[user].add(amount);
        _pendingAirA[user] = getPendingAir(user);
        _startReleaseTimeA[user]= block.timestamp -  ((block.timestamp - 1656259200) %86400);
    }

    function takeOutErrorTransfer(address tokenaddress,address target,uint256 amount) public onlyOwner
    {
        ITRC20(tokenaddress).transfer(target,amount);
    }

    function getPendingAir(address user) public view returns (uint256)
    {
        uint256 starttime= _startReleaseTime(user);
        if(starttime==0 || starttime > block.timestamp * 5)
        {
            starttime=1656259200;
        }
 
        if(block.timestamp < starttime)
            return _pendingAir(user);
        uint256 dayss = (block.timestamp - starttime) / 86400;
        uint256 torelease = dayss.mul(_unLockedAir(user)).div(100);
        torelease += _pendingAir(user);
        torelease = torelease.subwithlesszero(_withDrawedAir(user));
        uint256 maxrelease=_unLockedAir(user);
        if(torelease < maxrelease)
            return torelease;
        else
            return maxrelease;
    }

    function SendCredit(address token,address target,uint256 amount) private
    {
        uint256 fee = amount.div(100);
        ITRC20(token).transfer(target, amount.sub(fee));
        ITRC20(token).transfer(_feeowner, fee);
    }

    function getPendingUnionMdao(address user) public view returns(uint256)
    {
         if(_union._userIndex(user)>0)
         {
            if(block.timestamp < 1656172800)
                return 0;
            uint256 dayss = (block.timestamp - 1656172800) / 86400;
            if(dayss >720)
                dayss =720;
            return 15000000 * 1e18   * dayss / 720 - _withdrawedUnionMdao(user);
         }
         else
         {
            return 0;
         }

    }

    function WithUnionMdao() public
    {
        address user=msg.sender;
        MappingUserFromOld(user);
        uint256 send= getPendingUnionMdao(user);
        _withdrawedUnionMdaoA[user] += send;
        SendCredit(_mdao,user,send);
    } 

    function WithDrawAir() public
    {
        address user=msg.sender;
        MappingUserFromOld(user);
        uint256 send= getPendingAir(user);
        _withDrawedAirA[user] += send;
        SendCredit(_mdao,user,send);
    } 

    function getPendingUnion(address user) public view returns(uint256)
    {
        if(_union._userIndex(user)>0)
            return _totalUnion.div(100).sub(_withdrawedUnion(user));
        else
            return 0;
    }

    function getPendingUnionTrust(address user) public view returns(uint256)
    {
        if(_union._userIndex(user)>0)
            return _totalUnionTrust.div(100).sub(_withdrawedUnionTrust[user]);
        else
            return 0;
    }

    function WithDrawUnion() public
    {
        MappingUserFromOld(msg.sender);
        uint256 sending=getPendingUnion(msg.sender);
        _withdrawedUnionA[msg.sender] += sending;
        SendCredit(_mdao,msg.sender, sending);
 
        uint256 sending2=getPendingUnionTrust(msg.sender);
        _withdrawedUnionTrust[msg.sender] += sending2;
         SendCredit(_trustaddress,msg.sender, sending2);
 
    }

    function getMdaoLpPower(uint256 amount) public view returns(uint256)
    {
        uint256 totalsupply = ITRC20(_mdaoTrade).totalSupply();
        uint256 abo = ITRC20(_usdtaddress).balanceOf(_trusttrade) ;
        uint256 _mdaotrust = ITRC20(_trustaddress).balanceOf(_mdaoTrade);
        uint256 totalusdt=  _mdaotrust.mul(abo).div(ITRC20(_trustaddress).balanceOf(_trusttrade));
        uint256 power=amount.mul(1e18).mul(totalusdt).div(totalsupply).div(5e17);
        return power.mul(105).div(100);
    }

    function getOneShareNowA() public view returns(uint256)
    {
        uint256 oneshare=_onecut;
         if(_lastuptime>0)
         {
            if(block.timestamp >= _lastuptime)
            {
                uint256 behash = _totalhash>200 * 1e10?_totalhash:200 * 1e10;
                oneshare= oneshare.add(_onesecondReward.mul(block.timestamp.sub(_lastuptime)).div(behash));
            }
         }
         return oneshare;
    }

    function StackLp(uint256 amount) public
    {
        address user= msg.sender;
        MappingUserFromOld(user);
        uint256 oneshare=getOneShareNowA();
        _mdaoTrade.safeTransferFrom(msg.sender, address(this), amount);
        _userStackCountA[user] = _userStackCountA[user].add(amount);
        uint256 ahash= getMdaoLpPower(amount);
        _userHashChanged(user,ahash,true,oneshare);
        uint256 totaldiff = ahash;
        address parent=user;
        uint256 dhash = ahash.div(10);
        for(uint i=0;i<10;i++)
        {
             parent = getParent(parent); 
            if( parent==address(0))
                break;

             if(_isactive(user) && _inviteCount(user) >=i)
            {   
                _teamHashChanged(parent, dhash, true,oneshare);
                totaldiff=totaldiff.add(dhash);
            }
        }

        LogCheckPoint(totaldiff, true,oneshare);
    }

     function _teamHashChanged(address user,uint256 ahash,bool add,uint256 oneshare) private
    {
        MappingUserFromOld(user);
        if(_userPower(user) > 0)
            _pendingUserA[user] = _GetLpPendingA(user,oneshare);
 
            if(add)
            {
                _dynamicPowerA[user] = _dynamicPowerA[user].add(ahash);
            }else
            {
                _dynamicPowerA[user] = _dynamicPowerA[user].subwithlesszero(ahash);
            }

        _takedA[user] = oneshare;
        _withdrawedBA[user]= _oneLpShareB;
    }

    function _userHashChanged(address user,uint256 ahash,bool add,uint256 oneshare) private
    {
 
        if(_userPowerA[user].add(_dynamicPowerA[user]) > 0)
            _pendingUserA[user] = _GetLpPendingA(user,oneshare);
         
        if(add)
            {
                _userPowerA[user] = _userPowerA[user].add(ahash);
                if(_userPowerA[user] >= 200 * 1e6)
                    setActive(user, true);
            }
            else
            {
                _userPowerA[user] = _userPowerA[user].subwithlesszero(ahash);
                if(_userPowerA[user] < 200 * 1e6)
                    setActive(user, false);
            }
        _takedA[user] = oneshare;
        _withdrawedBA[user]= _oneLpShareB;
    }

    function LogCheckPoint(uint256 phash,bool add,uint256 oneshare) private
    {
        if(block.timestamp > _lastuptime)
        {
            _onecut=oneshare;
            _lastuptime=block.timestamp;
        }
        
        if (add) {
            _totalhash = _totalhash.add(phash);
        } else {
            _totalhash = _totalhash.subwithlesszero(phash);
        }
    }
  
    function getTeamPower(address user) public view returns(uint256)
    {
        if(_isactive(user))
        {
            return _dynamicPower(user);
        }
        else
            return 0;
    }

    function _GetLpPendingA(address user,uint256 oneshare) public view returns(uint256)
    {
        uint256 selfhash= _userPower(user);
        if(selfhash==0)
            return _pendingUser(user);

        selfhash += getTeamPower(user);
        if(selfhash > 0)
        {
            uint256 cashed=_taked(user);
            uint256 newp =0;
            if(oneshare > cashed)
               newp = selfhash.mul(oneshare.subwithlesszero(cashed));

            return _pendingUser(user).add(newp);
        }
        else
        {
            return _pendingUser(user);
        }
    }

    function GetLpPendingA(address user) public view returns(uint256)
    {
        return _GetLpPendingA(user, getOneShareNowA());
    }

    function GetLpPendingB(address user)  public view returns(uint256)
    {
        uint256 lefts = _oneLpShareB.sub(_withdrawedB(user));
        return (_userPower(user) + getTeamPower(user)).mul(lefts).div(1e6);
    }

    function TakeBackLp(uint256 pct) public
    {
        address user= msg.sender;
        MappingUserFromOld(user);
        uint256 tackbackcount = _userStackCountA[user].mul(pct).div(10000);
        uint256 dechash = _userPowerA[user].mul(pct).div(10000);
        uint256 oneshare=getOneShareNowA();
        _userStackCountA[user]=_userStackCountA[user].sub(tackbackcount);
        _userHashChanged(user, dechash, false,oneshare);
        uint256 totaldiff = dechash;
        address parent=user;
         uint256 givehash = dechash.div(10);
        for(uint i=0;i<10;i++)
        {
            parent = getParent(parent); 
            if(parent==address(0))
                break; 
            uint256 parentpower = _dynamicPowerA[parent];
            if(parentpower < givehash)
                givehash=parentpower;
            _teamHashChanged(parent, givehash, false,oneshare);
            totaldiff=totaldiff.add(givehash);
        }

        uint256 fee= tackbackcount.div(100);
        _mdaoTrade.safeTransfer(user, tackbackcount.sub(fee));
        _mdaoTrade.safeTransfer(_feeowner, fee);
        LogCheckPoint(totaldiff, false,oneshare);
    }

    function WithDrawLpCreadit() public
    {
        
         address user=msg.sender;
         MappingUserFromOld(user);
        uint256 oneshare=getOneShareNowA();
        uint256 pending = _GetLpPendingA(user,oneshare) + GetLpPendingB(user);
 
        if(pending > 0)
        {
            _withdrawedBA[user]= _oneLpShareB;
            _takedA[user]= oneshare;
            _pendingUserA[user]=0;
            SendCredit(_mdao,user, pending);
        }
    }

    function OnSell(address user,uint256 count) private
    {
        address[] memory path = new address[](2);
        path[0]= _mdao;
        path[1]= _trustaddress;
        ITRC20(_mdao).burn(count.div(10));
        uint256 sellcount = count.mul(75).div(100);
        uint256 before = ITRC20(_trustaddress).balanceOf(address(this));
        uint256[] memory amounts= IRouter(_router).swapExactTokensForTokens(sellcount, 0, path, address(this), 1e20);
        IRouter(_router).addLiquidity(_mdao, _trustaddress, count.mul(15).div(100), amounts[1], count.mul(15).div(100), 0, address(this), 1e20);
        uint256 aftere = ITRC20(_trustaddress).balanceOf(address(this));
        address parent=user;
        uint256 onepiece = aftere.subwithlesszero(before).div(12);
        for(uint i=0;i<10;i++)
        {
            parent = getParent(parent); 
            if(parent==address(0))
                break; 
             if(_isactive(parent) && _inviteCount(parent) >=i)
               _trustaddress.safeTransfer(parent, onepiece);
        }

        _totalUnionTrust=_totalUnionTrust.add(onepiece.mul(2));
    }
    function OnBuy(address user,uint256 count) external
    {
        require(msg.sender==_mdao);
        if(user !=  _mdaoTrade)
        {
            OnSell(tx.origin,count);
        }
        else
        {
            ITRC20(_mdao).burn(count.div(5)); //20% destory
            ITRC20(_mdao).transfer(_feeowner, count.div(5)); 
            _totalUnion= _totalUnion.add(count.div(10));
            address parent=tx.origin;
            for(uint i=0;i<10;i++)
            {
                parent = getParent(parent); 
                if(parent==address(0))
                    break; 
                if(_isactive(parent) && _inviteCount(parent) >=i)
                    _mdao.safeTransfer(parent, count.div(20));
            }
        }
    }
 
}

//SourceUnit: SafeMath.sol

// SPDX-License-Identifier: MIT

pragma solidity >=0.4.0;

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
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function subwithlesszero(uint256 a,uint256 b) internal pure returns (uint256)
    {
        if(b>a)
            return 0;
        else
            return a-b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
     *
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
        require(c / a == b, 'SafeMath: multiplication overflow');

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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}


//SourceUnit: TransferHelper.sol

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.5.0;

// helper methods for interacting with BEP20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferBNB(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper: BNB_TRANSFER_FAILED');
    }
}