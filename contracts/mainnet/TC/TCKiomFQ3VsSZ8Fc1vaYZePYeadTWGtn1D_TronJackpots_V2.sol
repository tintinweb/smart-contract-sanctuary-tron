//SourceUnit: SmartCOntract_FINAL.sol

pragma solidity 0.5.9;

contract TronJackpots_V2 {
    address private ownerWallet;
       
    
    uint private currUserID = 0;
    uint public currLuckyDrawID = 0;	
    bool public signuppause = true;
	
    uint private pool1currUserID = 0;
    uint private pool2currUserID = 0;
    uint private pool3currUserID = 0;
    uint private pool4currUserID = 0;
    uint private pool5currUserID = 0;
    uint private pool6currUserID = 0;
    uint private pool7currUserID = 0;
    uint private pool8currUserID = 0;
    uint private pool9currUserID = 0;
    uint private pool10currUserID = 0;
    
    uint private pool1UpdateuserID = 0; 
    uint private pool2UpdateuserID = 0; 
    uint private pool3UpdateuserID = 0; 
    uint private pool4UpdateuserID = 0; 
    uint private pool5UpdateuserID = 0; 
    uint private pool6UpdateuserID = 0; 
    uint private pool7UpdateuserID = 0; 
    uint private pool8UpdateuserID = 0; 
    uint private pool9UpdateuserID = 0; 
    uint private pool10UpdateuserID = 0; 	
	
	uint private pool1masterid = 0;
	uint private pool2masterid = 0;
	uint private pool3masterid = 0;
	uint private pool4masterid = 0;
	uint private pool5masterid = 0;
	uint private pool6masterid = 0;
	uint private pool7masterid = 0;
	uint private pool8masterid = 0;
	uint private pool9masterid = 0;
	uint private pool10masterid = 0;
		
    uint private pool1referrerID = 0;
	uint private pool2referrerID = 0;
	uint private pool3referrerID = 0;
	uint private pool4referrerID = 0;
	uint private pool5referrerID = 0;
	uint private pool6referrerID = 0;
	uint private pool7referrerID = 0;
	uint private pool8referrerID = 0;
	uint private pool9referrerID = 0;
	uint private pool10referrerID = 0;
	
    bool private pool1isUpgrade = false;
	bool private pool2isUpgrade = false;
	bool private pool3isUpgrade = false;
	bool private pool4isUpgrade = false;
	bool private pool5isUpgrade = false;
	bool private pool6isUpgrade = false;
	bool private pool7isUpgrade = false;
	bool private pool8isUpgrade = false;
	bool private pool9isUpgrade = false;
	bool private pool10isUpgrade = false;
	
	uint private pool1reentry_no = 1;
	uint private pool2reentry_no = 1;
	uint private pool3reentry_no = 1;
	uint private pool4reentry_no = 1;
	uint private pool5reentry_no = 1;
	uint private pool6reentry_no = 1;
	uint private pool7reentry_no = 1;
	uint private pool8reentry_no = 1;
	uint private pool9reentry_no = 1;
	uint private pool10reentry_no = 1;
	
	uint private pool1masteridroot = 0;
	uint private pool2masteridroot = 0;
	uint private pool3masteridroot = 0;
	uint private pool4masteridroot = 0;
	uint private pool5masteridroot = 0;
	uint private pool6masteridroot = 0;
	uint private pool7masteridroot = 0;
	uint private pool8masteridroot = 0;
	uint private pool9masteridroot = 0;
	uint private pool10masteridroot = 0;
	
	uint private pool1referrerIDroot = 0;
	uint private pool2referrerIDroot = 0;
	uint private pool3referrerIDroot = 0;
	uint private pool4referrerIDroot = 0;
	uint private pool5referrerIDroot = 0;
	uint private pool6referrerIDroot = 0;
	uint private pool7referrerIDroot = 0;
	uint private pool8referrerIDroot = 0;
	uint private pool9referrerIDroot = 0;
	uint private pool10referrerIDroot = 0;	
	
	uint private level1referrerID =0;
	uint private level2referrerID =0;
	uint private level3referrerID =0;
	uint private level4referrerID =0;
	uint private level5referrerID =0;
	uint private level6referrerID =0;
	uint private level7referrerID =0;
	uint private level8referrerID =0;
	uint private level9referrerID =0;
	uint private level10referrerID =0;	
		
	struct UserStruct {
        bool isExist;
        uint id;
        uint referrerID;
    }

    struct LuckyDrawStruct {
       uint id;
	}
	
    struct PoolUserStruct {
        bool isExist;
        bool isUpgrade;
        uint id;
        uint masterid;
		uint referrerID;
        uint reentry_no;
    }

    mapping(address => UserStruct) public users;
    mapping(uint => address) public userList;
	
	mapping(address => LuckyDrawStruct) public luckydraws;
    mapping(uint => address) public luckydrawList;

    mapping(address => PoolUserStruct) public pool1users;
    mapping(uint => address) private pool1userList;
	mapping(uint => PoolUserStruct) public pool1userDetail;

    mapping(address => PoolUserStruct) public pool2users;
    mapping(uint => address) public pool2userList;
	mapping(uint => PoolUserStruct) public pool2userDetail;

    mapping(address => PoolUserStruct) public pool3users;
    mapping(uint => address) public pool3userList;
	mapping(uint => PoolUserStruct) public pool3userDetail;
    
    mapping(address => PoolUserStruct) public pool4users;
    mapping(uint => address) public pool4userList;
	mapping(uint => PoolUserStruct) public pool4userDetail;
    
    mapping(address => PoolUserStruct) public pool5users;
    mapping(uint => address) public pool5userList;
	mapping(uint => PoolUserStruct) public pool5userDetail;
    
    mapping(address => PoolUserStruct) public pool6users;
    mapping(uint => address) public pool6userList;
    mapping(uint => PoolUserStruct) public pool6userDetail;
    
    mapping(address => PoolUserStruct) public pool7users;
    mapping(uint => address) public pool7userList;
    mapping(uint => PoolUserStruct) public pool7userDetail;
    
    mapping(address => PoolUserStruct) public pool8users;
    mapping(uint => address) public pool8userList;
    mapping(uint => PoolUserStruct) public pool8userDetail;
    
    mapping(address => PoolUserStruct) public pool9users;
    mapping(uint => address) public pool9userList;
    mapping(uint => PoolUserStruct) public pool9userDetail;
    
    mapping(address => PoolUserStruct) public pool10users;
    mapping(uint => address) public pool10userList;
    mapping(uint => PoolUserStruct) public pool10userDetail;	
    
	uint sponsorincome = 5 trx;
	
    uint pool1_price = 200 trx;
    uint pool2_price = 300 trx;
    uint pool3_price = 500 trx;
    uint pool4_price = 900 trx;
    uint pool5_price = 1700 trx;
    uint pool6_price = 3300 trx;
    uint pool7_price = 6500 trx;
    uint pool8_price = 12900 trx;
    uint pool9_price = 25700 trx;
    uint pool10_price = 51300 trx;
    
    uint pool1_reentry_income = 100 trx; 
    uint pool2_reentry_income = 300 trx; 
    uint pool3_reentry_income = 700 trx; 
    uint pool4_reentry_income = 1500 trx; 
    uint pool5_reentry_income = 3100 trx; 
    uint pool6_reentry_income = 6300 trx; 
    uint pool7_reentry_income = 12700 trx; 
    uint pool8_reentry_income = 25500 trx; 
    uint pool9_reentry_income = 51100 trx; 
    uint pool10_reentry_income = 102300 trx; 
    
    uint pool1_upgrade_income = 0 trx; 
    uint pool2_upgrade_income = 0 trx; 
    uint pool3_upgrade_income = 100 trx; 
    uint pool4_upgrade_income = 300 trx; 
    uint pool5_upgrade_income = 700 trx; 
    uint pool6_upgrade_income = 1500 trx; 
    uint pool7_upgrade_income = 3100 trx; 
    uint pool8_upgrade_income = 6300 trx; 
    uint pool9_upgrade_income = 12700 trx; 
    uint pool10_upgrade_income = 25500 trx; 
    
    uint pool1_exit_income = 300 trx; 
    uint pool2_exit_income = 600 trx; 
    uint pool3_exit_income = 1200 trx; 
    uint pool4_exit_income = 2400 trx; 
    uint pool5_exit_income = 4800 trx; 
    uint pool6_exit_income = 9600 trx; 
    uint pool7_exit_income = 19200 trx;  
    uint pool8_exit_income = 38400 trx;  
    uint pool9_exit_income = 76800 trx;  
    uint pool10_exit_income = 153600 trx;  
    
    event addpayout(address indexed _user, uint _userid, string _incometype, uint _amount, uint _time);
	event addluckydraw(address indexed _user, uint _userid, uint _luckydrawid, uint _time);
	event adduser(address indexed _user, uint _userid, uint _referrerid, uint _time);
	event adduserpool(address indexed _user, uint _userid, uint _userpoolid, uint _entryreentry, uint _pool, bool _isupgrade, uint _time);
	event addtokenreceive(uint indexed _userid, uint ContractBalance, uint now);
	
    UserStruct[] private requests;
    
    constructor() public {
        ownerWallet = msg.sender;        
    }
	
    ////////////////////////////////////////////////////////////////////////////////////////////
    function buyPool1(uint _referrerID) public payable {
		require(!(signuppause),"Sign Up Been Paused");
        require(!users[msg.sender].isExist, "Address Already Exists");
		require(!pool1users[msg.sender].isExist, "Already in AutoPool 1");
        require(_referrerID > 0 && _referrerID <= currUserID, 'Incorrect Sponsor ID');
        require(msg.value == pool1_price, 'Incorrect Amount Sent');        
       
        UserStruct memory userStruct;
        currUserID++;
        userStruct = UserStruct({
            isExist: true,
            id: currUserID,
            referrerID: _referrerID
        });
        users[msg.sender] = userStruct;
        userList[currUserID] = msg.sender;
    
        LuckyDrawStruct memory luckydrawStruct;
		currLuckyDrawID++;
		luckydrawStruct = LuckyDrawStruct({
			id: currLuckyDrawID
		});
        luckydraws[msg.sender] = luckydrawStruct;
        luckydrawList[currLuckyDrawID] = msg.sender;
        
        PoolUserStruct memory userStructPool;
        pool1currUserID++;
        userStructPool = PoolUserStruct({
            isExist: true,
            isUpgrade: true,
            id: pool1currUserID,
            masterid: currUserID,
            referrerID: _referrerID,
			reentry_no: 1
        });
        pool1users[msg.sender] = userStructPool;
        pool1userList[pool1currUserID] = msg.sender;
		pool1userDetail[pool1currUserID] = userStructPool;
        
        emit adduser(msg.sender, currUserID, _referrerID, now);
        emit addluckydraw(msg.sender, currUserID, currLuckyDrawID, now);
        emit adduserpool(msg.sender, currUserID, pool1currUserID, 1, 1, true, now);
        sendBalance(currUserID);
		payReferral(msg.sender);
        
        if(((pool1currUserID-1)%3==0) && pool1currUserID >=4) {
			pool1UpdateuserID = ((pool1currUserID-1)/3);
            address pool1updateuser = pool1userList[pool1UpdateuserID];
                
			pool1masterid = pool1userDetail[pool1UpdateuserID].masterid;
            pool1referrerID = pool1userDetail[pool1UpdateuserID].referrerID;
            pool1reentry_no = pool1userDetail[pool1UpdateuserID].reentry_no;
				
            Upgrade(pool1updateuser, pool1masterid, 2, pool1referrerID);
    	}
    }
	////////////////////////////////////////////////////////////////////////////////////////////
	function buyPool2() public payable {
		require(!(signuppause),"Sign Up Been Paused");
		require(users[msg.sender].isExist, "Purchase Pool 1 First");
        require(pool1users[msg.sender].isExist, "Purchase Pool 1 First");
        require((!((pool2users[msg.sender].isExist) && (!pool2users[msg.sender].isUpgrade))), "Already in AutoPool 2");
        require(msg.value == pool2_price, 'Incorrect Amount Sent');
        
        LuckyDrawStruct memory luckydrawStruct;
		currLuckyDrawID++;
		luckydrawStruct = LuckyDrawStruct({
			id: currLuckyDrawID
		});
        luckydraws[msg.sender] = luckydrawStruct;
        luckydrawList[currLuckyDrawID] = msg.sender;
        
		pool2masteridroot = users[msg.sender].id;
		pool2referrerIDroot = users[msg.sender].referrerID;
		
        PoolUserStruct memory userStructPool;
        pool2currUserID++;
        userStructPool = PoolUserStruct({
            isExist: true,
            isUpgrade: false,
            id: pool2currUserID,
            masterid: pool2masteridroot,
            referrerID: pool2referrerIDroot,
			reentry_no: 1
        });
        pool2users[msg.sender] = userStructPool;
        pool2userList[pool2currUserID] = msg.sender;
        pool2userDetail[pool2currUserID] = userStructPool;
		
        emit addluckydraw(msg.sender, pool2masteridroot, currLuckyDrawID, now);
        emit adduserpool(msg.sender, pool2masteridroot, pool2currUserID, 1, 2, false, now);
        sendBalance(pool2masteridroot);
		payReferral(msg.sender);
        
        if(((pool2currUserID-1)%3==0) && pool2currUserID >=4) {
			pool2UpdateuserID = ((pool2currUserID-1)/3);
            
			address pool2updateuser = pool2userList[pool2UpdateuserID];
            
            pool2masterid = pool2userDetail[pool2UpdateuserID].masterid;
            pool2referrerID = pool2userDetail[pool2UpdateuserID].referrerID;
            pool2reentry_no = pool2userDetail[pool2UpdateuserID].reentry_no;
			pool2isUpgrade = pool2userDetail[pool2UpdateuserID].isUpgrade;
			
            if ((pool2reentry_no < 3) && !(pool2isUpgrade)) {
				pool2currUserID++;
                    
                userStructPool = PoolUserStruct({
                isExist: true,
                isUpgrade: pool2isUpgrade,
                id: pool2currUserID,
                masterid: pool2masterid ,
                referrerID: pool2referrerID ,
            	reentry_no: pool2reentry_no + 1
            });
                    
            pool2users[pool2updateuser] = userStructPool;
            pool2userList[pool2currUserID] = pool2updateuser;
            pool2userDetail[pool2currUserID] = userStructPool;
			
            currLuckyDrawID++;
            luckydrawStruct = LuckyDrawStruct({
            id: currLuckyDrawID
            });
            luckydraws[pool2updateuser] = luckydrawStruct;
            luckydrawList[currLuckyDrawID] = pool2updateuser;
                    
			emit addluckydraw(pool2updateuser, pool2masterid, currLuckyDrawID, now);
			emit adduserpool(pool2updateuser, pool2masterid, pool2currUserID, pool2reentry_no + 1, 2, pool2isUpgrade, now);
			emit addpayout(pool2updateuser, pool2masterid, "ReEntry Income", pool2_reentry_income,now);
			payReferral(pool2updateuser);
			
			}else{
				if (pool2isUpgrade){
					Upgrade(pool2updateuser, pool2masterid, 3, pool2referrerID);
				}else{
					emit addpayout(pool2updateuser, pool2masterid, "Pool Income", pool2_exit_income, now);
				}
			} 
        }
    }
	////////////////////////////////////////////////////////////////////////////////////////////
	function buyPool3() public payable {
		require(!(signuppause),"Sign Up Been Paused");
		require(users[msg.sender].isExist, "Purchase Pool 1 First");
        require(((pool2users[msg.sender].isExist ) && (!pool2users[msg.sender].isUpgrade)), "Purchase Pool 2 First");
        require((!((pool3users[msg.sender].isExist) && (!pool3users[msg.sender].isUpgrade))), "Already in AutoPool 3");
        require(msg.value == pool3_price, 'Incorrect Amount Sent');
        
        LuckyDrawStruct memory luckydrawStruct;
		currLuckyDrawID++;
		luckydrawStruct = LuckyDrawStruct({
			id: currLuckyDrawID
		});
        luckydraws[msg.sender] = luckydrawStruct;
        luckydrawList[currLuckyDrawID] = msg.sender;
        
		pool3masteridroot = users[msg.sender].id;
		pool3referrerIDroot = users[msg.sender].referrerID;
		
        PoolUserStruct memory userStructPool;
        pool3currUserID++;
        userStructPool = PoolUserStruct({
            isExist: true,
            isUpgrade: false,
            id: pool3currUserID,
            masterid: pool3masteridroot,
            referrerID: pool3referrerIDroot,
			reentry_no: 1
        });
        pool3users[msg.sender] = userStructPool;
        pool3userList[pool3currUserID] = msg.sender;
        pool3userDetail[pool3currUserID] = userStructPool;
		
        emit addluckydraw(msg.sender, pool3masteridroot, currLuckyDrawID, now);
        emit adduserpool(msg.sender, pool3masteridroot, pool3currUserID, 1, 3, false, now);
        sendBalance(pool3masteridroot);
        payReferral(msg.sender);
		
        if(((pool3currUserID-1)%3==0) && pool3currUserID >=4) {
			pool3UpdateuserID = ((pool3currUserID-1)/3);
            address pool3updateuser = pool3userList[pool3UpdateuserID];
                
			pool3masterid = pool3userDetail[pool3UpdateuserID].masterid;
            pool3referrerID = pool3userDetail[pool3UpdateuserID].referrerID;
            pool3reentry_no = pool3userDetail[pool3UpdateuserID].reentry_no;
			pool3isUpgrade = pool3userDetail[pool3UpdateuserID].isUpgrade;
			
				
            if ((pool3reentry_no < 3) && !(pool3isUpgrade)) {
				pool3currUserID++;
                    
                userStructPool = PoolUserStruct({
					isExist: true,
                    isUpgrade: pool3isUpgrade,
                    id: pool3currUserID,
                    masterid: pool3masterid ,
                    referrerID: pool3referrerID ,
            		reentry_no: pool3reentry_no + 1
                });
                    
                pool3users[pool3updateuser] = userStructPool;
                pool3userList[pool3currUserID] = pool3updateuser;
                pool3userDetail[pool3currUserID] = userStructPool;
				
                currLuckyDrawID++;
            	luckydrawStruct = LuckyDrawStruct({
					id: currLuckyDrawID
            	});
                luckydraws[pool3updateuser] = luckydrawStruct;
                luckydrawList[currLuckyDrawID] = pool3updateuser;
                    
				emit addluckydraw(pool3updateuser, pool3masterid, currLuckyDrawID, now);
				emit adduserpool(pool3updateuser, pool3masterid, pool3currUserID, pool3reentry_no + 1, 3, pool3isUpgrade, now);
				emit addpayout(pool3updateuser, pool3masterid, "ReEntry Income", pool3_reentry_income,now);
                payReferral(pool3updateuser);
				
			}else{
				if (pool3isUpgrade){
					Upgrade(pool3updateuser, pool3masterid, 4, pool3referrerID);
				}else{
					emit addpayout(pool3updateuser, pool3masterid, "Pool Income", pool3_exit_income, now);
				}
			} 
        }
    }
    ////////////////////////////////////////////////////////////////////////////////////////////  
	function buyPool4() public payable {
		require(!(signuppause),"Sign Up Been Paused");
		require(users[msg.sender].isExist, "Purchase Pool 1 First");
        require(((pool3users[msg.sender].isExist ) && (!pool3users[msg.sender].isUpgrade)), "Purchase Pool 3 First");
        require((!((pool4users[msg.sender].isExist) && (!pool4users[msg.sender].isUpgrade))), "Already in AutoPool 4");
        require(msg.value == pool4_price, 'Incorrect Amount Sent');
        
        LuckyDrawStruct memory luckydrawStruct;
		currLuckyDrawID++;
		luckydrawStruct = LuckyDrawStruct({
			id: currLuckyDrawID
		});
        luckydraws[msg.sender] = luckydrawStruct;
        luckydrawList[currLuckyDrawID] = msg.sender;
        
		pool4masteridroot = users[msg.sender].id;
		pool4referrerIDroot = users[msg.sender].referrerID;
	
        PoolUserStruct memory userStructPool;
        pool4currUserID++;
        userStructPool = PoolUserStruct({
            isExist: true,
            isUpgrade: false,
            id: pool4currUserID,
            masterid: pool4masteridroot,
            referrerID: pool4referrerIDroot,
			reentry_no: 1
        });
        pool4users[msg.sender] = userStructPool;
        pool4userList[pool4currUserID] = msg.sender;
        pool4userDetail[pool4currUserID] = userStructPool;
		
        emit addluckydraw(msg.sender, pool4masteridroot, currLuckyDrawID, now);
        emit adduserpool(msg.sender, pool4masteridroot, pool4currUserID, 1, 4, false, now);
        sendBalance(pool4masteridroot);
        payReferral(msg.sender);
		
        if(((pool4currUserID-1)%3==0) && pool4currUserID >=4) {
			pool4UpdateuserID = ((pool4currUserID-1)/3);
            address pool4updateuser = pool4userList[pool4UpdateuserID];
                
			pool4masterid = pool4userDetail[pool4UpdateuserID].masterid;
            pool4referrerID = pool4userDetail[pool4UpdateuserID].referrerID;
            pool4reentry_no = pool4userDetail[pool4UpdateuserID].reentry_no;
			pool4isUpgrade = pool4userDetail[pool4UpdateuserID].isUpgrade;
			
				
            if ((pool4reentry_no < 3) && !(pool4isUpgrade)) {
				pool4currUserID++;
                    
                userStructPool = PoolUserStruct({
					isExist: true,
                    isUpgrade: pool4isUpgrade,
                    id: pool4currUserID,
                    masterid: pool4masterid ,
                    referrerID: pool4referrerID ,
            		reentry_no: pool4reentry_no + 1
                });
                    
                pool4users[pool4updateuser] = userStructPool;
                pool4userList[pool4currUserID] = pool4updateuser;
                pool4userDetail[pool4currUserID] = userStructPool;
				
                currLuckyDrawID++;
            	luckydrawStruct = LuckyDrawStruct({
					id: currLuckyDrawID
            	});
                luckydraws[pool4updateuser] = luckydrawStruct;
                luckydrawList[currLuckyDrawID] = pool4updateuser;
                    
				emit addluckydraw(pool4updateuser, pool4masterid, currLuckyDrawID, now);
				emit adduserpool(pool4updateuser, pool4masterid, pool4currUserID, pool4reentry_no + 1, 4, pool4isUpgrade, now);
				emit addpayout(pool4updateuser, pool4masterid, "ReEntry Income", pool4_reentry_income,now);
                payReferral(pool4updateuser);    
                    
                    
            }else{
				if (pool4isUpgrade){
					Upgrade(pool4updateuser, pool4masterid, 5, pool4referrerID);
				}else{
					emit addpayout(pool4updateuser, pool4masterid, "Pool Income", pool4_exit_income, now);
				}
			} 
        }
    }
	///////////////////////
	function buyPool5() public payable {
		require(!(signuppause),"Sign Up Been Paused");
		require(users[msg.sender].isExist, "Purchase Pool 1 First");
        require(((pool4users[msg.sender].isExist ) && (!pool4users[msg.sender].isUpgrade)), "Purchase Pool 4 First");
        require((!((pool5users[msg.sender].isExist) && (!pool5users[msg.sender].isUpgrade))), "Already in AutoPool 5");
        require(msg.value == pool5_price, 'Incorrect Amount Sent');
        
        LuckyDrawStruct memory luckydrawStruct;
		currLuckyDrawID++;
		luckydrawStruct = LuckyDrawStruct({
			id: currLuckyDrawID
		});
        luckydraws[msg.sender] = luckydrawStruct;
        luckydrawList[currLuckyDrawID] = msg.sender;
        
		pool5masteridroot = users[msg.sender].id;
		pool5referrerIDroot = users[msg.sender].referrerID;
	
		
        PoolUserStruct memory userStructPool;
        pool5currUserID++;
        userStructPool = PoolUserStruct({
            isExist: true,
            isUpgrade: false,
            id: pool5currUserID,
            masterid: pool5masteridroot,
            referrerID: pool5referrerIDroot,
			reentry_no: 1
        });
        pool5users[msg.sender] = userStructPool;
        pool5userList[pool5currUserID] = msg.sender;        
		pool5userDetail[pool5currUserID] = userStructPool;
			
        emit addluckydraw(msg.sender, pool5masteridroot, currLuckyDrawID, now);
        emit adduserpool(msg.sender, pool5masteridroot, pool5currUserID, 1, 5, false, now);
        sendBalance(pool5masteridroot);
        payReferral(msg.sender);
		
            if(((pool5currUserID-1)%3==0) && pool5currUserID >=4) {
				pool5UpdateuserID = ((pool5currUserID-1)/3);
                address pool5updateuser = pool5userList[pool5UpdateuserID];
                
				pool5masterid = pool5userDetail[pool5UpdateuserID].masterid;
				pool5referrerID = pool5userDetail[pool5UpdateuserID].referrerID;
				pool5reentry_no = pool5userDetail[pool5UpdateuserID].reentry_no;
				pool5isUpgrade = pool5userDetail[pool5UpdateuserID].isUpgrade;
				
                if ((pool5reentry_no < 3) && !(pool5isUpgrade))  {
					pool5currUserID++;
                    
                    userStructPool = PoolUserStruct({
                        isExist: true,
                        isUpgrade: pool5isUpgrade,
                        id: pool5currUserID,
                        masterid: pool5masterid ,
                        referrerID: pool5referrerID ,
            			reentry_no: pool5reentry_no + 1
                    });
                    
                    pool5users[pool5updateuser] = userStructPool;
                    pool5userList[pool5currUserID] = pool5updateuser;
                    pool5userDetail[pool5currUserID] = userStructPool;
					
                   	currLuckyDrawID++;
            		luckydrawStruct = LuckyDrawStruct({
            			id: currLuckyDrawID
            		});
                    luckydraws[pool5updateuser] = luckydrawStruct;
                    luckydrawList[currLuckyDrawID] = pool5updateuser;
                    
					emit addluckydraw(pool5updateuser, pool5masterid, currLuckyDrawID, now);
					emit adduserpool(pool5updateuser, pool5masterid, pool5currUserID, pool5reentry_no + 1, 5, pool5isUpgrade, now);
					emit addpayout(pool5updateuser, pool5masterid, "ReEntry Income", pool5_reentry_income,now);
                    payReferral(pool5updateuser);
                    
                    
                }else{
					if (pool5isUpgrade){
						Upgrade(pool5updateuser, pool5masterid, 6, pool5referrerID);
					}else{
						emit addpayout(pool5updateuser, pool5masterid, "Pool Income", pool5_exit_income, now);
					}
				} 
            }
       
		    
    }
	
	///////////////////////
	function buyPool6() public payable {
		require(!(signuppause),"Sign Up Been Paused");
		require(users[msg.sender].isExist, "Purchase Pool 1 First");
		require(((pool5users[msg.sender].isExist ) && (!pool5users[msg.sender].isUpgrade)), "Purchase Pool 5 First");
        require((!((pool6users[msg.sender].isExist) && (!pool6users[msg.sender].isUpgrade))), "Already in AutoPool 6");
        require(msg.value == pool6_price, 'Incorrect Amount Sent');
        
        LuckyDrawStruct memory luckydrawStruct;
		currLuckyDrawID++;
		luckydrawStruct = LuckyDrawStruct({
			id: currLuckyDrawID
		});
        luckydraws[msg.sender] = luckydrawStruct;
        luckydrawList[currLuckyDrawID] = msg.sender;
        
		pool6masteridroot = users[msg.sender].id;
		pool6referrerIDroot = users[msg.sender].referrerID;
		
        PoolUserStruct memory userStructPool;
        pool6currUserID++;
        userStructPool = PoolUserStruct({
            isExist: true,
            isUpgrade: false,
            id: pool6currUserID,
            masterid: pool6masteridroot,
            referrerID: pool6referrerIDroot,
			reentry_no: 1
        });
        pool6users[msg.sender] = userStructPool;
        pool6userList[pool6currUserID] = msg.sender;
        pool6userDetail[pool6currUserID] = userStructPool;
		
        emit addluckydraw(msg.sender, pool6masteridroot, currLuckyDrawID, now);
        emit adduserpool(msg.sender, pool6masteridroot, pool6currUserID, 1, 6, false, now);
        sendBalance(pool6masteridroot);
        payReferral(msg.sender);
		
            if(((pool6currUserID-1)%3==0) && pool6currUserID >=4) {
				pool6UpdateuserID = ((pool6currUserID-1)/3);
                address pool6updateuser = pool6userList[pool6UpdateuserID];
                
				pool6masterid = pool6userDetail[pool6UpdateuserID].masterid;
				pool6referrerID = pool6userDetail[pool6UpdateuserID].referrerID;
				pool6reentry_no = pool6userDetail[pool6UpdateuserID].reentry_no;
				pool6isUpgrade = pool6userDetail[pool6UpdateuserID].isUpgrade;
				
                if ((pool6reentry_no < 3) && !(pool6isUpgrade)) {
					pool6currUserID++;
                    
                    userStructPool = PoolUserStruct({
                        isExist: true,
                        isUpgrade: pool6isUpgrade,
                        id: pool6currUserID,
                        masterid: pool6masterid ,
                        referrerID: pool6referrerID ,
            			reentry_no: pool6reentry_no + 1
                    });
                    
                    pool6users[pool6updateuser] = userStructPool;
                    pool6userList[pool6currUserID] = pool6updateuser;
                    pool6userDetail[pool6currUserID] = userStructPool;
					
                   	currLuckyDrawID++;
            		luckydrawStruct = LuckyDrawStruct({
            			id: currLuckyDrawID
            		});
                    luckydraws[pool6updateuser] = luckydrawStruct;
                    luckydrawList[currLuckyDrawID] = pool6updateuser;
                    
					emit addluckydraw(pool6updateuser, pool6masterid, currLuckyDrawID, now);
					emit adduserpool(pool6updateuser, pool6masterid, pool6currUserID, pool6reentry_no + 1, 6, pool6isUpgrade, now);
					emit addpayout(pool6updateuser, pool6masterid, "ReEntry Income", pool6_reentry_income,now);
					payReferral(pool6updateuser);
					
                }else{
					if (pool6isUpgrade){
						Upgrade(pool6updateuser, pool6masterid, 7, pool6referrerID);
					}else{
						emit addpayout(pool6updateuser, pool6masterid, "Pool Income", pool6_exit_income, now);
					}
				} 
            }
       
		    
    }
	
///////////////////////
	function buyPool7() public payable {
		require(!(signuppause),"Sign Up Been Paused");
		require(users[msg.sender].isExist, "Purchase Pool 1 First");
		require(((pool6users[msg.sender].isExist ) && (!pool6users[msg.sender].isUpgrade)), "Purchase Pool 6 First");
        require((!((pool7users[msg.sender].isExist) && (!pool7users[msg.sender].isUpgrade))), "Already in AutoPool 7");
        require(msg.value == pool7_price, 'Incorrect Amount Sent');
        
        LuckyDrawStruct memory luckydrawStruct;
		currLuckyDrawID++;
		luckydrawStruct = LuckyDrawStruct({
			id: currLuckyDrawID
		});
        luckydraws[msg.sender] = luckydrawStruct;
        luckydrawList[currLuckyDrawID] = msg.sender;
        
		pool7masteridroot = users[msg.sender].id;
		pool7referrerIDroot = users[msg.sender].referrerID;
		
        PoolUserStruct memory userStructPool;
        pool7currUserID++;
        userStructPool = PoolUserStruct({
            isExist: true,
            isUpgrade: false,
            id: pool7currUserID,
            masterid: pool7masteridroot,
            referrerID: pool7referrerIDroot,
			reentry_no: 1
        });
        pool7users[msg.sender] = userStructPool;
        pool7userList[pool7currUserID] = msg.sender;
        pool7userDetail[pool7currUserID] = userStructPool;
		
        emit addluckydraw(msg.sender, pool7masteridroot, currLuckyDrawID, now);
        emit adduserpool(msg.sender, pool7masteridroot, pool7currUserID, 1, 7, false, now);
        sendBalance(pool7masteridroot);
        payReferral(msg.sender);
		
            if(((pool7currUserID-1)%3==0) && pool7currUserID >=4) {
				pool7UpdateuserID = ((pool7currUserID-1)/3);
                address pool7updateuser = pool7userList[pool7UpdateuserID];
                
				pool7masterid = pool7userDetail[pool7UpdateuserID].masterid;
				pool7referrerID = pool7userDetail[pool7UpdateuserID].referrerID;
				pool7reentry_no = pool7userDetail[pool7UpdateuserID].reentry_no;
				pool7isUpgrade = pool7userDetail[pool7UpdateuserID].isUpgrade;
				
                if ((pool7reentry_no < 3) && !(pool7isUpgrade)){
					pool7currUserID++;
                    
                    userStructPool = PoolUserStruct({
                        isExist: true,
                        isUpgrade: pool7isUpgrade,
                        id: pool7currUserID,
                        masterid: pool7masterid ,
                        referrerID: pool7referrerID ,
            			reentry_no: pool7reentry_no + 1
                    });
                    
                    pool7users[pool7updateuser] = userStructPool;
                    pool7userList[pool7currUserID] = pool7updateuser;
                    pool7userDetail[pool7currUserID] = userStructPool;
					
                   	currLuckyDrawID++;
            		luckydrawStruct = LuckyDrawStruct({
            			id: currLuckyDrawID
            		});
                    luckydraws[pool7updateuser] = luckydrawStruct;
                    luckydrawList[currLuckyDrawID] = pool7updateuser;
                    
					emit addluckydraw(pool7updateuser, pool7masterid, currLuckyDrawID, now);
					emit adduserpool(pool7updateuser, pool7masterid, pool7currUserID, pool7reentry_no + 1, 7, pool7isUpgrade, now);
					emit addpayout(pool7updateuser, pool7masterid, "ReEntry Income", pool7_reentry_income,now);
					payReferral(pool7updateuser);
					
                }else{
					if (pool7isUpgrade){
						Upgrade(pool7updateuser, pool7masterid, 8, pool7referrerID);
					}else{
						emit addpayout(pool7updateuser, pool7masterid, "Pool Income", pool7_exit_income, now);
					}
				} 
            }
       
		   
    }

///////////////////////
	function buyPool8() public payable {
		require(!(signuppause),"Sign Up Been Paused");
		require(users[msg.sender].isExist, "Purchase Pool 1 First");
		require(((pool7users[msg.sender].isExist ) && (!pool7users[msg.sender].isUpgrade)), "Purchase Pool 7 First");
        require((!((pool8users[msg.sender].isExist) && (!pool8users[msg.sender].isUpgrade))), "Already in AutoPool 8");
        require(msg.value == pool8_price, 'Incorrect Amount Sent');
        
        LuckyDrawStruct memory luckydrawStruct;
		currLuckyDrawID++;
		luckydrawStruct = LuckyDrawStruct({
			id: currLuckyDrawID
		});
        luckydraws[msg.sender] = luckydrawStruct;
        luckydrawList[currLuckyDrawID] = msg.sender;
        
		pool8masteridroot = users[msg.sender].id;
		pool8referrerIDroot = users[msg.sender].referrerID;
		
        PoolUserStruct memory userStructPool;
        pool8currUserID++;
        userStructPool = PoolUserStruct({
            isExist: true,
            isUpgrade: false,
            id: pool8currUserID,
            masterid: pool8masteridroot,
            referrerID: pool8referrerIDroot,
			reentry_no: 1
        });
        pool8users[msg.sender] = userStructPool;
        pool8userList[pool8currUserID] = msg.sender;
        pool8userDetail[pool8currUserID] = userStructPool;
		
        emit addluckydraw(msg.sender, pool8masteridroot, currLuckyDrawID, now);
        emit adduserpool(msg.sender, pool8masteridroot, pool8currUserID, 1, 8, false, now);
        sendBalance(pool8masteridroot);
        payReferral(msg.sender);
		
		
            if(((pool8currUserID-1)%3==0) && pool8currUserID >=4) {
				pool8UpdateuserID = ((pool8currUserID-1)/3);
                address pool8updateuser = pool8userList[pool8UpdateuserID];
                
				pool8masterid = pool8userDetail[pool8UpdateuserID].masterid;
				pool8referrerID = pool8userDetail[pool8UpdateuserID].referrerID;
				pool8reentry_no = pool8userDetail[pool8UpdateuserID].reentry_no;
				pool8isUpgrade = pool8userDetail[pool8UpdateuserID].isUpgrade;
				
				
                if ((pool8reentry_no < 3) && !(pool8isUpgrade)) {
					pool8currUserID++;
                    
                    userStructPool = PoolUserStruct({
                        isExist: true,
                        isUpgrade: pool8isUpgrade,
                        id: pool8currUserID,
                        masterid: pool8masterid ,
                        referrerID: pool8referrerID ,
            			reentry_no: pool8reentry_no + 1
                    });
                    
                    pool8users[pool8updateuser] = userStructPool;
                    pool8userList[pool8currUserID] = pool8updateuser;
                    pool8userDetail[pool8currUserID] = userStructPool;
					
                   	currLuckyDrawID++;
            		luckydrawStruct = LuckyDrawStruct({
            			id: currLuckyDrawID
            		});
                    luckydraws[pool8updateuser] = luckydrawStruct;
                    luckydrawList[currLuckyDrawID] = pool8updateuser;
                    
					emit addluckydraw(pool8updateuser, pool8masterid, currLuckyDrawID, now);
					emit adduserpool(pool8updateuser, pool8masterid, pool8currUserID, pool8reentry_no + 1, 8, pool8isUpgrade, now);
					emit addpayout(pool8updateuser, pool8masterid, "ReEntry Income", pool8_reentry_income,now);
					payReferral(pool8updateuser);
					
                }else{
					if (pool8isUpgrade){
						Upgrade(pool8updateuser, pool8masterid, 9, pool8referrerID);
					}else{
						emit addpayout(pool8updateuser, pool8masterid, "Pool Income", pool8_exit_income, now);
					}
				} 
            }
       
		  
    }
///////////////////////
	function buyPool9() public payable {
		require(!(signuppause),"Sign Up Been Paused");
		require(users[msg.sender].isExist, "Purchase Pool 1 First");
		require(((pool8users[msg.sender].isExist ) && (!pool8users[msg.sender].isUpgrade)), "Purchase Pool 8 First");
        require((!((pool9users[msg.sender].isExist) && (!pool9users[msg.sender].isUpgrade))), "Already in AutoPool 9");
        require(msg.value == pool9_price, 'Incorrect Amount Sent');
        
       
        LuckyDrawStruct memory luckydrawStruct;
		currLuckyDrawID++;
		luckydrawStruct = LuckyDrawStruct({
			id: currLuckyDrawID
		});
        luckydraws[msg.sender] = luckydrawStruct;
        luckydrawList[currLuckyDrawID] = msg.sender;
        
		pool9masteridroot = users[msg.sender].id;
		pool9referrerIDroot = users[msg.sender].referrerID;
		
        PoolUserStruct memory userStructPool;
        pool9currUserID++;
        userStructPool = PoolUserStruct({
            isExist: true,
            isUpgrade: false,
            id: pool9currUserID,
            masterid: pool9masteridroot,
            referrerID: pool9referrerIDroot,
			reentry_no: 1
        });
        pool9users[msg.sender] = userStructPool;
        pool9userList[pool9currUserID] = msg.sender;
        pool9userDetail[pool9currUserID] = userStructPool;
		
        emit addluckydraw(msg.sender, pool9masteridroot, currLuckyDrawID, now);
        emit adduserpool(msg.sender, pool9masteridroot, pool9currUserID, 1, 9, false, now);
        sendBalance(pool9masteridroot);
		payReferral(msg.sender);
        
            if(((pool9currUserID-1)%3==0) && pool9currUserID >=4) {
				pool9UpdateuserID = ((pool9currUserID-1)/3);
                address pool9updateuser = pool9userList[pool9UpdateuserID];
                
				pool9masterid = pool9userDetail[pool9UpdateuserID].masterid;
				pool9referrerID = pool9userDetail[pool9UpdateuserID].referrerID;
				pool9reentry_no = pool9userDetail[pool9UpdateuserID].reentry_no;
				pool9isUpgrade = pool9userDetail[pool9UpdateuserID].isUpgrade;
				
                if ((pool9reentry_no < 3) && !(pool9isUpgrade)) {
					pool9currUserID++;
                    
                    userStructPool = PoolUserStruct({
                        isExist: true,
                        isUpgrade: pool9isUpgrade,
                        id: pool9currUserID,
                        masterid: pool9masterid ,
                        referrerID: pool9referrerID ,
            			reentry_no: pool9reentry_no + 1
                    });
                    
                    pool9users[pool9updateuser] = userStructPool;
                    pool9userList[pool9currUserID] = pool9updateuser;
                    pool9userDetail[pool9currUserID] = userStructPool;
					
                   	currLuckyDrawID++;
            		luckydrawStruct = LuckyDrawStruct({
            			id: currLuckyDrawID
            		});
                    luckydraws[pool9updateuser] = luckydrawStruct;
                    luckydrawList[currLuckyDrawID] = pool9updateuser;
                    
					emit addluckydraw(pool9updateuser, pool9masterid, currLuckyDrawID, now);
					emit adduserpool(pool9updateuser, pool9masterid, pool9currUserID, pool9reentry_no + 1, 9, pool9isUpgrade, now);
					emit addpayout(pool9updateuser, pool9masterid, "ReEntry Income", pool9_reentry_income,now);
					payReferral(pool9updateuser);
					
                }else{
					if (pool9isUpgrade){
						Upgrade(pool9updateuser, pool9masterid, 10, pool9referrerID);
					}else{
						emit addpayout(pool9updateuser, pool9masterid, "Pool Income", pool9_exit_income, now);
					}
				} 
            }
       
		    
    }
//////////////////////////
	function buyPool10() public payable {
		require(!(signuppause),"Sign Up Been Paused");
		require(users[msg.sender].isExist, "Purchase Pool 1 First");
		require(((pool9users[msg.sender].isExist ) && (!pool9users[msg.sender].isUpgrade)), "Purchase Pool 9 First");
        require((!((pool10users[msg.sender].isExist) && (!pool10users[msg.sender].isUpgrade))), "Already in AutoPool 10");
        require(msg.value == pool10_price, 'Incorrect Amount Sent');
        
       
        LuckyDrawStruct memory luckydrawStruct;
		currLuckyDrawID++;
		luckydrawStruct = LuckyDrawStruct({
			id: currLuckyDrawID
		});
        luckydraws[msg.sender] = luckydrawStruct;
        luckydrawList[currLuckyDrawID] = msg.sender;
        
		pool10masteridroot = users[msg.sender].id;
		pool10referrerIDroot = users[msg.sender].referrerID;
		
        PoolUserStruct memory userStructPool;
        pool10currUserID++;
        userStructPool = PoolUserStruct({
            isExist: true,
            isUpgrade: false,
            id: pool10currUserID,
            masterid: pool10masteridroot,
            referrerID: pool10referrerIDroot,
			reentry_no: 1
        });
        pool10users[msg.sender] = userStructPool;
        pool10userList[pool10currUserID] = msg.sender;
        pool10userDetail[pool10currUserID] = userStructPool;
		
        emit addluckydraw(msg.sender, pool10masteridroot, currLuckyDrawID, now);
        emit adduserpool(msg.sender, pool10masteridroot, pool10currUserID, 1, 10, false, now);
        sendBalance(pool10masteridroot);
		payReferral(msg.sender);
        
            if(((pool10currUserID-1)%3==0) && pool10currUserID >=4) {
				pool10UpdateuserID = ((pool10currUserID-1)/3);
                address pool10updateuser = pool10userList[pool10UpdateuserID];
                
				pool10masterid = pool10userDetail[pool10UpdateuserID].masterid;
				pool10referrerID = pool10userDetail[pool10UpdateuserID].referrerID;
				pool10reentry_no = pool10userDetail[pool10UpdateuserID].reentry_no;
				pool10isUpgrade = pool10userDetail[pool10UpdateuserID].isUpgrade;
				
                if ((pool10reentry_no < 3) && !(pool10isUpgrade)) {
					pool10currUserID++;
                    
                    userStructPool = PoolUserStruct({
                        isExist: true,
                        isUpgrade: pool10isUpgrade,
                        id: pool10currUserID,
                        masterid: pool10masterid ,
                        referrerID: pool10referrerID ,
            			reentry_no: pool10reentry_no + 1
                    });
                    
                    pool10users[pool10updateuser] = userStructPool;
                    pool10userList[pool10currUserID] = pool10updateuser;
                    pool10userDetail[pool10currUserID] = userStructPool;
					
                   	currLuckyDrawID++;
            		luckydrawStruct = LuckyDrawStruct({
            			id: currLuckyDrawID
            		});
                    luckydraws[pool10updateuser] = luckydrawStruct;
                    luckydrawList[currLuckyDrawID] = pool10updateuser;
                    
					emit addluckydraw(pool10updateuser, pool10masterid, currLuckyDrawID, now);
					emit adduserpool(pool10updateuser, pool10masterid, pool10currUserID, pool10reentry_no + 1, 10, pool10isUpgrade, now);
					emit addpayout(pool10updateuser, pool10masterid, "ReEntry Income", pool10_reentry_income,now);
					payReferral(pool10updateuser);
                }else{
					emit addpayout(pool10updateuser, pool10masterid,  "Pool Income", pool10_exit_income, now);
				} 
            }
       
		   
    }


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	function Upgrade(address _user, uint _masterid, uint _level, uint _referrerID) internal {
        if (_level == 2) {
            
            LuckyDrawStruct memory luckydrawStruct;
    		currLuckyDrawID++;
    		luckydrawStruct = LuckyDrawStruct({
    			id: currLuckyDrawID
    		});
            luckydraws[_user] = luckydrawStruct;
            luckydrawList[currLuckyDrawID] = _user;
            
            PoolUserStruct memory userStructPool;
            pool2currUserID++;
            userStructPool = PoolUserStruct({
                isExist: true,
                isUpgrade: true,
                id: pool2currUserID,
                masterid: _masterid,
                referrerID: _referrerID,
    			reentry_no: 1
            });
            pool2users[_user] = userStructPool;
            pool2userList[pool2currUserID] = _user;
            pool2userDetail[pool2currUserID] = userStructPool;
			
            //emit addpayout(_user, _masterid, "Upgrade Income", pool2_upgrade_income,now);
            emit addluckydraw(_user, _masterid, currLuckyDrawID, now);
            emit adduserpool(_user, _masterid, pool2currUserID, 1, 2, true, now);
            payReferral(_user);
			
			
            if(((pool2currUserID-1)%3==0) && pool2currUserID >=4) {
				pool2UpdateuserID = ((pool2currUserID-1)/3);
                address pool2updateuser = pool2userList[pool2UpdateuserID];
                
                pool2masterid = pool2userDetail[pool2UpdateuserID].masterid;
				pool2referrerID = pool2userDetail[pool2UpdateuserID].referrerID;
				pool2reentry_no = pool2userDetail[pool2UpdateuserID].reentry_no;
				pool2isUpgrade = pool2userDetail[pool2UpdateuserID].isUpgrade;
				
				
                if ((pool2reentry_no < 3) && !(pool2isUpgrade)) {
					pool2currUserID++;
                    
                    userStructPool = PoolUserStruct({
                        isExist: true,
                        isUpgrade: pool2isUpgrade,
                        id: pool2currUserID,
                        masterid: pool2masterid ,
                        referrerID: pool2referrerID ,
            			reentry_no: pool2reentry_no + 1
                    });
                    pool2users[pool2updateuser] = userStructPool;
                    pool2userList[pool2currUserID] = pool2updateuser;
                    pool2userDetail[pool2currUserID] = userStructPool;
					
                   	currLuckyDrawID++;
            		luckydrawStruct = LuckyDrawStruct({
            			id: currLuckyDrawID
            		});
                    luckydraws[pool2updateuser] = luckydrawStruct;
                    luckydrawList[currLuckyDrawID] = pool2updateuser;
                    
                    emit addpayout(pool2updateuser, pool2masterid, "ReEntry Income", pool2_reentry_income,now);
                    emit addluckydraw(pool2updateuser, pool2masterid, currLuckyDrawID, now);
                    emit adduserpool(pool2updateuser, pool2masterid, pool2currUserID, pool2reentry_no + 1, 2, pool2isUpgrade, now);
                    payReferral(pool2updateuser);
					
                }else{
                    if(pool2isUpgrade){
                        Upgrade(pool2updateuser, pool2masterid, 3, pool2referrerID);
                    }else{
    				    emit addpayout(pool2updateuser, pool2masterid, "Pool Income", pool2_exit_income,now);
                    }
    			} 
            }
        }else if (_level == 3) {
            
            LuckyDrawStruct memory luckydrawStruct;
    		currLuckyDrawID++;
    		luckydrawStruct = LuckyDrawStruct({
    			id: currLuckyDrawID
    		});
            luckydraws[_user] = luckydrawStruct;
            luckydrawList[currLuckyDrawID] = _user;
            
            PoolUserStruct memory userStructPool;
            pool3currUserID++;
            userStructPool = PoolUserStruct({
                isExist: true,
                isUpgrade: true,
                id: pool3currUserID,
                masterid: _masterid,
                referrerID: _referrerID,
    			reentry_no: 1
            });
            pool3users[_user] = userStructPool;
            pool3userList[pool3currUserID] = _user;
            pool3userDetail[pool3currUserID] = userStructPool;
			
            emit addpayout(_user, _masterid, "Upgrade Income", pool3_upgrade_income,now);
            emit addluckydraw(_user, _masterid, currLuckyDrawID, now);
            emit adduserpool(_user, _masterid, pool3currUserID, 1, 3, true, now);
            payReferral(_user);
			
            if(((pool3currUserID-1)%3==0) && pool3currUserID >=4) {
				pool3UpdateuserID = ((pool3currUserID-1)/3);
                address pool3updateuser = pool3userList[pool3UpdateuserID];
                
				pool3masterid = pool3userDetail[pool3UpdateuserID].masterid;
				pool3referrerID = pool3userDetail[pool3UpdateuserID].referrerID;
				pool3reentry_no = pool3userDetail[pool3UpdateuserID].reentry_no;
				pool3isUpgrade = pool3userDetail[pool3UpdateuserID].isUpgrade;
				
                if ((pool3reentry_no < 3) && !(pool3isUpgrade)) {
					pool3currUserID++;
                    
                    userStructPool = PoolUserStruct({
                        isExist: true,
                        isUpgrade: pool3isUpgrade,
                        id: pool3currUserID,
                        masterid: pool3masterid ,
                        referrerID: pool3referrerID ,
            			reentry_no: pool3reentry_no + 1
                    });
                    pool3users[pool3updateuser] = userStructPool;
                    pool3userList[pool3currUserID] = pool3updateuser;
                    pool3userDetail[pool3currUserID] = userStructPool;
					
                   	currLuckyDrawID++;
            		luckydrawStruct = LuckyDrawStruct({
            			id: currLuckyDrawID
            		});
                    luckydraws[pool3updateuser] = luckydrawStruct;
                    luckydrawList[currLuckyDrawID] = pool3updateuser;
                    
                    emit addpayout(pool3updateuser, pool3masterid, "ReEntry Income", pool3_reentry_income,now);
                    emit addluckydraw(pool3updateuser, pool3masterid, currLuckyDrawID, now);
                    emit adduserpool(pool3updateuser, pool3masterid, pool3currUserID, pool3reentry_no + 1, 3, pool3isUpgrade, now);
                    payReferral(pool3updateuser);
					
                }else{
                    if(pool3isUpgrade){
                        Upgrade(pool3updateuser, pool3masterid, 4, pool3referrerID);
                    }else{
    				    emit addpayout(pool3updateuser, pool3masterid, "Pool Income", pool3_exit_income,now);
                    }
    			} 
            }
        }else if (_level == 4) {
            
            LuckyDrawStruct memory luckydrawStruct;
    		currLuckyDrawID++;
    		luckydrawStruct = LuckyDrawStruct({
    			id: currLuckyDrawID
    		});
            luckydraws[_user] = luckydrawStruct;
            luckydrawList[currLuckyDrawID] = _user;
            
            PoolUserStruct memory userStructPool;
            pool4currUserID++;
            userStructPool = PoolUserStruct({
                isExist: true,
                isUpgrade: true,
                id: pool4currUserID,
                masterid: _masterid,
                referrerID: _referrerID,
    			reentry_no: 1
            });
            pool4users[_user] = userStructPool;
            pool4userList[pool4currUserID] = _user;
            pool4userDetail[pool4currUserID] = userStructPool;
			
            emit addpayout(_user, _masterid, "Upgrade Income", pool4_upgrade_income,now);
            emit addluckydraw(_user, _masterid, currLuckyDrawID, now);
            emit adduserpool(_user, _masterid, pool4currUserID, 1, 4, true, now);
            payReferral(_user);
			
            if(((pool4currUserID-1)%3==0) && pool4currUserID >=4) {
				pool4UpdateuserID = ((pool4currUserID-1)/3);
                address pool4updateuser = pool4userList[pool4UpdateuserID];
                
				pool4masterid = pool4userDetail[pool4UpdateuserID].masterid;
				pool4referrerID = pool4userDetail[pool4UpdateuserID].referrerID;
				pool4reentry_no = pool4userDetail[pool4UpdateuserID].reentry_no;
				pool4isUpgrade = pool4userDetail[pool4UpdateuserID].isUpgrade;
				
				
                if ((pool4reentry_no < 3) && !(pool4isUpgrade))  {
					pool4currUserID++;
                    
                    userStructPool = PoolUserStruct({
                        isExist: true,
                        isUpgrade: pool4isUpgrade,
                        id: pool4currUserID,
                        masterid: pool4masterid ,
                        referrerID: pool4referrerID ,
            			reentry_no: pool4reentry_no + 1
                    });
                    pool4users[pool4updateuser] = userStructPool;
                    pool4userList[pool4currUserID] = pool4updateuser;
                    pool4userDetail[pool4currUserID] = userStructPool;
					
                   	currLuckyDrawID++;
            		luckydrawStruct = LuckyDrawStruct({
            			id: currLuckyDrawID
            		});
                    luckydraws[pool4updateuser] = luckydrawStruct;
                    luckydrawList[currLuckyDrawID] = pool4updateuser;
                    
                    emit addpayout(pool4updateuser, pool4masterid, "ReEntry Income", pool4_reentry_income,now);
                    emit addluckydraw(pool4updateuser, pool4masterid, currLuckyDrawID, now);
                    emit adduserpool(pool4updateuser, pool4masterid, pool4currUserID, pool4reentry_no + 1, 4, pool4isUpgrade, now);
                    payReferral(pool4updateuser);
					
                }else{
                    if(pool4isUpgrade){
                        Upgrade(pool4updateuser, pool4masterid, 5, pool4referrerID);
                    }else{
    				    emit addpayout(pool4updateuser, pool4masterid, "Pool Income", pool4_exit_income,now);
                    }
    			} 
            }
        }else if (_level == 5) {
            
            LuckyDrawStruct memory luckydrawStruct;
    		currLuckyDrawID++;
    		luckydrawStruct = LuckyDrawStruct({
    			id: currLuckyDrawID
    		});
            luckydraws[_user] = luckydrawStruct;
            luckydrawList[currLuckyDrawID] = _user;
            
            PoolUserStruct memory userStructPool;
            pool5currUserID++;
            userStructPool = PoolUserStruct({
                isExist: true,
                isUpgrade: true,
                id: pool5currUserID,
                masterid: _masterid,
                referrerID: _referrerID,
    			reentry_no: 1
            });
            pool5users[_user] = userStructPool;
            pool5userList[pool5currUserID] = _user;
            pool5userDetail[pool5currUserID] = userStructPool;
			
            emit addpayout(_user, _masterid, "Upgrade Income", pool5_upgrade_income,now);
            emit addluckydraw(_user, _masterid, currLuckyDrawID, now);
            emit adduserpool(_user, _masterid, pool5currUserID, 1, 5, true, now);
            payReferral(_user);
			
            if(((pool5currUserID-1)%3==0) && pool5currUserID >=4) {
				pool5UpdateuserID = ((pool5currUserID-1)/3);
                address pool5updateuser = pool5userList[pool5UpdateuserID];
                
				pool5masterid = pool5userDetail[pool5UpdateuserID].masterid;
				pool5referrerID = pool5userDetail[pool5UpdateuserID].referrerID;
				pool5reentry_no = pool5userDetail[pool5UpdateuserID].reentry_no;
				pool5isUpgrade = pool5userDetail[pool5UpdateuserID].isUpgrade;
				
                if ((pool5reentry_no < 3) && !(pool5isUpgrade))  {
					pool5currUserID++;
                    
                    userStructPool = PoolUserStruct({
                        isExist: true,
                        isUpgrade: pool5isUpgrade,
                        id: pool5currUserID,
                        masterid: pool5masterid ,
                        referrerID: pool5referrerID ,
            			reentry_no: pool5reentry_no + 1
                    });
                    pool5users[pool5updateuser] = userStructPool;
                    pool5userList[pool5currUserID] = pool5updateuser;
                    pool5userDetail[pool5currUserID] = userStructPool;
					
                   	currLuckyDrawID++;
            		luckydrawStruct = LuckyDrawStruct({
            			id: currLuckyDrawID
            		});
                    luckydraws[pool5updateuser] = luckydrawStruct;
                    luckydrawList[currLuckyDrawID] = pool5updateuser;
                    
                    emit addpayout(pool5updateuser, pool5masterid, "ReEntry Income", pool5_reentry_income,now);
                    emit addluckydraw(pool5updateuser, pool5masterid, currLuckyDrawID, now);
                    emit adduserpool(pool5updateuser, pool5masterid, pool5currUserID, pool5reentry_no + 1, 5, pool5isUpgrade, now);
                    payReferral(pool5updateuser);
					
                }else{
                    if(pool5isUpgrade){
                        Upgrade(pool5updateuser, pool5masterid, 6, pool5referrerID);
                    }else{
    				    emit addpayout(pool5updateuser, pool5masterid, "Pool Income", pool5_exit_income,now);
                    }
    			} 
            }
        }else if (_level == 6) {
            
            LuckyDrawStruct memory luckydrawStruct;
    		currLuckyDrawID++;
    		luckydrawStruct = LuckyDrawStruct({
    			id: currLuckyDrawID
    		});
            luckydraws[_user] = luckydrawStruct;
            luckydrawList[currLuckyDrawID] = _user;
            
            PoolUserStruct memory userStructPool;
            pool6currUserID++;
            userStructPool = PoolUserStruct({
                isExist: true,
                isUpgrade: true,
                id: pool6currUserID,
                masterid: _masterid,
                referrerID: _referrerID,
    			reentry_no: 1
            });
            pool6users[_user] = userStructPool;
            pool6userList[pool6currUserID] = _user;
            pool6userDetail[pool6currUserID] = userStructPool;
			
            emit addpayout(_user, _masterid, "Upgrade Income", pool6_upgrade_income,now);
            emit addluckydraw(_user, _masterid, currLuckyDrawID, now);
            emit adduserpool(_user, _masterid, pool6currUserID, 1, 6, true, now);
            payReferral(_user);
			
            if(((pool6currUserID-1)%3==0) && pool6currUserID >=4) {
				pool6UpdateuserID = ((pool6currUserID-1)/3);
                address pool6updateuser = pool6userList[pool6UpdateuserID];
                
				pool6masterid = pool6userDetail[pool6UpdateuserID].masterid;
				pool6referrerID = pool6userDetail[pool6UpdateuserID].referrerID;
				pool6reentry_no = pool6userDetail[pool6UpdateuserID].reentry_no;
				pool6isUpgrade = pool6userDetail[pool6UpdateuserID].isUpgrade;
				
                if ((pool6reentry_no < 3) && !(pool6isUpgrade)) {
					pool6currUserID++;
                    
                    userStructPool = PoolUserStruct({
                        isExist: true,
                        isUpgrade: pool6isUpgrade,
                        id: pool6currUserID,
                        masterid: pool6masterid ,
                        referrerID: pool6referrerID ,
            			reentry_no: pool6reentry_no + 1
                    });
                    pool6users[pool6updateuser] = userStructPool;
                    pool6userList[pool6currUserID] = pool6updateuser;
					pool6userDetail[pool6currUserID] = userStructPool;
                    
                   	currLuckyDrawID++;
            		luckydrawStruct = LuckyDrawStruct({
            			id: currLuckyDrawID
            		});
                    luckydraws[pool6updateuser] = luckydrawStruct;
                    luckydrawList[currLuckyDrawID] = pool6updateuser;
                    
                    emit addpayout(pool6updateuser, pool6masterid, "ReEntry Income", pool6_reentry_income,now);
                    emit addluckydraw(pool6updateuser, pool6masterid, currLuckyDrawID, now);
                    emit adduserpool(pool6updateuser, pool6masterid, pool6currUserID, pool6reentry_no + 1, 6, pool6isUpgrade, now);
                    payReferral(pool6updateuser);
					
                }else{
                    if(pool6isUpgrade){
                        Upgrade(pool6updateuser, pool6masterid, 7, pool6referrerID);
                    }else{
    				    emit addpayout(pool6updateuser, pool6masterid, "Pool Income", pool6_exit_income,now);
                    }
    			} 
            }
        }else if (_level == 7) {
            
            LuckyDrawStruct memory luckydrawStruct;
    		currLuckyDrawID++;
    		luckydrawStruct = LuckyDrawStruct({
    			id: currLuckyDrawID
    		});
            luckydraws[_user] = luckydrawStruct;
            luckydrawList[currLuckyDrawID] = _user;
            
            PoolUserStruct memory userStructPool;
            pool7currUserID++;
            userStructPool = PoolUserStruct({
                isExist: true,
                isUpgrade: true,
                id: pool7currUserID,
                masterid: _masterid,
                referrerID: _referrerID,
    			reentry_no: 1
            });
            pool7users[_user] = userStructPool;
            pool7userList[pool7currUserID] = _user;
            pool7userDetail[pool7currUserID] = userStructPool;
			
            emit addpayout(_user, _masterid, "Upgrade Income", pool7_upgrade_income,now);
            emit addluckydraw(_user, _masterid, currLuckyDrawID, now);
            emit adduserpool(_user, _masterid, pool7currUserID, 1, 7, true, now);
            payReferral(_user);
			
            if(((pool7currUserID-1)%3==0) && pool7currUserID >=4) {
				pool7UpdateuserID = ((pool7currUserID-1)/3);
                address pool7updateuser = pool7userList[pool7UpdateuserID];
                
				pool7masterid = pool7userDetail[pool7UpdateuserID].masterid;
				pool7referrerID = pool7userDetail[pool7UpdateuserID].referrerID;
				pool7reentry_no = pool7userDetail[pool7UpdateuserID].reentry_no;
				pool7isUpgrade = pool7userDetail[pool7UpdateuserID].isUpgrade;
				
				
                if ((pool7reentry_no < 3) && !(pool7isUpgrade)) {
					pool7currUserID++;
                    
                    userStructPool = PoolUserStruct({
                        isExist: true,
                        isUpgrade: pool7isUpgrade,
                        id: pool7currUserID,
                        masterid: pool7masterid ,
                        referrerID: pool7referrerID ,
            			reentry_no: pool7reentry_no + 1
                    });
                    pool7users[pool7updateuser] = userStructPool;
                    pool7userList[pool7currUserID] = pool7updateuser;
                    pool7userDetail[pool7currUserID] = userStructPool;
					
                   	currLuckyDrawID++;
            		luckydrawStruct = LuckyDrawStruct({
            			id: currLuckyDrawID
            		});
                    luckydraws[pool7updateuser] = luckydrawStruct;
                    luckydrawList[currLuckyDrawID] = pool7updateuser;
                    
                    emit addpayout(pool7updateuser, pool7masterid, "ReEntry Income", pool7_reentry_income,now);
                    emit addluckydraw(pool7updateuser, pool7masterid, currLuckyDrawID, now);
                    emit adduserpool(pool7updateuser, pool7masterid, pool7currUserID, pool7reentry_no + 1, 7, pool7isUpgrade, now);
                    payReferral(pool7updateuser);
					
                }else{
                    if(pool7isUpgrade){
                        Upgrade(pool7updateuser, pool7masterid, 8, pool7referrerID);
                    }else{
    				    emit addpayout(pool7updateuser, pool7masterid, "Pool Income", pool7_exit_income,now);
                    }
    			} 
            }
        }else if (_level == 8) {
            
            LuckyDrawStruct memory luckydrawStruct;
    		currLuckyDrawID++;
    		luckydrawStruct = LuckyDrawStruct({
    			id: currLuckyDrawID
    		});
            luckydraws[_user] = luckydrawStruct;
            luckydrawList[currLuckyDrawID] = _user;
            
            PoolUserStruct memory userStructPool;
            pool8currUserID++;
            userStructPool = PoolUserStruct({
                isExist: true,
                isUpgrade: true,
                id: pool8currUserID,
                masterid: _masterid,
                referrerID: _referrerID,
    			reentry_no: 1
            });
            pool8users[_user] = userStructPool;
            pool8userList[pool8currUserID] = _user;
            pool8userDetail[pool8currUserID] = userStructPool;
			
            emit addpayout(_user, _masterid, "Upgrade Income", pool8_upgrade_income,now);
            emit addluckydraw(_user, _masterid, currLuckyDrawID, now);
            emit adduserpool(_user, _masterid, pool8currUserID, 1, 8, true, now);
            payReferral(_user);
			
            if(((pool8currUserID-1)%3==0) && pool8currUserID >=4) {
				pool8UpdateuserID = ((pool8currUserID-1)/3);
                address pool8updateuser = pool8userList[pool8UpdateuserID];
                
				pool8masterid = pool8userDetail[pool8UpdateuserID].masterid;
				pool8referrerID = pool8userDetail[pool8UpdateuserID].referrerID;
				pool8reentry_no = pool8userDetail[pool8UpdateuserID].reentry_no;
				pool8isUpgrade = pool8userDetail[pool8UpdateuserID].isUpgrade;
				
				
                if ((pool8reentry_no < 3) && !(pool8isUpgrade)) {
					pool8currUserID++;
                    
                    userStructPool = PoolUserStruct({
                        isExist: true,
                        isUpgrade: pool8isUpgrade,
                        id: pool8currUserID,
                        masterid: pool8masterid ,
                        referrerID: pool8referrerID ,
            			reentry_no: pool8reentry_no + 1
                    });
                    pool8users[pool8updateuser] = userStructPool;
                    pool8userList[pool8currUserID] = pool8updateuser;
                    pool8userDetail[pool8currUserID] = userStructPool;
					
                   	currLuckyDrawID++;
            		luckydrawStruct = LuckyDrawStruct({
            			id: currLuckyDrawID
            		});
                    luckydraws[pool8updateuser] = luckydrawStruct;
                    luckydrawList[currLuckyDrawID] = pool8updateuser;
                    
                    emit addpayout(pool8updateuser, pool8masterid, "ReEntry Income", pool8_reentry_income,now);
                    emit addluckydraw(pool8updateuser, pool8masterid, currLuckyDrawID, now);
                    emit adduserpool(pool8updateuser, pool8masterid, pool8currUserID, pool8reentry_no + 1, 8, pool8isUpgrade, now);
                    payReferral(pool8updateuser);
					
                }else{
                    if(pool8isUpgrade){
                        Upgrade(pool8updateuser, pool8masterid, 9, pool8referrerID);
                    }else{
    				    emit addpayout(pool8updateuser, pool8masterid, "Pool Income", pool8_exit_income,now);
                    }
    			} 
            }
        }else if (_level == 9) {
            
            LuckyDrawStruct memory luckydrawStruct;
    		currLuckyDrawID++;
    		luckydrawStruct = LuckyDrawStruct({
    			id: currLuckyDrawID
    		});
            luckydraws[_user] = luckydrawStruct;
            luckydrawList[currLuckyDrawID] = _user;
            
            PoolUserStruct memory userStructPool;
            pool9currUserID++;
            userStructPool = PoolUserStruct({
                isExist: true,
                isUpgrade: true,
                id: pool9currUserID,
                masterid: _masterid,
                referrerID: _referrerID,
    			reentry_no: 1
            });
            pool9users[_user] = userStructPool;
            pool9userList[pool9currUserID] = _user;
            pool9userDetail[pool9currUserID] = userStructPool;
			
            emit addpayout(_user, _masterid, "Upgrade Income", pool9_upgrade_income,now);
            emit addluckydraw(_user, _masterid, currLuckyDrawID, now);
            emit adduserpool(_user, _masterid, pool9currUserID, 1, 9, true, now);
            payReferral(_user);
			
            if(((pool9currUserID-1)%3==0) && pool9currUserID >=4) {
				pool9UpdateuserID = ((pool9currUserID-1)/3);
                address pool9updateuser = pool9userList[pool9UpdateuserID];
                
				pool9masterid = pool9userDetail[pool9UpdateuserID].masterid;
				pool9referrerID = pool9userDetail[pool9UpdateuserID].referrerID;
				pool9reentry_no = pool9userDetail[pool9UpdateuserID].reentry_no;
				pool9isUpgrade = pool9userDetail[pool9UpdateuserID].isUpgrade;
				
                if ((pool9reentry_no < 3) && !(pool9isUpgrade))  {
					pool9currUserID++;
                    
                    userStructPool = PoolUserStruct({
                        isExist: true,
                        isUpgrade: pool9users[pool9updateuser].isUpgrade,
                        id: pool9currUserID,
                        masterid: pool9masterid ,
                        referrerID: pool9referrerID ,
            			reentry_no: pool9reentry_no + 1
                    });
                    pool9users[pool9updateuser] = userStructPool;
                    pool9userList[pool9currUserID] = pool9updateuser;
                    pool9userDetail[pool9currUserID] = userStructPool;
					
                   	currLuckyDrawID++;
            		luckydrawStruct = LuckyDrawStruct({
            			id: currLuckyDrawID
            		});
                    luckydraws[pool9updateuser] = luckydrawStruct;
                    luckydrawList[currLuckyDrawID] = pool9updateuser;
                    
                    emit addpayout(pool9updateuser, pool9masterid, "ReEntry Income", pool9_reentry_income,now);
                    emit addluckydraw(pool9updateuser, pool9masterid, currLuckyDrawID, now);
                    emit adduserpool(pool9updateuser, pool9masterid, pool9currUserID, pool9reentry_no + 1, 9, pool9isUpgrade, now);
                    payReferral(pool9updateuser);
					
                }else{
                    if(pool9isUpgrade){
                        Upgrade(pool9updateuser, pool9masterid, 10, pool9referrerID);
                    }else{
    				    emit addpayout(pool9updateuser, pool9masterid, "Pool Income", pool9_exit_income,now);
                    }
    			} 
            }
        }else if (_level == 10) {
            
            LuckyDrawStruct memory luckydrawStruct;
    		currLuckyDrawID++;
    		luckydrawStruct = LuckyDrawStruct({
    			id: currLuckyDrawID
    		});
            luckydraws[_user] = luckydrawStruct;
            luckydrawList[currLuckyDrawID] = _user;
            
            PoolUserStruct memory userStructPool;
            pool10currUserID++;
            userStructPool = PoolUserStruct({
                isExist: true,
                isUpgrade: true,
                id: pool10currUserID,
                masterid: _masterid,
                referrerID: _referrerID,
    			reentry_no: 1
            });
            pool10users[_user] = userStructPool;
            pool10userList[pool10currUserID] = _user;
            pool10userDetail[pool10currUserID] = userStructPool;
			
            emit addpayout(_user, _masterid, "Upgrade Income", pool10_upgrade_income,now);
            emit addluckydraw(_user, _masterid, currLuckyDrawID, now);
            emit adduserpool(_user, _masterid, pool10currUserID, 1, 10, true, now);
            payReferral(_user);
			
            if(((pool10currUserID-1)%3==0) && pool10currUserID >=4) {
				pool10UpdateuserID = ((pool10currUserID-1)/3);
                address pool10updateuser = pool10userList[pool10UpdateuserID];
                
				pool10masterid = pool10userDetail[pool10UpdateuserID].masterid;
				pool10referrerID = pool10userDetail[pool10UpdateuserID].referrerID;
				pool10reentry_no = pool10userDetail[pool10UpdateuserID].reentry_no;
				pool10isUpgrade = pool10userDetail[pool10UpdateuserID].isUpgrade;
				
                if ((pool10reentry_no < 3) && !(pool10isUpgrade)) {
					pool10currUserID++;
                    
                    userStructPool = PoolUserStruct({
                        isExist: true,
                        isUpgrade: pool10isUpgrade,
                        id: pool10currUserID,
                        masterid: pool10masterid,
                        referrerID: pool10referrerID ,
            			reentry_no: pool10reentry_no + 1
                    });
                    pool10users[pool10updateuser] = userStructPool;
                    pool10userList[pool10currUserID] = pool10updateuser;
                    pool10userDetail[pool10currUserID] = userStructPool;
					
                   	currLuckyDrawID++;
            		luckydrawStruct = LuckyDrawStruct({
            			id: currLuckyDrawID
            		});
                    luckydraws[pool10updateuser] = luckydrawStruct;
                    luckydrawList[currLuckyDrawID] = pool10updateuser;
                    
                    emit addpayout(pool10updateuser, pool10masterid, "ReEntry Income", pool10_reentry_income,now);
                    emit addluckydraw(pool10updateuser, pool10masterid, currLuckyDrawID, now);
                    emit adduserpool(pool10updateuser, pool10masterid, pool10currUserID, pool10reentry_no + 1, 10, pool10isUpgrade, now);
                    payReferral(pool10updateuser);
					
                }else{
                    emit addpayout(pool10updateuser, pool10masterid, "Pool Income", pool10_exit_income,now);
                } 
            }
        }
    }
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
	function payReferral(address _newuseraddress) internal {
		level1referrerID = users[_newuseraddress].referrerID;
		address level1referreraddress = userList[level1referrerID];
		
		if (level1referrerID> 0){
			emit addpayout(level1referreraddress, level1referrerID, "Sponsor Income", sponsorincome ,now);
			
			level2referrerID = users[level1referreraddress].referrerID;
		    address level2referreraddress = userList[level2referrerID];
		    
		    if (level2referrerID> 0){
		        emit addpayout(level2referreraddress, level2referrerID, "Sponsor Income", sponsorincome ,now);
			
                level3referrerID = users[level2referreraddress].referrerID;
        		address level3referreraddress = userList[level3referrerID];
        		
        		if (level3referrerID> 0){
    		        emit addpayout(level3referreraddress, level3referrerID, "Sponsor Income", sponsorincome ,now);
    			
                    level4referrerID = users[level3referreraddress].referrerID;
            		address level4referreraddress = userList[level4referrerID];
        		
        		    if (level4referrerID> 0){
        		        emit addpayout(level4referreraddress, level4referrerID, "Sponsor Income", sponsorincome ,now);
        			
                        level5referrerID = users[level4referreraddress].referrerID;
                		address level5referreraddress = userList[level5referrerID];
            		
            		    if (level5referrerID> 0){
            		        emit addpayout(level5referreraddress, level5referrerID, "Sponsor Income", sponsorincome ,now);
            			
                            level6referrerID = users[level5referreraddress].referrerID;
                		    address level6referreraddress = userList[level6referrerID];
                		
                		    if (level6referrerID> 0){
                		        emit addpayout(level6referreraddress, level6referrerID, "Sponsor Income", sponsorincome ,now);
                			
                                level7referrerID = users[level6referreraddress].referrerID;
                    		    address level7referreraddress = userList[level7referrerID];
                    		
                    		    if (level7referrerID> 0){
                    		        emit addpayout(level7referreraddress, level7referrerID, "Sponsor Income", sponsorincome ,now);
                    			
                                    level8referrerID = users[level7referreraddress].referrerID;
                        		    address level8referreraddress = userList[level8referrerID];
                        		    
                        		    if (level8referrerID> 0){
                        		        emit addpayout(level8referreraddress, level8referrerID, "Sponsor Income", sponsorincome ,now);
                        			
                                        level9referrerID = users[level8referreraddress].referrerID;
                            		    address level9referreraddress = userList[level9referrerID];
                            	    
                            	        if (level9referrerID> 0){
                            		        emit addpayout(level9referreraddress, level9referrerID, "Sponsor Income", sponsorincome ,now);
                            			
                                            level10referrerID = users[level9referreraddress].referrerID;
                                		    address level10referreraddress = userList[level10referrerID];
                                	    
                            		        if (level10referrerID> 0){
                                		        emit addpayout(level10referreraddress, level10referrerID, "Sponsor Income", sponsorincome ,now);
                                			}
                            		    }
                        		    }
                        	    }
                    		}
                		}
            		}
        		} 
		    }      
		}
	}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    function getTrxBalance() public view returns(uint) {
        return address(this).balance;
    }
    
    function sendBalance(uint _userid) private{
        uint ContractBalance = getTrxBalance();
        if (ContractBalance>0){
            if (!address(uint160(ownerWallet)).send(ContractBalance)) {
            }
            emit addtokenreceive(_userid, ContractBalance, now);
        }
    }
    
    function withdrawSafe(uint _amount) external {
        require(msg.sender == ownerWallet, 'Permission denied');
        if (_amount > 0) {
            uint contractBalance = address(this).balance;
            if (contractBalance > 0) {
                uint amtToTransfer = _amount > contractBalance ? contractBalance : _amount;
                msg.sender.transfer(amtToTransfer);
            }
       }
   }
   
	function SignUpPaused(bool _issignup_paused) public {
		require(msg.sender == ownerWallet, 'Permission denied');
		
		signuppause = _issignup_paused;
    }
	

	function VersionUpgradeUser(uint256 _UpgradeAddress, uint _userid_upgrade, uint _referrerID_upgrade) public {
		require(msg.sender == ownerWallet, 'Permission denied');
		
		address useraddress = address(_UpgradeAddress);
		
		UserStruct memory userStruct;
		currUserID++;
        userStruct = UserStruct({
            isExist: true,
            id: _userid_upgrade,
            referrerID: _referrerID_upgrade
        });
        users[useraddress] = userStruct;
        userList[_userid_upgrade] = useraddress;
    }
	
	function VersionUpgradeLuckyDraw(uint256 _UpgradeAddress, uint _luckydrawid_upgrade) public {
		require(msg.sender == ownerWallet, 'Permission denied');
		
		address useraddress = address(_UpgradeAddress);
		
		LuckyDrawStruct memory luckydrawStruct;
		currLuckyDrawID++;
		luckydrawStruct = LuckyDrawStruct({
			id: _luckydrawid_upgrade
		});
        luckydraws[useraddress] = luckydrawStruct;
        luckydrawList[_luckydrawid_upgrade] =useraddress;

	}
	
	function VersionUpgradeUserPool1(uint256 _UpgradeAddress, uint _masterid_upgrade, uint _pooluserid_upgrade,  uint _referrerID_upgrade,  bool _isupgrade_upgrade, uint _reentryno_upgrade) public {
		require(msg.sender == ownerWallet, 'Permission denied');
		
		address useraddress = address(_UpgradeAddress);
		
		PoolUserStruct memory userStructPool;
		pool1currUserID++;
		
		userStructPool = PoolUserStruct({
            isExist: true,
            isUpgrade: _isupgrade_upgrade,
            id: _pooluserid_upgrade,
            masterid: _masterid_upgrade,
            referrerID: _referrerID_upgrade,
			reentry_no: _reentryno_upgrade
        });
		
		pool1users[useraddress] = userStructPool;
		pool1userList[_pooluserid_upgrade] = useraddress;
		pool1userDetail[_pooluserid_upgrade] = userStructPool;
	}
	
	function VersionUpgradeUserPool2(uint256 _UpgradeAddress, uint _masterid_upgrade, uint _pooluserid_upgrade,  uint _referrerID_upgrade,  bool _isupgrade_upgrade, uint _reentryno_upgrade) public {
		require(msg.sender == ownerWallet, 'Permission denied');
		
		address useraddress = address(_UpgradeAddress);
		
		PoolUserStruct memory userStructPool;
		pool2currUserID++;
		
		userStructPool = PoolUserStruct({
            isExist: true,
            isUpgrade: _isupgrade_upgrade,
            id: _pooluserid_upgrade,
            masterid: _masterid_upgrade,
            referrerID: _referrerID_upgrade,
			reentry_no: _reentryno_upgrade
        });
		
		pool2users[useraddress] = userStructPool;
		pool2userList[_pooluserid_upgrade] = useraddress;
		pool2userDetail[_pooluserid_upgrade] = userStructPool;
	}

	function VersionUpgradeUserPool3(uint256 _UpgradeAddress, uint _masterid_upgrade, uint _pooluserid_upgrade,  uint _referrerID_upgrade,  bool _isupgrade_upgrade, uint _reentryno_upgrade) public {
		require(msg.sender == ownerWallet, 'Permission denied');
		
		address useraddress = address(_UpgradeAddress);
		
		PoolUserStruct memory userStructPool;
		pool3currUserID++;
		
		userStructPool = PoolUserStruct({
            isExist: true,
            isUpgrade: _isupgrade_upgrade,
            id: _pooluserid_upgrade,
            masterid: _masterid_upgrade,
            referrerID: _referrerID_upgrade,
			reentry_no: _reentryno_upgrade
        });
		
		pool3users[useraddress] = userStructPool;
		pool3userList[_pooluserid_upgrade] = useraddress;
		pool3userDetail[_pooluserid_upgrade] = userStructPool;
	}
	
	function VersionUpgradeUserPool4(uint256 _UpgradeAddress, uint _masterid_upgrade, uint _pooluserid_upgrade,  uint _referrerID_upgrade,  bool _isupgrade_upgrade, uint _reentryno_upgrade) public {
		require(msg.sender == ownerWallet, 'Permission denied');
		
		address useraddress = address(_UpgradeAddress);
		
		PoolUserStruct memory userStructPool;
		pool4currUserID++;
		
		userStructPool = PoolUserStruct({
            isExist: true,
            isUpgrade: _isupgrade_upgrade,
            id: _pooluserid_upgrade,
            masterid: _masterid_upgrade,
            referrerID: _referrerID_upgrade,
			reentry_no: _reentryno_upgrade
        });
		
		pool4users[useraddress] = userStructPool;
		pool4userList[_pooluserid_upgrade] = useraddress;
		pool4userDetail[_pooluserid_upgrade] = userStructPool;
	}
	
	function VersionUpgradeUserPool5(uint256 _UpgradeAddress, uint _masterid_upgrade, uint _pooluserid_upgrade,  uint _referrerID_upgrade,  bool _isupgrade_upgrade, uint _reentryno_upgrade) public {
		require(msg.sender == ownerWallet, 'Permission denied');
		
		address useraddress = address(_UpgradeAddress);
		
		PoolUserStruct memory userStructPool;
		pool5currUserID++;
		
		userStructPool = PoolUserStruct({
            isExist: true,
            isUpgrade: _isupgrade_upgrade,
            id: _pooluserid_upgrade,
            masterid: _masterid_upgrade,
            referrerID: _referrerID_upgrade,
			reentry_no: _reentryno_upgrade
        });
		
		pool5users[useraddress] = userStructPool;
		pool5userList[_pooluserid_upgrade] = useraddress;
		pool5userDetail[_pooluserid_upgrade] = userStructPool;
	}
	
	function VersionUpgradeUserPool6(uint256 _UpgradeAddress, uint _masterid_upgrade, uint _pooluserid_upgrade,  uint _referrerID_upgrade,  bool _isupgrade_upgrade, uint _reentryno_upgrade) public {
		require(msg.sender == ownerWallet, 'Permission denied');
		
		address useraddress = address(_UpgradeAddress);
		
		PoolUserStruct memory userStructPool;
		pool6currUserID++;
		
		userStructPool = PoolUserStruct({
            isExist: true,
            isUpgrade: _isupgrade_upgrade,
            id: _pooluserid_upgrade,
            masterid: _masterid_upgrade,
            referrerID: _referrerID_upgrade,
			reentry_no: _reentryno_upgrade
        });
		
		pool6users[useraddress] = userStructPool;
		pool6userList[_pooluserid_upgrade] = useraddress;
		pool6userDetail[_pooluserid_upgrade] = userStructPool;
	}
	
	function VersionUpgradeUserPool7(uint256 _UpgradeAddress, uint _masterid_upgrade, uint _pooluserid_upgrade,  uint _referrerID_upgrade,  bool _isupgrade_upgrade, uint _reentryno_upgrade) public {
		require(msg.sender == ownerWallet, 'Permission denied');
		
		address useraddress = address(_UpgradeAddress);
		
		PoolUserStruct memory userStructPool;
		pool7currUserID++;
		
		userStructPool = PoolUserStruct({
            isExist: true,
            isUpgrade: _isupgrade_upgrade,
            id: _pooluserid_upgrade,
            masterid: _masterid_upgrade,
            referrerID: _referrerID_upgrade,
			reentry_no: _reentryno_upgrade
        });
		
		pool7users[useraddress] = userStructPool;
		pool7userList[_pooluserid_upgrade] = useraddress;
		pool7userDetail[_pooluserid_upgrade] = userStructPool;
	}
	
	function VersionUpgradeUserPool8(uint256 _UpgradeAddress, uint _masterid_upgrade, uint _pooluserid_upgrade,  uint _referrerID_upgrade,  bool _isupgrade_upgrade, uint _reentryno_upgrade) public {
		require(msg.sender == ownerWallet, 'Permission denied');
		
		address useraddress = address(_UpgradeAddress);
		
		PoolUserStruct memory userStructPool;
		pool8currUserID++;
		
		userStructPool = PoolUserStruct({
            isExist: true,
            isUpgrade: _isupgrade_upgrade,
            id: _pooluserid_upgrade,
            masterid: _masterid_upgrade,
            referrerID: _referrerID_upgrade,
			reentry_no: _reentryno_upgrade
        });
		
		pool8users[useraddress] = userStructPool;
		pool8userList[_pooluserid_upgrade] = useraddress;
		pool8userDetail[_pooluserid_upgrade] = userStructPool;
	}
	
	function VersionUpgradeUserPool9(uint256 _UpgradeAddress, uint _masterid_upgrade, uint _pooluserid_upgrade,  uint _referrerID_upgrade,  bool _isupgrade_upgrade, uint _reentryno_upgrade) public {
		require(msg.sender == ownerWallet, 'Permission denied');
		
		address useraddress = address(_UpgradeAddress);
		
		PoolUserStruct memory userStructPool;
		pool9currUserID++;
		
		userStructPool = PoolUserStruct({
            isExist: true,
            isUpgrade: _isupgrade_upgrade,
            id: _pooluserid_upgrade,
            masterid: _masterid_upgrade,
            referrerID: _referrerID_upgrade,
			reentry_no: _reentryno_upgrade
        });
		
		pool9users[useraddress] = userStructPool;
		pool9userList[_pooluserid_upgrade] = useraddress;
		pool9userDetail[_pooluserid_upgrade] = userStructPool;
	}
	
	function VersionUpgradeUserPool10(uint256 _UpgradeAddress, uint _masterid_upgrade, uint _pooluserid_upgrade,  uint _referrerID_upgrade,  bool _isupgrade_upgrade, uint _reentryno_upgrade) public {
		require(msg.sender == ownerWallet, 'Permission denied');
		
		address useraddress = address(_UpgradeAddress);
		
		PoolUserStruct memory userStructPool;
		pool10currUserID++;
		
		userStructPool = PoolUserStruct({
            isExist: true,
            isUpgrade: _isupgrade_upgrade,
            id: _pooluserid_upgrade,
            masterid: _masterid_upgrade,
            referrerID: _referrerID_upgrade,
			reentry_no: _reentryno_upgrade
        });
		
		pool10users[useraddress] = userStructPool;
		pool10userList[_pooluserid_upgrade] = useraddress;
		pool10userDetail[_pooluserid_upgrade] = userStructPool;
	}
	
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        
 }