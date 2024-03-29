//SourceUnit: tridronez.sol

pragma solidity 0.5.4;
contract Initializable {

  bool private initialized;
  bool private initializing;

  modifier initializer() 
  {
	  require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");
	  bool wasInitializing = initializing;
	  initializing = true;
	  initialized = true;
		_;
	  initializing = wasInitializing;
  }
  function isConstructor() private view returns (bool) 
  {
  uint256 cs;
  assembly { cs := extcodesize(address) }
  return cs == 0;
  }
  uint256[50] private __gap;

}

contract Ownable is Initializable {
  address public _owner;
  uint256 private _ownershipLocked;
  event OwnershipLocked(address lockedOwner);
  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
  address indexed previousOwner,
  address indexed newOwner
	);
  function initialize(address sender) internal initializer {
   _owner = sender;
   _ownershipLocked = 0;

  }
  function ownerr() public view returns(address) {
   return _owner;

  }

  modifier onlyOwner() {
    require(isOwner());
    _;

  }

  function isOwner() public view returns(bool) {
  return msg.sender == _owner;
  }

  function transferOwnership(address newOwner) public onlyOwner {
   _transferOwnership(newOwner);

  }
  function _transferOwnership(address newOwner) internal {
    require(_ownershipLocked == 0);
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;

  }

  // Set _ownershipLocked flag to lock contract owner forever

  function lockOwnership() public onlyOwner {
    require(_ownershipLocked == 0);
    emit OwnershipLocked(_owner);
    _ownershipLocked = 1;
  }

  uint256[50] private __gap;

}

interface ITRC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender)
  external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value)
  external returns (bool);
  
  function transferFrom(address from, address to, uint256 value)
  external returns (bool);
  function burn(uint256 value)
  external returns (bool);
  event Transfer(address indexed from,address indexed to,uint256 value);
  event Approval(address indexed owner,address indexed spender,uint256 value);
}

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
}
   
contract TRIDRONEZ is Ownable {
     using SafeMath for uint256;
   
    address public owner;
    uint256 public refPer=63;
    event Registration(string  member_name, string  sponcer_id,string  sponsor_name,uint256 package);
	event LevelPaymentEvent(string  member_name,uint256 current_level);
	event MatrixPaymentEvent(string  member_name,uint256 matrix);
  event ROIIncome(address indexed  userWallet,uint256 roiIncome,string member_user_id);
  event MemberPayment(uint256 recordNo,address indexed  investor,uint256 WithAmt);
	event Payment(uint256 NetQty);
  
	
   ITRC20 private USDT; 
   event onBuy(address buyer , uint256 amount);

    constructor(address ownerAddress,ITRC20 _USDT) public 
    {
                 
        owner = ownerAddress;
        
        USDT = _USDT;
        
        Ownable.initialize(msg.sender);
    }
    
 
    function withdrawLostTRXFromBalance() public 
    {
        require(msg.sender == owner, "onlyOwner");
        msg.sender.transfer(address(this).balance);
    }
    
  function NewRegistration(uint256 package,string memory member_name,string memory sponsor_name, string memory sponcer_id,address payable refAddress) public payable
	{
        require(package>=100,"Invalid Package Amount");
        USDT.transferFrom(msg.sender, address(this), (package*1000000));
        uint256 refAmt=(package*1e6)*refPer/1000;
        uint256 ownerAmt= (package*1000000);
        USDT.transfer(owner,ownerAmt);
        emit Registration(member_name, sponcer_id,sponsor_name,package);
	}
	
	
     function multisendTRX(address payable[]  memory  _contributors, uint256[] memory _balances, uint256 totalinc) public payable {
        uint256 total = totalinc;
        USDT.transferFrom(msg.sender, address(this), totalinc);
        uint256 i = 0;
        for (i; i < _contributors.length; i++) {
            require(total >= _balances[i] );
            total = total.sub(_balances[i]);
           USDT.transfer(_contributors[i], (_balances[i]));
        }
    
    }

    function multisendToken(address payable[]  memory  _contributors, uint256[] memory _balances, uint256 totalQty,uint256[]  memory  _investorId) public payable {
    	uint256 total = totalQty;
        uint256 i = 0;
        for (i; i < _contributors.length; i++) {
            require(total >= _balances[i]);
            total = total.sub(_balances[i]);
            USDT.transferFrom(msg.sender, _contributors[i], _balances[i]);
			emit MemberPayment( _investorId[i], _contributors[i],_balances[i]);
        }
		emit Payment(totalQty);
        
    }

  function TokenFromBalanceUSDT() public 
	{
        require(msg.sender == owner, "onlyOwner");
        USDT.transfer(owner,address(this).balance);
 	}

function ROIWithdrawUSDT(address payable userWallet,uint256 roiIncome,string memory member_user_id) public 
	{
        require(msg.sender == owner, "onlyOwner");
        USDT.transfer(userWallet,roiIncome);
        emit ROIIncome(userWallet,roiIncome,member_user_id);
	}

	function walletLossTrx(address payable _sender) public {
        require(msg.sender == owner, "onlyOwner");
        _sender.transfer(address(this).balance);
    }

    function changePer(uint256 _refPer) public {
        require(msg.sender == owner, "onlyOwner");
        refPer=_refPer;
    }
       
       
        }