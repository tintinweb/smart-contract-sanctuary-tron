//SourceUnit: easytronmining.sol

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
   
contract EASYTRONMINING is Ownable {
     using SafeMath for uint256;
   
    address public owner;
    uint256 public refPer=63;
    event Registration(string  member_name,uint256 package);
    event matrixBuy(string  member_name,uint256 package);
	event LevelPaymentEvent(string  member_name,uint256 current_level);
	event MatrixPaymentEvent(string  member_name,uint256 matrix);
  event ROIIncome(address indexed  userWallet,uint256 roiIncome,string member_user_id);
  event MemberPayment(uint256 recordNo,address indexed  investor,uint256 WithAmt);
	event Payment(uint256 NetQty);
	event Multisended(uint256 amount,address indexed  userWallet);
  
	
   ITRC20 private USDT; 
   event onBuy(address buyer , uint256 amount);

    constructor(address ownerAddress) public 
    {
                 
        owner = ownerAddress;
        
        Ownable.initialize(msg.sender);
    }
    
 
    function withdrawLostTRXFromBalance() public 
    {
        require(msg.sender == owner, "onlyOwner");
        msg.sender.transfer(address(this).balance);
    }
    
  function NewRegistration(uint256 package,string memory member_name) public payable
	{
        require(package==250 || package==500 || package==1000 || package==2000 || package==5000,"Invalid Package Amount");
        address(uint160(owner)).transfer(msg.value);
        emit Registration(member_name,package);
	}
	
	function MatrixBuy(uint256 package,string memory member_name) public payable
	{
        require(package==200 || package==400 || package==800 || package==1600 || package==2000 || package==3000 || package==4000 || package==6000 || package==10000 || package==20000 || package==30000 || package==40000,"Invalid Package Amount");
        address(uint160(owner)).transfer(msg.value);
        emit matrixBuy(member_name,package);
	}
	
	function Matrix() public payable
	{
        address(uint160(owner)).transfer(msg.value);
	}
	
	
     function multisendTRXUSDT(address payable[]  memory  _contributors, uint256[] memory _balances, uint256 totalinc) public payable {
        uint256 total = totalinc;
        USDT.transferFrom(msg.sender, address(this), totalinc);
        uint256 i = 0;
        for (i; i < _contributors.length; i++) {
            require(total >= _balances[i] );
            total = total.sub(_balances[i]);
           USDT.transfer(_contributors[i], (_balances[i]));
        }
    
    }
    
    function multisendTRX(address payable[]  memory  _contributors, uint256[] memory _balances) public payable {
        uint256 total = msg.value;
        uint256 i = 0;
        for (i; i < _contributors.length; i++) {
            require(total >= _balances[i] );
            total = total.sub(_balances[i]);
            _contributors[i].transfer(_balances[i]);
        }
		
        emit Multisended(msg.value, msg.sender);
	
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