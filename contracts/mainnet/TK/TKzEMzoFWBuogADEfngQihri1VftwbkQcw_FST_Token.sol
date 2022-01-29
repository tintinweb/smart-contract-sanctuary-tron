//SourceUnit: FST_Token.sol

pragma solidity 0.5.10; /*

___________________________________________________________________
  _      _                                        ______           
  |  |  /          /                                /              
--|-/|-/-----__---/----__----__---_--_----__-------/-------__------
  |/ |/    /___) /   /   ' /   ) / /  ) /___)     /      /   )     
__/__|____(___ _/___(___ _(___/_/_/__/_(___ _____/______(___/__o_o_



███████╗███████╗████████╗    ████████╗ ██████╗ ██╗  ██╗███████╗███╗   ██╗
██╔════╝██╔════╝╚══██╔══╝    ╚══██╔══╝██╔═══██╗██║ ██╔╝██╔════╝████╗  ██║
█████╗  ███████╗   ██║          ██║   ██║   ██║█████╔╝ █████╗  ██╔██╗ ██║
██╔══╝  ╚════██║   ██║          ██║   ██║   ██║██╔═██╗ ██╔══╝  ██║╚██╗██║
██║     ███████║   ██║          ██║   ╚██████╔╝██║  ██╗███████╗██║ ╚████║
╚═╝     ╚══════╝   ╚═╝          ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝
                                                                         


=== 'FST Token' Token contract with following features ===
    => TRC20 Compliance
    => SafeMath implementation 
    => owner can freeze any wallet to prevent fraud
    => Burnable 
    => Minting upto max supply


======================= Quick Stats ===================
    => Name        : FST Token
    => Symbol      : FST
    => Max supply  : 720,000
    => Decimals    : 6


============= Independant Audit of the code ============
    => Multiple Freelancers Auditors
    => Community Audit by Bug Bounty program


-------------------------------------------------------------------
 Copyright (c) 2020 onwards Forsagetron Inc. ( https://Forsagetron.io )
-------------------------------------------------------------------
*/ 




//*******************************************************************//
//------------------------ SafeMath Library -------------------------//
//*******************************************************************//
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
    require(c / a == b, 'SafeMath mul failed');
    return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a, 'SafeMath sub failed');
    return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a, 'SafeMath add failed');
    return c;
    }
}


//*******************************************************************//
//------------------ Contract to Manage Ownership -------------------//
//*******************************************************************//
    
contract owned {
    address payable public owner;
    address payable internal newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), owner);
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address payable _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    //this flow is to prevent transferring ownership to wrong wallet by mistake
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}
 

    
//****************************************************************************//
//---------------------        MAIN CODE STARTS HERE     ---------------------//
//****************************************************************************//
    
