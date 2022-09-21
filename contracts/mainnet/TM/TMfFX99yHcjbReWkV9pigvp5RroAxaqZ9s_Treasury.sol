//SourceUnit: Context.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


//SourceUnit: Ownable.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.7.6;

import "./Context.sol";

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


//SourceUnit: SafeMath.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;
// a library for performing overflow-safe math, updated with awesomeness from of DappHub (https://github.com/dapphub/ds-math)
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
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
        return mod(a, b, "SafeMath: modulo by zero");
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
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

}

library SafeMath128 {
    function add(uint128 a, uint128 b) internal pure returns (uint128 c) {require((c = a + b) >= b, "SafeMath: Add Overflow");}
    function sub(uint128 a, uint128 b) internal pure returns (uint128 c) {require((c = a - b) <= a, "SafeMath: Underflow");}
}


//SourceUnit: Treasury.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "./Ownable.sol";
import "./SafeMath.sol";

interface  TRC20Interface {
  function balanceOf(address who) external view  returns (uint256);
  
  function transfer(address to, uint256 value)  external returns (bool);
 
  function allowance(address owner, address spender) external view  returns (uint256);
  
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  
  function approve(address spender, uint256 value) external  returns (bool);
  
  event Approval(address indexed owner, address indexed spender, uint256 value); 
  
  event Transfer(address indexed from, address indexed to, uint256 value);
}


