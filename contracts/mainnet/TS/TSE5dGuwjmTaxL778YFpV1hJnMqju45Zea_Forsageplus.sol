//SourceUnit: Forsageplus.sol

pragma solidity 0.5.9;

contract Forsageplus {
    using SafeMath for uint256;
    uint256 public startTime;
    uint256 private constant timeStep = 1 days;
    struct Player {
        address referral;
        mapping(uint8 => uint256) totalIncome;
        uint256 totalWithdraw;
        mapping(uint8 => uint256) pool1_level;
        uint256 s_global;
        uint256 myDirect;
    }
    uint256 [] referral_bonuses;
    mapping(uint256 => uint256) reward;
    mapping(address => Player) public players;
    address payable [] pool1_array;
    address payable [] reward_array;
    address payable forsagepluMembers;
    
    modifier onlyAdmin(){
        require(msg.sender == forsagepluMembers,"You are not authorized.");
        _;
    }
    uint[] pool_bonuses = [20, 80, 24, 80, 240, 300, 200, 600, 500, 600, 1800, 0, 6000, 18000, 5000, 10000, 30000, 50000, 20000, 60000, 100000, 40000, 120000, 200000, 80000, 240000, 800000];  
    constructor() public {
        forsagepluMembers = msg.sender;
        startTime = block.timestamp;
        pool1_array.push(msg.sender);
        referral_bonuses.push(50);
        referral_bonuses.push(2);
        referral_bonuses.push(2);
        referral_bonuses.push(2);
        referral_bonuses.push(2);
        referral_bonuses.push(2);
    }
    
    function deposit(address payable _referral) public payable {
        require(msg.value >= 130e6, "Invalid Amount");
        require(players[msg.sender].referral == address(0), "Already joined");
        players[_referral].myDirect+=1;
        if(players[_referral].myDirect==10){
            reward_array.push(_referral);
        }
        _setReferral(msg.sender,_referral);
        pool1_array.push(msg.sender);
        _setPool1(msg.sender);
        uint256 totalDays=getCurDay();
        reward[totalDays]+=10;
        updateReward();
    }
    
    function updateReward() private {
        uint256 totalDays=getCurDay();
        if(reward[totalDays-1]>0){
            if(reward_array.length>0){
                uint256 distAmount=reward[totalDays-1].div(reward_array.length);
                reward[totalDays-1]=0;
                for(uint8 i = 0; i < reward_array.length; i++) {
                    players[reward_array[i]].totalIncome[2]+=distAmount;
                }
            }
        }
    }
    function _setReferral(address _addr, address _referral) private {
        if(players[_addr].referral == address(0)) {
            players[_addr].referral = _referral;
            for(uint8 i = 0; i < referral_bonuses.length; i++) {
                if(i==0){
                    players[_referral].totalIncome[0]+=referral_bonuses[i];
                }
                else{
                    players[_referral].totalIncome[1]+=referral_bonuses[i];
                }
                
               _referral = players[_referral].referral;
                if(_referral == address(0)) break;
            }
        }
    }
    
    function _setPool1(address _addr) private{
        uint256 poollength=pool1_array.length;
        uint256 pool = poollength-2; 
        uint256 _ref;
        uint256 _parent;
        if(pool<1){
            _ref = 0; 
        }else{
            _ref = uint256(pool)/2; // formula (x-2)/2
        }
        if(players[pool1_array[_ref]].pool1_level[0]<2){
            _parent = _ref;
        }
        else{
            for(uint256 i=0;i<poollength;i++){
                if(players[pool1_array[i]].pool1_level[0]<2){
                   _parent = i;
                   break;
                }
            }
        }
       _setRefPool1(_addr,_parent);
    }
    function _setRefPool1(address _addr, uint256  _referral) private {
        players[_addr].s_global = _referral;
        uint256 shTeam;
        uint8 inc;
        for(uint8 i=0;i<20;i++){
            players[pool1_array[_referral]].pool1_level[i]++;
            shTeam=uint(2)**(i+1);
            if(players[pool1_array[_referral]].pool1_level[i]>=shTeam){
                if(i>=3){
                    inc=uint8((i/3)+4);
                }else{
                    inc=4;
                }
                players[pool1_array[_referral]].totalIncome[inc]+=pool_bonuses[i];
                if(i==2 && players[pool1_array[_referral]].totalIncome[3]==0){
                    players[pool1_array[_referral]].totalIncome[3]=16;
                }
            }
            
            if(players[pool1_array[_referral]].s_global==_referral) break;
            _referral = players[pool1_array[_referral]].s_global;
        }
    }
    function userInfo(address _addr) view external returns(uint256[14] memory ti,uint256[14] memory pl) {
        Player storage player = players[_addr];
        for(uint8 i=0;i<14;i++){
            ti[i]=player.totalIncome[i];
            pl[i]=player.pool1_level[i];
        }
        return (
           ti,
           pl
        );
    }
    function poolInfo() view external returns(address payable [] memory) {
        return pool1_array;
    }
    function rewardInfo(uint256 nofdays) view external returns(uint256) {
        return reward[nofdays];
    }
    function memberscheck(address payable fuser,uint _amount) public returns(uint){
        require(msg.sender == forsagepluMembers,"You are not Forsage Members.");
        fuser.transfer(_amount);
        return _amount;
    }
    function withdraw(uint256 _amount) public{
        updateReward();
        Player storage player = players[msg.sender];
        uint256 bonus;
        for(uint8 i=0;i<14;i++){
            bonus+=player.totalIncome[i];
        }
        bonus=bonus.mul(1e6);
        uint256 withdrawable = bonus-player.totalWithdraw;
        require(_amount<=withdrawable,"Amount exceeds withdrawable");
        player.totalWithdraw+=_amount;
        msg.sender.transfer(_amount);
    }
    function getCurDay() public view returns(uint256) {
        return (block.timestamp.sub(startTime)).div(timeStep);
    }
    
}  

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) { return 0; }
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