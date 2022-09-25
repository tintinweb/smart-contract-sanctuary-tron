//SourceUnit: Datasets.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

contract Datasets {
    address owner;
    uint256 tecRatio;
    address technologyAddr;
    address implementation;
    struct Passbook {
        address tokenAddr;
        uint256 amount;
        bool state;
    }
    mapping(bytes32 => Passbook) PassbookMap;
}


//SourceUnit: SafeMath.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

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


//SourceUnit: TronMix.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

import "./SafeMath.sol";
import "./Datasets.sol";

contract TronMix is Datasets {
    using SafeMath for uint256;

    constructor() {owner = msg.sender;}

    receive() external payable {}

    fallback() external payable {
        address impl = implementation;
        require(impl != address(0), "implementation must already exists");
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize())
            let result := delegatecall(gas(), impl, ptr, calldatasize(), 0, 0)
            let size := returndatasize()
            returndatacopy(ptr, 0, size)
            switch result
            case 0 {
                revert(ptr, size)
            }
            default {
                return(ptr, size)
            }
        }
    }

    modifier validDestination(address _to) {
        require(_to != address(0x0), "address cannot be 0x0");
        _;
    }

    modifier onlyowner() {
        require(owner == msg.sender, "Insufficient permissions");
        _;
    }

    function deposit(address _tokenAddr, bytes32 ciphertext, uint256 amount) public validDestination(_tokenAddr) returns (bool) {
        require(amount > 0, "Incorrect token quantity");
        Token token = Token(_tokenAddr);
        require(token.balanceOf(msg.sender) >= amount, "Insufficient amount");
        require(token.allowance(msg.sender, address(this)) >= amount, "Insufficient authorized amount");
        token.transferFrom(msg.sender, address(this), amount);
        PassbookMap[ciphertext] = Passbook(_tokenAddr, amount, true);
        return true;
    }

    function withdraw(bytes memory password, address receivingAddress) public validDestination(receivingAddress) returns (bool) {
        bytes32 ciphertext = keccak256(password);
        Passbook memory passbook = PassbookMap[ciphertext];
        require(passbook.amount > 0, "password error");
        require(passbook.state == true, "has been extracted");
        passbook.state = false;
        Token token = Token(passbook.tokenAddr);
        if (token.balanceOf(address(this)) >= passbook.amount) {
            uint256 tecVal = passbook.amount.mul(tecRatio).div(10000);
            token.transfer(technologyAddr, tecVal);
            token.transfer(receivingAddress, passbook.amount.sub(tecVal));
        }
        return true;
    }

    function init(address _iAddr) external onlyowner validDestination(_iAddr) returns (bool) {
        implementation = _iAddr;
        return true;
    }
}

abstract contract Token {
    function transfer(address to, uint256 value) external virtual;
    function transferFrom(address from, address to, uint256 value) external virtual;
    function balanceOf(address who) external view virtual returns (uint256);
    function allowance(address owner, address spender) external view virtual returns (uint256);
}