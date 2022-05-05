//SourceUnit: RebelQueen.sol

pragma solidity 0.5.4;

contract RebelQueen {
    uint[] public REFERRAL_PERCENTS = [50, 30, 20, 10, 10, 5, 5, 5, 5, 10];
    uint public constant PERCENTS_DIVIDER = 1000;
    uint public constant TIME_STEP = 1 days;

    uint public totalUsers;
    uint public totalInvested;

    address payable public ownerWallet;
    address payable public marketingAddress;
    address payable public adminWallet;
    address payable public devAddress;
    address payable public tronQueen;

    struct User {
        uint invested;
        uint withdrawn;
        uint dividends;
        uint refBonus;
        uint reinvest;
        address payable referrer;
        uint32 checkpoint;
    }

    mapping(address => User) internal users;

    event Newbie(address user, address indexed referrer, uint amount);
    event NewDeposit(
        address indexed user,
        address indexed referrer,
        uint256 amount
    );
    event Withdrawn(address indexed user, uint256 amount);
    event Reinvest(address indexed user, uint256 amount);

    constructor(
        address payable devAddr,
        address payable ownerAddr,
        address payable adminAddr,
        address payable marketingAddr,
        address payable tronQueenAddr
    ) public {
        require(
            !isContract(marketingAddr) &&
                !isContract(adminAddr) &&
                !isContract(devAddr) &&
                !isContract(ownerAddr) &&
                !isContract(tronQueenAddr)
        );

        marketingAddress = marketingAddr;
        adminWallet = adminAddr;
        devAddress = devAddr;
        ownerWallet = ownerAddr;
        tronQueen = tronQueenAddr;

        users[msg.sender].invested = 1 trx;
        users[msg.sender].checkpoint = uint32(block.timestamp);
    }
    
    function() external {}

    function invest(address payable referrer) public payable {
        require(msg.value >= 500 trx);

        User storage user = users[msg.sender];

        if (user.referrer == address(0)) {
            require(!isContract(msg.sender), "Invalid account");
            require(users[referrer].invested > 0, "Invalid referrer");
            user.referrer = referrer;
        }

        if (user.referrer != address(0)) {
            address payable upline = user.referrer;
            for (uint256 i = 0; i < 10; i++) {
                if (upline != address(0)) {
                    uint256 amount = (msg.value * REFERRAL_PERCENTS[i]) /
                        PERCENTS_DIVIDER;
                    upline.transfer(amount);
                    users[upline].refBonus += amount;
                    upline = users[upline].referrer;
                } else break;
            }
        }

        if (user.invested == 0) {
            totalUsers = totalUsers + 1;
            emit Newbie(msg.sender, referrer, msg.value);
        } else {
            user.dividends += getUserDividends(msg.sender);
        }

        user.checkpoint = uint32(block.timestamp);
        user.invested += msg.value;
        totalInvested += msg.value;

        payAdminOnDep(msg.value);
        tronQueen.transfer((msg.value * 2) / 100);

        emit NewDeposit(msg.sender, user.referrer, msg.value);
    }

    function withdraw() public {
        User storage user = users[msg.sender];

        uint dividends = user.dividends + getUserDividends(msg.sender);
        require(dividends >= 200 trx, "Ops!");

        if (dividends + user.withdrawn > user.invested * 3)
            dividends = user.invested * 3 - user.withdrawn;

        uint contractBalance = address(this).balance;
        if (contractBalance < dividends) {
            dividends = contractBalance;
        }

        user.checkpoint = uint32(block.timestamp);
        user.dividends = 0;
        user.withdrawn += (dividends * 75) / 100;

        msg.sender.transfer((dividends * 75) / 100);

        payAdminOnWithdrawal(dividends);

        emit Withdrawn(msg.sender, dividends);
    }

    function reinvest() public {
        User storage user = users[msg.sender];

        uint dividends = user.dividends + getUserDividends(msg.sender);
        require(dividends >= 200 trx, "Ops!");

        if (dividends + user.withdrawn > user.invested * 3)
            dividends = user.invested * 3 - user.withdrawn;

        user.checkpoint = uint32(block.timestamp);
        user.invested += dividends;
        user.dividends = 0;
        user.withdrawn += dividends;
        user.reinvest += dividends;

        payAdminOnDep(dividends);
        tronQueen.transfer((dividends * 5) / 100);

        emit Reinvest(msg.sender, dividends);
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getUserDividends(address userAddress) public view returns (uint) {
        User storage user = users[userAddress];
        return
            (user.invested * 10 * (block.timestamp - user.checkpoint)) /
            PERCENTS_DIVIDER /
            TIME_STEP;
    }

    function getUser(address _addr)
        public
        view
        returns (
            uint,
            uint,
            uint,
            uint,
            uint,
            uint32,
            address payable
        )
    {
        return (
            users[_addr].invested,
            users[_addr].withdrawn,
            users[_addr].dividends,
            users[_addr].refBonus,
            users[_addr].reinvest,
            users[_addr].checkpoint,
            users[_addr].referrer
        );
    }

    function payAdminOnDep(uint _amount) private {
        devAddress.transfer((_amount * 3) / 100);
        adminWallet.transfer((_amount * 3) / 100);
        ownerWallet.transfer((_amount * 3) / 100);
        marketingAddress.transfer((_amount * 1) / 100);
    }

    function payAdminOnWithdrawal(uint _amount) private {
        devAddress.transfer((_amount * 2) / 100);
        adminWallet.transfer((_amount * 2) / 100);
        ownerWallet.transfer((_amount * 2) / 100);
        marketingAddress.transfer((_amount * 1) / 100);
        tronQueen.transfer((_amount * 2) / 100);
    }

    function getUserReferrer(address userAddress)
        public
        view
        returns (address)
    {
        return users[userAddress].referrer;
    }

    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }

    function getUserData(address _addr) external view returns (uint checkpoint, uint invested, uint withdrawn, uint dividends, uint refBonus, uint reinvests) {
        User storage u = users[_addr];
        checkpoint = u.checkpoint;
        invested = u.invested;
        withdrawn = u.withdrawn;
        dividends = u.dividends + getUserDividends(_addr);
        refBonus = u.refBonus;
        reinvests = u.reinvest;
    }

    function getContractData() external view returns (uint usersCount, uint invested, uint balance) {
        usersCount=totalUsers;
        invested = totalInvested;
        balance = getContractBalance();
    }
}