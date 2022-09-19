//SourceUnit: ITRC20.sol

// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.22 <0.9.0;

/**
 * @dev Interface of the TRC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {TRC20Detailed}.
 */
interface ITRC20 {
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

//SourceUnit: Migrations.sol

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Migrations {
    address public owner = msg.sender;
    uint256 public last_completed_migration;

    modifier restricted() {
        require(
            msg.sender == owner,
            "This function is restricted to the contract's owner"
        );
        _;
    }

    function setCompleted(uint256 completed) public restricted {
        last_completed_migration = completed;
    }

    function upgrade(address new_address) public restricted {
        Migrations upgraded = Migrations(new_address);
        upgraded.setCompleted(last_completed_migration);
    }
}


//SourceUnit: SalesDash.sol

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./ITRC20.sol";

contract SalesDash {
    // to save the owner of the contract in construction
    address private owner;

    // to save smart contract instance for interact with USDT smart contract
    ITRC20 private usdt;

    bool public paused = false;

    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);

    // modifier to check if the caller is owner
    modifier isOwner() {
        // If the first argument of 'require' evaluates to 'false', execution terminates and all
        // changes to the state and to USDT balances are reverted.
        // This used to consume all gas in old EVM versions, but not anymore.
        // It is often a good idea to use 'require' to check if functions are called correctly.
        // As a second argument, you can also provide an explanation about what went wrong.
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
     * @dev Set contract deployer as owner
     */
    constructor(address payable trc20ContractAddress) payable {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor

        emit OwnerSet(address(0), owner);

        require(trc20ContractAddress != address(0));

        usdt = ITRC20(trc20ContractAddress);
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public isOwner whenNotPaused {
        paused = true;
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public isOwner whenPaused {
        paused = false;
    }

    // the owner of the smart-contract can chage its owner to whoever
    // he/she wants
    function changeOwner(address newOwner) public isOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    /**
     * @dev Return owner address
     * @return address of owner
     */

    function getOwner() external view returns (address) {
        return owner;
    }

    //to return total amount available in the smart contract
    function getBalance(address payable trc20ContractAddress)
        external
        view
        isOwner 
        whenNotPaused
        returns (uint256)
    {
        ITRC20 token = ITRC20(trc20ContractAddress);
        return token.balanceOf(address(this));
    }

    // sum adds the different elements of the array and return its sum
    function sum(uint256[] memory amounts)
        private
        pure
        returns (uint256 retVal)
    {
        // the value of message should be exact of total amounts
        uint256 totalAmnt = 0;

        for (uint256 i = 0; i < amounts.length; i++) {
            totalAmnt += amounts[i];
        }

        return totalAmnt;
    }

    // withdraw perform the transfering of USDT (TRC20)
    function withdraw(address payable receiverAddr, uint256 receiverAmnt)
        private
    {
        usdt.transfer(receiverAddr, receiverAmnt);
    }

    // withdraw perform the transfering of other TRC20 tokens
    function withdraw(
        address payable trc20ContractAddress,
        address payable receiverAddr,
        uint256 receiverAmnt
    ) external payable isOwner whenNotPaused returns (uint256) {
        ITRC20 token = ITRC20(trc20ContractAddress);
        token.transfer(receiverAddr, receiverAmnt);
        return token.balanceOf(address(this));
    }

    // withdraw perform the transfering of TRX
    function withdrawTrx(address payable receiverAddr, uint256 receiverAmnt)
        external
        payable
        isOwner 
        whenNotPaused
        returns (uint256)
    {
        receiverAddr.transfer(receiverAmnt);
        return address(this).balance;
    }

    // withdrawls enable to multiple withdraws to different accounts
    // at one call, and decrease the network fee
    function withdrawals(address payable[] memory addrs, uint256[] memory amnts)
        public
        payable
        isOwner
        whenNotPaused
        returns (uint256)
    {
        // the addresses and amounts should be same in length
        require(
            addrs.length == amnts.length,
            "The length of two array should be the same"
        );

        // the value of the message in addition to sotred value should be more than total amounts
        uint256 totalAmnt = sum(amnts);

        require(
            usdt.balanceOf(address(this)) >= totalAmnt,
            "The value is not sufficient or exceed"
        );

        for (uint256 i = 0; i < addrs.length; i++) {
            // send the specified amount to the recipient
            withdraw(addrs[i], amnts[i]);
        }

        return usdt.balanceOf(address(this));
    }
}