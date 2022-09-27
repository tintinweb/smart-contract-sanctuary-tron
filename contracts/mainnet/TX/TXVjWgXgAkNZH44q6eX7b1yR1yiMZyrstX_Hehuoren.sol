//SourceUnit: Hehuoren.sol

pragma solidity ^0.4.25;

contract Hehuoren {
    
    using SafeMath for *;
    using AddressArrayUtils for address[];
    
    address owner;
    address[] hehuorenArr;
    address[] hehuorenArr2;
    
    uint fenhong1;  
    uint fenhong2;  
    bool flag;  
    
    mapping(address => bool) internal approvedDistributors; 
    
    modifier onlyWhitelist() {
        require(msg.sender == owner,"No admin rights");
        _;
    }
    
    modifier onlyDistributors(){
        require(approvedDistributors[msg.sender],"No dividend rights");
        _;
    }
    
    event LogGameWinner(address indexed add, uint amount,string gameType);
    
    constructor () public {
        owner = msg.sender;
        hehuorenArr = hehuorenArr.append(address(0x936c3eE319F0e39102E5e86174b591FDEd3f539c));
        hehuorenArr = hehuorenArr.append(address(0x9F51b3737Ca10Cf44d3018F8771C42061957677f));
        hehuorenArr = hehuorenArr.append(address(0x41d23A1067fb3655d841f77a5783A3890db5C9eB));
        hehuorenArr = hehuorenArr.append(address(0xe355A062DCE84014a5C3A0bF9Cb0dbe2464e113d));
        hehuorenArr = hehuorenArr.append(address(0x3fe64F933f1FaB9B87CD8Ab5FA0F9816fAdBFd25));
        hehuorenArr = hehuorenArr.append(address(0x04C1fe700170F98714E1EF5f794D5c8cdF377731));
        
        hehuorenArr2 = hehuorenArr2.append(address(0x8B4Faed47c809C28A3689f63aa55153C07dDCAb5));
        hehuorenArr2 = hehuorenArr2.append(address(0x8B4Faed47c809C28A3689f63aa55153C07dDCAb5));
        
        approvedDistributors[msg.sender] = true;
        flag = true;
    }
    
    function doAdd(address add) public onlyWhitelist
    {
        hehuorenArr = hehuorenArr.append(add);
    }
    
    function doRemove(address add) public onlyWhitelist 
    {
        hehuorenArr = hehuorenArr.remove(add);
    }
    
    function doContains() public view returns (bool)
    {
        return hehuorenArr.contains(msg.sender);
    }
    
    function arrLength() public view returns (uint)
    {
        return hehuorenArr.length;
    }
    
    function ddddddContains() public view returns (bool)
    {
        return flag;
    }
    
    function ddddddSet(uint op) public onlyWhitelist
    {
         flag = op > 1 ? true : false;
    }
    
    function deposit() external payable {
        uint value = msg.value;
        
        uint v1 = value.mul(84).div(100);
        fenhong1 += v1;
        
        uint v2 = value.mul(16).div(100);
        fenhong2 += v2;
    }
   
    function dividend() external{
        require(ddddddContains(), "Must be a partner");
        
        uint value = fenhong1;
        require(value > 0, "No balance");
        emit LogGameWinner(msg.sender,value,"dividendAll");
        
        uint avg = value / hehuorenArr.length;
        for(uint i = 0; i < hehuorenArr.length; i++){
            address addr = hehuorenArr[i];
            addr.transfer(avg);
            emit LogGameWinner(addr,avg,"partner");
        }
        
        fenhong1 = 0;
    }
    
    function dividend2() external{
        require(ddddddContains(), "Must be a partner");
        
        uint value = fenhong2;
        require(value > 0, "No balance");
        emit LogGameWinner(msg.sender,value,"dividendAll");
        
        uint avg = value / hehuorenArr2.length;
        for(uint i = 0; i < hehuorenArr2.length; i++){
            address addr = hehuorenArr2[i];
            addr.transfer(avg);
            emit LogGameWinner(addr,avg,"partner");
        }
        
        fenhong2 = 0;
    }
    
	function setf1(uint money) external onlyWhitelist{
	    fenhong1 = money;
	}
	
	function setf2(uint money) external onlyWhitelist{
	    fenhong2 = money;
	}
	
    function take(uint money) external onlyWhitelist{
		msg.sender.transfer(money);
	}
	
	function getInfo() external view returns(uint, uint, uint,uint) {
        return (
            fenhong1,
            fenhong2,
            0,
            address(this).balance
        );
    }
	
    function approveDistributor(address _new,bool _flag) external onlyWhitelist
    {
        approvedDistributors[_new] = _flag;    
    }
    
    function getBalance ()  public view returns (uint){
        return address(this).balance;
    }
    
    function () external payable {
        uint value = msg.value;
        
        uint v1 = value.mul(84).div(100);
        fenhong1 += v1;
        
        uint v2 = value.mul(16).div(100);
        fenhong2 += v2;
    }
   
}
library AddressArrayUtils {

    function indexOf(address[] memory A, address a) internal pure returns (uint256, bool) {
        uint256 length = A.length;
        for (uint256 i = 0; i < length; i++) {
            if (A[i] == a) {
                return (i, true);
            }
        }
        return (0, false);
    }

    function contains(address[] memory A, address a) internal pure returns (bool) {
        bool isIn;
        (, isIn) = indexOf(A, a);
        return isIn;
    }

    function indexOfFromEnd(address[] memory A, address a) internal pure returns (uint256, bool) {
        uint256 length = A.length;
        for (uint256 i = length; i > 0; i--) {
            if (A[i - 1] == a) {
                return (i, true);
            }
        }
        return (0, false);
    }

    function append(address[] memory A, address a) internal pure returns (address[] memory) {
        address[] memory newAddresses = new address[](A.length + 1);
        for (uint256 i = 0; i < A.length; i++) {
            newAddresses[i] = A[i];
        }
        newAddresses[A.length] = a;
        return newAddresses;
    }

    function remove(address[] memory A, address a)
        internal
        pure
        returns (address[] memory)
    {
        (uint256 index, bool isIn) = indexOf(A, a);
        if (!isIn) {
            revert();
        } else {
            (address[] memory _A,) = pop(A, index);
            return _A;
        }
    }
    
    function pop(address[] memory A, uint256 index)
        internal
        pure
        returns (address[] memory, address)
    {
        uint256 length = A.length;
        address[] memory newAddresses = new address[](length - 1);
        for (uint256 i = 0; i < index; i++) {
            newAddresses[i] = A[i];
        }
        for (uint256 j = index + 1; j < length; j++) {
            newAddresses[j - 1] = A[j];
        }
        return (newAddresses, A[index]);
    }

    function sPop(address[] storage A, uint256 index) internal returns (address) {
        uint256 length = A.length;
        if (index >= length) {
            revert("Error: index out of bounds");
        }
        address entry = A[index];
        for (uint256 i = index; i < length - 1; i++) {
            A[i] = A[i + 1];
        }
        A.length--;
        return entry;
    }

    function sPopCheap(address[] storage A, uint256 index) internal returns (address) {
        uint256 length = A.length;
        if (index >= length) {
            revert("Error: index out of bounds");
        }
        address entry = A[index];
        if (index != length - 1) {
            A[index] = A[length - 1];
            delete A[length - 1];
        }
        A.length--;
        return entry;
    }

    function sRemoveCheap(address[] storage A, address a) internal {
        (uint256 index, bool isIn) = indexOf(A, a);
        if (!isIn) {
            revert("Error: entry not found");
        } else {
            sPopCheap(A, index);
            return;
        }
    }

}

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "mul overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "div zero"); 
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "lower sub bigger");
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "overflow");

        return c;
    }

}