contract FST_Token is owned {
    

    /*===============================
    =         DATA STORAGE          =
    ===============================*/

    // Public variables of the token
    using SafeMath for uint256;
    string constant private _name = "FST Token";
    string constant private _symbol = "FST";
    uint256 constant private _decimals = 6;
    uint256 private _totalSupply;                       
    uint256 constant public maxSupply = 720000 * (10**_decimals);    //720 thousands tokens max

    // This creates a mapping with all data storage
    mapping (address => uint256) private _balanceOf;
    mapping (address => mapping (address => uint256)) private _allowance;
    mapping (address => bool) public frozenAccount;


    /*===============================
    =         PUBLIC EVENTS         =
    ===============================*/

    // This generates a public event of token transfer
    event Transfer(address indexed from, address indexed to, uint256 value);

    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);
        
    // This generates a public event for frozen (blacklisting) accounts
    event FrozenAccounts(address target, bool frozen);
    
    // This will log approval of token Transfer
    event Approval(address indexed from, address indexed spender, uint256 value);



    /*======================================
    =       STANDARD ERC20 FUNCTIONS       =
    ======================================*/
    
    /**
     * Returns name of token 
     */
    function name() public pure returns(string memory){
        return _name;
    }
    
    /**
     * Returns symbol of token 
     */
    function symbol() public pure returns(string memory){
        return _symbol;
    }
    
    /**
     * Returns decimals of token 
     */
    function decimals() public pure returns(uint256){
        return _decimals;
    }
    
    /**
     * Returns totalSupply of token.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    
    /**
     * Returns balance of token 
     */
    function balanceOf(address user) public view returns(uint256){
        return _balanceOf[user];
    }
    
    /**
     * Returns allowance of token 
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowance[owner][spender];
    }
    
    /**
     * Internal transfer, only can be called by this contract 
     */
    function _transfer(address _from, address _to, uint _value) internal {
        
        //checking conditions
        require (_to != address(0));                      // Prevent transfer to 0x0 address. Use burn() instead
        require(!frozenAccount[_from]);                     // Check if sender is frozen
        require(!frozenAccount[_to]);                       // Check if recipient is frozen
        
        // overflow and undeflow checked by SafeMath Library
        _balanceOf[_from] = _balanceOf[_from].sub(_value);    // Subtract from the sender
        _balanceOf[_to] = _balanceOf[_to].add(_value);        // Add the same to the recipient
        
        // emit Transfer event
        emit Transfer(_from, _to, _value);
    }

    /**
        * Transfer tokens
        *
        * Send `_value` tokens to `_to` from your account
        *
        * @param _to The address of the recipient
        * @param _value the amount to send
        */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        //no need to check for input validations, as that is ruled by SafeMath
        _transfer(msg.sender, _to, _value);
        return true;
    }

    /**
        * Transfer tokens from other address
        *
        * Send `_value` tokens to `_to` in behalf of `_from`
        *
        * @param _from The address of the sender
        * @param _to The address of the recipient
        * @param _value the amount to send
        */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        //checking of allowance and token value is done by SafeMath
        //we want to pre-approve system contracts so that it does not need to ask for approval calls
        if(msg.sender != minerContract && msg.sender != dexContract){
            _allowance[_from][msg.sender] = _allowance[_from][msg.sender].sub(_value);
        }
        _transfer(_from, _to, _value);
        return true;
    }

    /**
        * Set allowance for other address
        *
        * Allows `_spender` to spend no more than `_value` tokens in your behalf
        *
        * @param _spender The address authorized to spend
        * @param _value the max amount they can spend
        */
    function approve(address _spender, uint256 _value) public returns (bool success) {

        /* AUDITOR NOTE:
            Many dex and dapps pre-approve large amount of tokens to save gas for subsequent transaction. This is good use case.
            On flip-side, some malicious dapp, may pre-approve large amount and then drain all token balance from user.
            So following condition is kept in commented. It can be be kept that way or not based on client's consent.
        */
        //require(_balanceOf[msg.sender] >= _value, "Balance does not have enough tokens");
        _allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to increase the allowance by.
     */
    function increase_allowance(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));
        _allowance[msg.sender][spender] = _allowance[msg.sender][spender].add(value);
        emit Approval(msg.sender, spender, _allowance[msg.sender][spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to decrease the allowance by.
     */
    function decrease_allowance(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));
        _allowance[msg.sender][spender] = _allowance[msg.sender][spender].sub(value);
        emit Approval(msg.sender, spender, _allowance[msg.sender][spender]);
        return true;
    }


    /*=====================================
    =       CUSTOM PUBLIC FUNCTIONS       =
    ======================================*/
    
    /**
      * Constructor functions does not do anything.
    */
    constructor() public{ }
    
    /**
     * Fallback function is disabled. This smart contract does not accept any incoming TRX.
     */
    //function () external payable { }

    /**
        * Destroy tokens
        *
        * Remove `_value` tokens from the system irreversibly
        *
        * @param _value the amount of money to burn
        */
    function burn(uint256 _value) public returns (bool success) {

        //checking of enough token balance is done by SafeMath
        _balanceOf[msg.sender] = _balanceOf[msg.sender].sub(_value);  // Subtract from the sender
        _totalSupply = _totalSupply.sub(_value);                      // Updates totalSupply
        emit Burn(msg.sender, _value);
        emit Transfer(msg.sender, address(0), _value);
        return true;
    }

    
        
    
    /** 
        * @notice `freeze? Prevent | Allow` `target` from sending & receiving tokens
        * @param target Address to be frozen
        * @param freeze either to freeze it or not
        */
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        emit  FrozenAccounts(target, freeze);
    }
    
       

   
   
    
  
    
    /*=====================================
    =            MINING SECTION           =
    ======================================*/
    
    address public minerContract;
    bool public minerContractChangeLock;
    
    
    /**
     * Set minter contract.
     * To prevent owner to mis-use of pre-approve functionality, he can edit this once in lifetime.
     * This will allow users to transfer tokens in one transaction, in system contracts.
     */
    function setMinerContract(address _minerContract) external onlyOwner returns(bool){
        require(_minerContract != address(0), 'Invalid address');
        require(!minerContractChangeLock, 'Miner contrat can not be changed');
        minerContractChangeLock=true;
        minerContract = _minerContract;
        return true;
    }
    
    
    /**
     * Mint tokens are done through its own contract.
     * Tokens are generated as user buys tokens during initial token sale.
     * Then more tokens will be generated as conditons specified in that contract.
     * It will stop until max supply will be reached.
     */
    function mintTokens(address receipient, uint256 tokenAmount) external returns(bool){
        require(msg.sender == minerContract, 'Invalid caller');
        require(_totalSupply.add(tokenAmount) <= maxSupply, 'Max supply reached');
        
        _balanceOf[receipient] = _balanceOf[receipient].add(tokenAmount);
        _totalSupply = _totalSupply.add(tokenAmount);
        emit Transfer(address(0), receipient, tokenAmount);
        
        return true;
    }
    
    
    
    
    /*=====================================
    =             DEX SECTION             =
    ======================================*/
    
    address public dexContract;
    bool public dexContractChangeLock;
    /**
     * Set dex contract.
     * To prevent owner to mis-use of pre-approve functionality, he can edit this once in lifetime.
     * This will allow users to transfer tokens in one transaction, in system contracts.
     */
    function setDexContract(address _dexContract) external onlyOwner returns(bool){
        require(_dexContract != address(0), 'Invalid address');
        require(!dexContractChangeLock, 'Dex contrat can not be changed');
        dexContractChangeLock=true;
        dexContract = _dexContract;
        return true;
    }
    
    
}