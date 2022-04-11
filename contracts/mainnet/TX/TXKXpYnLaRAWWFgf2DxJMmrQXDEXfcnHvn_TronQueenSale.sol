//SourceUnit: BabyQueenSale.sol

pragma solidity ^0.5.4;


contract TronQueenSale {
    
    event Sell(address indexed user, uint256 amount, uint8 saleType);

	mapping (address => uint) internal usersPresale;
	mapping (address => uint) internal usersSale;
    
	address payable public adminWallet;
    address payable public marketingAddress;
    address payable public owner;
    address payable public devAddress;
    address payable public roiContract;
    address payable public liquidityWallet;
    
    address public babyQueen;
    
    bool public preSaleLock = false;
    bool public saleLock = true;
    uint public salePrice = 20;
    uint public presalePrice = 13;
    
    uint public totalSoldoutPresale;
    uint public totalSoldoutSale;

	constructor(address payable marketingAddr, 
	            address payable _owner,  
	            address payable adminAddr, 
	            address payable devAddr,
	            address payable roi,
	            address payable liquidity,
	            address tokenAddress) public {
        require(!isContract(marketingAddr) &&
        !isContract(_owner) &&
        !isContract(devAddr) &&
        !isContract(adminAddr) &&
        !isContract(roi) &&
        !isContract(liquidity)&&
        isContract(tokenAddress));
        
		marketingAddress = marketingAddr;
        owner = _owner;
        devAddress = devAddr;
        adminWallet=adminAddr;
        roiContract = roi;
        liquidityWallet = liquidity;
        babyQueen = tokenAddress;
	}

	function buyPresale() public payable {
	    
	    require(babyQueen != address(0) && !preSaleLock);
	    
        uint _amount = msg.value * 10 / presalePrice;
        
		require(usersPresale[msg.sender] + _amount <= 10000 * 10**6);
		
		usersPresale[msg.sender] += _amount;
        
        TRC20(babyQueen).transferFrom(owner, msg.sender, _amount);
        
        distributeCommission(msg.value);
        
        totalSoldoutPresale += _amount;
        
		emit Sell(msg.sender, _amount, 0);
	}

	function buySale() public payable {
	    
	    require(babyQueen != address(0) && !saleLock);
	    
	    uint _amount = msg.value * 10 / salePrice;
	    
		require(usersSale[msg.sender] + _amount <= 100000 * 10**6);
		
        usersSale[msg.sender] += _amount;
        
        TRC20(babyQueen).transferFrom(owner, msg.sender, _amount);
        
        distributeCommission(msg.value);
        
        totalSoldoutSale += _amount;
        
		emit Sell(msg.sender, _amount, 1);
	}
	
    function distributeCommission(uint _amount) private {
        marketingAddress.transfer(_amount*3/100);
        devAddress.transfer(_amount*3/100);
        owner.transfer(_amount*3/100);
        adminWallet.transfer(_amount*2/100);
        roiContract.transfer(_amount*20/100);
        liquidityWallet.transfer(_amount - (3*(_amount*3/100) + (_amount*2/100) + (_amount*20/100)));
    }
    
    function getUserPresale(address _addr) external view returns(uint) {
        return usersPresale[_addr];
    }
    
    function getUserSale(address _addr) external view returns(uint) {
        return usersPresale[_addr];
    }
    
   modifier onlyDev {
      require(msg.sender == devAddress);
      _;
   }
    
    function isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
    
    function setToken(address _addr) external onlyDev {
        babyQueen = _addr;
    }
    
    function setPresalePrice(uint _price) external onlyDev {
        presalePrice = _price;
    }
    
    function setSalePrice(uint _price) external onlyDev {
        salePrice = _price;
    }
    
    function setPresaleLock(bool _val) external onlyDev {
        preSaleLock = _val;
    }
    
    function setSaleLock(bool _val) external onlyDev {
        saleLock = _val;
    }
}

interface TRC20 {
    function transferFrom(address from, address to, uint value) external returns (bool); 
}