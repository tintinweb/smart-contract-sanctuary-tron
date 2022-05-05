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


//SourceUnit: PXLTokenStake.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.5.10;

import "./ITRC20.sol";

contract PXLTokenStake{
    
      ITRC20 PraxisLands;
      
      uint256 public StratDate;
      
      address owner; // This is the admin address
      
      uint16 public FreezeYears = 12; // This is the number of years to be deposited, 12 Years.
      
      uint16 public CurrentYear = 0;
      
      address WalletManager1;
      
      address WalletManager2;
      
      address payable WithdrawalConfirmationContract;
      
      
      constructor(address _WalletManager1,address _WalletManager2,address payable _WithdrawalConfirmationContract) public{
        
        owner = msg.sender;
        
        StratDate = block.timestamp;
        
        WalletManager1 = _WalletManager1;
        
        WalletManager2 = _WalletManager2;
        
        WithdrawalConfirmationContract = _WithdrawalConfirmationContract;
     
     
    }
    
    function Withdraw() public returns (string memory){
        
         require( msg.sender == WalletManager1 || msg.sender == WalletManager2 || msg.sender == owner , "You do not have the required access" );
         
         require (block.timestamp >= StratDate + (CurrentYear*365*86400),"Withdrawal is not allowed");
         
         require (AmountOfTokensYear(CurrentYear) > 0 ,"The contract is over");
        
         PraxisLands.transfer(WithdrawalConfirmationContract, AmountOfTokensYear(CurrentYear));
         
         CurrentYear ++;
         
         return "success";
    
    }
    
    function setPraxisLandsAddress(address PraxisLandsAddress) public returns (string memory) { // This function is set PraxisLands Contract Address . 
        
        require(msg.sender == owner);
        
        require(address(PraxisLands) == address(0),"Praxis Lands contract address is set");
        
        PraxisLands = ITRC20(PraxisLandsAddress);
        
        return "success";
    }
    
    function AmountOfTokensYear(uint16 _CurrentYear) public pure returns (uint256){
        
        if( _CurrentYear >=0 && _CurrentYear<=3){
            
            return 21000000e7;
           
            
        }else if( _CurrentYear >=4 && _CurrentYear<=7){
            
            return 12600000e7;
           
            
        }else if( _CurrentYear >=8 && _CurrentYear<=11){
            
            return 8400000e7;
            
        }else{
            
           return 0;
        }
    }
      
    
    
}