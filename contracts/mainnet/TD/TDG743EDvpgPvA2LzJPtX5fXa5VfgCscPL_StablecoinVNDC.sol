//SourceUnit: StablecoinVNDC.sol

pragma solidity ^0.4.24;

contract StablecoinVNDC {

    string public name;
    string public symbol;
    uint8 public decimals = 3;
    uint256 public totalSupply;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed _owner, address indexed _spender, uint256 value);
    event Burn(address indexed from, uint256 value);

    uint256 initialSupply = 120000000000;
    string tokenName = 'VNDC';
    string tokenSymbol = 'VNDC';

    constructor() public {

        totalSupply = initialSupply*10**uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        name = tokenName;
        symbol = tokenSymbol;

    }

    function _transfer(address _from, address _to, uint _value) internal {

        require(_to!=0x0);
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);

        uint previousBalances = balanceOf[_from] + balanceOf[_to];

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(_from, _to, _value);

        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);

    }

    function transfer(address _to, uint256 _value) public returns (bool success){

        _transfer(msg.sender, _to, _value);
        return true;

    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){

        require(_value <= allowance[_from][msg.sender]);
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);

        return true;

    }

    function approve (address _spender, uint256 _value) public returns (bool success){
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);

        return true;
    }

    /*

    This smart contract was created by Vietnamese community . It is a TRC20 token named VNDC (Stablecoin VNDC) with a total supply of 120000000000 VNDC and precision of 3 decimals , 1VNDC = 1VND.

    */

}