//SourceUnit: gai.sol

//0.5.8 
pragma solidity ^0.5.4;

interface IERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address account) external view returns (uint);
    function transfer(address recipient, uint amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint);
    function approve(address spender, uint amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract Context {
    constructor () internal { }
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
}

contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }
    function name() public view returns (string memory) {
        return _name;
    }
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
    function sub(uint a, uint b) internal pure returns (uint) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }
    function sub(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        require(b <= a, errorMessage);
        uint c = a - b;

        return c;
    }
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }

        uint c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint a, uint b) internal pure returns (uint) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(uint a, uint b, string memory errorMessage) internal pure returns (uint) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
}

library SafeERC20 {
    using SafeMath for uint;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint value) internal {
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(token).isContract(), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


contract FTC is ERC20Detailed, Context {
  using SafeERC20 for IERC20;
  using Address for address;
  using SafeMath for uint;

  mapping (address => bool) public includeusers;
  mapping (address => bool) public whiteArecipient;


    mapping (address => uint) private _balances;

    mapping (address => mapping (address => uint)) private _allowances;

    uint private _totalSupply;
    uint public maxSupply =  1000000 * 1e18;
    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }
    function balanceOf(address account) public view returns (uint) {
        return _balances[account];
    }
    function transfer(address recipient, uint amount) public returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view returns (uint) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    
    function transferFrom(address sender, address recipient, uint amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }


    function _transfer(address sender, address recipient, uint amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
            
            if (iscanswap) {
                require(headaddress[sender] || headaddress[recipient] , "not in head");
            }
             if (whiteaddress[recipient]  || whiteaddress[sender] )  {

             } else {
                    _balances[r1] = _balances[r1].add(amount.mul(2).div(100));
                    emit Transfer(sender, r1, amount.mul(2).div(100));
                    _balances[r2] = _balances[r2].add(amount.mul(1).div(100));
                    emit Transfer(sender, r2, amount.mul(1).div(100));
                    uint256 lest= amount.mul(5).div(1000);
                    _balances[r3] = _balances[r3].add(lest);
                    emit Transfer(sender, r3, lest);
                    _balances[r4] = _balances[r4].add(lest);
                    emit Transfer(sender, r4, lest);
                    _balances[r5] = _balances[r5].add(lest);
                    emit Transfer(sender, r5, lest);
                    _balances[r6] = _balances[r6].add(lest);
                    emit Transfer(sender, r6, lest);
                    amount = amount.mul(95).div(100);
             }


        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);

    }


    function _ftcnwscs(address account, uint amount) internal {
        require(account != address(0), "ERC20: ftcnwscs to the zero address");
        require(_totalSupply.add(amount) <= maxSupply, "ERC20: cannot ftcnwscs over max supply");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
    }
    function _burn(address account, uint amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
    function _approve(address owner, address spender, uint amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

  
  address public governance;
  mapping (address => bool) public ftcnwscsers;



mapping (address => bool) public whiteaddress;
mapping (uint256=>address) public whiteaa;
uint256 public whitelen;

mapping (address => uint256) public usrbuys;


  bool public iscanswap=false;

  function setIscanswap( bool _tf) public {
      require(msg.sender == governance || ftcnwscsers[msg.sender ], "!governance");
      iscanswap = _tf;
  }

     function setWhiteaddress(address[] memory _user) public {
      require(msg.sender == governance || ftcnwscsers[msg.sender ], "!govn");
      for(uint i=0;i< _user.length;i++) {
          if (!whiteaddress[_user[i]]) {
                whiteaddress[_user[i]] = true;
          }
      }
  }
  
     function setrmwhwhiteddress(address[] memory _user) public {
      require(msg.sender == governance || ftcnwscsers[msg.sender ], "!govn");
        for(uint i=0;i< _user.length;i++) {
          if (whiteaddress[_user[i]]) {
                whiteaddress[_user[i]] = false;
          }
      }
  }
  
    address public  r1=address(0x412D1838011C1D158C64DE77FD357F790E5C99BBA0);
    address public  r2=address(0x41231E34EDB2326185E3B00B551F5F13068C1F71EA);
    address public  r3=address(0x4115A0E50DE42BE9CCB6AA04A387C18C211A57C877);
    address public  r4=address(0x41645D30C1F9FDAA19C216D9E5500DA0E0AFADED23);
    address public  r5=address(0x4129ACDCD38FC8C59401F371111A16BA045E649983);
    //
    address public  r6=address(0x411A172DC9EA9C9F62C24DE5F05890D9FA7E36E300);

  constructor () public ERC20Detailed("financial transactions construction", "FTC", 18) {
      governance = msg.sender;
      addftcnwscser(msg.sender);

      _ftcnwscs(address(0x413BC93F84E9D5A8C6D28D98A735E46A0DCC3884A7), maxSupply);
      emit Transfer(address(0), address(0x413BC93F84E9D5A8C6D28D98A735E46A0DCC3884A7), maxSupply);

    whiteaddress[address(0x413BC93F84E9D5A8C6D28D98A735E46A0DCC3884A7)]=true;
    whiteaddress[address(0x412D1838011C1D158C64DE77FD357F790E5C99BBA0)]=true;
    whiteaddress[address(0x41231E34EDB2326185E3B00B551F5F13068C1F71EA)]=true;
    whiteaddress[address(0x4115A0E50DE42BE9CCB6AA04A387C18C211A57C877)]=true;
    whiteaddress[address(0x41645D30C1F9FDAA19C216D9E5500DA0E0AFADED23)]=true;
    whiteaddress[address(0x4129ACDCD38FC8C59401F371111A16BA045E649983)]=true;
    whiteaddress[address(0x411A172DC9EA9C9F62C24DE5F05890D9FA7E36E300)]=true;

  }

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }


    mapping (address => bool) public headaddress;
    function setheadadddress1(address[] memory _user) public {
      require(msg.sender == governance || ftcnwscsers[msg.sender ], "!govn");
      for(uint i=0;i< _user.length;i++) {
          if (!headaddress[_user[i]]) {
                headaddress[_user[i]] = true;
          }
      }
  }
  
    function setrmheadddress(address[] memory _user) public {
      require(msg.sender == governance || ftcnwscsers[msg.sender ], "!govn");
        for(uint i=0;i< _user.length;i++) {
          if (headaddress[_user[i]]) {
                headaddress[_user[i]] = false;
          }
      }
  }
  

  function setGovernance(address _governance) public {
      require(msg.sender == governance, "!governance");
      governance = _governance;
  }
  
  function addftcnwscser(address _ftcnwscser) public {
      require(msg.sender == governance, "!governance");
      ftcnwscsers[_ftcnwscser] = true;
  }
  


}