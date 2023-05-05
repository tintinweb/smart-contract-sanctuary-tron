//SourceUnit: dct-staking.sol

// SPDX-License-Identifier: MIT

pragma solidity 0.8.0;

import "./dct.sol";

contract StakingDCT {
    address public owner;
    mapping (address => bool) public isAdministrator;
    uint256 public totalStaked;
    uint256 public totalPendingStaked;
    mapping (address => Staker) public stakers;
    mapping (address => uint256) public pendingStaking;
    mapping (address => uint256) public stakerMinted;

    mapping (address => bool) public oldStaker;
    mapping (address => bool) public importStaker;
    mapping (address => uint256) public oldStakerValidUntil;

    // miner price, payout per claim, total payout
    mapping (address => uint8) public minerType;  // miner type : 1, 2, 3
    mapping (address => uint256) public minerPrice;
    mapping (uint8 => uint256) public setupMinerPrice;
    // cycle start 0 until 11
    mapping (address => uint8) public minerCycle;
    mapping (address => uint16) public minerRoundCycle;
    mapping (address => uint256) public minerLastPayout;
    mapping (address => uint256) public minerFirstTimeFee;

    mapping (uint8 => uint256) public maxStaking;

    struct Staker {
        uint8 status;   // 0:inactive; 1:active; 2:unstake; 3:burned;
        uint256 lockSetup; // set lock amount when staker claim stake capital
        uint256 lockAmount;
        uint256 amountStaked;
        uint256 lastRewardTime;
        uint256 stakedTimestamp;
        uint256 minerBurnedTimestamp;
    }

    mapping(uint8 => uint64) public stageSchedule;
    mapping(uint8 => uint16) public rewardPercentage; // div 10000

    // address to collect miner usage fee -- tron
    address payable public addrminerfee;
    // address to collect first staking fee -- tron
    address payable public immutable addrfirststakingfee;
    // amount first staking fee;
    uint256 public firststakingfee;
    // address to collect claim transaction fee -- token
    address public addrfee;
    // address to collect claim transaction tax -- token
    address public immutable addrtax;
    uint64 public constant rewardInterval = 8 days;
    uint64 public constant burnedDuration = 90 days;
    // max claim in a row, reset to 0 after 11
    uint8 public constant maxCycle = 11;
    // active stage
    uint8 public nowStage = 2;
    // max stage available
    uint8 public constant maxStage = 7;
    // set up fee each claim token reward
    uint16 public constant claimfee = 100; // 10 div 1000 = 10%
    // set up tax each claim token reward
    uint8 public constant claimtax = 11; // 11 div 1000 = 1.1%
    uint64 public tronRate;    // 1 IDR = xxx trx div 1000000 (6 decimal places)
    // uint256 public flatRate;    
    DegreeCryptoToken public token;

    event Staked(address staker, uint256 amount);
    event ImportStaked(address staker, uint256 amount);
    event Unstaked(address staker, uint256 amount);
    event ClaimedReward(address staker, uint256 reward);
    event ChangeContractOwner(address staker);
    event ChangeTronRate(uint256 amount);
    event ChangeFirstStakingFee(uint256 amount);
    event ChangeMinerPrice(uint256 price, uint8 typeminer);
    event ChangeAdministratorStatus(address adminAddr, bool status);

    modifier onlyOwner() {
        require(msg.sender == owner, "ACCESS_DENIED");
        _;
    }

    modifier onlyAdmin() {
        require(isAdministrator[msg.sender], "ADMIN_ONLY");
        _;
    }

    bool public isOpenImport = true;
    // check import still allowed
    modifier openImport() {
        require(isOpenImport, "IMPORT_CLOSED");
        _;
    }

    constructor(address tokenAddress, address addrfeeinp, address addrtaxinp, address payable addrminerfeeinp, address payable addrfirststakingfeeinp) {
        require(addrfeeinp != address(0), "Invalid address");
        require(addrtaxinp != address(0), "Invalid address");
        require(addrminerfeeinp != address(0), "Invalid address");
        require(addrfirststakingfeeinp != address(0), "Invalid address");
        
        owner = msg.sender;
        token = DegreeCryptoToken(tokenAddress);
        addrfee = addrfeeinp;
        addrtax = addrtaxinp;
        addrminerfee = addrminerfeeinp;
        addrfirststakingfee = addrfirststakingfeeinp;

        rewardPercentage[1] = 375;  // 375 div 10000 = 3.75%
        rewardPercentage[2] = 300;  // 300 div 10000 = 3%
        rewardPercentage[3] = 250;  // 250 div 10000 = 2.5%
        rewardPercentage[4] = 200;  // 200 div 10000 = 2%
        rewardPercentage[5] = 150;  // 150 div 10000 = 1.5%
        rewardPercentage[6] = 100;  // 100 div 10000 = 1%
        rewardPercentage[7] = 50;  // 50 div 10000 = 0.5%

        stageSchedule[1] = 1680282001;  // Saturday, April 1, 2023 0:00:01 AM GMT+07:00
        stageSchedule[2] = 1743354001;  // Monday, March 31, 2025 0:00:01 AM GMT+07:00
        stageSchedule[3] = 1806426001;  // Wednesday, March 31, 2027 0:00:01 AM GMT+07:00
        stageSchedule[4] = 1869498001;  // Friday, March 30, 2029 0:00:01 AM GMT+07:00
        stageSchedule[5] = 1932570001;  // Sunday, March 30, 2031 0:00:01 AM GMT+07:00
        stageSchedule[6] = 1995642001;  // Tuesday, March 29, 2033 0:00:01 AM GMT+07:00
        stageSchedule[7] = 2058714001;  // Thursday, March 29, 2035 0:00:01 AM GMT+07:00

        uint256 decimaldigit = 10 ** uint256(token.decimals());
        // max staking by type
        maxStaking[1] = 10 * decimaldigit;
        maxStaking[2] = 50 * decimaldigit;
        maxStaking[3] = 200 * decimaldigit;
        // miner pcice by type (IDR currency)
        setupMinerPrice[1] = 1650000;
        setupMinerPrice[2] = 7770000;
        setupMinerPrice[3] = 31080000;

        firststakingfee = 50000;
    }

    //update stage when now time > schedule and nowstage < maxstage
    function _checkStage() internal virtual {
        if((nowStage < maxStage) && (block.timestamp > stageSchedule[nowStage])) {
            nowStage = nowStage + 1;
        }
    }

    // calc reward
    function _calcReward(address staker) internal view returns (uint256){
        uint256 dailyReward = (stakers[staker].amountStaked * rewardPercentage[nowStage]) / (10000);
        return dailyReward;
    }

    function _calcFirstStakingFee() internal view returns (uint256){
        uint256 resFee = (firststakingfee * 1000000 * tronRate) / 1000000;
        return resFee;
    }

    function _calcMinerClaimPayout(address staker) internal view returns (uint256){
        uint256 claimPayout = ((minerPrice[staker] * 1000000 * tronRate) / 1000000) / maxCycle; // tron rate 6 decimal point
        return claimPayout;
    }

    function _calcResMinerClaimPayout(address staker) internal view returns (uint256){
        uint256 nextshare = stakers[staker].lastRewardTime + rewardInterval;
        uint256 payoutLeft;
        if(minerRoundCycle[staker] > 0 && minerCycle[staker] == 0 && block.timestamp < nextshare) {
            payoutLeft = 0;
        } else {
            uint256 minerClaimPayout = _calcMinerClaimPayout(staker);
            payoutLeft = (maxCycle - minerCycle[staker]) * minerClaimPayout;
         }        
        return payoutLeft;
    }

    function _burnStaker(address staker) internal virtual {
        uint256 amount = stakers[staker].amountStaked + pendingStaking[staker];
        uint256 toburn = 0;
        uint256 totallocked = (stakers[staker].lockAmount) + (stakers[staker].lockSetup);
        if(amount <= totallocked) {
            // burn amount
            toburn = amount;
            require(token.burn(amount), "Failed staker burned");
        } else {
            // transfer rest token
            require(token.transfer(staker, (amount - totallocked)), "Failed transfer token!");
            toburn = totallocked;
            // burn lock
            require(token.burn(toburn), "Failed staker burned");
        }

        totalStaked = totalStaked - toburn;
        
        // reset all data
        stakers[staker].status = 0;
        stakers[staker].lockAmount = 0;
        stakers[staker].amountStaked = 0;
        stakers[staker].lastRewardTime = 0;
        stakers[staker].stakedTimestamp = 0;
        stakers[staker].minerBurnedTimestamp = 0;

        pendingStaking[staker] = 0;

        stakerMinted[staker] = 0;
        minerLastPayout[staker] = 0;

        minerCycle[staker] = 0;
        minerRoundCycle[staker] = 0;

        oldStaker[staker] = false;
        importStaker[staker] = false;
        oldStakerValidUntil[staker] = 0;
    }

    function calcFirstStakingFee() public view returns (uint256){
        return _calcFirstStakingFee();
    }

    function calcMinerClaimPayout() public view returns (uint256){
        require(minerPrice[msg.sender] > 0, "Miner price not set");
        return _calcMinerClaimPayout(msg.sender);
    }

    function calcResMinerClaimPayout() public view returns (uint256){
        require(minerPrice[msg.sender] > 0, "Miner price not set");
        uint256 payoutLeft = _calcResMinerClaimPayout(msg.sender);
        return payoutLeft;
    }

    // do stake
    function stake(uint256 amount) payable public returns (bool) {
        uint256 allowance = token.allowance(msg.sender, address(this));
        // validate allowance
        require(allowance >= amount, "Invalid allowance");
        require(stakers[msg.sender].status<=2, "Staker stoped/burned");

        if(!(stakers[msg.sender].status == 2 && minerCycle[msg.sender] == 11) && stakers[msg.sender].amountStaked > 0) {
            require(block.timestamp <= (stakers[msg.sender].lastRewardTime + rewardInterval), "There are rewards that have not been claimed");
        }

        if(stakers[msg.sender].minerBurnedTimestamp > 0 && block.timestamp >= stakers[msg.sender].minerBurnedTimestamp) {
            _burnStaker(msg.sender);
        }

        // amount gt 0
        require(amount > 0, "Amount to stake must be greater than 0");
        // tokenSuply + amount should be less than maxSupply
        require((token.totalSupply() + amount) < token.maxSupply(), "Amount to stake must be less than maxSupply");
        // amountStaked+amount lt or the same with maxStaking
        if(stakers[msg.sender].amountStaked == 0) {
            minerType[msg.sender] = 1;
        }
        require((stakers[msg.sender].amountStaked + pendingStaking[msg.sender] + amount) <= maxStaking[minerType[msg.sender]], string(abi.encodePacked("Maximum staking ", maxStaking[minerType[msg.sender]])));

        _checkStage();

        // staking for the first time
        if(stakers[msg.sender].amountStaked==0 && minerCycle[msg.sender]==0) {
            minerFirstTimeFee[msg.sender] = _calcFirstStakingFee();
        }

        // pay only once every round cycle
        if(minerFirstTimeFee[msg.sender] > 0 && minerCycle[msg.sender] == 0) {
            addrfirststakingfee.transfer(minerFirstTimeFee[msg.sender]);
            minerFirstTimeFee[msg.sender] = 0;
        }        
        
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        // if amount staked == 0
        if(stakers[msg.sender].amountStaked>0) {
            pendingStaking[msg.sender] = pendingStaking[msg.sender] + amount;
            totalPendingStaked = totalPendingStaked + amount;
            stakers[msg.sender].minerBurnedTimestamp = 0;
            // miner status unstaked   
            if(stakers[msg.sender].status == 2) {
                // change miner status to 1
                stakers[msg.sender].status = 1;
                stakers[msg.sender].stakedTimestamp = block.timestamp;
                stakers[msg.sender].lastRewardTime = block.timestamp;
                // minerCycle start from 0
                minerCycle[msg.sender] = 0;
                minerRoundCycle[msg.sender] = 0;
                minerPrice[msg.sender] = setupMinerPrice[minerType[msg.sender]];
            }            
        } else {
            minerPrice[msg.sender] = setupMinerPrice[minerType[msg.sender]];
            stakers[msg.sender].lockSetup = 4000000000000000000;
            stakers[msg.sender].lockAmount = 0;

            stakers[msg.sender].stakedTimestamp = block.timestamp;
            
            stakers[msg.sender].minerBurnedTimestamp = 0;
            
            stakers[msg.sender].status = 1;
            stakers[msg.sender].amountStaked = amount;
            stakers[msg.sender].lastRewardTime = block.timestamp;
            totalStaked = totalStaked + amount;
        }

        emit Staked(msg.sender, amount);
        return true;
    }

    function unstake() payable public returns (bool) {
        require(stakers[msg.sender].status==1, "Miner not active");
        require(stakers[msg.sender].amountStaked>0, "No staking available");

        _checkStage();

        if(oldStaker[msg.sender]) {
            // minerCycle[msg.sender] = 0;
            // minerFirstTimeFee[msg.sender] = _calcFirstStakingFee();
            oldStaker[msg.sender] = false;
        } else {
            // calculate the remaining miner fees that must be paid
            uint256 payoutLeft = _calcResMinerClaimPayout(msg.sender);

            addrminerfee.transfer(payoutLeft);
            minerLastPayout[msg.sender] = payoutLeft;
        }

        // set lock token 
        uint256 amountToLocked = stakers[msg.sender].lockAmount + stakers[msg.sender].lockSetup;
        uint256 amountToClaim = stakers[msg.sender].amountStaked + pendingStaking[msg.sender];
        require(amountToClaim > amountToLocked, "Staked amount less than locked staking!");
        
        uint256 amount = amountToClaim - amountToLocked;
        require(token.transfer(msg.sender, amount), "Transfer failed");

        // time allowed to burn miner (burnedDuration)
        stakers[msg.sender].minerBurnedTimestamp = block.timestamp + burnedDuration;

        // reset data
        totalStaked = totalStaked - amount;
        totalPendingStaked = totalPendingStaked - pendingStaking[msg.sender];
        pendingStaking[msg.sender] = 0;
        stakers[msg.sender].status = 2;
        stakers[msg.sender].lockAmount = amountToLocked;
        stakers[msg.sender].amountStaked = amountToLocked;

        emit Unstaked(msg.sender, amount);
        return true;
    }

    function claimReward() payable public returns (bool) {
        require(stakers[msg.sender].status==1 || stakers[msg.sender].status==2, "Staker status not active");
        if(stakers[msg.sender].minerBurnedTimestamp > 0 && block.timestamp >= stakers[msg.sender].minerBurnedTimestamp) {
            revert("Staking burned duration exceeded");
        }
        require(block.timestamp >= (stakers[msg.sender].lastRewardTime + rewardInterval), "Cannot claim reward before interval");

        _checkStage();

        if(stakers[msg.sender].status==2) {
            require(minerCycle[msg.sender] < maxCycle, "Miner unstaked. Max cycle exceeded");
            minerCycle[msg.sender] = minerCycle[msg.sender] + 1;
        } else {
            // for oldstaker only
            if(oldStaker[msg.sender]) {                
                // change oldstaker status to false when now > minervaliduntil
                if(block.timestamp > oldStakerValidUntil[msg.sender]) {
                    oldStaker[msg.sender] = false;
                    minerCycle[msg.sender] = 0;
                    minerRoundCycle[msg.sender] = 0;
                    oldStakerValidUntil[msg.sender] = 0;
                }

                minerCycle[msg.sender] = minerCycle[msg.sender] + 1;
                if(minerCycle[msg.sender] >= maxCycle) {
                    oldStaker[msg.sender] = false;
                    oldStakerValidUntil[msg.sender] = 0;
                    minerCycle[msg.sender] = 0;
                    minerFirstTimeFee[msg.sender] = _calcFirstStakingFee();
                    minerRoundCycle[msg.sender] = minerRoundCycle[msg.sender] + 1;
                    minerPrice[msg.sender] = setupMinerPrice[minerType[msg.sender]];
                }
            } else if(!oldStaker[msg.sender]) {
                // only new staker
                // miner payouts every claim
                // transfer trx to addrminerfee
                uint256 minerClaimPayout = _calcMinerClaimPayout(msg.sender);

                require(msg.sender.balance >= minerClaimPayout, "Insufficient balance.");
                addrminerfee.transfer(minerClaimPayout);
                minerLastPayout[msg.sender] = minerClaimPayout;
                minerCycle[msg.sender] = minerCycle[msg.sender] + 1;
                if(minerCycle[msg.sender]>=maxCycle) {
                    minerCycle[msg.sender] = 0;
                    minerFirstTimeFee[msg.sender] = _calcFirstStakingFee();
                    minerRoundCycle[msg.sender] = minerRoundCycle[msg.sender] + 1;
                    minerPrice[msg.sender] = setupMinerPrice[minerType[msg.sender]];
                }
            }
        }

        uint256 dailyReward = _calcReward(msg.sender);
        uint256 amountfee = dailyReward * (claimfee) / (1000); // calc fee 10%
        uint256 amounttax = dailyReward * (claimtax) / (1000); // calc tax 1.1%
        uint256 reward = dailyReward - (amountfee) - (amounttax);
        require(reward > 0, "Reward must be greater than 0");
        // mint for reward staker
        require(token.mint(msg.sender, reward), "Reward transfer failed");
        // mint for fee
        require(token.mint(addrfee, amountfee), "Reward fee transfer failed");
        // mint for tax
        require(token.mint(addrtax, amounttax), "Reward tax transfer failed");
        stakerMinted[msg.sender] = stakerMinted[msg.sender] + dailyReward;
        stakers[msg.sender].lastRewardTime = (stakers[msg.sender].lastRewardTime) + (rewardInterval);

        // if available pending staking
        if(pendingStaking[msg.sender] > 0) {
            stakers[msg.sender].amountStaked = (stakers[msg.sender].amountStaked) + (pendingStaking[msg.sender]);
            totalStaked = totalStaked + (pendingStaking[msg.sender]);
            totalPendingStaked = totalPendingStaked - (pendingStaking[msg.sender]);
            pendingStaking[msg.sender] = 0;
        }

        emit ClaimedReward(msg.sender, reward);
        return true;
    }

    function importOldStaker(address staker, uint8 xstatus, uint8 typeminer, uint256 locksetup, uint256 lockAmount, uint256 stakedTimestamp, uint256 amountStaked, uint256 pendingStaked, uint256 lastReward, uint256 minervaliduntil, uint8 minercycle) public onlyAdmin openImport returns (bool) {
        require(typeminer>=1 && typeminer<=3, "Invalid miner type");
        require(xstatus==1, "Status not running");
        require(stakers[staker].status==0, "Already running");

        // transfer from admin to staking smartcontact
        require(token.transferFrom(msg.sender, address(this), amountStaked), "Transfer failed");

        oldStaker[staker] = true;
        importStaker[staker] = true;
        oldStakerValidUntil[staker] = minervaliduntil;

        // set miner price
        minerType[staker] = typeminer;
        minerPrice[staker] = setupMinerPrice[typeminer];

        stakers[staker].status = xstatus;
        
        stakers[staker].lockSetup = locksetup;
        stakers[staker].lockAmount = lockAmount;
        stakers[staker].stakedTimestamp = stakedTimestamp;
        stakers[staker].minerBurnedTimestamp = 0;

        stakers[staker].amountStaked = amountStaked;
        stakers[staker].lastRewardTime = lastReward;
        totalStaked = totalStaked + amountStaked;

        pendingStaking[staker] = pendingStaked;
        totalPendingStaked = totalPendingStaked + pendingStaked;

        minerCycle[staker] = minercycle;

        emit ImportStaked(staker, amountStaked);
        return true;
    }

    function burnStaker(address staker) public onlyOwner returns (bool) {
        require(stakers[staker].minerBurnedTimestamp > 0 && block.timestamp>stakers[staker].minerBurnedTimestamp, "It's not time to burn yet");
        _burnStaker(staker);
        return true;
    }

    // set 1 IDR = xxx tron div 1000000 (6 decimal places)
    function setTronRate(uint64 rateTron) public onlyOwner returns (bool) {
        require(rateTron > 0, "Zero rate");
        tronRate = rateTron;
        emit ChangeTronRate(tronRate);
        return true;
    }
    // IDR Currentcy
    function setFirstStakingFee(uint256 feeFirstStaking) public onlyOwner returns (bool) {
        require(feeFirstStaking > 0, "Zero amount");
        firststakingfee = feeFirstStaking;
        emit ChangeFirstStakingFee(firststakingfee);
        return true;
    }

    // update miner price (IDR Currency)
    function updateMinerPrice(uint256 price, uint8 typeminer) public onlyOwner returns (bool) {
        require(typeminer>=1 && typeminer<=3, "Invalid miner type");
        setupMinerPrice[typeminer] = price;
        emit ChangeMinerPrice(price, typeminer);
        return true;
    }

    function changeAddrFee(address newAddr) public onlyOwner returns (bool) {
        require(newAddr != address(0), "Zero address");
        addrfee = newAddr;
        return true;
    }

    function changeAddrMinerFee(address payable newAddr) public onlyOwner returns (bool) {
        require(newAddr != address(0), "Zero address");
        addrminerfee = newAddr;
        return true;
    }

    function changeContractOwnership(address newOwner) public onlyOwner returns (bool) {
        require(newOwner != address(0), "Zero address");
        owner = newOwner;
        emit ChangeContractOwner(newOwner);
        return true;
    }

    function setAdministrator(address adminAddr, bool status) public onlyOwner returns (bool) {
        require(adminAddr != address(0), "Zero address");
        isAdministrator[adminAddr] = status;
        emit ChangeAdministratorStatus(adminAddr, status);
        return true;
    }

    function closeImport() public onlyOwner returns (bool) {
        require(isOpenImport, "IMPORT_CLOSED");
        isOpenImport = false;
        return true;
    }

    function getStakerInfo(address staker) public view returns (
        uint8 status,   
        uint256 maxStakingx,
        uint256 lockSetup, 
        uint256 lockAmount,
        uint256 amountStaked,
        uint256 lastRewardTime,
        uint256 minerBurnedTimestamp, 
        uint256 rpendingStaking) {
        
        status = stakers[staker].status;   
        maxStakingx = maxStaking[minerType[staker]];
        lockSetup = stakers[staker].lockSetup; 
        lockAmount = stakers[staker].lockAmount;
        amountStaked = stakers[staker].amountStaked;
        lastRewardTime = stakers[staker].lastRewardTime;
        minerBurnedTimestamp = stakers[staker].minerBurnedTimestamp; 
        rpendingStaking = pendingStaking[staker];
    }

    function getAmountStaked(address staker) public view returns (uint256) {
        return stakers[staker].amountStaked;
    }

    function getLastRewardTime(address staker) public view returns (uint256) {
        return stakers[staker].lastRewardTime;
    }

    function getNextRewardTime(address staker) public view returns (uint256) {
        uint256 nextshare;
        if(stakers[staker].lastRewardTime > 0) {
            nextshare = (stakers[staker].lastRewardTime) + (rewardInterval);
        } else {
            nextshare = 0;
        }
        return nextshare;
    }

    function getClaimableReward(address staker) public view returns (uint256) {
        require(stakers[staker].amountStaked > 0, "Staker must have staked a positive amount");
        uint256 elapsedTime = uint256(block.timestamp - stakers[staker].lastRewardTime) / rewardInterval;

        uint256 dailyReward = _calcReward(staker);
        // reward every rewardInterval
        uint256 reward = dailyReward * (elapsedTime);
        return reward;
    }
}

