//SourceUnit: ProposalUSDDNewMaxAssetMint.sol

pragma solidity ^0.5.10;
pragma experimental ABIEncoderV2;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }


    function add(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, errorMessage);

        return c;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction underflow");
    }


    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }


    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }


    function mul(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, errorMessage);

        return c;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }


    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }


    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }


    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


interface GovernorAlphaInterface {
    struct Proposal {
        mapping(address => Receipt) receipts;
    }

    struct Receipt {
        bool hasVoted;
        bool support;
        uint96 votes;
    }

    function state(uint proposalId) external view returns (uint8);

    function getReceipt(uint proposalId, address voter) external view returns (Receipt memory);

    function propose(address[] calldata targets, uint[] calldata values, string[] calldata signatures, bytes[] calldata calldatas, string calldata description) external returns (uint);
}

interface IWJST {
    function deposit(uint256) external;

    function withdraw(uint256) external;
}

interface ITRC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ProposalUSDDNewMaxAssetMint {
    using SafeMath for uint256;

    address public _owner;
    address public _cfo = msg.sender;
    address public jstAddress;
    address public wjstAddress;
    bool public onlyOnce = false;

    GovernorAlphaInterface public governorAlpha;

    struct Receipt {
        bool hasVoted;
        bool support;
        uint96 votes;
    }

    event OwnershipTransferred(address  indexed previousOwner, address  indexed newOwner);
    event Withdraw_token(address _caller, address _recievor, uint256 _amount);

    function() external payable {
    }

    constructor(address governorAlpha_, address jst_, address wjst_, address newOwner_) public {
        governorAlpha = GovernorAlphaInterface(governorAlpha_);
        _owner = newOwner_;
        jstAddress = jst_;
        wjstAddress = wjst_;
    }

    modifier  onlyOwner()  {
        require(msg.sender == _owner);
        _;
    }

    modifier  onlyCFO()  {
        require(msg.sender == _cfo);
        _;
    }

    function createPropose() public returns (bool){
        require(onlyOnce == false, "onlyOnce");
        uint256 balance = ITRC20(jstAddress).balanceOf(address(this));
        if (balance >= 200000000e18) {
            ITRC20(jstAddress).approve(wjstAddress, balance);
            IWJST(wjstAddress).deposit(balance);
            _createPropose();
            onlyOnce = true;
            return true;
        }
        return false;
    }

    function _createPropose() internal {
        address[] memory targets = new address[](5);
        // miannet : usdd TPYmHEhy5n8TCEfYGqW2rPxsghSfzghPDn 0xe49A7ED6844C3fBe18f25b07882149c462eE6B46
        // miannet : jusdd TWox9L3UTabikUhxkPjAK6nVUbHZ7isDMG 0x94F24E992cA04B49C6f2a2753076Ef8938eD4daa
        //nile: USDD 合约地址：TGjgvdTWWrybVLaVeFqSyVqJQWjxqRYbaK 0x4a3a5dd265bd974B4DE0Bbe33FAa7EFb8b7b87e8
        //nile: jUSDD 合约地址：need deploy
        address jUSDD = 0xe49A7ED6844C3fBe18f25b07882149c462eE6B46;
        address USDD = 0x94F24E992cA04B49C6f2a2753076Ef8938eD4daa;
        // miannet : TGjYzgCyPobsNS9n6WcbdLVR9dH7mWqFx7   0x4a33BF2666F2e75f3D6Ad3b9ad316685D5C668D4
        //nile: unitroller 合约地址：TPdWn5nRLxx8n2WKbBZ3FkBejVdiTUGDVM 0x95d847d74d6b25B60c293fEb95Fe6f26f89352d8
        targets[0] = (0x4a33BF2666F2e75f3D6Ad3b9ad316685D5C668D4);
        targets[1] = (0x4a33BF2666F2e75f3D6Ad3b9ad316685D5C668D4);
        targets[2] = (0x4a33BF2666F2e75f3D6Ad3b9ad316685D5C668D4);
        targets[3] = (USDD);
        targets[4] = (jUSDD);

        uint256[] memory values = new uint256[](5);
        values[0] = 0;
        values[1] = 0;
        values[2] = 0;
        values[3] = 0;
        values[4] = 0;

        string[] memory signatures = new string[](5);
        signatures[0] = ("_supportMarket(address)");
        signatures[1] = ("_setCollateralFactor(address,uint256)");
        signatures[2] = ("_setMaxAssets(uint256)");
        signatures[3] = ("approve(address,uint256)");
        signatures[4] = ("mint(uint256)");

        bytes[] memory calldatas = new bytes[](5);
        calldatas[0] = abi.encode(jUSDD);
        calldatas[1] = abi.encode(jUSDD, 0);
        calldatas[2] = abi.encode(12);
        calldatas[3] = abi.encode(jUSDD, 0.01e18);
        calldatas[4] = abi.encode(0.01e18);


        string memory description = "add jUSDD Market and maxasset";
        governorAlpha.propose(targets, values, signatures, calldatas, description);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        _owner = newOwner;
        emit  OwnershipTransferred(_owner, newOwner);
    }

    function withdrawToken() public onlyOwner {
        _withdrawToken();
    }

    function withdrawTokenCFO() public onlyCFO {
        _withdrawToken();
    }

    function _withdrawToken() internal {
        uint256 wjstAmount = ITRC20(wjstAddress).balanceOf(address(this));
        if (wjstAmount > 0) {
            IWJST(wjstAddress).withdraw(wjstAmount);
        }
        uint256 jstAmount = ITRC20(jstAddress).balanceOf(address(this));
        if (jstAmount > 0) {
            ITRC20(jstAddress).transfer(_owner, jstAmount);
        }
        if (address(this).balance > 0) {
            address(uint160(_owner)).transfer(address(this).balance);
        }
        emit Withdraw_token(msg.sender, _owner, jstAmount);
    }

}