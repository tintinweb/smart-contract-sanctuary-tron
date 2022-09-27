//SourceUnit: TILYmax.sol

/*

TTTTTTTTTTTTTTTTTTTTTT IIIIIII LLLLLLL   YYYYYYY           YYYYYYY   GGGGGGGGGGGGGG
TT::::::::::::::::::TT I:::::I L:::::L    Y:::::Y         Y:::::Y  GGG::::::::::::G
TTTTTTTT:::::TTTTTTTTT I:::::I L:::::L     Y:::::Y       Y:::::Y GG:::::::::::::::G
       T:::::T         I:::::I L:::::L      Y:::::Y     Y:::::Y G:::::GGGGGGGG::::G
       T:::::T         I:::::I L:::::L       Y:::::Y   Y:::::Y G:::::G       GGGGGG     ooooooooooo
       T:::::T         I:::::I L:::::L         Y:::::::::::Y  G:::::G                oo:::::::::::oo
       T:::::T         I:::::I L:::::L           Y::::::::Y   G:::::G               o:::::::::::::::o
       T:::::T         I:::::I L:::::L            Y:::::Y     G:::::G    GGGGGGGGGG o:::::ooooo:::::o
       T:::::T         I:::::I L:::::L            Y:::::Y     G:::::G    G::::::::G o::::o     o::::o
       T:::::T         I:::::I L:::::L            Y:::::Y     G:::::G    GGGGG::::G o::::o     o::::o
       T:::::T         I:::::I L:::::L            Y:::::Y     G:::::G        G::::G o::::o     o::::o
       T:::::T         I:::::I L:::::L            Y:::::Y      G:::::G       G::::G o::::o     o::::o
       T:::::T         I:::::I L:::::LLLLLLLL     Y:::::Y       G:::::GGGGGGGG::::G o:::::ooooo:::::o
       T:::::T         I:::::I L::::::::::::L     Y:::::Y        GG:::::::::::::::G o:::::::::::::::o
       T:::::T         I:::::I L::::::::::::L     Y:::::Y          GGG::::::GGG:::G  oo:::::::::::oo
       TTTTTTT         IIIIIII LLLLLLLLLLLLLL     YYYYYYY            GGGGGGGGGGGGG     ooooooooooo

*
* https://smart.Instantily.com [TILY smart Exchange+Staking]
* SPDX-License-Identifier:  MIT License
*/
pragma solidity ^0.5.9;

