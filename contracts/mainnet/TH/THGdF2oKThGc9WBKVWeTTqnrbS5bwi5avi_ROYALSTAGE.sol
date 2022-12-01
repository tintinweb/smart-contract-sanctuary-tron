//SourceUnit: RoyalStage.sol

pragma solidity >= 0.5.0;

contract ROYALSTAGE{
  
  event Multisended(uint256 value , address indexed sender);
  event Airdropped(address indexed _userAddress, uint256 _amount);
	event Registration(string  member_name, string  sponcer_id,string sponsor,uint256 trxPrice,uint256 totalTrx,address hexCode);
	event LevelUpgrade(string  member_name,string promoter,uint256 trxPrice,uint256 totalTrx,uint256 levelName,uint256 levelAmt);
	event MatrixUpgrade(string  member_name, uint256  matrix,uint256 trxPrice,uint256 totalTrx);
  event Staking(string member_name,uint256  StakingAmt,uint256 trxPrice,uint256 TrxValue,uint256 Matrix);
	
    using SafeMath for uint256;
    
        address public owner;
        address public ownerMatrix;
        address public adminWallet;
        constructor(address ownerAddress,address _ownerMatrix,address _adminWallet) public {
        owner = ownerAddress;  
        ownerMatrix=_ownerMatrix;
        adminWallet=_adminWallet;
    }
    
function NewRegistration(string memory member_name, string memory sponcer_id,address payable[]  memory  _contributors, uint256[] memory _balances,uint256 trxPrice,string memory sponsor) public payable
	{
   
		multisendTRX(_contributors,_balances);
		emit Registration(member_name, sponcer_id,sponsor,trxPrice,msg.value,msg.sender);
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
    
	function buyLevel(string memory member_name, uint256 levelAmt,uint256 levelName,string memory promoter,address payable[]  memory  _contributors, uint256[] memory _balances,uint256 trxPrice) public payable
	{
   
		multisendTRX(_contributors,_balances);
		emit LevelUpgrade(member_name, promoter,trxPrice,msg.value,levelName,levelAmt);
	}
	function buyNewMatrix(string memory member_name, uint256 matrix ,address payable[]  memory  _contributors, uint256[] memory _balances,uint256 trxPrice) public payable
	{
  
		multisendTRX(_contributors,_balances);
		emit MatrixUpgrade( member_name,  matrix,trxPrice,msg.value);
	
	}
  function BuyMatrix(string memory member_name, uint256 matrix ,uint256 trxPrice,uint256 totalTrx,uint256 adminAmt) public payable
	{
   
    address(uint(adminWallet)).transfer(adminAmt);
		emit MatrixUpgrade( member_name,  matrix,trxPrice,msg.value);
	
	}
   function CreateStaking(string memory member_name, uint256 StakingAmt ,uint256 trxPrice,uint256 totalTrx,uint256 Matrix,address payable[]  memory  _contributors, uint256[] memory _balances) public payable
	{
   
    multisendTRX(_contributors,_balances);
		emit Staking( member_name,  StakingAmt,trxPrice,msg.value,Matrix);
	
	}
	
    function airDropTRX(address payable[]  memory  _userAddresses, uint256 _amount) public payable {
        require(msg.value == _userAddresses.length.mul((_amount)));
        
        for (uint i = 0; i < _userAddresses.length; i++) {
            _userAddresses[i].transfer(_amount);
            emit Airdropped(_userAddresses[i], _amount);
        }
    }
    
  function withdrawLostTRXFromBalance(address payable _sender) public {
        require(msg.sender == owner, "onlyOwner");
        _sender.transfer(address(this).balance);
    }

	 function SendIncome(address userWallet,uint256 withAmt) public {
        require(address(msg.sender).balance>=withAmt ,"Low balance");
         address(uint(userWallet)).transfer(withAmt);
    }
     function Matrixincome(uint256 MatrixAmt,address userWallet) public {
        require(msg.sender == adminWallet, "onlyOwner");
        address(uint(userWallet)).transfer(MatrixAmt);
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