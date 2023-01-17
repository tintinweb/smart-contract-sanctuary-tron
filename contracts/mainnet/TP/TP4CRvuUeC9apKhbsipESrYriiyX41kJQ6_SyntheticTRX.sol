//SourceUnit: Auth.sol

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity ^0.5.8;

contract Authority {
    function canCall(address src, address dst, bytes4 sig) public view returns (bool);
}

contract AuthEvents {
    event LogSetAuthority (address indexed authority);
    event LogSetOwner     (address indexed owner);
}

contract Auth is AuthEvents {
    Authority public authority;
    address   public owner;

    constructor() public {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

    function setOwner(address owner_) public auth {
        owner = owner_;
        emit LogSetOwner(owner);
    }

    function setAuthority(Authority authority_) public auth returns (bool result) {
        authority = authority_;
        emit LogSetAuthority(address(authority));
        result = true;
    }

    modifier auth {
        require(isAuthorized(msg.sender, msg.sig), "auth-unauthorized");
        _;
    }

    function isAuthorized(address src, bytes4 sig) public view returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == Authority(0)) {
            return false;
        } else {
            return authority.canCall(src, address(this), sig);
        }
    }
}

//SourceUnit: Distribution.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.5.8;

import "../Auth.sol";

contract DistributionEvents {
    event Distributor(address indexed distributor);
}

contract Distribution is DistributionEvents, Auth {
    address public distributor;

    function setDistributor(address distributor_) public auth {
        require(isContract(distributor_), "contract");
        
        distributor = distributor_;
        emit Distributor(distributor_);
    }

    function isDistributor() public view returns (bool) {
        return msg.sender == distributor;
    }
    
    function isContract(address address_) internal view returns (bool){
      uint32 size;
      assembly { size := extcodesize(address_) }
      return (size > 0);
    }
}


//SourceUnit: ITRC20.sol

/// TRC20.sol -- API for the TRC20 token standard

// See <https://github.com/tronprotocol/tips/blob/master/tip-20.md>.

// This file likely does not meet the threshold of originality
// required for copyright to apply.  As a result, this is free and
// unencumbered software belonging to the public domain.

pragma solidity ^0.5.8;

contract TRC20Events {
    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);
}

contract ITRC20 is TRC20Events {
    function totalSupply() public view returns (uint);
    function balanceOf(address guy) public view returns (uint);
    function allowance(address src, address guy) public view returns (uint);

    function approve(address guy, uint wad) public returns (bool);
    function transfer(address dst, uint wad) public returns (bool);
    function transferFrom(address src, address dst, uint wad) public returns (bool);
}


//SourceUnit: SafeMath.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.5.8;

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
     *
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
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
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

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
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
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
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
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

//SourceUnit: SyntheticTRX.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.5.8;

import "./SyntheticTRXBase.sol";

contract SyntheticTRX is SyntheticTRXBase {
    uint256 public decimals;
    
    bool public mintable;
    bool public burnable;

    constructor(uint256 decimals_)
        SyntheticTRXBase(uint(1).mul(10 ** decimals_)) public {
            
        decimals = decimals_;
    }
    
    function setMintable(bool value) public auth {
        mintable = value;
    }
    
    function setBurnable(bool value) public auth {
        burnable = value;
    }
    
    function mint() public payable returns (bool) {
        require(mintable, "mintable");
        return super.mint();
    }
    
    function burn(uint amount) public returns (bool) {
        require(burnable, "burnable");
        return super.burn(amount);
    }

    function approve(address guy) public returns (bool) {
        return super.approve(guy, uint(-1));
    }

    function approve(address guy, uint wad) public returns (bool) {
        return super.approve(guy, wad);
    }

    function transferFrom(address src, address dst, uint wad) public returns (bool) {
        return super.transferFrom(src, dst, wad);
    }

    function push(address dst, uint wad) public {
        transferFrom(msg.sender, dst, wad);
    }

    function pull(address src, uint wad) public {
        transferFrom(src, msg.sender, wad);
    }

    function move(address src, address dst, uint wad) public {
        transferFrom(src, dst, wad);
    }

    function refund(address token_, uint256 amount_) public auth returns (bool) {
        ITRC20 token = ITRC20(token_);
        require(token.approve(msg.sender, amount_), "approve");
        require(token.transfer(msg.sender, amount_), "transfer");
        return true;
    }

    // Optional token name
    string public name = "";

    function setName(string memory name_) public auth {
        name = name_;
    }

    // Optional symbol name
    string public symbol = "";

    function setSymbol(string memory symbol_) public auth {
        symbol = symbol_;
    }
}


//SourceUnit: SyntheticTRXBase.sol

/// TRC20TokenBase.sol -- basic ERC20 implementation

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity ^0.5.8;

import "./ITRC20.sol";
import "./SafeMath.sol";
import "./Distribution.sol";

contract SyntheticTRXBase is ITRC20, Distribution {
    using SafeMath for uint256;

    uint256 _supply;
    mapping(address => uint256) _balances;
    mapping(address => mapping(address => uint256)) _approvals;
    
    constructor(uint256 supply) public {
		_supply = supply;
		_balances[address(this)] = supply;
    }

    function totalSupply() public view returns (uint) {
        return _supply;
    }

    function balanceOf(address src) public view returns (uint) {
        return _balances[src];
    }

    function allowance(address src, address guy) public view returns (uint) {
        return _approvals[src][guy];
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad) public returns (bool) {
        require(src != dst, "self");
        
        if (src != msg.sender && _approvals[src][msg.sender] != uint(-1)) {
            _approvals[src][msg.sender] = _approvals[src][msg.sender].sub(wad);
        }

        _balances[src] = _balances[src].sub(wad);
        _balances[dst] = _balances[dst].add(wad);

        emit Transfer(src, dst, wad);
        return true;
    }

    function approve(address guy, uint wad) public returns (bool) {
        _approvals[msg.sender][guy] = wad;

        emit Approval(msg.sender, guy, wad);
        return true;
    }

    function mint() public payable returns (bool) {
        require(msg.value > 0, "positive");
        
        _balances[msg.sender] = _balances[msg.sender].add(msg.value);
        _supply = _supply.add(msg.value);

        return true;
    }

    function burn(uint amount) public returns (bool) {
        require(amount > 0, "positive");
        
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        _supply = _supply.sub(amount);
        msg.sender.transfer(amount);

        return true;
    }
}