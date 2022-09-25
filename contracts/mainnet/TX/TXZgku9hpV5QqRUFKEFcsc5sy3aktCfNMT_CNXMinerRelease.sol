//SourceUnit: CNXReleaseA.sol

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

abstract contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _owner = msg.sender;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
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

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[49] private __gap;
}

interface ERC20Interface {
    function decimals() external view returns (uint256);

    function name() external view returns (string memory);

    function balanceOf(address user) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);
}

library SafeToken {
    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(
        address token,
        address owner,
        address spender
    ) internal view returns (uint256) {
        return ERC20Interface(token).allowance(owner, spender);
    }

    function myBalance(address token) internal view returns (uint256) {
        return ERC20Interface(token).balanceOf(address(this));
    }

    function name(address token) internal view returns (string memory) {
        return ERC20Interface(token).name();
    }

    function decimals(address token) internal view returns (uint256) {
        return ERC20Interface(token).decimals();
    }

    function balanceOf(address token, address user)
        internal
        view
        returns (uint256)
    {
        return ERC20Interface(token).balanceOf(user);
    }

    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x095ea7b3, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "!safeApprove"
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "!safeTransfer"
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "!safeTransferFrom"
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, "!safeTransferETH");
    }
}

contract CNXMinerRelease is Ownable {
    using SafeToken for address;
    struct MapRecord {
        address _user;
        uint256 _amount;
    }
    // CNX Mapping
    mapping(bytes32 => MapRecord) trxMappings;
    mapping(address => uint256) userAmounts;
    address public CNX;

    event MappingTRX(bytes32 _tx, address _owner, uint256 amount);

    function initialize(address _cnx) external onlyOwner {
        CNX = _cnx;
    }

    function mappingTrx(
        bytes32 _tx,
        address _user,
        uint256 amount
    ) external onlyOwner {
        require(amount > 0, "amount can not zero!");
        require(trxMappings[_tx]._amount == 0, "tx has already mapped!");
        trxMappings[_tx]._user = _user;
        trxMappings[_tx]._amount = amount;
        userAmounts[_user] += amount;
        emit MappingTRX(_tx, _user, amount);
    }

    function mappingTrxAndSend(
        bytes32 _tx,
        address _user,
        uint256 amount
    ) external onlyOwner {
        require(amount > 0, "amount can not zero!");
        require(trxMappings[_tx]._amount == 0, "tx has already mapped!");
        trxMappings[_tx]._user = _user;
        trxMappings[_tx]._amount = amount;
        CNX.safeTransfer(_user, amount);
        emit MappingTRX(_tx, _user, amount);
    }

    function queryTx(bytes32 _tx) public view returns (uint256) {
        return trxMappings[_tx]._amount;
    }

    function query(address _user) public view returns (uint256) {
        return userAmounts[_user];
    }

    function claim(address _user) public {
        uint256 amount = query(_user);
        if (amount <= 0) {
            return;
        }
        CNX.safeTransfer(_user, amount);
        userAmounts[_user] = 0;
    }

    function batchClaim(address[] memory _users) external {
        for (uint256 i = 0; i < _users.length; i++) {
            claim(_users[i]);
        }
    }
}