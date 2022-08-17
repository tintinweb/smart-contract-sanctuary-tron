//SourceUnit: OpxStaking.sol

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

interface TRC20 {
    
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    
    function transfer(address recipient, uint256 amount) external returns (bool);
    function governanceTransfer(address owner, address buyer, uint256 numTokens) external returns (bool);
    
}

contract CLUB {

    struct User {
        address referrer;
        uint256 expiration;
        uint256 cyclecount;
    }

    mapping(address => User) public users;
}

contract OPXStaking {
    address public TOKEN_CONTRACT_ADDRESS;
    address public MAIN_CONTRACT_ADDRESS;
    address public owner;
    
    uint256 public firstStakePercent = 130;
    uint256 public initialPercent = 100;
    
    uint256 public tokensPerTrx = 100000000;
    uint256 public minimumStake = 1000000000;

    uint256 public bonus5 = 1;
    uint256 public bonus10 = 2;
    uint256 public bonus15 = 5;
    
    uint256 public immatureUnstakeDeduction = 70;
    uint256 public unstakeFee = 2000000;
    
    uint256[] public arrDays = [15, 30, 45, 60, 90, 120, 365];
    uint256[] public arrPercent = [5, 12, 20, 30, 60, 80, 300];

    struct Stake {
        uint256 amount;
        uint256 trxAmount;
        uint256 percent;
        uint256 timeStaked;
        uint256 numDays;
        uint256 lastWithdraw;
        bool unstaked;
    }
    
    mapping(address => uint256) public stakeCount;
    mapping(address => mapping(uint256 => Stake)) public stakes;
    
    TRC20 internal token20;
    CLUB internal club;
    
    constructor(address _owner, address tokenAddress, address clubAddress) {
        owner = _owner;
        MAIN_CONTRACT_ADDRESS = clubAddress;
        TOKEN_CONTRACT_ADDRESS = tokenAddress;
        
        token20 = TRC20(TOKEN_CONTRACT_ADDRESS);
        club = CLUB(MAIN_CONTRACT_ADDRESS);
    }
    
    function setAddress(uint256 n, address addr) public returns (bool) {
        require(msg.sender == owner);
        if(n == 1) {
            TOKEN_CONTRACT_ADDRESS = addr;
            token20 = TRC20(TOKEN_CONTRACT_ADDRESS);
        }
        else if(n == 2) {
            MAIN_CONTRACT_ADDRESS = addr;
            club = CLUB(MAIN_CONTRACT_ADDRESS);
        }
        return true;
    }

    function getPackages() public view returns (uint[] memory, uint[] memory) {
        return (arrDays, arrPercent);
    }
    
    function addPackage(uint256 nDays, uint256 percent) external returns (bool) {
        require(msg.sender == owner, "Only owner can use this.");
        arrDays.push(nDays);
        arrPercent.push(percent);
        return true;
    }
    
    function removeLastPackage() external returns (bool) {
        require(msg.sender == owner, "Only owner can use this.");
        arrDays.pop();
        arrPercent.pop();
        return true;
    }
    
    function tweakPackage(uint256 index, bool modifyingDays, uint256 value) external returns (bool) {
        require(msg.sender == owner, "Only owner can use this.");
        require(index < arrDays.length, "Index out of bound.");
        if(modifyingDays) {
            arrDays[index] = value;
        }
        else {
            arrPercent[index] = value;
        }
        return true;
    }
    
    function tweakSettings(uint256 index, uint256 value) external returns (bool) {
        require(msg.sender == owner, "Only owner can use this.");
        if(index == 2) {
            firstStakePercent = value;
        }
        else if(index == 3) {
            initialPercent = value;
        }
        else if(index == 4) {
            tokensPerTrx = value;
        }
        else if(index == 5) {
            minimumStake = value;
        }
        else if(index == 6) {
            bonus5 = value;
        }
        else if(index == 7) {
            bonus10 = value;
        }
        else if(index == 8) {
            bonus15 = value;
        }
        else if(index == 9) {
            immatureUnstakeDeduction = value;
        }
        else if(index == 10) {
            unstakeFee = value;
        }
        return true;
    }
    
    function claimable(address sender, uint256 index) public view returns (uint256) {
        Stake memory stake = stakes[sender][index];
        
        uint256 totalTime = stake.numDays * 1 days;
        uint256 timePassed = block.timestamp;
        if(stake.lastWithdraw > 0) {
            timePassed -= stake.lastWithdraw;
        }
        else {
            timePassed -= stake.timeStaked;
        }
        
        return stake.amount * stake.percent / 100 * timePassed / totalTime;
    }
    
    function claim(uint256 index) external returns (bool) {
        require(index < stakeCount[msg.sender], "This stake has not been set yet.");
        
        Stake storage stake = stakes[msg.sender][index];
        
        require(stake.unstaked == false, "This has already been unstaked.");
        require(stake.timeStaked + stake.numDays * 1 days >= block.timestamp, "You can't claim anymore after the staking period. Please unstake to claim the remaining tokens.");
        require((stake.lastWithdraw != 0 ? stake.lastWithdraw : stake.timeStaked) + 1 days <= block.timestamp, "You can only claim once a day.");
        
        uint256 clm = claimable(msg.sender, index);
        token20.transfer(msg.sender, clm);
        
        stake.lastWithdraw = block.timestamp;
        
        emit Claimed(msg.sender, index, clm);
        
        return true;
    }
    
    function unstake(uint256 index) external payable returns (bool) {
        require(msg.value == unstakeFee, "You need to pay the exact unstake fee.");

        require(index < stakeCount[msg.sender], "This stake has not been set yet.");
        
        Stake storage stake = stakes[msg.sender][index];
        
        require(stake.unstaked == false, "This has already been unstaked.");

        if(stake.timeStaked + stake.numDays * 1 days <= block.timestamp) {
            
            uint256 totalTime = stake.numDays * 1 days;
            
            uint256 timePassed;
            if(stake.lastWithdraw > 0) {
                timePassed = stake.timeStaked + totalTime - stake.lastWithdraw;
            }
            else {
                timePassed = totalTime;
            }
            
            uint256 clm = stake.amount * stake.percent / 100 * timePassed / totalTime;
            
            payable(address(uint160(msg.sender))).transfer(stake.trxAmount);
            token20.transfer(msg.sender, clm + stake.amount);
        }
        else {
            uint256 clm = claimable(msg.sender, index);
            payable(address(uint160(msg.sender))).transfer(stake.trxAmount * immatureUnstakeDeduction / 100);
            payable(owner).transfer(stake.trxAmount * (100 - immatureUnstakeDeduction) / 100);
            token20.transfer(msg.sender, clm + (stake.amount * immatureUnstakeDeduction / 100));
        }

        stake.lastWithdraw = block.timestamp;
        stake.unstaked = true;
        
        emit Unstaked(msg.sender, index);
        return true;
    }
    
    function makeStake(uint256 amount, uint256 packageIndex) external payable returns (uint stakeID) {
        
        require(arrDays[packageIndex] > 0, "Invalid package index.");
        
        (, uint256 expiration, uint256 cyclecount) = club.users(msg.sender);
        require(expiration > block.timestamp, "Only members can stake.");
        
        require(amount >= minimumStake, "The minimum exchange is 1000OPX.");
        
        uint256 trxAmount = amount / tokensPerTrx * 1000000;
        require(trxAmount <= msg.value, "You need to pair an equal trx value for the token.");
        
        if(trxAmount < msg.value) payable(address(uint160(msg.sender))).transfer(msg.value - trxAmount);
        
        token20.governanceTransfer(msg.sender, address(this), amount);
        
        stakeID = stakeCount[msg.sender]++;
        Stake storage stake = stakes[msg.sender][stakeID];

        uint256 percent = arrPercent[packageIndex] * (stakeID == 0 ? firstStakePercent : initialPercent ) / 100;
        	
        cyclecount -= 1;
        if(cyclecount >= 15) {
            percent += bonus15;
        }
        else if(cyclecount >= 10) {
            percent += bonus10;
        }
        else if(cyclecount >= 5) {
            percent += bonus5;
        }
        
        stake.amount = amount;
        stake.trxAmount = trxAmount;
        stake.percent = percent;
        stake.timeStaked = block.timestamp;
        stake.numDays = arrDays[packageIndex];
        
        emit Staked(msg.sender, stakeID);
    }
    
    function returnTokenFunds() public returns (bool) {
        require(owner == msg.sender);
        token20.transfer(msg.sender, token20.balanceOf(address(this)));
        return true;
    }
    
    event Staked(address indexed staker, uint256 indexed id);
    event Unstaked(address indexed staker, uint256 indexed id);
    event Claimed(address indexed staker, uint256 indexed id, uint256 amount);
}