//SourceUnit: Investpool.sol

pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract InvestPool {
    address USDT_ADDRESS;
    address OWNER_ADDRESS;

    uint256 main_balance = 0;
    uint256 withdrawable_balance = 0;
    bool poolClosed = false;

    constructor(address _USDT_ADDRESS, address _OWNER_ADDRESS) {
        USDT_ADDRESS = _USDT_ADDRESS; // USDT TRC20 Contract Address
        OWNER_ADDRESS = _OWNER_ADDRESS; // Owner's Address
    }

    function depositToken( uint256 amount) public  {
        require(amount % 100 == 0, "Amount must be divisible by 100");
        require(IERC20(USDT_ADDRESS).balanceOf(msg.sender) >= amount, "Your token amount must be greater then you are trying to deposit");
        require(IERC20(USDT_ADDRESS).approve(address(this), amount));
        require(IERC20(USDT_ADDRESS).transferFrom(msg.sender, address(this), amount)); 

        if(poolClosed){
              withdrawable_balance += amount; 
        } else {
            if(main_balance < 80000000000){
                main_balance += amount / 100 * 80;
                withdrawable_balance += amount / 100 * 20; 
            } else {
             withdrawable_balance += main_balance + amount;
             main_balance = 0;
             poolClosed = true;
            }
        }

    }
    
     function renounceOwnership(address _address) public {
        require(msg.sender == address(OWNER_ADDRESS), "You are not contract owner");
        OWNER_ADDRESS = _address;
    }

     function withdraw(uint256 amount, address _address) public {
        require(msg.sender == address(OWNER_ADDRESS), "You are not contract owner");
        require(amount <= withdrawable_balance, "Too few funds available");
        require(IERC20(USDT_ADDRESS).transfer(_address, amount), "the transfer failed");
        withdrawable_balance -= amount;
    }

    function fundBalance() public view virtual returns (uint256) {
        return main_balance;
    }

     function withdrawableBalance() public view virtual returns (uint256) {
        return withdrawable_balance;
    }
    
     function owner() public view virtual returns (address) {
        return OWNER_ADDRESS;
    }

}