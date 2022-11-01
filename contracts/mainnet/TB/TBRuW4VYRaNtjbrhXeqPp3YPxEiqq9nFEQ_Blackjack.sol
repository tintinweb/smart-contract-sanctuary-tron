//SourceUnit: Blackjack.sol

/**
 * The Blackjack game is fully decentralized, it doesn't rely on external 
 * input for randomness. It uses future block's hash value to generate 
 * random numbers. Almost all the gameplay logic happened off-chain to 
 * improve perfomance and reduce transaction fees.
 * 
 * Dealer must hit soft 17.
 * Blackjack pays 3 to 2.
 * Player can split up to three times.
 * No insurance.
 * No hit or double down on splitted aces.
 * You can only play with the dealer.
 * 
 * Note: Once you initiate the play, you have less than 12 minutes to 
 * generate random bytes with marked block hash.
 *
 * If your a developer, and you have an idea on how to improve this game 
 * performance and transaction fees, feel free to contact our 
 * development team on developer@linkedpalm.org.
 * 
 * Created Date: 30/06/2022
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

contract Blackjack {
    uint256 constant MIN_WAGER = 5e7; // 50 TRX
    uint256 constant MAX_WAGER = 1e10; // 10,000 TRX
    uint256 internal pending_profit = 1; // set to 1 instead of 0
    uint256 internal total_unpaid_loan = 1; // set to 1 instead of 0
    address constant linkedpalm_address = address(0x418ab46a6b9b632f387a5e259392a63f5fc49f8806);
    address payable internal deployer_address;
    
    // play options
    enum PlayOptions { 
        NONE, 
        HIT, 
        SPLIT, 
        SPLIT_L, 
        SPLIT_R, 
        STAND, 
        DOUBLE_DOWN, 
        DOUBLE_DOWN_ON_SPLIT
    } 
    PlayOptions playOptions;
    
    mapping(address => bytes32) internal playingHandHashes;
    
    constructor() {
        deployer_address = msg.sender;
    }
    
    fallback() external payable {}
    
    receive() external payable {}
    
    // event that will be fired
    event FutureBlockNumberEvent(address indexed user, uint256 block_number);
    event GeneratedRandomBytesEvent(address indexed user, bytes32 random_bytes);
    event AmountWonEvent(address indexed user, uint256 amount);
    
    // give access to administrator only
    modifier onlyAdmin() {
        require(
            deployer_address == msg.sender, 
            "Access denied."
        );
        _;
    }
    
    /**
     * @dev Retrieve a slice of bytes8 from stored bytes32 hash.
     * 
     * @param selected_hand_index Player's playing hand index.
     * @return bytes32
     * 
     */
    function retrievePlayingHandHash(uint256 selected_hand_index) internal view returns (bytes8) {
        require(selected_hand_index < 4, "Invalid selected hand index.");
        return bytes8(playingHandHashes[msg.sender] << 64 * selected_hand_index);
    }
    
    /**
     * @dev Update a slice of bytes8 in the stored bytes32 hash.
     * 
     * @param selected_hand_index Player's playing hand index.
     * @param data New playing hand hash.
     * 
     */
    function updatePlayingHandHash(uint256 selected_hand_index, bytes8 data) internal {
        bytes32 hand_hash = playingHandHashes[msg.sender];
        bytes32 loaded_data;
        bytes memory packed_data;
        
        if (selected_hand_index == 0) {
            packed_data = abi.encodePacked(
                data, 
                bytes8(hand_hash << 64), 
                bytes8(hand_hash << 128), 
                bytes8(hand_hash << 192)
            );
            
            assembly {
                loaded_data := mload(add(packed_data, 32))
            }
            
        } else if (selected_hand_index == 1) {
            packed_data = abi.encodePacked(
                bytes8(hand_hash), 
                data, 
                bytes8(hand_hash << 128), 
                bytes8(hand_hash << 192)
            );
            
            assembly {
                loaded_data := mload(add(packed_data, 32))
            }
            
        } else if (selected_hand_index == 2) {
            packed_data = abi.encodePacked(
                bytes8(hand_hash), 
                bytes8(hand_hash << 64), 
                data, 
                bytes8(hand_hash << 192)
            );
            
            assembly {
                loaded_data := mload(add(packed_data, 32))
            }
            
        } else {
            packed_data = abi.encodePacked(
                bytes8(hand_hash), 
                bytes8(hand_hash << 64), 
                bytes8(hand_hash << 128), 
                data
            );
            
            assembly {
                loaded_data := mload(add(packed_data, 32))
            }
        }
        
        playingHandHashes[msg.sender] = loaded_data;
    }
    
    /**
     * @dev Return an array that contain all the playing hand bytes8 slice.
     * @return bytes8[]
     */
    function getPlayingHandHashes() internal view returns (bytes8[] memory) {
        bytes32 hand_hash = playingHandHashes[msg.sender];
        bytes8[] memory hashes = new bytes8[](4);
        hashes[0] = bytes8(hand_hash);
        hashes[1] = bytes8(hand_hash << 64);
        hashes[2] = bytes8(hand_hash << 128);
        hashes[3] = bytes8(hand_hash << 192);
        
        return hashes;
    }
    
    /**
     * @dev Retrieve current game data hash use as previous data hash.
     * Note that you have to call this function first before calling 
     * other function to avoid data override.
     * 
     * @param selected_hand_index The playing hand.
     * @return bytes8
     * 
     */
    function getCurrentPlayingHandHash(uint256 selected_hand_index) external view returns (bytes8) {
        return retrievePlayingHandHash(selected_hand_index);
    }
    
    /**
     * @dev Retrieve all the current game data hash use as previous data hash.
     * Note that you have to call this function first before calling 
     * other function to avoid data override.
     * 
     * @return (bytes8, bytes8, bytes8, bytes8)
     * 
     */
    function getCurrentPlayingHandHashes() external view returns (bytes8, bytes8, bytes8, bytes8) {
        bytes32 hand_hash = playingHandHashes[msg.sender];
        
        return (
            bytes8(hand_hash), 
            bytes8(hand_hash << 64), 
            bytes8(hand_hash << 128), 
            bytes8(hand_hash << 192)
        );
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
     * @dev Get card face value from index.
     * @param index The index is in the range of 1 to 52.
     * @return (uint256, uint256)
     */
    function getCardFaceValue(uint256 index) internal pure returns (uint256, uint256) {
        uint256 reduced_index;
        
        // remap passed in index
        if (index < 14) {
            reduced_index = index;
            
        } else if (index < 27) {
            reduced_index = index - 13;
            
        } else if (index < 40) {
            reduced_index = index - 26;
            
        } else {
            reduced_index = index - 39;
        }
        
        // return the face value(s)
        if (reduced_index == 1) {
            return (1, 11);
        }
        
        if (reduced_index < 11) {
            return (reduced_index, reduced_index);
        }
        
        return (10, 10);
    }

    /**
     * @dev Calculate the played cards best total sum.
     * 
     * @param cards Array of card.
     * @param total_card Total card in the array.
     * 
     * @return uint256
     */
    function playedCardSum(uint256[] memory cards, uint256 total_card) internal pure returns (uint256) {
        uint256 card_first_face_value;
        uint256 card_second_face_value;
        uint256 card_face_value_sum;
        uint256 counter;

        // calculate cards' second value total sum
        while (counter < total_card) {
            (, card_second_face_value) = getCardFaceValue(cards[counter]);
            card_face_value_sum += card_second_face_value;
            counter += 1;
        }

        // check if the total sum is less than 22
        if (card_face_value_sum < 22) {
            return card_face_value_sum;
        }

        counter = 0; // reset counter

        // check if there is any possible sum less than 22
        while (counter < total_card) {
            (card_first_face_value, card_second_face_value) = getCardFaceValue(cards[counter]);
            card_face_value_sum = (card_face_value_sum - card_second_face_value) + card_first_face_value;

            if (card_face_value_sum < 22) {
                return card_face_value_sum;
            }

            counter += 1;
        }

        return card_face_value_sum;
    }
    
    /**
     * @dev Check if the future block for random number generator has been produced.
     * @return bool
     */
    function blockHashForRNGProduced(uint256 future_block_number) external view returns (bool) {
        return future_block_number < block.number;
    }
    
    /**
     * @dev Initiate the game by placing wager.
     * @param wager_amount Player's bet amount in TRX.
     * 
     */
    function initiatePlay(uint256 wager_amount) 
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
        
        // set the house possible pending profit
        pending_profit += msg.value;
        
        // set the next minimum future block use for random number generator (RNG)
        uint256 future_block_number = block.number + 1;
        
        // Save first playing hand hash and reset other slot
        bytes memory packed_data = abi.encodePacked(
            bytes8(keccak256(abi.encodePacked(
                wager_amount, 
                future_block_number, 
                bytes8(0x00), // default value is 0x00
                uint256(PlayOptions.NONE)
            ))), 
            bytes24(0x00)
        );
        bytes32 loaded_data;
        
        assembly {
            loaded_data := mload(add(packed_data, 32))
        }
        
        playingHandHashes[msg.sender] = loaded_data;
        
        // return future block number as event
        emit FutureBlockNumberEvent(msg.sender, future_block_number);
    }
    
    /**
     * @dev Call this function after the future block has been produced to 
     * generate random bytes. 
     * 
     * @param wager_amount Player's bet amount in TRX.
     * @param future_block_number This block number is used for RNG.
     * @param previous_data_hash Previous playing hand game hash.
     * @param play_option Game play option.
     * @param selected_hand_index The playing hand.
     * 
     */
    function generateRandomBytes
    (
        uint256 wager_amount, 
        uint256 future_block_number, 
        bytes8 previous_data_hash, 
        uint256 play_option, 
        uint256 selected_hand_index
    ) external {
        bytes8 data_hash = bytes8(keccak256(abi.encodePacked(
            wager_amount, 
            future_block_number, 
            previous_data_hash, 
            play_option
        )));
        
        // check the player's data integrity
        require(
            data_hash == retrievePlayingHandHash(selected_hand_index), 
            "Data integrity check failed."
        );
        
        // check if the future block has been produced
        require(
            future_block_number < block.number, 
            "Please wait for future block to be produced."
        );
        
        // random bytes
        bytes32 random_bytes = keccak256(abi.encodePacked(blockhash(future_block_number)));
        
        // check if is a splitted hand
        if (play_option == uint256(PlayOptions.SPLIT)) {
            bytes8[] memory playing_hand_hashes = getPlayingHandHashes();
            
            // store the player's game data hash
            playing_hand_hashes[selected_hand_index] = bytes8(keccak256(abi.encodePacked(
                data_hash, 
                random_bytes, 
                uint256(PlayOptions.SPLIT_L)
            )));
            
            playing_hand_hashes[selected_hand_index + 1] = bytes8(keccak256(abi.encodePacked(
                data_hash, 
                random_bytes, 
                uint256(PlayOptions.SPLIT_R)
            )));
            
            // save the "playing_hand_hashes"
            bytes memory packed_data = abi.encodePacked(
                playing_hand_hashes[0], 
                playing_hand_hashes[1], 
                playing_hand_hashes[2], 
                playing_hand_hashes[3]
            );
            bytes32 loaded_data;
            
            assembly {
                loaded_data := mload(add(packed_data, 32))
            }
            
            playingHandHashes[msg.sender] = loaded_data;
            
        } else {
            // store the player's game data hash
            updatePlayingHandHash(selected_hand_index, bytes8(keccak256(abi.encodePacked(
                data_hash, 
                random_bytes, 
                play_option
            ))));
        }
        
        // return hash value as event
        emit GeneratedRandomBytesEvent(msg.sender, random_bytes);
    }
    
    /**
     * @dev Call this function after the future block has been produced to 
     * generate random bytes for all the playing hand.
     * 
     * @param wager_amount Player's bet amount in TRX.
     * @param future_block_number This block number is used for RNG.
     * @param previous_data_hashes List of previous playing hand game hash.
     * 
     */
    function generateRandomBytesAll(
        uint256 wager_amount, 
        uint256 future_block_number, 
        bytes8[] calldata previous_data_hashes
        
    ) external {
        // check if the future block has been produced
        require(
            future_block_number < block.number, 
            "Please wait for future block to be produced."
        );
        
        bytes32 random_bytes = keccak256(abi.encodePacked(blockhash(future_block_number))); // random bytes
        bytes8[] memory playing_hand_hashes = getPlayingHandHashes();
        bytes8 data_hash;
        uint256 counter;
        
        // iterate through the previous hashes
        while (counter < previous_data_hashes.length) {
            data_hash = bytes8(keccak256(abi.encodePacked(
                wager_amount, 
                future_block_number, 
                previous_data_hashes[counter], 
                uint256(PlayOptions.STAND)
            )));
        
            // check the player's data integrity
            require(
                data_hash == playing_hand_hashes[counter], 
                "Data integrity check failed."
            );
            
            // store the player's game data hash
            playing_hand_hashes[counter] = bytes8(keccak256(abi.encodePacked(
                data_hash, 
                random_bytes, 
                uint256(PlayOptions.STAND)
            )));
            
            counter++; // increment by one
        }
        
        // save the "playing_hand_hashes"
        bytes memory packed_data = abi.encodePacked(
            playing_hand_hashes[0], 
            playing_hand_hashes[1], 
            playing_hand_hashes[2], 
            playing_hand_hashes[3]
        );
        bytes32 loaded_data;
        
        assembly {
            loaded_data := mload(add(packed_data, 32))
        }
        
        playingHandHashes[msg.sender] = loaded_data;
        
        // return hash value as event
        emit GeneratedRandomBytesEvent(msg.sender, random_bytes);
    }
    
    /**
     * @dev Request for an additonal card.
     * 
     * @param wager_amount Player's bet amount in TRX.
     * @param selected_hand_index The hand you want dealer to deal card to.
     * 
     */
    function hit(uint256 wager_amount, uint256 selected_hand_index) external {
        // set the future block use for random number generator (RNG)
        uint256 future_block_number = block.number + 1;
        
        // store the player's game data hash
        updatePlayingHandHash(selected_hand_index, bytes8(keccak256(abi.encodePacked(
            wager_amount, 
            future_block_number, 
            retrievePlayingHandHash(selected_hand_index), 
            uint256(PlayOptions.HIT)
        ))));
        
        // return future block number as event
        emit FutureBlockNumberEvent(msg.sender, future_block_number);
    }
    
    /**
     * @dev Stand on current hand.
     * 
     * @param wager_amount Player's bet amount in TRX.
     * @param selected_hand_index The hand you want dealer to deal card to.
     * 
     */
    function stand(uint256 wager_amount, uint256 selected_hand_index) external {
        // set the future block use for random number generator (RNG)
        uint256 future_block_number = block.number + 1;
        
        // store the player's game data hash
        updatePlayingHandHash(selected_hand_index, bytes8(keccak256(abi.encodePacked(
            wager_amount, 
            future_block_number, 
            retrievePlayingHandHash(selected_hand_index), 
            uint256(PlayOptions.STAND)
        ))));
        
        // return future block number as event
        emit FutureBlockNumberEvent(msg.sender, future_block_number);
    }
    
    /**
     * @dev Request for hand split.
     * 
     * @param wager_amount Player's bet amount in TRX.
     * @param selected_hand_index The hand you want the dealer to split.
     * @param playing_hand_count Number of playing hand on the table.
     * 
     */
    function split(uint256 wager_amount, uint256 selected_hand_index, uint256 playing_hand_count) 
        external 
        payable 
    {
        // check if player's wager amount is equal to or less than deposited amount
        require(wager_amount <= msg.value, "Insufficient wager deposit.");
        
        // set the house possible pending profit
        pending_profit += msg.value;
        
        bytes8[] memory playing_hand_hashes = getPlayingHandHashes();
        
        // check to shift the hash right to create a space next to splitted hand
        if (playing_hand_hashes[selected_hand_index + 1] != bytes8(0x00)) {
            if ((playing_hand_count - selected_hand_index) == 2) {
                playing_hand_hashes[selected_hand_index + 2] = playing_hand_hashes[selected_hand_index + 1];

            } else { // (playing_hand_count - selected_hand_index) == 3
                playing_hand_hashes[3] = playing_hand_hashes[2];
                playing_hand_hashes[2] = playing_hand_hashes[1];
            }
        }
        
        // set the future block use for random number generator (RNG)
        uint256 future_block_number = block.number + 1;
        
        // the first 8 bytes is what is used
        bytes8 data_hash = bytes8(keccak256(abi.encodePacked(
            wager_amount, 
            future_block_number, 
            playing_hand_hashes[selected_hand_index], 
            uint256(PlayOptions.SPLIT)
        )));
        
        // store the player's game data hash
        playing_hand_hashes[selected_hand_index] = data_hash;
        playing_hand_hashes[selected_hand_index + 1] = data_hash;
        
        // save the "playing_hand_hashes"
        bytes memory packed_data = abi.encodePacked(
            playing_hand_hashes[0], 
            playing_hand_hashes[1], 
            playing_hand_hashes[2], 
            playing_hand_hashes[3]
        );
        bytes32 loaded_data;
        
        assembly {
            loaded_data := mload(add(packed_data, 32))
        }
        
        playingHandHashes[msg.sender] = loaded_data;
        
        // return future block number as event
        emit FutureBlockNumberEvent(msg.sender, future_block_number);
    }
    
    /**
     * @dev Double down on current hand.
     * 
     * @param wager_amount Player's bet amount in TRX.
     * @param selected_hand_index The hand you want the dealer to split.
     * 
     */
    function doubleDown(uint256 wager_amount, uint256 selected_hand_index) 
        external 
        payable 
    {
        // check if player's wager amount is equal to or less than deposited amount
        require(wager_amount <= msg.value, "Insufficient wager deposit.");
        
        // set the house possible pending profit
        pending_profit += msg.value;
        
        // set the future block use for random number generator (RNG)
        uint256 future_block_number = block.number + 1;
        
        // store the player's game data hash
        updatePlayingHandHash(selected_hand_index, bytes8(keccak256(abi.encodePacked(
            wager_amount, 
            future_block_number, 
            retrievePlayingHandHash(selected_hand_index), 
            uint256(PlayOptions.DOUBLE_DOWN)
        ))));
        
        // return future block number as event
        emit FutureBlockNumberEvent(msg.sender, future_block_number);
    }
    
    /**
     * @dev Double down on current hand.
     * 
     * @param wager_amount Player's bet amount in TRX.
     * @param selected_hand_index The hand you want the dealer to split.
     * 
     */
    function doubleDownOnSplit(uint256 wager_amount, uint256 selected_hand_index) 
        external 
        payable 
    {
        // check if player's wager amount is equal to or less than deposited amount
        require(wager_amount <= msg.value, "Insufficient wager deposit.");
        
        // set the house possible pending profit
        pending_profit += msg.value;
        
        // set the future block use for random number generator (RNG)
        uint256 future_block_number = block.number + 1;
        
        // store the player's game data hash
        updatePlayingHandHash(selected_hand_index, bytes8(keccak256(abi.encodePacked(
            wager_amount, 
            future_block_number, 
            retrievePlayingHandHash(selected_hand_index), 
            uint256(PlayOptions.DOUBLE_DOWN_ON_SPLIT)
        ))));
        
        // return future block number as event
        emit FutureBlockNumberEvent(msg.sender, future_block_number);
    }
    
    /**
     * @dev Conclude playing hands.
     * 
     * @param wager_amount Player's bet amount in TRX.
     * @param playing_hand_count Number of playing hand on the table.
     * 
     */
    function concludePlayingHands(uint256 wager_amount, uint256 playing_hand_count) external {
        require(
            playing_hand_count > 1 && playing_hand_count < 5, 
            "Playing hand count not acceptable."
        );
        
        uint256 counter;
        bytes8[] memory playing_hand_hashes = getPlayingHandHashes();
        
        // set the future block use for random number generator (RNG)
        uint256 future_block_number = block.number + 1;
        
        while (counter < playing_hand_count) {
            // store the player's game data hash
            playing_hand_hashes[counter] = bytes8(keccak256(abi.encodePacked(
                wager_amount, 
                future_block_number, 
                playing_hand_hashes[counter], 
                uint256(PlayOptions.STAND)
            )));
            
            counter++; // increment by one
        }
        
        // save the "playing_hand_hashes"
        bytes memory packed_data = abi.encodePacked(
            playing_hand_hashes[0], 
            playing_hand_hashes[1], 
            playing_hand_hashes[2], 
            playing_hand_hashes[3]
        );
        bytes32 loaded_data;
        
        assembly {
            loaded_data := mload(add(packed_data, 32))
        }
        
        playingHandHashes[msg.sender] = loaded_data;
        
        // return future block number as event
        emit FutureBlockNumberEvent(msg.sender, future_block_number);
    }
    
    /**
     * @dev Verify player's gameplay and update their balance.
     * 
     * @param gameplay_datas Gameplay data that will be verified.
     * @param selected_hand_index Playing hand that you want to verify the gameplay.
     * 
     */
    function verifyGameplay(uint256[5][] calldata gameplay_datas, uint256 selected_hand_index) external {
        require(gameplay_datas[0][3] == uint256(PlayOptions.NONE), "Gameplay data can not be verified.");
        
        uint256[] memory player_cards = new uint256[](11);
        uint256 player_cards_counter;
        uint256[] memory dealer_cards = new uint256[](11);
        uint256 dealer_cards_counter;
        uint256 dealer_card_sum;
        uint256 win_amount = gameplay_datas[0][0];
        
        { // start of block scope
        
        bytes8 previous_data_hash = bytes8(0x00);
        bytes32 random_bytes;
        uint256 counter;
        
        while (counter < gameplay_datas.length) {
            random_bytes = bytes32(gameplay_datas[counter][2]);
            
            // compute each play hash
            previous_data_hash = bytes8(keccak256(abi.encodePacked(
                bytes8(keccak256(abi.encodePacked(
                    gameplay_datas[counter][0], // wager amount
                    gameplay_datas[counter][1], // block number
                    previous_data_hash,          // previous data hash
                    gameplay_datas[counter][3]  // play option
                ))), 
                random_bytes,                    // random bytes
                gameplay_datas[counter][4]      // play option
            )));
            
            // validate the player's play option
            if (gameplay_datas[counter][3] == uint256(PlayOptions.NONE)) { // start of the game
                uint256 random_byte_index;
                
                // player's first card
                player_cards[player_cards_counter++] = 1 + uint256(uint8(random_bytes[random_byte_index++])) % 52;
                ( ,uint256 card_face_value_1) = getCardFaceValue(player_cards[0]);
                
                // dealer's first card
                dealer_cards[dealer_cards_counter++] = 1 + uint256(uint8(random_bytes[random_byte_index++])) % 52;
                
                // player's second card
                player_cards[player_cards_counter++] = 1 + uint256(uint8(random_bytes[random_byte_index++])) % 52;
                ( ,uint256 card_face_value_2) = getCardFaceValue(player_cards[2]);
                
                // check if is a blackjack
                if ((card_face_value_1 + card_face_value_2) == 21) {
                    // deal cards to dealer until the sum is above 16
                    while (true) {
                        dealer_cards[dealer_cards_counter++] = 1 + uint256(uint8(random_bytes[random_byte_index++])) % 52;
                        
                        // get the cards sum
                        dealer_card_sum = playedCardSum(dealer_cards, dealer_cards_counter);
                        
                        // check if cards sum is above 16
                        if (dealer_card_sum > 16) {
                            break; // exit loop
                        }
                    }
                    
                    break; // exit loop
                }
                
            } else if (gameplay_datas[counter][3] == uint256(PlayOptions.HIT)) {
                random_bytes = bytes32(gameplay_datas[0][2]);
                
                // two dealt cards (at the start of the game)
                (uint256 first_card_value, ) = getCardFaceValue(1 + uint256(uint8(random_bytes[0])) % 52);
                (uint256 second_card_value, ) = getCardFaceValue(1 + uint256(uint8(random_bytes[2])) % 52);
                
                // Check if the player is allowed to hit.
                // Note that your not allowed to hit on splitted aces.
                require(
                    !((first_card_value == second_card_value && first_card_value == 1 && 
                      gameplay_datas[counter - 1][3] == uint256(PlayOptions.SPLIT)) || 
                      gameplay_datas[counter - 1][3] == uint256(PlayOptions.DOUBLE_DOWN_ON_SPLIT)), 
                    "Invalid gameplay."
                );
                
                // add player's card to the list
                random_bytes = bytes32(gameplay_datas[counter][2]);
                player_cards[player_cards_counter++] = 1 + uint256(uint8(random_bytes[0])) % 52;
                
            } else if (gameplay_datas[counter][3] == uint256(PlayOptions.SPLIT)) {
                // check if the wager amount is valid
                require(
                    gameplay_datas[counter][0] == gameplay_datas[0][0], 
                    "Wager amount not acceptable."
                );
                
                uint256 random_byte_index;
                random_bytes = bytes32(gameplay_datas[0][2]);
                
                // check if the first two dealt cards (at the start of the game) are identical
                (uint256 first_card_value, ) = getCardFaceValue(1 + uint256(uint8(random_bytes[0])) % 52); // player's first card
                (uint256 second_card_value, ) = getCardFaceValue(1 + uint256(uint8(random_bytes[2])) % 52); // player's first card
                
                require(first_card_value == second_card_value, "Invalid gameplay.");
                
                // check if you can split, and the previous two card are identical
                if ((counter - 1) > 0) {
                    require(
                        !(gameplay_datas[counter - 1][3] == uint256(PlayOptions.HIT) || 
                        gameplay_datas[counter - 1][3] == uint256(PlayOptions.DOUBLE_DOWN_ON_SPLIT)), 
                        "Invalid gameplay."
                    );
                    
                    random_bytes = bytes32(gameplay_datas[counter - 1][2]);
                    random_byte_index = gameplay_datas[counter - 1][4] == uint256(PlayOptions.SPLIT_L) ? 0 : 1;
                    (uint256 previous_card_value, ) = getCardFaceValue(1 + uint256(uint8(random_bytes[random_byte_index])) % 52);
                    
                    require(previous_card_value == first_card_value, "Invalid gameplay.");
                }
                
                // add card to the list by overriding last added card to the list
                random_bytes = bytes32(gameplay_datas[counter][2]);
                random_byte_index = gameplay_datas[counter][4] == uint256(PlayOptions.SPLIT_L) ? 0 : 1;
                player_cards[player_cards_counter - 1] = 1 + uint256(uint8(random_bytes[random_byte_index])) % 52;
                
            } else if (gameplay_datas[counter][3] == uint256(PlayOptions.DOUBLE_DOWN_ON_SPLIT)) {
                // check if the wager amount is valid
                require(
                    gameplay_datas[counter][0] == gameplay_datas[0][0], 
                    "Wager amount not acceptable."
                );
                
                win_amount = gameplay_datas[0][0] * 2;
                
                // Check if the player is allowed to double down after the first dealt of two card.
                // Note that your not allowed to double down on splitted aces.
                if (counter > 1) {
                    random_bytes = bytes32(gameplay_datas[0][2]);
                    (uint256 first_card_value, ) = getCardFaceValue(1 + uint256(uint8(random_bytes[0])) % 52);
                    
                    require(
                        !(gameplay_datas[counter - 1][3] == uint256(PlayOptions.HIT) || 
                        gameplay_datas[counter - 1][3] == uint256(PlayOptions.DOUBLE_DOWN_ON_SPLIT) || first_card_value == 1),
                        "Invalid gameplay."
                    );
                    
                    // restore the random bytes for double down
                    random_bytes = bytes32(gameplay_datas[counter][2]);
                }
                
                // add card to the list
                player_cards[player_cards_counter++] = 1 + uint256(uint8(random_bytes[0])) % 52;
                
            } else if (gameplay_datas[counter][3] == uint256(PlayOptions.DOUBLE_DOWN)) {
                // check if the wager amount is valid
                require(
                    gameplay_datas[counter][0] == gameplay_datas[0][0], 
                    "Wager amount not acceptable."
                );
                
                win_amount = gameplay_datas[0][0] * 2;
                
                // Check if the player is allowed to double down after the first dealt of two card.
                // Note that your not allowed to double down on splitted aces.
                if (counter > 1) {
                    random_bytes = bytes32(gameplay_datas[0][2]);
                    (uint256 first_card_value, ) = getCardFaceValue(1 + uint256(uint8(random_bytes[0])) % 52);
                    
                    require(
                        !(gameplay_datas[counter - 1][3] == uint256(PlayOptions.HIT) || 
                          gameplay_datas[counter - 1][3] == uint256(PlayOptions.DOUBLE_DOWN_ON_SPLIT) || first_card_value == 1),
                        "Invalid gameplay."
                    );
                    
                    // restore the random bytes for double down
                    random_bytes = bytes32(gameplay_datas[counter][2]);
                }
                
                uint256 random_byte_index;
                
                // add card to the list
                player_cards[player_cards_counter++] = 1 + uint256(uint8(random_bytes[random_byte_index++])) % 52;
                
                // deal cards to dealer until the sum is above 16
                while (true) {
                    dealer_cards[dealer_cards_counter++] = 1 + uint256(uint8(random_bytes[random_byte_index++])) % 52;
                    
                    // get the cards sum
                    dealer_card_sum = playedCardSum(dealer_cards, dealer_cards_counter);
                    
                    // check if cards sum is above 16
                    if (dealer_card_sum > 16) {
                        break; // exit loop
                    }
                }
                
                break; // exit loop
                
            } else if (gameplay_datas[counter][3] == uint256(PlayOptions.STAND)) {
                uint256 random_byte_index;
                
                // deal cards to dealer until the sum is above 16
                while (true) {
                    dealer_cards[dealer_cards_counter++] = 1 + uint256(uint8(random_bytes[random_byte_index++])) % 52;
                    
                    // get the cards sum
                    dealer_card_sum = playedCardSum(dealer_cards, dealer_cards_counter);
                    
                    // check if cards sum is above 16
                    if (dealer_card_sum > 16) {
                        break; // exit loop
                    }
                }
                
                break; // exit loop
            }
            
            counter++; // increment by one
        }
        
        // check if the computed gameplay hash matches the selected hand last saved hash
        require(
            retrievePlayingHandHash(selected_hand_index) == previous_data_hash, 
            "Gameplay data can not be verified."
        );
    
        } // end of block scope
        
        // deduct player won amount from house pending profit
        if (pending_profit > win_amount) {
            pending_profit -= win_amount;
        } else {
            pending_profit = 1; // set to 1 instead of 0
        }
    
        // player's hand possible sum
        uint256 player_card_sum = playedCardSum(player_cards, player_cards_counter);
    
        // check if the player hand have busted
        require(player_card_sum < 22, "You lost the game.");
    
        // check if the player hand is a blackjack
        if (player_cards_counter == 2 && player_card_sum == 21) {
            // Check if the dealer don't have a blackjack too. If dealer does, is a push
            if (!(dealer_cards_counter == 2 && dealer_card_sum == 21)) {
                // Player won. Pay 3 to 2.
                win_amount = win_amount + (win_amount * 3) / 2;
            }
    
        } if (dealer_card_sum > 21 || player_card_sum > dealer_card_sum) { // check if the dealer hand have busted, or you have a better hand than the dealer
            // player won
            win_amount = win_amount * 2;
            
        } else if (player_card_sum == dealer_card_sum) { // check if is a push
            // check if the dealer hand is a blackjack
            if (dealer_cards_counter == 2 && dealer_card_sum == 21) {
                require(false, "You lost the game.");
            }
            
        } else { // dealer hand is better than your hand
            require(false, "You lost the game.");
        }
    
        // reset the hash (by setting it to non zero value so that we don't pay higher fee when initiating a new game)
        updatePlayingHandHash(selected_hand_index, 0x1000000000000000);
        
        (bool success, ) = msg.sender.call{value: win_amount}("");
        require(success, "Payment failed.");
        
        emit AmountWonEvent(msg.sender, win_amount);
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
     * @dev Forward all the balance to the staking smartcontract and 
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