//SourceUnit: Opx_Staking.sol

// SPDX-License-Identifier: GPL-3.0
import "Ownable.sol";

pragma solidity >=0.7.0 <0.9.0;

interface TRC20 {
    
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    
    function transfer(address recipient, uint256 amount) external returns (bool);
    function governanceTransfer(address owner, address buyer, uint256 numTokens) external returns (bool);
    
}

contract CLUB {

    struct User {
        address referrer;
        uint256 expiration;
        uint256 cyclecount;
    }

    mapping(address => User) public users;
}

contract OPX_Staking is Ownable {
    address public TOKEN_CONTRACT_ADDRESS;
    address public MAIN_CONTRACT_ADDRESS;
    
    TRC20 internal token20;
    CLUB internal club;
    
    constructor(address _owner, address tokenAddress, address clubAddress) {
        owner = _owner;
        MAIN_CONTRACT_ADDRESS = clubAddress;
        TOKEN_CONTRACT_ADDRESS = tokenAddress;
        
        token20 = TRC20(TOKEN_CONTRACT_ADDRESS);
        club = CLUB(MAIN_CONTRACT_ADDRESS);
    }

    function setAddress(uint256 n, address addr) public onlyOwner returns (bool) {
        if(n == 1) {
            TOKEN_CONTRACT_ADDRESS = addr;
            token20 = TRC20(TOKEN_CONTRACT_ADDRESS);
        }
        else if(n == 2) {
            MAIN_CONTRACT_ADDRESS = addr;
            club = CLUB(MAIN_CONTRACT_ADDRESS);
        }
        return true;
    }

    uint256 public immatureUnstakeDeduction = 70;
    uint256 public unstakeFee;
    uint256 public claimFee;
    bool public online = true;

    bool public immatureUnstakeEnabled = false;

    struct Package {
        uint256 amount;
        uint256 trxAmount;
        uint16 numDays;
        uint8 growth;

        uint8 tier;
        uint8 minimumCyclecount;

        bool hidden;
        bool nonActiveCanSubscribe;

        uint8[] activePackagesRequired;
    }

    Package[] public packages;

    struct Staker {
        uint64 endDate;
        uint64 lastClaim;
    }

    mapping(address => mapping(uint256 => Staker)) public stakes;

    function isSubscribedToTier(address addr, uint256 tier) internal view returns (bool) {
        uint256 length = packages.length;
        for(uint256 i = 0; i < length; ++i) {
            if(packages[i].tier == tier && stakes[addr][i].endDate > block.timestamp) return true;
        }
        return false;
    }

    function getPackage(uint256 index) external view returns(uint8[] memory, uint64, uint64) {
        return (packages[index].activePackagesRequired, stakes[msg.sender][index].endDate, stakes[msg.sender][index].lastClaim);
    }

    function makeStake(uint256 index) external payable returns (bool) {
        require(online, "Contract is offline.");

        (, uint256 expiration, uint256 cyclecount) = club.users(msg.sender);
        require(cyclecount > 0, "Only members can stake.");
        
        require(packages.length > index, "Out of bound.");
        Package memory package = packages[index];

        if(!package.nonActiveCanSubscribe) {
            require(expiration > block.timestamp, "Only active members can stake.");
        }

        require(!package.hidden, "Package is already hidden.");
        require(stakes[msg.sender][index].endDate == 0, "Claim the package first before staking again.");

        require(msg.value >= package.trxAmount, "Insufficient amount");

        require(cyclecount >= package.minimumCyclecount, "Minimum cyclecount not met.");

        uint256 length = package.activePackagesRequired.length;
        for(uint256 i = 0; i < length; ++i) {
            require(isSubscribedToTier(msg.sender, package.activePackagesRequired[i]), "Requirements not met.");
        }

        token20.governanceTransfer(msg.sender, address(this), package.amount);

        uint256 maturityDate = block.timestamp + (package.numDays * 1 days);
        stakes[msg.sender][index].endDate = uint64(maturityDate);

        emit Staked(msg.sender, index, maturityDate);

        return true;
    }

    function claim(uint256 index) public payable returns (bool) {
        require(msg.value >= claimFee, "Insufficient unstake fee.");
        require(packages.length > index, "Out of bound.");
        Package memory package = packages[index];

        require(stakes[msg.sender][index].endDate != 0, "You haven't bought this package yet.");
        require(block.timestamp < stakes[msg.sender][index].endDate, "Unstake the package.");

        uint256 duration = package.numDays * 1 days;

        uint256 startDate = stakes[msg.sender][index].endDate - duration;

        uint256 lastClaimTime = startDate > stakes[msg.sender][index].lastClaim ? startDate : stakes[msg.sender][index].lastClaim;

        require(block.timestamp - lastClaimTime > 1 days, "You can only claim daily.");

        token20.transfer(msg.sender, package.amount * package.growth / 100 * (block.timestamp - lastClaimTime) / duration);

        stakes[msg.sender][index].lastClaim = uint64(block.timestamp);
        emit Claim(msg.sender, index);
        return true;
    }

    function unstake(uint256 index) public payable returns (bool) {
        require(packages.length > index, "Out of bound.");
        Package memory package = packages[index];

        require(stakes[msg.sender][index].endDate != 0, "You haven't bought this package yet.");
        require(msg.value >= unstakeFee, "Insufficient unstake fee.");

        require(stakes[msg.sender][index].endDate < block.timestamp, "You can't unstake yet.");

        uint256 duration = package.numDays * 1 days;

        uint256 startDate = stakes[msg.sender][index].endDate - duration;

        uint256 lastClaimTime = startDate > stakes[msg.sender][index].lastClaim ? startDate : stakes[msg.sender][index].lastClaim;

        uint256 time = block.timestamp > stakes[msg.sender][index].endDate ? stakes[msg.sender][index].endDate : block.timestamp;

        payable(msg.sender).transfer(package.trxAmount);
        token20.transfer(msg.sender, package.amount + (package.amount * package.growth / 100 * (time - lastClaimTime) / duration));

        stakes[msg.sender][index].endDate = 0;

        emit Unstaked(msg.sender, index);

        return true;
    }

    function immatureUnstake(uint256 index) external payable returns (bool) {
        if(stakes[msg.sender][index].endDate < block.timestamp) {
            return unstake(index);
        }

        require(packages.length > index, "Out of bound.");
        Package memory package = packages[index];

        require(stakes[msg.sender][index].endDate != 0, "You haven't bought this package yet.");
        require(msg.value >= unstakeFee, "Insufficient unstake fee.");

        uint256 duration = package.numDays * 1 days;

        uint256 startDate = stakes[msg.sender][index].endDate - duration;

        uint256 lastClaimTime = startDate > stakes[msg.sender][index].lastClaim ? startDate : stakes[msg.sender][index].lastClaim;

        uint256 time = block.timestamp > stakes[msg.sender][index].endDate ? stakes[msg.sender][index].endDate : block.timestamp;

        uint256 trxAmount = package.trxAmount * immatureUnstakeDeduction / 100;
        uint256 amount = package.amount * immatureUnstakeDeduction / 100;

        payable(msg.sender).transfer(trxAmount);
        token20.transfer(msg.sender, amount + (package.amount * package.growth / 100 * (time - lastClaimTime) / duration));

        stakes[msg.sender][index].endDate = 0;

        emit Unstaked(msg.sender, index);

        return true;
    }

    event Staked(address indexed staker, uint256 indexed id, uint256 maturityDate);
    event Unstaked(address indexed staker, uint256 indexed id);
    event Claim(address indexed staker, uint256 indexed id);

    // Operators

    function addPackage(uint256 amount, uint256 trxAmount, uint8 growth, uint16 numDays, uint8 tier, uint8 minimumCyclecount, uint8[] memory activePackagesRequired, bool nonActiveCanSubscribe) public onlyGovernors returns (bool) {
        packages.push(Package(amount, trxAmount, numDays, growth, tier, minimumCyclecount, false, nonActiveCanSubscribe, activePackagesRequired));
        return true;
    }

    function tweakPackage(uint256 packageID, uint256 index, uint256 newValue) public onlyGovernors {
        if(index == 1) {
            packages[packageID].amount = newValue;
        } else if(index == 2) {
            packages[packageID].trxAmount = newValue;
        } else if(index == 3) {
            packages[packageID].growth = uint8(newValue);
        } else if(index == 4) {
            packages[packageID].numDays = uint16(newValue);
        } else if(index == 5) {
            packages[packageID].tier = uint8(newValue);
        } else if(index == 6) {
            packages[packageID].minimumCyclecount = uint8(newValue);
        } else if(index == 7) {
            packages[packageID].hidden = newValue == 1;
        } else if(index ==8) {
            packages[packageID].nonActiveCanSubscribe = newValue == 1;
        }
    }

    function tweakPackageMultiple(uint256 packageID, uint256[] memory indexes, uint256[] memory values) public onlyGovernors returns(bool) {
        uint256 length = indexes.length;
        uint256 index;
        for(uint256 i = 0; i < length; ++i) {
            index = indexes[i];
            if(index == 1) {
                packages[packageID].amount = values[i];
            } else if(index == 2) {
                packages[packageID].trxAmount = values[i];
            } else if(index == 3) {
                packages[packageID].growth = uint8(values[i]);
            } else if(index == 4) {
                packages[packageID].numDays = uint16(values[i]);
            } else if(index == 5) {
                packages[packageID].tier = uint8(values[i]);
            } else if(index == 6) {
                packages[packageID].minimumCyclecount = uint8(values[i]);
            } else if(index == 7) {
                packages[packageID].hidden = values[i] == 1;
            } else if(index ==8) {
                packages[packageID].nonActiveCanSubscribe = values[i] == 1;
            }
        }
        return true;
    }

    function tweakActivePackagesRequired(uint256 packageID, uint8[] memory activePackagesRequired) public onlyGovernors returns(bool) {
        packages[packageID].activePackagesRequired = activePackagesRequired;
        return true;
    }

    function setOnline(bool value) public onlyGovernors returns(bool) {
        online = value;
        return true;
    }

    function tweakSettings(uint256 index, uint256 value) public onlyGovernors {
        if(index == 1) {
            immatureUnstakeDeduction = value;
        } else if(index == 2) {
            unstakeFee = value;
        } else if(index == 3) {
            immatureUnstakeEnabled = value == 1;
        } else if(index == 4) {
            claimFee = value;
        }
    }

    function withdrawToken(uint256 amount) external onlyOwner returns (bool) {
        token20.transfer(msg.sender, amount);
        return true;
    }

    function withdrawTrx(uint256 amount) external onlyOwner returns (bool) {
        payable(owner).transfer(amount);
        return true;
    }
}

//SourceUnit: Ownable.sol

// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;
  mapping(address => bool) public isGovernor;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  
  modifier onlyGovernors() {
      require(isGovernor[msg.sender] == true || msg.sender == owner);
      _;
  }
  
  function giveGovernance(address governor) public onlyOwner {
      isGovernor[governor] = true;
  }
  
  function revokeGovernance(address governor) public onlyOwner {
      isGovernor[governor] = false;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}