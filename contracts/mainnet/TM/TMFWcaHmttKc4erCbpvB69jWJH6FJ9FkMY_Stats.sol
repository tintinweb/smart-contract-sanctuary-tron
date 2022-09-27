//SourceUnit: Stats_flattened.sol


// File: localhost/token/ITRC20.sol

pragma solidity ^0.5.4;


/**
 * @title TRC20 interface (compatible with ERC20 interface)
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 */
interface ITRC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// File: localhost/lib/Ownable.sol

pragma solidity ^0.5.4;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address payable private _owner;
    mapping(address => bool) private _owners;
    event OwnershipGiven(address indexed newOwner);
    event OwnershipTaken(address indexed previousOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() public {
        address payable msgSender = msg.sender;
        _addOwnership(msgSender);
        _owner = msgSender;
        emit OwnershipGiven(msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() private view returns (address payable) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner 1");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _owners[msg.sender];
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function addOwnership(address payable newOwner) public onlyOwner {
        _addOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _addOwnership(address payable newOwner) private {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipGiven(newOwner);
        _owners[newOwner] = true;
    }

    function _removeOwnership(address payable __owner) private {
        _owners[__owner] = false;
        emit OwnershipTaken(__owner);
    }

    function removeOwnership(address payable __owner) public onlyOwner {
        _removeOwnership(__owner);
    }
}

// File: localhost/lib/Stats.sol

pragma solidity ^0.5.4;




interface IWINR {
    function stakeOf(address) external view returns (uint256);

    function passiveStakeOf(address) external view returns (uint256);

    function calculateReward(address, uint256) external view returns (uint256);

    function lotteryTicketPrice() external view returns (uint256);

    function getStakeID() external view returns (uint256);

    function stats() external view returns (uint256);

    function lastWeek()
        external
        view
        returns (
            uint256[7] memory,
            uint256[7] memory,
            uint256[7] memory,
            uint256[7] memory,
            uint256[7] memory
        );
}


interface ILottery {
    function getLastDrawTime() external view returns (uint256);
}


contract Stats {
    address routerContract;
    address winrContract;
    address lotteryContract;

    constructor(
        address _router,
        address _winr,
        address _lottery
    ) public {
        routerContract = _router;
        winrContract = _winr;
        lotteryContract = _lottery;
    }

    function getPlayerStats(address payable player)
        public
        view
        returns (
            uint256 winrBalance,
            uint256 activeStakes,
            uint256 passiveStakes,
            uint256 claimable,
            uint256 lotteryTime,
            uint256 lotteryTicketPrice,
            uint256 lotteryTrxBalance
        )
    {
        winrBalance = ITRC20(winrContract).balanceOf(player);
        activeStakes = IWINR(winrContract).stakeOf(player);
        passiveStakes = IWINR(winrContract).passiveStakeOf(player);
        claimable = IWINR(winrContract).calculateReward(player, 0);
        lotteryTime = ILottery(lotteryContract).getLastDrawTime();
        lotteryTicketPrice = IWINR(winrContract).lotteryTicketPrice();
        lotteryTrxBalance = address(lotteryContract).balance;
    }
}