//SourceUnit: dct.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity 0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

contract DegreeCryptoToken is ERC20, Ownable {
    address public immutable admin;
    uint256 public decimaldigit;
    uint256 public maxSupply;
    uint256 public hasburn;
    uint8 public nowStage;
    uint8 public immutable maxStage;

    mapping(uint40 => uint40) public stageSchedule;
    // mapping(uint40 => uint40) public stage_date;

    mapping(uint8 => uint256) public allocationStage;
    mapping(uint8 => uint256) public mintedStage;
    mapping(uint8 => uint256) public availableStage;
    mapping(address => uint256) public addrburned;

    bool public isOpenMinting = true;
    modifier openMinting() {
        require(isOpenMinting, "MINTING_PAUSED");
        _;
    }
    modifier onlyAdmin() {
        require(msg.sender == admin, "NOT_ADMIN");
        _;
    }

    constructor() ERC20("DEGREE CRYPTO TOKEN", "DCT") {
        admin = msg.sender;
        nowStage = 1;
        maxStage = 9;
        decimaldigit = 10 ** uint256(decimals());
        maxSupply = decimaldigit * 7000000;
        hasburn = 0;

        allocationStage[1] = decimaldigit * (300000); //first token created
        allocationStage[2] = decimaldigit * (1050000); // first allocation
        allocationStage[3] = decimaldigit * (840000);
        allocationStage[4] = decimaldigit * (700000);
        allocationStage[5] = decimaldigit * (560000);
        allocationStage[6] = decimaldigit * (420000);
        allocationStage[7] = decimaldigit * (280000);
        allocationStage[8] = decimaldigit * (140000);
        // The rest of the allocation will be mined until it runs out (maxStage)

        availableStage[1] = allocationStage[1];
        availableStage[2] = allocationStage[2];
        availableStage[3] = allocationStage[3];
        availableStage[4] = allocationStage[4];
        availableStage[5] = allocationStage[5];
        availableStage[6] = allocationStage[6];
        availableStage[7] = allocationStage[7];
        availableStage[8] = allocationStage[8];

        // start time stage schedule (365 days * 2)
        stageSchedule[1] = 1617210001;  // Thursday, April 1, 2021 0:00:01 AM GMT+07:00
        stageSchedule[2] = 1617210001;  // Thursday, April 1, 2021 0:00:01 AM GMT+07:00
        stageSchedule[3] = 1680282001;  // Saturday, April 1, 2023 0:00:01 AM GMT+07:00
        stageSchedule[4] = 1743354001;  // Monday, March 31, 2025 0:00:01 AM GMT+07:00
        stageSchedule[5] = 1806426001;  // Wednesday, March 31, 2027 0:00:01 AM GMT+07:00
        stageSchedule[6] = 1869498001;  // Friday, March 30, 2029 0:00:01 AM GMT+07:00
        stageSchedule[7] = 1932570001;  // Sunday, March 30, 2031 0:00:01 AM GMT+07:00
        stageSchedule[8] = 1995642001;  // Tuesday, March 29, 2033 0:00:01 AM GMT+07:00
        stageSchedule[9] = 2058714001;  // Thursday, March 29, 2035 0:00:01 AM GMT+07:00
    }

    function mint(address to, uint256 value) external onlyOwner openMinting returns (bool) {
        require(to != address(0), "DCT: transfer to the zero address");
        // if now > next stage => go to next stage
        if(nowStage < maxStage && uint40(block.timestamp) >= stageSchedule[nowStage+1]) {
            if(nowStage < (maxStage-1)) {
                nowStage = nowStage + 1;
                if(availableStage[nowStage-1] >= 0) {
                    allocationStage[nowStage] = allocationStage[nowStage] + (availableStage[nowStage-1]);
                    allocationStage[nowStage-1] = mintedStage[nowStage-1];
                    availableStage[nowStage-1] = 0;
                    availableStage[nowStage] = allocationStage[nowStage];
                }
            } else {
                if(nowStage==(maxStage-1)) {
                    nowStage = nowStage + 1;
                    if((allocationStage[nowStage]==0) && (availableStage[nowStage-1] >= 0)) {
                        uint256 lastsupply = maxSupply - (totalSupply());
                        allocationStage[nowStage] = lastsupply;
                        allocationStage[nowStage-1] = mintedStage[nowStage-1];
                        availableStage[nowStage-1] = 0;
                        availableStage[nowStage] = allocationStage[nowStage];
                    }
                }
            }
        }

        if(nowStage<maxStage) {
            require(mintedStage[nowStage] + (value)<=allocationStage[nowStage], "DCT: ALLOCATION EXCEEDED");
        }
        
        require((totalSupply() + (value)<=maxSupply), "DCT: LIMIT EXCEEDED");

        if(value > 0) {
            mintedStage[nowStage] = mintedStage[nowStage] + (value);
            availableStage[nowStage] = availableStage[nowStage] - (value);
            _mint(to, value);
            return true;
        } else {
            return false;
        }
    }

    function burn(uint256 amount) external returns (bool) {
        require(_msgSender() != address(0), "DCT: burn from the zero address");
        require(balanceOf(_msgSender()) >= amount, "DCT: burn amount exceeds balance");
        maxSupply = maxSupply - (amount);
        hasburn = hasburn + (amount);
        addrburned[_msgSender()] = addrburned[_msgSender()] + (amount);
        _burn(_msgSender(), amount);
        return true;
    }

    function burnFrom(address account, uint256 amount) external virtual returns (bool) {
        require(account != address(0), "DCT: burn from the zero address");
        require(_msgSender() != address(0), "DCT: burn from the zero address");
        require(balanceOf(account) >= amount, "DCT: burn amount exceeds balance");
        maxSupply = maxSupply - (amount);
        hasburn = hasburn + (amount);
        addrburned[_msgSender()] = addrburned[_msgSender()] + (amount);

        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
        return true;
    }

    // allow minting
    function setOpenMinting() external onlyAdmin returns (bool) {
        require(!isOpenMinting, "Minting unpaused");
        isOpenMinting = true;
        return true;
    }
    
    // pause minting
    function setCloseMinting() external onlyAdmin returns (bool) {
        require(isOpenMinting, "Minting paused");
        isOpenMinting = false;
        return true;
    }

    function getStageInfo(uint8 currstage) external view virtual returns (uint256 allocation_s, uint256 available_s, uint256 minted_s, uint256 stage_schec) {
        allocation_s = allocationStage[currstage];
        available_s = availableStage[currstage];
        minted_s = mintedStage[currstage];
        stage_schec = stageSchedule[currstage];
    }

    function nowtimestamp() external view virtual returns (uint40) {
        return uint40(block.timestamp);
    }
}