contract Treasury is Ownable {
   using SafeMath for uint256;  

     TRC20Interface private ITRC;
     address Token;
   struct userInfo{
        string     userName;  // user name 
        string     kId;   // bank kard id
        string     bankName;//         
   }

   mapping (address => userInfo) private UserMap;
  
   struct stakeInfo{
        uint256  usdtAmount;
        bool     islocked;  //
        address  lockedBybuyer;        
   }

   mapping (address => stakeInfo) private userStakeMap; 
 
   struct buyerStakeInfo{
       uint256 fee;
       uint256 amount;
       bool isLocked;
       uint256 lockUsers;
   }
   mapping (address => buyerStakeInfo) private buyerstakeMap; 
   mapping (address => uint256) private buyerAmont;    
   address[] private userAddr;
   address[] private buyerAddr;

   uint256 private sysAmount = 0;
   uint256 private toDayUsdt2CNY = 7* 1e18;      
   uint256 private miniStakeAmount = 20* 1e18; //2000U
   uint256 private amountOnce =  15* 1e18;// 1500一次交易
   uint256 private feePercent = 200; // div 10000
   uint256 private minibuyerStakeAmount = 5* 1e18;
   
   /* =================== Modifier =================== */ 
   // if elc expanded,get the els amounts to personal amout array
   modifier isUnLocked {
      require(userStakeMap[msg.sender].islocked == false);
      _;
   }
  
   /* ========== MUTABLE FUNCTIONS ========== */
   constructor( )  {   
       Token = 0xa614f803B6FD780986A42c78Ec9c7f77e6DeD13C;
   }
   
   // 设置系统代币地址
   function setTokenAddress(address usdtToken) external  onlyOwner()returns(bool){
       Token = usdtToken;
      return true;
   }

   function findUsr(address usrAddr) public view returns (bool){
    for(uint256 i = 0; i < userAddr.length; i++)
    {
      if(usrAddr == userAddr[i])
         return true;
    }
    return false;
  }

  function findBuyer(address Addr) public view returns (bool){
    for(uint256 i = 0; i < buyerAddr.length; i++)
    {
      if(Addr == buyerAddr[i])
        return true;
    }
    return false;
  }

   // 用户上压
   function addUserStakeAndInfo(uint256 _amount,string memory _name, string memory _kid, string memory bank) external  returns(bool ){
      require(_amount > 0,"_amount  > 0");
      require(_amount.add(userStakeMap[msg.sender].usdtAmount) >= miniStakeAmount,"large than miniStakeAmount");  
      
      TRC20Interface(Token).transferFrom(msg.sender, address(this), _amount);    
      
      userStakeMap[msg.sender].usdtAmount += _amount;       
      if(!findUsr(msg.sender)){
         userAddr.push(msg.sender) ;
      }
 
      UserMap[msg.sender].userName = _name;  // user name 
      UserMap[msg.sender].kId = _kid;       // bank kard id
      UserMap[msg.sender].bankName = bank;  //  
      
      emit AddUserUsdt(msg.sender, _amount,_name,_kid,bank,block.timestamp);
      return true;
   }

   // 用户修改/添加银行卡
   function addUserBankInfo(string memory _name, string memory _kid, string memory bank) external  returns(bool ){
      require(findUsr(msg.sender),"must have this addr in usr array");
      UserMap[msg.sender].userName = _name;  // user name 
      UserMap[msg.sender].kId = _kid;       // bank kard id
      UserMap[msg.sender].bankName = bank;  //  
      emit AddUserUsdt(msg.sender, 0,_name,_kid,bank,block.timestamp);
      return true;
   }

  // 用户添加上压
  function addUserStake(uint256 _amount) external  returns(bool ){
      require(_amount > 0,"must larger than 0");
      require(_amount.add(userStakeMap[msg.sender].usdtAmount) >= miniStakeAmount,"total amount must larger than min");      
    
     TRC20Interface(Token).transferFrom(msg.sender, address(this), _amount);  
      
     // TransferHelper.safeTransferFrom(  Token,msg.sender, address(this), _amount);   
      userStakeMap[msg.sender].usdtAmount += _amount;       
      if(!findUsr(msg.sender)){
         userAddr.push(msg.sender) ;
      }
      return true;
  }

   // 用户提现
   function withdrawUserUsdt() external isUnLocked  returns(bool ) {
      require(userStakeMap[msg.sender].usdtAmount > 0,"must have usdt"); 
      require(findUsr(msg.sender),"must be a usr");   

      UserMap[msg.sender].userName =  "";  // user name 
      UserMap[msg.sender].kId =  "";       // bank kard id
      UserMap[msg.sender].bankName =  "";  //  
      uint256 tempAmount =  userStakeMap[msg.sender].usdtAmount;
      userStakeMap[msg.sender].usdtAmount = 0;
      userStakeMap[msg.sender].islocked =false;  //
      userStakeMap[msg.sender].lockedBybuyer= address(0xfffffffffffffffffffffffffffffffffff);     
  
      TRC20Interface(Token).transfer(msg.sender,tempAmount); 
      
     // TransferHelper.safeTransfer(   Token,msg.sender, tempAmount); 

     for(uint256 i = 0; i < userAddr.length; i++)
     {
      if(msg.sender == userAddr[i])
       { 
         userAddr[i] = userAddr[userAddr.length-1];
         userAddr.pop(); 
         break;
       }
     }
     emit   WithdrawUsdt(msg.sender,userStakeMap[msg.sender].usdtAmount,block.timestamp);  
     return true;  
   }

   // 商家上压
   function addBuyerStake(uint256 _amount) external returns(bool ){
      require(_amount.add(buyerstakeMap[msg.sender].amount) >= minibuyerStakeAmount,"must larger than min");
      TRC20Interface(Token).transferFrom(msg.sender, address(this), _amount);  
     // TransferHelper.safeTransferFrom(Token,msg.sender, address(this), _amount);   
      buyerstakeMap[msg.sender].amount += _amount;
      buyerstakeMap[msg.sender].fee = 0; // 默认公共费率,可根据不同商户定制费率
      if(!findBuyer(msg.sender))
      {
         buyerAddr.push(msg.sender) ;
      }   
      return true;
   }
 
   // 商家提现
   function  withdrawBuyerUsdt(bool isbuy,bool isStake) external returns(bool ){   
      // 手续费给平台，其它提现
      require(isbuy || isStake);
      require( buyerstakeMap[msg.sender].isLocked==false);

      uint256 tempAmount = 0;     
      if(isbuy){        
           tempAmount = tempAmount.add(buyerAmont[msg.sender]);
           buyerAmont[msg.sender] = 0;
      }
      if(isStake){
           tempAmount += buyerstakeMap[msg.sender].amount;
           buyerstakeMap[msg.sender].amount = 0;
      }   
      TRC20Interface(Token).transfer(msg.sender, tempAmount);
     
      if(isbuy && isStake){
            for(uint256 i = 0; i < buyerAddr.length; i++)
            {
               if(msg.sender == buyerAddr[i])
               { 
                   buyerAddr[i] = buyerAddr[buyerAddr.length-1];
                   buyerAddr.pop(); 
                   break;
              }
           }       
      }
      emit  WithdrawBuyerUsdt(isbuy,isStake,block.timestamp);
      return true;
   }   

   //运营商提现手续费
   function ownerWithdraw() external onlyOwner() returns(bool){ 
      require(sysAmount > 0);     
       TRC20Interface(Token).transfer(msg.sender, sysAmount);
      //TransferHelper.safeTransfer(  Token, msg.sender, sysAmount); 
      sysAmount = 0;
      return true;
   } 
   
   // 商户发起购买邀约，锁定用户的账号和Usdt 最多20个一组,每一个都要上压minibuyerStakeAmount，押金不够，不能发起邀请这么多个普通用户
   function buyUsdtReq(address[] memory _userArray) external returns(uint256){                  
      require(_userArray.length < 21);
      require( buyerstakeMap[msg.sender].isLocked == false);
      require( buyerstakeMap[msg.sender].amount >= minibuyerStakeAmount.mul(_userArray.length ),"stake amount must larger than legth *minibuyerStakeAmount");
      require(miniStakeAmount > amountOnce);
      uint256 userArryLength = _userArray.length;  
      uint256 tempi = 0;
      for(uint256 i = 0; i < userArryLength; i++)
      {
           if(userStakeMap[_userArray[i]].islocked==false  && userStakeMap[_userArray[i]].usdtAmount >= miniStakeAmount)
           {     
              userStakeMap[_userArray[i]].islocked = true;  //             
              userStakeMap[_userArray[i]].lockedBybuyer = msg.sender;               
              tempi++ ;            
           }
      }

      if(tempi > 0){
            buyerstakeMap[msg.sender].lockUsers += tempi;  
            buyerstakeMap[msg.sender].isLocked = true;  
      }
      emit BuyUsdtReq(msg.sender,block.timestamp);
      return tempi;
   }

   // 用户收到银行转帐后确认同意交易
   function userApproved() external returns(bool){
      require(userStakeMap[msg.sender].islocked == true );   
      require(amountOnce < userStakeMap[msg.sender].usdtAmount,"total stake > onceAmount");
      address  lockedbuyer =  userStakeMap[msg.sender].lockedBybuyer;     
      
      uint256 _fee = feePercent;
      if(buyerstakeMap[msg.sender].fee >feePercent ){
            _fee = buyerstakeMap[msg.sender].fee;
      } 
      uint256 _amount = amountOnce.mul(_fee).div(10000);
      sysAmount += _amount;
      buyerAmont[lockedbuyer] += amountOnce.sub(_amount);

      userStakeMap[msg.sender].usdtAmount -=  amountOnce;
      userStakeMap[msg.sender].islocked = false;
      userStakeMap[msg.sender].lockedBybuyer = address(0xfffffffffffffffffffffffffffffffffff);   

      buyerstakeMap[lockedbuyer].lockUsers-=1;
      if(buyerstakeMap[lockedbuyer].lockUsers == 0)
      {
           buyerstakeMap[lockedbuyer].isLocked = false;
      }      
      emit Approved(msg.sender,userStakeMap[msg.sender].lockedBybuyer,block.timestamp);
      return true;
   }

   //如果用户收到银行转帐后，不执行approved, 24小时后，由买家发起申诉，通过查询银行记录确认后强制用户执行approved，并将用户质押余额罚没。
   function forcedApproved(address  buyer,address  user ) external onlyOwner() returns(bool){
      require(userStakeMap[user].islocked == true &&  userStakeMap[user].lockedBybuyer == buyer,"locked = true,buyer");
       
      uint256 _fee = feePercent;
      if(buyerstakeMap[buyer].fee >feePercent ){
         _fee = buyerstakeMap[buyer].fee;
      } 
      uint256 _amount = amountOnce.mul(_fee).div(10000);
      buyerAmont[buyer] += amountOnce.sub(_amount);
      sysAmount = sysAmount.add(userStakeMap[user].usdtAmount).sub(amountOnce).add(_amount);
      
      userStakeMap[user].usdtAmount = 0;
      userStakeMap[user].islocked = false;   
      userStakeMap[user].lockedBybuyer = address(0xfffffffffffffffffffffffffffffffffff);        
       
      buyerstakeMap[buyer].lockUsers-=1;       
      if(buyerstakeMap[buyer].lockUsers == 0)
      {
         buyerstakeMap[buyer].isLocked = false;
      }         
      emit  ForcedApproved(msg.sender,user,buyer,block.timestamp);
      return true;
   }

   // 如果商家锁定用户的账号后，不执行银行转帐，24小时后，用户发起申诉，确认后强制解锁，并将商家质押罚没。
   function forcedUnlock(address  buyer,address user ) external onlyOwner() returns(bool) {
      require(userStakeMap[user].islocked == true &&  userStakeMap[user].lockedBybuyer == buyer);
      sysAmount =sysAmount +  buyerstakeMap[buyer].amount;
      buyerstakeMap[buyer].amount = 0;
      userStakeMap[user].islocked = false;
      userStakeMap[user].lockedBybuyer = address(0xfffffffffffffffffffffffffffffffffff);           
      buyerstakeMap[buyer].lockUsers-=1;       
      if(buyerstakeMap[buyer].lockUsers == 0)
      {
         buyerstakeMap[buyer].isLocked = false;
      }       
     
      emit ForcedUnlock(msg.sender,buyer,user,block.timestamp);  
      return true;
   }

   // 根据主流交易所币价刷新当天usdt价格，由运营账号每天24点自动刷新。本平台价格保持在主流交易所价格基础上浮3个点。
   function updateTodayPrice( uint256 _price) external onlyOwner() {
      toDayUsdt2CNY = _price;
     emit SetTodayPrice( _price,block.timestamp);
   }

   /* ========== setting FUNCTIONS ========== */ 
   // 设置商家单独费率
   function setBuyerFee(address addr,uint256 fee) external onlyOwner() {
       buyerstakeMap[addr].fee = fee;
   }
   
   // 当天费率
   function updateTodayFee( uint256 _fee) external onlyOwner() {
      feePercent = _fee;
      emit SetTodayFee( _fee,block.timestamp);
   }

   // 最小用户质押量
   function updateMiniStakeAmount( uint256 _amount) external onlyOwner() {
      miniStakeAmount = _amount;
     emit SetTodayMiniStakeAmount( _amount,block.timestamp);
   }

   // 单次交易额度
    function updateAmountOnce(uint256 _amount) external onlyOwner() {
      amountOnce = _amount;
      emit  SetAmountOnce( _amount,block.timestamp);
   }

   // 商户质押的最小量
   function updateBuyerStakeAmount(uint256 _amount) external onlyOwner() {
      minibuyerStakeAmount = _amount;
      emit  SetMinibuyerStakeAmount( _amount,block.timestamp);
   }   
   
   /* ========== VIEW FUNCTIONS ========== */ 
   function getTodayPrice() external view returns (uint256){
      return toDayUsdt2CNY;
   }
    // 得到系统
   function getTokenAddress() external  view onlyOwner()returns(address ){
      return   Token ;    
   }

   // 得到指定商家单独费率
   function getBuyerFee(address addr) external view onlyOwner() returns(uint256 ) {
     require(findBuyer(msg.sender) == true || msg.sender == owner());
     return buyerstakeMap[addr].fee;
   }

   //得到当天默认费率
   function getTodayFee() external view returns (uint256){
      require(findBuyer(msg.sender) == true || msg.sender == owner());
      return feePercent;
   }

   // 最小用户质押量
    function getMiniStakeAmount() external view returns (uint256) {
      return miniStakeAmount;
   }

   // 一次交易额度
    function getAmountOnce() external  view returns (uint256) {
      return amountOnce;      
   }

  // 商户质押的最小量
   function getBuyerStakeMiniAmount() external  view returns (uint256) {
      return minibuyerStakeAmount;
   }   

   //得到商户自己的质押信息，质押的量amount，是否锁定islocked，多少个锁定-count
   function getBuyerInfoByAddr(address addr) external view  onlyOwner() returns (uint256 trade,uint256 stake,bool islocked,uint256  count ){        
      require(findBuyer(msg.sender) == true );
      trade = buyerAmont[addr];
      stake = buyerstakeMap[addr].amount;
      islocked = buyerstakeMap[addr].isLocked;
      count =  buyerstakeMap[addr].lockUsers;     
   }

 //得到商户自己的质押信息，质押的量amount，是否锁定islocked，多少个锁定-count
   function getBuyerSelfInfo() external view   returns (uint256 trade,uint256 stake,bool islocked,uint256  count ){  
        
       trade = buyerAmont[msg.sender];
       stake = buyerstakeMap[msg.sender].amount;
       islocked = buyerstakeMap[msg.sender].isLocked;
       count =  buyerstakeMap[msg.sender].lockUsers;     
   }

  //得到用户adr的银行信息和质押，锁定信息,只能由商户和管理员查询，普通用户之间不能相互查询
  function getUserinfoByadr(address  adr) 
   external view returns (string memory user,string memory kId,string memory  bankName,
    uint256 amount,bool islocked,address who ){
      require(findBuyer(msg.sender) == true || msg.sender == owner());     
       user =  UserMap[adr].userName;
       kId = UserMap[adr].kId;
       bankName = UserMap[adr].bankName;

       amount = userStakeMap[adr].usdtAmount;
       islocked = userStakeMap[adr].islocked;
       who =  userStakeMap[adr].lockedBybuyer;  
   }

  //得到用户adr的自己银行信息和质押，锁定信息
  function getUserinfoBySelf() 
   external view returns (string memory user,string memory kId,string memory  bankName,
   uint256 amount,bool islocked,address who ){
           
      user =  UserMap[msg.sender].userName;
      kId = UserMap[msg.sender].kId;
      bankName = UserMap[msg.sender].bankName;

      amount = userStakeMap[msg.sender].usdtAmount;
      islocked = userStakeMap[msg.sender].islocked;
      who =  userStakeMap[msg.sender].lockedBybuyer;  
   }

   //得到系统费用信息
   function getSysAmount() external view  onlyOwner() returns (uint256 amount){
      return sysAmount;    
   }

   //得到用户的地址，只能由商户和管理员执行
   function getUserArray() external view   returns (address[] memory){
      require(findBuyer(msg.sender) == true || msg.sender == owner());
      return userAddr;    
   }

   //得到商户的地址，只能由管理员执行
   function getBuyerArray() external view  onlyOwner() returns (address[] memory){
      return buyerAddr;    
   }

  /* =================== Event =================== */
    event AddUserUsdt(address indexed user, uint256 amount,string  _name,string  _kid,string  bank,uint256 timestamp);    
    event SetTodayPrice(uint256 _price,uint256 blocktime);
    event  SetTodayFee(uint256 _fee,uint256 timestamp);
    event SetTodayMiniStakeAmount(uint256 _amount,uint256 timestamp);
    event  SetAmountOnce(uint256 _amount,uint256 timestamp);
    event  SetMinibuyerStakeAmount(uint256 _amount,uint256 timestamp);
    event  WithdrawUsdt(address buyer,uint256 _amount,uint256 time); 
    event  Approved(address sender,address buyer,uint256 timestamp);
    event  ForcedApproved(address sender,address user,address buyer,uint256 timestamp);
    event  ForcedUnlock(address sender,address buyer,address user,uint256 timestamp);
    event BuyUsdtReq(address sender,uint256 timestamp) ;
    event  WithdrawBuyerUsdt(bool isbuy,bool isStake,uint256  timestamp);
}