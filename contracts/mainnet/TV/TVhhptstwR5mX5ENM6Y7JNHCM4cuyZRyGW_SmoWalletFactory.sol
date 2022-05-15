//SourceUnit: AccessControl.sol

pragma solidity ^0.5.0;

contract AccessControl{
  address owner;  
  mapping(address => bool) operators;
  
  constructor() public {
    owner = msg.sender;
  }
  
  function enableOperator(address operator, bool enable) public onlyOwner{
    operators[operator] = enable;
  }
  
  modifier onlyOwner(){
    require(msg.sender == owner);
    _;
  }
  
  modifier onlyOperator(){
    require(operators[msg.sender]);
    _;
  }
}

//SourceUnit: SmoWallet.sol

pragma solidity ^0.5.0;

import './TRC20.sol';
import './TransferHelper.sol';

contract SmoWallet {
  constructor() public{}
  function sweep(address tokens, address payable wallet) public {
    TRC20 token = TRC20(tokens);
    uint balance = token.balanceOf(address(this));
    TransferHelper.safeTransfer(tokens, wallet, balance);

    selfdestruct(wallet);
  }
}

//SourceUnit: SmoWalletFactory.sol

pragma solidity ^0.5.0;

import './TRC20.sol';
import './SmoWallet.sol';
import './AccessControl.sol';

contract SmoWalletFactory is AccessControl {
  event Deployed(address indexed addr, bytes32 salt, bytes initdata);
  constructor() public {
    enableOperator(msg.sender, true);
    enableOperator(address(this), true);
  }
  function computeAddress(bytes32 salt) public view returns(address) {
    bytes memory bytecode = type(SmoWallet).creationCode;
    uint8 prefix = 0x41;
    bytes32 initCodeHash = keccak256(abi.encodePacked(bytecode));
    bytes32 hash = keccak256(abi.encodePacked(prefix, address(this), salt, initCodeHash));
    return address(uint160(uint256(hash)));
  }
  function deployWallet(bytes32 salt, bytes memory initdata) public onlyOperator {
    bytes memory bytecode = type(SmoWallet).creationCode;
    address addr;
    assembly{
      addr := create2(0,add(bytecode,0x20),mload(bytecode),salt)
      if iszero(extcodesize(addr)) { revert(0, 0) }    
    }
    (bool success, ) = addr.call(initdata);
    require(success);
    emit Deployed(addr, salt, initdata);    
  }
  function sweepWallet(bytes32 salt, address tokens, address payable wallet) public onlyOperator{
	address salt_address=computeAddress(salt);
    TRC20 token = TRC20(tokens);
    uint balance = token.balanceOf(salt_address);
	require(balance>0,"balance is zero!");
	bytes memory initdata = abi.encodeWithSignature('sweep(address,address)', tokens, wallet);
	deployWallet(salt, initdata);
  }
  function sweepWallets(bytes32[] memory salts,address tokens, address payable wallet) public onlyOperator {
    for(uint i = 0; i < salts.length; i++){
      sweepWallet(salts[i],tokens, wallet);
    }
  }
}

//SourceUnit: TRC20.sol

pragma solidity ^0.5.0;

contract TRC20{
  function balanceOf(address _owner) public view returns (uint256 balance);
  function transfer(address _to, uint256 _value) public returns (bool success);
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
}


//SourceUnit: TransferHelper.sol

pragma solidity ^0.5.0;


library TransferHelper {
  function safeTransfer(address token, address to, uint value) internal {
    // bytes4(keccak256(bytes('transfer(address,uint256)')));
    (bool success, /*bytes memory data*/) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
    require(success, 'TransferHelper: TRANSFER_FAILED');
  }
}