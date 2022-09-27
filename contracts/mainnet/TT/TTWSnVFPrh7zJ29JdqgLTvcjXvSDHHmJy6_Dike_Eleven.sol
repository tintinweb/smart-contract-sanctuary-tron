//SourceUnit: dike_game.sol

pragma solidity 0.5.4;

contract Initializable {

  bool private initialized;
  bool private initializing;

  modifier initializer() 
  {
	  require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");
	  bool wasInitializing = initializing;
	  initializing = true;
	  initialized = true;
		_;
	  initializing = wasInitializing;
  }
  function isConstructor() private view returns (bool) 
  {
  uint256 cs;
  assembly { cs := extcodesize(address) }
  return cs == 0;
  }
  uint256[50] private __gap;

}

contract Ownable is Initializable {
  address public _owner;
  uint256 private _ownershipLocked;
  event OwnershipLocked(address lockedOwner);
  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
  address indexed previousOwner,
  address indexed newOwner
	);
  function initialize(address sender) internal initializer {
   _owner = sender;
   _ownershipLocked = 0;

  }
  function ownerr() public view returns(address) {
   return _owner;

  }

  modifier onlyOwner() {
    require(isOwner());
    _;

  }

  function isOwner() public view returns(bool) {
  return msg.sender == _owner;
  }

  function transferOwnership(address newOwner) public onlyOwner {
   _transferOwnership(newOwner);

  }
  function _transferOwnership(address newOwner) internal {
    require(_ownershipLocked == 0);
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;

  }

  // Set _ownershipLocked flag to lock contract owner forever

  function lockOwnership() public onlyOwner {
    require(_ownershipLocked == 0);
    emit OwnershipLocked(_owner);
    _ownershipLocked = 1;
  }

  uint256[50] private __gap;

}

interface ITRC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender)
  external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value)
  external returns (bool);
  
  function transferFrom(address from, address to, uint256 value)
  external returns (bool);
  function burn(uint256 value)
  external returns (bool);
  event Transfer(address indexed from,address indexed to,uint256 value);
  event Approval(address indexed owner,address indexed spender,uint256 value);
}

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


