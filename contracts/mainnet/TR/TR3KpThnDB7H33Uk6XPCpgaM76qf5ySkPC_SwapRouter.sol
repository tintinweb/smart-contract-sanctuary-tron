//SourceUnit: IERC20.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

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

//SourceUnit: Ownable.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;

    /**
      * @dev The Ownable constructor sets the original `owner` of the contract to the sender
      * account.
      */
    constructor() {
        owner = msg.sender;
    }

    /**
      * @dev Throws if called by any account other than the owner.
      */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }

}

//SourceUnit: SwapRouter.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Ownable.sol";
import "./IERC20.sol";

contract SwapRouter is Ownable {

    address public feeTo;

    struct TokenInfo {
        uint256 chainId;
        address token;
    }

    struct FeeInfo {
        uint256 rate;
        uint256 min;
    }

    mapping(address => mapping(uint256 => mapping(address => FeeInfo))) public feePair;
    mapping(uint256 => mapping(address => uint256)) public tokenBalances;
    mapping(uint256 => mapping(address => bool)) swapTokens;
    TokenInfo[] public allTokens;

    event PairCreated(address indexed token0, address indexed token1, uint256 chainId, uint256 feeRate, uint256 feeMin);

    event Withdraw(address indexed payment, address indexed token, uint256 chainId, uint256 amount);

    event Swap(address indexed token0, address indexed token1, address indexed payment, uint256 chainId, uint256 amount, uint256 fee);

    constructor() {
    }

    function createPair(address tokenA, address tokenB, uint256 chainId, uint256 feeRate, uint256 feeMin) external onlyOwner {

        require(feeRate <= 1000, "Rate ratio cannot be greater than 1000");

        require(tokenA != address(0), 'ZERO_ADDRESS');
        require(tokenB != address(0), 'ZERO_ADDRESS');
        require(tokenA != tokenB, "token cannot be the same");

        FeeInfo memory feeInfo;
        feeInfo.rate = feeRate;
        feeInfo.min = feeMin;
        feePair[tokenA][chainId][tokenB] = feeInfo;

        emit PairCreated(tokenA, tokenB, chainId, feeRate, feeMin);
    }

    function withdraw(address payment, address token, uint256 chainId, uint256 amount) payable external onlyOwner {

        require(payment != address(0), 'ZERO_ADDRESS');
        require(token != address(0), 'ZERO_ADDRESS');
        require(amount > 0, "Withdrawal amount must be greater than 0");

        require(tokenBalances[chainId][token] > amount, 'Not Balance');
        tokenBalances[chainId][token] -= amount;

        if (token != address(1)) {
            IERC20(token).transfer(payment, amount);
        } else {
            payable(payment).transfer(amount);
        }

        emit Withdraw(payment, token, chainId, amount);
    }

    function swap(address tokenA, address tokenB, address payment, uint256 chainId, uint256 amount) payable external {

        if (tokenA == address(1)) {
            amount = msg.value;
        }
        require(amount > 0, "Swap amount must be greater than 0");

        if (!swapTokens[chainId][tokenA]) {
            TokenInfo memory _tokenInfo = TokenInfo({
            chainId : chainId,
            token : tokenA
            });
            allTokens.push(_tokenInfo);
        }

        FeeInfo memory feeInfo = feePair[tokenA][chainId][tokenB];
        uint256 feeRate = feeInfo.rate;
        uint256 fee = 0;

        if (tokenA != address(1)) {
            uint256 before = IERC20(tokenA).balanceOf(address(this));
            IERC20(tokenA).transferFrom(msg.sender, address(this), amount);
            amount = IERC20(tokenA).balanceOf(address(this)) - before;

            if (feeTo != address(0) && feeRate > 0) {
                fee = amount * feeRate / 1000;
            }

            if (fee < feeInfo.min) {
                fee = feeInfo.min;
            }

            require(amount - fee > 0, "Swap amount must be greater than fee");
            if (fee > 0) {
                IERC20(tokenA).transfer(feeTo, fee);
            }
        } else {
            if (feeTo != address(0) && feeRate > 0) {
                fee = amount * feeRate / 1000;
            }

            if (fee < feeInfo.min) {
                fee = feeInfo.min;
            }
            if (fee > 0) {
                payable(feeTo).transfer(fee);
            }
        }

        uint256 realAmount = amount - fee;

        tokenBalances[chainId][tokenA] += realAmount;

        emit Swap(tokenA, tokenB, payment, chainId, realAmount, fee);
    }

    function setFeeTo(address _feeTo) external onlyOwner {
        feeTo = _feeTo;
    }

    function balance() public view returns (uint256) {
        return address(this).balance;
    }

    function deposit(uint256 chainId, address token, uint256 amount) payable external returns (bool){
        uint256 before = IERC20(token).balanceOf(address(this));
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        amount = IERC20(token).balanceOf(address(this)) - before;

        tokenBalances[chainId][token] += amount;

        return true;
    }
}