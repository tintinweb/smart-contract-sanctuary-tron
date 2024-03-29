//SourceUnit: TRON_HIGH.sol

pragma solidity 0.5.10;

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

contract TRON_HIGH {
    using SafeMath for uint256;

    uint256 constant public INVEST_MIN_AMOUNT = 1;

    

    uint256[] public REFERRAL_PERCENTS = [40, 30, 10, 10, 10];
    uint256 constant public MARKETING_FEE = 100;
uint256 constant public BASEROI = 600;

    uint256 constant public PERCENTS_DIVIDER = 1000;
    uint256 constant public AMOUNT_DIVIDER = 1000000; 
    uint256 constant public TIME_STEP = 1 days;

    uint256 public totalUsers;
    uint256 public totalInvested;
    uint256 public totalWithdrawn;
    uint256 public totalDeposits;
    uint256 public backBalance;

    address payable public marketingAddress;

    struct Deposit {
        uint256 amount;
        uint256 withdrawn;
        uint256 start;
    }

    struct User {
        Deposit[] deposits;
        uint256 checkpoint;
        address referrer;
        uint256 bonus;
        uint24[5] refs;

    }

    mapping (address => User) internal users;

    event Newbie(address user);
    event NewDeposit(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RefBonus(address indexed referrer, address indexed referral, uint256 indexed level, uint256 amount);
    event FeePayed(address indexed user, uint256 totalAmount);

    constructor(address payable marketingAddr) public {
        require(!isContract(marketingAddr));
        marketingAddress = marketingAddr;
    }

    function invest(address referrer) public payable {
        require(msg.value >= INVEST_MIN_AMOUNT);

        marketingAddress.transfer(msg.value.mul(MARKETING_FEE).div(PERCENTS_DIVIDER));
        
        emit FeePayed(msg.sender, msg.value.mul(MARKETING_FEE).div(PERCENTS_DIVIDER));

        User storage user = users[msg.sender];

        if (user.referrer == address(0) && users[referrer].deposits.length > 0 && referrer != msg.sender) {
            user.referrer = referrer;
        }

        if (user.referrer != address(0)) {

            address upline = user.referrer;
            for (uint256 i = 0; i < 5; i++) {
                if (upline != address(0)) {
                    uint256 amount = msg.value.mul(REFERRAL_PERCENTS[i]).div(PERCENTS_DIVIDER);
                    users[upline].bonus = users[upline].bonus.add(amount);
                    emit RefBonus(upline, msg.sender, i, amount);
                    users[upline].refs[i]++;

                    upline = users[upline].referrer;
                } else break;
            }

        }
        

        if (user.deposits.length == 0) {
            user.checkpoint = block.timestamp;
            totalUsers = totalUsers.add(1);
            
            emit Newbie(msg.sender);
        }
                user.deposits.push(Deposit(msg.value, 0, block.timestamp));

        totalInvested = totalInvested.add(msg.value);
        totalDeposits = totalDeposits.add(1);
        backBalance = backBalance.add(msg.value.div(100).mul(90));

        emit NewDeposit(msg.sender, msg.value);

    }
function Reinvest(uint256 amount) public payable {
        marketingAddress.transfer(amount.mul(MARKETING_FEE).div(PERCENTS_DIVIDER));
        
        emit FeePayed(msg.sender, amount.mul(MARKETING_FEE).div(PERCENTS_DIVIDER));

        User storage user = users[msg.sender]; 
        
                user.deposits.push(Deposit(amount, 0, block.timestamp));

        totalInvested = totalInvested.add(msg.value);
        totalDeposits = totalDeposits.add(1);
        backBalance = backBalance.add(amount.div(100).mul(90));

        emit NewDeposit(msg.sender, amount);

    }


    function withdraw() public {
        User storage user = users[msg.sender];

        uint256 userPercentRate = getUserPercentRate(msg.sender);

        uint256 totalAmount;
        uint256 dividends;
uint256 ReInvestAmount;

        for (uint256 i = 0; i < user.deposits.length; i++) {


                if (user.deposits[i].start > user.checkpoint) {

                    dividends = (user.deposits[i].amount.mul(userPercentRate).div(PERCENTS_DIVIDER))
                        .mul(block.timestamp.sub(user.deposits[i].start))
                        .div(TIME_STEP);

                } else {

                    dividends = (user.deposits[i].amount.mul(userPercentRate).div(PERCENTS_DIVIDER))
                        .mul(block.timestamp.sub(user.checkpoint))
                        .div(TIME_STEP);

                }


                user.deposits[i].withdrawn = user.deposits[i].withdrawn.add(dividends); /// changing of storage data
                totalAmount = totalAmount.add(dividends);

            }
        

        uint256 referralBonus = getUserReferralBonus(msg.sender);
        if (referralBonus > 0) {
            totalAmount = totalAmount.add(referralBonus);
            user.bonus = 0;
        }

        require(totalAmount > 0, "User has no dividends");

        uint256 contractBalance = address(this).balance;
        if (contractBalance < totalAmount) {
            totalAmount = contractBalance;
        }
ReInvestAmount= totalAmount.div(2);
Reinvest(ReInvestAmount);
        user.checkpoint = block.timestamp;

        msg.sender.transfer(totalAmount.div(2));

        totalWithdrawn = totalWithdrawn.add(totalAmount.div(2));

        emit Withdrawn(msg.sender, totalAmount.div(2));

    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getUserPercentRate(address userAddress) public view returns (uint256) {
        return BASEROI;
    }

    function getUserDividends(address userAddress) public view returns (uint256) {
        User storage user = users[userAddress];

        uint256 userPercentRate = getUserPercentRate(userAddress);

        uint256 totalDividends;
        uint256 dividends;

        for (uint256 i = 0; i < user.deposits.length; i++) {

            

                if (user.deposits[i].start > user.checkpoint) {

                    dividends = (user.deposits[i].amount.mul(userPercentRate).div(PERCENTS_DIVIDER))
                        .mul(block.timestamp.sub(user.deposits[i].start))
                        .div(TIME_STEP);

                } else {

                    dividends = (user.deposits[i].amount.mul(userPercentRate).div(PERCENTS_DIVIDER))
                        .mul(block.timestamp.sub(user.checkpoint))
                        .div(TIME_STEP);

                }


                totalDividends = totalDividends.add(dividends);

                /// no update of withdrawn because that is view function

            

        }

        return totalDividends;
    }

    function getUserCheckpoint(address userAddress) public view returns(uint256) {
        return users[userAddress].checkpoint;
    }

    function getUserReferrer(address userAddress) public view returns(address) {
        return users[userAddress].referrer;
    }

    function getUserReferralBonus(address userAddress) public view returns(uint256) {
        return users[userAddress].bonus;
    }

    function getUserAvailable(address userAddress) public view returns(uint256) {
        return getUserReferralBonus(userAddress).add(getUserDividends(userAddress));
    }

    function isActive(address userAddress) public view returns (bool) {
        User storage user = users[userAddress];

        if (user.deposits.length > 0) {
                return true;
            
        }
    }


    function getUserAmountOfDeposits(address userAddress) public view returns(uint256) {
        return users[userAddress].deposits.length;
    }

    function getUserTotalDeposits(address userAddress) public view returns(uint256) {
        User storage user = users[userAddress];

        uint256 amount;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            amount = amount.add(user.deposits[i].amount);
        }

        return amount;
    }

    function getUserTotalWithdrawn(address userAddress) public view returns(uint256) {
        User storage user = users[userAddress];

        uint256 amount;

        for (uint256 i = 0; i < user.deposits.length; i++) {
            amount = amount.add(user.deposits[i].withdrawn);
        }

        return amount;
    }
    function getSiteStats() public view returns (uint, uint, uint) {
        return (totalInvested, totalDeposits, address(this).balance);
        
    }

    function getUserStats(address userAddress) public view returns (uint, uint, uint, uint[4][] memory) {

      
uint[4][] memory deposits = new uint[4][](100);

User storage user = users[userAddress];

        uint256 dividends;
        uint256 userPercentRate = getUserPercentRate(msg.sender);


for(uint256 i = 0; i < user.deposits.length; i++) {
            Deposit storage dep = user.deposits[i];
            
if (user.deposits[i].start > user.checkpoint) {

                    dividends = (user.deposits[i].amount.mul(userPercentRate).div(PERCENTS_DIVIDER))
                        .mul(block.timestamp.sub(user.deposits[i].start))
                        .div(TIME_STEP);

                } else {

                    dividends = (user.deposits[i].amount.mul(userPercentRate).div(PERCENTS_DIVIDER))
                        .mul(block.timestamp.sub(user.checkpoint))
                        .div(TIME_STEP);

                }

                deposits[i][2] = 0;
                deposits[i][3] = dividends;

            
            deposits[i][0] = userPercentRate;
            deposits[i][1] = dep.amount;
        }

        return (getUserTotalDeposits(userAddress), getUserAmountOfDeposits(userAddress), getUserTotalWithdrawn(userAddress), deposits);
    }

    function getUserReferralsStats(address userAddress) public view returns (address, uint256, uint24[5] memory) {
        User storage user = users[userAddress];

        return (user.referrer, user.bonus, user.refs);
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

}