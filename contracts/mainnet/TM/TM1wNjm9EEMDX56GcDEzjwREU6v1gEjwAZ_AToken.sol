//SourceUnit: Untitled-1.sol

// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

abstract contract ERC20 {
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    string public name;
    string public symbol;
    uint8 public immutable decimals;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    /*//////////////////////////////////////////////////////////////
                               ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
		_transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

		_transfer(from, to, amount);
		return true;
	}

	function _transfer(
		address from,
		address to,
		uint256 amount
	) internal virtual {

        balanceOf[from] -= amount;
        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }
        emit Transfer(from, to, amount);
	}

	function _mint(address to, uint256 amount) internal virtual {
		totalSupply += amount;

		// Cannot overflow because the sum of all user
		// balances can't exceed the max uint256 value.
		unchecked {
			balanceOf[to] += amount;
		}

		emit Transfer(address(0), to, amount);
	}

	function _burn(address from, uint256 amount) internal virtual {
		balanceOf[from] -= amount;

		// Cannot underflow because a user's balance
		// will never be larger than the total supply.
		unchecked {
			totalSupply -= amount;
		}

		emit Transfer(from, address(0), amount);
	}
}

abstract contract Owned {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event OwnerUpdated(address indexed user, address indexed newOwner);

    /*//////////////////////////////////////////////////////////////
                            OWNERSHIP STORAGE
    //////////////////////////////////////////////////////////////*/

    address public owner;

    modifier onlyOwner() virtual {
        require(msg.sender == owner, "UNAUTHORIZED");

        _;
    }

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor() {
        owner = msg.sender;
        emit OwnerUpdated(address(0), msg.sender);
    }

    /*//////////////////////////////////////////////////////////////
                             OWNERSHIP LOGIC
    //////////////////////////////////////////////////////////////*/

    function setOwner(address newOwner) public virtual onlyOwner {
        owner = newOwner;
        emit OwnerUpdated(msg.sender, newOwner);
    }
}

contract ExcludedFromFeeList is Owned {
	mapping (address => bool) internal _isExcludedFromFee;

	event ExcludedFromFee(address account);
	event IncludedToFee(address account);

	function isExcludedFromFee(address account) public view returns(bool) {
		return _isExcludedFromFee[account];
	}

	function excludeFromFee(address account) public onlyOwner {
		_isExcludedFromFee[account] = true;
		emit ExcludedFromFee(account);
	}

	function includeInFee(address account) public onlyOwner {
		_isExcludedFromFee[account] = false;
		emit IncludedToFee(account);
	}
}


contract AToken is ExcludedFromFeeList, ERC20 {
	uint private constant burnFee = 3;
	uint private constant marketFee = 2;
	uint private constant fundFee = 8;
	uint private constant __total = 24 * 10000_0000 * 1e18;
	address private constant burnAddr = 0x000000000000000000000000000000000000dEaD;
	address private immutable marketAddr;
	address private immutable fundAddr;
	address public sunSwapPair = 0x6E0617948FE030a7E4970f8389d4Ad295f249B7e;


	constructor(address _marketAddress, address _fundAddress) ERC20("KXL", 'KXL', 18){
		_mint(msg.sender, __total);
		marketAddr = _marketAddress;
		fundAddr = _fundAddress;
		excludeFromFee(msg.sender);
	}

	function shouldTakeFee(address sender, address recipient) internal view returns (bool) {
		if(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]){
			return false;
		}
		if(recipient == sunSwapPair){
			return true; 
		}
		return false;
	}

	function _takeBurn(address sender, uint256 amount) internal returns (uint256) {
		if(balanceOf[burnAddr] > __total - 22 * 10000_000 * 1e18){
			return 0;
		}
		uint256 burnAmount = amount * burnFee / 100;
		super._transfer(sender, burnAddr, burnAmount);
		return burnAmount;
	}

	function _takeMarket(address sender, uint256 amount) internal returns (uint256) {
		uint256 marketAmount = amount * marketFee / 100;
		super._transfer(sender, marketAddr, marketAmount);
		return marketAmount;
	}
	function _takeFund(address sender, uint256 amount) internal returns (uint256) {
		uint256 fundAmount = amount * fundFee / 100;
		super._transfer(sender, fundAddr, fundAmount);
		return fundAmount;
	}

	function takeFee(address sender, uint256 amount) internal returns (uint256) {
		uint256 burnAmount = _takeBurn(sender, amount);
		uint256 marketAmount = _takeMarket(sender, amount);
		uint256 fundAmount = _takeFund(sender, amount);
		return amount - burnAmount - marketAmount - fundAmount;
	}

	function _transfer(
		address sender,
		address recipient,
		uint256 amount
	) internal virtual override {
		if(shouldTakeFee(sender, recipient)){
			uint256 transferAmount = takeFee(sender,  amount);
			super._transfer(sender, recipient, transferAmount);
		}else{
			super._transfer(sender, recipient, amount);
		}
	}

	function setSwapPairAddress(address _sunSwapPair) external onlyOwner {
			sunSwapPair = _sunSwapPair;
	}

}