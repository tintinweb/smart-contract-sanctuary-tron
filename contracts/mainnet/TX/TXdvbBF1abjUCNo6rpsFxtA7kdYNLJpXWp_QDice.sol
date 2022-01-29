//SourceUnit: QDice.sol

pragma solidity ^0.4.25;

contract QDice {
    address public owner = msg.sender;
    address private lastSender;
    address private lastOrigin;
    uint public totalFrozen;
    uint public freezePeriod = 28800; // 1 day
    uint public tokenId = 1002721;
    uint public stageSize = 100000000; // QDICE
    uint public tokensPaid;
    uint public initialK = 500;
    uint public totalUsers;
    int public dividends;
    uint public dividendsToPay;

    mapping (address => bool) public registered;
    mapping (address => address) public referrers;
    mapping (address => uint) public frozen;
    mapping (address => uint) public frozenAt;
    
    event Registered(address user);
    event Dice(address indexed from, uint256 bet, uint256 prize, uint256 number, uint256 rollUnder, uint256 tokenReward);
    
    uint private seed;
 
    modifier notContract() {
        lastSender = msg.sender;
        lastOrigin = tx.origin;
        require(lastSender == lastOrigin);
        _;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    // uint256 to bytes32
    function toBytes(uint256 x) internal pure returns (bytes b) {
        b = new bytes(32);
        assembly {
            mstore(add(b, 32), x)
        }
    }
    
    function _register(address referrerAddress) internal {
        if (!registered[msg.sender]) {   
            if (registered[referrerAddress] && referrerAddress != msg.sender) {
                referrers[msg.sender] = referrerAddress;
            }

            totalUsers++;
            registered[msg.sender] = true;

            emit Registered(msg.sender);
        }
    }
    
    // returns a pseudo-random number
    function random(uint lessThan) internal returns (uint) {
        seed += block.timestamp + uint(msg.sender);
        return uint(sha256(toBytes(uint(blockhash(block.number - 1)) + seed))) % lessThan;
    }

    function getMaxBet(uint rollUnder) public view returns (uint) {
        uint udivs = dividends > 0 ? uint(dividends) : 0;
        uint maxBet = (address(this).balance - udivs) * rollUnder / (98 - rollUnder) / 40;
        return maxBet > 100000000000 ? 100000000000 : maxBet;
    }

    function getProfit(uint amount) external onlyOwner {
        uint udivs = dividends > 0 ? uint(dividends) : 0;
        uint max = address(this).balance - udivs;
        owner.transfer(amount < max ? amount : max);
    }

    function withdrawTokens(uint amount) external onlyOwner {
        owner.transferToken(amount, tokenId);
    }
    
    function dice(address referrerAddress, uint rollUnder) external payable notContract {
        require(msg.value >= 15000000 && msg.value <= getMaxBet(rollUnder));
        require(rollUnder >= 4 && rollUnder <= 95);
        
        _register(referrerAddress);
        
        if (referrers[msg.sender] != 0x0) {
            referrers[msg.sender].transfer(msg.value / 5000);
        }

        uint stage = tokensPaid / 1000000 / stageSize;
        uint toPay = msg.value * 100 / (initialK + 50 * stage);
        if (toPay <= address(this).tokenBalance(tokenId)) {
            msg.sender.transferToken(toPay, tokenId);
            tokensPaid += toPay;
        } else {
            toPay = 0;
        }
        
        uint number = random(100);
        if (number < rollUnder) {
            uint prize = msg.value * 98 / rollUnder;
            msg.sender.transfer(prize);
            uint divToSub = (prize - msg.value) / 2;
            dividends -= int(divToSub);
            emit Dice(msg.sender, msg.value, prize, number, rollUnder, toPay);
        } else {
            dividends += int(msg.value) / 2;
            emit Dice(msg.sender, msg.value, 0, number, rollUnder, toPay);
        }
    }

    function clearDividends() external onlyOwner {
        dividendsToPay = dividends > 0 ? uint(dividends) : 0;
        dividends = 0;
        if (dividendsToPay > 0) {
            owner.transfer(dividendsToPay);
        }
    }

    function freeze(address referrerAddress) external payable {
        require(msg.tokenid == tokenId);
        require(msg.tokenvalue > 0);

        _register(referrerAddress);

        frozen[msg.sender] += msg.tokenvalue;
        frozenAt[msg.sender] = block.number;
        totalFrozen += msg.tokenvalue;
    }

    function unfreeze() external {
        require(block.number - frozenAt[msg.sender] >= freezePeriod);
        totalFrozen -= frozen[msg.sender];
        msg.sender.transferToken(frozen[msg.sender], tokenId);
        frozen[msg.sender] = 0;
        delete frozenAt[msg.sender];
    }
}