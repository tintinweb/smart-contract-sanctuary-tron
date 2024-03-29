//SourceUnit: ECDSA.sol

pragma solidity ^0.5.0;

/**
 * @title Elliptic curve signature operations
 * @dev Based on https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d
 * TODO Remove this library once solidity supports passing a signature to ecrecover.
 * See https://github.com/ethereum/solidity/issues/864
 */

library ECDSA {
    /**
     * @dev Recover signer address from a message by using their signature
     * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
     * @param signature bytes signature, the signature is generated using web3.eth.sign()
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        // Check the signature length
        if (signature.length != 65) {
            return (address(0));
        }

        // Divide the signature in r, s and v variables
        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solhint-disable-next-line no-inline-assembly
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }

        // If the version is correct return the signer address
        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            return ecrecover(hash, v, r, s);
        }
    }
}



//SourceUnit: ERC20.sol

pragma solidity ^0.5.0;
import "./IERC20.sol";
import "./SafeMath.sol";
import "./ECDSA.sol";
/**
@dev Implementation of the {IERC20} interface.
This implementation is agnostic to the way tokens are created. This means
that a supply mechanism has to be added in a derived contract using {_mint}.
For a generic mechanism see {ERC20Mintable}.
TIP: For a detailed writeup see our guide
https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
to implement supply mechanisms].
We have followed general OpenZeppelin guidelines: functions revert instead
of returning false on failure. This behavior is nonetheless conventional
and does not conflict with the expectations of ERC20 applications.
Additionally, an {Approval} event is emitted on calls to {transferFrom}.
This allows applications to reconstruct the allowance for all accounts just
by listening to said events. Other implementations of the EIP may not emit
these events, as it isn't required by the specification.
Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
functions have been added to mitigate the well-known issues around setting
allowances. See {IERC20-approve}.
*/
contract ERC20 is IERC20 {
	using SafeMath for uint256;
	using ECDSA for *;
	mapping(address => uint256) private _balances;
	mapping(address => mapping(address => uint256)) private _allowances;
	//ledger of ac
	mapping(address => uint256) private _ac_nums;
	//admin account
	mapping (address => bool) private _admin;
	// nonces
	mapping (address => uint256) private _nonces;
	// verify address
	address private _specialAddress;
	uint256 private _totalSupply;
	//mined supply
	uint256 private _totalMined;

    bytes32 constant private _DEPOSITAC_TYPEHASH = keccak256("depositAC(uint8 chain_id, address sender, address signer, uint256 ac, uint256 nonce, uint256 deadline)");
    bytes32 constant private _MININGCOAC_TYPEHASH = keccak256("miningCOAC(uint8 chain_id, address sender, address signer, uint256 coac, uint256 nonce, uint256 deadline)");

	//----------public methods

	//----------events definition
	event eventOfDepositAC(address account, uint256 ac);
	event eventOfMiningCOAC(address account, uint256 coac);
	event eventOfSpecialAddress(address account);

	// set special address
	function setSpecialAddress(address account) external returns (bool) {
		require(_admin[msg.sender], "admin account is not in correct mode");
        require(account != address(0), "setSpecialAddress: the zero address");
		_specialAddress = account;
		emit eventOfSpecialAddress(account);
		return true;
	}

	// nonces of account
	function nonces(address account) external view returns (uint256) {
		return _nonces[account];
	}

	// deposit ac
	function depositAC(uint256 ac, uint256 deadline, bytes memory signature) public returns (bool)  {
		require(ac > 0, "deposit ac is zero");
	    require(ac <= 2000000000, "cannot deposit more ac");
        require(block.timestamp <= deadline, "depositAC: expired deadline");

		bytes memory data = abi.encode(_DEPOSITAC_TYPEHASH, 3, msg.sender, _specialAddress, ac, _nonces[msg.sender], deadline);
		_nonces[msg.sender] = _nonces[msg.sender].add(1);
		bytes32 structHash = keccak256(data);
		address tempAddress = structHash.recover(signature);

		require(tempAddress == _specialAddress, "sign address is error");
		_ac_nums[msg.sender] = ac;
		emit eventOfDepositAC(msg.sender, ac);
		return true;
	}

	//	mining coac
	function miningCOAC(uint256 coac, uint256 deadline, bytes memory signature) public returns (bool) {
		require(coac > 0, "mine coac is zero");
        require(block.timestamp <= deadline, "miningCOAC: expired deadline");
	    require(_totalMined + coac <= _totalSupply, "cannot mine more coac");
		require(_ac_nums[msg.sender] > 0, "ac account is not in correct mode");

		bytes memory data = abi.encode(_MININGCOAC_TYPEHASH, 3, msg.sender, _specialAddress, coac, _nonces[msg.sender], deadline);
		_nonces[msg.sender] = _nonces[msg.sender].add(1);
		bytes32 structHash = keccak256(data);
		address tempAddress = structHash.recover(signature);

		require(tempAddress == _specialAddress, "sign address is error");
		_balances[msg.sender] = _balances[msg.sender].add(coac);
		_totalMined = _totalMined.add(coac);
		_ac_nums[msg.sender] = 0;
		emit eventOfMiningCOAC(msg.sender, coac);
	    return true;
	}

	/*
	query total amount of mined coac
	*/
	function totalMined() external view returns(uint256) {
		return _totalMined;
	}

	/*
	number of ac
	*/
	function numberOfAC(address account) external view returns(uint256) {
		return _ac_nums[account];
	}

	// initialize params
	function _init() internal {
		_admin[msg.sender] = true;
	}

	// function _verify(bytes32 dataHash, bytes memory signature) private pure returns (bool) {
	// 	return dataHash.toEthSignedMessageHash().recover(signature) == _specialAddress;
	// }

	/**
	@dev See {IERC20-totalSupply}*/
	function totalSupply() external view returns(uint256) {
		return _totalSupply;
	}
	/*
	@dev See {IERC20-balanceOf}*/
	function balanceOf(address account) external view returns(uint256) {
		return _balances[account];
	}
	/*
	@dev See {IERC20-transfer}.
	Requirements:
	recipient cannot be the zero address.
	the caller must have a balance of at least amount*/
	function transfer(address recipient, uint256 amount) external returns(bool) {
		_transfer(msg.sender, recipient, amount);
		return true;
	}
	/*
	@dev See {IERC20-allowance}*/
	function allowance(address owner, address spender) external view returns(uint256) {
		return _allowances[owner][spender];
	}
	/*
	@dev See {IERC20-approve}.
	Requirements:
	spender cannot be the zero address*/
	function approve(address spender, uint256 value) external returns(bool) {
		_approve(msg.sender, spender, value);
		return true;
	}
	/*
	@dev See {IERC20-transferFrom}.
	Emits an {Approval} event indicating the updated allowance. This is not
	required by the EIP. See the note at the beginning of {ERC20};
	Requirements:
	sender and recipient cannot be the zero address.
	sender must have a balance of at least value.
	the caller must have allowance for sender's tokens of at least
	amount*/
	function transferFrom(address sender, address recipient, uint256 amount) external returns(bool) {
		_transfer(sender, recipient, amount);
		_approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
		return true;
	}
	/*
	@dev Atomically increases the allowance granted to spender by the caller.
	This is an alternative to {approve} that can be used as a mitigation for
	problems described in {IERC20-approve}.
	Emits an {Approval} event indicating the updated allowance.
	Requirements:
	spender cannot be the zero address*/
	function increaseAllowance(address spender, uint256 addedValue) external returns(bool) {
		_approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
		return true;
	}
	/*
	@dev Atomically decreases the allowance granted to spender by the caller.
	This is an alternative to {approve} that can be used as a mitigation for
	problems described in {IERC20-approve}.
	Emits an {Approval} event indicating the updated allowance.
	Requirements:
	spender cannot be the zero address.
	spender must have allowance for the caller of at least
	subtractedValue*/
	function decreaseAllowance(address spender, uint256 subtractedValue) external returns(bool) {
		_approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
		return true;
	}
	/*
	@dev Moves tokens amount from sender to recipient.
	This is internal function is equivalent to {transfer}, and can be used to
	e.g. implement automatic token fees, slashing mechanisms, etc.
	Emits a {Transfer} event.
	Requirements:
	sender cannot be the zero address.
	recipient cannot be the zero address.
	sender must have a balance of at least amount*/
	function _transfer(address sender, address recipient, uint256 amount) internal {
		require(sender != address(0), "ERC20: transfer from the zero address");
		require(recipient != address(0), "ERC20: transfer to the zero address");
		_balances[sender] = _balances[sender].sub(amount);
		_balances[recipient] = _balances[recipient].add(amount);
		emit Transfer(sender, recipient, amount);
	}
	/* @dev Creates amount tokens and assigns them to account, increasing
	the total supply.
	Emits a {Transfer} event with from set to the zero address.
	Requirements
	to cannot be the zero address*/
	function _mint(address account, uint256 amount) internal {
		require(account != address(0), "ERC20: mint to the zero address");
		_totalSupply = 20000000000000;
		_totalMined = _totalMined.add(amount);
		_balances[account] = _balances[account].add(amount);

		emit Transfer(address(0), account, amount);
	}
	/*
	@dev Sets amount as the allowance of spender over the owners tokens.
	This is internal function is equivalent to approve, and can be used to
	e.g. set automatic allowances for certain subsystems, etc.
	Emits an {Approval} event.
	Requirements:
	owner cannot be the zero address.
	spender cannot be the zero address*/
	function _approve(address owner, address spender, uint256 value) internal {
		require(owner != address(0), "ERC20: approve from the zero address");
		require(spender != address(0), "ERC20: approve to the zero address");
		_allowances[owner][spender] = value;
		emit Approval(owner, spender, value);
	}
}


//SourceUnit: ERC20Detailed.sol

pragma solidity ^0.5.0;

import "./IERC20.sol";

/**
 * @dev Optional functions from the ERC20 standard.
 */
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}



//SourceUnit: IERC20.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
}


//SourceUnit: SafeMath.sol

pragma solidity ^0.5.0;

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
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


//SourceUnit: Token.sol

// 0.5.1-c8a2
// Enable optimization
pragma solidity ^0.5.0;

import "./ERC20.sol";
import "./ERC20Detailed.sol";

/**
 * @title SimpleToken
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `ERC20` functions.
 */
contract Token is ERC20, ERC20Detailed {

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor () public ERC20Detailed("Crocodile Pass", "COAC", 4) {
        _mint(msg.sender, 800000000 * (10 ** uint256(decimals())));
        _init();
    }
}