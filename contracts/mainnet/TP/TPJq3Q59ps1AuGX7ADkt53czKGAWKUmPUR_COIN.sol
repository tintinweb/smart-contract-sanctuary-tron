//SourceUnit: CACHE.sol

pragma solidity 0.5.8;

// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address payable public owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address payable _newOwner) public onlyOwner {
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// ----------------------------------------------------------------------------
contract TRC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address payable from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

contract COIN is Owned, TRC20Interface{
    using SafeMath for uint256;

    /* TRC20 public vars */
    string public constant version = 'TestBox 0.2';
    string public name = 'COIN';
    string public symbol = 'COIN';
    uint256 public decimals = 18;
    uint256 internal _totalSupply;

    /* TRC20 This creates an array with all balances */
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;


    /* Keeps record of Depositor's amount and deposit time */
    mapping (address => Depositor) public depositor;
    /* Keeps record of Penalty amount and penalty fee time */
    mapping (uint256 => mapping (uint256 =>Penalty)) public penalty;

    struct Depositor{
        uint256 amount;
        uint256 time;
    }

    struct Penalty{
        uint256 amount;
        uint256 time;
        uint256 deservers;
        uint256 totalPenaltiesInThisIndex;
    }

    /* feePot collects fees from quick withdrawals. This gets re-distributed to withdrawals */
    uint256 public feePot;

    /* reservedReward collects owner reward share */
    uint256 public reservedReward;

    //uint256 public timeWait = 30 days;
    uint256 public timeWait = 30 minutes; //  for TestNet
    uint256 startTime = now;

    uint256 public constant initialSupply = 4e7;                                                //40,000,000

    /* custom events to notify users */
    event Withdraw(address indexed by, uint256 amount, uint256 fee, uint256 reward);            // successful withdraw event
    event Deposited(address indexed by, uint256 amount);                                        // funds Deposited event
    event PaidOwnerReward(uint256 amount);
    /*
     * Initializes contract with initial supply tokens to the creator of the contract
     * In our case, there's no initial supply. Tokens will be created as TRX is sent
     * to the fall-back function. Then tokens are burned when TRX is withdrawn.
     */
    constructor () public {
        owner = address(msg.sender);
        _totalSupply = initialSupply * 10 ** uint(decimals);                            // Update total supply
        balances[owner] = _totalSupply;                                                 // Give the creator all initial tokens
        emit Transfer(address(0),address(owner), _totalSupply);
    }

    /**
     * Fallback function when sending TRX to the contract
     * Gas use: 91000
    */
    function() external payable {
        makeDeposit(msg.sender, msg.value);
    }

    function makeDeposit(address sender, uint256 amount) internal {
        require(balances[sender] == 0);
        require(amount > 0);
        balances[sender] = balances[sender].add(amount.mul(1000));                      // mint new tokens
        _totalSupply = _totalSupply.add(amount.mul(1000));                              // track the supply
        emit Transfer(address(0), sender, amount.mul(1000));                            // notify of the transfer event
        depositor[sender].time = now;
        depositor[sender].amount = amount;
        emit Deposited(sender, amount);
    }

    function withdraw(address payable _sender, uint256 _tokens) internal {
        //uint256 amount = depositor[_sender].amount;                                   // check the actual deposit of the sender
        uint256 amount = _tokens.div(1000);
        uint256 reward = calculateReward(/*amount*/ _tokens, _sender);                  // calculate reward of the sender based on actual deposit
        // depositor[_sender].amount = depositor[_sender].amount.sub(amount);           // remove deposit information from depositor record
        if(depositor[_sender].time.add(timeWait) > now )                                // sender asked for withdraw before 30 days of purchase
            amount = quickWithdraw(amount);                                             // quick Withdraw will happen
        require(_sender.send(amount + reward));                                         // transfer TRX plus earned reward to sender
        feePot = feePot.sub(reward);                                                    // remove reward from feePot
        emit Withdraw(_sender, amount, _tokens.div(1000).sub(amount), reward);
    }

    /**
     * Quick withdrawal, deduct 4% penalty fee due to early withdraw.
     *
     * Gas use: ? (including call to processWithdrawal)
    */
    function quickWithdraw(uint256 _amount) internal returns (uint256) {
        uint256 penaltyFee = calculateFee(_amount);                                       // deduct 4% of the actual deposit as penalty fee
        feePot =  feePot.add((penaltyFee.mul(70).mul(100)).div(10000));                   // add 70% of the penaltyFee to fee Pot to distribute later
        reservedReward = reservedReward.add((penaltyFee.mul(30).mul(100)).div(10000));    // add 30% of the penaltyFee to reserves for owner
        recordPenalty((penaltyFee.mul(70).mul(100)).div(10000), _amount);                                               // record penalty fee
        return _amount.sub(penaltyFee);
    }

    function recordPenalty(uint256 fee, uint256 _amount) internal {
        uint TP = penalty[(now.sub(startTime)).div(timeWait)][0].totalPenaltiesInThisIndex;
        if(_totalSupply.sub(balanceOf(owner)).sub(_amount.mul(1000)) == 0) { // no deservers
            reservedReward = reservedReward.add(fee);
            feePot = feePot.sub(fee);
        }
        else{
            penalty[(now.sub(startTime)).div(timeWait)][TP] = Penalty(fee, now, _totalSupply.sub(balanceOf(owner)).sub(_amount.mul(1000)),TP+1);
            penalty[(now.sub(startTime)).div(timeWait)][0].totalPenaltiesInThisIndex = TP+1;
        }
    }

    function ownerReward() internal{
        require(owner.send(reservedReward));
        emit PaidOwnerReward(reservedReward);
        reservedReward = reservedReward.sub(reservedReward);

    }

    /**
     * Reward is based on the amount held, relative to total supply of tokens.
     */
    function calculateReward(uint256 _amount, address _sender) internal view returns (uint256) {
        uint256 reward = 0;
        for (uint256 i= (depositor[_sender].time.sub(startTime)).div(timeWait);
        i<= ((depositor[_sender].time.sub(startTime)).div(timeWait)).add(now.sub(depositor[_sender].time)).div(timeWait);
        i++){
            uint count = penalty[i][0].totalPenaltiesInThisIndex;
            while(count != 0){
                if(penalty[i][count].time >= depositor[_sender].time && penalty[i][count].time <= now){
                    if (feePot > 0) {
                        reward += ((penalty[i][count].amount).mul(_amount)).div(penalty[i][count].deservers); // assuming that if feePot > 0 then also totalSupply > 0
                    }
                }
                count = count.sub(1);
            }

            if(count == 0){
                if(penalty[i][count].time >= depositor[_sender].time && penalty[i][count].time <= now){
                    if (feePot > 0) {
                        reward += ((penalty[i][count].amount).mul(_amount)).div(penalty[i][count].deservers); // assuming that if feePot > 0 then also totalSupply > 0
                    }
                }
            }
        }


        // if (feePot > 0) {
        //     reward = (feePot.mul(_amount)).div((_totalSupply.sub(balances[owner]))); // assuming that if feePot > 0 then also totalSupply > 0
        // }
        return reward;
    }

    /** calculate the penalty fee for quick withdrawal
     */
    function calculateFee(uint256 _amount) public pure returns  (uint256) {
        uint256 feeRequired = (_amount.mul(4).mul(100)).div(10000); // 4%
        return feeRequired;
    }

    /***************************** TRC20 implementation **********************/
    function totalSupply() public view returns (uint){
       return _totalSupply;
    }
    // ------------------------------------------------------------------------
    // Get the token balance for account `tokenOwner`
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }

    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to `to` account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) public returns (bool success) {
        if(msg.sender == owner) { require(tokens >= 1e18);}                         // minimum tokens sent by owner sould be >= 1
        require(to != address(0));                                                  // receiver address should not be zero-address
        require(balances[msg.sender] >= tokens );                                   // sender must have sufficient tokens to transfer
        uint256 bal1 = balances[address(this)];

        balances[msg.sender] = balances[msg.sender].sub(tokens);                    // remove tokens from sender

        require(balances[to] + tokens >= balances[to]);                             // if tokens are sent to any other wallet address

        balances[to] = balances[to].add(tokens);                                    // Transfer the tokens to "to" address

        emit Transfer(msg.sender,to,tokens);                                        // emit Transfer event to "to" address

        if(to ==  address(this)){                                                   // if tokens are sent to contract address
            require(bal1 < balances[address(this)]);

            if(depositor[msg.sender].time > 0){                                     // sender must be an actual depositor
                withdraw(msg.sender, tokens);                                       // perform withdraw
            }

             if (msg.sender == owner){
                ownerReward();
             }

            balances[to] = balances[to].sub(tokens);                                // remove tokens from sender balance
            _totalSupply = _totalSupply.sub(tokens);                                // remove sent tokens from totalSupply
            emit Transfer(to, address(0), tokens);                                  // emit Transfer event of burning
        }
        return true;
    }


    // ------------------------------------------------------------------------
    // Transfer `tokens` from the `from` account to the `to` account
    //
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the `from` account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transferFrom(address payable from, address to, uint tokens) public returns (bool success){
        require(from != address(0));
        require(to != address(0));
        require(tokens <= allowed[from][msg.sender]); //check allowance
        require(balances[from] >= tokens); // check if sufficient balance exist or not

        if(to == address(this)){
            if(from == owner)
                require(tokens == 1e18);
        }

        uint256 bal1 = balances[address(this)];
        balances[from] = balances[from].sub(tokens);

        require(balances[to] + tokens >= balances[to]);

        balances[to] = balances[to].add(tokens);                                            // Transfer the tokens to "to" address

        emit Transfer(from,to,tokens);                                                // emit Transfer event to "to" address

        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);

        if(to ==  address(this)){                                                   // if tokens are sent to contract address
            require(bal1 < balances[address(this)]);


            if(depositor[from].time > 0){                                     // sender must be an actual depositor
                withdraw(from, tokens);                                       // perform withdraw
            }

            if (from == owner){
                ownerReward();
            }

            balances[to] = balances[to].sub(tokens);                                // remove tokens from sender balance
            _totalSupply = _totalSupply.sub(tokens);                                // remove sent tokens from totalSupply
            emit Transfer(to, address(0), tokens);                                  // emit Transfer event of burning
        }
        return true;
    }

    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account
    // ------------------------------------------------------------------------
    function approve(address spender, uint tokens) public returns (bool success){
        require(spender != address(0));
        require(tokens <= balances[msg.sender]);
        require(tokens >= 0);
        require(allowed[msg.sender][spender] == 0 || tokens == 0);
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender,spender,tokens);
        return true;
    }

    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

}