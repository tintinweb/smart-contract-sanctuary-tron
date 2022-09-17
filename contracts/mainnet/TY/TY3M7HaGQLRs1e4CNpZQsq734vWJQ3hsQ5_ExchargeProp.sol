//SourceUnit: excharge_prop.sol


// File: contracts/ExchargeProp/contracts/openzeppelin/contracts/ownership/Ownable.sol

pragma solidity ^0.4.21;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

// File: contracts/ExchargeProp/contracts/VerifySignature.sol

pragma solidity ^0.4.24;



contract VerifySignature is Ownable {

    address public  signaturer;

    constructor() public {
        signaturer = msg.sender;
    }

    function changeSignaturer(address value) public onlyOwner {
        signaturer = value;
    }


    function getMessageHash(address contract_address, address seller, uint256 real_price, uint256 price, uint256 token_id, uint256 _nonce) public view returns (bytes32)
    {
        return keccak256(abi.encodePacked(contract_address, signaturer, seller, real_price, price, token_id, _nonce));
    }


    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32)
    {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }

    function verify(address seller, uint256 real_price, uint256 price, uint256 token_id, uint256 _nonce, bytes memory signature) public view returns (bool)
    {
        bytes32 messageHash = getMessageHash(address(this), seller, real_price, price, token_id, _nonce);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);
        return recoverSigner(ethSignedMessageHash, signature) == signaturer;
    }


    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature) public pure returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory sig) public pure returns (bytes32 r, bytes32 s, uint8 v)
    {
        require(sig.length == 65, "invalid signature length");
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }

}
// File: contracts/ExchargeProp/contracts/ExchargeProp.sol

pragma solidity ^0.4.24;


contract ExchargeProp is VerifySignature
{
    mapping(uint256 => uint256) public token_ids;
    address owner;
    
    event Cancel(uint256 indexed token_id);
    event Success(uint256 indexed token_id);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    constructor() public {
        owner = msg.sender;
    }
    
    function cancel(uint256 token_id)  public  {
        require(token_ids[token_id]  == 0);
        token_ids[token_id] =1;
        emit Cancel(token_id);
    }   
    
    function buy(bytes memory signature, uint256 token_id,uint256 price,address seller,uint256 nonce)  public payable  {
        require(token_ids[token_id]  == 0,"asd");
        require(msg.value  > price);
        require(verify(seller,msg.value, price, token_id, nonce, signature), "verify");
        token_ids[token_id] =2;
        seller.transfer(price);
        emit Success(token_id);
        
    }
    
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    
    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
    
    function reclaimEther() external onlyOwner {
        owner.transfer(address(this).balance);
    }
}