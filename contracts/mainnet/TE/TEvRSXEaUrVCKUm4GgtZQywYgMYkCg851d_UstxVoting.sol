//SourceUnit: IERC20.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.3.2 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
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
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


//SourceUnit: IStaking.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.3.2 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IStaking {

    /* ========== VIEWS ========== */

    function totalStaked() external view returns (uint256, uint256, uint256, uint256, uint256);
    function balanceOf(address account) external view returns (uint256, uint256, uint256,uint256, uint256);

	// Events
    event NewEpoch(uint256 epoch, uint256 reward, uint256 rateFree, uint256 rateL1, uint256 rateL2, uint256 rateL3, uint256 rateL4);
    event Staked(address indexed user, uint256 amount, uint256 stakeType);
    event Withdrawn(address indexed user, uint256 amount, uint256 stakeType);
    event RewardPaid(address indexed user, uint256 reward, uint256 stakeType);
    event AdminAdded(address indexed account);
    event AdminRemoved(address indexed account);
}


//SourceUnit: Roles.sol

// Roles.sol
// Based on OpenZeppelin contracts v2.5.1
// SPDX-License-Identifier: MIT
// solhint-disable-next-line
pragma solidity ^0.8.0;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}


//SourceUnit: UstxVoting.sol

// Staking.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IStaking.sol";
import "./IERC20.sol";
import "./Roles.sol";


