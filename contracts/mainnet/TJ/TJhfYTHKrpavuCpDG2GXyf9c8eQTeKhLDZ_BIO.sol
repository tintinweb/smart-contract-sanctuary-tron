//SourceUnit: BIO.sol

pragma solidity 0.6.12;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return add(a, b, "SafeMath: addition overflow");
    }


    function add(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, errorMessage);

        return c;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }


    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
        return div(a, b, "SafeMath: division by zero");
    }


    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


contract Ownable  is Context{
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner ==  msg.sender, "Ownable: caller is not the owner");
        _;
    }

}

interface TRC20Interface {

    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    /**
     * @dev Returns the amount of tokens owned by `account`.
   */
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// ----------------------------------------------------------------------------
// Contract function to receive approval and execute function in one call
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// Limit users in blacklist
// ----------------------------------------------------------------------------
contract UserLock is Ownable {
    mapping(address => bool) blacklist;

    event LockUser(address indexed who);
    event UnlockUser(address indexed who);

    modifier permissionCheck {
        require(!blacklist[msg.sender], "Blocked user");
        _;
    }

    function lockUser(address who) public onlyOwner {
        blacklist[who] = true;

        emit LockUser(who);
    }

    function unlockUser(address who) public onlyOwner {
        blacklist[who] = false;

        emit UnlockUser(who);
    }
}

contract TRC20 is TRC20Interface, UserLock {
    using SafeMath for uint256;

    /// @notice Official record of token balances for each account
    mapping (address => uint256) private _balances;

    /// @notice Allowance amounts on behalf of others
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    uint8 private _decimals;

    string private _symbol;

    string private _name;

    constructor (string memory token_name, string memory token_symbol) public {
        _name = token_name;
        _symbol = token_symbol;
        _decimals = 18;
    }

    function getOwner()  public view override returns (address) {
        return owner();
    }

    function decimals()  public view override returns (uint8) {
        return _decimals;
    }

    function symbol()  public view override returns (string memory) {
        return _symbol;
    }

    function name()  public view override returns (string memory) {
        return _name;
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account)  public view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function transfer(address recipient, uint256 amount) public permissionCheck override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }


    function approve(address spender, uint256 amount) public permissionCheck override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public permissionCheck override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "TRC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public permissionCheck returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue, "The increased allowance overflows"));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public permissionCheck returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "The decreased allowance below zero"));
        return true;
    }


    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "Cannot approve from the zero address");
        require(spender != address(0), "Cannot approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "Cannot burn from the zero address");
        require(amount > 0 , "Cannot burn zero amount");

        _balances[account] = _balances[account].sub(amount, "The burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);

    }

    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "Cannot mint from the zero address");
        require(amount > 0 , "Cannot mint zero amount");

        _balances[account] = _balances[account].add(amount, "The mint amount exceeds balance");
        _totalSupply = _totalSupply.add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "TRC20: transfer from the zero address");
        require(recipient != address(0), "TRC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "TRC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
}


contract BIO is TRC20("BITONE", "BIO") {

    function burn(address account, uint256 amount) public  permissionCheck onlyOwner returns (bool) {
        _burn(account, amount);
        return true;
    }

    function mint(address account, uint256 amount) public  permissionCheck onlyOwner returns (bool) {
        _mint(account, amount);
        return true;
    }
}