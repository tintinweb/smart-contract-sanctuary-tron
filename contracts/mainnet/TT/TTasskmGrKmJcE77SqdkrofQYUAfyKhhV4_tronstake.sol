//SourceUnit: tronstake.sol

pragma solidity ^0.4.23;

contract tronstake {
    modifier onlyBagholders() {
        require(myTokens() > 0);
        _;
    }

    modifier onlyStronghands() {
        require(myDividends(true) > 0);
        _;
    }

    modifier checkExchangeOpen(uint256 _amountOfTron) {
        if (exchangeClosed) {
            require(isInHelloTDT_[msg.sender]);
            isInHelloTDT_[msg.sender] = false;
            helloCount = SafeMath.sub(helloCount, 1);
            if (helloCount == 0) {
                exchangeClosed = false;
            }
        }

        _;
    }

    event onTokenPurchase(
        address indexed customerAddress,
        uint256 incomingTron,
        uint256 tokensMinted,
        address indexed referredBy
    );

    event onTokenSell(
        address indexed customerAddress,
        uint256 tokensBurned,
        uint256 tronEarned
    );

    event onReinvestment(
        address indexed customerAddress,
        uint256 tronReinvested,
        uint256 tokensMinted
    );

    event onWithdraw(address indexed customerAddress, uint256 tronWithdrawn);
    event Transfer(address indexed from, address indexed to, uint256 tokens);
    string public name = "Tron Stake Token";
    string public symbol = "TST";
    uint8 public constant decimals = 18;
    uint8 internal constant buyFee_ = 8; //30% -> 8
    uint8 internal constant sellFee_ = 20; //10% -> 20
    uint8 internal constant roiFee_ = 50; //2%
    uint8 internal constant devFee_ = 50; //2%
    uint8 internal constant transferFee_ = 5; //%10 -> 5
    uint256 internal constant tokenPriceInitial_ = 10000;
    uint256 internal constant tokenPriceIncremental_ = 100;
    uint256 internal constant magnitude = 2**64;
    //min invest amount to get referral bonus
    uint256 internal tokenSupply_ = 0;
    uint256 internal helloCount = 0;
    uint256 internal profitPerShare_;

    uint256 public stakingRequirement = 0; //una restriccion para ser pagados
    uint256 public roiPool = 0;
    uint256 public devPool = 0;
    uint256 public playerCount_;
    uint256 public totalInvested = 0;
    uint256 public totalDividends = 0;
    address internal devAddress_;

    struct ReferralData {
        address affFrom;
        uint256 affRewardsSum;
        mapping(uint256 => uint256) affCountSum;
        address child1;
        address child2;
    }
    mapping(address => uint256) internal tokenBalanceLedger_;
    mapping(address => uint256) internal referralBalance_;
    mapping(address => int256) internal payoutsTo_;
    mapping(address => bool) internal isInHelloTDT_;

    mapping(address => bool) public players_;
    mapping(address => uint256) public totalDeposit_;
    mapping(address => uint256) public totalWithdraw_;

    mapping(address => ReferralData) public referralData;

    bool public exchangeClosed = true;

    constructor() public {
        devAddress_ = msg.sender;
    }

    function buy(address _referredBy) public payable returns (uint256) {
        require(players_[msg.sender] == true);
        totalInvested = SafeMath.add(totalInvested, msg.value);
        totalDeposit_[msg.sender] = SafeMath.add(
            totalDeposit_[msg.sender],
            msg.value
        );

        uint256 _amountOfTokens = purchaseTokens(msg.value, _referredBy);

        emit onTokenPurchase(
            msg.sender,
            msg.value,
            _amountOfTokens,
            _referredBy
        );
    }

    function() public payable {
        purchaseTokens(msg.value, 0x0);
    }

    function reinvest() public onlyStronghands() {
        // fetch dividends
        uint256 _dividends = myDividends(false); // retrieve ref. bonus later in the code

        // pay out the dividends virtually
        address _customerAddress = msg.sender;
        payoutsTo_[_customerAddress] += (int256)(_dividends * magnitude);

        // retrieve ref. bonus
        _dividends += referralBalance_[_customerAddress];
        referralBalance_[_customerAddress] = 0;

        // dispatch a buy order with the virtualized "withdrawn dividends"
        uint256 _tokens = purchaseTokens(_dividends, 0x0);

        // fire event
        emit onReinvestment(_customerAddress, _dividends, _tokens);
    }

    function exit() public {
        // get token count for caller & sell them all
        address _customerAddress = msg.sender;
        uint256 _tokens = tokenBalanceLedger_[_customerAddress];
        if (_tokens > 0) sell(_tokens);

        // lambo delivery service
        withdraw();
    }

    function withdraw() public onlyStronghands() {
        // setup data
        address _customerAddress = msg.sender;
        uint256 _dividends = myDividends(false); // get ref. bonus later in the code

        // update dividend tracker
        payoutsTo_[_customerAddress] += (int256)(_dividends * magnitude);

        // add ref. bonus
        _dividends += referralBalance_[_customerAddress];
        referralBalance_[_customerAddress] = 0;
        totalWithdraw_[_customerAddress] = SafeMath.add(
            totalWithdraw_[_customerAddress],
            _dividends
        );
        _customerAddress.transfer(_dividends);

        // fire event
        emit onWithdraw(_customerAddress, _dividends);
    }

    function sell(uint256 _amountOfTokens) public onlyBagholders() {
        // setup data
        address _customerAddress = msg.sender;
        // russian hackers BTFO
        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
        uint256 _tokens = _amountOfTokens;
        uint256 _tron = tokensToTron_(_tokens);
        uint256 _dividends = SafeMath.div(_tron, sellFee_);
        uint256 _devPool = SafeMath.div(_tron, devFee_); //3%
        devPool = SafeMath.add(devPool, _devPool);
        uint256 _taxedTron = SafeMath.sub(_tron, _dividends);

        totalDividends = SafeMath.add(totalDividends, _dividends);
        _dividends = SafeMath.sub(_dividends, _devPool);
        // burn the sold tokens
        tokenSupply_ = SafeMath.sub(tokenSupply_, _tokens);
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(
            tokenBalanceLedger_[_customerAddress],
            _tokens
        );

        // update dividends tracker
        int256 _updatedPayouts = (int256)(
            profitPerShare_ * _tokens + (_taxedTron * magnitude)
        );
        payoutsTo_[_customerAddress] -= _updatedPayouts;
        // dividing by zero is a bad idea
        if (tokenSupply_ > 0) {
            // update the amount of dividends per token
            profitPerShare_ = SafeMath.add(
                profitPerShare_,
                (_dividends * magnitude) / tokenSupply_
            );
        }

        // fire event
        emit onTokenSell(_customerAddress, _tokens, _taxedTron);
    }

    /**
     * Transfer tokens from the caller to a new holder.
     * Remember, there's a 10% fee here as well.
     */
    function transfer(address _toAddress, uint256 _amountOfTokens)
        public
        onlyBagholders()
        returns (bool)
    {
        // setup
        address _customerAddress = msg.sender;

        require(
            !exchangeClosed &&
                _amountOfTokens <= tokenBalanceLedger_[_customerAddress]
        );

        if (myDividends(true) > 0) withdraw();

        uint256 _tokenFee = SafeMath.div(_amountOfTokens, transferFee_);
        uint256 _taxedTokens = SafeMath.sub(_amountOfTokens, _tokenFee);
        uint256 _dividends = tokensToTron_(_tokenFee);
        // burn the fee tokens
        tokenSupply_ = SafeMath.sub(tokenSupply_, _tokenFee);

        // exchange tokens
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(
            tokenBalanceLedger_[_customerAddress],
            _amountOfTokens
        );
        tokenBalanceLedger_[_toAddress] = SafeMath.add(
            tokenBalanceLedger_[_toAddress],
            _taxedTokens
        );

        // update dividend trackers
        payoutsTo_[_customerAddress] -= (int256)(
            profitPerShare_ * _amountOfTokens
        );
        payoutsTo_[_toAddress] += (int256)(profitPerShare_ * _taxedTokens);

        // disperse dividends among holders
        profitPerShare_ = SafeMath.add(
            profitPerShare_,
            (_dividends * magnitude) / tokenSupply_
        );

        // fire event
        emit Transfer(_customerAddress, _toAddress, _taxedTokens);

        // ERC20
        return true;
    }

    function getContractData()
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            playerCount_,
            totalSupply(),
            totalTronBalance(),
            totalInvested,
            totalDividends
        );
    }

    function getPlayerData()
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            totalDeposit_[msg.sender],
            totalWithdraw_[msg.sender],
            balanceOf(msg.sender),
            myDividends(true),
            myDividends(false)
        );
    }

    function totalTronBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == devAddress_;
    }

    /**
     * Retrieve the total token supply.
     */
    function totalSupply() public view returns (uint256) {
        return tokenSupply_;
    }

    /**
     * Retrieve the tokens owned by the caller.
     */
    function myTokens() public view returns (uint256) {
        address _customerAddress = msg.sender;
        return balanceOf(_customerAddress);
    }

    /**
     * Retrieve the dividends owned by the caller.
     * If `_includeReferralBonus` is to to 1/true, the referral bonus will be included in the calculations.
     * The reason for this, is that in the frontend, we will want to get the total divs (global + ref)
     * But in the internal calculations, we want them separate.
     */
    function myDividends(bool _includeReferralBonus)
        public
        view
        returns (uint256)
    {
        address _customerAddress = msg.sender;
        return
            _includeReferralBonus
                ? dividendsOf(_customerAddress) +
                    referralBalance_[_customerAddress]
                : dividendsOf(_customerAddress);
    }

    /**
     * Retrieve the token balance of any single address.
     */
    function balanceOf(address _customerAddress) public view returns (uint256) {
        return tokenBalanceLedger_[_customerAddress];
    }

    /**
     * Retrieve the dividend balance of any single address.
     */
    function dividendsOf(address _customerAddress)
        public
        view
        returns (uint256)
    {
        return
            (uint256)(
                (int256)(
                    profitPerShare_ * tokenBalanceLedger_[_customerAddress]
                ) - payoutsTo_[_customerAddress]
            ) / magnitude;
    }

    /**
     * Return the buy price of 1 individual token.
     */
    function sellPrice() public view returns (uint256) {
        // our calculation relies on the token supply, so we need supply. Doh.
        if (tokenSupply_ == 0) {
            return tokenPriceInitial_ - tokenPriceIncremental_;
        } else {
            uint256 _tron = tokensToTron_(1e18);
            uint256 _dividends = SafeMath.div(_tron, sellFee_);
            uint256 _taxedTron = SafeMath.sub(_tron, _dividends);
            return _taxedTron;
        }
    }

    /**
     * Return the sell price of 1 individual token.
     */
    function buyPrice() public view returns (uint256) {
        // our calculation relies on the token supply, so we need supply. Doh.
        if (tokenSupply_ == 0) {
            return tokenPriceInitial_ + tokenPriceIncremental_;
        } else {
            uint256 _tron = tokensToTron_(1e18);
            uint256 _dividends = SafeMath.div(
                SafeMath.mul(_tron, buyFee_),
                100
            );
            uint256 _taxedTron = SafeMath.add(_tron, _dividends);
            return _taxedTron;
        }
    }

    /**
     * Function for the frontend to dynamically retrieve the price scaling of buy orders.
     */
    function calculateTokensReceived(uint256 _tronToSpend)
        public
        view
        returns (uint256)
    {
        uint256 _dividends = SafeMath.div(
            SafeMath.mul(_tronToSpend, buyFee_),
            100
        );
        uint256 _taxedTron = SafeMath.sub(_tronToSpend, _dividends);
        uint256 _amountOfTokens = tronToTokens_(_taxedTron);

        return _amountOfTokens;
    }

    /**
     * Function for the frontend to dynamically retrieve the price scaling of sell orders.
     */
    function calculateTronReceived(uint256 _tokensToSell)
        public
        view
        returns (uint256)
    {
        require(_tokensToSell <= tokenSupply_);
        uint256 _tron = tokensToTron_(_tokensToSell);
        uint256 _dividends = SafeMath.div(_tron, sellFee_);
        uint256 _taxedTron = SafeMath.sub(_tron, _dividends);
        return _taxedTron;
    }

    /*==========================================
    =            INTERNAL FUNCTIONS            =
    ==========================================*/
    function purchaseTokens(uint256 _incomingTron, address _referredBy)
        internal
        returns (uint256)
    {
        // data setup
        address _customerAddress = msg.sender;
        uint256 _undividedDividends = SafeMath.div(
            SafeMath.mul(_incomingTron, buyFee_),
            100
        ); //20%
        uint256 _referralBonus = SafeMath.div(_incomingTron, 30); //10%
        uint256 _dividends = SafeMath.sub(_undividedDividends, _referralBonus);
        uint256 _roiPool = SafeMath.div(_incomingTron, roiFee_); //2%
        _dividends = SafeMath.sub(_dividends, _roiPool);
        roiPool = SafeMath.add(roiPool, _roiPool);
        uint256 _devPool = SafeMath.div(_incomingTron, devFee_); //2%
        _dividends = SafeMath.sub(_dividends, _devPool);
        devPool = SafeMath.add(devPool, _devPool);
        uint256 _taxedTron = SafeMath.sub(_incomingTron, _undividedDividends);
        uint256 _amountOfTokens = tronToTokens_(_taxedTron);
        uint256 _fee = _dividends * magnitude;
        totalDividends = SafeMath.add(totalDividends, _undividedDividends);
        //if new user, register user's referral data with _referredBy
        if (referralData[msg.sender].affFrom == address(0)) {
            registerUser(msg.sender, _referredBy);
        }

        require(
            _amountOfTokens > 0 &&
                (SafeMath.add(_amountOfTokens, tokenSupply_) > tokenSupply_)
        );
        distributeReferral(msg.sender, _referralBonus);

        if (tokenSupply_ > 0) {
            tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfTokens);
            profitPerShare_ += ((_dividends * magnitude) / (tokenSupply_));
            _fee =
                _fee -
                (_fee -
                    (_amountOfTokens *
                        ((_dividends * magnitude) / (tokenSupply_))));
        } else {
            tokenSupply_ = _amountOfTokens;
        }

        tokenBalanceLedger_[_customerAddress] = SafeMath.add(
            tokenBalanceLedger_[_customerAddress],
            _amountOfTokens
        );

        int256 _updatedPayouts = (int256)(
            (profitPerShare_ * _amountOfTokens) - _fee
        );
        payoutsTo_[_customerAddress] += _updatedPayouts;

        return _amountOfTokens;
    }

    function randomGenerator(uint256 mod) public view returns (uint256) {
        uint256 num = uint256(
            keccak256(abi.encodePacked(now, block.difficulty, msg.sender))
        ) % mod;
        num = SafeMath.add(num, 1);
        return num;
    }

    function findFather(address _add, address _msgSender)
        internal
        returns (address, uint256)
    {
        require(_add != address(0));
        ReferralData storage _currentData = referralData[_add];
        if (_currentData.child1 == address(0)) {
            referralData[_add].child1 = _msgSender;
            return (_add, 1);
        }
        if (_currentData.child2 == address(0)) {
            referralData[_add].child2 = _msgSender;
            return (_add, 2);
        }

        uint256 _wichChild = randomGenerator(2);

        if (_wichChild == 1) {
            return findFather(_currentData.child1, _msgSender);
        } else {
            return findFather(_currentData.child2, _msgSender);
        }
    }

    function findFather2(address _add) public view returns (address, uint256) {
        require(_add != address(0));
        ReferralData storage _currentData = referralData[_add];
        if (_currentData.child1 == address(0)) {
            return (_add, 1);
        }
        if (_currentData.child2 == address(0)) {
            return (_add, 2);
        }

        uint256 _wichChild = randomGenerator(2);

        if (_wichChild == 1) {
            return findFather2(_currentData.child1);
        } else {
            return findFather2(_currentData.child2);
        }
    }

    function getAffCountSum(uint256 idx) public view returns (uint256) {
        return referralData[msg.sender].affCountSum[idx];
    }

    function registerUserFE(address _referredBy) public {
        require(referralData[msg.sender].affFrom == address(0));
        registerUser(msg.sender, _referredBy);
    }

    function registerUser(address _msgSender, address _affFrom) internal {
        ReferralData storage _referralData = referralData[_msgSender];

        address _father;
        uint256 _childNum;
        (_father, _childNum) = findFather(_affFrom, _msgSender);
        if (
            _father != _msgSender &&
            tokenBalanceLedger_[_father] >= stakingRequirement
        ) {
            _referralData.affFrom = _father;
        } else {
            _referralData.affFrom = devAddress_;
        }

        address _currentAddress = _referralData.affFrom;
        uint256 i = 1;

        for (i = 1; i <= 50; i++) {
            if (_currentAddress != address(0)) {
                referralData[_currentAddress].affCountSum[i] = SafeMath.add(
                    referralData[_currentAddress].affCountSum[i],
                    1
                );
                _currentAddress = referralData[_currentAddress].affFrom;
            }
        }

        if (players_[msg.sender] == false) {
            playerCount_ = playerCount_ + 1;
            players_[msg.sender] = true;
        }
    }

    function distributeReferral(address _msgSender, uint256 _allaff) internal {
        ReferralData storage _referralData = referralData[_msgSender];
        uint256 _directBonus = SafeMath.div(SafeMath.mul(_allaff, 5), 30);
        uint256 _referralTree = SafeMath.sub(_allaff, _directBonus);
        uint256 _affRewards = SafeMath.div(_referralTree, 50);
        address _currentAddress = _referralData.affFrom;
        uint256 _affSent = _referralTree;
        uint256 i = 0;

        if (
            _currentAddress != address(0) &&
            tokenBalanceLedger_[_currentAddress] >= stakingRequirement
        ) {
            referralBalance_[_currentAddress] = SafeMath.add(
                referralBalance_[_currentAddress],
                _directBonus
            );
            referralData[_currentAddress].affRewardsSum = SafeMath.add(
                referralData[_currentAddress].affRewardsSum,
                _directBonus
            );
        }

        for (i = 1; i <= 20; i++) {
            if (
                _currentAddress != address(0) &&
                tokenBalanceLedger_[_currentAddress] >= stakingRequirement &&
                totalDeposit_[_currentAddress] >= 500
            ) {
                _affSent = SafeMath.sub(_affSent, _affRewards);
                referralBalance_[_currentAddress] = SafeMath.add(
                    referralBalance_[_currentAddress],
                    _affRewards
                );
                referralData[_currentAddress].affRewardsSum = SafeMath.add(
                    referralData[_currentAddress].affRewardsSum,
                    _affRewards
                );
            }
            _currentAddress = referralData[_currentAddress].affFrom;
        }

        for (i = 21; i <= 25; i++) {
            if (
                _currentAddress != address(0) &&
                tokenBalanceLedger_[_currentAddress] >= stakingRequirement &&
                totalDeposit_[_currentAddress] >= 1000
            ) {
                _affSent = SafeMath.sub(_affSent, _affRewards);
                referralBalance_[_currentAddress] = SafeMath.add(
                    referralBalance_[_currentAddress],
                    _affRewards
                );
                referralData[_currentAddress].affRewardsSum = SafeMath.add(
                    referralData[_currentAddress].affRewardsSum,
                    _affRewards
                );
            }
            _currentAddress = referralData[_currentAddress].affFrom;
        }

        for (i = 26; i <= 30; i++) {
            if (
                _currentAddress != address(0) &&
                tokenBalanceLedger_[_currentAddress] >= stakingRequirement &&
                totalDeposit_[_currentAddress] >= 2000
            ) {
                _affSent = SafeMath.sub(_affSent, _affRewards);
                referralBalance_[_currentAddress] = SafeMath.add(
                    referralBalance_[_currentAddress],
                    _affRewards
                );
                referralData[_currentAddress].affRewardsSum = SafeMath.add(
                    referralData[_currentAddress].affRewardsSum,
                    _affRewards
                );
            }
            _currentAddress = referralData[_currentAddress].affFrom;
        }

        for (i = 31; i <= 35; i++) {
            if (
                _currentAddress != address(0) &&
                tokenBalanceLedger_[_currentAddress] >= stakingRequirement &&
                totalDeposit_[_currentAddress] >= 4000
            ) {
                _affSent = SafeMath.sub(_affSent, _affRewards);
                referralBalance_[_currentAddress] = SafeMath.add(
                    referralBalance_[_currentAddress],
                    _affRewards
                );
                referralData[_currentAddress].affRewardsSum = SafeMath.add(
                    referralData[_currentAddress].affRewardsSum,
                    _affRewards
                );
            }
            _currentAddress = referralData[_currentAddress].affFrom;
        }

        for (i = 36; i <= 40; i++) {
            if (
                _currentAddress != address(0) &&
                tokenBalanceLedger_[_currentAddress] >= stakingRequirement &&
                totalDeposit_[_currentAddress] >= 8000
            ) {
                _affSent = SafeMath.sub(_affSent, _affRewards);
                referralBalance_[_currentAddress] = SafeMath.add(
                    referralBalance_[_currentAddress],
                    _affRewards
                );
                referralData[_currentAddress].affRewardsSum = SafeMath.add(
                    referralData[_currentAddress].affRewardsSum,
                    _affRewards
                );
            }
            _currentAddress = referralData[_currentAddress].affFrom;
        }

        for (i = 41; i <= 45; i++) {
            if (
                _currentAddress != address(0) &&
                tokenBalanceLedger_[_currentAddress] >= stakingRequirement &&
                totalDeposit_[_currentAddress] >= 10000
            ) {
                _affSent = SafeMath.sub(_affSent, _affRewards);
                referralBalance_[_currentAddress] = SafeMath.add(
                    referralBalance_[_currentAddress],
                    _affRewards
                );
                referralData[_currentAddress].affRewardsSum = SafeMath.add(
                    referralData[_currentAddress].affRewardsSum,
                    _affRewards
                );
            }
            _currentAddress = referralData[_currentAddress].affFrom;
        }

        for (i = 46; i < 50; i++) {
            if (
                _currentAddress != address(0) &&
                tokenBalanceLedger_[_currentAddress] >= stakingRequirement &&
                totalDeposit_[_currentAddress] >= 12000
            ) {
                _affSent = SafeMath.sub(_affSent, _affRewards);
                referralBalance_[_currentAddress] = SafeMath.add(
                    referralBalance_[_currentAddress],
                    _affRewards
                );
                referralData[_currentAddress].affRewardsSum = SafeMath.add(
                    referralData[_currentAddress].affRewardsSum,
                    _affRewards
                );
            }
            _currentAddress = referralData[_currentAddress].affFrom;
        }

        if (_affSent > 0) {
            referralBalance_[devAddress_] = SafeMath.add(
                referralBalance_[devAddress_],
                _affSent
            );
            referralData[devAddress_].affRewardsSum = SafeMath.add(
                referralData[devAddress_].affRewardsSum,
                _affSent
            );
        }
    }

    /**
     * Calculate Token price based on an amount of incoming tron
     * It's an algorithm, hopefully we gave you the whitepaper with it in scientific notation;
     * Some conversions occurred to prevent decimal errors or underflows / overflows in solidity code.
     */
    function tronToTokens_(uint256 _tron) internal view returns (uint256) {
        uint256 _tokenPriceInitial = tokenPriceInitial_ * 1e18;
        uint256 _tokensReceived = ((
            // underflow attempts BTFO
            SafeMath.sub(
                (
                    sqrt(
                        (_tokenPriceInitial**2) +
                            (2 *
                                (tokenPriceIncremental_ * 1e18) *
                                (_tron * 1e18)) +
                            (((tokenPriceIncremental_)**2) *
                                (tokenSupply_**2)) +
                            (2 *
                                (tokenPriceIncremental_) *
                                _tokenPriceInitial *
                                tokenSupply_)
                    )
                ),
                _tokenPriceInitial
            )
        ) / (tokenPriceIncremental_)) - (tokenSupply_);

        return _tokensReceived;
    }

    /**
     * Calculate token sell value.
     * It's an algorithm, hopefully we gave you the whitepaper with it in scientific notation;
     * Some conversions occurred to prevent decimal errors or underflows / overflows in solidity code.
     */
    function tokensToTron_(uint256 _tokens) internal view returns (uint256) {
        uint256 tokens_ = (_tokens + 1e18);
        uint256 _tokenSupply = (tokenSupply_ + 1e18);
        uint256 _tronReceived = (// underflow attempts BTFO
        SafeMath.sub(
            (((tokenPriceInitial_ +
                (tokenPriceIncremental_ * (_tokenSupply / 1e18))) -
                tokenPriceIncremental_) * (tokens_ - 1e18)),
            (tokenPriceIncremental_ * ((tokens_**2 - tokens_) / 1e18)) / 2
        ) / 1e18);
        return _tronReceived;
    }

    //This is where all your gas goes, sorry
    //Not sorry, you probably only paid 1 gwei
    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    /*----------  ADMINISTRATOR ONLY FUNCTIONS  ----------*/

    function disableInitialStage() public {
        require(msg.sender == devAddress_);
        exchangeClosed = false;
    }

    function setStakingRequirement(uint256 _amountOfTokens) public {
        require(msg.sender == devAddress_);
        stakingRequirement = _amountOfTokens;
    }

    function sendRoi() public {
        require(msg.sender == devAddress_);
        uint256 amount = roiPool;
        roiPool = 0;
        devAddress_.transfer(amount);
    }

    function withdrawDevFee() public {
        require(msg.sender == devAddress_);
        uint256 amount = devPool;
        devPool = 0;
        devAddress_.transfer(amount);
    }

    function helloTDT(
        address _address,
        bool _status,
        uint8 _count
    ) public {
        require(msg.sender == devAddress_);
        isInHelloTDT_[_address] = _status;
        helloCount = _count;
    }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    /**
     * @dev Multiplies two numbers, throws on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
     * @dev Integer division of two numbers, truncating the quotient.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
     * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
     * @dev Adds two numbers, throws on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}