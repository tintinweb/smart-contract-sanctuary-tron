//SourceUnit: rieko.sol

    pragma solidity ^0.5.0;
   
    // Name and Symbol: RKO-Reiko Coin
    // Total supply: 10,00,00,000
    // Decimals    : 8
  
 
    library SafeMath {
        function add(uint a, uint b) internal pure returns (uint c) {
            c = a + b;
            require(c >= a);
        }
        function sub(uint a, uint b) internal pure returns (uint c) {
            require(b <= a);
            c = a - b;
        }
        function mul(uint a, uint b) internal pure returns (uint c) {
            c = a * b;
            require(a == 0 || c / a == b);
        }
        function div(uint a, uint b) internal pure returns (uint c) {
            require(b > 0);
            c = a / b;
        }
    }


    contract ERC20Interface {
        function totalSupply() public view returns (uint);
        function balanceOf(address tokenOwner) public view returns (uint balance);
        function allowance(address tokenOwner, address spender) public view returns (uint remaining);
        function transfer(address to, uint tokens) public returns (bool success);
        function approve(address spender, uint tokens) public returns (bool success);
        function transferFrom(address from, address to, uint tokens) public returns (bool success);
        event Transfer(address indexed from, address indexed to, uint tokens);
        event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
        event Burn(address indexed from, uint256 value);
		}

		contract ApproveAndCallFallBack
		{
        function receiveApproval(address from, uint256 tokens, address token, bytes memory data) public;
		}

		contract Owned {
        address public owner;
        address public newOwner;

        event OwnershipTransferred(address indexed _from, address indexed _to);

        constructor() public {
            owner = msg.sender;
        }

        modifier onlyOwner {
            require(msg.sender == owner);
            _;
        }

        function transferOwnership(address _newOwner) public onlyOwner {
            newOwner = _newOwner;
        }
        function acceptOwnership() public {
            require(msg.sender == newOwner);
            emit OwnershipTransferred(owner, newOwner);
            owner = newOwner;
            newOwner = address(0);
        }
    }

		contract ReikoCoin is ERC20Interface, Owned {
        using SafeMath for uint;
        string public symbol;
        string public  name;
        uint8 public decimals;
        uint _totalSupply;
        mapping(address => uint) balances;
        mapping(address => mapping(address => uint)) allowed;

        constructor() public {
            symbol = "RKO";
            name = "Reiko Coin";
            decimals = 8;
            _totalSupply = 100000000 * 10**uint(decimals);
            balances[owner] = _totalSupply;
            emit Transfer(address(0), owner, _totalSupply);
        }

		function totalSupply() public view returns (uint) {
            return _totalSupply.sub(balances[address(0)]);
        }

		function balanceOf(address tokenOwner) public view returns (uint balance) {
            return balances[tokenOwner];
        }
		function transfer(address to, uint tokens) public returns (bool success) {
            balances[msg.sender] = balances[msg.sender].sub(tokens);
            balances[to] = balances[to].add(tokens);
            emit Transfer(msg.sender, to, tokens);
            return true;
        }


        function approve(address spender, uint tokens) public returns (bool success) {
            allowed[msg.sender][spender] = tokens;
            emit Approval(msg.sender, spender, tokens);
            return true;
        }


       function transferFrom(address from, address to, uint tokens) public returns (bool success) {
            balances[from] = balances[from].sub(tokens);
            allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
            balances[to] = balances[to].add(tokens);
            emit Transfer(from, to, tokens);
            return true;
        }

		function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
            return allowed[tokenOwner][spender];
        }

		function approveAndCall(address spender, uint tokens, bytes memory data) public returns (bool success) {
            allowed[msg.sender][spender] = tokens;
            emit Approval(msg.sender, spender, tokens);
            ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, address(this), data);
            return true;
        }
        function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
            return ERC20Interface(tokenAddress).transfer(owner, tokens);
        }
    
        function burn(uint256 _value) public returns (bool success) {
            require(balances[msg.sender] >= _value);   // Check if the sender has enough
            balances[msg.sender] -= _value;            // Subtract from the sender
            _totalSupply -= _value;                      // Updates totalSupply
            emit Burn(msg.sender, _value);
            return true;
        }

      
        function burnFrom(address _from, uint256 _value) public returns (bool success) {
            require(balances[_from] >= _value);               // Check if the targeted balance is enough
            require(_value <= allowed[_from][msg.sender]);    // Check allowance
            balances[_from] -= _value;                        // Subtract from the targeted balance
            allowed[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
            _totalSupply -= _value;                           // Update totalSupply
            emit Burn(_from, _value);
            return true;
        }
    }