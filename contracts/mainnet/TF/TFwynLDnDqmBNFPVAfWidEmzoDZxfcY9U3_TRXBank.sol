//SourceUnit: TRXBank.sol

// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.4;

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract TRXBank {
        address private owner;

        uint public INTERVAL_TIMES = 10 days;
        uint public DEPOSIT_GAP_TIME = 24 hours;
        uint public BACK_RATE = 110;

        struct Deposit {
            uint time;
            uint amount;
            bool withdrawed;
            uint backAmount;
        }

        struct Deposits {
            Deposit[] deposits;
            uint withdrawIndex;
        }

        mapping(address=>Deposits) public userDeposits;
        mapping(address=>address) public refs;
        mapping(address=>uint) public _totalDepositAmount;
        mapping(address=>uint) public _totalWithdrawAmount;
        mapping(address=>uint) public _totalADepositAmount;


        uint public userCount;
        uint public minAmount = 1;
        uint public maxAmount = 1000;


        address public feeAddress1;
        uint public feeRate1;
        address public feeAddress2;
        uint public feeRate2;

        IERC20 public airToken;

        //0.000005
        uint public AIRPORT_TRX_RATE = 5;
        uint public AIRPORT_TOKEN_RATE = 1000000;


        uint public refFeeRate1;
        uint public refFeeRate2;
        
        constructor(uint _intervalTimes, uint _backRate, uint _depositGapTime, uint _refFeeRate1, uint _refFeeRate2) {
            owner = msg.sender;

            INTERVAL_TIMES = _intervalTimes;
            DEPOSIT_GAP_TIME = _depositGapTime;

            BACK_RATE = _backRate;

            refFeeRate1 = _refFeeRate1;
            refFeeRate2 = _refFeeRate2;
        }

        function min(uint a, uint b) private pure returns(uint){
            return a < b ? a : b;
        }

        function deposit(address ref) external payable {
            uint amount = msg.value;

            require((amount >= minAmount * 10**6) && (amount<= maxAmount * 10**6), "ERR: 0");

            require(ref != msg.sender, "ERR: 1");
            if(refs[msg.sender]== address(0)){
                    require(userDeposits[ref].deposits.length>0 || ref == address(this), "ERR: 2");
                    refs[msg.sender] = ref;
            }

            if(userDeposits[msg.sender].deposits.length>0){
                require(block.timestamp >= (userDeposits[msg.sender].deposits[userDeposits[msg.sender].deposits.length-1].time + DEPOSIT_GAP_TIME),  "ERR: 3" );
            }
            
            if(userDeposits[msg.sender].deposits.length == 0){
                userCount ++;
            }

            userDeposits[msg.sender].deposits.push(
                Deposit({time: block.timestamp, amount: amount, withdrawed: false, backAmount:0})
            );

            _totalADepositAmount[msg.sender] += amount;

            if(address(feeAddress1)!=address(0) && feeRate1>0){
                safeTransferTRX(feeAddress1,amount*feeRate1/100);
            }

            if(address(feeAddress2)!=address(0) && feeRate2>0){
                safeTransferTRX(feeAddress2,amount*feeRate2/100);
            }

            address ref1 = address(refs[msg.sender]);
            if(ref1!=address(0)){
                uint amount2 = amount ;
                if(ref1 != address(this)){
                    (uint amount1,,,) = getWithDrawDeposit(ref1);
                    amount2 = min(amount1,amount);
                }
                safeTransferTRX(ref1,amount2*refFeeRate1/100);
            }

            address ref2 = address(refs[ref1]);
            if(ref2!=address(0)){
                uint amount2 = amount ;
                if(ref1 != address(this)){
                    (uint amount1,,,) = getWithDrawDeposit(ref2);
                    amount2 = min(amount1,amount);
                }
                safeTransferTRX(ref2,amount2*refFeeRate2/100);
            }

            if( address(airToken) != address(0)){
                uint tokenBalance = airToken.balanceOf(address(this));
                if(AIRPORT_TRX_RATE>0 && AIRPORT_TOKEN_RATE>0){
                    if(tokenBalance >= (amount * AIRPORT_TOKEN_RATE / AIRPORT_TRX_RATE)){
                        if(amount * AIRPORT_TOKEN_RATE / AIRPORT_TRX_RATE>0){
                            airToken.transfer(msg.sender, amount * AIRPORT_TOKEN_RATE / AIRPORT_TRX_RATE);
                        }
                    }
                }
            }

            if(userDeposits[msg.sender].deposits.length>1){
                    //check lastone between withdrawIndex
                    Deposit storage withdrawDeposit = userDeposits[msg.sender].deposits[userDeposits[msg.sender].withdrawIndex];
                    require(!withdrawDeposit.withdrawed, "already withdraw");  

                    if( block.timestamp >= (withdrawDeposit.time + INTERVAL_TIMES) ){ //time check
                        if( amount >=  withdrawDeposit.amount ) { //amount check

                            uint backAmount = withdrawDeposit.amount * BACK_RATE / 100;
                            if( address(this).balance >= backAmount ){ //balance check

                                if((totalDepositAmount(msg.sender) - withdrawDeposit.amount) + (_totalDepositAmount[msg.sender]+amount) >=
                                    (_totalWithdrawAmount[msg.sender] + backAmount)){
                                    //all passed!
                                    userDeposits[msg.sender].withdrawIndex += 1;
                                    withdrawDeposit.withdrawed = true;
                                    withdrawDeposit.backAmount = backAmount;

                                    _totalADepositAmount[msg.sender] -= withdrawDeposit.amount;
                                    _totalWithdrawAmount[msg.sender] += backAmount;

                                    safeTransferTRX(msg.sender,backAmount);
                                }
                            }
                        }
                    }
            }

            _totalDepositAmount[msg.sender] += amount;
        }

        function getWithDrawDeposit(address user) public view returns (uint amount,uint time ,bool withdrawed,uint backAmount){
            return getWithdrawInfo(user, userDeposits[user].withdrawIndex);
        }

        function getWithdrawIndex(address user) public view returns(uint) {
            return userDeposits[user].withdrawIndex;
        }

        function getWithdrawInfo(address user, uint index) public view returns(uint amount,uint time ,bool withdrawed,uint backAmount) {
            if(index>=0 && index < userDeposits[user].deposits.length){
                Deposit memory info =  userDeposits[user].deposits[index];
                return (info.amount, info.time, info.withdrawed,info.backAmount);
            }
            return (0,0,false,0);
        }

        function totalDeposit(address user) public view returns(uint){
            return userDeposits[user].deposits.length;
        }

        function checkRefValid(address ref) public view returns(bool) {
            return userDeposits[ref].deposits.length>0 || ref == address(this);
        }

        function totalDepositAmount(address user)public view returns(uint){
            return _totalADepositAmount[user];
        }
        
        function contractBalance() public view returns(uint){
            return address(this).balance;
        }
        
        function myBalance() public view returns(uint){
            return address(msg.sender).balance;
        }
        
        function leftTime() public view returns(uint){
            if(userDeposits[msg.sender].deposits.length>0){
                Deposit memory lastDeposit = userDeposits[msg.sender].deposits[userDeposits[msg.sender].deposits.length-1];
                if(DEPOSIT_GAP_TIME > (block.timestamp - lastDeposit.time)){
                    return DEPOSIT_GAP_TIME - (block.timestamp - lastDeposit.time);
                }
                
            }
            return 0;
        }

        function safeTransferTRX(address receipt, uint amount) private {
            if(amount>0 && address(this)!=receipt){
                payable(receipt).transfer(amount);
            }                
        }

        // ------------- owner -------------------------------------------------
        function setMinAmount(uint _minAmount) public onlyOwner{
            minAmount = _minAmount;
        }

        function setMaxAmount(uint _maxAmount) public onlyOwner{
            maxAmount = _maxAmount;
        }

        function setProjectAddressAndFee1(address _feeAddress, uint fee) public onlyOwner{
            feeAddress1 = _feeAddress;
            feeRate1 = fee;
            require(refFeeRate1+refFeeRate2+feeRate1+feeRate2<=100, "over 100%");
        }

        function setProjectAddressAndFee2(address _feeAddress, uint fee) public onlyOwner{
            feeAddress2 = _feeAddress;
            feeRate2 = fee;
            require(refFeeRate1+refFeeRate2+feeRate1+feeRate2<=100, "over 100%");
        }

        function setAirToken(address tokenAddr) external onlyOwner {
            airToken = IERC20(tokenAddr);
        }

        function setAirportRate(uint rate1, uint rate2) external onlyOwner {
            AIRPORT_TRX_RATE = rate1;
            AIRPORT_TOKEN_RATE = rate2;
        }
         
        function transferOwner(address newOwner) external onlyOwner {
            owner = newOwner;
        }

        receive() external payable{}

        modifier onlyOwner {
            require(owner == msg.sender, "auth");
            _;
        }
}