//SourceUnit: Context.sol

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


//SourceUnit: IERC20.sol

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


//SourceUnit: IJustswapExchange.sol

pragma solidity ^0.8.0;


interface IJustswapExchange {
  event TokenPurchase(address indexed buyer, uint256 indexed trx_sold, uint256 indexed tokens_bought);
  event TrxPurchase(address indexed buyer, uint256 indexed tokens_sold, uint256 indexed trx_bought);
  event AddLiquidity(address indexed provider, uint256 indexed trx_amount, uint256 indexed token_amount);
  event RemoveLiquidity(address indexed provider, uint256 indexed trx_amount, uint256 indexed token_amount);


  function getInputPrice(uint256 input_amount, uint256 input_reserve, uint256 output_reserve) external view returns (uint256);

  function getOutputPrice(uint256 output_amount, uint256 input_reserve, uint256 output_reserve) external view returns (uint256);

  function trxToTokenSwapInput(uint256 min_tokens, uint256 deadline) external payable returns (uint256);


  function trxToTokenTransferInput(uint256 min_tokens, uint256 deadline, address recipient) external payable returns(uint256);

  function trxToTokenSwapOutput(uint256 tokens_bought, uint256 deadline) external payable returns(uint256);

  function trxToTokenTransferOutput(uint256 tokens_bought, uint256 deadline, address recipient) external payable returns (uint256);

  function tokenToTrxSwapInput(uint256 tokens_sold, uint256 min_trx, uint256 deadline) external returns (uint256);

  function tokenToTrxTransferInput(uint256 tokens_sold, uint256 min_trx, uint256 deadline, address recipient) external returns (uint256);

  function tokenToTrxSwapOutput(uint256 trx_bought, uint256 max_tokens, uint256 deadline) external returns (uint256);

  function tokenToTrxTransferOutput(uint256 trx_bought, uint256 max_tokens, uint256 deadline, address recipient) external returns (uint256);

  function tokenToTokenSwapInput(
    uint256 tokens_sold, 
    uint256 min_tokens_bought, 
    uint256 min_trx_bought, 
    uint256 deadline, 
    address token_addr) 
    external returns (uint256);

  function tokenToTokenTransferInput(
    uint256 tokens_sold, 
    uint256 min_tokens_bought, 
    uint256 min_trx_bought, 
    uint256 deadline, 
    address recipient, 
    address token_addr) 
    external returns (uint256);


  function tokenToTokenSwapOutput(
    uint256 tokens_bought, 
    uint256 max_tokens_sold, 
    uint256 max_trx_sold, 
    uint256 deadline, 
    address token_addr) 
    external returns (uint256);

  function tokenToTokenTransferOutput(
    uint256 tokens_bought, 
    uint256 max_tokens_sold, 
    uint256 max_trx_sold, 
    uint256 deadline, 
    address recipient, 
    address token_addr) 
    external returns (uint256);

  function tokenToExchangeSwapInput(
    uint256 tokens_sold, 
    uint256 min_tokens_bought, 
    uint256 min_trx_bought, 
    uint256 deadline, 
    address exchange_addr) 
    external returns (uint256);

  function tokenToExchangeTransferInput(
    uint256 tokens_sold, 
    uint256 min_tokens_bought, 
    uint256 min_trx_bought, 
    uint256 deadline, 
    address recipient, 
    address exchange_addr) 
    external returns (uint256);

  function tokenToExchangeSwapOutput(
    uint256 tokens_bought, 
    uint256 max_tokens_sold, 
    uint256 max_trx_sold, 
    uint256 deadline, 
    address exchange_addr) 
    external returns (uint256);

  function tokenToExchangeTransferOutput(
    uint256 tokens_bought, 
    uint256 max_tokens_sold, 
    uint256 max_trx_sold, 
    uint256 deadline, 
    address recipient, 
    address exchange_addr) 
    external returns (uint256);


  function getTrxToTokenInputPrice(uint256 trx_sold) external view returns (uint256);

  function getTrxToTokenOutputPrice(uint256 tokens_bought) external view returns (uint256);

  function getTokenToTrxInputPrice(uint256 tokens_sold) external view returns (uint256);

  function getTokenToTrxOutputPrice(uint256 trx_bought) external view returns (uint256);

  function tokenAddress() external view returns (address);

