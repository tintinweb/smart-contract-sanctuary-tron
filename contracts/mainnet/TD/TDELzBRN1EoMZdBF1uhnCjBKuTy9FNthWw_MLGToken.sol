//SourceUnit: token.sol

    pragma solidity ^0.4.11;
 
    /**
     * ERC 20 token
     *
     * https://github.com/ethereum/EIPs/issues/20
     */
 
    /**
     * Math operations with safety checks
     */
    contract SafeMath {
        function safeMul(uint256 a, uint256 b) internal returns (uint256) {
            if (a == 0) {
                return 0;
            }
            uint256 c = a * b;
            require(c / a == b);
            return c;
        }
 
        function safeDiv(uint256 a, uint256 b) internal returns (uint256) {
            require(b > 0);
            uint256 c = a / b;
            require(a == b * c + a % b);
            return c;
        }
 
        function safeSub(uint256 a, uint256 b) internal returns (uint256) {
            require(b <= a);
            return a - b;
        }
 
        function safeAdd(uint256 a, uint256 b) internal returns (uint256) {
            uint256 c = a + b;
            require(c>=a && c>=b);
            return c;
        }
    }
 
    contract MLGToken is SafeMath{
        string public constant name = "MLG Token";
        string public constant symbol = "MLG";
        uint public constant decimals = 18;
        uint256 _totalSupply = SafeMath.safeMul(679 , 10**uint256(decimals));
 
        function totalSupply() constant returns (uint256 supply) {
            return _totalSupply;
        }
 
        function balanceOf(address _owner) constant returns (uint256 balance) {
            return balances[_owner];
        }
 
        function approve(address _spender, uint256 _value) returns (bool success) {
            allowed[msg.sender][_spender] = _value;
            Approval(msg.sender, _spender, _value);
            return true;
        }
 
        function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
            return allowed[_owner][_spender];
        }
 
        mapping(address => uint256) balances;         //list of balance of each address
        mapping(address => uint256) distBalances;     //list of distributed balance of each address to calculate restricted amount
        mapping(address => mapping (address => uint256)) allowed;
        mapping(address => uint256) timestamp;        //每个地址对应一个时间戳
 
        uint public baseStartTime;                    //All other time spots are calculated based on this time spot.
 
        // Initial founder address (set in constructor)
        // All deposited ETH will be instantly forwarded to this address.
        address public founder = 0x0;
 
        uint256 public distributed = 0;
 
        event AllocateFounderTokens(address indexed sender);
        event Transfer(address indexed _from, address indexed _to, uint256 _value);
        event Approval(address indexed _owner, address indexed _spender, uint256 _value);
 
        //constructor
        function DABToken() {
            founder = msg.sender;
            baseStartTime = block.timestamp;
        }
 
        function setStartTime(uint _startTime) {
            require(msg.sender == founder);
            baseStartTime = _startTime;
        }
 
        /**
         * Distribute tokens out.
         *
         * Security review
         *
         * Applicable tests:
         */
        function distribute(uint256 _amount, address _to) {
            require(msg.sender == founder);
            require((_to == founder) || ((_to != founder) && (distBalances[_to] == 0))); //每个账号只能分发一次
 
            require(distributed + _amount >= distributed);
            require(distributed + _amount <= _totalSupply);
 
            distributed = SafeMath.safeAdd(distributed , _amount);
            balances[_to] = SafeMath.safeAdd(balances[_to] , _amount);
            distBalances[_to] = SafeMath.safeAdd(distBalances[_to] , _amount);
            timestamp[_to] = block.timestamp;                        //分发的时候记录时间戳，用于计算freeAmount
 
        }
 
        /**
         * ERC 20 Standard Token interface transfer function
         *
         * Prevent transfers until freeze period is over.
         */
        function transfer(address _to, uint256 _value) returns (bool success) {
            require(_to != 0x0);
            require(_to != msg.sender);
            require(now > baseStartTime);
 
            //Default assumes totalSupply can't be over max (2^256 - 1).
            //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
            //Replace the if with this one instead.
            if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
                uint _freeAmount = freeAmount(msg.sender);
                if (_freeAmount < _value) {
                    return false;
                }
 
                balances[msg.sender] = SafeMath.safeSub(balances[msg.sender] , _value);
                balances[_to] = SafeMath.safeAdd(balances[_to] , _value);
                Transfer(msg.sender, _to, _value);
                return true;
            } else {
                return false;
            }
        }
 
        function freeAmount(address user) internal returns (uint256 amount) {
            uint monthDiff;
            uint unrestricted;
 
            //0) no restriction for founder
            if (user == founder) {
                return balances[user];
            }
 
            //1) no free amount before base start time;
            if (now < baseStartTime) {
                return 0;
            }
 
            //2) calculate number of months passed since base start time;
            //此处增加判断
            if (now < timestamp[user]) {
                monthDiff = 0;
            }else{
                monthDiff = SafeMath.safeSub(now , timestamp[user]) / (30 days);   //此处改为每个账号按照自己的时间
			}
 
            //3) if it is over 10 months, free up everything.
            if (monthDiff >= 10) {
                return balances[user];
            }
 
            //4) calculate amount of unrestricted within distributed amount.
            if (now < timestamp[user]) {
                unrestricted = 0;
            }else{
                unrestricted = SafeMath.safeAdd(distBalances[user] / 10 , SafeMath.safeMul(distBalances[user] , monthDiff) / 10);
            }
            if (unrestricted > distBalances[user]) {
                unrestricted = distBalances[user];
            }
 
            //5) calculate total free amount including those not from distribution
            if (unrestricted + balances[user] < distBalances[user]) {
                amount = 0;
            } else {
                amount = SafeMath.safeSub(SafeMath.safeAdd(unrestricted , balances[user]) , distBalances[user]);
            }
 
            return amount;
        }
 
        function getFreeAmount(address user) constant returns (uint256 amount) {
            amount = freeAmount(user);
            return amount;
        }
 
        function getRestrictedAmount(address user) constant returns (uint256 amount) {
            amount = balances[user] - freeAmount(user);
            return amount;
        }
 
        /**
         * Change founder address (where ICO ETH is being forwarded).
         */
        function changeFounder(address newFounder) {
            require(msg.sender == founder);
            founder = newFounder;
        }
 
        /**
         * ERC 20 Standard Token interface transfer function
         *
         * Prevent transfers until freeze period is over.
         */
        function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
            //same as above. Replace this line with the following if you want to protect against wrapping uints.
            if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
                uint _freeAmount = freeAmount(_from);
                if (_freeAmount < _value) {
                    return false;
                }
 
                balances[_to] = SafeMath.safeAdd(balances[_to] , _value);
                balances[_from] = SafeMath.safeSub(balances[_from] , _value);
                allowed[_from][msg.sender] = SafeMath.safeSub(allowed[_from][msg.sender] , _value);
                Transfer(_from, _to, _value);
                return true;
            } else { return false; }
        }
 
        function() payable {
            if (!founder.call.value(msg.value)()) revert();
        }
 
        // only owner can kill
        function kill() {
            require(msg.sender == founder);
            selfdestruct(founder);
        }
 
    }