//SourceUnit: Token.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.5.10;

contract Context {
    constructor () internal { }
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
}

interface ITRC20 {
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
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
        require(b > 0, errorMessage);
        uint256 c = a / b;
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
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}

contract Ownable is Context {
    address private _owner;
    address[] private _partners = new address[](6);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event PartnershipTransferred(address indexed previousPartner, address indexed newPartner);
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        //partner
        _partners[0] = address(0);
        _partners[1] = address(0);
        //presale
        _partners[2] = address(0);
        //exchange
        _partners[3] = address(0);
        _partners[4] = address(0);
        _partners[5] = address(0);
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    function partner(uint256 index) public view returns (address) {
        require(index < _partners.length, "Ownable: index of partner is incorrect");
        return _partners[index];
    }
    function is_partner(address addr) public view returns (bool) {
        bool partnership = false;
        uint256 partnerIndex = _partners.length;
        for(uint256 i=0; i<partnerIndex; i++){
            if(_partners[i] == addr) {
                partnership = true;
                break;
            }
        }
        return partnership;
    }
    function partner_length() public view returns (uint256) {
        return _partners.length;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    modifier onlyPartner() {
        if(_owner != _msgSender()) {
            bool partnership = false;
            uint256 partnerIndex = _partners.length;
            for(uint256 i=0; i<partnerIndex; i++){
                if(_partners[i] == _msgSender()) {
                    partnership = true;
                    break;
                }
            }
            require(partnership == true, "Partner not found");
        }
        _;
    }
    modifier onlyPartnerIndex(uint256 index) {
        if(_partners[index] != address(0) && _owner != _msgSender()) {
            bool partnership = false;
            uint256 partnerIndex = _partners.length;
            for(uint256 i=0; i<partnerIndex; i++){
                if(_partners[i] == _msgSender()) {
                    partnership = true;
                    break;
                }
            }
            require(partnership == true, "Partner not found");
        }
        _;
    }
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    function transferPartnership(address newPartner,uint256 index) public onlyPartnerIndex(index) {
        require(newPartner != address(0), "Ownable: new partner is the zero address");
        require(index < _partners.length, "Ownable: index of partner is incorrect");
        emit PartnershipTransferred(_partners[index], newPartner);
        _partners[index] = newPartner;
    }
}

contract BaseTRC20 is Ownable, ITRC20 {
    using SafeMath for uint256;
    using Address for address;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint256 private _totalSupply;
    bool private _mintingFinished = false;
    bool private _transferEnabled = false;
    bool private _paused = false;
    event MintFinished();
    event TransferEnabled();
    event TransferDisabled();
    event Paused(address account);
    event Unpaused(address account);
    modifier canMint() {
        require(!_mintingFinished, "TRC20Base: minting is finished");
        _;
    }
    modifier canTransfer(address from) {
        require(
            _transferEnabled || owner() == from || is_partner(from) == true,
            "TRC20Base: transfer is not enabled or from does not have status owner"
        );
        _;
    }
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public canTransfer(_msgSender()) returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public canTransfer(sender) returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "TRC20: transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "TRC20: decreased allowance below zero"));
        return true;
    }
    function burn(uint256 amount) public {
        _burn(_msgSender(), amount);
    }
    function burnFrom(address account, uint256 amount) public {
        uint256 decreasedAllowance = allowance(account, _msgSender()).sub(amount, "TRC20: burn amount exceeds allowance");
        _approve(account, _msgSender(), decreasedAllowance);
        _burn(account, amount);
    }
    function recoverTRC20(address tokenAddress, uint256 tokenAmount) public onlyPartner {
        ITRC20(tokenAddress).transfer(owner(), tokenAmount);
    }
    function mintingFinished() public view returns (bool) {
        return _mintingFinished;
    }
    function transferEnabled() public view returns (bool) {
        return _transferEnabled;
    }
    function paused() public view returns (bool) {
        return _paused;
    }
    function mint(address to, uint256 value) public canMint onlyPartner {
        _mint(to, value);
    }
    function finishMinting() public canMint onlyPartner {
        _mintingFinished = true;
        emit MintFinished();
    }
    function disableTransfer() public onlyPartner {
        _transferEnabled = false;
        emit TransferDisabled();
    }
    function enableTransfer() public onlyPartner {
        _transferEnabled = true;
        emit TransferEnabled();
    }
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "TRC20: transfer from the zero address");
        require(recipient != address(0), "TRC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "TRC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "TRC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "TRC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "TRC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "TRC20: approve from the zero address");
        require(spender != address(0), "TRC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal {
        require(!paused(), "TRC20: token transfer while paused");
    }
    function _pause() internal whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }
    function _unpause() internal whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

contract TRC20Detailed is BaseTRC20 {
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
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }
}

contract Token is ITRC20, TRC20Detailed {
    constructor() public TRC20Detailed("ProGram", "GRAM", 9){
        _setupDecimals(9);
        _mint(owner(), 21000000 * 10 ** 9);
    }
}