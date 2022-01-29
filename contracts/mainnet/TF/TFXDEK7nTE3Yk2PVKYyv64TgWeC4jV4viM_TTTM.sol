//SourceUnit: updatedTTTM.sol

/**
 *Submitted for verification at Etherscan.io on 2018-04-10
*/

pragma solidity ^0.4.20;
contract Divide {



  function percent(uint numerator, uint denominator, uint precision) internal 



  pure returns(uint quotient) {



         // caution, check safe-to-multiply here

        uint _numerator  = numerator * 10 ** (precision+1);

        // with rounding of last digit

        uint _quotient =  ((_numerator / denominator) + 5) / 10;

        return ( _quotient);

  }



}
contract Percentage is Divide{



    uint256 internal baseValue = 100;



    function onePercent(uint256 _value) internal view returns (uint256)  {

        uint256 roundValue = SafeMath.ceil(_value, baseValue);

        uint256 Percent = SafeMath.div(SafeMath.mul(roundValue, baseValue), 10000);

        return  Percent;

    }

}
contract TTTM is Percentage {
    /*=================================
    =            MODIFIERS            =
    =================================*/
    // only people with tokens
    modifier onlybelievers () {
        require(myTokens() > 0);
        _;
    }
    
    // only people with profits
    modifier onlyhodler() {
        require(myDividends(true) > 0);
        _;
    }
    
    // administrators can:
    // -> change the name of the contract
    // -> change the name of the token
    // -> change the PoS difficulty 
    // they CANNOT:
    // -> take funds
    // -> disable withdrawals
    // -> kill the contract
    // -> change the price of tokens
    modifier onlyAdministrator(){
        address _customerAddress = msg.sender;
        require(administrators[bytes32(uint256(_customerAddress) << 96)]);
        _;
    }
    
    
    modifier antiEarlyWhale(uint256 _amountOfEthereum){
        address _customerAddress = msg.sender;
        
      
        if( onlyAmbassadors && ((totalEthereumBalance() - _amountOfEthereum) <= ambassadorQuota_ )){
            require(
                // is the customer in the ambassador list?
                ambassadors_[_customerAddress] == true &&
                
                // does the customer purchase exceed the max ambassador quota?
                (ambassadorAccumulatedQuota_[_customerAddress] + _amountOfEthereum) <= ambassadorMaxPurchase_
                
            );
            
            // updated the accumulated quota    
            ambassadorAccumulatedQuota_[_customerAddress] = SafeMath.add(ambassadorAccumulatedQuota_[_customerAddress], _amountOfEthereum);
        
            // execute
            _;
        } else {
            // in case the ether count drops low, the ambassador phase won't reinitiate
            onlyAmbassadors = false;
            _;    
        }
        
    }
    
    
    /*==============================
    =            EVENTS            =
    ==============================*/
    event Buy(
        string nature,
        address indexed _buyer,
        uint256 _tokens,
        uint256 _amounts
    );
    
    event Sell(
        string nature,
        address indexed _seller,
        uint256 _tokens,
        uint256 _amounts
    );
    
    event Withdraw(
        string nature,
        address indexed _drawer,
        uint256 _amountWithDrawn
    );
    
    // ERC20
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 tokens
    );
    
    
    /*=====================================
    =            CONFIGURABLES            =
    =====================================*/
    string public name = "Tron To The Moon";
    string public symbol = "TTTM";
    uint8 constant public decimals = 6;
    uint8 constant internal dividendFee_ = 10;
    uint256 constant internal magnitude = 2**64;
    uint256 startTime;
    address public owner;
    uint256 initialPrice=20000;
    // proof of stake (defaults at 1 token)
    uint256 public stakingRequirement = 1e6;
    // ambassador program
    mapping(address => bool) internal ambassadors_;
    uint256 constant internal ambassadorMaxPurchase_ = 10**6;
    uint256 constant internal ambassadorQuota_ = 10**6;
    
    
    struct Users{



        uint256 totalWithdrawn;

        uint256 totalTRXDeposited;
        
        address _upline;


    }

    mapping(address=>Users)public users;
    
   /*================================
    =            DATASETS            =
    ================================*/
    // amount of shares for each address (scaled number)
    mapping(address => uint256) internal tokenBalanceLedger_;
    mapping(address => uint256) internal referralBalance_;
    mapping(address => int256) internal payoutsTo_;
    mapping(address => uint256) internal ambassadorAccumulatedQuota_;
    uint256 internal tokenSupply_ = 0;
    uint256 internal profitPerShare_;
    uint256 internal marketCapValue;
    uint256 ownerWithdrawl;
    // administrator list (see above on what they can do)
    mapping(bytes32 => bool) public administrators;
    
    
    bool public onlyAmbassadors = false;
    


    /*=======================================
    =            PUBLIC FUNCTIONS            =
    =======================================*/
    /*
    * -- APPLICATION ENTRY POINTS --  
    */
    constructor(address _admin)
        public
    {
        // add administrators here
        administrators[bytes32(uint256(_admin) << 96)] = true;
						 
   
        ambassadors_[0x0000000000000000000000000000000000000000] = true;
        startTime=now;
        owner=msg.sender;
    }
    /**
     * Converts all incoming Ethereum to tokens for the caller, and passes down the referral address (if any)
     */
    function buyToken(address _referredBy)
        public
        payable
        returns(uint256)
    {
        purchaseTokens(msg.value, _referredBy);
    }
    
    
    function()
        payable
        public
    {
        purchaseTokens(msg.value, 0x0);
    }

    /**
     * Withdraws all of the callers earnings.
     */
    function withdraw()
        onlyhodler()
        public
    {
        // setup data
        address _customerAddress = msg.sender;
        uint256 _dividends = myDividends(false); // get ref. bonus later in the code
        
        // update dividend tracker
        payoutsTo_[_customerAddress] +=  (int256) (_dividends * magnitude);
        
        // add ref. bonus
        _dividends += referralBalance_[_customerAddress];
        referralBalance_[_customerAddress] = 0;
        
        // delivery service
        users[_customerAddress].totalWithdrawn+=_dividends;
        _customerAddress.transfer(_dividends);
        // fire event
        emit Withdraw("Withdraw",_customerAddress, _dividends);
    }
    
    /**
     * Liquifies tokens to ethereum.
     */
    function sellToken(uint256 _amountOfTokens)
        onlybelievers ()
        public
    {
      
        address _customerAddress = msg.sender;
       
        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
        uint256 _tokens = _amountOfTokens;
        uint256 _ethereum = tokensToTrx(_tokens);
        uint256 _dividends=SafeMath.mul(onePercent(_ethereum),8);
        uint256 refferalBonus=SafeMath.mul(onePercent(_ethereum),2);
        uint256 _taxedEthereum =calculateTrxReceived(_amountOfTokens);
        uint256 ownerDividend;
        ownerDividend=SafeMath.mul(onePercent(_dividends),5);
        _dividends=SafeMath.sub(_dividends,ownerDividend);
        //update refferalBonus
        referralBalance_[users[_customerAddress]._upline]+=refferalBonus;
        // burn the sold tokens
        tokenSupply_ = SafeMath.sub(tokenSupply_, _tokens);
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _tokens);
        
        // update dividends tracker
        int256 _updatedPayouts = (int256) (profitPerShare_ * _tokens + (_taxedEthereum * magnitude));
        payoutsTo_[_customerAddress] -= _updatedPayouts;       
        
        // dividing by zero is a bad idea
        if (tokenSupply_ > 0) {
            // update the amount of dividends per token
            profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);
        }
        
        marketCapValue-=_ethereum;
        owner.transfer(ownerDividend);
        // fire event
       emit  Sell("Sell",_customerAddress,_taxedEthereum,_tokens);
    }

    /**
     * Transfer tokens from the caller to a new holder.
     * Remember, there's a 10% fee here as well.
     */
    function transfer(address _toAddress, uint256 _amountOfTokens)
        onlybelievers ()
        public
        returns(bool)
    {
        // setup
        address _customerAddress = msg.sender;
        
        // make sure we have the requested tokens
     
        require(!onlyAmbassadors && _amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
        
        // withdraw all outstanding dividends first
        if(myDividends(true) > 0) withdraw();
        
        // liquify 10% of the tokens that are transfered
        // these are dispersed to shareholders
        uint256 _tokenFee = SafeMath.div(_amountOfTokens, dividendFee_);
        uint256 _taxedTokens = SafeMath.sub(_amountOfTokens, _tokenFee);
        uint256 _dividends = tokensToTrx(_tokenFee);
  
        // burn the fee tokens
        tokenSupply_ = SafeMath.sub(tokenSupply_, _tokenFee);

        // exchange tokens
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
        tokenBalanceLedger_[_toAddress] = SafeMath.add(tokenBalanceLedger_[_toAddress], _taxedTokens);
        
        // update dividend trackers
        payoutsTo_[_customerAddress] -= (int256) (profitPerShare_ * _amountOfTokens);
        payoutsTo_[_toAddress] += (int256) (profitPerShare_ * _taxedTokens);
        
        // disperse dividends among holders
        profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);
        
        // fire event
        emit Transfer(_customerAddress, _toAddress, _taxedTokens);
        
        // ERC20
        return true;
       
    }
    
    /*----------  ADMINISTRATOR ONLY FUNCTIONS  ----------*/
    /**
     * administrator can manually disable the ambassador phase.
     */
    function disableInitialStage()
        onlyAdministrator()
        public
    {
        onlyAmbassadors = false;
    }
    
   
    function setAdministrator(address _identifier, bool _status)
        onlyAdministrator()
        public
    {
        administrators[bytes32(uint256(_identifier) << 96)] = _status;
    }
    
   
    function setStakingRequirement(uint256 _amountOfTokens)
        onlyAdministrator()
        public
    {
        stakingRequirement = _amountOfTokens;
    }
    
    
    function setName(string _name)
        onlyAdministrator()
        public
    {
        name = _name;
    }
    
   
    function setSymbol(string _symbol)
        onlyAdministrator()
        public
    {
        symbol = _symbol;
    }

    
    /*----------  HELPERS AND CALCULATORS  ----------*/
    /**
     * Method to view the current Ethereum stored in the contract
     * Example: totalEthereumBalance()
     */
    function totalEthereumBalance()
        public
        view
        returns(uint)
    {
        return address(this).balance+ownerWithdrawl;
    }
    
    /**
     * Retrieve the total token supply.
     */
    function circulatingSupply()
        public
        view
        returns(uint256)
    {
        return tokenSupply_;
    }
    /**
     * Retrieve the tokens owned by the caller.
     */
    function myTokens()
        public
        view
        returns(uint256)
    {
        address _customerAddress = msg.sender;
        return balanceOf(_customerAddress);
    }
    
    /**
     * Retrieve the dividends owned by the caller.
       */ 
    function myDividends(bool _includeReferralBonus) 
        public 
        view 
        returns(uint256)
    {
        address _customerAddress = msg.sender;
        return _includeReferralBonus ? dividendsOf(_customerAddress) + referralBalance_[_customerAddress] : dividendsOf(_customerAddress);
    }
    
    /**
     * Retrieve the token balance of any single address.
     */
    function balanceOf(address _customerAddress)
        view
        public
        returns(uint256)
    {
        return tokenBalanceLedger_[_customerAddress];
    }
    
    /**
     * Retrieve the dividend balance of any single address.
     */
    function dividendsOf(address _customerAddress)
        view
        public
        returns(uint256)
    {
    return ((uint256) ((int256)(profitPerShare_ * tokenBalanceLedger_[_customerAddress]) - payoutsTo_[_customerAddress]) / magnitude);
    }
    
    /**
     * Return the buy price of 1 individual token.
     */
   
    function calculateTokensReceived(uint256 _ethereumToSpend) 
        public 
        view 
        returns(uint256)
    {
        uint256 _dividends = SafeMath.div(_ethereumToSpend, dividendFee_);
        uint256 _taxedEthereum = SafeMath.sub(_ethereumToSpend, _dividends);
        uint256 _amountOfTokens = trxToTokens_(_taxedEthereum);
        
        return _amountOfTokens;
    }
    
   
    function calculateTrxReceived(uint256 _tokensToSell) 
        public 
        view 
        returns(uint256)
    {
        require(_tokensToSell <= tokenSupply_);
        uint256 _ethereum = tokensToTrx(_tokensToSell);
        uint256 _dividends = SafeMath.div(_ethereum, dividendFee_);
        uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);
        return _taxedEthereum;
    }
    
    
    /*==========================================
    =            INTERNAL FUNCTIONS            =
    ==========================================*/
    function purchaseTokens(uint256 _incomingTrx, address _referredBy)
        antiEarlyWhale(_incomingTrx)
        internal
        returns(uint256)
    {
        // data setup
        address _customerAddress = msg.sender;
        uint256 _undividedDividends = SafeMath.div(_incomingTrx, dividendFee_);
        uint256 _referralBonus = SafeMath.div(_undividedDividends, 5);
        uint256 _dividends = SafeMath.sub(_undividedDividends, _referralBonus);
        uint256 _taxedEthereum = SafeMath.sub(_incomingTrx, _undividedDividends);
        uint256 _amountOfTokens = trxToTokens_(_taxedEthereum);
        uint256 _fee = _dividends * magnitude;
        uint256 ownerDividend;
      
        require(_amountOfTokens > 0 && (SafeMath.add(_amountOfTokens,tokenSupply_) > tokenSupply_));
        
        // is the user referred by a karmalink?
        if(
            // is this a referred purchase?
            _referredBy != 0x0000000000000000000000000000000000000000 &&

            // no cheating!
            _referredBy != _customerAddress &&
            
        
            tokenBalanceLedger_[_referredBy] >= stakingRequirement||
            _referredBy==owner
        ){
            //set Refferal in user struct
            users[_customerAddress]._upline=_referredBy;
            // wealth redistribution
            referralBalance_[_referredBy] = SafeMath.add(referralBalance_[_referredBy], _referralBonus);
            ownerDividend=SafeMath.mul(onePercent(_dividends),5);

        } else {
            // no ref purchase
            // add the referral bonus back to the global dividends cake
            ownerDividend=SafeMath.mul(onePercent(_dividends),5);
            _dividends = SafeMath.add(_dividends, _referralBonus);
            _fee = _dividends * magnitude;
        }
        _dividends=SafeMath.sub(_dividends,ownerDividend);
        // we can't give people infinite ethereum
        if(tokenSupply_ > 0){
            
            // add tokens to the pool
            tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfTokens);
 
            // take the amount of dividends gained through this transaction, and allocates them evenly to each shareholder
            profitPerShare_ += (_dividends * magnitude / (tokenSupply_));
            
            // calculate the amount of tokens the customer receives over his purchase 
            _fee = _fee - (_fee-(_amountOfTokens * (_dividends * magnitude / (tokenSupply_))));
        
        } else {
            // add tokens to the pool
            tokenSupply_ = _amountOfTokens;
        }
        
        // update circulating supply & the ledger address for the customer
        tokenBalanceLedger_[_customerAddress] = SafeMath.add(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
        
        payoutsTo_[_customerAddress] +=  (int256) ((profitPerShare_ * _amountOfTokens) - _fee);
        users[_customerAddress].totalTRXDeposited+=_incomingTrx;
        marketCapValue+=_taxedEthereum;
        owner.transfer(ownerDividend);
        // fire event
        emit Buy("Buy",_customerAddress, _amountOfTokens,_incomingTrx);
        return _amountOfTokens;
    }

    /**
     * Calculate Token price based on an amount of incoming ethereum
     * It's an algorithm, hopefully we gave you the whitepaper with it in scientific notation;
     * Some conversions occurred to prevent decimal errors or underflows / overflows in solidity code.
     */
     function buyPriceCalculation() internal view returns(uint){

        require(startTime != 0,"contract isn't deployed yet!");

        uint256 increment= ((now - startTime)/(1 days))*10;

        return increment;

       }
     function trxToTokens_(uint256 _trxvalue)
        internal
        view
        returns(uint256)
      {

       uint256 price= (buyPriceCalculation()+initialPrice);

       return (_trxvalue/price)*(1000000);
      }
    
     function marketCap()public view returns(uint256){

        // return (SafeMath.sub(totalEthereumBalance(),(onePercent(totalEthereumBalance())*10)));
        return marketCapValue;
      }
    /**
     * Calculate token sell value.
          */
      function sellPriceCalculation()internal view returns(uint256){
        if(tokenSupply_==0){

         return 0;   

        }else{
        require(tokenSupply_>0,"No token bought yet");

        uint256 marketCapValueOf=SafeMath.mul(marketCap(),10**12);

        uint256 price= SafeMath.div(marketCapValueOf,circulatingSupply());

        return price;  
        }
        

       }
     function TrxToTTTM()public view returns(uint256){

        return buyPriceCalculation()+initialPrice;

     }
     function TTTMtoTrx()public view returns(uint256){

       if(circulatingSupply()==0){

         return 0;   

        }

        else{

        return SafeMath.div(sellPriceCalculation(),10**6);  

        }  

     }
      function tokensToTrx(uint256 _tokens)
        internal
        view
        returns(uint256)
     {
 
        uint256 price=SafeMath.mul(_tokens,sellPriceCalculation());

        return SafeMath.div(price,10**12);  
     }
    
    
    
    function sqrt(uint x) internal pure returns (uint y) {
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

   
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

   
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

   
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
    function ceil(uint256 a, uint256 m) internal pure returns (uint256) {
        uint256 c = add(a,m);
        uint256 d = sub(c,1);
        return mul(div(d,m),m);
    }

/**
* Also in memory of JPK, miss you Dad.
*/
    
}