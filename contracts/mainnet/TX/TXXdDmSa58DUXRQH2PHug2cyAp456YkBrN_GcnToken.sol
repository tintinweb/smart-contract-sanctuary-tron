//SourceUnit: GCN.sol

pragma solidity ^0.5.10;


library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
}


contract GcnToken {
    using SafeMath for uint256;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);


    uint256 public totalSupply;
    string public name;
    uint8 public decimals;
    string public symbol;

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) _allowances;

 
    //init   
    address initAddress = 0xfD6842947336117ca6240B7f8228740Cba188C15;
    address burnAddress = 0x34DeF59ee19483F1C06704545C5Dfd7B00059480;
    
    uint256 maxBurnPercent = 90;    
    uint256 denominator = 100;  
    uint256 feePoolPercent = 10;                    

    uint256 public maxBurnAmount;
    uint256 public curBurnAmount;
    
    constructor(string memory _tokenName, string memory _tokenSymbol, uint8 _decimalUnits, uint256 _initialAmount) public {
        totalSupply = _initialAmount * 10 ** uint256(_decimalUnits);         
        name = _tokenName;
        decimals = _decimalUnits;
        symbol = _tokenSymbol;
        _init(totalSupply);
    }

    function _init(uint256 _totalSupply) internal {
        balances[initAddress] = _totalSupply;
        emit Transfer(address(0), initAddress, _totalSupply);    
        
        maxBurnAmount = _totalSupply.mul(maxBurnPercent).div(denominator);   
        
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }


    function transferFrom(address _from, address _to, uint256 _value) public returns
    (bool) {
        require(_allowances[_from][msg.sender] >= _value, "ERC20: transferFrom amount exceeds allowance");
        _transfer(_from, _to, _value);
        _allowances[_from][msg.sender] = _allowances[_from][msg.sender].sub(_value);
        return true;
    }

  

    function _transfer(address _from, address _to, uint256 _value) internal {
        require(balances[_from] >= _value, "ERC20: transfer amount exceeds balance");
       	balances[_from] = balances[_from].sub(_value);  
       	  
        if(_from==initAddress||_to==initAddress||_to==burnAddress){        
       		balances[_to] = balances[_to].add(_value);
       		emit Transfer(_from, _to, _value);
        }else{
            if (curBurnAmount < maxBurnAmount) {
                 uint256 burn = _value.mul(feePoolPercent).div(denominator);
                 curBurnAmount = curBurnAmount.add(burn);
                 
                 balances[burnAddress] = balances[burnAddress].add(burn);
            	 emit Transfer(_from, burnAddress, burn);
                 _value = _value.sub(burn);                 
            }
            
             balances[_to] = balances[_to].add(_value);
             emit Transfer(_from, _to, _value);
        }


    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }


    function approve(address _spender, uint256 _value) public returns (bool)
    {
        _allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return _allowances[_owner][_spender];
    }

    function _burn(address _from, uint256 _value) internal {
        require(balances[_from] >= _value, "ERC20: burn amount exceeds balance");
        balances[_from] = balances[_from].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Transfer(_from, address(0), _value);
    }

    function burn(uint256 _value) public {
        _burn(msg.sender, _value);
    }

    function burnFrom(address _from, uint256 _value) public {
        require(_allowances[_from][msg.sender] >= _value, "ERC20: burn amount exceeds allowance");
        _burn(msg.sender, _value);
        _allowances[_from][msg.sender] = _allowances[_from][msg.sender].sub(_value);
        emit Transfer(_from, address(0), _value);
    }


    function transferArray(address[] memory _to, uint256[] memory _value) public {
        require(_to.length == _value.length);
        uint256 sum = 0;
        for (uint256 i = 0; i < _value.length; i++) {
            sum = sum.add(_value[i]);
        }
        require(balances[msg.sender] >= sum);
        for (uint256 k = 0; k < _to.length; k++) {
            _transfer(msg.sender, _to[k], _value[k]);
        }
    }

}