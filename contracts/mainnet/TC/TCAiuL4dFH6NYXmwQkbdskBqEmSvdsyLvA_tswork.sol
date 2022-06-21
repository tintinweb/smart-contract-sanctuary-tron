//SourceUnit: ts.sol

pragma solidity ^0.6.12;
 // SPDX-License-Identifier: Unlicensed

library Math {
   
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

  
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
     
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}


library SafeMath {
   
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

 
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

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
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


interface IERC20 {
   
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

   
    function transfer(address recipient, uint256 amount) external returns (bool);

    function mint(address account, uint amount) external;

  
    function allowance(address owner, address spender) external view returns (uint256);

   
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function burn(uint256 amount) external;

    event Transfer(address indexed to, uint256 value);


    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library Address {
  
    function isContract(address account) internal view returns (bool) {
       
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        
        assembly {codehash := extcodehash(account)}
        return (codehash != 0x0 && codehash != accountHash);
    }

   
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }


  
}


library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
      
        require((value == 0) || (token.allowance(address(this), spender) == 0),
     
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {
      
        // require(address(token).isContract(), "SafeERC20: call to non-contract");

       
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


contract TokenWrapper {
    using SafeMath for uint256;
    // using SafeERC20 for IERC20;

    mapping(address=>bool) internal  governance;
    // address internal erylpaddress;
    // address internal eoilpaddress;
    // address internal eryad;
    // address internal eoiad;
    // address internal eunad;

    address internal erylpaddress;
    address internal eoilpaddress;
    address internal eryad;
    address internal eoiad;
    address internal eunad;

    event Transfer(IERC20 token,address toad,uint256 amount);
    event transferFrom(address token,address toad,uint256 amount);
    event  TreeAprove(IERC20 token,address toad,uint256 amount);
    function transfromcoin(address coinaddress,address fromad,address toad,uint256 amount) internal {
        // usdt.safeApprove(toad,amount);
        IERC20(coinaddress).transferFrom(fromad,toad,amount);
        emit transferFrom(fromad,toad,amount);
    }
  
	function transcoin(address coinaddress,address toad,uint256 amount) internal {
        IERC20(coinaddress).transfer(toad, amount);
        emit Transfer(IERC20(coinaddress),toad,amount);
    } 

}

contract tswork is TokenWrapper {
    using SafeMath for uint256;
    struct deposit{
        uint256 erycount;
        uint256 lpcount;
        uint256 day;
        uint256 times;
        uint256 withdrawtimes;
        bool isover;
        uint256 types;
    }
    struct users{
        deposit[] Deopsit;//
        address referer;//
        uint256 tzbonusery;//
        uint256 tzbonuseoi;//
        uint256 tzbonuseun;//
        uint256 referbonusery;//
        uint256 referbonuseoi;//
        uint256 referbonuseun;//
        address[] myson;// 
    }
    address private _governance_;


    // 
    uint256  private mintery;//ery
    uint256  private minteoi;//eoi
    uint256  private minteun;//eun
    // 
    uint256  private eryrefer;//ery
    uint256  private eoirefer;//eoi
    uint256  private eunrefer;//eun
    // 
    uint256  private minteryyet;//ery
    uint256  private minteoiyet;//eoi
    uint256  private minteunyet;//eun
    // 
    uint256  private eryreferyet;//ery
    uint256  private eoireferyet;//eoi
    uint256  private eunreferyet;//eun

    //
    uint256 private lperycount30;
    uint256 private lperycount60;
    uint256 private lperycount90;
    uint256 private lpeoicount30;
    uint256 private lpeoicount60;
    uint256 private lpeoicount90;

    //
    uint256 private lperycount30ed;
    uint256 private lperycount60ed;
    uint256 private lperycount90ed;

    uint256 private lpeoicount30ed;
    uint256 private lpeoicount60ed;
    uint256 private lpeoicount90ed;

    //
    uint256 private smcount;
    uint256 private smcounted;
    //
    mapping(address=>uint256) private _lockerybalance_;
    mapping(address=>uint256) private _islock;

    // 
    uint256 private minteoistarttime;// eoi
    uint256 private minteunstarttime;// eun
    

    //
    // uint256[4]  private CLASSBONUSSUM=[80,160,320,480];
    uint256[3]  private CLASSBONUSSUM=[30,70,150];
    // mapping(uint256=>uint256) private idays;//
    //
    uint256 constant private PERCENT=1000;

    //
    uint256 private erylplockall;
    //
    uint256 private eoilplockall;
    
    //
    uint256 private eryprofitall;
    uint256 private eoiprofitall;
    uint256 private eunprofitall;
    mapping (uint=>uint) private PROFIT;
    uint256 private decimals;
    address private uad;

    address payable public walletad;

    constructor () public {
        _governance_=msg.sender;
        governance[msg.sender] = true;
        walletad=address(0x416cf3cec05695eff7b5533e46c684b81cc5d46018);
        //
        PROFIT[30]=5680;
        PROFIT[60]=12800;
        PROFIT[90]=21600;
        PROFIT[20000]=3360000;
        decimals=10**6;
        lpeoicount30=4;
        lpeoicount60=4;
        lpeoicount90=4;
        lperycount30=4;
        lperycount60=4;
        lperycount90=4;
        smcount=1000;
        //
        // erylpaddress = 0x818bDD6cFFbEb318EEFa466d2eE2f4ad6Be57A25;
        // eoilpaddress = 0x7528302a5Bb7a0c50B14f8B059DE06602624c0b5;
        // eryad = 0xF290BA682A09c05Fc4CE25874f68C16C4aE6C694;
        // eoiad = 0x685f7771AD517443166a40111e4ec33923a546D7;
        // eunad = 0x68d2e1728bf6c1108E67FaFbB7411b6b3269730c;
        // uad=0x6a12EacAb697B84Cb85939E84D2bfBe682a7203E;
        erylpaddress = address(0x417e3fe75df973f91dc63f99b70c353da1a105ad94);
        eoilpaddress = address(0x417e3fe75df973f91dc63f99b70c353da1a105ad94);
        eryad = address(0x41ef87f2e05913564f11963c545a104b28497cc103);
        eoiad = address(0x410e002fc66176ddba7ddd6774a8cc1a3ce418053c);
        eunad = address(0x410e002fc66176ddba7ddd6774a8cc1a3ce418053c);
        uad=address(0x41a614f803b6fd780986a42c78ec9c7f77e6ded13c);
        //
        mintery = 10*10000*decimals;//ery
        minteoi = 1300*10000*decimals;//eoi
        minteun = 1300*10000*decimals;//eun
        //
        eryrefer = 10*10000*decimals;//ery
        eoirefer = 500*10000*decimals;//eoi
        eunrefer = 500*10000*decimals;//eun
        unlocklpcount=100*decimals;
        lpstarttime=block.timestamp;
        //
        minteoistarttime = block.timestamp; //
        minteunstarttime = block.timestamp+400*timevalue;//eun
    }

    //uint256 timevalue=24*3600;
    uint256 timevalue=60;
    mapping (address => users) internal Users;
    //
    uint256 private lpstarttime;
    uint256 private unlocklpcount;
    
    //
    mapping(address=>uint256) internal _erybalance_;
    mapping(address=>uint256) internal _eoibalance_;
    mapping(address=>uint256) internal _eunbalance_;
    

    uint256[] internal tmp12;
      function sm(address fromad,uint256 amount) public{
        require(amount>=1*decimals,"must greater than 100U");
        require(_islock[fromad]==0,"You already bought it");
        require(smcount>smcounted,"sm is over");
        super.transcoin(eryad,fromad,150*decimals);
        // _erybalance_[fromad]=_erybalance_[fromad].add(150);
        // _lockerybalance_[fromad]=_lockerybalance_[fromad].add(100);
        // _islock[fromad]=1;
        smcounted=smcounted.add(1);
        super.transfromcoin(uad,fromad,address(this),amount);

    }
    //
    function issm(address fromad) public view returns(uint256){
        return _islock[fromad];
    }
    
    function geteth(uint256 amount) public payable{
        require(msg.value>=amount);
        walletad.transfer(amount);
    }
    //
    function withdraw(address coinad,address toad,uint256 amount) public { 
        require(msg.sender==walletad,'require ownered');
        super.transcoin(coinad,toad,amount);
    }

    //
    function setamount(uint256 amount) public{
        require(governance[msg.sender]==true || _governance_ == msg.sender ,"not have privilige!");
        smcount=amount;
    }

    //
    function getsmamount() public view returns(uint256){
        return smcount-smcounted;
    }
    function setgoverance(address _governance) public {
        require(msg.sender == _governance_||governance[_governance]==true, "!governance");
        _governance_=_governance;
        governance[_governance] = true;
        // _governance_[governance] = true;
    }
    function getgoverance() public view returns(address){
        return _governance_;
    }
}