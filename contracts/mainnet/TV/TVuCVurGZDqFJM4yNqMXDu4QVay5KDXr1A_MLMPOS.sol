//SourceUnit: MLMPOS.sol

pragma solidity 0.5.14;

contract MLMPOS {
	uint256 constant private DEPOSIT_MIN_AMOUNT = 1e6;// 1 TRX
    uint256 constant private DEPOSIT_MAX_AMOUNT = 1e15;// 1,000,000,000 TRX
    uint8[10] private PERCENT_REFS;

    uint256 private balance;
    uint256 private currentdeposit;
    uint256 private depositscount;
    uint256 private totalusers;
    uint256 private totaldeposit;
    uint256 private totalstaking;
    uint8 private limitdividend;

    address payable private root;
    address payable private admin;
    address payable private stak;

    struct User {
    	address upline;
        uint256 fundsavailable;
        uint256 totalinvest;
        uint256 totalreferrals;
        uint256 totalrewards;
        uint256 totaldividends;
        uint256[] depositids;
    }

    struct Deposit {
        address investor;
        uint256 amount;
        uint8 reinvest;
        uint40 start;
        uint40 close;
    }

    mapping (address => User) internal users;
    mapping (uint256 => Deposit) internal deposits;

    event Upline(address indexed addr, address indexed upline);
    event Staking(address indexed addr, uint256 amount);
    event Invest(address indexed addr, uint256 amount);
    event Withdrawal(address indexed addr, uint256 amount);
    event Reinvest(address indexed addr, uint256 amount);
    event Reward(address indexed addr, address indexed upline, uint8 indexed line, uint256 amount);

    constructor(address payable _root, address payable _admin, address payable _stak) public {
        root = _root;
        admin = _admin;
        stak = _stak;
        PERCENT_REFS = [10,5,3,2,2,2,2,2,1,1];// %
        currentdeposit = 1;
        limitdividend = 10;
    }

    function deposit(address upline) payable external {
        address _addr = msg.sender;
        require(!_addr.isContract, 'This is a contract');
        uint256 _amount = msg.value;
        require(_amount >= DEPOSIT_MIN_AMOUNT && _amount <= DEPOSIT_MAX_AMOUNT, 'Error amount');
        User storage u = users[_addr];
        address _upline = upline;
        User storage up = users[_upline];
        bool _newuser = false;
        if(u.depositids.length == 0){
            if(u.upline == address(0) && _addr != _upline && up.depositids.length > 0){
                u.upline = _upline;

                emit Upline(_addr, _upline);
            }
            require(u.upline != address(0) || _addr == root, 'Error upline');
            _newuser = true;
            totalusers++;
        }
        depositscount++;
        deposits[depositscount] = Deposit(_addr, _amount, 0, uint40(block.timestamp), 0);
        u.depositids.push(depositscount);
        u.totalinvest += _amount;
        totaldeposit += _amount;

        emit Invest(_addr, _amount);

        uint8 _dper = 0;
        uint8 _per;
        _upline = u.upline;
        for(uint8 i = 0; i < 10; i++) {
            if(_upline == address(0)) break;
            _per = PERCENT_REFS[i];
            up = users[_upline];
            up.fundsavailable += _amount*_per/100;
            up.totalrewards += _amount*_per/100;
            _dper += _per;
            if(_newuser == true) up.totalreferrals++;
            _upline = up.upline;

            emit Reward(_addr, _upline, i+1, _amount);
        }
        root.transfer(_amount*5/100);
        admin.transfer(_amount*5/100);
        stak.transfer(_amount*50/100);
        balance += (_amount - _amount*(_dper+60)/100);
        dividends();
    }

    function withdrawal() external {
        uint256 _balance = address(this).balance;
        require(_balance > 0, 'Balance is zero');
        address payable _addr = msg.sender;
        User storage u = users[_addr];
        uint256 _amount = u.fundsavailable;
        if(_balance < _amount) _amount = _balance;
        _addr.transfer(_amount);
        u.fundsavailable -= _amount;

        emit Withdrawal(_addr, _amount);
    }

    function staking() payable external {
        uint256 _amount = msg.value;
        require(_amount > 0, 'Error amount');
        balance += _amount;
        totalstaking += _amount;

        emit Staking(msg.sender, _amount);
    }

    function dividends() public {
        if(balance > 0){
            Deposit storage _dep = deposits[currentdeposit];
            User storage u = users[_dep.investor];
            address _upline = u.upline;
            User storage up = users[_upline];
            uint256 _amount;
            uint256 _fee;
            uint8 _dper;
            uint8 _per;
            uint8 _limitdividend = limitdividend;
            for(uint8 i = 0;i < _limitdividend;i++){
                _amount = _dep.amount;
                if(_amount*4 > balance) break;
                balance -= _amount*3;
                u.fundsavailable += _amount*3;
                u.totaldividends += _amount*3;
                _dep.close = uint40(block.timestamp);
                if(_dep.reinvest + 1 <= 10){
                    depositscount++;
                    deposits[depositscount] = Deposit(_dep.investor, _amount, _dep.reinvest + 1 , uint40(block.timestamp), 0);
                    u.depositids.push(depositscount);

                    emit Reinvest(_dep.investor, _amount);

                    _dper = 0;
                    for(uint8 j = 0;j < 10;j++) {
                        if(_upline == address(0)) break;
                        _per = PERCENT_REFS[j];
                        up = users[_upline];
                        up.fundsavailable += _amount*_per/100;
                        up.totalrewards += _amount*_per/100;
                        _dper += _per;
                        _upline = up.upline;

                        emit Reward(_dep.investor, _upline, j+1, _amount);
                    }
                    _fee += _amount;
                    balance -= _amount*(_dper+60)/100;
                }
                if(currentdeposit + 1 > depositscount) break;
                currentdeposit++;
                _dep = deposits[currentdeposit];
                u = users[_dep.investor];
            }
            if(_fee > 0){
                root.transfer(_fee*5/100);
                admin.transfer(_fee*5/100);
                stak.transfer(_fee*50/100);
            }
        }
    }

    function infoContract() external view returns(
        uint256 _balance,
        uint256 _currentdeposit,
        uint256 _depositscount,
        uint256 _totalusers,
        uint256 _totaldeposit,
        uint256 _totalstaking
    ) {
        return (
        balance,
        currentdeposit,
        depositscount,
        totalusers,
        totaldeposit,
        totalstaking
        );
    }

    function infoUser(address addr) external view returns(
        address _upline,
        uint256 _depositcount,
        uint256 _fundsavailable,
        uint256 _totalinvest,
        uint256 _totalreferrals,
        uint256 _totalrewards,
        uint256 _totaldividends
    ) {
        User memory u = users[addr];
        return (
        u.upline,
        u.depositids.length,
        u.fundsavailable,
        u.totalinvest,
        u.totalreferrals,
        u.totalrewards,
        u.totaldividends
        );
    }

    function infoDeposits(address addr) external view returns(
        uint256[] memory _id,
        uint256[] memory _amount,
        uint8[] memory _reinvest,
        uint40[] memory _start,
        uint40[] memory _close
    ){
        User memory u = users[addr];
        uint256 _depositcount =  u.depositids.length;
        uint256[] memory id = new uint256[](_depositcount);
        uint256[] memory amount = new uint256[](_depositcount);
        uint8[] memory reinvest = new uint8[](_depositcount);
        uint40[] memory start = new uint40[](_depositcount);
        uint40[] memory close = new uint40[](_depositcount);
        Deposit memory d;
        for(uint256 i = 0; i < _depositcount; i++){
            id[i] = u.depositids[i];
            d = deposits[id[i]];
            amount[i] = d.amount;
            reinvest[i] = d.reinvest;
            start[i] = d.start;
            close[i] = d.close;
        }
        return (
        id,
        amount,
        reinvest,
        start,
        close
        );
    }

    function calculateDeposit(uint256 id) external view returns(uint256 amount){
        uint256 _start = currentdeposit;
        if(id < _start || id > depositscount) return 0;
        if(id == _start) {
            return balance < deposits[id].amount*4?deposits[id].amount*4 - balance:0;
        }
        uint256 _amount = 0;
        uint256 _end = id + 1;
        for(uint256 i = _start;i < _end;i++){
            _amount += deposits[i].amount*4;
        }
        return balance < _amount?_amount - balance:0;
    }

    function setRoot(address payable addr) external{
        require(msg.sender == root && addr != address(0), 'Only root');
        root = addr;
    }
    function setAdmin(address payable addr) external{
        require(msg.sender == admin && addr != address(0), 'Only admin');
        admin = addr;
    }
    function setStak(address payable addr) external{
        require(msg.sender == root && addr != address(0), 'Only root');
        stak = addr;
    }
    function setLimitDividend(uint8 limit) external{
        require(msg.sender == root && limit > 0, 'Only root');
        limitdividend = limit;
    }
}