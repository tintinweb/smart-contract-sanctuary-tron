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


//SourceUnit: TeamContract.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.5.10;

import "./ITRC20.sol";

contract TeamContract{
    
    ITRC20 PraxisLands;
    
    struct Wallet{
        
        string name;
        
        address payable Wallet;
        
        uint256 DepositAmount;
        
        uint16 YearCount;
    }
    
    mapping(address=>Wallet)public wallets; // This is the address of the wallets that have access to this contrac.t
    
    
    uint256 public AnnualWithrowAmount = 500000e7; // This is the number that will be deposited each year, 500,000 PXL.
 
    uint256 public StratDate;
    
    address owner; // This is the admin address

    uint16 FreezeYears = 21; // This is the number of years to be deposited, 21 Years.
    
    constructor(address payable _FounderWallet,address payable _TokenTeamWallet,address payable _AdvistorWallet,address payable _MetaTeamWallet) public{
        
        owner = msg.sender;
        
        StratDate = block.timestamp;
     
        wallets[_FounderWallet] = Wallet("Funder",_FounderWallet,0,1); // This is set FounderWallet value. 
        
        wallets[_TokenTeamWallet] = Wallet("TokenTeam",_TokenTeamWallet,0,1);  // This is set TokenTeamWallet value. 
        
        wallets[_AdvistorWallet] = Wallet("Advistor",_AdvistorWallet,0,1);  // This is set AdvistorWallet value. 
        
        wallets[_MetaTeamWallet] = Wallet("MetaTeam",_MetaTeamWallet,0,1); // This is set MetaTeamWallet value. 
        
    }
    
    function setPraxisLandsAddress(address PraxisLandsAddress) public returns (string memory) { // This function is set PraxisLands Contract Address . 
        
        require(msg.sender == owner);
        
        require(address(PraxisLands) == address(0),"Praxis Lands contract address is set");
        
        PraxisLands = ITRC20(PraxisLandsAddress);
        
        return "success";
    }
    
    function withdraw() public  returns (string memory){  // This function is withdraw  . 
        
       require(wallets[msg.sender].YearCount > 0,"You do not have the required access");
       
       require(timecheck(wallets[msg.sender].YearCount,block.timestamp) == true,"Withdrawal is not allowed");
       
       require(wallets[msg.sender].YearCount <= FreezeYears,"You have withdraw all your tokens");
       
       PraxisLands.transfer(msg.sender, AnnualWithrowAmount);
       
       wallets[msg.sender].DepositAmount += AnnualWithrowAmount;
       
       wallets[msg.sender].YearCount ++;
       
       return "success";
        
     
    }
    
    function timecheck(uint16 YearCount , uint256 nowTime) private view returns (bool){
        
       if(nowTime >= StratDate + (365*84600*YearCount)){
           
           return true;
           
       }else{
           
           return false;
           
       }
    }
    
    function getAllFrozenAmount() public view returns(uint256) {
        
        return(PraxisLands.balanceOf(address(this)));
        
    }
        
    function getMyTotalDepositAmount() public view returns(uint256) {
        
        return(wallets[msg.sender].DepositAmount);
        
    }
}