/// @title Up Stable Token eXperiment Voting contract
/// @author USTX Team
/// @dev This contract implements the voting platform
contract UstxVoting {
	using Roles for Roles.Role;

	/***********************************|
	|        Variables && Events        |
	|__________________________________*/


	//Variables
	bool private _notEntered;			//reentrancyguard state
	Roles.Role private _administrators;
	uint256 private _numAdmins;
	uint256 private _minAdmins;

    IStaking public stakingContract;

    // Info of each proposition.
    struct PropInfo {
        uint256 totalVotes;         // Total votes available, including team
        uint256 teamVotes;          // Team votes
        uint256 quorum;             // Minimum votes to be valid
        uint8 propType;           // Proposition type: 1 (yes/no), 2-5 multiple choice
        uint256 startTime;
        uint256 endTime;
        uint8 teamVoted;
        mapping (uint8 => uint256) castVotes;       // Cast votes for each possible propType
        mapping (address => uint8) hasVoted;       // 0-1 if user has voted
    }
    mapping (uint256 => PropInfo) private _propInfo;           //Proposition information
    uint256 public propIndex;

    uint256 public teamShare;          //percentage of votes assigned to the team
    uint256 private _voteLot;           //number of USTX each vote
    uint256 private _showResultsDuring;     //show voting result during voting session

	// Events
    event AdminAdded(address indexed account);
    event AdminRemoved(address indexed account);
    event PropCreated(uint256 indexed propID, uint8 indexed propType, uint256 indexed startTime, uint256 endTime, uint256 quorum);
    event PropEdited(uint256 indexed propID, uint8 indexed propType, uint256 indexed startTime, uint256 endTime, uint256 quorum);
    event Voted(uint256 indexed propID);

	/**
	* @dev costructor
	*
	*/
    constructor() {
        _notEntered = true;
        _numAdmins=0;
		_addAdmin(msg.sender);		//default admin
		_minAdmins = 2;					//at least 2 admins in charge
        propIndex = 0;
        teamShare = 20;                 //20% of total available votes are team
        _voteLot=1000000000;                  //1 vote every 1000 USTX
        _showResultsDuring=1;           //if 1 it allows seeing the voting results during voting
    }


	/***********************************|
	|        AdminRole                  |
	|__________________________________*/

	modifier onlyAdmin() {
        require(isAdmin(msg.sender), "AdminRole: caller does not have the Admin role");
        _;
    }

    function isAdmin(address account) public view returns (bool) {
        return _administrators.has(account);
    }

    function addAdmin(address account) public onlyAdmin {
        _addAdmin(account);
    }

    function renounceAdmin() public {
        require(_numAdmins>_minAdmins, "There must always be a minimum number of admins in charge");
        _removeAdmin(msg.sender);
    }

    function _addAdmin(address account) internal {
        _administrators.add(account);
        _numAdmins++;
        emit AdminAdded(account);
    }

    function _removeAdmin(address account) internal {
        _administrators.remove(account);
        _numAdmins--;
        emit AdminRemoved(account);
    }

	/***********************************|
	|        ReentrancyGuard            |
	|__________________________________*/

	/**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_notEntered, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _notEntered = false;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _notEntered = true;
    }

    /* ========== VIEWS ========== */

	/**
	* @dev total votes available, non including team votes
	*/
    function totalVotes() public view returns (uint256) {
        uint256 S0;
        uint256 S1;
        uint256 S2;
        uint256 S3;
        uint256 S4;

        (S0, S1, S2, S3, S4) = stakingContract.totalStaked();

        return (S0+S1+S2+S3+S4)/_voteLot;           //team votes are not considered
    }

	/**
	* @dev total votes available, including team votes
	*/
	function teamVotes() public view returns (uint256) {
        return totalVotes()*teamShare/100;
    }

	/**
	* @dev user votes available
	*/
    function userVotes(address user) public view returns (uint256) {
        uint256 S0;
        uint256 S1;
        uint256 S2;
        uint256 S3;
        uint256 S4;

        (S0, S1, S2, S3, S4) = stakingContract.balanceOf(user);

        return (S0+S1+S2+S3+S4)/_voteLot;
    }

	/**
	* @dev returns >0 if user has voted
	*/
    function userVoted(uint256 propID) public view returns (uint256){
        return(_propInfo[propID].hasVoted[msg.sender]);
    }

	/**
	* @dev connected user votes available
	*/
    function myVotes() public view returns (uint256) {
        return userVotes(msg.sender);
    }

   /**
	* @dev Function to get voting status
	* @param propID proposition ID
    * returns status: 0 pending, 1 live, 2 ended, 99 not existant
    * returns total eligible votes
    * returns votes cast so far
    * returns if quorum is reached
	*/
    function getPropStatus(uint256 propID) public view returns (uint256, uint256, uint256, uint256) {
        uint256 status=0;         //waiting start
        uint256 votes;
        uint256 quorum=0;

		if (_propInfo[propID].startTime>0) {
	        if (block.timestamp>_propInfo[propID].startTime) {
	            status=1;             //voting is live
	        }
	        if (block.timestamp>_propInfo[propID].endTime) {
	            status=2;             //voting ended
	        }

	        votes = _propInfo[propID].castVotes[0]+
	            _propInfo[propID].castVotes[1]+
	            _propInfo[propID].castVotes[2]+
	            _propInfo[propID].castVotes[3]+
	            _propInfo[propID].castVotes[4];

	        if (votes > _propInfo[propID].quorum) {
	            quorum = 1;
	        }

	        return (status, _propInfo[propID].totalVotes, votes, quorum);
        } else {
            return (99,0,0,0);
        }
    }

   /**
	* @dev Function to get proposition info
	* @param propID proposition ID
    * returns proposition type
    * returns start time
    * returns end time
    * returns total votes
    * returns quorum value
    * returns team votes
	*/
    function getPropInfo(uint256 propID) public view returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        return (_propInfo[propID].propType,
            _propInfo[propID].startTime,
            _propInfo[propID].endTime,
            _propInfo[propID].totalVotes,
            _propInfo[propID].quorum,
            _propInfo[propID].teamVotes);
    }

   /**
	* @dev Function to get voting status
	* @param propID proposition ID
    * returns votes cast so far for each option
	*/
    function getVoteResult(uint256 propID) public view returns (uint256, uint256, uint256, uint256, uint256) {
        if (block.timestamp>_propInfo[propID].endTime || (_showResultsDuring>0 && _propInfo[propID].hasVoted[msg.sender]>0)) {
            return (_propInfo[propID].castVotes[0],
                _propInfo[propID].castVotes[1],
                _propInfo[propID].castVotes[2],
                _propInfo[propID].castVotes[3],
                _propInfo[propID].castVotes[4]);
        } else {
            return (0,0,0,0,0);
        }
    }

    /* ========== VOTING FUNCTIONS ========== */

    /**
	* @dev Function to vote for yes/no proposition
	* @param propID proposition ID
    * @param yesVotes votes for yes
    * @param noVotes votes for no
	*/
    function voteSimple(uint256 propID, uint256 yesVotes, uint256 noVotes) public nonReentrant {
        require(_propInfo[propID].propType==1,"WRONG PROPOSITION TYPE");
        require((yesVotes==0 && noVotes !=0) || (yesVotes!=0 && noVotes ==0),"INVALID VOTE");
        require(block.timestamp>_propInfo[propID].startTime && block.timestamp<_propInfo[propID].endTime, "VOTING IS CLOSED");
        require(yesVotes+noVotes <= userVotes(msg.sender),"VOTES EXCEED BALANCE");
        require(_propInfo[propID].hasVoted[msg.sender]==0,"USER HAS ALREADY VOTED");

        PropInfo storage info = _propInfo[propID];

        info.castVotes[0] += yesVotes;
        info.castVotes[1] += noVotes;
        info.hasVoted[msg.sender] = 1;

        emit Voted(propID);
    }

    /**
	* @dev Function to vote for yes/no proposition for team
	* @param propID proposition ID
    * @param yesVotes votes for yes
    * @param noVotes votes for no
	*/
    function voteSimpleTeam(uint256 propID, uint256 yesVotes, uint256 noVotes) public onlyAdmin nonReentrant {
        require(_propInfo[propID].propType==1,"WRONG PROPOSITION TYPE");
        require((yesVotes==0 && noVotes !=0) || (yesVotes!=0 && noVotes ==0),"INVALID VOTE");
        require(block.timestamp>_propInfo[propID].startTime && block.timestamp<_propInfo[propID].endTime, "VOTING IS CLOSED");
        require(yesVotes+noVotes <= _propInfo[propID].teamVotes,"VOTES EXCEED BALANCE");
        require(_propInfo[propID].teamVoted==0,"USER HAS ALREADY VOTED");

        PropInfo storage info = _propInfo[propID];

        info.castVotes[0] += yesVotes;
        info.castVotes[1] += noVotes;
        info.teamVoted = 1;

        emit Voted(propID);
    }

    /**
	* @dev Function to vote for multiple options proposition
	* @param propID proposition ID
    * @param opt0 votes for option 0
    * @param opt1 votes for option 1
    * @param opt2 votes for option 2
    * @param opt3 votes for option 3
    * @param opt4 votes for option 4
	*/
    function voteMulti(uint256 propID, uint256 opt0, uint256 opt1, uint256 opt2, uint256 opt3, uint256 opt4) public nonReentrant {
        require(_propInfo[propID].propType>1,"WRONG PROPOSITION TYPE");
        require(opt0>0 || opt1>0 || opt2>0 || opt3>0 || opt4>0,"INVALID VOTE");
        require(block.timestamp>_propInfo[propID].startTime && block.timestamp<_propInfo[propID].endTime, "VOTING IS CLOSED");
        require(opt0+opt1+opt2+opt3+opt4 <= userVotes(msg.sender),"VOTES EXCEED BALANCE");
        require(_propInfo[propID].hasVoted[msg.sender]==0,"USER HAS ALREADY VOTED");

        PropInfo storage info = _propInfo[propID];

        info.castVotes[0] += opt0;
        info.castVotes[1] += opt1;
        info.castVotes[2] += opt2;
        info.castVotes[3] += opt3;
        info.castVotes[4] += opt4;
        info.hasVoted[msg.sender] = 1;

        emit Voted(propID);
    }

    /**
	* @dev Function to vote for multiple options proposition for team
	* @param propID proposition ID
    * @param opt0 votes for option 0
    * @param opt1 votes for option 1
    * @param opt2 votes for option 2
    * @param opt3 votes for option 3
    * @param opt4 votes for option 4
	*/
    function voteMultiTeam(uint256 propID, uint256 opt0, uint256 opt1, uint256 opt2, uint256 opt3, uint256 opt4) public onlyAdmin nonReentrant {
        require(_propInfo[propID].propType>1,"WRONG PROPOSITION TYPE");
        require(opt0>0 || opt1>0 || opt2>0 || opt3>0 || opt4>0,"INVALID VOTE");
        require(block.timestamp>_propInfo[propID].startTime && block.timestamp<_propInfo[propID].endTime, "VOTING IS CLOSED");
        require(opt0+opt1+opt2+opt3+opt4 <= _propInfo[propID].teamVotes,"VOTES EXCEED BALANCE");
        require(_propInfo[propID].teamVoted==0,"USER HAS ALREADY VOTED");

        PropInfo storage info = _propInfo[propID];

        info.castVotes[0] += opt0;
        info.castVotes[1] += opt1;
        info.castVotes[2] += opt2;
        info.castVotes[3] += opt3;
        info.castVotes[4] += opt4;
        info.teamVoted = 1;

        emit Voted(propID);
    }
    /* ========== RESTRICTED FUNCTIONS ========== */

    /**
	* @dev Function to create new proposition
	* @param propType proposition type
    * @param start begin timestamp
    * @param end end timestamp
    * @param qPerc quorum percentage
    * returns propIndex
	*/
    function newProposition(uint8 propType, uint256 start, uint256 end, uint256 qPerc) public onlyAdmin returns (uint256){
        require(propType<6,"WRONG PROPOSITION TYPE");
        require(start>block.timestamp && end>block.timestamp && end>start,"CHECK START AND END TIMES");

        uint256 total = totalVotes();
        uint256 team = total*teamShare/100;
        total += team;       //add team share to total votes;

        PropInfo storage info = _propInfo[propIndex];
        info.totalVotes = total;
        info.teamVotes = team;
        info.quorum = total*qPerc/100;
        info.propType = propType;
        info.startTime = start;
        info.endTime = end;
        info.teamVoted = 0;

        emit PropCreated(propIndex, propType, start, end, qPerc);

        return (propIndex++);
    }

    /**
	* @dev Function to edit proposition
    * @param propID prosition ID to edit
	* @param propType proposition type
    * @param start begin timestamp
    * @param end end timestamp
    * @param qPerc quorum percentage
	*/
    function editProposition(uint256 propID, uint8 propType, uint256 start, uint256 end, uint256 qPerc) public onlyAdmin {
        require(propType<6,"WRONG PROPOSITION TYPE");
        require(start>block.timestamp && end>block.timestamp && end>start,"CHECK START AND END TIMES");
        require(propID<propIndex,"PROPOSITION DOES NOT EXIST");

        PropInfo storage info = _propInfo[propID];
        info.quorum = info.totalVotes*qPerc/100;
        info.propType = propType;
        info.startTime = start;
        info.endTime = end;

        emit PropEdited(propID, propType, start, end, qPerc);
    }

    /**
	* @dev Function to set vote lot size
    * @param newLot new value
    */
    function setVoteLot(uint256 newLot) public onlyAdmin {
        require(newLot>0,"INVALID LOT NUMBER");
        _voteLot = newLot;
    }

    /**
	* @dev Function to enable viewing result during voting
    * @param allowDuring enabled is >0
    */
    function setResultsVisibility(uint256 allowDuring) public onlyAdmin {
        _showResultsDuring = allowDuring;
    }

    function setTeamShare(uint256 share) public onlyAdmin {
        require(share<25,"TEAM SHARE CANNOT BE BIGGER THAN 25%");
        teamShare = share;
    }

	/**
	* @dev Function to set Stake contract address (only admin)
	* @param contractAddress address of the staking contract
	*/
	function setStakingAddr(address contractAddress) public onlyAdmin {
	    require(contractAddress != address(0), "INVALID_ADDRESS");
		stakingContract = IStaking(contractAddress);
	}

    /**
	* @dev Function to withdraw lost tokens balance (only admin)
	* @param tokenAddr Token address
	*/
	function withdrawToken(address tokenAddr) public onlyAdmin returns(uint256) {
	    require(tokenAddr != address(0), "INVALID_ADDRESS");

		IERC20 token = IERC20(tokenAddr);

		uint256 balance = token.balanceOf(address(this));

		token.transfer(msg.sender,balance);

		return balance;
	}

	/**
	* @dev Function to withdraw TRX balance (only admin)
	*/
    function withdrawTrx() public onlyAdmin returns(uint256){
        uint256 balance = address(this).balance;
		address payable rec = payable(msg.sender);
		(bool sent, ) = rec.call{value: balance}("");
		require(sent, "Failed to send TRX");
		return balance;
    }

}