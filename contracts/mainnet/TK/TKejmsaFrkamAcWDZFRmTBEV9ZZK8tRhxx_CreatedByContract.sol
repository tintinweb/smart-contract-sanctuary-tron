//SourceUnit: mloadstore.sol



contract trcToken077 {
    function addressTest() public returns(bytes32 addressValue) {
        assembly{
            let x := mload(0x40)  //Find empty storage location using "free memory pointer"
            mstore(x,123) //Place current contract address
            mstore8(x,456)
            addressValue := mload(x)
        }
    }

    function kill(address payable target) payable public {
        selfdestruct(target);
    }

    function TransferTokenTo(address payable toAddress, trcToken id,uint256 amount) public payable{
        //trcToken id = 0x74657374546f6b656e;
        //TransferTokenTo(address,trcToken,uint256)
        toAddress.transferToken(amount,id);
    }

    fallback() external payable {
        //flag = 1;
    }
}

contract D {
    constructor() public payable{}

    function deploy(uint256 salt) public returns(address){
        address addr;
        bytes memory code = type(trcToken077).creationCode;
        assembly {
            addr := create2(0, add(code, 0x20), mload(code), salt)
        }
        return addr;
    }

    function TransferTokenTo(address payable toAddress, trcToken id,uint256 amount) public payable{
        //trcToken id = 0x74657374546f6b656e;
        //TransferTokenTo(address,trcToken,uint256)
        toAddress.transferToken(amount,id);
    }

    fallback() external payable {
        //flag = 1;
    }
}