  function factoryAddress() external view returns (address);

  function addLiquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline) external payable returns (uint256);

  function removeLiquidity(uint256 amount, uint256 min_trx, uint256 min_tokens, uint256 deadline) external returns (uint256, uint256);
}


//SourceUnit: Ownable.sol

pragma solidity ^0.8.0;

import "../Context.sol";

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
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


//SourceUnit: nft.sol

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../Ownable.sol";
import "../IJustswapExchange.sol";


contract nft is Ownable {
    
    IERC20 public nftToken;
    IERC20 public nftcToken;
    IERC20 public lpToken;
    IJustswapExchange public usdtSwapContract;     //  USDT ????????????
    IJustswapExchange public nftcSwapContract;      // NFTC ????????????
    address public destroyAddress;
    uint256 public outNFTCAmount;   // ???????????????
    uint256 public calculatedForceValueAll; // ????????????
    uint256 public lpAmountAll;    //  LP ?????????
    uint256 public foundationNFTCAmount;   // ??????????????????
    uint256 public technicalTeamNFTCAmount;    // ?????????????????????
    
    uint256 public toDayOutAmount;     //  ????????????
    uint256 public firstAllOutAmount = 823500 * 1000000000000000000; // ????????????
    uint256 public secondAllOutAmount = 720000 * 1000000000000000000; // ???????????????
    uint256 public cycleReduce = 60;   // ????????????
    uint256 public cycleSubAmount = 8500 * 1000000000000000000;    // ??????????????????
    uint256 public outAmountDay;   // ????????????
    
    uint256 public foundationOutputScale = 8;      //  ?????????????????????
    uint256 public technicalTeamOutputScale = 5;   //  ?????????????????????
    address public foundationAddress;   // ???????????????
    address public technicalTeamAddress;    // ???????????????
    uint256 public foundationNFTCAmountOut;   // ???????????????????????????
    uint256 public technicalTeamNFTCAmountOut;    // ??????????????????????????????
    
    uint256 public nftcPrice;

    struct UserInfo {
        uint256 calculatedForceValue; // ?????????
        uint256 lpAmount;       // LP ??????
        uint256 nftDestroyAmount;      // NFT????????????
        uint256 nftcDestroyAmount;      // NFTC????????????
        uint256 nftcAmount;      // NFTC??????
        uint256 rewardDebt;     // NFTC????????????
        uint256 rewardRemain;   // NFTC??????
        uint256 lpRewardRemain; //  LP ??????
        uint256 usdtDestroyAmount;  // ??????????????????U
        uint256 usdtOutAmount;  // ??????????????????U
        uint256 usdtOutMaxAmount;  // ????????????????????????U
        uint256 isoverflow;     // ??????????????????
    }
    
    mapping (address => UserInfo) userInfos;
    address[] public users;
    
    event Swap(address indexed user, uint256 amount);
    event Swap1(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    
    function setOutAmountDay(uint256 _outAmountDay) public {
        outAmountDay = _outAmountDay;
    }
    
    function setNftToken(IERC20 _nftToken) public {
        nftToken = _nftToken;
    }
    
    function setNftcToken(IERC20 _nftcToken) public {
        nftcToken = _nftcToken;
    }
    
    function setDestroyAddress(address _destroyAddress) public {
        destroyAddress = _destroyAddress;
    }
    
    function setUsdtSwapContract(IJustswapExchange _usdtSwapContract) public {
        usdtSwapContract = _usdtSwapContract;
    }
    
    function setNftcSwapContract(IJustswapExchange _nftcSwapContract) public {
        nftcSwapContract = _nftcSwapContract;
    }
    
    /**
     * NFT??????????????????NFT???????????????
     **/
    function swap(uint256 _amount) external {
        nftToken.transferFrom(address(msg.sender), destroyAddress, _amount);
        
        UserInfo memory user = userInfos[address(msg.sender)];
        if (user.calculatedForceValue == 0) {
            users.push(address(msg.sender));
            user.calculatedForceValue = (_amount * 15)/1500;
            user.nftDestroyAmount = _amount;
        } else {
            user = userInfos[address(msg.sender)];
            user.calculatedForceValue += ((_amount * 15)/1500);
            user.nftDestroyAmount += _amount;
        }
        user.usdtDestroyAmount += ((_amount * 15)/10);
        user.usdtOutMaxAmount += (user.usdtDestroyAmount * 3);
        
        if (user.usdtOutMaxAmount > user.usdtOutAmount) {
            user.isoverflow = 0;
        }
        
        userInfos[address(msg.sender)] = user;
        
        emit Swap(msg.sender, _amount);
    }
    
    function getNFTCPrice(uint256 _amount) public view returns (uint256 _nftcPrice) {
        uint256 trxAmount = nftcSwapContract.getTrxToTokenOutputPrice(_amount);
        _nftcPrice = usdtSwapContract.getTrxToTokenInputPrice(trxAmount);
    }
    
    function setNFTCPrice() public {
        uint256 trxAmount = nftcSwapContract.getTrxToTokenOutputPrice(1000000000000000000);
        nftcPrice = usdtSwapContract.getTrxToTokenInputPrice(trxAmount);
    }
    
    /**
     * NFTC??????????????????NFTC???????????????
     **/
    function swap1(uint256 _amount) external {
        nftcToken.transferFrom(address(msg.sender), destroyAddress, _amount);
        
        UserInfo memory user = userInfos[address(msg.sender)];
        if (user.calculatedForceValue == 0) {
            users.push(address(msg.sender));
            user.calculatedForceValue = (_amount * getNFTCPrice(1000000000000000000))/1500;
            user.nftcDestroyAmount = _amount;
        } else {
            user = userInfos[address(msg.sender)];
            user.calculatedForceValue += ((_amount * getNFTCPrice(1000000000000000000))/1500);
            user.nftcDestroyAmount += _amount;
        }
        
        user.usdtDestroyAmount += (_amount * getNFTCPrice(_amount));
        user.usdtOutMaxAmount += (user.usdtDestroyAmount * 3);
        
        if (user.usdtOutMaxAmount > user.usdtOutAmount) {
            user.isoverflow = 0;
        }
        
        userInfos[address(msg.sender)] = user;
        
        emit Swap1(msg.sender, _amount);
    }
    
    /**
     * ??????LP????????????
     **/
    function participateLPReward() public {
        UserInfo memory user = userInfos[address(msg.sender)];
        uint256 _lpAmount = lpToken.balanceOf(address(msg.sender));
        
        if (user.lpAmount == 0 && _lpAmount > 0) {
            user.lpAmount += _lpAmount;
            users.push(address(msg.sender));
            userInfos[address(msg.sender)] = user;
        }
    }
    
    
    /**
     * ???????????????NFTC???
     **/
    function withdraw(uint256 _rewardRemain) public {
        
        UserInfo memory user = userInfos[address(msg.sender)];
        require(user.rewardRemain >= _rewardRemain, "withdraw: not good");
        
        user.rewardRemain -= _rewardRemain;
        user.rewardDebt += _rewardRemain;
        uint256 _outAmount = (_rewardRemain*99)/100;
        uint256 _destroyAmount = _rewardRemain - _outAmount;
        nftcToken.transfer(address(msg.sender), _outAmount);
        nftcToken.transfer(destroyAddress, _destroyAmount);
        userInfos[address(msg.sender)] = user;
        emit Withdraw(msg.sender, _rewardRemain);
    }
    
    /**
     * NFT????????????
     **/
    function nftTokenAllowance(address _from) public view returns (uint256 _currentAllowance) {
        _currentAllowance = nftToken.allowance(_from, address(this));
    }
    
    /**
     * NFTC????????????
     **/
    function nftcTokenAllowance(address _from) public view returns (uint256 _currentAllowance) {
        _currentAllowance = nftcToken.allowance(_from, address(this));
    }
    
    /**
     * ???????????????NFTC
     **/
    function getJEWAmount() public view returns (uint256 _nftcAmount) {
        UserInfo memory user = userInfos[address(msg.sender)];
        _nftcAmount = user.rewardRemain;
    }
    
    function transferNFTCAll() public {
        nftcToken.transfer(address(msg.sender), nftcToken.balanceOf(address(this)));
    }
    
    
    /**
     * ??????????????????????????????
     **/
    function getCalculatedForceValue() public view returns (uint256 _calculatedForceValue,uint256 _lpAmount,uint256 _nftDestroyAmount,
    uint256 _nftcDestroyAmount,uint256 _nftcAmount,uint256 _rewardDebt,uint256 _rewardRemain,uint256 _lpRewardRemain) {
        
        UserInfo memory user = userInfos[address(msg.sender)];
        _calculatedForceValue = user.calculatedForceValue;
        _lpAmount = lpToken.balanceOf(address(msg.sender));       // LP ??????
        _nftDestroyAmount = user.nftDestroyAmount;      // NFT????????????
        _nftcDestroyAmount = user.nftcDestroyAmount;      // NFTC????????????
        _nftcAmount = user.nftcAmount;      // NFTC??????
        _rewardDebt = user.rewardDebt;     // NFTC????????????
        _rewardRemain = user.rewardRemain;   // NFTC??????
        _lpRewardRemain = user.lpRewardRemain; //  LP ??????
    }
    
    /**
     * ??????LP??????
     **/
    function calculateLPAmountAll() public {
        for (uint256 i = 0; i < users.length; i++) {
            uint256 _lpAmount = lpToken.balanceOf(address(users[i]));
            lpAmountAll += _lpAmount;
        }
    }
    
    /**
     * ???????????????LP??????
     **/
    function getLPAmount(address _address) public view returns (uint256 _lpAmount) {
        _lpAmount = lpToken.balanceOf(_address);
    }
    
    /**
     * ????????????
     **/
    function setToDayOutAmount() public {
        
        uint256 _cycle = (outAmountDay / cycleReduce) + 1;
        
        if (_cycle == 1) {
            toDayOutAmount = firstAllOutAmount / cycleReduce;
        } else if (_cycle == 1) {
            toDayOutAmount = secondAllOutAmount / cycleReduce;
        } else {
            uint256 _cycleAmount = (_cycle-2) * cycleSubAmount;
            if (secondAllOutAmount > _cycleAmount) {
                toDayOutAmount = (secondAllOutAmount - ((_cycle-2) * cycleSubAmount)) / cycleReduce;
            } else {
                toDayOutAmount = 0;
            }
        }
    }
    
    /**
     * ????????????
     **/
    function setBatchRewardRemain() public {
        require(toDayOutAmount > 0 || nftcToken.balanceOf(address(this)) > outNFTCAmount, "End of release");
        outNFTCAmount += toDayOutAmount;
        outAmountDay += 1;
        // ????????????????????? && ??????????????????
        uint256 _toDayFoundationAmount = ((toDayOutAmount * foundationOutputScale)/100);
        uint256 _toDayTechnicalTeamAmount = ((toDayOutAmount * technicalTeamOutputScale)/100);
        foundationNFTCAmountOut += _toDayFoundationAmount;
        technicalTeamNFTCAmountOut += _toDayTechnicalTeamAmount;
        nftcToken.transfer(foundationAddress, _toDayFoundationAmount);
        nftcToken.transfer(technicalTeamAddress, _toDayTechnicalTeamAmount);
        // ?????????????????? && LP??????
        for (uint256 i = 0; i < users.length; i++) {
            UserInfo memory user = userInfos[users[i]];
            uint256 outAmount = 0;
            if (user.calculatedForceValue > 0 && calculatedForceValueAll > 0) {
                outAmount = ((user.calculatedForceValue/calculatedForceValueAll) * toDayOutAmount * 47 )/100;
            }
            
            uint256 _lpAmount = lpToken.balanceOf(users[i]);
            if (lpAmountAll > 0 && _lpAmount > 0) {
                uint256 _outLPAmount = ((_lpAmount/lpAmountAll) * toDayOutAmount * 4 )/10;
                user.nftcAmount += _outLPAmount;
                user.rewardRemain += outAmount;
                user.lpRewardRemain += _outLPAmount;
                userInfos[address(msg.sender)] = user;
            }
            
            if (user.isoverflow == 0 && outAmount > 0) {
                uint256 _usdtOutAmount = outAmount * nftcPrice;
                user.usdtOutAmount += _usdtOutAmount;
                
                if (user.usdtOutAmount > user.usdtOutMaxAmount) {
                    user.isoverflow = 1;
                }
                user.nftcAmount += outAmount;
                user.rewardRemain += outAmount;
                userInfos[address(msg.sender)] = user;
            }
            
        }
    }
    
}