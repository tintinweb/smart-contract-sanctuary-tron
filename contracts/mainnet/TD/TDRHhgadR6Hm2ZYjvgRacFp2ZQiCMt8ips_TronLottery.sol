//SourceUnit: TronGame.sol

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;
interface USDTOKEN {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address _owner, address spender)
        external
        view
        returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
struct RefferalPlayer {
    address code; 
    bool isRefered;
}

struct Game {
    uint256 amount;
    string gameType;
}

contract TronLottery{

	address public tokenAddress=0xa614f803B6FD780986A42c78Ec9c7f77e6DeD13C; //USDT token address
    USDTOKEN public USDT = USDTOKEN(tokenAddress);
    address public owner=0x6201B0172f6A649941F10ef2bE73ee2062c0aFc4; //Enter owner address here
    address public oracle=0xeD70953c2fe49B8211D796F24F153ef37Ea222D4; //Enter oracle address here

    // Winning factors for each game type
    mapping(string => uint256) winningFactors;
    mapping(address => RefferalPlayer) refferals;

    mapping (address => Game) currentGame;
    event newGame(address player,uint256 amount, string gameType);

    constructor() {
        winningFactors['LastTwo'] = 10;
        winningFactors['Big'] = 20;
        winningFactors['Small'] = 30;
        winningFactors['Odd'] = 40;
        winningFactors['Even'] = 50;
    }

    function getWinningFactor(string memory gameType) public view returns (uint256) {
        if (winningFactors[gameType] > 0) {
            return winningFactors[gameType];
        } else {
            revert('unknownGameType');
        }
    }

    function changeWinningFactor(string memory gameType, uint256 newFactor) public {
        require(msg.sender==owner,"Not owner");

        if (winningFactors[gameType] > 0) {
            winningFactors[gameType] = newFactor;   
        } else {
            revert('unknownGameType');
        }
    }

    
    function changeOracle(address newOracle) public{
        require(msg.sender==owner,"Not owner");
        oracle=newOracle;
    }
    function changeOwner(address newOwner) public{
        require(msg.sender==owner,"Not owner");
        owner=newOwner;
    }
    
    function withdrawFunds(uint256 amount) public { //function that only owner can execute to withdraw funds. make sure the amount of funds is specified in SUN unit. 1 USDT=1000000 SUN. So if you want to withdraw 12 usdt you need to type 12000000
        require(msg.sender==owner,"Not owner");
        USDT.transfer(owner,amount);
    }
	
	function getRefferal(address player) public view returns (address) {
        RefferalPlayer memory reffered = refferals[player];
        if(reffered.isRefered) {
            return reffered.code;
        } else {
            revert('NoRefferal');
        }
    }


    function play(uint256 amount, string memory gameType) public{
        USDT.transferFrom(msg.sender,address(this),amount);
        currentGame[msg.sender].amount = amount;
        currentGame[msg.sender].gameType = gameType;

        emit newGame(msg.sender, amount, gameType);
    }
	
	

    function playWithRefferal(uint256 amount, string memory gameType, address reff) public{
		if(!refferals[msg.sender].isRefered) {
            refferals[msg.sender].code = reff;
			refferals[msg.sender].isRefered = true;
		}
        play(amount, gameType);
    }
	
	function changeTocken(address newTocken) public {
		require(msg.sender==owner,"Not owner");
		tokenAddress=newTocken;
		USDT = USDTOKEN(tokenAddress);
	}

    function sendWinnings(address player) public {
        require(msg.sender==oracle);
        
        Game memory game = currentGame[player];
        uint256 winningFactor = getWinningFactor(game.gameType);

        USDT.transfer(player,(game.amount + (winningFactor * (game.amount / 100))));
        currentGame[player].amount = 0;
    }
}