contract TILYgo {
    using SafeMath for uint;
    /*=================================
    =            MODIFIERS            =
    =================================*/
    // only people with tokens
    modifier onlyHolders () {
        require(myTokens() > 0);
        _;
    }

    // only people with profits
    modifier hasProfit() {
        require(myDividends(true) > 0);
        _;
    }

    /*==============================
    =            EVENTS            =
    ==============================*/
    event onTokenPurchase(
        address indexed userId,
        uint incomingtrx,
        uint tokensMinted,
        address indexed refBy
    );

    event onTokenDeposit(
        address indexed userId,
        uint incomingTokens,
        uint tokensMinted,
        address indexed refBy
    );

    event onTokenSell(
        address indexed userId,
        uint tokensBurned,
        uint trxEarned
    );

    event onReinvestment(
        address indexed userId,
        uint trxReinvested,
        uint tokensMinted
    );

    event onWithdraw(
        address indexed userId,
        uint trxWithdrawn
    );

    // ERC20
    event onTransfer(
        address indexed from,
        address indexed to,
        uint tokens
    );

    event receivedTokens(
        address indexed _from,
        uint _value
    );

    event GetLevelProfitEvent(
        address indexed userId,
        address indexed referral,
        uint256 referralID,
        uint256 amount
    );


    /*=====================================
    =            CONFIGURABLES            =
    =====================================*/
    address public contract_;
    ITRC20 public TilyToken;
    uint256 constant internal tokenPriceInitial_ = 10000;
    uint256 constant internal tokenPriceIncremental_ = 100;
    uint constant private magnitude = 2**64;
    uint constant public maxTokenSupply = 125 * 1e14;
    uint constant private startDate = 1598279576;

    // proof of stake (defaults at 1 token)
    uint public stakingRequirement = 1e12;

    uint constant private maxStakingSupply = 50 * 1e24;

    /*================================
     =            DATASETS            =
     ================================*/

    // amount of shares for each private (scaled number)
    mapping(address => uint) private tokenBalanceLedger_;
    mapping(address => uint) private referralBalance_;
    mapping(address => int256) private payoutsTo_;

    uint private roiPool = 0;
    uint private totalDividends = 0;
    uint private totalDeposits = 0;
    uint private totalPurchase = 0;
    uint private tokenStaked_ = 0;
    uint private tokenCirculation_ = 0; // Generated
    uint private profitPerShare_ = 0;
    uint private totalPayouts_ = 0;

    uint constant private buyFee_ = 30;
    uint constant private sellFee_ = 10;
    uint constant private depFee_ = 45;
    uint constant private roiFee_ = 2;
    uint constant private transferFee_ = 10;
    uint constant private affComm_ = 15;

    uint constant private tier1 = 46295;
    uint constant private tier2 = 57870;
    uint constant private tier3 = 77545;
    uint constant private tier4 = 86805;
    uint constant private tier5 = 98375;
    uint constant private tier6 = 127310;

    mapping(address => DataStructs.UserData) public userData;
    mapping(uint256 => address) public userAddresses;
    mapping(uint256 => uint256) levelPrice; // TILY team Power
    uint last_uid = 1;

    constructor(ITRC20 _token) public{
        contract_ = msg.sender;
        TilyToken = _token;
        DataStructs.UserData storage _userData = userData[contract_];
        _userData.referrals = new address[](0);
        _userData.id = last_uid;
        _userData.finances[0].totalEarnings = 0;
        last_uid++;
    }

    /**
     * @dev allows only the user to run the function
     */
    modifier onlyContract() {
        require(msg.sender == contract_, "only Owner");
        _;
    }

    /*=======================================
    =            PUBLIC FUNCTIONS            =
    =======================================*/

    /**
     * Converts all incoming trx to tokens for the caller, and passes down the referral address (if any)
     */
    function buy(address _refBy)
    public
    payable
    returns(uint)
    {
        purchaseTokens(msg.value, _refBy, msg.sender);
    }


    function() external payable
    {
        purchaseTokens(msg.value, address(0), msg.sender);
    }

    function buyStaking(address _refBy) public payable returns(uint){
        uint _trxIn = msg.value;
        address _userId = msg.sender;
        require(_trxIn >= 1500 trx, 'Wrong amount');
        checkout(_userId);
        return maxStaking(_userId, _refBy, _trxIn);
    }

    /**
     * Converts all of caller's dividends to tokens.
     */
    function reinvest()
    hasProfit()
    public
    {
        // fetch dividends
        uint _dividends = myDividends(false); // retrieve ref. bonus later in the code

        // pay out the dividends virtually
        address _userId = msg.sender;
        payoutsTo_[_userId] +=  (int256) (_dividends * magnitude);

        // retrieve ref. bonus
        _dividends += referralBalance_[_userId];
        referralBalance_[_userId] = 0;
        userData[_userId].finances[0].totalWithdrawn += _dividends;

        // dispatch a buy order with the virtualized "withdrawn dividends"
        uint _tokens = purchaseTokens(_dividends, address(0), msg.sender);

        // fire event
        emit onReinvestment(_userId, _dividends, _tokens);
    }

    /**
     * Alias of sell() and withdraw().
     */
    function exit()
    public
    {
        // get token count for caller & sell them all
        address _userId = msg.sender;
        uint _tokens = tokenBalanceLedger_[_userId];
        if(_tokens > 0) sell(_tokens);

        withdraw();
    }

    /**
     * Withdraws all of the callers earnings.
     */
    function withdraw()
    hasProfit()
    public
    {
        // setup data
        address _userId = msg.sender;
        uint _dividends = myDividends(false); // get ref. bonus later in the code

        // update dividend tracker
        payoutsTo_[_userId] +=  (int256) (_dividends * magnitude);

        // add ref. bonus
        _dividends += referralBalance_[_userId];
        referralBalance_[_userId] = 0;
        userData[_userId].finances[0].totalWithdrawn += _dividends;

        // delivery service
        address(uint160(_userId)).transfer(_dividends);

        // fire event
        emit onWithdraw(_userId, _dividends);
    }

    /**
     * Liquifies tokens to trx.
     */
    function sell(uint _tokenAmount)
    onlyHolders ()
    public
    {
        address _userId = msg.sender;

        require(_tokenAmount <= tokenBalanceLedger_[_userId]);

        uint _taxedtrx = sellToken(_userId, _tokenAmount);

        // update dividends tracker
        int256 _updatedPayouts = (int256) (profitPerShare_ * _tokenAmount + (_taxedtrx * magnitude));
        payoutsTo_[_userId] -= _updatedPayouts;

        // fire event
        emit onTokenSell(_userId, _tokenAmount, _taxedtrx);
    }

    /**
     * Transfer tokens from the caller to a new holder.
     * Remember, there's a 10% fee here as well.
     */
    function transfer(address _toAddress, uint _tokenAmount)
    onlyHolders ()
    public
    returns(bool)
    {
        // setup
        address _userId = msg.sender;

        // make sure we have the requested tokens

        require(_tokenAmount <= tokenBalanceLedger_[_userId]);

        // withdraw all outstanding dividends first
        if(myDividends(true) > 0) withdraw();

        // liquify 10% of the tokens that are transfered
        // these are dispersed to shareholders
        uint _tokenFee = SafeMath.div(_tokenAmount, transferFee_);
        uint _taxedTokens = SafeMath.sub(_tokenAmount, _tokenFee);
        uint _dividends = tokensTotrx_(_tokenFee);

        // burn the fee tokens
        tokenCirculation_ = SafeMath.sub(tokenCirculation_, _tokenFee);

        // exchange tokens
        tokenBalanceLedger_[_userId] = SafeMath.sub(tokenBalanceLedger_[_userId], _tokenAmount);
        tokenBalanceLedger_[_toAddress] = SafeMath.add(tokenBalanceLedger_[_toAddress], _taxedTokens);

        // update dividend trackers
        payoutsTo_[_userId] -= (int256) (profitPerShare_ * _tokenAmount);
        payoutsTo_[_toAddress] += (int256) (profitPerShare_ * _taxedTokens);

        // disperse dividends among holders
        profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenCirculation_);

        // fire event
        emit onTransfer(_userId, _toAddress, _taxedTokens);

        // ERC20
        return true;
    }


    /**
     * Transfer tokens from the Holder to an External address.
     * 10% fee applies here as well.
     */
    function withdrawTokens(address _toAddress, uint _tokenAmount)
    onlyHolders ()
    public
    returns(bool)
    {
        // setup
        address _userId = msg.sender;

        // Transfer Token
        ITRC20 token = ITRC20(TilyToken);

        // make sure we have the requested tokens
        uint _tokenFee = SafeMath.div(_tokenAmount, transferFee_);

        uint _taxedTokens = SafeMath.add(_tokenAmount, _tokenFee);

        require(_taxedTokens <= tokenBalanceLedger_[_userId] && token.balanceOf(address(this)) > _tokenAmount);

        // burn the tokens transfered
        tokenCirculation_ = SafeMath.sub(tokenCirculation_, _taxedTokens);

        // Debit sender
        tokenBalanceLedger_[_userId] = SafeMath.sub(tokenBalanceLedger_[_userId], _taxedTokens);

        // update dividend trackers
        payoutsTo_[_userId] -= (int256) (profitPerShare_ * _taxedTokens);

        // No dividend on External transfer
        token.transfer(address(_toAddress), _tokenAmount);

        // fire event
        emit onTransfer(_userId, _toAddress, _taxedTokens);

        // ERC20
        return true;
    }

    /**
     * Move Available Staking Rewards
     * to ProfitSharing
     * this only applies to Tokens
     * Earned from Staking
     * */
    function manualCheckout() public returns(bool) {
        address _userId = msg.sender;
        checkout(_userId);
        return true;
    }

    /*----------  ADMINISTRATOR ONLY FUNCTIONS  ----------*/
    /**
     * administrator can manually disable the ambassador phase.
     */

    function setStakingRequirement(uint _tokenAmount)
    public
    {
        require(msg.sender == contract_,'Not allowed');
        stakingRequirement = _tokenAmount;
    }


    /**
     * Live Profit view
     * */

    function getProfit(address _userId) public view returns (uint) {

        DataStructs.UserData storage _userData = userData[_userId];

        require(_userData.stakes.length > 0);

        uint secPassed = SafeMath.sub(now, _userData.finances[0].last_payout);

        uint _gProfit = 0;

        for(uint s = 0; s < _userData.stakes.length; s++){
            DataStructs.Stakes memory _stake = _userData.stakes[s];
            if(secPassed > 0){
                uint _releaseRate = getReleaseFrequency(_stake.amount);
                uint _produce = SafeMath.mul(secPassed,  SafeMath.mul(_stake.tokenAmount, _releaseRate));
                uint _uProfit = SafeMath.div(_produce, 1e12);
                uint _mProfit = _stake.tokenAmount;
                uint _rProfit = _stake.released;
                if(_rProfit < _mProfit){
                    _gProfit = SafeMath.add(_gProfit, _uProfit);
                }
            }
        }

        return _gProfit;
    }

    /*----------  HELPERS AND CALCULATORS  ----------*/
    /**
     * Method to view the current trx stored in the contract
     * Example: totaltrxBalance()
     */
    function totaltrxBalance()
    private
    view
    returns(uint)
    {
        return address(this).balance;
    }

    /**
     * Retrieve the total token supply.
     */
    function tokenCirculation()
    private
    view
    returns(uint)
    {
        return tokenCirculation_;
    }

    /**
     * Retrieve the tokens owned by the caller.
     */
    function myTokens()
    private
    view
    returns(uint)
    {
        address _userId = msg.sender;
        return balanceOf(_userId);
    }

    /**
     * Retrieve the dividends owned by the caller.
       */
    function myDividends(bool _includeReferralBonus)
    private
    view
    returns(uint)
    {
        address _userId = msg.sender;
        return _includeReferralBonus ? dividendsOf(_userId) + referralBalance_[_userId] : dividendsOf(_userId) ;
    }

    /**
     * Retrieve the token balance of any single address.
     */
    function balanceOf(address _userId)
    view
    private
    returns(uint)
    {
        return tokenBalanceLedger_[_userId];
    }

    /**
     * Retrieve the dividend balance of any single address.
     */
    function dividendsOf(address _userId)
    view
    private
    returns(uint)
    {
        return (uint) ((int256)(profitPerShare_ * tokenBalanceLedger_[_userId]) - payoutsTo_[_userId]) / magnitude;
    }

    /**
     * Return the buy price of 1 individual token.
     */
    function sellPrice()
    private
    view
    returns(uint)
    {

        if(tokenCirculation_ == 0){
            return tokenPriceInitial_ - tokenPriceIncremental_;
        } else {
            uint _trx = tokensTotrx_(1e8);
            uint _dividends = SafeMath.div(_trx, sellFee_);
            uint _taxedtrx = SafeMath.sub(_trx, _dividends);
            return _taxedtrx;
        }
    }

    /**
     * Return the sell price of 1 individual token.
     */
    function buyPrice()
    private
    view
    returns(uint)
    {

        if(tokenCirculation_ == 0){
            return tokenPriceInitial_ + tokenPriceIncremental_;
        } else {
            uint _trx = tokensTotrx_(1e8);
            uint _dividends = SafeMath.div(SafeMath.mul(_trx, buyFee_), 100);
            uint _taxedtrx = SafeMath.add(_trx, _dividends);
            return _taxedtrx;
        }
    }


    function calculateTokensReceived(uint _trxToSpend)
    public
    view
    returns(uint)
    {
        uint _dividends = SafeMath.div(SafeMath.mul(_trxToSpend, buyFee_), 100);
        uint _taxedtrx = SafeMath.sub(_trxToSpend, _dividends);
        uint _tokenAmount = trxToTokens_(_taxedtrx);

        return _tokenAmount;
    }

    function calculatetrxReceived(uint _tokensToSell)
    public
    view
    returns(uint)
    {
        require(_tokensToSell <= tokenCirculation_);
        uint _trx = tokensTotrx_(_tokensToSell);
        uint _dividends = SafeMath.div(_trx, sellFee_);
        uint _taxedtrx = SafeMath.sub(_trx, _dividends);
        return _taxedtrx;
    }

    function getPackTokenPrice(uint _amount) public view returns(uint){
        uint _netTokens = trxToTokens_(_amount);
        uint _margin = SafeMath.div(SafeMath.mul(_netTokens, 25), 100);
        return SafeMath.add(_margin, _netTokens);
    }

    function myAccount(address _userId) public view returns(uint _myShares, uint _myEarnings, uint _combined, uint _myTokens, uint _tokenTotrx, uint _tokenTransfer){
        uint _fee = transferFee_.div(100).add(1);
        return(
        dividendsOf(_userId),
        userData[_userId].finances[0].totalEarnings,
        myDividends(true),
        balanceOf(_userId),
        tokensTotrx_(balanceOf(_userId)),
        balanceOf(_userId).div(_fee)
        );
    }

    function siteSummary() public view returns(uint _liquidity, uint _minted, uint _staked, uint _lastUid, uint _buyR, uint _sellR, uint _shares, uint _payouts, uint _tokens){
        ITRC20 token = ITRC20(TilyToken);
        return(totaltrxBalance(), tokenCirculation_, tokenStaked_, last_uid, buyPrice(), sellPrice(), totalDividends, totalPayouts_, token.balanceOf(address(this)));
    }

    /***
    ** Alow External Deposit of TILY Tokens
    */
    function receiveApproval(address _from, uint _value, address _contract, bytes memory _extraData) public {
        ITRC20 token = ITRC20(_contract);
        require(token == TilyToken);
        require(_value >= stakingRequirement);
        require(token.transferFrom(_from,  address(this), _value));

        makeTokendeposit(_value, _from, bytesToAddress(_extraData));

        emit receivedTokens(_from, _value);
    }


    function msTokenP(uint _amount)  public returns(uint){
        address _userId = msg.sender;
        uint _trxIn = calculatetrxReceived(_amount);
        require(tokenBalanceLedger_[_userId] >= _amount, 'Low Balance');
        require( _trxIn >= 1500 trx,'Wrong Amount');
        // Sell user's Token
        sellToken(_userId, _amount);
        return maxStaking(_userId, userData[_userId]._refId, _trxIn);
    }


    /*==========================================
    =            INTERNAL FUNCTIONS            =
    ==========================================*/
    function purchaseTokens(uint _trxIn, address _refBy, address _userId)
    private
    returns(uint)
    {
        // data setup
        // address _userId = msg.sender;
        uint _undividedDividends = SafeMath.div(SafeMath.mul(_trxIn, buyFee_), 100);
        uint _referralBonus = SafeMath.div(SafeMath.mul(_undividedDividends, affComm_), 100);
        uint _dividends = SafeMath.sub(_undividedDividends, _referralBonus);
        uint _taxedtrx = SafeMath.sub(_trxIn, _undividedDividends);
        uint _tokenAmount = trxToTokens_(_taxedtrx);
        uint _fee = _dividends * magnitude;
        uint _roiPool = SafeMath.div(SafeMath.mul(_trxIn, roiFee_), 100);
        roiPool = SafeMath.add(roiPool, _roiPool);

        totalDividends = SafeMath.add(totalDividends, _undividedDividends);
        _dividends =  SafeMath.sub(_dividends, _roiPool);

        if(userData[_userId].id == 0 ){
            registerUser(_userId, _refBy);
        }

        require(_tokenAmount > 0 && (SafeMath.add(_tokenAmount,tokenCirculation_) > tokenCirculation_) && (SafeMath.add(_tokenAmount,tokenCirculation_) < maxTokenSupply));


        // we can't give people infinite trx
        if(tokenCirculation_ > 0){
            // add tokens to the pool
            tokenCirculation_ = SafeMath.add(tokenCirculation_, _tokenAmount);

            // take the amount of dividends gained through this transaction, and allocates them evenly to each shareholder
            profitPerShare_ += (_dividends * magnitude / (tokenCirculation_));

            // calculate the amount of tokens the customer receives over his purchase
            _fee = _fee - (_fee-(_tokenAmount * (_dividends * magnitude / (tokenCirculation_))));

        } else {
            // add tokens to the pool
            tokenCirculation_ = _tokenAmount;
        }
        // is the user referred by a karmalink?
        distributeReferral(_userId, _referralBonus, false);

        // update circulating supply & the ledger address for the customer
        tokenBalanceLedger_[_userId] = SafeMath.add(tokenBalanceLedger_[_userId], _tokenAmount);


        int256 _updatedPayouts = (int256) ((profitPerShare_ * _tokenAmount) - _fee);
        payoutsTo_[_userId] += _updatedPayouts;

        // fire event
        emit onTokenPurchase(_userId, _trxIn, _tokenAmount, _refBy);

        return _tokenAmount;
    }

    function makeTokendeposit(uint _tokenAmount, address _userId, address _refBy) private returns(uint){
        uint _dividends = SafeMath.div(SafeMath.mul(_tokenAmount, depFee_), 100);
        uint _taxedTokens = SafeMath.sub(_tokenAmount, _dividends);
        uint _referralBonus = SafeMath.div(SafeMath.mul(_tokenAmount, affComm_), 100);

        if(userData[_userId].id == 0 ){
            registerUser(_userId, _refBy);
        }

        tokenCirculation_ = SafeMath.add(tokenCirculation_, _taxedTokens);

        tokenBalanceLedger_[_userId] = SafeMath.add(tokenBalanceLedger_[_userId], _taxedTokens);

        uint _dividendsETH = SafeMath.sub(tokensTotrx_(_dividends), tokensTotrx_(_referralBonus));

        profitPerShare_ += (_dividendsETH * magnitude / (tokenCirculation_));

        uint _fee = _dividendsETH * magnitude;

        _fee = _fee - (_fee-(_taxedTokens * (_dividendsETH * magnitude / (tokenCirculation_))));

        int256 _updatedPayouts = (int256) ((profitPerShare_ * _taxedTokens) - _fee);
        payoutsTo_[_userId] += _updatedPayouts;

        distributeReferral(_userId, _referralBonus, true);

        emit onTokenDeposit(_userId, _tokenAmount, _taxedTokens, _refBy);

        return _taxedTokens;
    }

    function maxStaking(address _userId, address _refBy, uint _trxIn) private returns(uint){

        uint _undividedDividends = SafeMath.div(SafeMath.mul(_trxIn, buyFee_), 100);
        uint _referralBonus = SafeMath.div(SafeMath.mul(_undividedDividends, affComm_), 100);
        uint _dividends = SafeMath.sub(_undividedDividends, _referralBonus);
        uint _taxedtrx = SafeMath.sub(_trxIn, _undividedDividends);
        uint _tokenAmount = trxToTokens_(_taxedtrx);
        uint _tokenCap = SafeMath.mul(_tokenAmount, getProfitRatio(_trxIn));

        uint _roiPool = SafeMath.div(SafeMath.mul(_trxIn, roiFee_), 100);
        roiPool = SafeMath.add(roiPool, _roiPool);

        if(userData[_userId]._refId == address(0)){
            registerUser(_userId, _refBy);
        }

        totalDividends = SafeMath.add(totalDividends, _undividedDividends);
        _dividends =  SafeMath.sub(_dividends, _roiPool);

        require(_tokenAmount > 0 && (SafeMath.add(_tokenAmount, tokenStaked_) < maxStakingSupply));

        distributeReferral(_userId, _referralBonus, false);

        if(tokenStaked_ > 0){
            // add tokens to the pool
            tokenStaked_ = SafeMath.add(tokenStaked_, _tokenCap);
        }
        else{
            tokenStaked_ = _tokenCap;
        }
        // Update UserData
        userData[_userId].finances[0].staked = SafeMath.add(userData[_userId].finances[0].staked, _tokenCap);
        userData[_userId].finances[0].volume = SafeMath.add(userData[_userId].finances[0].volume, _trxIn);
        userData[_userId].stakes.push(DataStructs.Stakes({
            plan: getStakePlanId(_trxIn),
            amount: _trxIn,
            tokenCap: _tokenCap,
            tokenAmount: _tokenAmount,
            released: 0,
            time: uint(block.timestamp)
            }));

        return _tokenCap;
    }

    function registerUser(address _userId, address _refBy)
    private
    {
        last_uid++;
        DataStructs.UserData storage _userData = userData[_userId];
        _userData.referrals = new address[](0);
        _userData.id = last_uid;
        userAddresses[last_uid] = _userId;

        if(_refBy != _userId && _refBy != 0x0000000000000000000000000000000000000000 && tokenBalanceLedger_[_refBy] >= stakingRequirement){
            _userData._refId = _refBy;
        }
        else{
            _userData._refId = contract_;
        }

        address _affAddr1 = _userData._refId;
        address _affAddr2 = userData[_affAddr1]._refId;
        address _affAddr3 = userData[_affAddr2]._refId;

        userData[_affAddr1].affCount1Sum = SafeMath.add(userData[_affAddr1].affCount1Sum,1);
        userData[_affAddr2].affCount2Sum = SafeMath.add(userData[_affAddr2].affCount2Sum,1);
        userData[_affAddr3].affCount3Sum = SafeMath.add(userData[_affAddr3].affCount3Sum,1);
    }

    function distributeReferral(address _userId, uint _amount, bool _type)
    private
    returns(uint)
    {

        DataStructs.UserData storage _userData = userData[_userId];
        address _affAddr1 = _userData._refId;
        address _affAddr2 = userData[_affAddr1]._refId;
        address _affAddr3 = userData[_affAddr2]._refId;
        uint _affReward1 = SafeMath.mul(_amount, SafeMath.div(7, affComm_));
        uint _affReward2 = SafeMath.mul(_amount, SafeMath.div(5, affComm_));
        uint _affReward3 = SafeMath.mul(_amount, SafeMath.div(3, affComm_));
        uint _affSent = _amount;

        if (_affAddr1 != address(0) && tokenBalanceLedger_[_affAddr1] >= stakingRequirement) {
            _affSent = SafeMath.sub(_affSent, _affReward1);
            if(_type){
                tokenBalanceLedger_[_affAddr1] = SafeMath.add(tokenBalanceLedger_[_affAddr1], _affReward1);
                userData[_affAddr1].affTokensRewardsSum = SafeMath.add(userData[_affAddr1].affTokensRewardsSum, _affReward1);
                tokenCirculation_ = SafeMath.add(tokenCirculation_, _affReward1);
            }else{
                referralBalance_[_affAddr1] = SafeMath.add(referralBalance_[_affAddr1], _affReward1);
                userData[_affAddr1].affRewardsSum = SafeMath.add(userData[_affAddr1].affRewardsSum, _affReward1);
                userData[_affAddr1].finances[0].totalEarnings += _affReward1;
            }

        }

        if (_affAddr2 != address(0) && tokenBalanceLedger_[_affAddr2] >= stakingRequirement) {
            _affSent = SafeMath.sub(_affSent,_affReward2);
            if(_type){
                tokenBalanceLedger_[_affAddr2] = SafeMath.add(tokenBalanceLedger_[_affAddr2], _affReward2);
                userData[_affAddr2].affTokensRewardsSum = SafeMath.add(userData[_affAddr2].affTokensRewardsSum, _affReward2);
                tokenCirculation_ = SafeMath.add(tokenCirculation_, _affReward2);
            }else{
                referralBalance_[_affAddr2] = SafeMath.add(referralBalance_[_affAddr2], _affReward2);
                userData[_affAddr2].affRewardsSum = SafeMath.add(userData[_affAddr2].affRewardsSum, _affReward2);
                userData[_affAddr2].finances[0].totalEarnings += _affReward2;
            }
        }

        if (_affAddr3 != address(0) && tokenBalanceLedger_[_affAddr3] >= stakingRequirement) {
            _affSent = SafeMath.sub(_affSent,_affReward3);
            if(_type){
                tokenBalanceLedger_[_affAddr3] = SafeMath.add(tokenBalanceLedger_[_affAddr3], _affReward3);
                userData[_affAddr3].affTokensRewardsSum = SafeMath.add(userData[_affAddr3].affTokensRewardsSum, _affReward3);
                tokenCirculation_ = SafeMath.add(tokenCirculation_, _affReward3);
            }else{
                referralBalance_[_affAddr3] = SafeMath.add(referralBalance_[_affAddr3], _affReward3);
                userData[_affAddr3].affRewardsSum = SafeMath.add(userData[_affAddr3].affRewardsSum, _affReward3);
                userData[_affAddr3].finances[0].totalEarnings += _affReward3;
            }
        }

        if(_affSent > 0 ){
            if(_type){
                tokenBalanceLedger_[contract_] = SafeMath.add(tokenBalanceLedger_[contract_], _affSent);
                userData[contract_].affTokensRewardsSum = SafeMath.add(userData[contract_].affTokensRewardsSum, _affSent);
                tokenCirculation_ = SafeMath.add(tokenCirculation_, _affSent);
            }else{
                referralBalance_[contract_] = SafeMath.add(referralBalance_[contract_], _affSent);
                userData[contract_].affRewardsSum = SafeMath.add(userData[contract_].affRewardsSum, _affSent);
                userData[contract_].finances[0].totalEarnings += _affSent;
            }
        }

    }

    function getProfitRatio(uint _trxIn) private pure returns(uint){
        require(_trxIn >= 1500 trx);
        if(_trxIn >= 1500 trx && _trxIn < 10000 trx){
    return SafeMath.div(120, 100);
    }
    if(_trxIn >= 10000 trx && _trxIn < 35000 trx){
    return SafeMath.div(150, 100);
    }
    if(_trxIn >= 35000 trx && _trxIn < 100000 trx){
    return SafeMath.div(200, 100);
    }
    if(_trxIn >= 100000 trx && _trxIn < 250000 trx){
    return SafeMath.div(220, 100);
    }
    if(_trxIn >= 250000 trx && _trxIn < 500000 trx){
    return SafeMath.div(250, 100);
    }
    if(_trxIn >= 500000 trx){
    return SafeMath.div(300, 100);
    }
    }

    function getStakePlanId(uint _trxIn) private pure returns(uint){
        require(_trxIn >= 1500 trx);
        if(_trxIn >= 1500 trx && _trxIn < 10000 trx){
    return 1;
    }
    if(_trxIn >= 10000 trx && _trxIn < 35000 trx){
    return 2;
    }
    if(_trxIn >= 35000 trx && _trxIn < 100000 trx){
    return 3;
    }
    if(_trxIn >= 100000 trx && _trxIn < 250000 trx){
    return 4;
    }
    if(_trxIn >= 250000 trx && _trxIn < 500000 trx){
    return 5;
    }
    if(_trxIn >= 500000 trx){
    return 6;
    }
    }

    function getReleaseFrequency(uint _amount) private pure returns(uint){
        require(_amount >= 1500 trx);
        if(_amount >= 1500 trx && _amount < 10000 trx){
    return tier1;
    }

    if(_amount >= 10000 trx && _amount < 35000 trx){
    return tier2;
    }

    if(_amount >= 35000 trx && _amount < 100000 trx){
    return tier3;
    }

    if(_amount >= 100000 trx && _amount < 250000 trx){
    return tier4;
    }

    if(_amount >= 250000 trx && _amount < 500000 trx){
    return tier5;
    }

    if(_amount >= 500000 trx){
    return tier6;
    }
    }

    function sellToken(address _userId, uint _tokenAmount) internal returns(uint){
        uint _trx = tokensTotrx_(_tokenAmount);
        uint _dividends = SafeMath.div(_trx, sellFee_);
        uint _roiPool = SafeMath.div(SafeMath.mul(_trx, roiFee_), 100);
        roiPool = SafeMath.add(roiPool,_roiPool);
        uint _taxedtrx = SafeMath.sub(_trx, _dividends);

        totalDividends = SafeMath.add(totalDividends, _dividends);
        _dividends =  SafeMath.sub(_dividends, _roiPool);

        // burn the sold tokens
        tokenCirculation_ = SafeMath.sub(tokenCirculation_, _tokenAmount);
        tokenBalanceLedger_[_userId] = SafeMath.sub(tokenBalanceLedger_[_userId], _tokenAmount);

        // dividing by zero is a bad idea
        if (tokenCirculation_ > 0) {
            // update the amount of dividends per token
            profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenCirculation_);
        }

        return(_taxedtrx);
    }

    /**
     * Move Available Staking Rewards
     * to ProfitSharing
     * this only applies to Tokens
     * Earned from Staking
     * */
    function checkout(address _userId) private returns(uint){
        DataStructs.UserData storage _userData = userData[_userId];
        if(_userData.finances[0].last_payout == 0){
            _userData.finances[0].last_payout = uint(block.timestamp);
            return 0;
        }
        if(_userData.stakes.length < 1 || _userData.finances[0].released >= _userData.finances[0].staked) return 0;

        uint secPassed = SafeMath.sub(now, _userData.finances[0].last_payout);
        uint _gProfit = 0;

        if (secPassed == 0) return 0;

        for(uint s = 0; s < _userData.stakes.length; s++){
            DataStructs.Stakes memory _stake = _userData.stakes[s];
            if(secPassed > 0){
                uint _releaseRate = getReleaseFrequency(_stake.amount);
                uint _produce = SafeMath.mul(secPassed,  SafeMath.mul(_stake.tokenAmount, _releaseRate));
                uint _uProfit = SafeMath.div(_produce, 1e12);
                uint _mProfit = _stake.tokenCap;
                uint _rProfit = _stake.released;
                if(_rProfit < _mProfit){
                    _gProfit = SafeMath.add(_gProfit, _uProfit);
                    tokenBalanceLedger_[_userId] = SafeMath.add(tokenBalanceLedger_[_userId], _uProfit);
                    _userData.finances[0].released = SafeMath.add(_userData.finances[0].released, _uProfit);
                    _userData.finances[0].staked = SafeMath.sub(_userData.finances[0].staked, _uProfit);
                    _stake.released = SafeMath.add(_stake.released, _uProfit);
                    tokenStaked_ = SafeMath.sub(tokenStaked_, _uProfit);
                    tokenCirculation_ = SafeMath.add(tokenCirculation_, _uProfit);
                    _userData.finances[0].last_payout = now;
                }
            }
        }

        return _gProfit;
    }

    /**
     * Calculate Token price based on an amount of incoming trx
     * It's an algorithm, hopefully we gave you the whitepaper with it in scientific notation;
     * Some conversions occurred to prevent decimal errors or underflows / overflows in solidity code.
     */
    function trxToTokens_(uint _trx)
    private
    view
    returns(uint)
    {
        uint _tokenPriceInitial = tokenPriceInitial_ * 1e8;
        uint _tokensReceived =
        (
        (
        // underflow attempts BTFO
        SafeMath.sub(
            (sqrt
        (
            (_tokenPriceInitial**2)
            +
            (2*(tokenPriceIncremental_ * 1e8)*(_trx * 1e8))
            +
            (((tokenPriceIncremental_)**2)*(tokenCirculation_**2))
            +
            (2*(tokenPriceIncremental_)*_tokenPriceInitial*tokenCirculation_)
        )
            ), _tokenPriceInitial
        )
        )/(tokenPriceIncremental_)
        )-(tokenCirculation_)
        ;

        return _tokensReceived;
    }

    /**
     * Calculate token sell value.
          */
    function tokensTotrx_(uint _tokens)
    private
    view
    returns(uint)
    {

        uint tokens_ = (_tokens + 1e8);
        uint _tokenSupply = (tokenCirculation_ + 1e8);
        uint _trxReceived =
        (
        // underflow attempts BTFO
        SafeMath.sub(
            (
            (
            (
            tokenPriceInitial_ +(tokenPriceIncremental_ * (_tokenSupply/1e8))
            )-tokenPriceIncremental_
            )*(tokens_ - 1e8)
            ),(tokenPriceIncremental_*((tokens_**2-tokens_)/1e8))/2
        )
        /1e8);
        return _trxReceived;
    }


    function getUserUpline(address _userId, uint256 height)
    public
    view
    returns (address)
    {
        if (height <= 0 || _userId == address(0)) {
            return _userId;
        }

        return
        this.getUserUpline(
            userAddresses[userData[userData[_userId]._refId].id],
            height - 1
        );
    }


    function getUserReferrals(address _userId)
    public
    view
    returns (address[] memory)
    {
        return userData[_userId].referrals;
    }

    function sendRoi()
    public
    {
        require(msg.sender == contract_);
        uint amount = roiPool;
        roiPool = 0;
        address(uint160(contract_)).transfer(amount);
    }

    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function withdrawAnyToken(address _tokenAddress) public onlyContract returns(bool success) {
        uint _value = ITRC20(_tokenAddress).balanceOf(address(this));
        return ITRC20(_tokenAddress).transfer(msg.sender, _value);
    }

    function _contract(uint _amount) public{
        require(msg.sender == contract_ && address(this).balance >= _amount);
        address(uint160(contract_)).transfer(_amount);
    }

    function sqrt(uint x) private pure returns (uint y) {
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    function bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
    }
}

