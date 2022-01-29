//SourceUnit: vault.sol

pragma solidity 0.4.25; 

/*

___________________________________________________________________
  _      _                                        ______           
  |  |  /          /                                /              
--|-/|-/-----__---/----__----__---_--_----__-------/-------__------
  |/ |/    /___) /   /   ' /   ) / /  ) /___)     /      /   )     
__/__|____(___ _/___(___ _(___/_/_/__/_(___ _____/______(___/__o_o_ 



████████╗██████╗  ██████╗ ███╗   ██╗    ████████╗ ██████╗ ██████╗ ██╗ █████╗ 
╚══██╔══╝██╔══██╗██╔═══██╗████╗  ██║    ╚══██╔══╝██╔═══██╗██╔══██╗██║██╔══██╗
   ██║   ██████╔╝██║   ██║██╔██╗ ██║       ██║   ██║   ██║██████╔╝██║███████║
   ██║   ██╔══██╗██║   ██║██║╚██╗██║       ██║   ██║   ██║██╔═══╝ ██║██╔══██║
   ██║   ██║  ██║╚██████╔╝██║ ╚████║       ██║   ╚██████╔╝██║     ██║██║  ██║
   ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝       ╚═╝    ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝
                                                                             


=== 'Vault' contract with following features ===
    => Higher degree of control by owner - derived safeguard functionality in dependent contract
    => SafeMath implementation 
    => Vault game logic control 
    

======================= Quick Stats ===================
    => Game Name            : Topia Vault Game
    => Based Token Name     : Topia Voucher

============= Independant Audit of the code ============
    => Multiple Freelancers Auditors
    => Community Audit by Bug Bounty program


-------------------------------------------------------------------
 Copyright (c) 2019 onwards TRONtopia Inc. ( https://trontopia.co )
 Contract designed by EtherAuthority ( https://EtherAuthority.io )
-------------------------------------------------------------------
*/ 

//*******************************************************************//
//------------------------ SafeMath Library -------------------------//
//*******************************************************************//
/**
    * @title SafeMath
    * @dev Math operations with safety checks that throw on error
    */
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

//*******************************************************************//
//------------------ Contract to Manage Ownership -------------------//
//*******************************************************************//
    
