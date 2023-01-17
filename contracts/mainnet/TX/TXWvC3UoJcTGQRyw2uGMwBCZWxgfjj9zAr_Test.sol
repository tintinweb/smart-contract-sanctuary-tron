//SourceUnit: test.sol

pragma solidity ^0.5.8;

 contract Test {
    event Hi(string hi);

     function deployCloneWallet2(
             address _recoveryAddress,
             address _authorizedAddress,
             uint256 _cosigner,
             bytes32 _salt
         )
             external pure returns  (bytes32 r)
         {
             bytes32 salt = keccak256(abi.encodePacked(_salt, _authorizedAddress, _cosigner, _recoveryAddress));
             return (salt);
         }

         function addrBytes(
                      address _recoveryAddress
                  )
                      external pure returns  (bytes20 r)
                  {
                      bytes20 targetBytes = bytes20(_recoveryAddress);
                      return (targetBytes);
                  }

       function sender() external view returns  (address r) {
           return (msg.sender);
       }

       address txt;
       function hi() external {
          txt = msg.sender;
       }

       function() external payable {
            emit Hi("hii~~");
       }

       function getHi() external view returns (address r) {
          return (txt);
       }
 }