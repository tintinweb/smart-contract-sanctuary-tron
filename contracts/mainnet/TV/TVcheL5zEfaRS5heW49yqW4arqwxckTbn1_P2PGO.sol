//SourceUnit: BasicToken.sol

pragma solidity ^0.4.18;

import "./SafeMath.sol";

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    function totalSupply() public constant returns (uint256);

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping(address => uint256) balances;

    /**
     * @dev transfer token for a specified address
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param _owner The address to query the the balance of.
     * @return An uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }
}


//SourceUnit: Migrations.sol

pragma solidity ^0.4.4;

/* solhint-disable var-name-mixedcase */

contract Migrations {
    address public owner;
    uint256 public last_completed_migration;

    modifier restricted() {
        if (msg.sender == owner) _;
    }

    function Migrations() public {
        owner = msg.sender;
    }

    function setCompleted(uint256 completed) public restricted {
        last_completed_migration = completed;
    }

    function upgrade(address newAddress) public restricted {
        Migrations upgraded = Migrations(newAddress);
        upgraded.setCompleted(last_completed_migration);
    }
}


//SourceUnit: Ownable.sol

pragma solidity ^0.4.18;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() public {
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
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}


//SourceUnit: P2PGO.sol

pragma solidity ^0.4.18;

import "./StandardTokenWithFees.sol";
import "./Pausable.sol";

contract UpgradedStandardToken is StandardToken {
    // those methods are called by the legacy contract
    // and they must ensure msg.sender to be the contract address
    uint256 public _totalSupply;

    function transferByLegacy(
        address from,
        address to,
        uint256 value
    ) public returns (bool);

    function transferFromByLegacy(
        address sender,
        address from,
        address spender,
        uint256 value
    ) public returns (bool);

    function approveByLegacy(
        address from,
        address spender,
        uint256 value
    ) public returns (bool);

    function increaseApprovalByLegacy(
        address from,
        address spender,
        uint256 addedValue
    ) public returns (bool);

    function decreaseApprovalByLegacy(
        address from,
        address spender,
        uint256 subtractedValue
    ) public returns (bool);
}

