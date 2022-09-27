//SourceUnit: right(2).sol



contract Ownable  {
    address  public  _owner;
    address  public  _coo;
    address  public  _cfo;
    bool public paused = false;
    event  OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor(address ads) public payable{
        _owner  =  ads;
    }

    function owner() public view returns (address)  {
        return  _owner;
    }

    modifier onlyOwner(){
        require(msg.sender  ==  _owner);
        _;
    }

    modifier onlyCOO(){
        require(msg.sender  ==  _coo);
        _;
    }

    modifier onlyCFO(){
        require(msg.sender  ==  _cfo);
        _;
    }

    function setCoo(address  cooAddress)  public onlyOwner{
        _coo  =  cooAddress;
    }

    function setCfo(address  cfoAddress)  public onlyOwner{
        _cfo  =  cfoAddress;
    }

    function transferOwnership(address  newOwner)  public onlyOwner{
        require(newOwner  !=  address(0));
        emit  OwnershipTransferred(_owner,  newOwner);
        _owner  =  newOwner;
    }

    modifier whenNotPaused(){
        require(!paused);
        _;
    }

    modifier whenPaused{
        require(paused);
        _;
    }

    function pause() external onlyCOO  whenNotPaused{
        paused  =  true;
    }

    function unPause() public onlyCOO  whenPaused  {
        paused  =  false;
    }
}