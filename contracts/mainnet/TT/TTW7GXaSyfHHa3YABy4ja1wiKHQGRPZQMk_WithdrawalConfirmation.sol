//SourceUnit: ITRC20.sol

pragma solidity ^0.5.10;
// SPDX-License-Identifier: MIT
/**
 * @dev Interface of the TRC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {TRC20Detailed}.
 */
interface ITRC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

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
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


//SourceUnit: WithdrawalConfirmation.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.5.10;

import "./ITRC20.sol";

contract WithdrawalConfirmation{
    
    ITRC20 PraxisLands;
    
    struct Wallet{
        
        uint16 id;
        
        address payable wallet;
        
        uint256 ConfirmAmount;
        
        uint256 ExpirDate;
        
    }
    
    mapping(uint16=>Wallet)public wallets;
    
    uint256 public StratDate;
    
    uint256 ReleaseAmount = 0;
    
    uint16 public VoteCount = 0 ;
    
    address owner; // This is the admin address
    
    address payable MainWallet;
    
    constructor(address payable jadgment1,address payable jadgment2,address payable jadgment3,address payable jadgment4,address payable _MainWallet) public{
        
        owner = msg.sender;
        
        StratDate = block.timestamp;
     
        wallets[1] = Wallet(1,jadgment1,0,StratDate+(365*86400*21)); // This is set jadgment1 value. 
        
        wallets[2] = Wallet(2,jadgment2,0,StratDate+(365*86400*21));  // This is set jadgment2 value. 
        
        wallets[3] = Wallet(3,jadgment3,0,StratDate+(365*86400*21));  // This is set jadgment3 value. 
        
        wallets[4] = Wallet(4,jadgment4,0,StratDate+(365*86400)); // This is set jadgment4 value. 
        
        MainWallet = _MainWallet;
        
    }
    
     function setPraxisLandsAddress(address PraxisLandsAddress) public returns (string memory) { // This function is set PraxisLands Contract Address . 
        
        require(msg.sender == owner);
        
        require(address(PraxisLands) == address(0),"Praxis Lands contract address is set");
        
        PraxisLands = ITRC20(PraxisLandsAddress);
        
        return "success";
    }
    
    function ConfirmAmount(uint256 Amount) public returns (string memory){
        
        for(uint16 i = 1;i<=4;i++){
            
            if(wallets[i].wallet == msg.sender){
                
                 require(wallets[i].ExpirDate >= block.timestamp,"Your wallet address has expired");
                 
                 wallets[i].ConfirmAmount = Amount * 10000000;
        
                 VoteCount ++;
                 
                 return "success";
            }
        }
        
        return "You do not have the required access";
        
        
    }
    
    function Withdraw() public returns (string memory){
        
        require(wallets[1].wallet == msg.sender || wallets[2].wallet == msg.sender || owner == msg.sender , "You do not have the required access" );
        
        if((StratDate +(365*86400)) < block.timestamp ){
            
            require (VoteCount >= 2 , "The number of votes is less than the specified limit");
            
            if( wallets[1].ConfirmAmount > 0  && wallets[1].ConfirmAmount == wallets[2].ConfirmAmount){
                
                ReleaseAmount = wallets[1].ConfirmAmount;
                
            }else if( wallets[1].ConfirmAmount > 0  && wallets[1].ConfirmAmount == wallets[3].ConfirmAmount){
                
                ReleaseAmount = wallets[1].ConfirmAmount;
                
            } else if( wallets[2].ConfirmAmount > 0  && wallets[2].ConfirmAmount == wallets[3].ConfirmAmount){
                
                ReleaseAmount = wallets[2].ConfirmAmount;
                
            } else {
                
                return "The command is not executable";
            }
            
            
        }else{
            
             require (VoteCount >= 3 , "The number of votes is less than the specified limit");
            
            if( wallets[1].ConfirmAmount > 0  && wallets[1].ConfirmAmount == wallets[2].ConfirmAmount){
                
                ReleaseAmount = wallets[1].ConfirmAmount;
                
            }else if( wallets[1].ConfirmAmount > 0  && wallets[1].ConfirmAmount == wallets[3].ConfirmAmount){
                
                ReleaseAmount = wallets[1].ConfirmAmount;
                
            } else if( wallets[1].ConfirmAmount > 0  && wallets[1].ConfirmAmount == wallets[4].ConfirmAmount){
                
                ReleaseAmount = wallets[1].ConfirmAmount;
                
            }else if( wallets[2].ConfirmAmount > 0  && wallets[2].ConfirmAmount == wallets[3].ConfirmAmount){
                
                ReleaseAmount = wallets[2].ConfirmAmount;
                
            }else if( wallets[2].ConfirmAmount > 0  && wallets[2].ConfirmAmount == wallets[4].ConfirmAmount){
                
                ReleaseAmount = wallets[2].ConfirmAmount;
                
            }else if( wallets[3].ConfirmAmount > 0  && wallets[3].ConfirmAmount == wallets[4].ConfirmAmount){
                
                ReleaseAmount = wallets[3].ConfirmAmount;
                
            }
            
            else {
                
                return "The command is not executable";
            }
            
          
        }
        
        require(ReleaseAmount > 0 ,"The requested value must be greater than 0");
                
        PraxisLands.transfer(MainWallet , ReleaseAmount);
                
        wallets[1].ConfirmAmount = 0;
        wallets[2].ConfirmAmount = 0;
        wallets[3].ConfirmAmount = 0;
        wallets[4].ConfirmAmount = 0;
        ReleaseAmount = 0;
        VoteCount = 0;
                
        return "success";
        
    }
    
    
}