contract Dike_Eleven is Ownable {
    
    struct User 
    {
        uint id;
        address referrer;
        uint partnersCount;
        bool is_block;
        mapping(uint8 => X3) x3Matrix;
        mapping(uint8 => X3_Second) x3sMatrix;
        mapping(uint8 => X3_Third) x3tMatrix;
        mapping(uint8 => PX3) px3Matrix;
        mapping(uint8 => PX3_Second) px3sMatrix;
        mapping(uint8 => PX3_Third) px3tMatrix;
        mapping(uint8 => PX3_Fourth) px3fMatrix;
    }
    
    struct X3 
    {
        address currentReferrer;
        address[] referrals;
        bool blocked;
        uint reinvestCount;
    }
    
    struct X3_Second 
    {
        address currentReferrer;
        address[] referrals;
        bool blocked;
        uint reinvestCount;
    }
    
    struct X3_Third 
    {
        address currentReferrer;
        address[] referrals;
        bool blocked;
        uint reinvestCount;
    }
    
    struct PX3 
    {
        address currentReferrer;
        address[] referrals;
        bool blocked;
        uint reinvestCount;
    }
    
    struct PX3_Second 
    {
        address currentReferrer;
        address[] referrals;
        bool blocked;
        uint reinvestCount;
    }
    
    struct PX3_Third 
    {
        address currentReferrer;
        address[] referrals;
        bool blocked;
        uint reinvestCount;
    }
    
     struct PX3_Fourth 
    {
        address currentReferrer;
        address[] referrals;
        bool blocked;
        uint reinvestCount;
    }
  

    uint8 public currentStartingLevel = 1;
   
    uint8 public LAST_LEVEL = 3;
    uint256 public MINIMUM = 16 trx;
    uint256 public adminFee = 2 trx;
    
    uint public max_dev=5;
    
    
    mapping(address => User) public users;        //  User struct ka ek object create array ke form me
      
    
    mapping(uint => address) public idToAddress;   //  kon si id pe kon sa address h

    uint public lastUserId = 2;
    
    address public owner;
    
    mapping(uint => address) public dev_address;   //  kon si id pe kon sa address h
    
    mapping(uint8 => uint) public levelPrice;
    mapping(uint => uint) public packagePrice;
    mapping(uint => mapping(uint8 => uint)) packageIncome;
    ITRC20 private DIKETOKEN; 

    event Registration(address indexed user, address indexed referrer, uint indexed userId, uint referrerId);
    event Reinvest(address indexed user, address indexed currentReferrer, address indexed caller, uint8 matrix, uint8 level);
    event Upgrade(address indexed user, address indexed referrer, uint8 matrix, uint8 level);
    event NewUserPlace(address indexed user, address indexed referrer, uint8 matrix, uint8 level, uint8 place);
    event MissedEthReceive(address indexed receiver, address indexed _from, uint8 matrix, uint8 level);
    event SentExtraEthDividends(address indexed _from, address indexed receiver, uint8 matrix, uint8 level);
    event Buy_new_slot(address indexed user , uint package);
    //event Rewardsended(uint256 amount , address indexed _receiver,uint256 game_id,uint256 _type);
    event Rewardsended(uint256 indexed game_id);
    
    constructor(address ownerAddress,address devAddress,ITRC20 _DIKETOKEN) public {
         
        owner = ownerAddress;   //   contractOwner Address
        
        dev_address[1] = devAddress;   //   contract developer Address
        
        levelPrice[1]=3 trx;
        levelPrice[2]=2 trx;
        levelPrice[3]=1 trx;
        
        packagePrice[1]=16 trx;
        packagePrice[12]=192 trx;
        packagePrice[84]=1344 trx;
        packagePrice[336]=5376 trx;
        
        packageIncome[1][1]=3 trx;
        packageIncome[1][2]=2 trx;
        packageIncome[1][3]=1 trx;
        
        packageIncome[2][1]=36 trx;
        packageIncome[2][2]=24 trx;
        packageIncome[2][3]=12 trx;
        
        packageIncome[3][1]=252 trx;
        packageIncome[3][2]=168 trx;
        packageIncome[3][3]=84 trx;
        
        packageIncome[4][1]=1008 trx;
        packageIncome[4][2]=672 trx;
        packageIncome[4][3]=336 trx;
    
        
        
        User memory user = User({    //   first ki value set hui h User struct me
            id: 1,
            is_block:false,
            referrer: address(0),
            partnersCount: uint(0)
        });
        
        users[ownerAddress] = user;    //  mapping me  wallet address pe data insert hua h
       
         DIKETOKEN = _DIKETOKEN; 
        
        idToAddress[1] = ownerAddress; // first id pe owner ka address
         
    }
    
    function() external payable {
        uint256[] memory con = new uint256[](1);
        if(msg.data.length == 0) {
            return registration(msg.sender, owner,con);
        }
        
        registration(msg.sender, bytesToAddress(msg.data),con);
    }
   
   
   
  


    function multisendTRX(address payable[]  memory  _contributors, uint[] memory _balances, uint gid, uint[] memory _type) public payable 
    {
      require(msg.sender==dev_address[1] || msg.sender==dev_address[2] || msg.sender==dev_address[3] || msg.sender==dev_address[4] || msg.sender==dev_address[5]);
        uint i = 0;
        for (i; i < _contributors.length; i++) 
        {
            if(_type[i]==1)
            {
            _contributors[i].transfer(_balances[i]);
            }
            else
            {
                DIKETOKEN.transfer(_contributors[i],_balances[i]);
            }            
        }
         emit Rewardsended(gid);        
    }

    function withdrawLostTRXFromBalance(address payable userAddress) public {
        require(userAddress==owner, "onlyOwner");
        userAddress.transfer(address(this).balance);
    }


    function registrationExt(address referrerAddress,uint[] memory  referrals) public payable {
        registration(msg.sender, referrerAddress,referrals);
    }
    
   
    
    function registration(address userAddress, address referrerAddress, uint[] memory referrals) private {
        require(!isUserExists(userAddress), "user exists");
        require(isUserExists(referrerAddress), "referrer not exists");
        
        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        require(size == 0, "cannot be a contract");

            require(msg.value == MINIMUM, "invalid registration cost");
       
        User memory user = User({
            id: lastUserId,
            is_block:false,
            referrer: referrerAddress,
            partnersCount: 0
        });
        
        users[userAddress] = user;
        idToAddress[lastUserId] = userAddress;
        
        users[userAddress].referrer = referrerAddress;
        
        lastUserId++;
        
        users[referrerAddress].partnersCount++;

        address freeX3Referrer = findFreeX3Referrer(userAddress);
        
        if(freeX3Referrer!=idToAddress[referrals[0]])
        {
           emit MissedEthReceive(freeX3Referrer, msg.sender, 1, 1);  
           emit SentExtraEthDividends(msg.sender, idToAddress[referrals[0]], 1, 1);
        }
        
        
        address freeX3sReferrer = findFreeX3sReferrer(userAddress);
           
        if(freeX3sReferrer!=idToAddress[referrals[1]])
        {
          emit MissedEthReceive(freeX3sReferrer, msg.sender, 1, 2);  
          emit SentExtraEthDividends(msg.sender, idToAddress[referrals[1]], 1, 2);
        }
        
        address freeX3tReferrer = findFreeX3tReferrer(userAddress);
        
           
        if(freeX3tReferrer!=idToAddress[referrals[2]])
        {
           emit MissedEthReceive(freeX3tReferrer, msg.sender, 1, 3);  
           emit SentExtraEthDividends(msg.sender, idToAddress[referrals[2]], 1, 3);
        }
         
        users[userAddress].x3Matrix[1].currentReferrer = freeX3Referrer;
        
        users[userAddress].x3sMatrix[1].currentReferrer = freeX3sReferrer;
        
        users[userAddress].x3tMatrix[1].currentReferrer = freeX3tReferrer;
        
       updateX3Referrer(userAddress, freeX3Referrer, 1,idToAddress[referrals[0]]);
       updateX3sReferrer(userAddress, freeX3sReferrer, 1,idToAddress[referrals[1]]);
       updateX3tReferrer(userAddress, freeX3tReferrer, 1,idToAddress[referrals[2]]);
       
        address(uint160(owner)).send(2 trx);
        
        emit Registration(userAddress, referrerAddress, users[userAddress].id, users[referrerAddress].id);
    }

    
    function updateX3Referrer(address userAddress, address referrerAddress, uint8 level, address payment_address) private {
        users[referrerAddress].x3Matrix[level].referrals.push(userAddress);

        if (users[referrerAddress].x3Matrix[level].referrals.length < 3) {
            emit NewUserPlace(userAddress, referrerAddress, 1, level, uint8(users[referrerAddress].x3Matrix[level].referrals.length));
            return sendETHDividends(payment_address, userAddress, 1, level,0);
        }
        
        emit NewUserPlace(userAddress, referrerAddress, 1, level, 3);
        //close matrix
        users[referrerAddress].x3Matrix[level].referrals = new address[](0);
        

        //create new one by recursion
        if (referrerAddress != owner) {
            //check referrer active level
            address freeReferrerAddress = findFreeX3Referrer(referrerAddress);
            if (users[referrerAddress].x3Matrix[level].currentReferrer != freeReferrerAddress) {
                users[referrerAddress].x3Matrix[level].currentReferrer = freeReferrerAddress;
            }
            
            users[referrerAddress].x3Matrix[level].reinvestCount++;
            emit Reinvest(referrerAddress, freeReferrerAddress, userAddress, 1, level);
            updateX3Referrer(referrerAddress, freeReferrerAddress, level,freeReferrerAddress);
        } else {
            sendETHDividends(owner, userAddress, 1, level,0);
            users[owner].x3Matrix[level].reinvestCount++;
            emit Reinvest(owner, address(0), userAddress, 1, level);
        }
    }
    
    function updateX3sReferrer(address userAddress, address referrerAddress, uint8 level, address payment_address) private {
        users[referrerAddress].x3sMatrix[level].referrals.push(userAddress);

        if (users[referrerAddress].x3sMatrix[level].referrals.length < 3) {
            emit NewUserPlace(userAddress, referrerAddress, 1, 2, uint8(users[referrerAddress].x3sMatrix[level].referrals.length));
            return sendETHDividends(payment_address, userAddress, 1, 2,0);
        }
        
        emit NewUserPlace(userAddress, referrerAddress, 1, 2, 3);
        //close matrix
        users[referrerAddress].x3sMatrix[level].referrals = new address[](0);
        

        //create new one by recursion
        if (referrerAddress != owner) {
            //check referrer active level
            address freeReferrerAddress = findFreeX3Referrer(referrerAddress);
            if (users[referrerAddress].x3sMatrix[level].currentReferrer != freeReferrerAddress) {
                users[referrerAddress].x3sMatrix[level].currentReferrer = freeReferrerAddress;
            }
            
            users[referrerAddress].x3sMatrix[level].reinvestCount++;
            emit Reinvest(referrerAddress, freeReferrerAddress, userAddress, 1, 2);
            updateX3sReferrer(referrerAddress, freeReferrerAddress, level,referrerAddress);
        } else {
            sendETHDividends(owner, userAddress, 1, 2,0);
            users[owner].x3sMatrix[level].reinvestCount++;
            emit Reinvest(owner, address(0), userAddress, 1, 2);
        }
    }
    
    function updateX3tReferrer(address userAddress, address referrerAddress, uint8 level, address payment_address) private {
        users[referrerAddress].x3tMatrix[level].referrals.push(userAddress);

        if (users[referrerAddress].x3tMatrix[level].referrals.length < 3) {
            emit NewUserPlace(userAddress, referrerAddress, 1, 3, uint8(users[referrerAddress].x3tMatrix[level].referrals.length));
            return  sendETHDividends(payment_address, userAddress, 1, 3,0);
        }
        
        emit NewUserPlace(userAddress, referrerAddress, 1, 3, 3);
        //close matrix
        users[referrerAddress].x3tMatrix[level].referrals = new address[](0);
        

        //create new one by recursion
        if (referrerAddress != owner) {
            //check referrer active level
            address freeReferrerAddress = findFreeX3Referrer(referrerAddress);
            if (users[referrerAddress].x3tMatrix[level].currentReferrer != freeReferrerAddress) {
                users[referrerAddress].x3tMatrix[level].currentReferrer = freeReferrerAddress;
            }
            
            users[referrerAddress].x3tMatrix[level].reinvestCount++;
            emit Reinvest(referrerAddress, freeReferrerAddress, userAddress, 1, 3);
            updateX3tReferrer(referrerAddress, freeReferrerAddress, level,referrerAddress);
        } else {
            sendETHDividends(owner, userAddress, 1, 3,0);
            users[owner].x3tMatrix[level].reinvestCount++;
            emit Reinvest(owner, address(0), userAddress, 1, 3);
        }
    }

    function findFreeX3Referrer(address userAddress) public view returns(address) {
               return users[userAddress].referrer;
          }
        
    function findFreeX3sReferrer(address userAddress) public view returns(address) {
              if(users[users[userAddress].referrer].referrer!=address(0))
                return users[users[userAddress].referrer].referrer;
                else
                return owner;
          }
        
    function findFreeX3tReferrer(address userAddress) public view returns(address) {
               if(users[users[users[userAddress].referrer].referrer].referrer!=address(0))
                return users[users[users[userAddress].referrer].referrer].referrer;
                else
                return owner;
          }

    function usersX3Matrix(address userAddress, uint8 level) public view returns(address, address[] memory, bool,uint) {
        return (users[userAddress].x3Matrix[level].currentReferrer,
                users[userAddress].x3Matrix[level].referrals,
                users[userAddress].x3Matrix[level].blocked,
                users[userAddress].x3Matrix[level].reinvestCount);
    }
    
     function usersX3sMatrix(address userAddress, uint8 level) public view returns(address, address[] memory, bool,uint) {
        return (users[userAddress].x3sMatrix[level].currentReferrer,
                users[userAddress].x3sMatrix[level].referrals,
                users[userAddress].x3sMatrix[level].blocked,
                users[userAddress].x3sMatrix[level].reinvestCount);
    }
    
     function usersX3tMatrix(address userAddress, uint8 level) public view returns(address, address[] memory, bool,uint) {
        return (users[userAddress].x3tMatrix[level].currentReferrer,
                users[userAddress].x3tMatrix[level].referrals,
                users[userAddress].x3tMatrix[level].blocked,
                users[userAddress].x3tMatrix[level].reinvestCount);
     }
     
     //   for buy Buy_new_slot
    
    
    function buy_new_slot(uint package, uint[] memory referrals,uint _type) public payable {
        uint min=0;
        
        require(isUserExists(msg.sender), "user not exists");
          min=packagePrice[package];

        require(msg.value == min, "invalid slot cost"); 
        
        uint adminfee=package*2 trx;
       
        
        address freeX3Referrer  = findFreeX3Referrer(msg.sender);
        address freeX3sReferrer = findFreeX3sReferrer(msg.sender);
        address freeX3tReferrer = findFreeX3tReferrer(msg.sender);
        
        if(_type==1)
        {
            
            users[msg.sender].px3Matrix[1].currentReferrer  = freeX3Referrer;
            users[msg.sender].px3Matrix[2].currentReferrer = freeX3sReferrer;
            users[msg.sender].px3Matrix[3].currentReferrer = freeX3tReferrer;
            
        //   // address freeX3Referrer = findFreeX3Referrer(userAddress);
            
        //     if(freeX3Referrer!=idToAddress[referrals[0]])
        //     {
        //       emit MissedEthReceive(freeX3Referrer, msg.sender, 2, 1);  
        //       emit SentExtraEthDividends(msg.sender, idToAddress[referrals[0]], 2, 1);
        //     }
            
        //     if(freeX3sReferrer!=idToAddress[referrals[1]])
        //     {
        //       emit MissedEthReceive(freeX3sReferrer, msg.sender, 2, 2);  
        //       emit SentExtraEthDividends(msg.sender, idToAddress[referrals[1]], 2, 2);
        //     }
            
        //     if(freeX3tReferrer!=idToAddress[referrals[2]])
        //     {
        //       emit MissedEthReceive(freeX3tReferrer, msg.sender, 2, 3);  
        //       emit SentExtraEthDividends(msg.sender, idToAddress[referrals[2]], 2, 3);
        //     }
            
            
           updatePX3Referrer(msg.sender, freeX3Referrer,1,idToAddress[referrals[0]],1);
           updatePX3Referrer(msg.sender, freeX3sReferrer,2,idToAddress[referrals[1]],1);
           updatePX3Referrer(msg.sender, freeX3tReferrer,3,idToAddress[referrals[2]],1);
        }
         if(_type==2)
        {
            
            users[msg.sender].px3sMatrix[1].currentReferrer  = freeX3Referrer;
            users[msg.sender].px3sMatrix[2].currentReferrer = freeX3sReferrer;
            users[msg.sender].px3sMatrix[3].currentReferrer = freeX3tReferrer;
            
           // address freeX3Referrer = findFreeX3Referrer(userAddress);
            
            // if(freeX3Referrer!=idToAddress[referrals[0]])
            // {
            //   emit MissedEthReceive(freeX3Referrer, msg.sender, 3, 1);  
            //   emit SentExtraEthDividends(msg.sender, idToAddress[referrals[0]],3, 1);
            // }
            
            // if(freeX3sReferrer!=idToAddress[referrals[1]])
            // {
            //   emit MissedEthReceive(freeX3sReferrer, msg.sender, 3, 2);  
            //   emit SentExtraEthDividends(msg.sender, idToAddress[referrals[1]], 3, 2);
            // }
            
            // if(freeX3tReferrer!=idToAddress[referrals[2]])
            // {
            //   emit MissedEthReceive(freeX3tReferrer, msg.sender, 3, 3);  
            //   emit SentExtraEthDividends(msg.sender, idToAddress[referrals[2]], 3, 3);
            // }
            
           updatePX3sReferrer(msg.sender, freeX3Referrer,1,idToAddress[referrals[0]],2);
           updatePX3sReferrer(msg.sender, freeX3sReferrer,2,idToAddress[referrals[1]],2);
           updatePX3sReferrer(msg.sender, freeX3tReferrer,3,idToAddress[referrals[2]],2);
        }
        
         if(_type==3)
        {
            
            users[msg.sender].px3tMatrix[1].currentReferrer  = freeX3Referrer;
            users[msg.sender].px3tMatrix[2].currentReferrer = freeX3sReferrer;
            users[msg.sender].px3tMatrix[3].currentReferrer = freeX3tReferrer;
            
           // address freeX3Referrer = findFreeX3Referrer(userAddress);
            
            // if(freeX3Referrer!=idToAddress[referrals[0]])
            // {
            //   emit MissedEthReceive(freeX3Referrer, msg.sender, 4, 1);  
            //   emit SentExtraEthDividends(msg.sender, idToAddress[referrals[0]],4, 1);
            // }
            
            // if(freeX3sReferrer!=idToAddress[referrals[1]])
            // {
            //   emit MissedEthReceive(freeX3sReferrer, msg.sender, 4, 2);  
            //   emit SentExtraEthDividends(msg.sender, idToAddress[referrals[1]], 4, 2);
            // }
            
            // if(freeX3tReferrer!=idToAddress[referrals[2]])
            // {
            //   emit MissedEthReceive(freeX3tReferrer, msg.sender, 4, 3);  
            //   emit SentExtraEthDividends(msg.sender, idToAddress[referrals[2]], 4, 3);
            // }
            
           updatePX3tReferrer(msg.sender, freeX3Referrer,1,idToAddress[referrals[0]],3);
           updatePX3tReferrer(msg.sender, freeX3sReferrer,2,idToAddress[referrals[1]],3);
           updatePX3tReferrer(msg.sender, freeX3tReferrer,3,idToAddress[referrals[2]],3);
        }
        
         if(_type==4)
        {
            users[msg.sender].px3fMatrix[1].currentReferrer  = freeX3Referrer;
            users[msg.sender].px3fMatrix[2].currentReferrer = freeX3sReferrer;
            users[msg.sender].px3fMatrix[3].currentReferrer = freeX3tReferrer;
            
           // address freeX3Referrer = findFreeX3Referrer(userAddress);
            
            // if(freeX3Referrer!=idToAddress[referrals[0]])
            // {
            //   emit MissedEthReceive(freeX3Referrer, msg.sender, 5, 1);  
            //   emit SentExtraEthDividends(msg.sender, idToAddress[referrals[0]],5, 1);
            // }
            
            // if(freeX3sReferrer!=idToAddress[referrals[1]])
            // {
            //   emit MissedEthReceive(freeX3sReferrer, msg.sender,5, 2);  
            //   emit SentExtraEthDividends(msg.sender, idToAddress[referrals[1]], 5, 2);
            // }
            
            // if(freeX3tReferrer!=idToAddress[referrals[2]])
            // {
            //   emit MissedEthReceive(freeX3tReferrer, msg.sender, 5, 3);  
            //   emit SentExtraEthDividends(msg.sender, idToAddress[referrals[2]],5, 3);
            // }
            
           updatePX3fReferrer(msg.sender, freeX3Referrer,1,idToAddress[referrals[0]],4);
           updatePX3fReferrer(msg.sender, freeX3sReferrer,2,idToAddress[referrals[1]],4);
           updatePX3fReferrer(msg.sender, freeX3tReferrer,3,idToAddress[referrals[2]],4);
        }
        
        address(uint160(owner)).send(adminfee);
        
        emit Buy_new_slot(msg.sender, package);
    }
     
    function updatePX3Referrer(address userAddress, address referrerAddress, uint8 level, address payment_address,uint package) private {
        users[referrerAddress].px3Matrix[level].referrals.push(userAddress);

        if (users[referrerAddress].px3Matrix[level].referrals.length < 3) {
            if(referrerAddress!=payment_address){
             emit MissedEthReceive(referrerAddress, userAddress, 2, level);  
             emit SentExtraEthDividends(userAddress, payment_address,2, level);
            }
            emit NewUserPlace(userAddress, referrerAddress, 2, level, uint8(users[referrerAddress].px3Matrix[level].referrals.length));
            return sendETHDividends(payment_address, userAddress, 2, level,package);
        }
        
        emit NewUserPlace(userAddress, referrerAddress, 2, level, 3);
        //close matrix
        users[referrerAddress].px3Matrix[level].referrals = new address[](0);
        

        //create new one by recursion
        if (referrerAddress != owner) {
            //check referrer active level
            address freeReferrerAddress = findFreePX3Referrer(referrerAddress);
            if (users[referrerAddress].px3Matrix[level].currentReferrer != freeReferrerAddress) {
                users[referrerAddress].px3Matrix[level].currentReferrer = freeReferrerAddress;
            }
            
            users[referrerAddress].px3Matrix[level].reinvestCount++;
            emit Reinvest(referrerAddress, freeReferrerAddress, userAddress, 2, level);
            updatePX3Referrer(referrerAddress, freeReferrerAddress, level,freeReferrerAddress,package);
        } else {
            sendETHDividends(owner, userAddress, 2, level,package);
            users[owner].px3Matrix[level].reinvestCount++;
            emit Reinvest(owner, address(0), userAddress, 2, level);
        }
    }
    
    function updatePX3sReferrer(address userAddress, address referrerAddress, uint8 level, address payment_address,uint package) private {
        users[referrerAddress].px3sMatrix[level].referrals.push(userAddress);

        if (users[referrerAddress].px3sMatrix[level].referrals.length < 3) {
            if(referrerAddress!=payment_address){
             emit MissedEthReceive(referrerAddress, userAddress, 3, level);  
             emit SentExtraEthDividends(userAddress, payment_address,3, level);
            }
            emit NewUserPlace(userAddress, referrerAddress, 3, level, uint8(users[referrerAddress].px3sMatrix[level].referrals.length));
            return sendETHDividends(payment_address, userAddress, 3, level,package);
        }
        
        emit NewUserPlace(userAddress, referrerAddress, 3, level, 3);
        //close matrix
        users[referrerAddress].px3sMatrix[level].referrals = new address[](0);
        

        //create new one by recursion
        if (referrerAddress != owner) {
            //check referrer active level
            address freeReferrerAddress = findFreePX3Referrer(referrerAddress);
            if (users[referrerAddress].px3sMatrix[level].currentReferrer != freeReferrerAddress) {
                users[referrerAddress].px3sMatrix[level].currentReferrer = freeReferrerAddress;
            }
            users[referrerAddress].px3sMatrix[level].reinvestCount++;
            emit Reinvest(referrerAddress, freeReferrerAddress, userAddress, 3, level);
            updatePX3sReferrer(referrerAddress, freeReferrerAddress, level,freeReferrerAddress,package);
        } else {
            sendETHDividends(owner, userAddress, 3, level,package);
            users[owner].px3sMatrix[level].reinvestCount++;
            emit Reinvest(owner, address(0), userAddress, 3, level);
        }
    }
    
    function updatePX3tReferrer(address userAddress, address referrerAddress, uint8 level, address payment_address, uint package) private {
        users[referrerAddress].px3tMatrix[level].referrals.push(userAddress);

        if (users[referrerAddress].px3tMatrix[level].referrals.length < 3) {
            if(referrerAddress!=payment_address){
             emit MissedEthReceive(referrerAddress, userAddress, 4, level);  
             emit SentExtraEthDividends(userAddress, payment_address,4, level);
            }
            emit NewUserPlace(userAddress, referrerAddress, 4, level, uint8(users[referrerAddress].px3tMatrix[level].referrals.length));
            return  sendETHDividends(payment_address, userAddress, 4, level,package);
        }
        
        emit NewUserPlace(userAddress, referrerAddress, 4, level, 3);
        //close matrix
        users[referrerAddress].px3tMatrix[level].referrals = new address[](0);
        

        //create new one by recursion
        if (referrerAddress != owner) {
            //check referrer active level
            address freeReferrerAddress = findFreePX3Referrer(referrerAddress);
            if (users[referrerAddress].px3tMatrix[level].currentReferrer != freeReferrerAddress) {
                users[referrerAddress].px3tMatrix[level].currentReferrer = freeReferrerAddress;
            }
            
            users[referrerAddress].px3tMatrix[level].reinvestCount++;
            emit Reinvest(referrerAddress, freeReferrerAddress, userAddress, 4, level);
            updatePX3tReferrer(referrerAddress, freeReferrerAddress, level,freeReferrerAddress,package);
        } else {
            sendETHDividends(owner, userAddress, 4, level,package);
            users[owner].px3tMatrix[level].reinvestCount++;
            emit Reinvest(owner, address(0), userAddress, 4, level);
        }
    }
    
    function updatePX3fReferrer(address userAddress, address referrerAddress, uint8 level, address payment_address, uint package) private {
        users[referrerAddress].px3fMatrix[level].referrals.push(userAddress);

        if (users[referrerAddress].px3fMatrix[level].referrals.length < 3) {
            if(referrerAddress!=payment_address){
             emit MissedEthReceive(referrerAddress, userAddress, 5, level);  
             emit SentExtraEthDividends(userAddress, payment_address,5, level);
            }
            emit NewUserPlace(userAddress, referrerAddress, 5, level, uint8(users[referrerAddress].px3fMatrix[level].referrals.length));
            return  sendETHDividends(payment_address, userAddress, 5, level,package);
        }
        
        emit NewUserPlace(userAddress, referrerAddress, 5, level, 3);
        //close matrix
        users[referrerAddress].px3fMatrix[level].referrals = new address[](0);
        

        //create new one by recursion
        if (referrerAddress != owner) {
            //check referrer active level
            address freeReferrerAddress = findFreePX3Referrer(referrerAddress);
            if (users[referrerAddress].px3fMatrix[level].currentReferrer != freeReferrerAddress) {
                users[referrerAddress].px3fMatrix[level].currentReferrer = freeReferrerAddress;
            }
            
            users[referrerAddress].px3fMatrix[level].reinvestCount++;
            emit Reinvest(referrerAddress, freeReferrerAddress, userAddress, 5, level);
            updatePX3fReferrer(referrerAddress, freeReferrerAddress, level,freeReferrerAddress,package);
        } else {
            sendETHDividends(owner, userAddress, 5, level,package);
            users[owner].px3tMatrix[level].reinvestCount++;
            emit Reinvest(owner, address(0), userAddress, 5, level);
        }
    }



    function usersPX3Matrix(address userAddress, uint8 level) public view returns(address, address[] memory, bool,uint) {
        return (users[userAddress].px3Matrix[level].currentReferrer,
                users[userAddress].px3Matrix[level].referrals,
                users[userAddress].px3Matrix[level].blocked,
                users[userAddress].px3Matrix[level].reinvestCount);
    }
    
     function usersPX3sMatrix(address userAddress, uint8 level) public view returns(address, address[] memory, bool,uint) {
        return (users[userAddress].px3sMatrix[level].currentReferrer,
                users[userAddress].px3sMatrix[level].referrals,
                users[userAddress].px3sMatrix[level].blocked,
                users[userAddress].px3sMatrix[level].reinvestCount);
    }
    
     function usersPX3tMatrix(address userAddress, uint8 level) public view returns(address, address[] memory, bool,uint) {
        return (users[userAddress].px3tMatrix[level].currentReferrer,
                users[userAddress].px3tMatrix[level].referrals,
                users[userAddress].px3tMatrix[level].blocked,
                users[userAddress].px3tMatrix[level].reinvestCount);
     }
     
       function usersPX3fMatrix(address userAddress, uint8 level) public view returns(address, address[] memory, bool,uint) {
        return (users[userAddress].px3fMatrix[level].currentReferrer,
                users[userAddress].px3fMatrix[level].referrals,
                users[userAddress].px3fMatrix[level].blocked,
                users[userAddress].px3fMatrix[level].reinvestCount);
     }
     
     
     
     function findFreePX3Referrer(address userAddress) public view returns(address) {
               return users[userAddress].referrer;
          }

  
    
    function isUserExists(address user) public view returns (bool)  {
        return (users[user].id != 0);
    }
    
      function add_dev(address user, uint place) public  {
          
          require(msg.sender==dev_address[1]);
          if(place==0)
          {
              require(max_dev<5,"Maximum 5 developer");
              max_dev++;
              dev_address[max_dev]=user;
          }
          else
          {
              dev_address[place]=user;
          }
       }
    

    // function findEthReceiver(address userAddress, address _from, uint8 matrix, uint8 level) private returns(address, bool) {
    //     address receiver = userAddress;
    //     bool isExtraDividends;
    //     if (matrix == 1) {
    //         while (true) {
    //             if (users[receiver].x3Matrix[level].blocked) {
    //                 emit MissedEthReceive(receiver, _from, 1, level);
    //                 isExtraDividends = true;
    //                 receiver = users[receiver].x3Matrix[level].currentReferrer;
    //             } else {
    //                 return (receiver, isExtraDividends);
    //             }
    //         }
    //     }
    //      if (matrix == 2) {
    //         while (true) {
    //             if (users[receiver].px3Matrix[level].blocked) {
    //                 emit MissedEthReceive(receiver, _from, 2, level);
    //                 isExtraDividends = true;
    //                 receiver = users[receiver].px3Matrix[level].currentReferrer;
    //             } else {
    //                 return (receiver, isExtraDividends);
    //             }
    //         }
    //     }
        
    // }

    function sendETHDividends(address userAddress, address _from, uint8 matrix, uint8 level, uint package) private {
       // (address receiver, bool isExtraDividends) = findEthReceiver(userAddress, _from, matrix, level);
    address receiver=userAddress;
        bool isExtraDividends=false;
        if(matrix==1)
        {
        if (!address(uint160(receiver)).send(levelPrice[level])) {
            address(uint160(owner)).send(address(this).balance);
            return;
        }
        
        if (isExtraDividends) {
            emit SentExtraEthDividends(_from, receiver, matrix, level);
        }
        }
        
        else
        {
          if (!address(uint160(receiver)).send(packageIncome[package][level])) {
            address(uint160(owner)).send(packageIncome[package][level]);
            return;
        }
        
        if (isExtraDividends) {
            emit SentExtraEthDividends(_from, receiver, matrix, level);
        }   
        }
    }
    
  
    
    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }
}