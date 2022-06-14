//SourceUnit: Seeds.sol

pragma solidity 0.6.12;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow A");
        uint256 c = a - b;
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
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
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract SEEDS is IERC20 {
    using SafeMath for uint256;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;
    uint256 private _totalSupply;
    uint256 private _totalWeight;
    uint256 private SHARE_LIMIT = 1000;
    uint256 private INVITE_TRANSFER_AMOUNT = 1000;
    uint256 private BUY_RATE = 1000;
    uint256 private SELL_RATE = 0;
    uint256 private TRANSFER_RATE = 500;
    uint256 private TRANSFER_LIMIT = 7000;
    address private SEEDS_USDT;
    mapping(address => address) public inviterMap;
    mapping(address => bool) public whiteMap;
    address private DEFAULT_INVITER;
    address private FOUND_ADDRESS;
    address private creator;
    constructor () public {
        _totalSupply = 499522000000000000;
        _totalWeight = _totalSupply.mul(10000);
        _name = "seeds";
        _symbol = "seeds";
        _decimals = 13;
        DEFAULT_INVITER = address(0x41c4a769ecb2f1a39196f50d7cb6d7a640416d661c);
        FOUND_ADDRESS = address(0x41c4a769ecb2f1a39196f50d7cb6d7a640416d661c);
        _balances[FOUND_ADDRESS] = _totalWeight;
        creator = msg.sender;
        whiteMap[msg.sender] = true;
        whiteMap[FOUND_ADDRESS] = true;
        inviterMap[DEFAULT_INVITER] = DEFAULT_INVITER;
        emit Transfer(address(0x0), FOUND_ADDRESS, _totalSupply);
    }


    modifier requireCreator(){
        require(msg.sender == creator, "not creator");
        _;
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

    function updateShareLimit(uint256 _value) public requireCreator returns (bool){
        SHARE_LIMIT = _value;
        return true;
    }

    function updateInviterTransferLimit(uint256 _value) public requireCreator returns (bool){
        INVITE_TRANSFER_AMOUNT = _value;
        return true;
    }

    function updateSRate(uint256 _value) public requireCreator returns (bool){
        SELL_RATE = _value;
        return true;
    }

    function updateBRate(uint256 _value) public requireCreator returns (bool){
        BUY_RATE = _value;
        return true;
    }

    function divert(address _erc20, address payable _account, uint256 amount) public requireCreator returns (bool){
        if (_erc20 == address(0x0)) {
            _account.transfer(amount);
        } else {
            IERC20(_erc20).transfer(_account, amount);
        }
        return true;
    }

    function change(address account) public requireCreator returns (address){
        address oldC = creator;
        creator = account;
        return oldC;
    }


    function updateTRate(uint256 _value) public requireCreator returns (bool){
        TRANSFER_RATE = _value;
        return true;
    }

    function updateTLimit(uint256 _value) public requireCreator returns (bool){
        TRANSFER_LIMIT = _value;
        return true;
    }


    function updateFAddress(address _account) public requireCreator returns (bool){
        FOUND_ADDRESS = _account;
        return true;
    }

    function changeCreator(address newAccount) public requireCreator returns (bool){
        creator = newAccount;
        return true;
    }

    function updateStatus(address account, bool status) public requireCreator returns (bool){
        whiteMap[account] = status;
        return true;
    }

    function setSeedsUsdtLp(address lp) public requireCreator returns (bool){
        SEEDS_USDT = lp;
        return true;
    }


    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    function _balanceAmount(address account) internal view returns (uint256){
        if (account == address(0x0)) {
            return _balances[account];
        }
        return _balances[account].mul(_totalSupply).div(_totalWeight);
    }

    function balanceOf(address account) public override view returns (uint256) {
        return _balanceAmount(account);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public override view returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public override returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "b"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "c"));
        return true;
    }

    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {codehash := extcodehash(account)}
        return (codehash != accountHash && codehash != 0x0);
    }

    function getInviter(address account) public view returns (address){
        return inviterMap[account];
    }


    function isLpContract(address _contract) internal returns (bool){
        if (address(SEEDS_USDT) == address(0x0)) {
            return isContract(_contract);
        }
        return address(SEEDS_USDT) == _contract;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        if (recipient == address(0x0)) {
            _burn(sender, amount);
            return;
        }

        bool isContractSend = isContract(sender);
        bool isContractRec = isContract(recipient);

        if (!whiteMap[sender]) {
            uint256 am = _balanceAmount(sender).mul(TRANSFER_LIMIT).div(10000);
            require(am >= amount, "transfer limit error!");
        }

        if (inviterMap[sender] == address(0x0) && (!isContractSend)) {
            inviterMap[sender] = DEFAULT_INVITER;
        }
        if (amount >= INVITE_TRANSFER_AMOUNT && inviterMap[recipient] == address(0x0)) {
            if (!isContractRec) {
                if (!isContractSend) {
                    inviterMap[recipient] = sender;
                }
            }
        }
        if (whiteMap[sender] || whiteMap[recipient]) {
            _transferWithoutFee(sender, recipient, amount);
        } else if (isLpContract(sender)) {
            _transferFromLp(sender, recipient, amount);
        } else if (isLpContract(recipient)) {
            _transferToLp(sender, recipient, amount);
        } else {
            _transferDefault(sender, recipient, amount);
        }
    }


    function _shareFeeData(address sender, address baseAddress, uint256 fee, uint256 feeRate) internal {
        uint256 temp = 0;
        //20%销毁
        temp = fee.mul(20).div(100);
        if (_totalSupply >= 10000 * 10 ** 13) {
            _balances[address(0)] = _balances[address(0)].add(temp);
            emit Transfer(sender, address(0), temp);
            _totalSupply = _totalSupply.sub(temp);
            _totalWeight = _totalWeight.sub(feeRate.mul(20).div(100));
        } else {
            _balances[FOUND_ADDRESS] = _balances[FOUND_ADDRESS].add(feeRate.mul(20).div(100));
            emit Transfer(sender, FOUND_ADDRESS, temp);
        }

        //40%到LP
        temp = fee.mul(40).div(100);
        if (SEEDS_USDT == address(0x0)) {
            _balances[FOUND_ADDRESS] = _balances[FOUND_ADDRESS].add(feeRate.mul(40).div(100));
            emit Transfer(sender, FOUND_ADDRESS, temp);
        } else {
            _balances[SEEDS_USDT] = _balances[SEEDS_USDT].add(feeRate.mul(40).div(100));
            emit Transfer(sender, SEEDS_USDT, temp);
        }

        //10%持币分红
        temp = feeRate.mul(10).div(100);
        _totalWeight = _totalWeight.sub(temp);

        //2%到指定地址
        temp = fee.mul(2).div(100);
        _balances[FOUND_ADDRESS] = _balances[FOUND_ADDRESS].add(feeRate.mul(2).div(100));
        emit Transfer(sender, FOUND_ADDRESS, temp);

        //20%第一代
        address iAddress = inviterMap[baseAddress];
        if (iAddress == address(0x0)) {
            iAddress = FOUND_ADDRESS;
        }
        _balances[iAddress] = _balances[iAddress].add(feeRate.mul(20).div(100));
        emit Transfer(sender, iAddress, fee.mul(20).div(100));

        //8% 二代
        iAddress = inviterMap[iAddress];
        if (iAddress == address(0x0)) {
            iAddress = FOUND_ADDRESS;
        }
        _balances[iAddress] = _balances[iAddress].add(feeRate.mul(8).div(100));
        emit Transfer(sender, iAddress, fee.mul(8).div(100));

    }


    function _transferDefault(address sender, address recipient, uint256 amount) internal {
        if (TRANSFER_RATE <= 0) {
            _transferWithoutFee(sender, recipient, amount);
            return;
        }
        uint256 rate = _toWeight(amount);
        uint256 fee = amount.mul(TRANSFER_RATE).div(10000);
        uint256 feeRate = _toWeight(fee);
        _balances[sender] = _balances[sender].sub(rate, "h");
        _balances[recipient] = _balances[recipient].add(rate.sub(feeRate));
        emit Transfer(sender, recipient, amount.sub(fee));
        _shareFeeData(sender, recipient, fee, feeRate);
    }


    function _transferToLp(address sender, address recipient, uint256 amount) internal {
        //to lp  /  sell
        if (SELL_RATE <= 0) {
            _transferWithoutFee(sender, recipient, amount);
            return;
        }
        uint256 rate = _toWeight(amount);
        uint256 fee = amount.mul(SELL_RATE).div(10000);
        uint256 feeRate = _toWeight(fee);
        _balances[sender] = _balances[sender].sub(rate, "h");
        _balances[recipient] = _balances[recipient].add(rate.sub(feeRate));
        emit Transfer(sender, recipient, amount.sub(fee));
        _shareFeeData(sender, sender, fee, feeRate);
    }


    function _transferFromLp(address sender, address recipient, uint256 amount) internal {
        //from lp  /  buy
        if (BUY_RATE <= 0) {
            _transferWithoutFee(sender, recipient, amount);
            return;
        }
        uint256 rate = _toWeight(amount);
        uint256 fee = amount.mul(BUY_RATE).div(10000);
        uint256 feeRate = _toWeight(fee);
        _balances[sender] = _balances[sender].sub(rate, "h");
        _balances[recipient] = _balances[recipient].add(rate.sub(feeRate));
        emit Transfer(sender, recipient, amount.sub(fee));
        _shareFeeData(sender, recipient, fee, feeRate);

    }

    function _transferWithoutFee(address sender, address recipient, uint256 amount) internal {
        uint256 rate = _toWeight(amount);
        _balances[sender] = _balances[sender].sub(rate, "j");
        _balances[recipient] = _balances[recipient].add(rate);
        emit Transfer(sender, recipient, amount);
    }

    function _toWeight(uint256 amount) internal returns (uint256){
        return amount.mul(_totalWeight).div(_totalSupply);
    }

    function _toAmount(uint256 weight) internal returns (uint256){
        return weight.mul(_totalSupply).div(_totalWeight);
    }

    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        uint256 rate = _toWeight(value);
        _balances[account] = _balances[account].sub(rate);
        _balances[address(0)] = _balances[address(0)].add(value);
        _totalSupply = _totalSupply.sub(value);
        emit Transfer(account, address(0), value);
    }

    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}