contract P2PGO is Pausable, StandardTokenWithFees {
    address public upgradedAddress;
    bool public deprecated;

    //  The contract can be initialized with a number of tokens
    //  All the tokens are deposited to the owner address

    address public BizUtility =
        address(0x417403820798687A68E841F3D868508D897818DC35);
    address public Reserve =
        address(0x411DF889395DA5FB3E1225855BB26541D0069C34E7);
    address public Company =
        address(0x417084FCF7E1BD3903517D868A32F8668391151CC4);
    address public Partnership =
        address(0x41B22C024497B8BFF0609A3AE982C82E1B772DD066);
    address public PrivateSale =
        address(0x415A1529EC556D08D842803196A97F409F0BD9E258);
    address public Advisors =
        address(0x4155727F163A1C244002CD2C8CA298A0DB712C913D);
    address public Bounty =
        address(0x415D40B3172755C6E22CBE6118C1072D90DC86B1AC);

    function P2PGO(
        uint256 _initialSupply,
        string _name,
        string _symbol,
        uint8 _decimals
    ) public {
        _totalSupply = _initialSupply;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        balances[owner] = _initialSupply;

        deprecated = false;

        uint256 timeAdd = 30 days;
        quarterMap[0] = now;
        for (uint256 i = 1; i <= 72; i++) {
            quarterMap[i] = quarterMap[i - 1].add(timeAdd);
        }
        transferAndLock(Advisors, _totalSupply.mul(3).div(100), quarterMap[8]);
        transferAndLock(Reserve, _totalSupply.mul(20).div(100), quarterMap[24]);
        transferAndLock(Company, _totalSupply.mul(20).div(100), quarterMap[36]);
        transferAndLock(Bounty, _totalSupply.mul(2).div(100), quarterMap[8]);
        transfer(PrivateSale, _totalSupply.mul(10).div(100));
    }

    /**
     * @dev function that burns an amount of the token of a given
     * account.
     * @param value The amount that will be burnt.
     */
    function burn(uint256 value) public {
        _burn(msg.sender, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0));
        require(value <= balances[account]);
        _totalSupply = _totalSupply.sub(value);
        balances[account] = balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    // Forward ERC20 methods to upgraded contract if this one is deprecated
    function transfer(address _to, uint256 _value)
        public
        whenNotPaused
        returns (bool)
    {
        uint256 remain = balanceOf(msg.sender).sub(_value);
        require(remain >= getLockedAmount(msg.sender));
        if (deprecated) {
            return
                UpgradedStandardToken(upgradedAddress).transferByLegacy(
                    msg.sender,
                    _to,
                    _value
                );
        } else {
            return super.transfer(_to, _value);
        }
    }

    // Forward ERC20 methods to upgraded contract if this one is deprecated
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public whenNotPaused returns (bool) {
        uint256 remain = balanceOf(_from).sub(_value);
        require(remain >= getLockedAmount(_from));
        if (deprecated) {
            return
                UpgradedStandardToken(upgradedAddress).transferFromByLegacy(
                    msg.sender,
                    _from,
                    _to,
                    _value
                );
        } else {
            return super.transferFrom(_from, _to, _value);
        }
    }

    // Forward ERC20 methods to upgraded contract if this one is deprecated
    function getTime() public constant returns (uint256) {
        return now;
    }

    // Forward ERC20 methods to upgraded contract if this one is deprecated
    function balanceOf(address who) public constant returns (uint256) {
        if (deprecated) {
            return UpgradedStandardToken(upgradedAddress).balanceOf(who);
        } else {
            return super.balanceOf(who);
        }
    }

    // Allow checks of balance at time of deprecation
    function oldBalanceOf(address who) public constant returns (uint256) {
        if (deprecated) {
            return super.balanceOf(who);
        }
    }

    // Forward ERC20 methods to upgraded contract if this one is deprecated
    function approve(address _spender, uint256 _value)
        public
        whenNotPaused
        returns (bool)
    {
        if (deprecated) {
            return
                UpgradedStandardToken(upgradedAddress).approveByLegacy(
                    msg.sender,
                    _spender,
                    _value
                );
        } else {
            return super.approve(_spender, _value);
        }
    }

    function increaseApproval(address _spender, uint256 _addedValue)
        public
        whenNotPaused
        returns (bool)
    {
        if (deprecated) {
            return
                UpgradedStandardToken(upgradedAddress).increaseApprovalByLegacy(
                    msg.sender,
                    _spender,
                    _addedValue
                );
        } else {
            return super.increaseApproval(_spender, _addedValue);
        }
    }

    function decreaseApproval(address _spender, uint256 _subtractedValue)
        public
        whenNotPaused
        returns (bool)
    {
        if (deprecated) {
            return
                UpgradedStandardToken(upgradedAddress).decreaseApprovalByLegacy(
                    msg.sender,
                    _spender,
                    _subtractedValue
                );
        } else {
            return super.decreaseApproval(_spender, _subtractedValue);
        }
    }

    // Forward ERC20 methods to upgraded contract if this one is deprecated
    function allowance(address _owner, address _spender)
        public
        constant
        returns (uint256 remaining)
    {
        if (deprecated) {
            return StandardToken(upgradedAddress).allowance(_owner, _spender);
        } else {
            return super.allowance(_owner, _spender);
        }
    }

    // deprecate current contract in favour of a new one
    function deprecate(address _upgradedAddress) public onlyOwner {
        require(_upgradedAddress != address(0));
        deprecated = true;
        upgradedAddress = _upgradedAddress;
        Deprecate(_upgradedAddress);
    }

    // deprecate current contract if favour of a new one
    function totalSupply() public constant returns (uint256) {
        if (deprecated) {
            return StandardToken(upgradedAddress).totalSupply();
        } else {
            return _totalSupply;
        }
    }

    // Issue a new amount of tokens
    // these tokens are deposited into the owner address
    //
    // @param _amount Number of tokens to be issued
    function issue(uint256 amount) public onlyOwner {
        balances[owner] = balances[owner].add(amount);
        _totalSupply = _totalSupply.add(amount);
        Issue(amount);
        Transfer(address(0), owner, amount);
    }

    // Redeem tokens.
    // These tokens are withdrawn from the owner address
    // if the balance must be enough to cover the redeem
    // or the call will fail.
    // @param _amount Number of tokens to be issued
    function redeem(uint256 amount) public onlyOwner {
        _totalSupply = _totalSupply.sub(amount);
        balances[owner] = balances[owner].sub(amount);
        Redeem(amount);
        Transfer(owner, address(0), amount);
    }

    // Called when new token are issued
    event Issue(uint256 amount);

    // Called when tokens are redeemed
    event Redeem(uint256 amount);

    // Called when contract is deprecated
    event Deprecate(address newAddress);

    event Lock(address indexed receiver, uint256 amount, uint256 releaseDate);
    struct LockItem {
        uint256 releaseDate;
        uint256 amount;
    }
    mapping(address => LockItem[]) public lockList;
    mapping(uint256 => uint256) public quarterMap;

    function isLocked(address lockedAddress)
        public
        view
        returns (bool isLockedAddress)
    {
        if (lockList[lockedAddress].length > 0) {
            return true;
        }
        return false;
    }

    function transferBizUtility(uint256 from, uint256 to) public onlyOwner {
        for (uint256 x = from; x <= to; x++) {
            transferAndLock(
                BizUtility,
                _totalSupply.mul(35).div(100).div(72),
                quarterMap[x]
            );
        }
    }

    function transferPartnership(uint256 from, uint256 to) public onlyOwner {
        for (uint256 z = from; z <= to; z++) {
            transferAndLock(
                Partnership,
                _totalSupply.mul(10).div(100).div(36),
                quarterMap[z]
            );
        }
    }

    function transferAndLock(
        address _receiver,
        uint256 _amount,
        uint256 _releaseDate
    ) public returns (bool success) {
        transfer(_receiver, _amount);
        LockItem memory item =
            LockItem({amount: _amount, releaseDate: _releaseDate});
        lockList[_receiver].push(item);
        Lock(_receiver, _amount, _releaseDate);
        return true;
    }

    function getLockedListSize(address lockedAddress)
        public
        view
        returns (uint256 _lenght)
    {
        return lockList[lockedAddress].length;
    }

    function getLockedAmountAt(address lockedAddress, uint256 index)
        public
        view
        returns (uint256 _amount)
    {
        return lockList[lockedAddress][index].amount;
    }

    function getLockedAmountAtTime(address lockedAddress, uint256 time)
        public
        view
        returns (uint256 _amount)
    {
        uint256 lockedAmount = 0;
        for (uint256 j = 0; j < getLockedListSize(lockedAddress); j++) {
            uint256 _releaseDate = getLockedTimeAt(lockedAddress, j);
            if (time < _releaseDate) {
                uint256 temp = getLockedAmountAt(lockedAddress, j);
                lockedAmount = lockedAmount.add(temp);
            }
        }
        return lockedAmount;
    }

    function getLockedTimeAt(address lockedAddress, uint256 index)
        public
        view
        returns (uint256 _time)
    {
        return lockList[lockedAddress][index].releaseDate;
    }

    function getLockedAmount(address lockedAddress)
        public
        view
        returns (uint256 _amount)
    {
        return getLockedAmountAtTime(lockedAddress, now);
    }
}


