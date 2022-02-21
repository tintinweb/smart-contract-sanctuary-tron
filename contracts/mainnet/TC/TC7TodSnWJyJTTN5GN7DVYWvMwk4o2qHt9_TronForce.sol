//SourceUnit: tronforce.sol

pragma solidity 0.4.25;


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
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}




contract TronForce {
     using SafeMath for uint256;
     
    struct User {
        bool isExist;
        address upline;
        uint256 id;
        mapping(uint256 => uint256) referrals;
        uint256 refEarning;
        uint256 earning;
    }
    
    struct LotteryInfo
    {
        uint256 id;
        uint256 totalBids;
        uint256 collectedFunds;
        uint256 lastBidId;
        uint256 winnerid;
    }
    
   
    address  public owner;
    address public RandDwallet;//2%
   
    uint public TRX_FOR_ONE_USD=1;
    uint256 constant public PERCENTS_DIVIDER = 1000;
   
    mapping(address => User) public users;
    mapping(uint256 => LotteryInfo) public looteryList;
    mapping(uint256 => mapping(uint256 => address)) public bidDetails;
    uint256 public currentLotteryId = 1;
    

    uint256 public total_users = 1;
    
    uint256 public total_invested = 0;
    
    uint public curruserid=1;
    
    event Upline(address indexed addr, address indexed upline);
   
    event Register(address indexed addr,address indexed upline,uint256 time); 
    
    event JoinToLottery(address indexed addr,uint256 amount,uint256 time); 
    
    event winnerList(address indexed addr,uint256 amount,uint256 time); 
    

    constructor(address _owner,address _RandDwallet) public {
        owner = _owner;
        RandDwallet=_RandDwallet;
        users[owner].isExist=true;
        users[owner].id=curruserid++;
         users[owner].upline = owner;
    }
    
    function exchangeratefortrx(uint amountperusd) public {
        require(msg.sender==owner,"Invalid address");
        TRX_FOR_ONE_USD=amountperusd;
    }
    
    function changeAmountTRXtoUSD(uint256 amount) public view returns(uint256){
        return (amount*1 trx*TRX_FOR_ONE_USD).div(100);
    }
    
    
    
    function() payable external {
        register(owner);
    }

     function _setUpline(address _addr,address _upline) private 
     {
          if (users[_addr].upline == address(0) && users[_upline].isExist && _upline != msg.sender) {
            users[_addr].upline = _upline;
             emit Upline(_addr, _upline);
        }
     }

   
    
    function register(address _upline) public payable {
        uint256 _amount=msg.value;
        require(!users[msg.sender].isExist,"user already exists");
        require(!users[_addr].isExist, "No upline");
        require(_amount==(changeAmountTRXtoUSD(20)), "Bad amount");
        address _addr=msg.sender;
         _setUpline(msg.sender, _upline);
         require(users[msg.sender].upline!=address(0),"Invalid referral");
         RandDwallet.transfer(_amount.mul(10).div(100));
         users[_addr].isExist=true;
         distributeRef(msg.sender,1,_amount);
         looteryList[currentLotteryId].collectedFunds = looteryList[currentLotteryId].collectedFunds.add(msg.value.mul(20).div(100));
         total_invested=total_invested.add(msg.value);
         total_users++;
         emit Register(msg.sender,users[msg.sender].upline,block.timestamp);
    }
    
    function distributeRef(address user,uint256 level,uint256 amount) internal
    {
        address upline = users[user].upline;
        //  RandDwallet.transfer(amount.mul(10).div(100));
        if(upline!=address(0) && level<=7)
        {
            upline.transfer(amount.mul(10).div(100));
            users[upline].referrals[level-1]++;
            users[upline].refEarning = users[user].refEarning.add(amount.mul(10).div(100));
            distributeRef(upline,level+1,amount);
        }
    }
    
    function joinToLottery() public payable
    {
        require(users[msg.sender].isExist, "User not registered");
        require(msg.value==(changeAmountTRXtoUSD(5)), "Bad amount");
        RandDwallet.transfer(msg.value.mul(40).div(100));
        looteryList[currentLotteryId].lastBidId = looteryList[currentLotteryId].totalBids;
        looteryList[currentLotteryId].collectedFunds = looteryList[currentLotteryId].collectedFunds.add(msg.value.mul(60).div(100));
        bidDetails[currentLotteryId][looteryList[currentLotteryId].lastBidId] = msg.sender;
        looteryList[currentLotteryId].totalBids++;
        total_invested=total_invested.add(msg.value);
        emit JoinToLottery(msg.sender,msg.value,block.timestamp);
    }
    
    function declareWinner() public payable
    {
        require(msg.sender==owner,"Only owner can use this");
        uint index = random() % looteryList[currentLotteryId].totalBids;
        uint256 totalCollected = looteryList[currentLotteryId].collectedFunds;
        
        uint256 winningAmount = totalCollected.mul(65).div(100);
        bidDetails[currentLotteryId][index].transfer(winningAmount);
        
        lotteryDistributeRef(bidDetails[currentLotteryId][index],1,totalCollected);
        users[bidDetails[currentLotteryId][index]].earning = users[bidDetails[currentLotteryId][index]].earning.add(winningAmount);
        looteryList[currentLotteryId].winnerid = index;
        emit winnerList(msg.sender,looteryList[currentLotteryId].collectedFunds,block.timestamp);
        currentLotteryId++;
    }
    
    function lotteryDistributeRef(address user,uint256 level,uint256 amount) internal
    {
        address upline = users[user].upline;
        if(upline!=address(0) && level<=7)
        {
            upline.transfer(amount.mul(5).div(100));
            users[upline].refEarning = users[upline].refEarning.add(amount.mul(5).div(100));
            lotteryDistributeRef(upline,level+1,amount);
        }
    }
    
    function random() private view returns (uint) 
    {
        return uint(keccak256(abi.encodePacked(block.difficulty, now,  bidDetails[currentLotteryId][looteryList[currentLotteryId].lastBidId])));
    }
    
       function getReferralIncome(address user) public view  returns(uint256[7] memory referrals)
    {
        
          for(uint256 i = 0; i < 7; i++) {
            referrals[i] = users[user].referrals[i];
        }
        return (referrals);
    }
    
    
    function getR(address user)  public view  returns(uint256)
    {
        return users[user].referrals[0];
    }
    
}