//SourceUnit: Trex.sol

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.0 <0.7.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
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

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;
    mapping (address => bool) private _isBurner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event BurnerAdded(address indexed added);
    event BurnerRemoved(address indexed removed);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () public {
        address msgSender = _msgSender();
        _owner = msgSender;
        _isBurner[msgSender] = true;
        emit OwnershipTransferred(address(0), msgSender);
        emit BurnerAdded(msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function isBurner(address account) public view virtual returns (bool) {
        return _isBurner[account];
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    modifier onlyOwnerAndBurner() {
        require(isBurner(_msgSender()) || owner() == _msgSender(), "Only Burners and Owner can do this");
        _;
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function addBurner(address account) public virtual onlyOwner {
        require(isBurner(account) == false, "Ownable: Already a Burner");
        require(account != address(0), "Ownable: Can not set the zero address");

        emit BurnerAdded(account);
        _isBurner[account] = true;
    }

    function removeBurner(address account) public virtual onlyOwner {
        require(isBurner(account) == true, "Ownable: Is not a Burner");

        emit BurnerRemoved(account);
        _isBurner[account] = false;
    }
}

/**
 * @dev Interface of the TRC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {TRC20Detailed}.
 */
interface ITRC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IWBASE {
    function deposit() external payable;
    function transfer(address to, uint256 value) external returns(bool);
}

interface IJMSwapFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint256);

    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface IJMSwapPair {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Sync(uint112 reserve0, uint112 reserve1);

    function sync() external;
}

interface IJMSwapRouter {
    function factory() external pure returns (address);
    function WBASE() external pure returns (address);

    function swapExactBaseForTokens(
        uint256 amountOutMin, 
        address[] calldata path, 
        bytes32[] memory taxes, 
        address to, 
        uint256 deadline
    ) external payable returns(uint256[] memory amounts);
}

/**
 * @dev Optional functions from the TRC20 standard.
 */
abstract contract TRC20Detailed is ITRC20 {
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

contract TRexPunk is TRC20Detailed, Ownable {
    using SafeMath for uint256;

    event SwapIncomeFromNFT(uint256 trxTotalUsed, uint256 trexTokensBought, uint256 trexTokensBurned, uint256 trxUsedToBuy, uint256 trxSentToLP, uint256 trexTokensSentToNFTpool);

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply = 10000000000 * (10 ** 18);
    uint256 public _maxTxAmount = 10000000000 * (10 ** 18);
    uint256 public startTime = 1643734797; // Tuesday, 1 February 2022 11:59:57 EST

    IJMSwapRouter public jmSwapRouter;

    address public jmSwapPair;
    address public stakeRewardNFT;

    constructor (address rewardWalletNFT, address _SwapRouter) public TRC20Detailed("T-Rex Punk Token", "TREX", 18) {
        IJMSwapRouter _jmSwapRouter = IJMSwapRouter(_SwapRouter); // JMSwap Router

        // Create a JustMoney Swap pair for this new token
        jmSwapPair = IJMSwapFactory(_jmSwapRouter.factory()).createPair(address(this), _jmSwapRouter.WBASE());

        // set the rest of the contract variables
        jmSwapRouter = _jmSwapRouter;
        stakeRewardNFT = rewardWalletNFT;
        startTime = 1;
        _balances[stakeRewardNFT] = 3500000000 * (10 ** 18); // 35% added to NFT Stake Reward Wallet
        _balances[msg.sender] = 6500000000 * (10 ** 18); // 65% To creator wallet (60% for liquidity pool 5% for dev and marketing)

        emit Transfer(address(0), stakeRewardNFT, balanceOf(stakeRewardNFT));
        emit Transfer(address(0), msg.sender, balanceOf(msg.sender));
    }

    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 value) public override returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function setMaxTxAmount(uint256 maxTxAmount) public onlyOwner {
        require(maxTxAmount >= (1000000 * (10 ** 18)), "Min amount 1m tokens");
        
        _maxTxAmount = maxTxAmount;
    }

    function setStartTime(uint256 startTimestamp) public onlyOwner {
        require(block.timestamp < 1643734797, "Can not change the start time anymore"); // The timestamp can not be edited after Tuesday, 1 February 2022 11:59:57 EST
        require(startTimestamp <= 1643734797, "invalid date"); // Timestamp must be before Tuesday, 1 February 2022 11:59:57 EST

        startTime = startTimestamp;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(amount > 0, "Transfer amount can't be zero");
        require(sender != address(0), "TRC20: transfer from the zero address");
        require(recipient != address(0), "TRC20: transfer to the zero address");
        require(block.timestamp >= startTime, "The token is not launched yet");
        require(amount <= _maxTxAmount, "Amount exceeds the maxTxAmount");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "TRC20: approve from the zero address");
        require(spender != address(0), "TRC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function changeRewardAddressNFT(address _newWallet) public onlyOwner {
        require(_newWallet != address(0), "Cant set the 0 address");

        stakeRewardNFT = _newWallet;
    }

    function changeJMSwapRouter(address _newRouter) public onlyOwner {
        require(_newRouter != address(0), "Cant set the 0 address");

        IJMSwapRouter _jmSwapRouterNew = IJMSwapRouter(_newRouter);
        jmSwapRouter = _jmSwapRouterNew;
    }

    function changeJMSwapPair(address _newPair) public onlyOwner {
        require(_newPair != address(0), "Cant set the 0 address");

        jmSwapPair = _newPair;
    }

    function burn(uint256 amount) external onlyOwnerAndBurner {
        require(amount > 0, "Burn: Amount must be greater than 0");
        _burn(msg.sender, amount);
    }
    
    function _burn(address from, uint256 amount) internal onlyOwnerAndBurner {
        require(balanceOf(from) >= amount, "Burn: Not enough tokens to burn");

        _balances[from] = _balances[from].sub(amount);
        _totalSupply = _totalSupply.sub(amount);

        emit Transfer(from, address(0), amount);
    }

    function _swapTRXforTokens(uint256 trxAmount) private {
        // jmswap pair path of WTRX -> Token
        address[] memory path = new address[](2);
        path[0] = jmSwapRouter.WBASE();
        path[1] = address(this);

        // jmswap taxes array for WTRX & Token
        bytes32[] memory taxes = new bytes32[](2);
        taxes[0] = bytes32(0);
        taxes[1] = bytes32(0);

        // make the swap
        jmSwapRouter.swapExactBaseForTokens{value: trxAmount}(
            0, // accept any amount of TREX
            path,
            taxes,
            msg.sender,
            block.timestamp
        );
    }

    function swapIncomeFromNFT() public payable onlyOwnerAndBurner {
        require(msg.value > 0, "Cant send 0 TRX");

        _swapIncomeFromNFT(msg.value);
    }

    function _swapIncomeFromNFT(uint256 amount) private onlyOwnerAndBurner {
        // 1. Split the sent TRX amount and get initial TREX token balance of the user
        uint256 trxHalf = amount.div(2);
        uint256 trexInitialBal = balanceOf(msg.sender);

        // 2. Swap half TRX amount sent for TREX tokens
        _swapTRXforTokens(trxHalf);

        // 3. Get amount of bought TREX Tokens and burn half of it
        uint256 trexBought = balanceOf(msg.sender).sub(trexInitialBal); // New balance after buying minus initial balance
        uint256 trexBoughtHalf = trexBought.div(2);
        require(trexBoughtHalf > 0, "Amount must be greater than 0");
        _burn(msg.sender, trexBoughtHalf);

        // 4. Convert the remaining half of TRX to WTRX and send them to the Liquidity Pool
        uint256 trxRemainingAmount = amount.sub(trxHalf);
        IWBASE(jmSwapRouter.WBASE()).deposit{value: trxRemainingAmount}();
        assert(IWBASE(jmSwapRouter.WBASE()).transfer(jmSwapPair, trxRemainingAmount));
        IJMSwapPair(jmSwapPair).sync(); // Sync the pair balances

        // 5. Send half the TREX tokens bought to the NFT Staking Reward Wallet
        uint256 trexRemainingHalf = balanceOf(msg.sender).sub(trexInitialBal);
        _transfer(msg.sender, stakeRewardNFT, trexRemainingHalf);

        emit SwapIncomeFromNFT(amount, trexBought, trexBoughtHalf, trxHalf, trxRemainingAmount, trexRemainingHalf);
    }
}