//SourceUnit: Market.sol

pragma solidity ^0.5.0;

interface TRC721TokenReceiver {
    function onTRC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    ) external returns (bytes4);
}

interface ITRC721 {
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}

interface ITRC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract Market is TRC721TokenReceiver {
    address owner;
    address projectManager;
    mapping(address/**tokenAddress */ => mapping(uint256/**tokenId */ => NFTCommodity)) private nftCommodityMap;
    mapping(address/**tokenAddress */ => mapping(address/**seller */ => mapping(uint256/**price */ => uint256/**amount */))) private trc20CommodityMap;

    ITRC20 star;

    mapping(address => bool) isGoods;

    struct NFTCommodity {
        address seller;
        uint256 price;
    }

    event SellTRC721(address indexed tokenAddress,address indexed seller,uint256 indexed tokenId,uint256 price);
    event BuyTRC721(address indexed tokenAddress,uint256 indexed tokenId,address indexed buyer,address seller,uint256 price);
    event WithdrawTRC721(address indexed tokenAddress,uint256 indexed tokenId,address indexed seller,uint256 price);

    event SellTRC20(address indexed tokenAddress,address indexed seller,uint256 amount,uint256 price);
    event BuyTRC20(address indexed tokenAddress,address indexed seller,address buyer, uint256 amount,uint256 price,bool isSellOut);
    event WithdrawTRC20(address indexed tokenAddress,address indexed seller,uint256 amount,uint256 price,bool isSellOut);

    constructor(address starAddress,address manager) public {
        owner = msg.sender;
        projectManager = manager;
        star = ITRC20(starAddress);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function setGood(address goodAddress) external onlyOwner {
        isGoods[goodAddress] = true;
    }

    function transferStar(address from,address to,uint256 amount) internal {
        uint256 fee = amount * 2 / 100;
        star.transferFrom(from, projectManager, fee);
        star.transferFrom(from, address(1), fee);
        star.transferFrom(from, to, amount - 2 * fee);
    }

    function getNFTCommodity(address _tokenAddress,uint256 _tokenId) external view returns(address,uint256) {
        NFTCommodity memory nftCommodity = nftCommodityMap[_tokenAddress][_tokenId];
        return (nftCommodity.seller,nftCommodity.price);
    }

    function getTRC20Commodity(address _tokenAddress,address _seller,uint256 _price) external view returns(uint256) {
        return trc20CommodityMap[_tokenAddress][_seller][_price];
    }

    function buyNFT(address _nftAddress,uint256 _tokenId) external {
        NFTCommodity memory commodity = nftCommodityMap[_nftAddress][_tokenId];
        require(nftCommodityMap[_nftAddress][_tokenId].seller != address(0),"Goods don't exist");
        transferStar(msg.sender, commodity.seller, commodity.price);
        ITRC721 nft = ITRC721(_nftAddress);
        nft.safeTransferFrom(address(this), msg.sender, _tokenId);
        delete nftCommodityMap[_nftAddress][_tokenId];
        emit BuyTRC721(_nftAddress,_tokenId,msg.sender,commodity.seller,commodity.price);
    }

    function withdrawNFT(address _nftAddress,uint256 _tokenId) external {
        NFTCommodity memory commodity = nftCommodityMap[_nftAddress][_tokenId];
        require(commodity.seller == msg.sender,"Only the owner can call");
        ITRC721 nft = ITRC721(_nftAddress);
        nft.safeTransferFrom(address(this), msg.sender, _tokenId);
        delete nftCommodityMap[_nftAddress][_tokenId];
        emit WithdrawTRC721(_nftAddress,_tokenId,msg.sender,commodity.price);
    }

    function buyTRC20(address _tokenAddress,address _seller,uint256 _amount,uint256 _price) external {
        uint256 amount = trc20CommodityMap[_tokenAddress][_seller][_price];
        require(_amount <= amount);
        trc20CommodityMap[_tokenAddress][_seller][_price] = amount - _amount;
        ITRC20 token = ITRC20(_tokenAddress);
        token.transfer(msg.sender, _amount);
        transferStar(msg.sender, _seller, _amount * _price);
        bool isSellOut = false;
        if(trc20CommodityMap[_tokenAddress][_seller][_price] == 0) {
            isSellOut = true;
            delete trc20CommodityMap[_tokenAddress][_seller][_price];
        }
        emit BuyTRC20(_tokenAddress, _seller, msg.sender, _amount,_price, isSellOut);
    }

    function withdrawTRC20(address _tokenAddress,address _seller,uint256 _amount,uint256 _price) external {
        require(msg.sender == _seller);
        uint256 amount = trc20CommodityMap[_tokenAddress][_seller][_price];
        require(_amount <= amount);
        trc20CommodityMap[_tokenAddress][_seller][_price] = amount - _amount;
        ITRC20 token = ITRC20(_tokenAddress);
        token.transfer(msg.sender, _amount);
        bool isSellOut = false;
        if(trc20CommodityMap[_tokenAddress][_seller][_price] == 0) {
            isSellOut = true;
            delete trc20CommodityMap[_tokenAddress][_seller][_price];
        } 
        emit WithdrawTRC20(_tokenAddress, _seller, _amount,_price, isSellOut);
    }

    function onTRC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    ) external returns (bytes4) {
        require(isGoods[msg.sender]);
        (uint256 price) = abi.decode(_data,(uint256));
        NFTCommodity memory commodity = NFTCommodity(_from,price);
        nftCommodityMap[msg.sender][_tokenId] = commodity;
        emit SellTRC721(msg.sender,_from,_tokenId,price);
        return 0x5175f878;
    }

    function onTRC20Received(
        address _operator,
        address _from,
        uint256 _amount,
        bytes calldata _data
    ) external returns (bytes4) {
        require(isGoods[msg.sender]);
        (uint256 price) = abi.decode(_data,(uint256));
        trc20CommodityMap[msg.sender][_from][price] += _amount;

        emit SellTRC20(msg.sender,_from,_amount,price);
        return 0x76a68326;
    }
}