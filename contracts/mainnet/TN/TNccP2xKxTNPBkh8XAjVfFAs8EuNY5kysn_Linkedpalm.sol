//SourceUnit: Linkedpalm.sol

/**
 * Linkedpalm Smartcontract
 * 
 * Created Date: 22/06/2022
 * Author: Linkedpalm Community
 *
 * SPDX-License-Identifier: UNLICENSED
 */
 
pragma solidity 0.7.6;

interface ILoanLiquidity {
    function receiveFund() external payable;
}

contract Linkedpalm {
    // constants and variables
    uint256 constant STAKE_FEE_PERCENT = 15; // 15%
    uint256 internal current_liquidity; // total TRX available for claiming in this smartcontract
    uint256 internal next_stake_index;
    uint64 internal unresolved_amount;
    uint64 internal resolved_amount;
    uint64 internal unresolved_outstanding_count;
    uint64 internal resolved_outstanding_count;
    uint128 internal total_stake; // total amount of TRX staked in this smartcontract
    uint128 internal total_generated_liquidity; // total amount of liquidity made from users' stakes
    uint64 internal total_investors; // number of investors in this platform
    bool internal locked; // false
    uint8 internal funded_contract_count; // number of smartcontract that are funded
    address payable internal deployer_address;

    struct StakePackage {
        uint64 duration; // stake duration in seconds
        uint64 percent; // stake profit base percent
        uint64 referral_percent; // referral percentage for this package
    }
    
    // stake packages
    mapping(uint256 => StakePackage) internal stakePackages;

    struct UserAccount {
        uint64 current_total_stake; // current amount of TRX staked
        uint64 outstanding_start_index;
        uint64 outstanding_end_bound;
        uint64 referral_bonus; // total amount of TRX earn from referral
        uint48 referral_count; // number of users you referred 
        uint40 referral_insert_index;
        bool is_investor;
        address your_referral; // the address of the user that referred you
    }
    
    // users' account
    mapping(address => UserAccount) internal accounts;

    struct Stake {
        uint256 id;
        uint64 amount; // stake amount
        uint64 profit; // expected profit
        uint64 start_time; // stake time in seconds since the Epoch
        uint64 due_time; // time the stake will due in seconds since the Epoch
    }
    
    // hold users' stake list
    mapping(address => Stake[]) internal userStakes;

    struct StakeOutstanding {
        uint64 outstanding_profit; // profit not yet resolved
        uint64 trail_unresolved_amount;
    }

    // user's stake outstandings
    mapping(address => mapping(uint256 => StakeOutstanding)) internal stakeOutstandings;

    struct Referral {
        uint64 id;
        uint64 amount;
        address user_address;
    }

    // users' referral bonus list
    mapping(address => mapping(uint256 => Referral)) internal userReferrals;

    struct FundContract {
        uint64 loan_amount;
        uint64 total_loan_amount;
        uint64 total_generated_liquidity;
        bool access;
    }

    // contract that has access to loan or funding
    mapping(address => FundContract) internal fundContracts;

    constructor() {
        deployer_address = msg.sender;

        // set stake packages
        stakePackages[0].duration = 864000; // 10 days in seconds
        stakePackages[0].percent = 20; // 20%
        stakePackages[0].referral_percent = 4; // 4% referral bonus
        stakePackages[1].duration = 1728000; // 20 days in seconds
        stakePackages[1].percent = 45; // 45%
        stakePackages[1].referral_percent = 6; // 6% referral bonus
        stakePackages[2].duration = 2592000; // 30 days in seconds
        stakePackages[2].percent = 75; // 75%
        stakePackages[2].referral_percent = 8; // 8% referral bonus
        stakePackages[3].duration = 5184000; // 60 days in seconds
        stakePackages[3].percent = 170; // 170%
        stakePackages[3].referral_percent = 10; // 10% referral bonus
    }
    
    fallback() external payable {
        // donate TRX
        require(msg.value > 0);
        current_liquidity += msg.value;
    }
    
    receive() external payable {
        // donate TRX
        require(msg.value > 0);
        current_liquidity += msg.value;
    }

    // event that will be fired
    event StakeClaimed(address indexed user, uint256 amount);
    event AmountStaked(address indexed user, uint256 stake_id, uint256 package, uint256 level, uint256 amount);
    event ReferralBonusClaimed(address indexed user, uint256 amount);
    event FundedContract(address indexed caller, uint256 amount);
    event LiguidityGenerated(address indexed contract_address, uint256 amount);

    // give access to administrator
    modifier onlyAdmin() {
        require(
            deployer_address == msg.sender, 
            "Access denied."
        );
        _;
    }

    // prevent reentracy call
    modifier preventReentracy() {
        require(!locked, "Function still executing.");
        locked = true;
        _;
        locked = false;
    }

    // check if stake amount and level is valid for the package
    modifier validateStake(uint256 package, uint256 level) {
        UserAccount memory account = accounts[msg.sender];

        // check if package exist
        require(package >= 0 && package < 4, "Package does not exist.");

        // check if level exist
        require(level >= 0 && level < 3, "Level does not exist.");

        // validate user's entered stake
        if (level == 0) {
            require(msg.value >= 1e8 && msg.value <= 15e10, "Stake amount is out of range");
            require((msg.value + account.current_total_stake) <= 15e10, "Allowed maximum stake exceeded.");

        } else if (level == 1) {
            require(account.referral_count > 19, "Level not available");
            require(msg.value >= 2e9 && msg.value <= 35e10, "Stake amount is out of range");
            require((msg.value + account.current_total_stake) <= 35e10, "Allowed maximum stake exceeded.");

        } else {
            require(account.referral_count > 59, "Level not available");
            require(msg.value >= 5e9 && msg.value <= 5e11, "Stake amount is out of range");
            require((msg.value + account.current_total_stake) <= 5e11, "Allowed maximum stake exceeded.");
        }
        _;
    }

    /**
     * @dev Fund that can be requested.
     * @param caller The address of the contract that requested for a fund. 
     */
    function getAvailableFund(address caller) external view returns (uint256) {
        FundContract storage fund_contract = fundContracts[caller];
        uint256 max_loan = 1e11; // 100,000 TRX
        uint256 loan_amount;

        // check if contract has access to loan
        if (!(fund_contract.access && fund_contract.loan_amount == 0)) {
            return 0;
        }

        loan_amount = (current_liquidity * 25) / 100;
        return loan_amount < max_loan ? loan_amount : max_loan;
    }

    /**
     * @dev Fund the eligible smartcontract.
     * @param caller The address of the contract that requested for a fund. 
     */
    function getFund(address caller) external preventReentracy {
        ILoanLiquidity loan_liquidity = ILoanLiquidity(caller);
        FundContract storage fund_contract = fundContracts[caller];
        uint256 max_loan = 1e11; // 100,000 TRX
        uint256 loan_amount;

        // check if loan can be granted
        require(fund_contract.access, "Access denied.");
        require(fund_contract.loan_amount == 0, "You have unresolved loan.");
        require(current_liquidity > 0, "Liquidity is insufficient.");

        // Unresolved loans count can not exceed 4. 
        // Trusted smartcontract can still receive funding.
        require(
            funded_contract_count < 4 || fund_contract.total_loan_amount > 0, 
            "Maximum unresolved loan exceeded."
        );
        
        loan_amount = (current_liquidity * 25) / 100;
        loan_amount = loan_amount < max_loan ? loan_amount : max_loan;
        current_liquidity -= loan_amount;

        // set contract loan amount
        fund_contract.loan_amount = uint64(loan_amount);
        fund_contract.total_loan_amount += uint64(loan_amount);
        funded_contract_count += 1;
        
        // send the fund to the caller
        loan_liquidity.receiveFund{value: loan_amount}();

        emit FundedContract(caller, loan_amount);
    }

    /**
     * @dev Fund the smartcontract liquidity.
     */
    function fundLiquidity() external payable {
        FundContract storage fund_contract = fundContracts[msg.sender];
        uint64 received_amount = uint64(msg.value);

        // resolve funding
        if (fund_contract.loan_amount > received_amount) {
            fund_contract.loan_amount -= received_amount;

        } else if (fund_contract.loan_amount > 0) {
            fund_contract.loan_amount = 0;
            funded_contract_count -= 1;
        }

        fund_contract.total_generated_liquidity += received_amount;

        // check for outstanding or unresolved amount
        if (resolved_amount < unresolved_amount) {
            uint64 remaining_unresolved_amount = unresolved_amount - resolved_amount;

            // check if amount can clear the outstanding
            if (received_amount > remaining_unresolved_amount) {
                resolved_amount = unresolved_amount;
                received_amount -= remaining_unresolved_amount;
                
            } else { // can't clear the outstanding
                resolved_amount += received_amount;
                received_amount = 0;
            }
        }

        // add available amount to liquidity
        if (received_amount > 0) {
            current_liquidity += received_amount;
        }

        emit LiguidityGenerated(msg.sender, msg.value);
    }

    /**
     * @dev Link user to there referral.
     * @param referral The address of the referral. 
     */
    function setUserReferral(address referral) external {
        UserAccount storage account = accounts[msg.sender];
        
        // check if user haven't been referred
        require(account.your_referral == address(0));
        
        // check if user is referring itself
        require(msg.sender != referral);

        // check if a user is trying to refer the person that referred him
        require(msg.sender != accounts[referral].your_referral);
        
        // increment referral counter
        accounts[referral].referral_count += 1;
        
        // link user to their referral
        account.your_referral = referral;
    }

    /**
     * @dev Call this function to stake TRX. 
     * @param package Value range is from 0 to 3.
     * @param level Value range is from 0 to 2
     */
    function stake(uint256 package, uint256 level) external validateStake(package, level) payable {
        UserAccount storage account = accounts[msg.sender];
        StakePackage memory stake_package = stakePackages[package];
        uint256[] memory local_variables = new uint256[](3);
        uint256 stake_id = next_stake_index += 1;

        // calculate user's stake total profit
        local_variables[0] = (msg.value * (uint256(stake_package.percent) + 5 * level)) / 100; // total_profit

        // calculate stake fee
        local_variables[1] = (local_variables[0] * STAKE_FEE_PERCENT) / 100; // stake_fee

        // calculate user referral earn amount
        local_variables[2] = (local_variables[0] * uint256(stake_package.referral_percent)) / 100; // referral_earn_amount

        // remove stake fee from stake amount
        uint256 remaining_stake_amount = msg.value - local_variables[1];

        // stake the amount
        userStakes[msg.sender].push(Stake({
            id: stake_id,
            amount: uint64(msg.value),
            profit: uint64(local_variables[0] - local_variables[1]),
            start_time: uint64(block.timestamp), // current block time in seconds
            due_time: uint64(block.timestamp) + stake_package.duration // current time + stake duration in seconds
        }));

        // check if user have a referral
        if (account.your_referral != address(0)) {
            uint40 insert_index = accounts[account.your_referral].referral_insert_index++;

            // set referral bonus
            userReferrals[account.your_referral][insert_index].id = insert_index;
            userReferrals[account.your_referral][insert_index].amount = uint64(local_variables[2]);
            userReferrals[account.your_referral][insert_index].user_address = msg.sender;
            accounts[account.your_referral].referral_bonus += uint64(local_variables[2]);

            // remove the referral bonus from stake amount
            remaining_stake_amount -= local_variables[2];
        }

        // check for outstanding or unresolved amount
        if (resolved_amount < unresolved_amount) {
            uint64 remaining_unresolved_amount = unresolved_amount - resolved_amount;

            // check if stake amount can clear the outstanding
            if (remaining_stake_amount > remaining_unresolved_amount) {
                resolved_amount = unresolved_amount;
                remaining_stake_amount -= uint256(remaining_unresolved_amount);
                
            } else { // can't clear the outstanding
                resolved_amount += uint64(remaining_stake_amount);
                remaining_stake_amount = 0;
            }
        }

        // update user's current total stake
        account.current_total_stake += uint64(msg.value);

        // update contract information
        total_stake += uint128(msg.value);

        if (!account.is_investor) {
            account.is_investor = true;
            total_investors += 1;
        }

        // add available amount to liquidity
        if (remaining_stake_amount > 0) {
            current_liquidity += remaining_stake_amount;
        }

        // send the stake fee to deployer address
        (bool success, ) = deployer_address.call{value: local_variables[1]}("");
        require(success, "Stake fee transaction failed.");

        emit AmountStaked(msg.sender, stake_id, package, level, msg.value);
    }

    /**
     * @dev Claim user's stake profit and remove the stake from the list.
     * @param stake_id The id of the stake you want to claim.
     */
    function claimStake(uint256 stake_id) external preventReentracy {
        UserAccount storage account = accounts[msg.sender];
        Stake[] storage user_stakes = userStakes[msg.sender];
        Stake memory user_stake;
        uint256 stake_index = 0;
        bool stake_exist = false;
        uint256 claim_amount;
        
        // find the stake user want to claim
        for (; stake_index < user_stakes.length; stake_index++) {
            if (user_stakes[stake_index].id == stake_id) {
                user_stake = user_stakes[stake_index];
                stake_exist = true;
                break; // exit the loop
            }
        }

        // check if user's stake with provided ID exist
        require(stake_exist, "Provided stake ID is invalid.");
        
        // check if it has reached the time to claim profit
        require(block.timestamp > user_stake.due_time, "Stake still running.");

        // set total stake claim amount
        claim_amount = uint256(user_stake.amount + user_stake.profit);

        // update user's current total stake
        account.current_total_stake -= user_stake.amount;

        // remove user's stake from the list
        if (user_stakes.length == 1 || stake_index == user_stakes.length - 1) {
            user_stakes.pop();
            
        } else {
            user_stakes[stake_index] = user_stakes[user_stakes.length - 1];
            user_stakes.pop();
        }

        // check if contract has enough liquidity
        if (claim_amount <= current_liquidity) {
            // remove stake amount and profit from the liquidity
            current_liquidity -= claim_amount;

            // send the claimed profit and stake amount to user's wallet
            (bool success, ) = msg.sender.call{value: claim_amount}("");
            require(success, "Stake can't be claimed.");
            
        } else { // liquidity is insufficient
            uint64 remaining_balance = uint64(claim_amount - current_liquidity);
            claim_amount = current_liquidity;

            // set user's stake outstanding
            stakeOutstandings[msg.sender][account.outstanding_end_bound].outstanding_profit = remaining_balance;
            stakeOutstandings[msg.sender][account.outstanding_end_bound].trail_unresolved_amount = unresolved_amount;
            account.outstanding_end_bound += 1;

            unresolved_amount += remaining_balance;
            unresolved_outstanding_count += 1;

            // send the current liquidity
            if (current_liquidity > 0) {
                // set the liquidity to zero
                current_liquidity = 0;

                (bool success, ) = msg.sender.call{value: claim_amount}("");
                require(success, "Stake can't be claimed.");
            }
        }

        emit StakeClaimed(msg.sender, claim_amount);
    }

    /**
     * @dev Claim user's stake outstanding.
     */
    function claimStakeOutstanding() external preventReentracy {
        UserAccount storage account = accounts[msg.sender];
        uint256 counter = account.outstanding_start_index;
        uint256 resolved_counter = resolved_outstanding_count;
        uint64 claim_amount;

        // check if user have stake outstanding
        require(account.outstanding_end_bound > 0, "You have no outstanding.");

        // iterate through the outstanding list
        while (counter < account.outstanding_end_bound) {
            StakeOutstanding storage stake_outstanding = stakeOutstandings[msg.sender][counter];

            // check if stake outstanding can be resolved
            if (resolved_amount <= stake_outstanding.trail_unresolved_amount) {
                break; // exit the loop
            }

            // check if it will clear the outstanding
            if (resolved_amount >= (stake_outstanding.trail_unresolved_amount + stake_outstanding.outstanding_profit)) {
                claim_amount += stake_outstanding.outstanding_profit;
                resolved_counter += 1;

            } else { // it can't clear the outstanding
                claim_amount += resolved_amount - stake_outstanding.trail_unresolved_amount;
                stake_outstanding.outstanding_profit -= resolved_amount - stake_outstanding.trail_unresolved_amount;
                stake_outstanding.trail_unresolved_amount = resolved_amount;

                // exit the loop
                break;
            }

            counter += 1; // increment by one
        }

        // check if the user claimed any amount
        require(claim_amount > 0, "Stake outstanding is not yet resolved.");

        // check if all the user have claimed their pending outstandings
        if (unresolved_outstanding_count == resolved_counter) {
            // reset the unresolved and resolved track data
            unresolved_amount = 0;
            resolved_amount = 0;
            unresolved_outstanding_count = 0;
            resolved_outstanding_count = 0;

        } else {
            resolved_outstanding_count = uint64(resolved_counter);
        }

        // check if all the stake outstanding is resolved
        if (counter == account.outstanding_end_bound) {
            account.outstanding_start_index = 0;
            account.outstanding_end_bound = 0;

        } else {
            account.outstanding_start_index = uint64(counter);
        }

        // send the claimed amount
        (bool success, ) = msg.sender.call{value: claim_amount}("");
        require(success, "Resolving stake outstanding failed.");

        emit StakeClaimed(msg.sender, claim_amount);
    }

    /**
     * @dev Claim all your referral bonus.
     */
    function claimReferralBonus() external {
        UserAccount storage account = accounts[msg.sender];
        uint64 claim_amount = account.referral_bonus;

        // check if user have any referral bonus
        require(claim_amount > 0, "No referral bonus.");

        // reset the referral bonus
        account.referral_bonus = 0;
        account.referral_insert_index = 0;

        // send the claimed referral bonus
        (bool success, ) = msg.sender.call{value: claim_amount}("");
        require(success, "Claiming of referral bonus failed.");

        emit ReferralBonusClaimed(msg.sender, claim_amount);
    }

    /**
     * @dev Get smartcontract information.
     * @return (uint256, uint256, uint256)
     */
    function getContractInfo() 
        external 
        view 
        returns (uint256, uint256, uint256) 
    {
        return (
            total_investors, 
            total_stake, 
            total_generated_liquidity
        );
    }

    /**
     * @dev Get user account information.
     * @return (uint256, uint256, uint256, uint256)
     */
    function getUserAccountInfo() 
        external 
        view 
        returns (uint256, uint256, uint256, address) 
    {
        UserAccount memory account = accounts[msg.sender];

        // return some user's account information
        return (
            account.current_total_stake, // current amount of TRX staked
            account.referral_bonus, // total amount of TRX earn from referral
            account.referral_count, // number of users you referred 
            account.your_referral // the address of the user that referred you
        );
    }

    /**
     * @dev Get user outstanding information.
     * @return (uint256, uint256)
     */
    function getUserOutstandingInfo() external view returns (uint256, uint256) {
        UserAccount memory account = accounts[msg.sender];
        uint256 available_amount;
        uint256 total_outstanding_profit;
        uint256 counter = account.outstanding_start_index;

        while (counter < account.outstanding_end_bound) {
            StakeOutstanding memory stake_outstanding = stakeOutstandings[msg.sender][counter];

            // resolved outstanding to claim
            if (resolved_amount >= (stake_outstanding.trail_unresolved_amount + stake_outstanding.outstanding_profit)) {
                available_amount += stake_outstanding.outstanding_profit;

            } else if (resolved_amount > stake_outstanding.trail_unresolved_amount) {
                available_amount += resolved_amount - stake_outstanding.trail_unresolved_amount;
            }

            total_outstanding_profit += stake_outstanding.outstanding_profit;
            counter += 1; // increment by one
        }

        return (available_amount, total_outstanding_profit);
    }

    /**
     * @dev Get user's active stake list.
     * @return uint256[5][]
     */
    function getUserStakes() external view returns (uint256[5][] memory) {
        Stake[] memory user_stakes = userStakes[msg.sender];
        uint256[5][] memory stake_list = new uint256[5][](user_stakes.length);

        // populate the array
        for (uint256 i = 0; i < user_stakes.length; i++) {
            stake_list[i][0] = user_stakes[i].id; 
            stake_list[i][1] = user_stakes[i].amount; 
            stake_list[i][2] = user_stakes[i].profit; 
            stake_list[i][3] = user_stakes[i].start_time; 
            stake_list[i][4] = user_stakes[i].due_time;
        }

        return stake_list;
    }

    /**
     * @dev Get user referral bonus list.
     * @return uint256[2][]
     */
    function getUserReferralList() external view returns (uint256[3][] memory) {
        UserAccount memory account = accounts[msg.sender];
        uint256[3][] memory referral_list = new uint256[3][](account.referral_insert_index);

        // populate the array
        for (uint256 i = 0; i < account.referral_insert_index; i++) {
            referral_list[i][0] = userReferrals[msg.sender][i].id;
            referral_list[i][1] = uint256(userReferrals[msg.sender][i].user_address);
            referral_list[i][2] = userReferrals[msg.sender][i].amount;
        }

        return referral_list;
    }

    /**
     * @dev Get Linkedpalm current liquidity.
     * @return uint256
     */
    function getCurrentLiquidity() external view onlyAdmin returns (uint256) {
        return current_liquidity;
    }

    /**
     * @dev Get smartcontract loan information.
     * @param contract_address Tron contract address.
     */
    function getFundContractInfo(address contract_address) 
        external 
        view 
        onlyAdmin 
        returns (uint256, uint256, uint256) 
    {
        FundContract memory fund_contract = fundContracts[contract_address];

        // return smartcontract loan information
        return (
            fund_contract.loan_amount, 
            fund_contract.total_loan_amount, 
            fund_contract.total_generated_liquidity
        );
    }

    /**
     * @dev Allow or disallow smartcontract from requesting for a loan.
     * @param contract_address Tron contract address.
     * @param authorize The value can either be true or false.
     */
    function authorizeContractLoanRequest(address contract_address, bool authorize) external onlyAdmin {
        // Give the smartcontract access to request for loan
        fundContracts[contract_address].access = authorize;
    }
}