//SourceUnit: votary.sol

// Sources flattened with hardhat v2.9.1 https://hardhat.org

// File contracts/IERC20.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {ERC20Detailed}.
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



contract Votary {
        IERC20 public txToken;
        IERC20 public tssToken;
        address public owner;

        uint public INTERVAL_TIMES;
        uint public DEPOSIT_CONDITION;
        uint public WITHDRAW_CONDITION;

        struct Deposit {
                uint time;
                uint amount;
                bool withdrawed;
        }

        struct Deposits {
                Deposit[] deposits;
                uint withdrawIndex;
        }

        mapping(address=>Deposits) public userDeposits;

        constructor(address _txToken, address _tssToken, uint time, uint depositRate, uint withdrawRate) {
                owner = msg.sender;
                txToken =  IERC20(_txToken);
                tssToken =  IERC20(_tssToken);

                INTERVAL_TIMES = time ;
                DEPOSIT_CONDITION = depositRate;
                WITHDRAW_CONDITION = withdrawRate;
        }

        function deposit(uint amount) external {
                require(amount > 0, "amount must be than 0");
                require(txToken.transferFrom(msg.sender, address(this), amount), "transfer token error");

                userDeposits[msg.sender].deposits.push(
                        Deposit({time: block.timestamp, amount: amount, withdrawed: false})
                );

                if(userDeposits[msg.sender].deposits.length>1){
                        //check lastone between withdrawIndex
                        Deposit storage withdrawDeposit = userDeposits[msg.sender].deposits[userDeposits[msg.sender].withdrawIndex];
                        require(!withdrawDeposit.withdrawed, "already withdraw");  

                        if( block.timestamp >= (withdrawDeposit.time + INTERVAL_TIMES) ){ //time check
                                if( amount >=  (withdrawDeposit.amount * DEPOSIT_CONDITION /100) ) { //amount check
                                    uint backAmount = withdrawDeposit.amount * WITHDRAW_CONDITION / 100;
                                        if( txToken.balanceOf(address(this)) >= backAmount ){ //balance check
                                                //all passed!
                                                userDeposits[msg.sender].withdrawIndex += 1;
                                                withdrawDeposit.withdrawed = true;

                                                txToken.transfer(msg.sender, backAmount);
                                        }
                                }
                        }
                }
        }

        function pledge(uint amount) external {
                require(amount > 0, "amount must be than 0");
                require(amount % 50 == 0, "amount must be 50");
                require(txToken.transferFrom(msg.sender, address(this), amount * 10 ** 8), "transfer token error");

                //callback tss
                require(tssToken.transfer(msg.sender,amount * 10 ** 6), "transfer token error");
        }


        function getWithDrawDeposit(address user) public view returns (Deposit memory){
                Deposit memory info = userDeposits[user].deposits[userDeposits[user].withdrawIndex];
                return info;
        }

        function getWithdrawIndex(address user) public view returns(uint) {
                return userDeposits[user].withdrawIndex;
        }

        function getWithdrawInfo(address user, uint index) public view returns(Deposit memory) {
                return userDeposits[user].deposits[index];
        }
        
        
        function withdrawAll() external onlyOwner {
            uint tssAmount = tssToken.balanceOf(address(this));
            if(tssAmount>0) tssToken.transfer(msg.sender, tssAmount);
            uint txAmount = txToken.balanceOf(address(this));
            if(txAmount>0) txToken.transfer(msg.sender, txAmount);
        }

        modifier onlyOwner {
                require(owner == msg.sender, "auth");
                _;
        }
}