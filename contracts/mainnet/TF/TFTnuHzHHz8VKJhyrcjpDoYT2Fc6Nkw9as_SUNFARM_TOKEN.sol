//SourceUnit: SUNFARM.sol

/*
 * 
 * SUNFARM TOKEN DIGITAL CURRENCY | http://sunfarm.farm 
 *
 *   ┌───────────────────────────────────────────────────────────────────────┐  
 *   │   Website: http://sunfarm.farm                                        │
 *   │                                                                       │   
 *   │   Contract Address: TFTnuHzHHz8VKJhyrcjpDoYT2Fc6Nkw9as                │
 *   |   E-mail: admin@sunfarm.farm                                          |
 *   └───────────────────────────────────────────────────────────────────────┘ 
 */
 

pragma solidity 0.5.10;

library SafeMath {

    
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        
        if (a == 0) {
            return 0;
        }

        c = a * b;
        assert(c / a == b);
        return c;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        return a / b;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}


contract TRC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}


contract BasicToken is TRC20Basic {
    using SafeMath for uint256;

    mapping(address => uint256) balances;

    uint256 totalSupply_;

    
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0), "Address must not be zero.");
        require(_value <= balances[msg.sender], "There is no enough balance.");

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

}


contract TRC20 is TRC20Basic {
    function allowance(address owner, address spender)
        public view returns (uint256);

    function transferFrom(address from, address to, uint256 value)
        public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


contract StandardToken is TRC20, BasicToken {

    mapping (address => mapping (address => uint256)) internal allowed;


    
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        public
        returns (bool)
    {
        require(_to != address(0), "Address must not be zero.");
        require(_value <= balances[_from], "There is no enough balance.");
        require(_value <= allowed[_from][msg.sender], "There is no enough allowed balance.");

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

        function allowance(
        address _owner,
        address _spender
    )
        public
        view
        returns (uint256)
    {
        return allowed[_owner][_spender];
    }

    
    function increaseApproval(
        address _spender,
        uint256 _addedValue
    )
        public
        returns (bool)
    {
        allowed[msg.sender][_spender] = (
        allowed[msg.sender][_spender].add(_addedValue));
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    
    function decreaseApproval(
        address _spender,
        uint256 _subtractedValue
    )
        public
        returns (bool)
    {
        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}

contract SUNFARM_TOKEN is StandardToken {
    string public name = "SUNFARM TOKEN";
    string public symbol = "SFC";
    uint8 public decimals = 6;
    uint256 public INITIAL_SUPPLY = 1000000000 * 10 ** uint256(decimals);

    constructor() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = totalSupply_;
        emit Transfer(address(0), msg.sender, INITIAL_SUPPLY);
    }
}