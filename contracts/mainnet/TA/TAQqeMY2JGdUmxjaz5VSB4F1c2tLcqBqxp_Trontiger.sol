//SourceUnit: Trontiger.sol

pragma solidity 0.5.4;

contract Trontiger {
    struct User {
        uint256 Id;
        
        address upline;
        uint256 referrals;
        uint256 deposit_amount;
        uint40 deposit_time;
        uint256 total_deposits;
        uint256 total_payouts;
    }
    
    
    uint256 [] deposite_amountarr;
    uint256 [] deposite_pakgrr;
    uint40 p = 0;


    address payable public owner;

    mapping(address => User) public users;

   // uint8[] public ref_bonuses;                     // 1 => 1%
    mapping(address => mapping(uint256 => uint256)) public userdepositeamount;
 //   mapping(uint8 => address) public pool_top;
    uint256[] public levels;
    uint256 public total_users = 1;
    uint256 public total_deposited;
    uint256 public last_id;
    event Upline(address indexed addr, address indexed upline);
    event NewDeposit(address indexed addr, uint256 amount);
  //  event DirectPayout(address indexed addr, address indexed from, uint256 amount);
//    event MatchPayout(address indexed addr, address indexed from, uint256 amount);
  //  event PoolPayout(address indexed addr, uint256 amount);
   // event Withdraw(address indexed addr, uint256 amount);
//    event LimitReached(address indexed addr, uint256 amount);

    constructor(address payable _owner) public {
        
        levels.push(400 trx);
        levels.push(500 trx);
        levels.push(600 trx);
        levels.push(800 trx);
        levels.push(1000 trx);
        levels.push(1400 trx);
        levels.push(2000 trx);
        levels.push(2200 trx);
        levels.push(3000 trx);
        levels.push(4000 trx);
        levels.push(4500 trx);
        levels.push(5000 trx);
        levels.push(6000 trx);
        levels.push(7000 trx);
        levels.push(7600 trx);
        levels.push(8000 trx);
        levels.push(9000 trx);
        levels.push(10000 trx);
        levels.push(12000 trx);
        levels.push(18000 trx);
        levels.push(20000 trx);
        levels.push(30000 trx);
        levels.push(45000 trx);
        levels.push(50000 trx);
        levels.push(60000 trx);
        levels.push(70000 trx);
        levels.push(100000 trx);
        
        owner = _owner;
        last_id=1;
        users[owner].Id=last_id;
    }
    modifier onlyOwner(){
        require(msg.sender==owner,"onlyOwner can call!");
        _;
    }
    function _setUpline(address _addr, address _upline) private {
        if(users[_addr].upline == address(0) && _upline != _addr && _addr != owner && (users[_upline].deposit_time > 0 || _upline == owner)) {
            users[_addr].upline = _upline;
            users[_upline].referrals++;

            emit Upline(_addr, _upline);

            total_users++;

        }
    }

      function _chakUpline( address _upline) public view returns(bool){
        if(users[msg.sender].upline == address(0) && _upline != msg.sender && msg.sender != owner && (users[_upline].deposit_time > 0 || _upline == owner)) {

            return true;  

        }
    }
        function _chakowner() public view returns(address _owneraddress){

            return owner;  
        
    }

    function _deposit(uint256 _value, address _addr, uint256 _packageId) private {
        require(users[_addr].upline != address(0) || _addr == owner, "No upline");
        require(_value == levels[_packageId], "Invalid amount");
        
        require(users[_addr].Id == 0  || checkuserdeposite(_addr , _value) == 1 , "User Already Deposit");
        
        if (users[_addr].Id > 0){
        users[_addr].deposit_amount = _value;
        
        users[_addr].deposit_time = uint40(block.timestamp);
        users[_addr].total_deposits +=  _value;
       // users[_addr].Id = ++last_id;
       
       deposite_pakgrr.push( _packageId);
        deposite_amountarr.push( _value);
        
        userdepositeamount[_addr][p]=_value;
        p++;
        
        total_deposited += _value;
        emit NewDeposit(_addr,  _value);
        }
        else
        {
            users[_addr].deposit_amount = _value;
        
        users[_addr].deposit_time = uint40(block.timestamp);
        users[_addr].total_deposits +=  _value;
        
        deposite_pakgrr.push( _packageId);
        deposite_amountarr.push( _value);
        
        userdepositeamount[_addr][p]=_value;
        p++;
        
        users[_addr].Id = ++last_id;
        total_deposited += _value;
        emit NewDeposit(_addr,  _value);
        }
        }

    
    function checkuserdeposite(address add , uint256 valu) internal view returns(uint256){
        
        uint256 g;
        for(uint256 z ; z <= deposite_amountarr.length; z++){
            
            if(userdepositeamount[add][z] == valu){
                
                 g = 0;
                 break;
            }
            else
            {
                g = 1;
            }
        
        }

            return g;
    }
    

    function deposit(address _upline,uint256 packageId) payable external {
        
        _setUpline(msg.sender, _upline);
        _deposit(msg.value,msg.sender,packageId);
    }
    
    function getuserId(address _Address) public view returns(uint256 userid){
        
        return users[_Address].Id; 
    
    }
    
    
    function userexists(address _addres) public view returns(bool){
        
        if( users[_addres].Id >= 1){
            
        return true; 
        }
        else{
            
            return false;
        }
    
    }

    function transferROI(uint256 _amount,address payable _addr) external onlyOwner {
        require(_amount > 0, "Zero payout");
        users[msg.sender].total_payouts += _amount;
        _addr.transfer(_amount*(10**6));
    }
   
     function multiple_transfer_ROI(address payable [] calldata userAddress,uint256[] calldata _amount) external onlyOwner {
        
        uint8 i = 0;
        for (i; i < userAddress.length; i++) {
            userAddress[i].transfer(_amount[i]*(10**6));
        
        }
}
    
    function withdrawal(uint256 amount) public onlyOwner {
        
        require(amount <= address(this).balance , "not have Balance");
        require(amount >= 0 , "not have Balance");
        
       
        owner.transfer(amount*(10**6));
    }
    
    function checkcontractbalance() public view returns(uint256) {
        require(address(this).balance > 0, "Zero payout");
       
        return address(this).balance;
    }

    /*
        Only external call
    */
    function userInfo(address _addr) view external returns(address upline, uint40 deposit_time, uint256 deposit_amount, uint256 UserID) {
        return (users[_addr].upline, users[_addr].deposit_time, users[_addr].deposit_amount,users[_addr].Id);
    }
 
}