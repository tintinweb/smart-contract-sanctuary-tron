//SourceUnit: StakingPool.sol

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

/// @title SafeMath Library
/// @author OpenZeppelin
/// @notice SafeMath` is generally not needed starting with Solidity 0.8, since the compiler now has built in overflow checking.
/// @dev Wrappers over Solidity's arithmetic operations.
library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
}

/// @title STRX Token Interface
/// @author STRXFinance
/// @dev The TRC20 Interface has been upgraded to include the mintSTRX and burnSTRX capabilities.
interface ISTRX {
    
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function mintSTRX(address to, uint strx) external payable;

    function burnSTRX(address from, uint strx) external;

}

/// @title StakingPool Contract
/// @author STRXFinance
/// @notice resourceManager should be a multisig wallet that users can rely on.
/// @dev Based on backed TRX, the Staking Pool mints/burns STRX and generates revenue for the STRX holders.
contract StakingPool {
    ///@dev Using SafeMath Library on all uint256 types
    using SafeMath for uint256;
    
    ///@dev userPendingClaim represents the total TRX that has been locked for the user.
    mapping(address => uint256) public userPendingClaim;
    ///@dev The timestamp for locked TRX to be unlocked is represented by userUnlockTime.
    mapping(address => uint256) public userUnlockTime;

    ///@dev This represents sum of all TRX that have been locked by users in this contract.
    // This is amount Of trx, which should be available in the contract, so that the user can claim their trx after unlock time, and the contract must not allow this trx to be borrowed by the resourceManager
    uint256 public totalPendingClaim = 0;

    ///@dev This is the amount of time in seconds user must wait before they can claim TRX after making an unstake request.
    uint256 public unstakingPeriod = 3 days;
    
    ///@dev Users will be charged 0.5% fees if they want to claim TRX without going through unstaking process of 3 days
    ///@notice 50 = 0.5%
    uint256 public emergencyFeesNumerator = 50;
    ///@dev This serves as the denominator in the fee % calculation.
    ///@notice 10000 = 100%
    uint256 public emergencyFeesDenominator = 10000;

    ///@dev This tracks the total amount of trx that the resourceManager has borrowed.
    uint256 public trxLentToManager;

    ///@dev A MultiSig EOA called resourceManager borrows TRX from contacts in order to generate revenue for STRX Holders.
    address payable public resourceManager;

    ///@dev The STRX Contract, or STRX, is what will be used to mint and burn STRX.
    ISTRX public immutable STRX;

    ///@dev Only the authorised EOA may borrow TRX from the contract thanks to this modifier, which limits function calls to only resourceManager for the borrowTRX function.
    modifier onlyResourceManager() {
        require(msg.sender == resourceManager, "Unauthorized");
        _;
    }

    ///@dev Staking Pool Contract Creation Using an Immutable STRX Token
    ///@notice In order to prevent this pool's UnderlyingTrx from ever reaching 0, we must first mint 1 STRX and send it to an inaccessible wallet.
    constructor(address STRX_ADDRESS) {
        resourceManager = payable(msg.sender);
        STRX = ISTRX(STRX_ADDRESS);
    }
    
    ///@dev This event gets emitted on every new stake
    event Staked(address user, uint256 trxStaked, uint256 strxMinted);
    ///@dev This event gets emitted when someone unstaked
    event Unstaked(address user, uint256 strxBurned, uint256 trxLocked, uint256 unlocksAfter);
    ///@dev This event gets emitted when someone claims their unstaked trx
    event Claimed(address user, uint256 trxClaimed);
    ///@dev This event gets emitted when someone directly unstakes their strx without going through 3 days waiting period.
    event EmergencyClaimed(address user, uint256 strxBurned, uint256 trxClaimed);
    
    ///@dev This event gets emitted when revenue is generated on energy/bandwidth renting
    event IncomeGenerated(uint256 trxAmount, address from);

    ///@dev This event gets emitted when resourceManager borrows some trx from the contract
    event BorrowedTRX(uint256 trxAmount, address to, string info);
    ///@dev This event gets emitted when resourceManager repays borrowed trx to the contract
    event RepaidTRX(uint256 trxAmount, address from, string info);

    ///@dev This event gets emitted when resourceManager is updated
    event ResourceManagerUpdated(address oldManager, address newManager);

    /**
     * @dev Stakes msg.value TRX and mints STRX for the msg.sender
     *
     * Returns Null
     *
     * Emits a {Staked} event.
     */
    function stake() external payable {
        require(msg.value > 0, "0 TRX");
        uint256 _strx = ( msg.value.mul(STRX.totalSupply()) ).div( reservedTRX().sub(msg.value) );
        emit Staked(msg.sender, msg.value, _strx);
        STRX.mintSTRX(msg.sender, _strx);
    }

    /**
     * @dev Mints strx at the rate of 1:1 when STRX total supply === 0, This is called only for 1 time, after deploying the contract
     *
     * Returns Null
     *
     * Emits a {Staked} event.
     */
    function emInit(address blackHoleAddress) external payable onlyResourceManager() {
        require(msg.value > 0, "0 TRX");
        require(STRX.totalSupply() == 0, "Already Initialized");
        emit Staked(blackHoleAddress, msg.value, msg.value);
        STRX.mintSTRX(blackHoleAddress, msg.value);
    }
    
    /**
     * @dev Checks for pendingClaim for user if any, and claim it for the user, then unstake given strx for TRX, which gets locked as pendingClaim for the user for next 3 days
     *
     * Returns Null
     *
     * Emits {Claimed and/or Unstaked} event.
     */
    function unstake(uint256 strx) external {
        require(strx > 0, "0 strx");
        uint256 newPendingClaim = ( strx.mul(reservedTRX()) ).div( STRX.totalSupply() );
        if ( userPendingClaim[msg.sender] > 0 && block.timestamp >= userUnlockTime[msg.sender] && address(this).balance >= userPendingClaim[msg.sender] ) {
            uint256 oldPendingClaim = userPendingClaim[msg.sender];
            totalPendingClaim = totalPendingClaim.sub(oldPendingClaim).add(newPendingClaim);
            userPendingClaim[msg.sender] = newPendingClaim;
            userUnlockTime[msg.sender] = block.timestamp.add(unstakingPeriod);
            emit Claimed(msg.sender, oldPendingClaim);
            emit Unstaked(msg.sender, strx, newPendingClaim, userUnlockTime[msg.sender]);
            STRX.burnSTRX(msg.sender, strx);
            payable(msg.sender).transfer(oldPendingClaim);
        } else {
            totalPendingClaim = totalPendingClaim.add(newPendingClaim);
            userPendingClaim[msg.sender] = userPendingClaim[msg.sender].add(newPendingClaim);
            userUnlockTime[msg.sender] = block.timestamp.add(unstakingPeriod);
            emit Unstaked(msg.sender, strx, newPendingClaim, userUnlockTime[msg.sender]);
            STRX.burnSTRX(msg.sender, strx);
        }
    }
    
    /**
     * @dev Checks for pending trx for user if any, and claims it for the user
     *
     * Returns Null
     *
     * Emits {Claimed} event.
     */
    function claim() external {
        require(userUnlockTime[msg.sender] <= block.timestamp, "Wait 3 Days");
        require(userPendingClaim[msg.sender] > 0, "0 TRX");
        require(address(this).balance >= userPendingClaim[msg.sender], "Insufficient TRX");
        uint256 trxToSend = userPendingClaim[msg.sender];
        totalPendingClaim = totalPendingClaim.sub(trxToSend);
        userUnlockTime[msg.sender] = 0;
        userPendingClaim[msg.sender] = 0;
        emit Claimed(msg.sender, trxToSend);
        payable(msg.sender).transfer(trxToSend);
    }

    /**
     * @dev This avoids 3 days Unstaking period by paying emergencyFees to the Pool
     *
     * Returns Null
     *
     * Emits an {EmergencyClaimed} event.
     */
    function emergencyClaim(uint256 strx) external {
        uint256 newPendingClaim = strx.mul( reservedTRX() ).mul( emergencyFeesDenominator.sub(emergencyFeesNumerator) ).div( emergencyFeesDenominator ).div( STRX.totalSupply() );
        require(address(this).balance >= newPendingClaim, "Insufficient TRX");
        emit EmergencyClaimed(msg.sender, strx, newPendingClaim);
        STRX.burnSTRX(msg.sender, strx);
        payable(msg.sender).transfer(newPendingClaim);
    }

    /**
    * @dev This allows only resourceManager to update address of resourceManager, This functions is intended to use when switching from SingleSig EOA to MultiSig Address
    *
    * Returns Null
    * 
    * Emits {ResourceManagerUpdated} event.
    */
    function emUpdateResourceManager(address payable newManager) external onlyResourceManager() {
        require(newManager != address(0), "0 Address");
        resourceManager = newManager;
        emit ResourceManagerUpdated(msg.sender, newManager);
    }

    /**
    * @dev This allows only resourceManager to Borrow TRX from the contract, resourceManager can withdraw any amount of trx from the contract as long as it doesnt exceeds totalPendingClaim + address(this).balance...
    *
    * Returns Null
    *
    * Emits a {BorrowedTRX} event.
    */
    function emBorrowTRX(uint256 newPendingClaim, string calldata reason) external onlyResourceManager() {
        trxLentToManager = trxLentToManager.add(newPendingClaim);
        require(address(this).balance.sub(totalPendingClaim) >= newPendingClaim, "Insufficient TRX");
        emit BorrowedTRX(newPendingClaim, resourceManager, reason);
        resourceManager.transfer(newPendingClaim);
    }

    /**
    * @dev This allows anyone to repay TRX borrowed by resourceManager. The amount to repay should be less than or equal to borrowed TRX
    *
    * Returns Null
    *
    * Emits a {RepaidTRX} event.
    */
    function emRepayTRX(string calldata reason) external payable {
        require(msg.value > 0, "0 TRX");
        require(trxLentToManager >= msg.value, "Repay > Borrowed");
        trxLentToManager = trxLentToManager.sub(msg.value);
        emit RepaidTRX(msg.value, msg.sender, reason);
    }

    /**
    * @dev Any TRX sent directly to this contract is considered as income
    *
    * Returns Null
    */
    receive() external payable {
        emit IncomeGenerated(
            msg.value,
            msg.sender
        );
    }
    fallback() external payable {
        emit IncomeGenerated(
            msg.value,
            msg.sender
        );
    }

    /**
    * @dev This is a function to calculate total reserved trx, Formula : (Available TRX Balance + Borrowed TRX - Total Pending Claims)
    *
    * Returns Null
    */
    function reservedTRX() public view returns (uint256 totalTRX) {
        return address(this).balance.add(trxLentToManager).sub(totalPendingClaim);
    }
}