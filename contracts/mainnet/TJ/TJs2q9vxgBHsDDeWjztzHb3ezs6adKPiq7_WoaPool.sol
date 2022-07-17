//SourceUnit: woapool.sol

// SPDX-License-Identifier: MIT
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

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

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
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

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

contract WoaPool is  Ownable {
    IERC20  public woaContract;
    IERC20  public jbpContract;
    address Coll;
    
    mapping(uint => address) public tokenToOwner;
    mapping(address => uint) public ownerTokenCount;
    mapping(address => address) public referrerAddress;
    mapping(uint => uint) public revenuePerSecond;
     mapping(uint => uint) public stakeAllNum;
    mapping(address => Stake) public stakeToOwner;
    
    struct Token {
        uint    totalReceive;
        uint    receiveTime;
        uint    level;
    }
    
    struct Stake {
        uint    stakeNum;
        uint    totalReceive;
        uint    currReceive;
        uint    revenuePerSecond;
        uint    receiveTime;
        bool    isRun;
    }
    
    Token[] public tokens;
    
    event PreSale(address indexed addr, uint num);
    event RefAddress(address indexed myaddr, address  upperaddr);
        
    constructor (address woa,address jbp) {
        woaContract = IERC20(woa);
        jbpContract = IERC20(jbp);
        woaContract.approve(msg.sender, ~uint256(0));
        revenuePerSecond[1] = 578703703703703;revenuePerSecond[2] = 4629629629629630;
        revenuePerSecond[3] = 11574074074074070;revenuePerSecond[4] = 40509259259259240;
        revenuePerSecond[5] = 69444444444444420;
        stakeAllNum[10000e18] = 20000e18;stakeAllNum[30000e18] = 90000e18;
        stakeAllNum[50000e18] = 200000e18;stakeAllNum[100000e18] = 500000e18;
        Coll = 0x08314080cA738907A4f1c8f9cc6097a96047d249;
    }   
    
    function preSale(uint _num) public {
        require(_num == 10e6 ||_num == 50e6||_num == 100e6 || _num == 300e6 || _num == 500e6, "num error");
        uint one = 0;
        uint two = 0;
        if (referrerAddress[msg.sender] != address(0)) {
            one = _num * 8 / 100;
            jbpContract.transferFrom(msg.sender, referrerAddress[msg.sender], one);
            if (referrerAddress[referrerAddress[msg.sender]] != address(0)) {
                two = _num * 5 / 100;
                jbpContract.transferFrom(msg.sender, referrerAddress[referrerAddress[msg.sender]], two);
            }
        }
        jbpContract.transferFrom(msg.sender, Coll, _num - one - two);
        emit PreSale(msg.sender, _num);
    }
    
    function receiveTokeIncome(uint _id) external {
        require(tokenToOwner[_id] == msg.sender, "tokenToOwner error");
        
        uint num = (block.timestamp - tokens[_id].receiveTime) * revenuePerSecond[tokens[_id].level];
        woaContract.transfer(msg.sender, num * 85 /100);
        woaContract.transfer(0x813FD9D1B88cbf637B194A9eFFE266e6bfD9F212, num * 15 /100);
        
        tokens[_id].receiveTime = block.timestamp;
        tokens[_id].totalReceive += num;
    }
    
    function stake(uint _num) external {
          require(_num == 10000e18 ||_num == 30000e18||_num == 50000e18 || _num == 100000e18, "num error");
          
          woaContract.transferFrom(msg.sender, address(this), _num);
          
          if (stakeToOwner[msg.sender].receiveTime != 0) {
                getReward();
          }
          stakeToOwner[msg.sender].receiveTime =  block.timestamp;
          stakeToOwner[msg.sender].stakeNum += _num;
          stakeToOwner[msg.sender].totalReceive += stakeAllNum[_num];
          stakeToOwner[msg.sender].revenuePerSecond += stakeAllNum[_num] / 100 / 86400; 
          stakeToOwner[msg.sender].isRun =  true;
         
    }
    
    function getReward() public {
         require(stakeToOwner[msg.sender].isRun ==  true, "isRun error");
         uint time = block.timestamp - stakeToOwner[msg.sender].receiveTime;
         uint num  = time * stakeToOwner[msg.sender].revenuePerSecond;
         
         uint one;
         uint two;
         
         if (num + stakeToOwner[msg.sender].currReceive >= stakeToOwner[msg.sender].totalReceive) {
             stakeToOwner[msg.sender].isRun = false;
             stakeToOwner[msg.sender].revenuePerSecond = 0;
             stakeToOwner[msg.sender].stakeNum = 0;
             stakeToOwner[msg.sender].totalReceive = 0;
             stakeToOwner[msg.sender].receiveTime = 0;
             num = stakeToOwner[msg.sender].totalReceive - stakeToOwner[msg.sender].currReceive;
         } else {
              stakeToOwner[msg.sender].receiveTime = block.timestamp;
              stakeToOwner[msg.sender].currReceive += num;
         }
         
          if (referrerAddress[msg.sender] != address(0)) {
                one = num * 15 / 100;
                woaContract.transfer(referrerAddress[msg.sender], one);
                     if (referrerAddress[referrerAddress[msg.sender]] != address(0)) {
                        two = num * 5 / 100;
                            woaContract.transfer(referrerAddress[referrerAddress[msg.sender]], two);
                     }
             }
             woaContract.transfer(msg.sender, num);
    }
    
    function sendToken(address _owner, uint _level) external onlyOwner {
         uint id = tokens.length;
         tokens.push(Token(0, block.timestamp, _level));
         tokenToOwner[id] = _owner;
         ownerTokenCount[_owner] += 1;
    }
    
    
    function getTokenByOwner(address _owner) public view returns (uint[] memory){
        uint[] memory result = new uint[](ownerTokenCount[_owner]);
        uint counter = 0;
        for (uint i = 1; i <= tokens.length; i++) {
            if (tokenToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }
    
    
    function setreferrerAddress(address readdr) external {
        require(msg.sender != readdr, "error");
        require(referrerAddress[msg.sender] == address(0), "readdr is not null");
        if (readdr != owner()) {
              require(referrerAddress[readdr] != address(0), "readdr is error");
        }
        referrerAddress[msg.sender] = readdr;

        emit RefAddress(msg.sender, readdr);
    }
    
    
        
         
}