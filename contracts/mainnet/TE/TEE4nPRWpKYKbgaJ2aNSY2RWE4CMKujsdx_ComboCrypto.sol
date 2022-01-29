//SourceUnit: combocrypto.sol

pragma solidity ^0.5.4;

contract ComboCrypto {
    uint256 private constant TOP_ENTRY_RATE = 100;
    uint256 private constant SECOND_ENTRY_RATE = 200;

    
    uint256 public latestReferrerCode;
    
    address payable private adminAccount_;
    address payable private centerAccount_;
    address payable private referenceAccount_;
    address payable private withdrawAccount_;
    mapping(uint256=>address) idToAddress;
    mapping(address=>uint256) addresstoUid;
    
    bool ten_active;

    event Registration(string waddress,address investor,uint256 investorId,address referrer,uint256 referrerId);
    event Deposit(address investor,uint256 investorId,uint256 amount);
    
  
    constructor(address payable _admin,address payable _center,address payable _ref,address payable _withdraw) public 
    {
        referenceAccount_ = _ref;
        adminAccount_=_admin;
        centerAccount_=_center;
        withdrawAccount_=_withdraw;
        latestReferrerCode++;
        idToAddress[latestReferrerCode]=_ref;
        addresstoUid[_ref]=latestReferrerCode;
    }

    function setReferenceAccount(address payable _newReferenceAccount) public  {
        require(_newReferenceAccount != address(0) && msg.sender==adminAccount_);
        referenceAccount_ = _newReferenceAccount;
    }
    
    function setAdminAccount(address payable _newAccount) public  {
        require(_newAccount != address(0) && msg.sender==adminAccount_);
        adminAccount_ = _newAccount;
    }
    
    function setCenterAccount(address payable _newAccount) public  {
        require(_newAccount != address(0) && msg.sender==adminAccount_);
        centerAccount_ = _newAccount;
    }
    
    function setWithdrawAccount(address payable _newAccount) public  {
        require(_newAccount != address(0) && msg.sender==adminAccount_);
        withdrawAccount_ = _newAccount;
    }
    
    function withdrawLostTRXFromBalance(address payable _sender,uint256 _amt) public {
        require(msg.sender == adminAccount_, "onlyOwner");
        _sender.transfer(_amt);
    }
    
    
    function active_ten(uint8 set) public {
        require(msg.sender == adminAccount_, "onlyOwner");
        if(set==1)
        ten_active=true;
        else
        ten_active=false;
    }

    function getBalance() public view returns (uint256) 
    {
        return address(this).balance;
    }


    function multisendTRX(address payable[]  memory  _contributors, uint256[] memory _balances) public payable {
        uint256 total = msg.value;
        uint256 i = 0;
        for (i; i < _contributors.length; i++) {
            require(total >= _balances[i] );
            total = total-_balances[i];
            _contributors[i].transfer(_balances[i]);
        }
    }


    function _invest(string memory _user,uint256 _referrerCode) public payable
    {
        if(addresstoUid[msg.sender]==0)
        {
            latestReferrerCode++;
            idToAddress[latestReferrerCode]=msg.sender;
            addresstoUid[msg.sender]=latestReferrerCode;
            emit Registration(_user,msg.sender,latestReferrerCode,idToAddress[_referrerCode],_referrerCode);
        }
        
        if(ten_active)
        {
         uint256 adminPercentage = (msg.value*TOP_ENTRY_RATE)/1000;
         adminAccount_.transfer(adminPercentage);
        }
        
        uint256 centerPercentage = (msg.value*SECOND_ENTRY_RATE)/1000;
        centerAccount_.transfer(centerPercentage);
        
        withdrawAccount_.transfer(address(this).balance);
        emit Deposit(msg.sender,addresstoUid[msg.sender], msg.value);
    }

}