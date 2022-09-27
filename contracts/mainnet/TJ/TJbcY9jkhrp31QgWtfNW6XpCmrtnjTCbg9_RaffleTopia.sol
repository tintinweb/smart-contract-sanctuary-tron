//SourceUnit: topiaRaffle.sol

pragma solidity ^0.4.25;  /*


    
    ___________________________________________________________________
      _      _                                        ______           
      |  |  /          /                                /              
    --|-/|-/-----__---/----__----__---_--_----__-------/-------__------
      |/ |/    /___) /   /   ' /   ) / /  ) /___)     /      /   )     
    __/__|____(___ _/___(___ _(___/_/_/__/_(___ _____/______(___/__o_o_
        
        




████████╗ ██████╗ ██████╗ ██╗ █████╗     ██████╗  █████╗ ███████╗███████╗██╗     ███████╗
╚══██╔══╝██╔═══██╗██╔══██╗██║██╔══██╗    ██╔══██╗██╔══██╗██╔════╝██╔════╝██║     ██╔════╝
   ██║   ██║   ██║██████╔╝██║███████║    ██████╔╝███████║█████╗  █████╗  ██║     █████╗  
   ██║   ██║   ██║██╔═══╝ ██║██╔══██║    ██╔══██╗██╔══██║██╔══╝  ██╔══╝  ██║     ██╔══╝  
   ██║   ╚██████╔╝██║     ██║██║  ██║    ██║  ██║██║  ██║██║     ██║     ███████╗███████╗
   ╚═╝    ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝    ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝     ╚══════╝╚══════╝
                                                                                         


  
                                                                                     
                                                                                     


----------------------------------------------------------------------------------------------------

=== MAIN FEATURES ===
    => Higher degree of control by owner - safeGuard functionality
    => SafeMath implementation 
    => Earning on Raffle Game

------------------------------------------------------------------------------------------------------
 Copyright (c) 2019 onwards topia Inc. ( https://Raffletopia.io )
 Contract designed with ❤ by EtherAuthority  ( https://EtherAuthority.io )
------------------------------------------------------------------------------------------------------
*/

/* Safemath library */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
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
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
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
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
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
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

