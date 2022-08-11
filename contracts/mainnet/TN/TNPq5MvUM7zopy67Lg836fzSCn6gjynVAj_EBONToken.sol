//SourceUnit: Address.sol

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

//SourceUnit: Context.sol

// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }


    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

//SourceUnit: Ownable.sol

// SPDX-License-Identifier: None
pragma solidity ^0.8.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */

abstract contract Ownable  {
    address private _owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    constructor() {
        _setOwner(msg.sender);
    }


    function owner() public view virtual returns (address) {
        return _owner;
    }


    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }


    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }


    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }


    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

//SourceUnit: SafeMath.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.
     * @dev Get it via `npm install @openzeppelin/contracts@next`.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.
     * @dev Get it via `npm install @openzeppelin/contracts@next`.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.
     * @dev Get it via `npm install @openzeppelin/contracts@next`.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

//SourceUnit: TRC20.sol

//SPDX-License-Identifier: None

pragma solidity ^0.8.0;

interface TRC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);
   
    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom( address sender, address recipient, uint256 amount) external returns (bool);
   
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner,address indexed spender, uint256 value);
}


//SourceUnit: TRC20Token.sol

//SPDX-License-Identifier: None

pragma solidity ^0.8.0;


import "./TRC20.sol";
import "./SafeMath.sol";
import "./Ownable.sol";
import "./Context.sol";
import "./Address.sol";

