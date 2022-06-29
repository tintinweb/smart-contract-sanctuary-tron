//SourceUnit: Contract.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

interface ITRC20 {
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract Ownable {
    address public owner;
    address public newOwner;

    event OwnershipChange(address indexed _from, address indexed _to);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "is not owner");
        _;
    }

    function OwnershipTransfer(address _newOwner)
        external
        onlyOwner
        returns (bool)
    {
        require(_newOwner != address(0), "invalid address");
        newOwner = _newOwner;
        return true;
    }

    function OwnershipReceiving() external returns (bool) {
        require(msg.sender == newOwner, "must be new owner");
        emit OwnershipChange(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
        return true;
    }
}

contract EapDaoCT is Ownable {
    using SafeMath for uint256;

    ITRC20 public token;
    uint256 public totalPlan;
    Plan[] public plans;

    struct Plan {
        uint256 id;
        address insured;
        address beneficiary;
        bool insuredVerify;
        bool beneficiaryVerify;
        uint256 amount;
        State state;
    }

    enum State {
        Start,
        Payment,
        Refund,
        ArbitrationPayment,
        ArbitrationRefund
    }

    event CreateLog(
        uint256 indexed id,
        address indexed insured,
        address indexed beneficiary,
        uint256 amount
    );
    event PaymentLog(uint256 indexed id);
    event RefundLog(uint256 indexed id);
    event ArbitrationLog(uint256 indexed id, string description);

    constructor(ITRC20 _token) {
        token = _token;
    }

    function FeeRate(uint256 _amount) internal pure returns (uint256) {
        return _amount.mul(300).div(10000);
    }

    function Create(address _to_address, uint256 _amount)
        external
        returns (bool)
    {
        require(
            msg.sender != _to_address && msg.sender != address(this),
            "must be different address"
        );
        require(_amount >= 1000000, "amount must be >= 1usdt");

        bool isTransfer = token.transferFrom(
            msg.sender,
            address(this),
            _amount
        );

        if (!isTransfer) return false;

        uint256 _feeRateAmount = FeeRate(_amount);

        token.transfer(owner, _feeRateAmount);

        plans.push(
            Plan({
                id: totalPlan,
                insured: msg.sender,
                beneficiary: _to_address,
                insuredVerify: false,
                beneficiaryVerify: false,
                amount: _amount - _feeRateAmount,
                state: State.Start
            })
        );

        emit CreateLog(
            totalPlan,
            msg.sender,
            _to_address,
            _amount - _feeRateAmount
        );
        totalPlan += 1;
        return true;
    }

    function Confirm(uint256 _id) external returns (bool) {
        Plan storage _plan = plans[_id];

        require(_plan.state == State.Start, "state must be start");
        require(
            msg.sender == _plan.insured || msg.sender == _plan.beneficiary,
            "not guarantor or beneficiary"
        );

        if (msg.sender == _plan.insured) {
            _plan.state = State.Payment;

            token.transfer(_plan.beneficiary, _plan.amount);
            emit PaymentLog(_id);

            return true;
        } else if (msg.sender == _plan.beneficiary) {
            _plan.state = State.Refund;

            token.transfer(_plan.insured, _plan.amount);
            emit RefundLog(_id);

            return true;
        }
        return false;
    }

    function AddressConfirm(uint256 _id) external returns (bool) {
        Plan storage _plan = plans[_id];
        require(
            msg.sender == _plan.insured || msg.sender == _plan.beneficiary,
            "not guarantor or beneficiary"
        );
        require(_plan.state == State.Start, "state must be start");

        if (msg.sender == _plan.insured && _plan.insuredVerify == false) {
            _plan.insuredVerify = true;
            return true;
        } else if (
            msg.sender == _plan.beneficiary && _plan.beneficiaryVerify == false
        ) {
            _plan.beneficiaryVerify = true;
            return true;
        }
        return false;
    }

    function Arbitration(
        uint256 _id,
        string memory _description,
        State _state
    ) external onlyOwner returns (bool) {
        Plan storage _plan = plans[_id];
        require(_plan.state == State.Start, "state must be start");

        uint256 _feeRateAmount = FeeRate(_plan.amount);
        uint256 _actualAmount = _plan.amount - _feeRateAmount;

        if (_state == State.ArbitrationRefund) {
            require(_plan.insuredVerify, "insured must be verify");

            _plan.state = State.ArbitrationRefund;
            _plan.amount = _actualAmount;

            token.transfer(msg.sender, _feeRateAmount);
            token.transfer(_plan.insured, _actualAmount);

            emit ArbitrationLog(_id, _description);
            return true;
        } else if (_state == State.ArbitrationPayment) {
            require(_plan.beneficiaryVerify, "beneficiary must be verify");

            _plan.state = State.ArbitrationPayment;
            _plan.amount = _actualAmount;

            token.transfer(msg.sender, _feeRateAmount);
            token.transfer(_plan.beneficiary, _actualAmount);

            emit ArbitrationLog(_id, _description);
            return true;
        }

        return false;
    }
}