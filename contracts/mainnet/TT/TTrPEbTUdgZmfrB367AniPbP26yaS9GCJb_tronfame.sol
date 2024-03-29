//SourceUnit: tronfame.sol

pragma solidity >=0.4.25 <0.6.0;

contract tronfame {
    uint public totalPlayers;
    uint public totalPayout;
    uint public totalInvested;
    uint private minDepositSize = 10000000;
    uint private divisor = 100;
    uint private devCommission = 20;
    uint private rate = 60;      //daily
    uint private releaseTime = 1603173600;
    uint public constant veces=4;
    bool private able;
    address payable owner;
    struct Deposit{
        uint256 amount;
        uint256 time;
        uint256 tmp;
        uint256 profit;
    }
    struct Player {
        address usadr;
        uint256 trxDeposit;
        uint time;
        uint interestProfit;
        uint affRewards;
        Deposit [veces] deposits;
        uint cant;
        address payable affFrom;
        uint256 aff1sum;       //3 Level Referral Commission
        uint256 aff2sum;
        uint256 aff3sum;
    }
    mapping(address => Player) public players;
    modifier onlyOwner {
        require(msg.sender == owner, 'you are not owner');
        _;
    } 
    constructor() public {
      owner = msg.sender;
    }
    function register(address _addr, address payable _affAddr) private{
        Player storage player = players[_addr];
        player.affFrom = _affAddr;
        address _affAddr1 = _affAddr;
        address _affAddr2 = players[_affAddr1].affFrom;
        address _affAddr3 = players[_affAddr2].affFrom;
        players[_affAddr1].aff1sum += 1;
        players[_affAddr2].aff2sum += 1;
        players[_affAddr3].aff3sum += 1;
    }
    function deposit(address payable _affAddr) public payable  returns(bool){
        require(now >= releaseTime, "not time yet!");
        require(msg.value >= minDepositSize);
        if(players[msg.sender].cant == veces){
            return false;
        }
        uint depositAmount = msg.value;
        if(players[msg.sender].usadr == msg.sender && players[msg.sender].trxDeposit > 0){
            register(msg.sender, _affAddr);
            players[msg.sender].cant += 1;
        }
        else{
            register(msg.sender, _affAddr);
            players[msg.sender].cant= 1;
            players[msg.sender].usadr = msg.sender;
            totalPlayers++;
        }
        distributeRef(msg.value, players[msg.sender].affFrom);
        totalInvested += depositAmount;
        players[msg.sender].time = now;
        players[msg.sender].trxDeposit += depositAmount;
        uint pos = players[msg.sender].deposits.length;
        uint p = (pos-(players[msg.sender].cant-1))-1;
        if(players[msg.sender].deposits[p].amount >0){
            uint pa = p+(players[msg.sender].cant-1);
            if(players[msg.sender].deposits[pa].amount > 0){
                uint t =1;
                for(uint i=0 ; i< pos;i++){
                    uint r = pa-t;
                    if(players[msg.sender].deposits[r].amount ==0){
                        players[msg.sender].deposits[r] = Deposit(msg.value,now,now+3 days,0);
                        return true;
                    }
                    t++;
                }
            }else{
                players[msg.sender].deposits[pa] = Deposit(msg.value,now,now+3 days,0);
                return true;
            }
        }else{
            players[msg.sender].deposits[p] = Deposit(msg.value,now,now+3 days,0);
            return true;
        }
    }
    function withdraw(uint pos) public returns(uint256){
        Player storage player = players[msg.sender];
        require(player.deposits[pos].amount > 0 ,"you have already withdraw everything.");
        uint secPassed = now-player.deposits[pos].time;
        uint por = getPercent(player.deposits[pos].amount,rate);
        uint256 total = getPercent(player.deposits[pos].amount,rate)*3;
        uint256 pft = secPassed*(por/24/60/60);
        if( player.deposits[pos].tmp <= now){
            uint t =0;
            if(player.deposits[pos].profit > 0){
                uint256 to = total-player.deposits[pos].profit;
                require(to< address(this).balance, "not balance system");
                player.interestProfit += to;
                t=to;
            }else{
                require(total< address(this).balance, "not balance system");
                player.interestProfit += total;
                t=total;
            }
            player.deposits[pos].amount = 0;
            player.deposits[pos].time = 0;
            player.deposits[pos].tmp = 0;
            player.deposits[pos].profit = 0;
            player.cant -=1;
            msg.sender.transfer(t);
            uint devEarn = getPercent(t,devCommission);
            owner.transfer(devEarn);
            return t;
        }else{
            require(pft< address(this).balance, "not balance system");
            player.deposits[pos].time =now;
            player.interestProfit += pft;
            player.deposits[pos].profit += pft;
            msg.sender.transfer(pft);
            uint devEarn = getPercent(pft,devCommission);
            owner.transfer(devEarn);
            return pft;
        }
    }
    function distributeRef(uint256 _trx, address payable _affFrom) private{
        address payable _affAddr1 = _affFrom;
        address payable _affAddr2 = players[_affAddr1].affFrom;
        address payable _affAddr3 = players[_affAddr2].affFrom;
        uint256 _affRewards = 0;
        if (_affAddr1 != address(0)) {
            _affRewards = getPercent(_trx,20);
            players[_affAddr1].affRewards += _affRewards;
            _affAddr1.transfer(_affRewards);
            totalPayout += _affRewards; 
        }
        if (_affAddr2 != address(0)) {
            _affRewards = getPercent(_trx,5);
            players[_affAddr2].affRewards += _affRewards;
            _affAddr2.transfer(_affRewards);
            totalPayout += _affRewards;
        }
        if (_affAddr3 != address(0)) {
            _affRewards = getPercent(_trx,5);
            players[_affAddr3].affRewards += _affRewards;
            _affAddr3.transfer(_affRewards);
            totalPayout += _affRewards;
        }
      
    }
    function details() public view returns(uint,uint,uint,uint,uint,uint){
        return (totalInvested,totalPlayers,totalPayout,players[msg.sender].cant,rate,minDepositSize);
    }
    function getPercent(uint256 _val, uint _percent) internal pure  returns (uint256) {
        uint256 valor = (_val * _percent) / 100 ;
        return valor;
    }
    function datas() public view returns(uint256[] memory, uint256[] memory, uint256[] memory, uint256[] memory, uint[] memory){
        uint256 [] memory amount = new uint256[](players[msg.sender].cant);
        uint256[] memory time = new uint256[](players[msg.sender].cant);
        uint256[] memory profit = new uint256[](players[msg.sender].cant);
        uint256[] memory tmp = new uint256[](players[msg.sender].cant);
        uint256[] memory pos = new uint256[](players[msg.sender].cant);
        uint p =0;
        for (uint i=0; i<players[msg.sender].deposits.length ;i++){
            if(players[msg.sender].deposits[i].amount > 0){
                amount[p] = players[msg.sender].deposits[i].amount;
                time[p] = players[msg.sender].deposits[i].time;
                tmp[p] = players[msg.sender].deposits[i].tmp;
                profit[p] = players[msg.sender].deposits[i].profit;
                pos[p] = i;
                p++;
            }
        }
        return (amount,time,tmp,profit,pos);
    }
    function getTime()public view returns(uint){
        return releaseTime;
    }
    function getHistory() public view returns(uint256,uint,uint){
        Player storage player = players[msg.sender];
        return (player.trxDeposit,player.interestProfit,player.affRewards);
    }
   
   
}