//SourceUnit: DRG.sol

pragma solidity ^0.4.25;

contract DIZ {
    address support = msg.sender;
    address private lastSender;
    address private lastOrigin;
    uint public totalFrozen;
    uint public tokenId = 1001854;
    
    uint public prizeFund;
    bool public prizeReceived;
    address public lastInvestor;
    uint public lastInvestedAt;
    
    uint public totalInvestors;
    uint public totalInvested;
    
    // records registrations
    mapping (address => bool) public registered;
    // records amounts invested
    mapping (address => mapping (uint => uint)) public invested;
    // records blocks at which investments were made
    mapping (address => uint) public atBlock;
    // records referrers
    mapping (address => address) public referrers;
    // records objects
    mapping (address => mapping (uint => uint)) public objects;
    // frozen tokens
    mapping (address => uint) public frozen;
    // upgrades
    mapping (address => uint) public upgrades;

    event Registered(address user);
 
    modifier notContract() {
        lastSender = msg.sender;
        lastOrigin = tx.origin;
        require(lastSender == lastOrigin);
        _;
    }
    
    modifier onlyOwner() {
        require(msg.sender == support);
        _;
    }

    function _register(address referrerAddress) internal {
        if (!registered[msg.sender]) {   
            if (registered[referrerAddress] && referrerAddress != msg.sender) {
                referrers[msg.sender] = referrerAddress;
            }

            totalInvestors++;
            registered[msg.sender] = true;

            emit Registered(msg.sender);
        }
    }

    function buy(address referrerAddress) external payable {
        require(block.number >= 19609792);
        require(msg.value == 50 || msg.value == 100 || msg.value == 200 || msg.value == 500
            || msg.value == 1000 || msg.value == 5000 || msg.value == 10000 || msg.value == 100000);
        
        objects[msg.sender][msg.value]++;
        prizeFund += msg.value / 25;
        support.transfer(msg.value * 3 / 25);
        
        _register(referrerAddress);
        
        if (referrers[msg.sender] != 0x0) {
            referrers[msg.sender].transfer(msg.value / 20);
        }
        
        lastInvestor = msg.sender;
        lastInvestedAt = block.number;

        getAllProfit();
        
        invested[msg.sender][msg.value] += msg.value;
        totalInvested += msg.value;

        msg.sender.transferToken(msg.value * 100, tokenId);

        prizeReceived = false;
    }

    function getProfitFrom(address user, uint price, uint percentage) internal view returns (uint) {
        return invested[user][price] * (percentage + upgrades[user]) / 100 * (block.number - atBlock[user]) / 432000;
    }

    function getAllProfitAmount(address user) public view returns (uint) {
        return
            getProfitFrom(user, 50, 95) +
            getProfitFrom(user, 100, 96) +
            getProfitFrom(user, 200, 97) +
            getProfitFrom(user, 500, 98) +
            getProfitFrom(user, 1000, 99) +
            getProfitFrom(user, 5000, 100) +
            getProfitFrom(user, 10000, 101) +
            getProfitFrom(user, 100000, 102);
    }

    function getAllProfit() internal {
        if (atBlock[msg.sender] > 0) {
            uint max = (address(this).balance - prizeFund) * 9 / 10;
            uint amount = getAllProfitAmount(msg.sender);
            
            if (amount > max) {
                amount = max;
            }

            if (amount > 0) {
                msg.sender.transfer(amount);
            }
        }

        atBlock[msg.sender] = block.number;
    }

    function getProfit() external {
        getAllProfit();
    }

    function allowGetPrizeFund(address user) public view returns (bool) {
        return !prizeReceived && lastInvestor == user && block.number >= lastInvestedAt + 2400 && prizeFund >= 20;
    }

    function getPrizeFund() external {
        require(allowGetPrizeFund(msg.sender));
        uint amount = prizeFund / 2;
        msg.sender.transfer(amount);
        prizeFund -= amount;
        prizeReceived = true;
    }

    function register(address referrerAddress) external notContract {
        _register(referrerAddress);
    }

    function freeze(address referrerAddress) external payable {
        require(msg.tokenid == tokenId);
        require(msg.tokenvalue > 0);

        _register(referrerAddress);

        frozen[msg.sender] += msg.tokenvalue;
        totalFrozen += msg.tokenvalue;
    }

    function unfreeze() external {
        totalFrozen -= frozen[msg.sender];
        msg.sender.transferToken(frozen[msg.sender], tokenId);
        frozen[msg.sender] = 0;
    }

    function upgrade(address referrerAddress) external payable {
        require(msg.tokenid == tokenId);
        require(upgrades[msg.sender] == 0 && msg.tokenvalue == 50000 ||
          upgrades[msg.sender] == 1 && msg.tokenvalue == 100000 ||
          upgrades[msg.sender] == 2 && msg.tokenvalue == 30000 ||
          upgrades[msg.sender] == 3 && msg.tokenvalue == 1000000 ||
          upgrades[msg.sender] == 4 && msg.tokenvalue == 10000000);

        _register(referrerAddress);
        
        getAllProfit();
        
        upgrades[msg.sender]++;
        support.transferToken(msg.tokenvalue, tokenId);
    }
}