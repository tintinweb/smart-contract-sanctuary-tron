//SourceUnit: DiceRoll.sol

/**
 * Linkedpalm DiceRoll game is fully decentralized, it doesn't rely on external 
 * input for randomness. It uses future block's hash value to generate 
 * random numbers.
 * 
 * The DiceRoll game uses 0.00045x ^ 2 + 1 quadractic equation to generate 
 * multiplier from 2 to 60 and cubic bezier curve with control points of p1(0, 1), 
 * p2(60, 2.5), p3(100, -0.5), and p4(100, 25) to generate multiplier from 61 to 98.
 * 
 * Note: Once you initiate the play, you have less than 12 minutes to 
 * generate random bytes with marked block hash.
 *
 * If your a developer, and you have an idea on how to improve this game 
 * performance and transaction fees, feel free to contact our 
 * development team on developer@linkedpalm.org.
 * 
 * Created Date: 09/11/2022
 * Author: Linkedpalm
 * 
 * SPDX-License-Identifier: GPL-3.0
 */
 
pragma solidity 0.7.6;

interface ILinkedpalmFund {
    function getAvailableFund(address) external view returns (uint256);
    function getFund(address) external;
    function fundLiquidity() external payable;
}

contract DiceRoll {
    uint256 constant MIN_WAGER = 2e7; // 20 TRX
    uint256 constant MAX_WAGER = 1e10; // 10,000 TRX
    uint256 internal pending_profit = 1; // set to 1 instead of 0
    uint256 internal total_unpaid_loan = 1; // set to 1 instead of 0
    address constant linkedpalm_address = address(0x418ab46a6b9b632f387a5e259392a63f5fc49f8806);
    address payable internal deployer_address;
    mapping(address => bytes32) internal betHashes;
    
    constructor() {
        deployer_address = msg.sender;
    }
    
    fallback() external payable {}
    
    receive() external payable {}
    
    // event that will be fired
    event FutureBlockNumberEvent(address indexed user, uint256 block_number);
    event GeneratedRandomBytesEvent(address indexed user, bytes32 random_bytes);
    event AmountWonEvent(address indexed user, uint256 amount);
    event AmountLostEvent(address indexed user, uint256 amount);
    
    // give access to administrator only
    modifier onlyAdmin() {
        require(
            deployer_address == msg.sender, 
            "Access denied."
        );
        _;
    }
    
    /**
     * @dev Calculate the value of the multiplier based on passed in range.
     * @param range Selected range from 2 to 98.
     * 
     * @return uint256
     * 
     */
    function calculateMultiplier(uint256 range, bool roll_under) internal pure returns (uint256) {
        uint256 remaped_range = roll_under ? (100 - range) * 3 : range * 3;
        bytes memory multiplier_table = hex"0000000000000027220027380027580027800027b20027ec00283000287c0028d2002930002998002a08002a82002b04002b90002c24002cc2002d68002e18002ed0002f9200305c00312f00320c0032f20033e00034d80035d80036e20037f400390f003a34003b62003c98003dd8003f200040720041cc00433000449c004612004790004918004aa8004c42004de4004f900051440053020054c8005698005870005a51005c3c005e3000602c006231006440006658006b80006e8c0071bb00750c0078f4007d0c0080d800854d0089f6008ed40093e90099d0009f5d00a5cd00ac8800b39000bae700c35700cb5a00d48d00de2900e92000f3a100ff99010d2d011a49012a4e0139e4014cc0015f39017564018cb601a85e01c73e01e9aa0211e00242a80281b2";
        bytes memory packed_data = abi.encodePacked(
            multiplier_table[remaped_range], 
            multiplier_table[remaped_range + 1], 
            multiplier_table[remaped_range + 2]
        );
        bytes3 multiplier;
        
        assembly {
            multiplier := mload(add(packed_data, 32))
        }
        
        return uint256(uint24(multiplier));
    }
    
    /** 
     * @dev Maximum amount a player can bet based on available liquidity.
     * @return uint256
     */
    function maximumWager() internal view returns (uint256) {
        uint256 max_wager = address(this).balance / 100; // 1% of smartcontract liquidity
        return max_wager < MAX_WAGER ? max_wager : MAX_WAGER;
    }
    
    /** 
     * @dev Calculate the maximum amount a player can bet based on available liquidity.
     * Player can bet up to 10,000 TRX if there is enough liquidity.
     * 
     * @return uint256
     */
    function getMaximumWager() external view returns (uint256) {
        uint256 max_wager = maximumWager();
        
        // check if the maximum amount a player can bet is greater than minimum allowed wager
        if (max_wager < MIN_WAGER) {
            // Linkedpalm smartcontract
            ILinkedpalmFund linkedpalm = ILinkedpalmFund(linkedpalm_address);

            // maximum amount a player can bet if the smartcontract is funded
            max_wager = (address(this).balance + linkedpalm.getAvailableFund(address(this))) / 100; // 1% of smartcontract liquidity
            max_wager = max_wager < MAX_WAGER ? max_wager : MAX_WAGER;
        }
        
        return max_wager;
    }
    
    /**
     * @dev Check if the future block for random number generator has been produced.
     * @return bool
     */
    function blockHashForRNGProduced(uint256 future_block_number) external view returns (bool) {
        return future_block_number < block.number;
    }
    
    /**
     * @dev Initiate the game by placing bet.
     * 
     * @param wager_amount Player's bet amount in TRX.
     * @param range Selected range from 2 to 98.
     * @param roll_under Boolean value to indicate roll over or roll under.
     * 
     */
    function placeBet(
        uint256 wager_amount, 
        uint256 range, 
        bool roll_under
    ) 
        external 
        payable 
    {
        uint256 max_wager = maximumWager(); // maximum amount you can bet
        
        // check if there is enough liquidity to play this game
        if (max_wager < MIN_WAGER) {
            // Linkedpalm smartcontract
            ILinkedpalmFund linkedpalm = ILinkedpalmFund(linkedpalm_address);

            // maximum amount a player can bet if the smartcontract is funded
            max_wager = (address(this).balance + linkedpalm.getAvailableFund(address(this))) / 100; // 1% of smartcontract liquidity
            max_wager = max_wager < MAX_WAGER ? max_wager : MAX_WAGER;

            // check if the requested fund will be enough
            require(max_wager > MIN_WAGER, "Liquidity is too low.");

            // request for fund
            linkedpalm.getFund(address(this));
        }
        
        // check if the entered amount is within the range
        require(
            wager_amount >= MIN_WAGER && wager_amount <= max_wager, 
            "Wager amount not allowed."
        );
        
        // check if player's wager amount is equal to or less than deposited amount
        require(wager_amount <= msg.value, "Insufficient wager deposit.");
        
        // check if the pass in range is within 1 and 99
        require(range > 1 && range < 99, "Entered range is invalid.");
        
        // set the house possible pending profit
        pending_profit += msg.value;
        
        // set the future block use for random number generator (RNG)
        uint256 future_block_number = block.number + 1;
        
        // save the bet hash for future verification
        betHashes[msg.sender] = keccak256(abi.encodePacked(
            wager_amount, 
            range, 
            future_block_number, 
            roll_under
        ));
        
        // return future block number as event
        emit FutureBlockNumberEvent(msg.sender, future_block_number);
    }
    
    /**
     * @dev Roll dice to determine the game outcome.
     * 
     * @param wager_amount Player's bet amount in TRX.
     * @param range Selected range from 2 to 98.
     * @param future_block_number This block number is used for RNG.
     * @param roll_under Boolean value to indicate roll over or roll under.
     */
    function rollDice(
        uint256 wager_amount, 
        uint256 range, 
        uint256 future_block_number, 
        bool roll_under
    ) 
        external 
    {
        bytes32 bet_hash = keccak256(abi.encodePacked(
            wager_amount, 
            range, 
            future_block_number, 
            roll_under
        ));
        
        // validate bet hash
        require(
            bet_hash == betHashes[msg.sender], 
            "Data integrity check failed."
        );
        
        // check if the future block has been produced
        require(
            future_block_number < block.number, 
            "Please wait for future block to be produced."
        );
        
        // check if the future block is within the latest 256 blocks
        require(
            255 > (block.number - future_block_number), 
            "Marked block for RNG has expired."
        );
        
        // multiplier base on Selected range
        uint256 multiplier = calculateMultiplier(range, roll_under);
        
        // random bytes
        bytes32 random_bytes = keccak256(abi.encodePacked(blockhash(future_block_number)));
        
        // calculate roll outcome
        uint256 roll_outcome = uint256(uint16(bytes2(random_bytes))) % 100; // 0 to 100
        
        // player's won amount
        uint256 won_amount;
        
        if ((roll_under && roll_outcome < range) || (!roll_under && roll_outcome > range)) { // player won
            won_amount = (wager_amount * multiplier) / 10000;
            
            // deduct player won amount from house pending profit
            if (pending_profit > wager_amount) {
                pending_profit -= wager_amount;
            } else {
                pending_profit = 1; // set to 1 instead of 0
            }
            
            // reset the bet hash
            betHashes[msg.sender] = 0x1000000000000000000000000000000000000000000000000000000000000000;
            
            (bool success, ) = msg.sender.call{value: won_amount}("");
            require(success, "Payment failed.");
            
            emit AmountWonEvent(msg.sender, won_amount);
            
        } else { // player lost
            emit AmountLostEvent(msg.sender, wager_amount);
        }
        
        // hash value used for RNG
        emit GeneratedRandomBytesEvent(msg.sender, random_bytes);
    }
    
    /**
     * @dev Needed to receive funding.
     */
    function receiveFund() external payable {
        total_unpaid_loan = msg.value;
    }
    
    /**
     * @dev Get the house possible pending profit.
     * @return uint256
     * 
     */
    function getCurrentHousePendingProfit() external view onlyAdmin returns (uint256) {
        return pending_profit;
    }
    
    /**
     * @dev 35% of the profit is added to Linkedpalm stake contract liquidity, 
     * 20% of the profit goes to the deployer of the smartcontract, 
     * and 45% of the profit is added to game liquidity.
     * 
     */
    function fundStakeLiquidity() external {
        require(pending_profit > 1, "No profit yet.");
        
        uint256 total_profit = pending_profit;
        uint256 staking_contract_profit = (total_profit * 35) / 100;
        pending_profit = 1; // reset pending profit
        
        // remove 35% of "pending_profit" from "total_unpaid_loan"
        if (total_unpaid_loan > 1) {
            if (total_unpaid_loan > staking_contract_profit) {
                total_unpaid_loan -= staking_contract_profit;
            } else {
                total_unpaid_loan = 1; // set to 1 instead of 0
            }
        }
        
        // Linkedpalm smartcontract
        ILinkedpalmFund linkedpalm = ILinkedpalmFund(linkedpalm_address);
        
        // 35% of the profit is added to loan contract liquidity
        linkedpalm.fundLiquidity{value: staking_contract_profit}();
        
        // 20% goes to the deployer of the smartcontract
        (bool success, ) = deployer_address.call{value: (total_profit * 20) / 100}("");
        require(success, "Payment failed.");
    }

    /**
     * @dev Repay borrowed loan from staking smartcontract and 
     * destroy the game contract.
     */
    function destroyContract(address payable to) external onlyAdmin {
        // Linkedpalm smartcontract
        ILinkedpalmFund linkedpalm = ILinkedpalmFund(linkedpalm_address);
        
        uint256 total_balance = address(this).balance;
        
        // check if the contract have unpaid loan
        if (total_unpaid_loan > 1) {
            if (total_balance > total_unpaid_loan) {
                // pay all the loan
                linkedpalm.fundLiquidity{value: total_unpaid_loan}();
            } else {
                // pay the loan
                linkedpalm.fundLiquidity{value: total_balance}();
            }
        }

        // forward the remaining balance
        selfdestruct(to);
    }
}