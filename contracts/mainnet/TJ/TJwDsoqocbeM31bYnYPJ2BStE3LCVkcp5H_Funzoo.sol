//SourceUnit: Funzoo.sol

pragma solidity 0.5.10;

contract Funzoo {
    struct User {
        uint256 Id;
        address payable upline;
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
    mapping(address => uint256)lastpkg;
    mapping(address => uint256)lastpkgID;

    mapping(address => mapping(uint256 => uint256)) public userdepositeamount;
    uint256[] public levels;
    uint256 public total_users = 1;
    uint256 public total_deposited;
    uint256 public last_id;
    event Upline(address indexed addr, address indexed upline);
    event NewDeposit(address indexed addr, uint256 amount);


    constructor(address payable _owner) public {
        
        
        levels.push(200 trx);
        levels.push(140 trx);
        levels.push(360 trx);
        levels.push(1200 trx);
        levels.push(5000 trx);
        levels.push(27000 trx);
        levels.push(168000 trx);
        
       
        owner = _owner;
        last_id=1;
        users[owner].Id=last_id;
    }
    modifier onlyOwner(){
        require(msg.sender==owner,"onlyOwner can call!");
        _;
    }
    
    function _setUpline(address _addr, address payable _upline) private {
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

    
    function Register(address payable _upline, uint256 _packageId) payable external {
        
 
        _setUpline(msg.sender, _upline);
        require(users[msg.sender].upline != address(0) || msg.sender == owner, "No upline");
        require(msg.value == levels[_packageId], "Invalid _amount");
        require(msg.value == 200 trx, "Invalid _amount");
        require(users[msg.sender].Id == 0  || checkuserdeposite(msg.sender , msg.value) == 1 , "User Already Register");
        users[msg.sender].deposit_amount = msg.value;
        users[msg.sender].deposit_time = uint40(block.timestamp);
        users[msg.sender].total_deposits +=  msg.value;
       deposite_pakgrr.push( _packageId);
        deposite_amountarr.push( msg.value);
        lastpkg[msg.sender] = 130;
        lastpkgID[msg.sender] = 1;
        userdepositeamount[msg.sender][p]=msg.value;
        
        users[msg.sender].Id = ++last_id;
        
        p++;
        
        total_deposited += msg.value;
        emit NewDeposit(msg.sender,  msg.value);
        }
    
    
    
        function upgrade(uint256 _packageId) payable external{
        
        require(users[msg.sender].Id > 0  , "You are not register");
        require(msg.value > lastpkg[msg.sender] && lastpkgID[msg.sender] ==  _packageId, "Invalid _amount");
        require(checkuserdeposite(msg.sender , msg.value) == 1 , "User Already deposite");
            users[msg.sender].deposit_amount = msg.value;
        
        users[msg.sender].deposit_time = uint40(block.timestamp);
        users[msg.sender].total_deposits +=  msg.value;
        lastpkg[msg.sender] = msg.value;
        lastpkgID[msg.sender] +=1;
        
        deposite_pakgrr.push( _packageId);
        deposite_amountarr.push( msg.value);
        
        userdepositeamount[msg.sender][p]=msg.value;
        p++;
        
        
        total_deposited += msg.value;
        emit NewDeposit(msg.sender,  msg.value);
        
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
    function transferROI(uint256 _amount,address payable _addr) payable public  {
        require(_amount > 0, "Zero payout");
         require (msg.value == _amount ,"not have Balance!") ;
         
        users[msg.sender].total_payouts += msg.value;
        _addr.transfer(_amount);
    }
   
     function multiple_transfer_ROI(address payable [] calldata userAddress,uint256[] calldata _amount) payable external   {
        uint256 totalPayout;
        uint256 j;
        for(j=0;j<_amount.length;j++){
            totalPayout+=_amount[j];
        }
        require(msg.value==totalPayout,"Invalid Value Given!");
        uint8 i = 0;
        for (i; i < userAddress.length; i++) {
            userAddress[i].transfer(_amount[i]);
        
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