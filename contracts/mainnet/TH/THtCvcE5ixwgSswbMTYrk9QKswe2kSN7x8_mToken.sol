//SourceUnit: mToken.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity 0.8.6;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}

interface IJustLend {
    function enterMarket(address jtoken) external returns (uint256);
    function exitMarket(address jtoken) external returns (uint256);
}


interface IJToken {
    /**
     * @dev Sender supplies assets into the market and receives cTokens in exchange
     */
    function mint(uint256 mintAmount) external;

    /**
     * @dev Sender borrows assets from the protocol to their own address
     */
    function borrow(uint256 borrowAmount) external returns (uint);

    /**
     * @dev Sender redeems cTokens in exchange for a specified amount of underlying asset
     */
    function redeem(uint256 redeemTokens) external returns (uint);

    function redeemUnderlying(uint256 redeemAmount) external returns (uint);

    /**
     * @dev  Sender repays their own borrow
     */
    function repayBorrow(uint256 repayAmount) external;

    /**
     * @dev  Return the borrow balance of account based on stored data
     */
    function borrowBalanceStored(address who) external;

    /**
     * @dev  Get the token balance of the `owner`
     */
    function balanceOf(address owner) external view returns (uint256);
    
    
    function transfer(address who, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

interface Iexchange {
    /**
    * @notice Convert Tokens (token) to Tokens (token_addr).
    * @dev User specifies exact input && minimum output.
    * @param tokens_sold Amount of Tokens sold.
    * @param min_tokens_bought Minimum Tokens (token_addr) purchased.
    * @param min_trx_bought Minimum TRX purchased as intermediary.
    * @param deadline Time after which this transaction can no longer be executed.
    * @param token_addr The address of the token being purchased.
    * @return Amount of Tokens (token_addr) bought.
    */
    function tokenToTokenSwapInput(
        uint256 tokens_sold, // 1000000
        uint256 min_tokens_bought, // 995382777145318606
        uint256 min_trx_bought, // getOutputPrice
        uint256 deadline, // +25000
        address token_addr) // what will be bought
        external returns (uint256);

    // function getInputPrice(
    //     uint256 input_amount,
    //     uint256 input_reserve,
    //     uint256 output_reserve) public view returns (uint256);

    function getOutputPrice(
        uint256 output_amount,
        uint256 input_reserve,
        uint256 output_reserve) external view returns (uint256);
}

interface IPSM {
    function sellGem(address usr, uint256 gemAmt) external;

    function buyGem(address usr, uint256 gemAmt) external;
}

// contract mToken is ERC20Burnable, Ownable {
contract mToken is ERC20Burnable {
    uint256 public constant BORROW_PERCENT = 84999; // 84.999
    uint256 public LIMIT_ITERNAL_TX = 5;
    IJustLend public jl;
    IJToken public jUSDDToken; // JUSDD
    IJToken public jUSDTToken; // JUSDT
    IERC20 public USDD;
    IERC20 public USDT;
    
    IPSM public USDTpsm;
    address public ex_USDT_TRX;
    address public ex_USDD_TRX;
    address public gemJoin;
    Iexchange public lp;
    // flags are used for seting routers related liquidity
    // if it is true then uses PSM contracts, otherwise sun routing
    bool isDirectDeposit = true;
    bool isDirectWithdraw = false;
    uint256 currentAmount;
    // address public JustLend = 'TGjYzgCyPobsNS9n6WcbdLVR9dH7mWqFx7';
    // address public jUSDDToken = 'TX7kybeP6UwTBRHLNPYmswFESHfyjm9bAS'; // JUSDD - 8
    // address public jUSDTToken = 'TXJgMdjVX5dKiQaUi9QobwNxtSQaFqccvd'; // JUSDT - 8
    // address public token = 'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t'; 
    // address public tokenMain = 'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t';
    // USDT - 6
    // USDD - 18
    // address public usdT->usdd = 'TQn9Y2khEsLJW1ChVWFMSMeRDow5KcbLSE'; 
    // address public usdd->usdT = 'TSJWbBJAS8HgQCMJfY5drVwYDa7JBAm6Es'; 
    // gemJoin = TMn5WeW8a8KH9o8rBQux4RCgckD2SuMZmS
    // _USDTpsm = TM9gWuCdFGNMiT1qTq1bgw4tNhJbsESfjA

    constructor() ERC20('mF 8.1', 'mF 8.1') {}

    function setAddresses(
        address _JustLend,
        address _JUSDDToken,
        address _JUSDTToken,
        address _USDD,
        address _USDT,
        address _ex_USDT_TRX,
        address _ex_USDD_TRX,
        address _gemJoin,
        address _USDTpsm) public {
        jl = IJustLend(_JustLend);
        jUSDDToken = IJToken(_JUSDDToken);
        jUSDTToken = IJToken(_JUSDTToken);
        USDD = IERC20(_USDD);
        USDT = IERC20(_USDT);
        ex_USDT_TRX = _ex_USDT_TRX; // JustswapExchange (sun)
        ex_USDD_TRX = _ex_USDD_TRX;
        gemJoin = _gemJoin;
        USDTpsm = IPSM(_USDTpsm);
    }

    function decimals() public pure override returns (uint8) {
        // should be the same amount as token.decimals
        return 6;
    }

    function getDeadline() public view returns (uint256) {
        return block.timestamp + 25000;
    }

    // function updateDirectDeposit(bool _new) public onlyOwner {
    //     isDirectDeposit = _new;
    // }

    // function updateDirectWithdraw(bool _new) public onlyOwner {
    //     isDirectWithdraw = _new;
    // }

    function _swapUSDT_USDD() public returns (bool) {
        // getTokenToTrxInputPrice returns amount of tokens for USDT
        // getTrxToTokenInputPrice returns amount of USDT for tokens
        uint256 usdtAmount = USDT.balanceOf(address(this));
        uint256 minTokensBought = _swapUSDT_USDD_1(usdtAmount);
        _swapUSDT_USDD_2(usdtAmount, minTokensBought);
        return true;
    }

    function _swapUSDT_USDD_1(uint256 usdtAmount) public view returns (uint256) {
        return Iexchange(ex_USDT_TRX).getOutputPrice(
            usdtAmount,
            USDT.balanceOf(ex_USDT_TRX),
            USDD.balanceOf(ex_USDT_TRX)
        );
    }

    function _swapUSDT_USDD_2(uint256 usdtAmount, uint256 minTokensBought) public {
        Iexchange(ex_USDT_TRX).tokenToTokenSwapInput(
            usdtAmount, // all USDT tokens on the smart contraacts
            minTokensBought,
            1, // min_trx_bought
            getDeadline(),
            address(USDD)
        );
    }

    function _swapUSDD_USDT() public returns (bool) {
        uint256 usddAmount = USDD.balanceOf(address(this));
        uint256 minTokensBought = _swapUSDD_USDT_1(usddAmount);
        _swapUSDD_USDT_2(usddAmount, minTokensBought);
        return true;
    }

    function _swapUSDD_USDT_1(uint256 _usddAmount) public view returns (uint256) {
        return Iexchange(ex_USDD_TRX).getOutputPrice(
            _usddAmount,
            USDD.balanceOf(ex_USDD_TRX),
            USDT.balanceOf(ex_USDD_TRX)
        );
    }

    function _swapUSDD_USDT_2(uint256 _usddAmount, uint256 _minTokensBought) public {
        Iexchange(ex_USDD_TRX).tokenToTokenSwapInput(
            _usddAmount, // all USDD tokens on the smart contraacts
            _minTokensBought,
            1, // min_trx_bought
            getDeadline(), // 1657117260
            address(USDT)
        );
    }

    // // add view for each funcs usdd->usdt for prices
    // function enterMarket() public onlyOwner {
    //     // must be called before making deposits
    //     jl.enterMarket(address(jUSDDToken));
    // }

    // function setLimitTx(uint256 _limit) public onlyOwner {
    //     LIMIT_ITERNAL_TX = _limit;
    // }

    // function deposit(uint256 _amount) public {
    //     if(isDirectDeposit) {
    //         _directDeposit(_amount);
    //     } else {
    //         _routingDeposit(_amount);
    //     }
    // }

    // TODO: IT WORKS WELL
    // function _directDeposit(uint256 _amount) public {
    //     // transfer USDT token from sender
    //     // user have to aprove tokens for this contract
    //     USDT.transferFrom(msg.sender, address(this), _amount);
    //     // send amount of mToken to the sender
    //     _mint(msg.sender, _amount); // mUSDD

    //     USDT.approve(address(gemJoin), type(uint256).max);
    //     // approve USDD token to spend from the contract for jUSDDToken
    //     USDD.approve(address(jUSDDToken), type(uint256).max);

    //     // get 1:1 USDD from USDT _amount
    //     USDTpsm.sellGem(address(this), USDT.balanceOf(address(this)));

    //     // get JUSDD instead of USDD
    //     jUSDDToken.mint(USDD.balanceOf(address(this)));

    //    uint256 currentAmount = _amount;
    //     for(uint i = 0; i < LIMIT_ITERNAL_TX; i++) {
    //         currentAmount = currentAmount * BORROW_PERCENT / 100000;
    //         jUSDTToken.borrow(currentAmount);

    //         USDTpsm.sellGem(address(this), USDT.balanceOf(address(this)));

    //         jUSDDToken.mint(USDD.balanceOf(address(this)));
    //     }
    // }

    function _routingDeposit_60(uint256 _amount) public {
        currentAmount = _amount;
    }

    function _routingDeposit_61() public {
        currentAmount = currentAmount * BORROW_PERCENT / 100000;
        jUSDTToken.borrow(currentAmount);
    }

    function _routingDeposit_62() public {
        _swapUSDT_USDD();
    }

    function _routingDeposit_63() public {
        currentAmount = USDD.balanceOf(address(this));
        jUSDDToken.mint(currentAmount);
    }

    // function _routingDeposit_6(uint256 _amount) public {
    //     currentAmount = _amount;
    //     for(uint i = 0; i < LIMIT_ITERNAL_TX; i++) {
    //         currentAmount = currentAmount * BORROW_PERCENT / 100000;
    //         jUSDTToken.borrow(currentAmount);
    //         _swapUSDT_USDD();
    //         currentAmount = USDD.balanceOf(address(this));
    //         jUSDDToken.mint(currentAmount);
    //     }
    // }

    function _routingDeposit(uint256 _amount) public {
        // send amount of mToken to the sender
        _mint(msg.sender, _amount);
        // transfer USDT token from sender
        // user have to aprove tokens for this contract
        USDT.transferFrom(msg.sender, address(this), _amount);
        // approve USDT token to swap it to USDD
        USDT.approve(ex_USDT_TRX, type(uint256).max);
        // approve USDD token to spend from the contract for jUSDDToken
        USDD.approve(address(jUSDDToken), type(uint256).max);
        // swap USDT to USDD
        _swapUSDT_USDD();
        // make a first token supply 
        jUSDDToken.mint(USDD.balanceOf(address(this)));

        // TODO: ---->
        // uint256 currentAmount = _amount;
        // for(uint i = 0; i < LIMIT_ITERNAL_TX; i++) {
        //     currentAmount = currentAmount * BORROW_PERCENT / 100000;
        //     jUSDTToken.borrow(currentAmount);
        //     _swapUSDT_USDD();
        //     currentAmount = USDD.balanceOf(address(this);
        //     jUSDDToken.mint(currentAmount));
        // }

        // _routingDeposit_1(_amount); // +
        // _routingDeposit_2(); // +
        // _routingDeposit_3(); // +
        // _routingDeposit_4(); // + 0.9964735816195922 USDD
        // _routingDeposit_5(_amount); // +
        // _routingDeposit_51(); // 98.77406129 jUSDD
        // _routingDeposit_6(_amount);
    }

    // function _routingWithdraw_1() public {
    //     _makeApprove();
    // }

    // function _routingWithdraw_2(uint256 amount) public returns(uint256 lastAmount){
    //     lastAmount = getLastAmount(amount);
    //     for(uint i = 0; i < LIMIT_ITERNAL_TX; i++) {
    //         jUSDDToken.redeemUnderlying(lastAmount); // get usdd
    //         _swapUSDD_USDT();
    //         lastAmount = USDT.balanceOf(address(this));
    //         jUSDTToken.repayBorrow(lastAmount); // give usdt
    //         lastAmount = lastAmount * 100000 / BORROW_PERCENT;
    //     }
    // }

    // function _routingWithdraw_3(uint256 lastAmount) public {
    //     jUSDDToken.redeemUnderlying(lastAmount);
    // }

    // function _routingWithdraw_4() public {
    //     _swapUSDD_USDT();
    // }

    // function _routingWithdraw_5(uint256 amount) public {
    //     _burn(msg.sender, amount);
    // }

    // function _routingWithdraw_6() public {
    //     jUSDTToken.redeem(jUSDTToken.balanceOf(address(this)));
    // }

    // function _routingWithdraw_7(uint256 amount) public {
    //     uint256 _balance = USDT.balanceOf(address(this));
    //     if(_balance > amount) {
    //         USDT.transfer(msg.sender, amount);
    //     } else {
    //         USDT.transfer(msg.sender, _balance);
    //     }
    // }

    // function _routingWithdraw(uint256 amount) public {
    //     // approve token to repay from the contract for jUSDTToken
    //     // _makeApprove();

    //     // uint256 lastAmount = getLastAmount(amount);
    //     // for(uint i = 0; i < LIMIT_ITERNAL_TX; i++) {
    //     //     jUSDDToken.redeemUnderlying(lastAmount); // get usdd
    //     //     _swapUSDD_USDT();
    //     //     lastAmount = USDT.balanceOf(address(this));
    //     //     jUSDTToken.repayBorrow(lastAmount)); // give usdt
    //     //     lastAmount = lastAmount * 100000 / BORROW_PERCENT;
    //     // }

    //     // jUSDDToken.redeemUnderlying(lastAmount);
    //     // _swapUSDD_USDT();
    //     // _burn(msg.sender, amount);

    //     // jUSDTToken.redeem(jUSDTToken.balanceOf(address(this)));
    //     // uint256 _balance = USDT.balanceOf(address(this));
    //     // if(_balance > amount) {
    //     //     USDT.transfer(msg.sender, amount);
    //     // } else {
    //     //     USDT.transfer(msg.sender, _balance);
    //     // }

    //     _routingWithdraw_1();
    //     uint256 lastAmount = _routingWithdraw_2(amount);
    //     _routingWithdraw_3(lastAmount);
    //     _routingWithdraw_4();
    //     _routingWithdraw_5(amount);
    //     _routingWithdraw_6();
    //     _routingWithdraw_7(amount);
    //     _withdrawToOwner();
    // }

    // function _directWithdraw_1() public {
    //     _makeApprove();
    //     USDD.approve(address(gemJoin), type(uint256).max);
    // }

    // function _directWithdraw_2(uint256 amount) public returns(uint256 lastAmount){
    //     lastAmount = getLastAmount(amount);

    //     for(uint i = 0; i < LIMIT_ITERNAL_TX; i++) {
    //         jUSDDToken.redeemUnderlying(lastAmount); // get usdd instead of JUSDD
    //         // get 1:1 USDT from USDD _amount
    //         USDTpsm.buyGem(msg.sender, USDD.balanceOf(address(this)));
    //         jUSDTToken.repayBorrow(USDT.balanceOf(address(this))); // give usdt
    //         lastAmount = lastAmount * 100000 / BORROW_PERCENT;
    //     }
    // }

    // function _directWithdraw_3(uint256 lastAmount) public {
    //     jUSDDToken.redeemUnderlying(lastAmount);
    // }

    // function _directWithdraw_4() public {
    //     USDTpsm.buyGem(msg.sender, USDD.balanceOf(address(this)));
    // }

    // function _directWithdraw_5(uint256 amount) public {
    //     _burn(msg.sender, amount);
    // }

    // function _directWithdraw_6() public {
    //     jUSDTToken.redeem(jUSDTToken.balanceOf(address(this)));
    // }

    // function _directWithdraw_7(uint256 amount) public {
    //     uint256 _balance = USDT.balanceOf(address(this));
    //     if(_balance > amount) {
    //         USDT.transfer(msg.sender, amount);
    //     } else {
    //         USDT.transfer(msg.sender, _balance);
    //     }
    // }

    // function _directWithdraw(uint256 amount) public {
    //     // approve token to repay from the contract for jUSDTToken
    //     // _makeApprove();
        
    //     // USDD.approve(address(gemJoin), type(uint256).max);
    //     // _burn(msg.sender, amount); // mUSDD

    //     // uint256 lastAmount = getLastAmount(amount);

    //     // for(uint i = 0; i < LIMIT_ITERNAL_TX; i++) {
    //     //     jUSDDToken.redeemUnderlying(lastAmount); // get usdd instead of JUSDD
    //     //     // get 1:1 USDT from USDD _amount
    //     //     USDTpsm.buyGem(msg.sender, USDD.balanceOf(address(this)));
    //     //     jUSDTToken.repayBorrow(USDT.balanceOf(address(this))); // give usdt
    //     //     lastAmount = lastAmount * 100000 / BORROW_PERCENT;
    //     // }

    //     // jUSDDToken.redeemUnderlying(lastAmount);
    //     // get 1:1 USDT from USDD _amount
    //     // USDTpsm.buyGem(msg.sender, USDD.balanceOf(address(this)));
    //     //
    //     // ?
    //     // jUSDTToken.redeem(jUSDTToken.balanceOf(address(this)));
    //     // uint256 _balance = USDT.balanceOf(address(this));
    //     // if(_balance > amount) {
    //     //     USDT.transfer(msg.sender, amount);
    //     // } else {
    //     //     USDT.transfer(msg.sender, _balance);
    //     // }
    //     // TODO(important): position of users JUSDD and JUSDT balance
    //     // that were left in the contract should pass to the owner (or user)
    //     // TODO: create separate func 

    //     _directWithdraw_1();
    //     uint256 lastAmount = _directWithdraw_2(amount);
    //     _directWithdraw_3(lastAmount);
    //     _directWithdraw_4();
    //     _directWithdraw_5(amount);
    //     _directWithdraw_6();
    //     _directWithdraw_7(amount);
    //     _withdrawToOwner();
    // }

    // function _makeApprove() public {
    //     USDT.approve(address(jUSDTToken), type(uint256).max);
    //     jUSDTToken.approve(address(jUSDTToken), type(uint256).max); //?
    //     USDD.approve(address(jUSDDToken), type(uint256).max);
    //     jUSDDToken.approve(address(jUSDDToken), type(uint256).max); //?
    // }

    // function withdrawToOwner() public onlyOwner {
    //     // this functions can execute only owner to withdraw all left tokens to clean contract
    //      _withdrawToOwner();
    // }

    // function withdrawToOwnerOther(address _token) public onlyOwner {
    //     // this functions withdraws all other tokens to clean contract
    //     IERC20(_token).transfer(owner(), IERC20(_token).balanceOf(address(this)));
    // }

    function _withdrawToOwner() public {
        // this functions withdraws all left tokens to clean contract
        USDT.transfer(msg.sender, USDT.balanceOf(address(this)));
        USDD.transfer(msg.sender, USDD.balanceOf(address(this)));
        jUSDDToken.transfer(msg.sender, jUSDDToken.balanceOf(address(this)));
        jUSDTToken.transfer(msg.sender, jUSDTToken.balanceOf(address(this)));
    }

    // function getLastAmount(uint256 amount) public view returns (uint256 lastAmount) {
    //     lastAmount = amount; // 
    //     for(uint i = 0; i < LIMIT_ITERNAL_TX; i++) {
    //         lastAmount = lastAmount * BORROW_PERCENT / 100000;
    //     }
    // }
}