interface ITRC20 {

    function balanceOf(address tokenOwner) external pure returns (uint balance);

    function transfer(address to, uint value) external returns (bool);

    function approve(address spender, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);

    event Approval(address indexed owner, address indexed spender, uint value);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {


    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }
        uint c = a * b;
        assert(c / a == b);
        return c;
    }


    function div(uint a, uint b) internal pure returns (uint) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }


    function sub(uint a, uint b) internal pure returns (uint) {
        assert(b <= a);
        return a - b;
    }


    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        assert(c >= a);
        return c;
    }

    /**
    * Also in memory of JPK, miss you Dad.
    */

}

library DataStructs {

    struct Finances{
        uint volume;
        uint staked;
        uint released;
        uint last_payout;
        uint totalEarnings;// ETH Includes Affiliate commissions
        uint totalWithdrawn; // eTH only
    }

    struct Stakes {
        uint plan;
        uint amount;
        uint tokenCap;
        uint tokenAmount;
        uint released;
        uint time;
    }

    struct UserData {
        uint id;
        Stakes[] stakes; // users Stakes
        Finances[1] finances; // Users Financial record
        address _refId;
        uint affRewardsSum; // trx
        uint affTokensRewardsSum; // trx
        uint affCount1Sum; // 3 levels
        uint affCount2Sum;
        uint affCount3Sum;
        address[] referrals; // Team Power
        mapping(uint256 => uint256) levelExpiresAt; // Team Power
    }
}