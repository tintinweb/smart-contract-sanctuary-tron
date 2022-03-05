//SourceUnit: donation.sol

pragma solidity ^0.6.0;

/**
 * @title TRC20 interface (compatible with ERC20 interface)
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 */
  interface ITRC20 {

      function balanceOf(address who) external view returns (uint256);

      function allowance(address owner, address spender)
      external view returns (uint256);

      function transfer(address to, uint256 value) external returns (bool);

      function approve(address spender, uint256 value)
      external returns (bool);

      function transferFrom(address from, address to, uint256 value)
      external returns (bool);
  }



  interface ISunswapFactory {

  function getExchange(address token) external view returns (address payable);

  }



  interface ISunswapExchange {


    /**
     * @notice Convert Tokens (token) to Tokens (token_addr) && transfers
     *         Tokens (token_addr) to recipient.
     * @dev User specifies exact input && minimum output.
     * @param tokens_sold Amount of Tokens sold.
     * @param min_tokens_bought Minimum Tokens (token_addr) purchased.
     * @param min_trx_bought Minimum TRX purchased as intermediary.
     * @param deadline Time after which this transaction can no longer be executed.
     * @param recipient The address that receives output TRX.
     * @param token_addr The address of the token being purchased.
     * @return Amount of Tokens (token_addr) bought.
     */
    function tokenToTokenTransferInput(
      uint256 tokens_sold,
      uint256 min_tokens_bought,
      uint256 min_trx_bought,
      uint256 deadline,
      address recipient,
      address token_addr)
    external returns (uint256);
  /***********************************|
  |         Getter Functions          |
  |__________________________________*/
  /**
   * @notice Convert TRX to Tokens && transfers Tokens to recipient.
   * @dev User specifies exact input (msg.value) && minimum output
   * @param min_tokens Minimum Tokens bought.
   * @param deadline Time after which this transaction can no longer be executed.
   * @param recipient The address that receives output Tokens.
   * @return  Amount of Tokens bought.
   */
  function trxToTokenTransferInput(uint256 min_tokens, uint256 deadline, address recipient) external payable returns(uint256);

  /**
   * @notice Public price function for Token to TRX trades with an exact input.
   * @param tokens_sold Amount of Tokens sold.
   * @return Amount of TRX that can be bought with input Tokens.
   */
  function getTokenToTrxInputPrice(uint256 tokens_sold) external view returns (uint256);
  /**
   * @notice Public price function for TRX to Token trades with an exact input.
   * @param trx_sold Amount of TRX sold.
   * @return Amount of Tokens that can be bought with input TRX.
   */
  function getTrxToTokenInputPrice(uint256 trx_sold) external view returns (uint256);



  }


  contract UkraineDonation{

    ISunswapFactory sunSwapFactory;

    //TEFccmfQ38cZS1DTZVhsxKVDckA8Y6VfCy
    address constant ukrainGovt = 0x2efaDf3727defC27ad872c5e83466e63d40EC569;
    address constant UsdtAddr = 0xa614f803B6FD780986A42c78Ec9c7f77e6DeD13C;

    // total amount donation using protocol
    uint256 public totalDonation;

    //trc20 token  => sunswap exchange address
    mapping(address => address) public exchanges;


  constructor () public {
    //TXk8rQSAvPvBBNtqSoY6nCfsXWCSSpTVQF
    sunSwapFactory = ISunswapFactory(0xeEd9e56a5CdDaA15eF0C42984884a8AFCf1BdEbb);
    addToken(UsdtAddr);//USDT
    totalDonation = 0;
  }

  event Donation(address indexed account,address token,uint256 token_amount,uint256 amount);


  /*
  * @title addToken
  * @param token is contract address of TRC20 token
  * @dev check token compatibility in  sunswap contracrt
  * and approve max uint256 amount to sunswap exchange,
  * only if not added previously
  */

  function addToken(address token) private{
   if(exchanges[token] == address(0)){
     address exchangeId = sunSwapFactory.getExchange(token);
     exchanges[token] = exchangeId;
     ITRC20(token).approve(exchangeId,uint256(-1));
   }
  }


  /*
  * @title getUsdtOutput
  * @param token is contract address of TRC20 token
  * returns  amount of USDT value according to sunswap
  */
  function getUsdtOutput(address token, uint256 amount) public view returns(uint256){
    require(amount > 0,"UkraineDonation: value can not be zero");

    if(token != address(0)){
      address exchangeId = sunSwapFactory.getExchange(token);
      amount = ISunswapExchange(exchangeId).getTokenToTrxInputPrice(amount);
    }

    return ISunswapExchange(exchanges[UsdtAddr]).getTrxToTokenInputPrice(amount);
  }

  /*
  * @title donateToken
  * @param token is contract address of TRC20 token
  * @param amount is amount of token to be donated
  * @dev
  * receive amount to token from sender and donate entrire balance of contract
  * for extra amount received by direct transfer.
  *
  * direct transfer if token is usdt
  * emit {Donation} on successful donation
  */
  function donateToken(address token, uint256 amount) public{
    require(amount > 0,"UkraineDonation: value can not be zero");
    addToken(token);

    if(token == UsdtAddr){
      ITRC20(UsdtAddr).transferFrom(msg.sender,ukrainGovt,amount);
      totalDonation += amount;
      emit Donation(msg.sender,UsdtAddr,amount,amount);
    }else{
      ITRC20(token).transferFrom(msg.sender,address(this),amount);
      uint256 balance = ITRC20(token).balanceOf(address(this));

      ISunswapExchange _exchange = ISunswapExchange(exchanges[token]);
      uint256 _donation = _exchange.tokenToTokenTransferInput(balance,1,1,block.timestamp,ukrainGovt,UsdtAddr);
      totalDonation += _donation;
      emit Donation(msg.sender,token,balance,_donation);
    }

  }

  /*
  * @title donateTrx
  * @dev swap all trx balance of contract to usdt and donate,
  * so that all extra trx if received in Previous transaction gets donated
  * emit {Donation} on successful donation
  */

  function donateTrx() public payable{
    require(msg.value > 0,"UkraineDonation: value can not be zero");

    ISunswapExchange _exchange = ISunswapExchange(exchanges[UsdtAddr]);
    uint256 _donation = _exchange.trxToTokenTransferInput.value(address(this).balance)(1,block.timestamp,ukrainGovt);
    emit Donation(msg.sender,address(0),address(this).balance,_donation);

  }



  /*
  * @title donateRemaining
  * @dev donated any direct transfered usdt remaining balance of contract
  * emit {Donation} on successful donation
  */
  function donateRemaining() public {
    uint256 balance = ITRC20(UsdtAddr).balanceOf(address(this));
    ITRC20(UsdtAddr).transfer(ukrainGovt,balance);
    totalDonation += balance;
    emit Donation(msg.sender,UsdtAddr,balance,balance);
  }



  }