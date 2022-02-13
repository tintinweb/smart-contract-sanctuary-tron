//SourceUnit: Bank.sol

pragma solidity ^0.5.0;

interface ITRC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address to, uint value) external returns (bool success);
    function mint(address to,uint256 amount) external;
    function permitMint(address to,uint256 amount,uint256 deadline,bytes32 r,bytes32 s,uint8 v) external;
}
interface ITRC721 {
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function permitMintWithTokenURI(address to, uint256 tokenId, string calldata tokenURI, uint256 deadline,bytes32 r,bytes32 s,uint8 v) external returns (bool);
}
interface INonces {
    function add(address user) external;
    function getNonce(address user) external view returns(uint256);
}
contract Bank {
    ITRC20 star;
    ITRC20 savageBox;
    INonces nonces;
    address owner;
    address projectManager;

    mapping(address => bool) isGoods;

    uint256 public savageBoxAmount = 2000;
    uint256 savageBoxPrice = 200 * 10 ** 18;

    event WithdrawTRC721(address indexed tokenAddress,address indexed user,uint256 tokenId);
    event WithdrawTRC20(address indexed tokenAddress,address indexed user,uint256 amount);
    event DepositTRC721(address indexed tokenAddress,address indexed user,uint256 tokenId);
    event DepositTRC20(address indexed tokenAddress,address indexed user,uint256 amount);

    constructor(address noncesAddress,address starAddress,address savageBoxAddress,address manager) public {
        owner = msg.sender;
        nonces = INonces(noncesAddress);
        projectManager = manager;
        star = ITRC20(starAddress);
        savageBox = ITRC20(savageBoxAddress);
    }

    function setGood(address goodAddress) external {
        require(msg.sender == owner);
        isGoods[goodAddress] = true;
    }

    function setMysteriousBoxAmount(uint256 amount) external {
        require(msg.sender == owner);
        savageBoxAmount = amount;
    }

    function setMysteriousBoxPrice(uint256 price) external {
        require(msg.sender == owner);
        savageBoxPrice = price * 10 **18;
    }

    function transferStar(address from,address to,uint256 amount) internal {
        uint256 managerAmount = amount * 80 / 100;
        star.transferFrom(from, to, managerAmount);
        star.transferFrom(msg.sender, address(1), amount - managerAmount);
    }

    function buyMysteriousBox(uint256 count) external {
        require(count > 0);
        require(count <= 2);
        require(savageBoxAmount >= count);
        uint256 amount = count * savageBoxPrice;
        transferStar(msg.sender, projectManager, amount);
        savageBox.mint(msg.sender, count);
        savageBoxAmount = savageBoxAmount - count;
    }

    function getTronSignedMessageHash(bytes32 _messageHash) private pure returns(bytes32) {
        return keccak256(abi.encodePacked("\x19TRON Signed Message:\n32",_messageHash));
    }

    function verify(address tokenAddress,address user,uint256 amountOrTokenId,uint256 nonce,uint256 deadline,bytes32 r,bytes32 s,uint8 v) private view returns(bool) {
        bytes32 messageHash = keccak256(abi.encode(tokenAddress,user,amountOrTokenId,nonce,deadline));
        bytes32 tronSignedMessageHash = getTronSignedMessageHash(messageHash);
        return ecrecover(tronSignedMessageHash,v,r,s) == owner;
    }

    function depositStar(uint256 amount) external {
        transferStar(msg.sender, projectManager, amount);
        emit DepositTRC20(address(star), msg.sender, amount);
    }

    function withdrawStar(uint256 amount,uint256 deadline,bytes32 r,bytes32 s,uint8 v) external {
        require(deadline > block.timestamp);
        
        emit WithdrawTRC20(address(star),msg.sender, amount);
    }

    function withdrawTRC721(address nftAddress,uint256 tokenId,uint256 deadline,bytes32 r,bytes32 s,uint8 v) external {
        require(deadline > block.timestamp);
        require(verify(nftAddress,msg.sender,tokenId,nonces.getNonce(msg.sender),deadline,r,s,v));
        ITRC721 token = ITRC721(nftAddress);
        token.safeTransferFrom(address(this), msg.sender, tokenId);
        nonces.add(msg.sender);
        emit WithdrawTRC721(nftAddress, msg.sender,tokenId);
    }

    function mintTRC721(address nftAddress,address to, uint256 tokenId, string calldata tokenURI, uint256 deadline,bytes32 r,bytes32 s,uint8 v) external {
        ITRC721 nft = ITRC721(nftAddress);
        nft.permitMintWithTokenURI(to, tokenId, tokenURI,deadline, r, s, v);
        emit WithdrawTRC721(nftAddress, to,tokenId);
    }

    function withdrowTRC20(address tokenAddress,address to,uint256 amount,uint256 deadline,bytes32 r,bytes32 s,uint8 v) external {
        ITRC20 token = ITRC20(tokenAddress);
        token.permitMint(to, amount,deadline, r, s, v);
        emit WithdrawTRC20(tokenAddress,msg.sender, amount);
    }

    function onTRC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    ) external returns (bytes4) {
        require(isGoods[msg.sender]);
        emit DepositTRC721(msg.sender,_from,_tokenId);
        return 0x5175f878;
    }

    function onTRC20Received(
        address _operator,
        address _from,
        uint256 _amount,
        bytes calldata _data
    ) external returns (bytes4) {
        require(isGoods[msg.sender]);
        emit DepositTRC20(msg.sender,_from,_amount);
        return 0x76a68326;
    }
}