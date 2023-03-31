//SourceUnit: airdrop.sol

// SPDX-License-Identifier: NO LICENSE
pragma solidity ^0.8.0;

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

contract SimpleTransfer{
  
    address payable public owner;
    event Multisended(uint256 total, address tokenAddress);

      modifier onlyOwner() {
        require(msg.sender==owner, "Only Call by Owner");
        _;
    }
    constructor() {
        owner = payable(msg.sender);
    }
 receive() external payable { }
 
    function multisendToken( IERC20 _token,address[] calldata _contributors, uint256[] calldata __balances) external   
        {
            uint256 i = 0;        
            IERC20 tokenAddress = IERC20(_token);
            for (i; i < _contributors.length; i++) {
            tokenAddress.transferFrom(msg.sender,_contributors[i], __balances[i]);
            }
        }
    
    
  
    function sendMultiBnb(address payable[]  memory  _contributors, uint256[] memory __balances) public  payable 
    {
        
        uint256 total = msg.value;
        uint256 i = 0;
        for (i; i < _contributors.length; i++) {
            require(total >= __balances[i],"Invalid Amount");
            total = total - __balances[i];
            _contributors[i].transfer(__balances[i]);
        }
        emit Multisended(  msg.value , msg.sender);
    }

    function withDraw (uint256 _amount) onlyOwner external 
    {
        payable(msg.sender).transfer(_amount);
    }
    
    
    
    function getTokens (IERC20 _token,uint256 _amount) onlyOwner external 
    {
        _token.transfer(msg.sender,_amount);
    }


}