//SourceUnit: Pausable.sol

pragma solidity ^0.4.18;

import "./Ownable.sol";

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;

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
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyOwner whenNotPaused {
        paused = true;
        Pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyOwner whenPaused {
        paused = false;
        Unpause();
    }
}


//SourceUnit: SafeMath.sol

pragma solidity ^0.4.18;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


//SourceUnit: StandardToken.sol

pragma solidity ^0.4.18;

import "./BasicToken.sol";

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender)
        public
        view
        returns (uint256);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {
    mapping(address => mapping(address => uint256)) internal allowed;

    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     *
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256)
    {
        return allowed[_owner][_spender];
    }

    /**
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     */
    function increaseApproval(address _spender, uint256 _addedValue)
        public
        returns (bool)
    {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(
            _addedValue
        );
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint256 _subtractedValue)
        public
        returns (bool)
    {
        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
}


//SourceUnit: StandardTokenWithFees.sol

pragma solidity ^0.4.18;

import "./StandardToken.sol";
import "./Ownable.sol";

contract StandardTokenWithFees is StandardToken, Ownable {
    // Additional variables for use if transaction fees ever became necessary
    uint256 public basisPointsRate = 0;
    uint256 public maximumFee = 0;
    uint256 constant MAX_SETTABLE_BASIS_POINTS = 20;
    uint256 constant MAX_SETTABLE_FEE = 50;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public _totalSupply;

    uint256 public constant MAX_UINT = 2**256 - 1;

    function calcFee(uint256 _value) constant returns (uint256) {
        uint256 fee = (_value.mul(basisPointsRate)).div(10000);
        if (fee > maximumFee) {
            fee = maximumFee;
        }
        return fee;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        uint256 fee = calcFee(_value);
        uint256 sendAmount = _value.sub(fee);

        super.transfer(_to, sendAmount);
        if (fee > 0) {
            super.transfer(owner, fee);
        }
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        uint256 fee = calcFee(_value);
        uint256 sendAmount = _value.sub(fee);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(sendAmount);
        if (allowed[_from][msg.sender] < MAX_UINT) {
            allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        }
        Transfer(_from, _to, sendAmount);
        if (fee > 0) {
            balances[owner] = balances[owner].add(fee);
            Transfer(_from, owner, fee);
        }
        return true;
    }

    function setParams(uint256 newBasisPoints, uint256 newMaxFee)
        public
        onlyOwner
    {
        // Ensure transparency by hardcoding limit beyond which fees can never be added
        require(newBasisPoints < MAX_SETTABLE_BASIS_POINTS);
        require(newMaxFee < MAX_SETTABLE_FEE);

        basisPointsRate = newBasisPoints;
        maximumFee = newMaxFee.mul(uint256(10)**decimals);

        Params(basisPointsRate, maximumFee);
    }

    // Called if contract ever adds fees
    event Params(uint256 feeBasisPoints, uint256 maxFee);
}