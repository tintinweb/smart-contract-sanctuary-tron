//SourceUnit: ASGVerifyCode.sol

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

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

contract ASG is ITRC20 {
    string public constant name = "Ecological chain of consumption";
    string public constant symbol = "ASG";
    uint8 public constant decimals = 18;
    uint256 public override totalSupply = 130000000 * 10**decimals;
    uint256 public burnLimit = 13000000 * 10**decimals;
    
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowances;
    
    constructor () {
        balances[msg.sender] = totalSupply;
        
        emit Transfer(address(0), msg.sender, totalSupply);
    }
    
    function balanceOf(address account) external view override returns(uint256 balance) {
        balance = balances[account];
    }
    
    function allowance(address account, address spender) external view override returns(uint256){
        return allowances[account][spender];
    }
    
    function transfer(address recipient, uint256 amount) external override returns(bool success) {
        if (recipient == address(0)) {
            return burn(msg.sender, amount);
        }
        require(amount > 0, "ASG: amount must be greater than 0");
        require(balances[msg.sender] >= amount, "ASG: Insufficient balance");
        
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        success = true;
    }
    
    function approve(address spender, uint256 amount) external override returns(bool success) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        success = true;
    }
    
    function transferFrom(address sender, address recipient, uint256 amount) external override returns(bool success){
        require(recipient != address(0), "ASG: The destination address must not be 0");
        require(amount > 0, "ASG: amount must be greater than 0");
        require(allowances[sender][msg.sender] >= amount, "ASG:Insufficient authorization");
        require(balances[sender] >= amount, "ASG:Insufficient balance");
        
        allowances[sender][msg.sender] -= amount;
        balances[sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
        success = true;
    }
    
    function burn(address spender, uint256 amount) internal returns (bool success) {
        require(amount > 0, "ASG: burn amount of ASG must be greater than 0");
        require(totalSupply > burnLimit, "ASG: Destruction up to limit");
        if (totalSupply - amount < burnLimit) {
            amount = totalSupply - burnLimit;
        }
        require(balances[spender] >= amount, "ASG: Insufficient balance");
        totalSupply -= amount;
        balances[spender] -= amount;
        balances[address(0)] += amount;
        emit Transfer(spender, address(0), amount);
        success = true;
    }
}