contract owned {
    address public owner;
    address public newOwner;
    address public signer;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
        signer = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlySigner {
        require(msg.sender == signer);
        _;
    }

    function changeSigner(address _signer) public onlyOwner {
        signer = _signer;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    //this flow is to prevent transferring ownership to wrong wallet by mistake
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}



//**************************************************************************//
//---------------------    GAMES CONTRACT INTERFACE    ---------------------//
//**************************************************************************//

interface InterfaceGAMES {
    function getAvailableVaultRake() external view returns (uint256);
    function requestVaultRakePayment() external returns(bool);
} 



interface ERC20Essential 
{
    function displayAvailableDividendALL() external returns (bool, uint256);
    function distributeMainDividend() external  returns(uint256);
    function getDividendConfirmed(address user) external view returns (uint256);
    function withdrawDividend() external returns(bool);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function burnVoucher(uint256 _value, uint8 mintShareStatus, address _user) external returns (bool success);

}


contract vaultGame is  owned
{

    constructor () public {


    }

    // Public variables of the token
    using SafeMath for uint256;

    uint256 public minimumVoucherToBurn;             // minimum amount required to burning for effective on time
    uint256 public burnIncreasePerLevelInPercent = 10000;  // 10000 = 100%, minimum amount will increase by percent on each deffined step
    uint256 public burnIncreaseAfterStepCount=100;  // after this step count reached required burning will increase by given percent
    uint256 public gameClockSpanInSeconds=43200; // 43200 sec = 12 Hr.
    uint256 public burnPushInSecond=30;     // Will push 30 second on each burn
    uint256 public secondPushDecreasePerLevel=1;  // Will decrease seconds ( like lavel 1 = 30 Sec, lavel 2 = 29 Sec, lavel 3 = 28 Sec) 
    uint256 public gameTimer;   // will keep the finished time of the game
    uint256 public burnCounter; // counting of only effective burn from the start of game session
    uint256 public totalVoucherBurnt;  //count total effective vaucher burnt for one game session
    bool public nextGameAutoStart;  // if auto start is true the game will start automatically after previous end else, voucher burn by user needed to start game
    mapping (address => bool) public globalToken;   // The very voucher token only allowed to play here admin need to set 
    // This creates a mapping with all data storage
    mapping (address => bool) public whitelistCaller;  //Game contracts whitelisting
    address[] public whitelistCallerArray;  //Game contracts whitelisting
    mapping (address => uint256) internal whitelistCallerArrayIndex;  //Game contracts whitelisting
    uint256 public dividendAccumulated;
    uint256 public divPercentageSUN = 100000000;  //100% of dividend distributed 

    //distribution %age can dynamically assigned by admin
        uint256 toLastBurnerPercent = 2500; // 25%
        uint256 toSenondLastBurnerPercent = 1500; // 15%
        uint256 toThirdLastBurnerPercent  = 1000; //10%
        uint256 toOwnerPercent =  1000; // 10%
        uint256 toDividendPercent  = 2500; // 25%
        uint256 carryOverPercent = 1500; // 15%
    mapping(address => uint256) public userTrxBalance;
    uint256 public carryOverAmount;  // last x % of distribution (by carryOverPercent) carrited over
    
    
    mapping (address => uint256[]) public burnerIndicesOdd; // All records or burnerInfos index of a single user
    mapping (address => uint256[]) public burnerIndicesEven; // All records or burnerInfos index of a single user
    // when odd is recording burning, even will help distribution of previous dividend and vice-versa
    bool public oddEven;  //to help passive distribution of dividendpercent, once odd and next even will be in action
    uint256 public totalVoucherBurntPrev;  // burn records shifted here after session so that passive dist can work without affectins next session record
    uint256 public toDividendPrev;   // calculated dividend records shifted here after distribution so that passive dist can work without affectins next session record
    mapping (address => uint256) public usersVaultBurnAmount;  // total burn in one session by user will reset on next session
    uint256 public maxBurnLimit=100000000;  // User can burn only this much amount in one session


    // Struct to keep burning records 
    struct burnerInfo
    {
        address burner;       //address of burner
        uint256 burnAmount;    // and his burn amount
    }
    
    burnerInfo[] public burnerInfos; //Address of burner in series for one game session and his amount
    burnerInfo[] public burnerInfosPrev; //This helps to claim dividend part for the user, once claimmed amount will be zero


     //Calculate percent and return result
    function calculatePercentage(uint256 PercentOf, uint256 percentTo ) internal pure returns (uint256) 
    {
        uint256 factor = 10000;
        require(percentTo <= factor);
        uint256 c = PercentOf.mul(percentTo).div(factor);
        return c;
    }   

    function () payable external {}  // This contract will accept TRX , useful when distribution fetchs TRX from other contract

    // To set max burn limit on one call
    function setmaxBurnLimit(uint _maxBurnLimit) onlyOwner public returns(bool success)
    {
        maxBurnLimit = _maxBurnLimit;
        return true;
    }
    // To set min voucher to burn on one call and its multiple will be allowed only not fractional
    function setMinimumVoucherToBurn(uint _minimumVoucherToBurn) onlyOwner public returns(bool success)
    {
        minimumVoucherToBurn = _minimumVoucherToBurn;
        return true;
    }
    // To set how much % amount will increase after certain steps count, if 0 will there be equal required amount for entire session
    function setBurnIncreasePerLevelInPercent(uint _burnIncreasePerLevelInPercent) onlyOwner public returns(bool success)
    {
        burnIncreasePerLevelInPercent = _burnIncreasePerLevelInPercent;
        return true;
    }
    // To set number of steps after which burn amount will increase by given percent 
    function setburnIncreaseAfterStepCount(uint _burnIncreaseAfterStepCount) onlyOwner public returns(bool success)
    {
        burnIncreaseAfterStepCount = _burnIncreaseAfterStepCount;
        return true;
    }
    //To set the max duration the game will live if no burns ( default 12 Hr. )
    function setGameClockSpanInSeconds(uint _gameClockSpanInSeconds) onlyOwner public returns(bool success)
    {
        gameClockSpanInSeconds = _gameClockSpanInSeconds;
        return true;
    }
    // To set if next game will start automatically (if true) or by the first burn (if false)
    function setNextGameAutoStart(bool _nextGameAutoStart) onlyOwner public returns(bool success)
    {
        nextGameAutoStart = _nextGameAutoStart;
        return true;
    }

    //To set max seconds a vault can achieve when min required amount is burn, will decrease by given setting in setSecondPushDecreasePerLevel as burning count grows
    function setBurnPushInSecond(uint256 _burnPushInSecond) onlyOwner public returns(bool success)
    {
        require(_burnPushInSecond > 1,"can not be less than 2");
        burnPushInSecond = _burnPushInSecond;
        return true;
    }

    // To set how much second will decrease after a certain lavel count
    function setSecondPushDecreasePerLevel(uint256 _secondPushDecreasePerLevel) onlyOwner public returns(bool success)
    {
        secondPushDecreasePerLevel = _secondPushDecreasePerLevel;
        return true;
    }
    // To set which voucher token will be burnt, when voucher change prev need to set false and new need to set true here
    event setglobalTokenEv(uint256 nowTime, address tokenAddress, bool status);
    function setglobalToken(address _globalToken, bool _enable ) onlyOwner public returns(bool success)
    {
        globalToken[_globalToken] = _enable;
        emit setglobalTokenEv(now, _globalToken, _enable);
        return true;
    }

    // To set % age distribution of reward for different segment , here % is as  ex 123= 1.23%, 10000 = 100% 
    function setDistributionPercent(uint256 _toLastBurnerPercent, uint256 _toSenondLastBurnerPercent, uint256 _toThirdLastBurnerPercent, uint256 _toOwnerPercent, uint256 _toDividendPercent,uint256 _carryOverPercent) public onlyOwner returns(bool)
    {
        uint256 sumAll = _toLastBurnerPercent + _toSenondLastBurnerPercent + _toThirdLastBurnerPercent + _toOwnerPercent + _toDividendPercent + _carryOverPercent;
        require(sumAll == 10000, "sum of all is not 100%");        
        toLastBurnerPercent = _toLastBurnerPercent;
        toSenondLastBurnerPercent = _toSenondLastBurnerPercent; 
        toThirdLastBurnerPercent  = _toThirdLastBurnerPercent; 
        toOwnerPercent =  _toOwnerPercent; 
        toDividendPercent  = _toDividendPercent;
        carryOverPercent = _carryOverPercent;        
        return true;
    }
    // Function to burn voucher, if it is first burn then startVAultPlay will be called internally else pushMyBurn will be called
    event placeMyBurnEv(address caller, uint amountBurned, uint timeNow, bool effective);
    function placeMyBurn(address token, uint amountToBurn) public returns (bool)
    {
        bool success;
        if (gameTimer == 0)
        {
            success = startVaultPlay(token,amountToBurn);
        }
        else
        {
            success = pushMyBurn(token,amountToBurn);
        }
        emit placeMyBurnEv(msg.sender, amountToBurn,now,success);
    }



    function startVaultPlay(address token, uint amountToBurn) internal returns(bool)
    {
        address starter = msg.sender;
        require(amountToBurn<= maxBurnLimit,"In one call can't burn beyond limit");
        require(globalToken[token], "invalid token address");
        require(ERC20Essential(token).balanceOf(starter)>= amountToBurn,"insufficiedt balance");
        require(claimMyPart(starter),"claim for previous session failed");
        require(gameTimer == 0, "game is already on");
        require(starter != address(0), "address 0 found");
        //To check fractional amount and will revert if true means amount is not multiple of minimumVoucherToBurn
        uint256 modOf = amountToBurn % minimumVoucherToBurn;
        require( modOf == 0, "franctional multiple amount not valid" );
        //Burning call to voucher contract
        require (ERC20Essential(token).burnVoucher(amountToBurn,2,starter),"burning failed");
        //Sum up total burning amount for user
        usersVaultBurnAmount[starter] += amountToBurn;
        
        //Increase burning counter as per given amount
        uint256 countMultiple = amountToBurn / minimumVoucherToBurn;
        uint i;
        for (i=0;i<countMultiple;i++)
        {
            burnCounter ++;
        }

        // Set burning records in variable burnerInfos in one session will be odd and in next even and hence alternate      
        bool success;
        burnerInfo memory temp;
        if (amountToBurn >= minimumVoucherToBurn)
        {
            gameTimer = now.add(gameClockSpanInSeconds);
            totalVoucherBurnt = amountToBurn;
            temp.burner = starter;
            temp.burnAmount = amountToBurn;
            if(! oddEven)
            {
                burnerIndicesEven[starter].push(burnerInfos.length);
            }
            else
            {
                burnerIndicesOdd[starter].push(burnerInfos.length);
            }
            burnerInfos.push(temp);
            
            success = true;
        }
        return success;
    }


    //To view the required amount and for how much seconds for that amount, 
    function whatIsRequiredNow() public view returns(uint256 reqAmount, uint256 secondAddOn)
    {
        //how much amount need to increase after a certain no of burn counting to calculate required amount at particular stage;
        uint increaseUnitAmount = calculatePercentage(minimumVoucherToBurn,burnIncreasePerLevelInPercent); 
        uint increaseFactor = burnCounter.div(burnIncreaseAfterStepCount);
        reqAmount = minimumVoucherToBurn.add(increaseUnitAmount.mul(increaseFactor));
        uint256 secondDecreased;
        secondDecreased = secondPushDecreasePerLevel * increaseFactor; // second decreased
        if(burnPushInSecond >= secondDecreased)
        {
            secondAddOn = burnPushInSecond  - secondDecreased;         
        } 
        if (secondAddOn == 0)  // if the calculated second is 0 then 1 will be return , capped on 1     
        {
            secondAddOn = 1;
        }
        return (reqAmount, secondAddOn);
    }

    // If next session is set to auto start then first burn will also come to pushMyBurn, else 2nd and all next burn will call this pushMyhBurn
    function pushMyBurn(address token, uint amountToBurn) internal returns(bool)
    {
        address callingUser = msg.sender;
        require(amountToBurn<= maxBurnLimit,"In one call can't burn beyond limit");
        require(globalToken[token], "invalid token address");
        require(gameTimer != 0 && gameTimer > now, "not started yet or reward distribution pending");
        require(ERC20Essential(token).balanceOf(callingUser)>= amountToBurn,"insufficiedt balance");
        require(claimMyPart(callingUser),"claim for previous session failed");

        //how much amount need to increase after a certain no of burn counting to calculate required amount at particular stage;
        uint increaseUnitAmount = calculatePercentage(minimumVoucherToBurn,burnIncreasePerLevelInPercent); 
        uint increaseFactor = burnCounter.div(burnIncreaseAfterStepCount);
        uint requiredAmount = minimumVoucherToBurn.add(increaseUnitAmount.mul(increaseFactor));

        // To check if amount is not in multiple of minRequiredAmount then will revert
        uint256 modOf = amountToBurn % requiredAmount; // getting mod to check fraction if any in next line if freaction will revert
        require( modOf == 0, "franctional multiple amount not valid" );
        //Burning called from voucher token contract
        require (ERC20Essential(token).burnVoucher(amountToBurn,2,callingUser),"burning failed");  // burning voucher
        usersVaultBurnAmount[callingUser] += amountToBurn;

        // To calculate how much second will be added for the given amount and burning counter will increase accordingly
        uint256 countMultiple = amountToBurn / requiredAmount;
        uint256 secondsEarned;
        uint256 secondDecreased;
        uint i;
        for (i=0;i<countMultiple;i++)
        {
            secondDecreased = secondPushDecreasePerLevel * increaseFactor; // second decreased
            if (secondDecreased >= burnPushInSecond)       
            {
                secondDecreased = (burnPushInSecond -1);
            }            
            if(burnPushInSecond > secondDecreased)
            {
                secondsEarned += burnPushInSecond  - secondDecreased;
                burnCounter ++;
                increaseFactor = burnCounter.div(burnIncreaseAfterStepCount);            
            }
        }

        //Updating burning records with the calculated seconds and its updating 
        burnerInfo memory temp;
        
        if(amountToBurn >= requiredAmount)
        {
            //updating calculated seconds, will never be greater than gameClockSpanInSeconds
            if ((gameTimer - now + secondsEarned) <= gameClockSpanInSeconds)
            {
                gameTimer += secondsEarned;
            }
            else
            {
                gameTimer += gameClockSpanInSeconds - (gameTimer - now);
            }

            // Updating burning records
            totalVoucherBurnt = totalVoucherBurnt.add(amountToBurn);
            temp.burner = callingUser;
            temp.burnAmount = amountToBurn;
            if(! oddEven)
            {
                burnerIndicesEven[callingUser].push(burnerInfos.length);
            }
            else
            {
                burnerIndicesOdd[callingUser].push(burnerInfos.length);
            }
            burnerInfos.push(temp);
            return true;
        }
        return false;      

    }


    event distributeRewardEv(uint256 toLastBurner, uint256 toSenondLastBurner, uint256 toThirdLastBurner,uint256 toOwner,uint256 toDividend,uint256 carryOverAmount );

    // To distribute rewards will be called by admin, only then next session of vault burning will start
    function distributeReward(address token) onlyOwner public returns(bool)
    {
        //check before distribution or rewards
        require(globalToken[token], "invalid token address");
        require(gameTimer < now, "game not finished yet");
        //require(burnerInfos.length > 0, "no player rolled");

        // If no burn in entire session then simply variable will reset no reward distribution else reward will be distributed
        if (totalVoucherBurnt > 0)    
        {
            //we will check dividends of all the game contract individually and sum up all values and transfering TRX to this contract
            uint256 totalGameContracts = whitelistCallerArray.length;
            uint256 totalDividend;
            uint256 i;
            for(i=0; i < totalGameContracts; i++){
                uint256 amount = InterfaceGAMES(whitelistCallerArray[i]).getAvailableVaultRake();
                if(amount > 0){
                    require(InterfaceGAMES(whitelistCallerArray[i]).requestVaultRakePayment(), 'could not transfer trx');
                    totalDividend += amount;
                }
            }

            // carryOverAmount of previous session is added in total amount
            totalDividend += carryOverAmount;

            //calculating distribution parts by percentage set by admin
            uint256 toLastBurner = calculatePercentage(totalDividend,toLastBurnerPercent);
            uint256 toSenondLastBurner = calculatePercentage(totalDividend,toSenondLastBurnerPercent); 
            uint256 toThirdLastBurner  = calculatePercentage(totalDividend,toThirdLastBurnerPercent);
            uint256 toOwner =  calculatePercentage(totalDividend,toOwnerPercent);
            uint256 toDividend  = calculatePercentage(totalDividend,toDividendPercent);
            carryOverAmount = calculatePercentage(totalDividend,carryOverPercent);

            // Distributing rewards to 1st 2nd and third Last burner
            uint256 lengthOf = burnerInfos.length;
            address burnerAddress;
            if (lengthOf > 0 )
            {
                burnerAddress = burnerInfos[lengthOf-1].burner;
                userTrxBalance[burnerAddress] = userTrxBalance[burnerAddress].add(toLastBurner);
            }
            if (lengthOf > 1 )
            {
                burnerAddress = burnerInfos[lengthOf-2].burner;
                userTrxBalance[burnerAddress] = userTrxBalance[burnerAddress].add(toSenondLastBurner);
            }        
            if (lengthOf > 2 )
            {
                burnerAddress = burnerInfos[lengthOf-3].burner;
                userTrxBalance[burnerAddress] = userTrxBalance[burnerAddress].add(toThirdLastBurner);
            }
            // reward to owner
            userTrxBalance[owner] = userTrxBalance[owner].add(toOwner);


            // shifting current burning data to other variable sot the passive distribution of dividend part can work for users
            // This distribution is controlled by oddEven variable once odd records current session and even distributed dividend and next vice-versa
            burnerInfosPrev = burnerInfos;
            totalVoucherBurntPrev = totalVoucherBurnt;
            toDividendPrev = toDividend;
            oddEven = ! oddEven;
        }
        
        //Reset all data after distribution
        delete burnerInfos;
        burnCounter = 0;
        totalVoucherBurnt = 0; 

        //If game is set to auto start then the reverse clock will set here else reverse clock will be 0 and will start when first burn     
        if(nextGameAutoStart)
        {
            gameTimer = now.add(gameClockSpanInSeconds);
        }
        else
        {
           gameTimer = 0;
        }
        emit distributeRewardEv(toLastBurner,toSenondLastBurner,toThirdLastBurner,toOwner,toDividend,carryOverAmount);
         
        return true;

    }

    // To give divident to specific user
    //User can call this himself who want to get his part
    // If admin calls need to provide user address for which award is to be claimed
    function claimDivPart(address user) public onlyOwner returns(bool)
    {
        address caller = msg.sender;
        if(caller == owner)
        {
            caller = user;
        }
        claimMyPart(caller);
    }

    // To claim dividend this is internall called be above finction claimDivPart
    function claimMyPart(address user) internal returns(bool)
    {
        // to all participant
        address caller = user;
        uint256 lengthOf;
        // To check odd / even and process accordingly
        // burnindices-odd/even contains all burning index of a user
        // when burnerIndicesOdd records current burning burnerIndicesEven helps to claim dividends and vice-versa
        if(!oddEven)
        {
            lengthOf = burnerIndicesOdd[caller].length;
        }
        else
        {
            lengthOf = burnerIndicesEven[caller].length;
        }        

        // claim processed here for all burns of a specific user 
        // which user can withdraw later when he wants
        uint256 hisPart;
        uint256 i;
        uint256 index;
        uint256 amount;
        for(i=0; i < lengthOf; i++)
        {
            if(!oddEven)
            {
                index = burnerIndicesOdd[caller][i];
            }
            else
            {
                index = burnerIndicesEven[caller][i];
            }             
            
            amount = burnerInfosPrev[index].burnAmount;
            //amount is 0 when taken for distribution in next line of hisPart =
            burnerInfosPrev[index].burnAmount = 0;
            if (amount == 0 )
            {
                // If already distributed this function will return from here ( helpful when called this while burning in next session)
                return true;
            }
            hisPart = amount / totalVoucherBurntPrev * toDividendPrev;
            userTrxBalance[caller] = userTrxBalance[caller].add(hisPart);
        }
        //Adter processing records is being deleted herre 
        if(!oddEven)
        {
            delete burnerIndicesOdd[caller];
        }
        else
        {
            delete burnerIndicesEven[caller];
        }  
        usersVaultBurnAmount[caller] = 0;
        return true;
    }

    //To withdraw TRX
    function withdrawTrx(uint256 amount) public returns(bool)
    {
        address caller = msg.sender;
        require(amount <= userTrxBalance[caller], "not enough balance");
        userTrxBalance[caller] = userTrxBalance[caller].sub(amount);
        caller.transfer(amount);
        return (true);
    }

    // To return view of current status for UI help
    function viewStat() public view returns (uint256 timeLeft, address lastBurner,uint256 lastBurnerAmount, address secondLastBurner,uint256 secondLastBurnerAmount, address thirdLastBurner,uint256 thirdLastBurnerAmount, uint256 poolSize,uint256 requiredAmountToBurn, uint256 canIncreaseSecondByBurn )
    {
        if (now < gameTimer )
        {
            timeLeft = gameTimer - now;
        }
        uint256 lengthOf = burnerInfos.length;
        if (lengthOf > 0 )
        {
            lastBurner = burnerInfos[lengthOf-1].burner;
            lastBurnerAmount = burnerInfos[lengthOf-1].burnAmount;
        }
        if (lengthOf > 1 )
        {
            secondLastBurner = burnerInfos[lengthOf-2].burner;
            secondLastBurnerAmount = burnerInfos[lengthOf-2].burnAmount;
        }        
        if (lengthOf > 2 )
        {
            thirdLastBurner = burnerInfos[lengthOf-3].burner;
            thirdLastBurnerAmount = burnerInfos[lengthOf-3].burnAmount;
        }

        poolSize += totalVoucherBurnt;

        (requiredAmountToBurn,canIncreaseSecondByBurn ) = whatIsRequiredNow();
        return (timeLeft,lastBurner,lastBurnerAmount,secondLastBurner,secondLastBurnerAmount,thirdLastBurner,thirdLastBurnerAmount,poolSize,requiredAmountToBurn,canIncreaseSecondByBurn);
    }


     /**
        This function displays all the dividend of all the game contracts
    */
    // To preview  the dividend
    function getDividendPotential() public view returns(uint256){

        //we will check dividends of all the game contract individually
        uint256 totalGameContracts = whitelistCallerArray.length;
        uint256 totalDividend;
        for(uint i=0; i < totalGameContracts; i++){
            uint256 amount = InterfaceGAMES(whitelistCallerArray[i]).getAvailableVaultRake();
            if(amount > 0){
                totalDividend += amount;
            }
        }

        if(totalDividend > 0 || dividendAccumulated > 0 ){
            
            //admin can set % of dividend to be distributed.
            //reason for 1000000 is that divPercentageSUN was in SUN
            uint256 newAmount = totalDividend * divPercentageSUN / 100 / 1000000; 

            return newAmount + dividendAccumulated + carryOverAmount;
            
        }
        
        //by default it returns zero
        
    }

    /*=====================================
    =          HELPER FUNCTIONS           =
    ======================================*/

    /** 
        * Add whitelist address who can call Mint function. Usually, they are other games contract
    */
    function addWhitelistGameAddress(address _newAddress) public onlyOwner returns(string){
        
        require(!whitelistCaller[_newAddress], 'No same Address again');

        whitelistCaller[_newAddress] = true;
        whitelistCallerArray.push(_newAddress);
        whitelistCallerArrayIndex[_newAddress] = whitelistCallerArray.length - 1;

        return "Whitelisting Address added";
    }

    /**
        * To remove any whilisted address
    */
    function removeWhitelistGameAddress(address _address) public onlyOwner returns(string){
        
        require(_address != address(0), 'Invalid Address');
        require(whitelistCaller[_address], 'This Address does not exist');

        whitelistCaller[_address] = false;
        uint256 arrayIndex = whitelistCallerArrayIndex[_address];
        address lastElement = whitelistCallerArray[whitelistCallerArray.length - 1];
        whitelistCallerArray[arrayIndex] = lastElement;
        whitelistCallerArrayIndex[lastElement] = arrayIndex;
        whitelistCallerArray.length--;

        return "Whitelisting Address removed";
    }
    //Just in rare case, owner wants to transfer TRX from contract to owner address
    function manualWithdrawTRX(uint256 amount) onlyOwner public returns(bool) 
    {
        require(address(this).balance >= amount, "not enough balance to withdraw" );
        address(owner).transfer(address(this).balance);
    }

}