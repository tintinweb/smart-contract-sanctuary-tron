//SourceUnit: Lotto.sol

pragma solidity ^0.5.10;

contract Lotto {
    uint nonce;
    uint lastRand;
    address admin;
    address public smartLotto;
    mapping(uint=>address) public users;
    uint public countUsers;

    uint amount = 15000 * 1e6;

    event UserWonLotteryEvent(address indexed user);

    modifier restricted() {
        require(msg.sender == admin, "restricted");
        _;
    }

    modifier onlySmartLotto() {
        require(smartLotto != address(0), "SmartLotto address is empty");
        require(msg.sender == smartLotto, "Only SmartLotto");
        _;
    }

    constructor() public {
        admin = msg.sender;
    }

    function setSmartLottoAddress(address contractAddress) external restricted {
        smartLotto = contractAddress;
    }

    function getStatus() external view returns(uint) {
        return address(this).balance;
    }

    function getRandom() internal returns(uint) {
        uint rand = uint(keccak256(abi.encodePacked(
            nonce,
            lastRand,
            now,
            block.difficulty,
            msg.sender)
        )) % countUsers;
        nonce++;
        lastRand = rand;
        return rand;
    }

    function addUser(address user) external onlySmartLotto {
        countUsers++;
        users[countUsers] = user;
        applyLottery();
    }

    function addToRaffle() external payable {
        if(countUsers != 0) {
            applyLottery();
        }
    }

    function applyLottery() internal {
        while(address(this).balance >= amount) {
            uint id = getRandom() + 1;
            if(users[id] != address(0)) {
                if(!address(uint160(users[id])).send(amount))
                    address(uint160(users[id])).transfer(amount);
                emit UserWonLotteryEvent(users[id]);
            }
        }
    }
}