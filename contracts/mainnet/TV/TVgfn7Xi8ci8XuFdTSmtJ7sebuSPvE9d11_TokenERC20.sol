//SourceUnit: xb-2.sol


pragma solidity ^0.4.16;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }

contract TokenERC20 {
    string public name ;
    string public symbol;
    uint8 public constant decimals = 18;  
    uint256 public totalSupply;
	
	uint256 private constant INITIAL_SUPPLY = 6666 * (10 ** uint256(decimals));

    mapping (address => uint256) public balanceOf;  // 
    mapping (address => mapping (address => uint256)) public allowance;
	
	address feeTo;
	address public poolAddr;
	address public deployer;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Burn(address indexed from, uint256 value);
	
	event Approval(address indexed owner, address indexed spender, uint256 value);

	modifier onlyDeployer() {
        require(msg.sender == deployer, "Only Deployer");
        _;
    }

	function TokenERC20(string tokenName, string tokenSymbol, address _feeTo) public {
		require(_feeTo != address(0), "feeTo can't be zero address");
		totalSupply = INITIAL_SUPPLY;
        balanceOf[msg.sender] = totalSupply;
        name = tokenName;
        symbol = tokenSymbol;
		feeTo = _feeTo;
		deployer = msg.sender;
    }

    function setPool(address _pool) public onlyDeployer {
    	require(_pool != address(0), "pool can't be zero");
    	poolAddr = _pool;
    }

    function setDeployer(address _dep) public onlyDeployer {
    	require(_dep != address(0), "deployer can't be zero");
    	deployer = _dep;
    }


    function _transfer(address _from, address _to, uint _value) internal returns (bool) {
        require(_to != 0x0);
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value > balanceOf[_to]);
        //uint previousBalances = balanceOf[_from] + balanceOf[_to] + balanceOf[feeTo];
		// uint fee = _value / 10;
		// uint amount = _value - fee;
  //       balanceOf[_from] -= _value;
  //       balanceOf[_to] += amount;
		// balanceOf[feeTo] += fee;
		if(poolAddr != address(0) && (_from == poolAddr || _to == poolAddr)) {
			uint fee = _value / 20;
			balanceOf[_from] -= _value;
			if(totalSupply >= fee + (999 ** decimals)) {
				balanceOf[feeTo] += fee;
				balanceOf[poolAddr] += fee;
				balanceOf[_to] += (_value - 3 * fee);
				totalSupply -= fee;
			} else if(totalSupply > (999 ** decimals)) {
				balanceOf[feeTo] += fee;
				balanceOf[poolAddr] += fee;
				uint burned = totalSupply - (999 ** decimals);
				balanceOf[_to] += (_value - 2 * fee - burned);
				totalSupply -= burned;
			} else {
				balanceOf[feeTo] += fee;
				balanceOf[poolAddr] += fee;
				balanceOf[_to] += (_value - 2 * fee);
			}
		} else {
			balanceOf[_from] -= _value;
			balanceOf[_to] += _value;
		}
        Transfer(_from, _to, _value);
        //assert(balanceOf[_from] + balanceOf[_to] + balanceOf[feeTo] == previousBalances);
		return true;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        _transfer(msg.sender, _to, _value);
		return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public
        returns (bool success) {
		require((_value == 0) || (allowance[msg.sender][_spender] == 0));
        allowance[msg.sender][_spender] = _value;
		Approval(msg.sender, _spender, _value);
        return true;
    }

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        Burn(msg.sender, _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        allowance[_from][msg.sender] -= _value;
        totalSupply -= _value;
        Burn(_from, _value);
        return true;
    }
}