// Owner Handler
contract ownerShip    // Auction Contract Owner and OwherShip change
{
    //Global storage declaration
    address public owner;

    address public newOwner;

    bool public safeGuard ; // To hault all non owner functions in case of imergency

    //Event defined for ownership transfered
    event OwnershipTransferredEv(address indexed previousOwner, address indexed newOwner);


    //Sets owner only on first run
    constructor() public 
    {
        //Set contract owner
        owner = msg.sender;
        // Disabled global hault on first deploy
        safeGuard = false;



    }

    //This will restrict function only for owner where attached
    modifier onlyOwner() 
    {
        require(msg.sender == owner);
        _;
    }


    function transferOwnership(address _newOwner) public onlyOwner 
    {
        newOwner = _newOwner;
    }


    //the reason for this flow is to protect owners from sending ownership to unintended address due to human error
    function acceptOwnership() public 
    {
        require(msg.sender == newOwner);
        emit OwnershipTransferredEv(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }

    function changesafeGuardStatus() onlyOwner public
    {
        if (safeGuard == false)
        {
            safeGuard = true;
        }
        else
        {
            safeGuard = false;    
        }
    }

}


//**************************************************************************//
//-------------------    REFERRAL CONTRACT INTERFACE    --------------------//
//**************************************************************************//

interface InterfaceREFERRAL {
    function referrers(address user) external returns(address);
    function updateReferrer(address _user, address _referrer) external returns(bool);
    function payReferrerBonusOnly(address _user, uint256 _refBonus, uint256 _trxAmount ) external returns(bool);
    //function payReferrerBonusAndAddReferrer(address _user, address _referrer, uint256 _trxAmount, uint256 _refBonus) external returns(bool);
} 

//**************************************************************************//
//---------------------  TRONTOPIA CONTRACT INTERFACE  ---------------------//
//**************************************************************************//

interface interfaceTOKEN
{
    function transfer(address recipient, uint amount) external returns(bool);
    function mintToken(address _user, uint256 _tronAmount)  external returns(bool);
}



//**************************************************************************//
//---------------------   VOUCHERS CONTRACT INTERFACE  ---------------------//
//**************************************************************************//

interface InterfaceVOUCHERS
{
    function mintVouchers(address _user, uint256 _mainBetSUN, uint256 _siteBetSUN)  external returns(bool);
}



//**************************************************************************//
//---------------------   DIAMOND CONTRACT INTERFACE  ----------------------//
//**************************************************************************//

interface InterfaceDIAMOND
{
    function usersDiamondFrozen(address _user)  external view returns(uint256);
}


contract RaffleTopia is ownerShip
{

    using SafeMath for uint256;

    uint256 public totalTicketSaleValueOfAllRaffleSession;   // Total deposited trx after ticket sale of all session
    uint256 public totalTicketSaleValueOfCurrentRaffleSession;   // Trx which admin should not withdraw.
    //uint256 public totalAvailableTrxBalance; // Total available trx balance of this contract
    uint256 public totalTRXRakeComission;  //Total collected comission.
    uint256 public totalAdminComission; //total admin comission
    uint256 public withdrawnByAdmin;  //Total withdrawn TRX by admin

    uint256 public voucherRakePercent = 2500; // 2500 = 25.00%
    uint256 public diamondRakePercent = 2500; // 2500 = 25.00%
    uint256 public topiaRakePercent = 2500;  // 2500 = 25.00%   
    uint256 public vaultRakePercent = 2500;  // 2500 = 25.00% 
    uint256 public voucherRakeBalance;  // withdrawable part for voucher rake
    uint256 public diamondRakeBalance;  // withdrawable part for diamond rake
    uint256 public topiaRakeBalance;    // withdrawable part for div rake
    uint256 public vaultRakeBalance;    // withdrawable part for vault rake

    address public topiaTokenContractAddress;
    address public dividendContractAddress;
    address public voucherContractAddress;
    address public voucherDividendContractAddress;
    address public vaultContractAddress;
    address public diamondContractAddress;
    address public diamondVoucherContractAddress;
    address public refPoolContractAddress;

    struct RaffleMode    // struct for keeping different rake percent with rake name
    {
        uint256 rakePercent; // % deduction for this rake will be forwarded to contract address
        uint256 adminPercent; // % deduction for this rake for admin comission
        uint256 entryPeriod;     // Raffle session will end after this seconds 
        uint256 startTicketNo;  // Starting number of the ticket, next all ticket will be next no up to max ticket count reached
        uint256 maxTicketCount;     // maximum ticket (count) open to sale for current session
        uint256 ticketPrice;        //Price of each ticket, user must paid to buy
        bool active;               // if false can not be used
    }

    RaffleMode[] public RaffleModes;


    struct RaffleInfo
    {
        uint256 totalTrxCollected;    // Total TRX on Raffle for the given ID
        uint256 lastSoldTicketNo;      // Last ticket no which sold
        uint256 startTime;          // Starting time of Raffle, to check participant can buy ticket up to certain given seconds for a session
        uint256 winningNo;             // the ticket no which declared as winner
        uint256 houseComission;     // comission paid to house for this RaffleID till claim reward it is used for loop control
        uint256 adminComission;     // comission paid to house for this RaffleID
        uint256 winningAmount;      // winningAmount of winner after comission
        uint256 raffleMode;        // rake percent info for this RaffleID
        bool winnerDeclared;        // winner declared or not if not then false
        uint256 thisBlockNo;   // current block number will be used later in selectWinner to predict winner ticket no
    }

    RaffleInfo[] public RaffleInfos;  //Its index is the RaffleID


    // first uint256 is raffleID and 2nd is ticket no and stored address is ticket owner
    mapping (uint256 => mapping( uint256 => address)) public ticketOwner;


    // Trx blance of user's (winning amount etc) which he can withdraw when he wants
    mapping( address => uint256 ) public userBalance; 


    function () payable external {
        revert();
    }



    //Sets owner only on first run
    constructor() public 
    {
        //Set default rake category rake category no 0
        RaffleMode memory temp;
        temp.rakePercent = 400;   // 4% comission to contract address
        temp.adminPercent = 100;  // 1% comission to admin
        temp.ticketPrice = 100;   // Trx required to buy one ticket
        temp.entryPeriod = 86400;   // 180 second 3 minute of betting time
        temp.startTicketNo = 9999;  // default is 8 players for category RaffleModes[0]
        temp.maxTicketCount = 99999999;  //15 seconds of grace period to increase bet amount
        temp.active =  true ;  // this rake is active gambler can use
        RaffleModes.push(temp);      
    }

    //Event for trx paid and withdraw (if any)
    event ticketBoughtEv(address paidAmount, address user, uint ticketNo );
    event trxWithdrawEv(address user, uint amount, uint remainingBalance);

    /**
        Function allows owner to update the Topia contract address
    */
    function updateContractAddresses(address topiaContract, address voucherContract, address dividendContract, address vaultContract, address diamondContract,address diamondVoucherContract, address refPoolContract,address voucherDividendContract) public onlyOwner returns(string)
    {
        topiaTokenContractAddress = topiaContract;
        voucherContractAddress = voucherContract;
        voucherDividendContractAddress = voucherDividendContract;
        dividendContractAddress = dividendContract;
        vaultContractAddress = vaultContract;
        diamondContractAddress = diamondContract;
        diamondVoucherContractAddress = diamondVoucherContract; 
        refPoolContractAddress = refPoolContract;

        return "Addresses updated successfully";
    }

    function updateRakeCategoryPercent(uint256 _voucherRakePercent, uint256 _diamondRakePercent, uint256 _topiaRakePercent, uint256 _vaultRakePercent) public onlyOwner returns(bool)
    {
        uint256 sumAll = _voucherRakePercent + _diamondRakePercent + _topiaRakePercent + _vaultRakePercent;
        require(sumAll == 10000, "sum of all must be 10000 (100%)");
        voucherRakePercent = _voucherRakePercent;
        diamondRakePercent = _diamondRakePercent;
        topiaRakePercent = _topiaRakePercent;
        vaultRakePercent = _vaultRakePercent;
        return true;
    }

    //Calculate percent and return result
    function calculatePercentage(uint256 PercentOf, uint256 percentTo ) internal pure returns (uint256) 
    {
        uint256 factor = 10000;
        require(percentTo <= factor);
        uint256 c = PercentOf.mul(percentTo).div(factor);
        return c;
    } 


    event createRaffleModeEv(uint256 nowTime,uint256 _rakePercent,uint256 _entryPeriod,bool _active);
    //To create different rake category
    function createRaffleMode(uint256 _rakePercent,uint256 _adminPercent, uint256 _entryPeriod,uint256 _startTicketNo, uint256 _maxTicketCount,uint256 _ticketPrice, bool _active) public onlyOwner returns(bool)
    {
        RaffleMode memory temp;
        temp.rakePercent = _rakePercent;
        temp.adminPercent = _adminPercent;
        temp.entryPeriod = _entryPeriod;
        temp.startTicketNo = _startTicketNo;
        temp.maxTicketCount = _maxTicketCount;
        temp.ticketPrice = _ticketPrice;
        temp.active = _active;
        RaffleModes.push(temp);
        emit createRaffleModeEv(now,_rakePercent,_entryPeriod,_active);
        return true;
    }

    event changeRaffleModeEv(uint256 nowTime,uint256 RaffleModeID,uint256 _rakePercent,uint256 _entryPeriod,bool _active);
    function changeRaffleMode(uint256 RaffleModeID, uint256 _rakePercent,uint256 _adminPercent, uint256 _entryPeriod,uint256 _startTicketNo, uint256 _maxTicketCount,uint256 _ticketPrice, bool _active) public onlyOwner returns(bool)
    {
        require(RaffleModeID < RaffleModes.length, "Invalid Raffle ID");
        RaffleModes[RaffleModeID].rakePercent = _rakePercent;
        RaffleModes[RaffleModeID].adminPercent = _adminPercent;
        RaffleModes[RaffleModeID].entryPeriod = _entryPeriod;
        RaffleModes[RaffleModeID].startTicketNo = _startTicketNo;
        RaffleModes[RaffleModeID].maxTicketCount = _maxTicketCount;
        RaffleModes[RaffleModeID].ticketPrice = _ticketPrice;
        RaffleModes[RaffleModeID].active = _active;
        emit changeRaffleModeEv(now,RaffleModeID,_rakePercent,_entryPeriod,_active);
        return true;
    }

    function changeActiveRaffleMode(uint256 _RaffleModeID, bool _status) public onlyOwner returns (bool)
    {
        RaffleModes[_RaffleModeID].active = _status;
        return true;
    }


    //To withdraw trx
    function trxWithdraw(uint amount) public returns (bool)
    {
        require(!safeGuard,"System Paused by Admin");
        address caller = msg.sender;
        require(caller!= address(0),"Address(0) found, can't continue" );
        require(userBalance[caller] >= amount,"Insufficient fund to withdraw");
        userBalance[caller] = userBalance[caller].sub(amount);
        caller.transfer(amount);
        emit trxWithdrawEv(caller, amount, userBalance[caller]);
        return true;
    }


    /**
     * Just in rare case, owner wants to transfer TRX from contract to owner address
     */
    function manualWithdrawTRX(uint256 Amount) public onlyOwner returns (bool){
        require (totalAdminComission >= Amount);
        address(owner).transfer(Amount);
        withdrawnByAdmin = withdrawnByAdmin.add(Amount);
        return true;
    }


    event buyRaffleTicketEv(uint256 timeNow, address buyer, uint256 lastTicketNo, uint256 noOfTicketBought, uint256 amountPaid);

    function buyRaffleTicket(uint256 _noOfTicketToBuy, uint256 _RaffleModeID, address _referrer ) public payable returns(bool)
    {
        require(!safeGuard,"System Paused by Admin");
        require(_RaffleModeID < RaffleModes.length , "undefined raffle mode");
        require(RaffleModes[_RaffleModeID].active = true,"this raffle mode is locked by admin");
        address caller = msg.sender;
        require(caller != address(0),"invalid caller address(0)");
        uint256 ticketPrice = RaffleModes[_RaffleModeID].ticketPrice;
        uint256 paidValue = msg.value;
        require(paidValue >= _noOfTicketToBuy * ticketPrice, "Paid Amount is less than required" );
        
        totalTicketSaleValueOfAllRaffleSession += paidValue;
        totalTicketSaleValueOfCurrentRaffleSession += paidValue;
        uint256 raffleInfoID = RaffleInfos.length;
        uint256 i;
        if (raffleInfoID == 0 || RaffleInfos[raffleInfoID -1 ].winnerDeclared == true)
        {
            RaffleInfo temp;
            temp.totalTrxCollected = paidValue;
            i = RaffleModes[_RaffleModeID].startTicketNo;
            temp.lastSoldTicketNo = RaffleModes[_RaffleModeID].startTicketNo + _noOfTicketToBuy - 1 ;
            temp.startTime = now;
            temp.raffleMode = _RaffleModeID;
            temp.thisBlockNo = block.number;
            RaffleInfos.push(temp);
        }
        else
        {
            raffleInfoID -= 1;
            require(now <= RaffleInfos[raffleInfoID].startTime.add(RaffleModes[RaffleInfos[raffleInfoID].raffleMode].entryPeriod), "sorry period is over");
            i = RaffleInfos[raffleInfoID].lastSoldTicketNo + 1;
            RaffleInfos[raffleInfoID].totalTrxCollected += paidValue;
            RaffleInfos[raffleInfoID].lastSoldTicketNo = i +  _noOfTicketToBuy;
            RaffleInfos[raffleInfoID].thisBlockNo = block.number;          
        }
        uint256 range = i + _noOfTicketToBuy;
        for (i; i< range; i++)
        {
           ticketOwner[raffleInfoID][i] = caller; 
        }

        // If this is the user's first bet...
        if (_referrer != address(0))
        {
            // Set their referral address
            InterfaceREFERRAL(refPoolContractAddress).updateReferrer(caller, _referrer);       
        }

        emit buyRaffleTicketEv(now, caller, RaffleInfos[raffleInfoID].lastSoldTicketNo, _noOfTicketToBuy, paidValue);        
        return true;
    }

    event  WinnerNComisisonRewardedEv(uint256 nowTime,address WinnerAddress,uint256 comission,uint256 rewardAmount  );
    event selectWinnerEv(uint256 nowTime,uint256 winnerNo, uint256 RaffleID,uint256 blockNo, bytes32 blockHashValue );
   
   
    function selectWinner(uint256 raffleInfoID, bytes32 blockHashValue ) public onlyOwner returns(uint256)
    {
        require(RaffleInfos[raffleInfoID].winnerDeclared == false, "winner is already declared");       
        require(now > RaffleInfos[raffleInfoID].startTime.add(RaffleModes[RaffleInfos[raffleInfoID].raffleMode].entryPeriod), "entry period is not over");

        uint256 lastBetBlockNo = RaffleInfos[raffleInfoID].thisBlockNo;

        if(block.number < 255 + lastBetBlockNo )
        {
            blockHashValue = blockhash(lastBetBlockNo);
        }
        require(blockHashValue != 0x0, "invalid blockhash" );

         // In blow line house comission is just a temporary value of upper bound of range 0-99 , this house comission will assigned a real value when reqard distribution
        uint256 startTicketNo = RaffleModes[RaffleInfos[raffleInfoID].raffleMode].startTicketNo;
        uint256 rangeFromZero = RaffleInfos[raffleInfoID].lastSoldTicketNo - startTicketNo;
        uint256 winnerTicketNo = uint256(blockHashValue) % rangeFromZero + 1;
        winnerTicketNo = winnerTicketNo + startTicketNo;

        RaffleInfos[raffleInfoID].winningNo = winnerTicketNo;
        RaffleInfos[raffleInfoID].winnerDeclared = true;

        require(claimWinnerReward(raffleInfoID),"reward failed");

        emit selectWinnerEv(now,winnerTicketNo, raffleInfoID , lastBetBlockNo, blockHashValue );
        return winnerTicketNo;
    }


    function claimWinnerReward(uint256 raffleInfoID) public returns (bool)
    {

        return true;
    }


    function getAvailableVoucherRake() public view returns (uint256)
    {
        return voucherRakeBalance;
    }


    // payout request for voucher rake part , only called by specific contract
    function requestVoucherRakePayment() public returns(bool)
    {
        require(msg.sender == voucherContractAddress, 'Unauthorised caller');
        require(voucherRakeBalance > 0, "not enough voucher balaance");
        uint256 rakeAmount = voucherRakeBalance;
        voucherRakeBalance = 0;
        totalTRXRakeComission = totalTRXRakeComission.sub(rakeAmount);
        msg.sender.transfer(rakeAmount);
        return true;
    }

    function getAvailableDiamondRake() public view returns(uint256)
    {
        return diamondRakeBalance;
    }

    // payout request for diamond rake part , only called by specific contract
    function requestDiamondRakePayment() public returns(bool)
    {
        require(msg.sender == diamondContractAddress, 'Unauthorised caller');
        require(diamondRakeBalance > 0, "not enough diamond balaance");
        uint256 rakeAmount = diamondRakeBalance;
        diamondRakeBalance = 0;
        totalTRXRakeComission = totalTRXRakeComission.sub(rakeAmount);
        msg.sender.transfer(rakeAmount);
        return true;
    }

    function getAvailableDivRake() public view returns(uint256)
    {
        return topiaRakeBalance;
    }

    // payout request for topia rake part , only called by specific contract
    function requestDivRakePayment(uint256 rakeAmount) public returns(bool)
    {
        require(msg.sender == topiaTokenContractAddress, 'Unauthorised caller');
        require(rakeAmount <= topiaRakeBalance, "not enough voucher balaance");
        topiaRakeBalance = topiaRakeBalance.sub(rakeAmount);
        totalTRXRakeComission = totalTRXRakeComission.sub(rakeAmount);
        msg.sender.transfer(rakeAmount);
        return true;
    }

    function getAvailableVaultRake() public view returns(uint256)
    {
        return vaultRakeBalance;
    }

    // payout request for diamond rake part , only called by specific contract
    function requestVaultRakePayment() public returns(bool)
    {
        require(msg.sender == vaultContractAddress, 'Unauthorised caller');
        require(vaultRakeBalance > 0, "not enough diamond balaance");
        uint256 rakeAmount = vaultRakeBalance;
        vaultRakeBalance = 0;
        totalTRXRakeComission = totalTRXRakeComission.sub(rakeAmount);
        msg.sender.transfer(rakeAmount);
        return true;
    }


}