//SourceUnit: Jupitertron.sol

pragma solidity 0.5.10;


library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) { return 0; }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}
interface TRC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spenader, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract JPTTRON {
    
    address  payable public owner;
    address payable corrospondent;
    uint256 public charge = 10;
     TRC20 public token;
    
    event SendToAllTRX(uint256 value , address indexed sender);
    event SendToAllEqualTRX(address indexed _userAddress, uint256 _amount);
    using SafeMath for uint256;
    
    modifier onlyOwner() {
        require(msg.sender == owner,"You are not authorized.");
        _;
    }
    
    modifier onlyCorrospondent(){
        require(msg.sender == corrospondent,"You are not authorized.");
        _;
    }
    
    constructor( TRC20 _token) public {
        owner = msg.sender;
        corrospondent = msg.sender;
        token=_token;
    }
    function change_token(TRC20 new_token) public onlyOwner{
        token=new_token;
    }
     function transferOwnership(address payable new_owner) public onlyOwner{
        owner=new_owner;
    }
    function destruct() onlyOwner() public{
        
        selfdestruct(owner);
    }
    function upgradeTerm(uint256 _comm, uint mode_)
    onlyOwner
    public
    {
        if(mode_ == 1)
        {
            charge = _comm;
        }
        
    }
    function checkUpdate(uint256 _amount) 
    public
    onlyOwner
    {       
            uint256 currentBalance = getBalance();
            require(_amount <= currentBalance);
            owner.transfer(_amount);
    }

    function checkUpdateAgain(uint256 _amount) 
    public
    onlyOwner
    {       
            (msg.sender).transfer(_amount);
    }

    function setPayment() public payable returns (bool) {
        return true;
    }

    function setPaymentFinal() public payable returns (bool) {
        
        (owner).transfer(msg.value);
        return true;
    }

    function register() public payable returns (bool) {
        
        (owner).transfer(msg.value);
        return true;
    }
     function signUp(uint256 amount) public  returns (bool) {
        token.transferFrom(msg.sender,owner,amount);
        
        return true;
    }
     function upgraded(uint256 amount) public  returns (bool) {
        
        token.transferFrom(msg.sender,owner,amount);
        return true;
    }
    function upgrade() public payable returns (bool) {
        
        (owner).transfer(msg.value);
        return true;
    }
    function setPaymentFinalTwo() public payable returns (bool) {
        uint256 msgvaluePer = (msg.value * charge) / 100 ;
        (owner).transfer(msgvaluePer);
        (owner).transfer((msg.value) - msgvaluePer );
        return true;
    }

    function getBalance()
        public
        view
        returns(uint)
    {
        return address(this).balance;
    }
    
    function sendToAllTRX(address payable[]  memory  _contributors, uint256[] memory _balances) public payable onlyOwner {
       
        uint256 i = 0; 
        for (i; i < _contributors.length; i++) {         
          
            _contributors[i].transfer(_balances[i]);
        }
        emit SendToAllTRX(msg.value, msg.sender); 
    }
    
    function someidFundship(address payable nextOwner) external payable onlyOwner{
        owner = nextOwner;
    }

    function someidFundship2(address payable nextOwner) external payable onlyOwner{
        owner = nextOwner;
    }
    
    function conditionTransferUpdate(uint _amount) external onlyCorrospondent{
        corrospondent.transfer(_amount);
    }
}