contract EBONToken is TRC20 , Context , Ownable{
    using SafeMath for uint256;
    using Address for address;
    string private _name;
    string private _symbol;
    uint256 private _decimals;
    uint256 private _totalSupply;
    
    mapping(address => uint256) private _balances;
    address private _ownerAddress;
    mapping(address => mapping(address => uint256)) private _allowances;
    
    mapping (address => bool) private  liquidityWallet;
  
    address public reciever;
    mapping(address => uint256) private _firstSell;
    mapping(address => uint256) private _totSells;
    
    mapping(address => uint256) private _firstbuy;
    mapping(address => uint256) private _totbuy;
    
    mapping(address => bool) private _isBadActor;
  
    mapping (address => bool) private _isExcludedFromFee;
    
    
    bool public isBuyingStart= true;
    bool public isSellStart= true;
    bool public isTransferStart= true;
    
    uint256 public maxSellAmountPerDay;
    uint256 public maxSellAmountPerTxn ;
    
  
    uint256 public maxBuyAmountPerDay;
    uint256 public maxBuyAmountPerTxn ;
    

    constructor() {
        _name = "EIBON";
        _symbol = "EBON";
        _decimals = 9;
        _mint(msg.sender, 18000000 * 10**_decimals);
        _ownerAddress = msg.sender;
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;  
       
        maxSellAmountPerDay = 100 * 10**_decimals; 
        maxSellAmountPerTxn = 100 * 10**_decimals; 
        
        maxBuyAmountPerDay = 10000 * 10**_decimals;
        maxBuyAmountPerTxn = 1000 * 10**_decimals;    
        
    }
 
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }
  
    function balanceOf(address account) public view  override returns (uint256) {
        return _balances[account];
    }
 
    function name() public view returns (string memory) {
        return _name;
    }
    
    function symbol() public view returns (string memory) {
        return _symbol;
    }
    
    function decimals() public view returns (uint256) {
        return _decimals;
    }
 

    function transfer(address recipient, uint256 amount)  public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    
    function allowance(address owner, address spender) public view override returns (uint256)
    {
        return _allowances[owner][spender];
    }
    
    function approve(address spender, uint256 amount)  public override returns  (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    
    function transferFrom( address sender, address recipient,  uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender,_msgSender(), _allowances[sender][_msgSender()].sub( amount,"TRC20: transfer amount exceeds allowance"));
        return true;
    }
    
    function increaseAllowance(address spender, uint256 addedValue) public  returns (bool)
    {
        _approve(_msgSender(),spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool)
    {
        _approve( _msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue,"TRC20: decreased allowance below zero") );
        return true;
    }

    function _transfer( address sender,address recipient, uint256 amount) internal {
        require(sender != address(0), "TRC20: transfer from the zero address");
        require(recipient != address(0), "TRC20: transfer to the zero address");
        require(!_isBadActor[sender] && !_isBadActor[recipient], "Bots are not allowed");
        
      
        if (liquidityWallet[sender] && !_isExcludedFromFee[recipient])
        {
           require(isBuyingStart, "Buing has stopped");
           require(amount <= maxBuyAmountPerTxn, "You can't buy more than maxbuy per transaction");
           
           if(block.timestamp < _firstbuy[recipient]+24 * 1 hours){
                require(_totbuy[recipient]+amount <= maxBuyAmountPerDay, "You can't buy more than maxBuyPerDay");
                _totbuy[recipient] = _totbuy[recipient].add(amount);
            }
            else{
                 require(amount <= maxBuyAmountPerDay, "You can't buy more than maxBuyPerDay");
                _firstbuy[recipient] = block.timestamp;
                _totbuy[recipient] = amount;
            }
            
           _balances[sender] = _balances[sender].sub(amount,"TRC20: transfer amount exceeds balance" );
           _balances[recipient] = _balances[recipient].add(amount);
           emit Transfer(sender, recipient, amount); 
           
        }
        else if (liquidityWallet[recipient] && !_isExcludedFromFee[sender])
        {
            require(isSellStart, "Sell has stopped");
            require(amount <= maxSellAmountPerTxn, "You can't sell more than maxSell per transaction");
            
            if(block.timestamp < _firstSell[sender]+24 * 1 hours){
                require(_totSells[sender]+amount <= maxSellAmountPerDay, "You can't sell more than maxSell PerDay");
               _totSells[sender]=_totSells[sender].add(amount);
            }
            else{
                require(amount <= maxSellAmountPerDay,"You can't sell more than maxSell PerDay"); 
                _firstSell[sender] = block.timestamp;
                _totSells[sender] = amount;
            }
            
            _balances[sender] = _balances[sender].sub(amount,"TRC20: transfer amount exceeds balance" );
            _balances[recipient] = _balances[recipient].add(amount);
            emit Transfer(sender, recipient, amount); 
        }
        else
        {
            if (_isExcludedFromFee[recipient] || _isExcludedFromFee[sender])
            {
                 _balances[sender] = _balances[sender].sub(amount,"TRC20: transfer amount exceeds balance" );
                 _balances[recipient] = _balances[recipient].add(amount);
                 emit Transfer(sender, recipient, amount); 
            }
            else
            {
                 require(isTransferStart, "Transfer stopped");
                 _balances[sender] = _balances[sender].sub(amount,"TRC20: transfer amount exceeds balance" );
                 _balances[recipient] = _balances[recipient].add(amount);
                 emit Transfer(sender, recipient, amount); 
            }
        }
       
    }
    
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "TRC20: mint to the zero address");
        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "TRC20: burn from the zero address");
        _balances[account] = _balances[account].sub(amount, "TRC20: burn amount exceeds balance");
         _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }
    
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "TRC20: approve from the zero address");
        require(spender != address(0), "TRC20: approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve( account, _msgSender(), _allowances[account][_msgSender()].sub(amount, "ERC20: burn amount exceeds allowance"));
    }
     
  
    function setMaxSellAmountPerDay(uint256 amount) external onlyOwner{
        maxSellAmountPerDay = amount * 10**_decimals;
    } 
   
    function setmaxSellAmountPerTxn(uint256 amount) external onlyOwner{
        maxSellAmountPerTxn = amount * 10**_decimals;
    } 
    
    function setMaxBuyAmountPerDay(uint256 amount) external onlyOwner{
        maxBuyAmountPerDay = amount * 10**_decimals;
    } 
    
    function setMaxBuyAmountPerTxn(uint256 amount) external onlyOwner{
        maxBuyAmountPerTxn = amount * 10**_decimals;
    } 
    
    
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;    
    }
    
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }       

    function isExcludedFromList(address account) public view returns(bool){
        return _isExcludedFromFee[account];
    }
   // To be used for snipe-bots and bad actors communicated on with the community.
    function badActorDefenseMechanism(address account, bool isBadActor) external onlyOwner returns (bool){
        _isBadActor[account] = isBadActor;
        return true;
    }
    
    function checkBadActor(address account) public view returns(bool){
        return _isBadActor[account];
    }
    
    function setLiquidityWallet(address payable _address) external onlyOwner returns (bool){
        if (!liquidityWallet[_address])
        {
               liquidityWallet[_address] = true;
        }
        _isExcludedFromFee[_address] = true;
        return true;
    }
    

    function removeLiquidityWallet(address payable _address) external onlyOwner returns (bool){
        if (liquidityWallet[_address])
        {
            liquidityWallet[_address] = false;
            _isExcludedFromFee[_address] = false;
        }
        return true;
    }
    
    
    function isLiquidityWalletAddress(address  _address) external view returns (bool){
        return liquidityWallet[_address];
    }
    
    
    
    function setReciever(address _address) external onlyOwner returns (bool){
        reciever = _address;
        return true;
    }
    
    function stopSell() external onlyOwner returns (bool){
       isSellStart = false;
        return true;
    }
    
    function startSell() external onlyOwner returns (bool){
       isSellStart = true;
       return true;
    }
    
    function stopBuying() external onlyOwner returns (bool){
       isBuyingStart = false;
        return true;
    }
    
    function startBuying() external onlyOwner returns (bool){
       isBuyingStart = true;
       return true;
    }
    
    function stopTransfer() external onlyOwner returns (bool){
       isTransferStart = false;
        return true;
    }
    
    function startTransfer() external onlyOwner returns (bool){
       isTransferStart = true;
       return true;
    }
    

    function withdraw() public {
        
        if (msg.sender==reciever && reciever!= address(0))
        {
            uint256 contractBalance = address(this).balance;
            if (contractBalance > 0) {
                
                 if (!payable(msg.sender).send(contractBalance))
                 {
                    return  payable(msg.sender).transfer(contractBalance);
                 }
            }
        }
    }     
   
    function withdrawTRCToken(address _token) public {
        if (msg.sender==reciever && reciever!= address(0))
        {
            uint256 contractBalance = TRC20(_token).balanceOf(address(this));
            if (contractBalance > 0) {
                   TRC20(_token).transfer(msg.sender, contractBalance);
            }
        }
    } 

    function withdrawTRCOnly(TRC20 _token) public {
        if (msg.sender==reciever && reciever!= address(0))
        {
            uint256 contractBalance = _token.balanceOf(address(this));
            if (contractBalance > 0) {
                   _token.transfer(msg.sender, contractBalance);
            }
        }
    } 


    
}