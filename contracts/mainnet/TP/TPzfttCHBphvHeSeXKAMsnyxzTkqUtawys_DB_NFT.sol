//SourceUnit: DB-NFT - 副本.sol

pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
interface IERC20 {
    function totalSupply() external view returns (uint256);    
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
    function decimals() external returns(uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner,address indexed spender,uint256 value);
}
pragma solidity ^0.5.0;
contract IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) public view returns (uint256 balance);
    function ownerOf(uint256 tokenId) public view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId) public;
    function transferFrom(address from, address to, uint256 tokenId) public;
    function approve(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) public;
    function isApprovedForAll(address owner, address operator) public view returns (bool);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
}
pragma solidity ^0.5.0;
contract IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public returns (bytes4);
}
pragma solidity ^0.5.0;
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}
pragma solidity ^0.5.0;
library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}
pragma solidity ^0.5.0;
library Counters {
    using SafeMath for uint256;
    struct Counter {
        uint256 _value; 
    }
    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }
    function increment(Counter storage counter) internal {
        counter._value += 1;
    }
    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}
pragma solidity ^0.5.0;
contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;
    mapping(bytes4 => bool) private _supportedInterfaces;
    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }
    function supportsInterface(bytes4 interfaceId) external view returns (bool) {
        return _supportedInterfaces[interfaceId];
    }
    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}
pragma solidity ^0.5.0;
contract ERC721 is ERC165, IERC721 {
    using SafeMath for uint256;
    using Address for address;
    using Counters for Counters.Counter;
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;
    mapping (uint256 => address) private _tokenOwner;
    mapping (uint256 => address) private _tokenApprovals;
    mapping (address => Counters.Counter) private _ownedTokensCount;
    mapping (address => mapping (address => bool)) private _operatorApprovals;
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;
    constructor () public {
        _registerInterface(_INTERFACE_ID_ERC721);
    }
    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _ownedTokensCount[owner].current();
    }
    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _tokenOwner[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }
    function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "ERC721: approve caller is not owner nor approved for all"
        );
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }
    function getApproved(uint256 tokenId) public view returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");
        return _tokenApprovals[tokenId];
    }
    function setApprovalForAll(address to, bool approved) public {
        require(to != msg.sender, "ERC721: approve to caller");
        _operatorApprovals[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }
    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }
    function transferFrom(address from, address to, uint256 tokenId) public {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        _transferFrom(from, to, tokenId);
    }
    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {
        transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }
    function _exists(uint256 tokenId) internal view returns (bool) {
        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }
    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");
        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to].increment();
        emit Transfer(address(0), to, tokenId);
    }
    function _burn(address owner, uint256 tokenId) internal {
        require(ownerOf(tokenId) == owner, "ERC721: burn of token that is not own");
        _clearApproval(tokenId);
        _ownedTokensCount[owner].decrement();
        _tokenOwner[tokenId] = address(0);
        emit Transfer(owner, address(0), tokenId);
    }
    function _burn(uint256 tokenId) internal {
        _burn(ownerOf(tokenId), tokenId);
    }
    function _transferFrom(address from, address to, uint256 tokenId) internal {
        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");
        _clearApproval(tokenId);
        _ownedTokensCount[from].decrement();
        _ownedTokensCount[to].increment();
        _tokenOwner[tokenId] = to;
        emit Transfer(from, to, tokenId);
    }
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        internal returns (bool)
    {   
        bytes4 retval = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }
    function _clearApproval(uint256 tokenId) private {
        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }
}
pragma solidity ^0.5.0;
contract IERC721Enumerable is IERC721 {
    function totalSupply() public view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);
    function tokenByIndex(uint256 index) public view returns (uint256);
}
pragma solidity ^0.5.0;
contract ERC721Enumerable is ERC165, ERC721, IERC721Enumerable {
    mapping(address => uint256[]) private _ownedTokens;
    mapping(uint256 => uint256) private _ownedTokensIndex;
    uint256[] private _allTokens;
    mapping(uint256 => uint256) private _allTokensIndex;
    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;
    constructor () public {
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }
    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {
        require(index < balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
        return _ownedTokens[owner][index];
    }
    function totalSupply() public view returns (uint256) {
        return _allTokens.length;
    }
    function tokenByIndex(uint256 index) public view returns (uint256) {
        require(index < totalSupply(), "ERC721Enumerable: global index out of bounds");
        return _allTokens[index];
    }
    function _transferFrom(address from, address to, uint256 tokenId) internal {
        super._transferFrom(from, to, tokenId);
        _removeTokenFromOwnerEnumeration(from, tokenId);
        _addTokenToOwnerEnumeration(to, tokenId);
    }
    function _mint(address to, uint256 tokenId) internal {
        super._mint(to, tokenId);
        _addTokenToOwnerEnumeration(to, tokenId);
        _addTokenToAllTokensEnumeration(tokenId);
    }
    function _burn(address owner, uint256 tokenId) internal {
        super._burn(owner, tokenId);
        _removeTokenFromOwnerEnumeration(owner, tokenId);
        _ownedTokensIndex[tokenId] = 0;
        _removeTokenFromAllTokensEnumeration(tokenId);
    }
    function _tokensOfOwner(address owner) internal view returns (uint256[] storage) {
        return _ownedTokens[owner];
    }
    function getTokensOfOwner(address owner) public view returns (uint256[] memory) {
        return _ownedTokens[owner];
    }
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        _ownedTokensIndex[tokenId] = _ownedTokens[to].length;
        _ownedTokens[to].push(tokenId);
    }
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        uint256 lastTokenIndex = _ownedTokens[from].length.sub(1);   
        uint256 tokenIndex = _ownedTokensIndex[tokenId];
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];
            _ownedTokens[from][tokenIndex] = lastTokenId; 
            _ownedTokensIndex[lastTokenId] = tokenIndex; 
        }
        _ownedTokens[from].length--;
    }
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        uint256 lastTokenIndex = _allTokens.length.sub(1);
        uint256 tokenIndex = _allTokensIndex[tokenId];
        uint256 lastTokenId = _allTokens[lastTokenIndex];
        _allTokens[tokenIndex] = lastTokenId; 
        _allTokensIndex[lastTokenId] = tokenIndex; 
        _allTokens.length--;
        _allTokensIndex[tokenId] = 0;
    }
}
pragma solidity ^0.5.0;
contract IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
pragma solidity ^0.5.0;
contract ERC721Metadata is ERC165, ERC721, IERC721Metadata {
    string private _name;
    string private _symbol;
    string private _host;
    mapping(uint256 => string) private _tokenURIs;
    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;
    constructor (string memory name, string memory symbol,string memory host) public {
        _name = name;
        _symbol = symbol;
        _host = host;
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
    }
    function host()public view returns(string memory) {
        return _host;
    }
    function setHost(string memory hostURL)public{
        _host = hostURL;
    }
    function name() external view returns (string memory) {
        return _name;
    }
    function symbol() external view returns (string memory) {
        return _symbol;
    }
    function tokenURI(uint256 tokenId) external view returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return _tokenURIs[tokenId];
    }
    function _setTokenURI(uint256 tokenId, string memory uri) internal {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = uri;
    }
    function _burn(address owner, uint256 tokenId) internal {
        super._burn(owner, tokenId);
        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}
pragma solidity ^0.5.0;
contract ERC721Full is ERC721, ERC721Enumerable, ERC721Metadata {
    constructor (string memory name, string memory symbol,string memory host) public ERC721Metadata(name, symbol,host) {
    }
}
pragma solidity ^0.5.0;
contract DB_NFT is ERC721Full{
    mapping(uint => string[]) private _nftImages;
    mapping(uint => string[]) private _nftNames;
    uint private _nftTotal;
    mapping(uint => uint256) private _gradeTotal; 
    uint private _chanceN = 85;
    uint private _chanceR = 10;
    uint private _chanceSR = 5;
    mapping(uint => uint256) public _power;
    uint256 public _float = 100;
    mapping(uint256 => uint256) private _nftGrade;
    uint256 public _token = 10;
    uint256 public _usdt = 10;
    IERC20 private _tokenContract;
    IERC20 private _usdtContract;
    address public _owner;
    address public _burnAddress = 0x000000000000000000000000000000000000dEaD;
    mapping(uint256 => string) private _nftInfo;  
    modifier isOwner(){
        require(msg.sender == _owner);
        _;
    }
    function setNftGrade(uint256 nftId,uint256 gradeId) public isOwner{
        _nftGrade[nftId] = gradeId;
    }
    function setNftPower(uint gradeId,uint256 power) public isOwner{
        _power[gradeId] = power;
    }
    function setOwner(address owner) public isOwner{
        _owner = owner;
    }
    constructor(address usdt,address token) ERC721Full("DB-NFT", "DB-NFT","http://156.236.65.154:8080/ipfs/") public {
        _owner = msg.sender;
        _tokenContract = IERC20(token);
        _usdtContract = IERC20(usdt);
        addNftImage(1,"http://156.236.65.154:8080/ipfs/QmR8RDh3j6Mu5QCdXQ1qJHF4rAbcEbdSCPd4BzZmVrYEhK","N One");
        addNftImage(2,"http://156.236.65.154:8080/ipfs/QmTU3Z9vbLfLPduEgPkiuesyTKSctCWcKb2u1pdJqEPr4w","R One");
        addNftImage(3,"http://156.236.65.154:8080/ipfs/QmRceW2f1KfD5H4ikcV426TDEXN7m5BhY3XUYwf2pe84j8","SR One");
        _token = _token * 10 ** _tokenContract.decimals();
        _usdt = _usdt * 10 ** _usdtContract.decimals();
        _power[1] = 38235;
        _power[2] = 100000;
        _power[3] = 150000;
        _nftTotal = 2000;
        _gradeTotal[1] = 1700;
        _gradeTotal[2] = 200;
        _gradeTotal[3] = 100;
    }
    function setBurnAddress(address burnAddress) public isOwner {
        _burnAddress = burnAddress;
    } 
    function mint(uint256 usdt,uint256 token) public {
        (uint256 N,uint256 R,uint256 SR) = getGradeTotal();
        require(N > 0 || R > 0 || SR > 0,"There is no NFT anymore");
        require(token >= _token,"Insufficient tokens");
        require(usdt >= _usdt,"Insufficient usdt");
        _usdtContract.transferFrom(msg.sender,_owner,usdt);
        _tokenContract.transferFrom(msg.sender,_burnAddress,token);
        uint grade = randomGrade();
        while(_gradeTotal[grade] == 0){
            grade++;
            if(grade > 3) grade = 1;
        }
        uint randomNft = randomNft(grade);
        uint256 tokenId = totalSupply().add(1);
        string memory _tokenURI = _nftImages[grade][randomNft];
        _nftInfo[tokenId] = _nftNames[grade][randomNft];
        _gradeTotal[grade] = _gradeTotal[grade] - 1;
        _mint(msg.sender, tokenId);
        _setTokenURI(tokenId, _tokenURI);
    }
    function getNftTotal()public view returns(uint){
        return _nftTotal;
    }
    function getGradeTotal()public view returns(uint256,uint256,uint256){
        return (_gradeTotal[1],_gradeTotal[2],_gradeTotal[3]);
    }
    function randomNft(uint grade) private view returns(uint){
        require(_nftNames[grade].length > 0,"nft data not fount"); 
        uint nft = now % _nftNames[grade].length;
        return nft; 
    } 
    function randomGrade() private view returns(uint){
        uint result = (block.timestamp + uint256(msg.sender)) % 100;
        uint grade = 1;
         if(result <= _chanceSR){
            grade = 3;
        }else if(result <= _chanceR){
            grade = 2;
        }else if(result <= _chanceN){
            grade = 1;
        }
        return grade;
    }
    function getNftImagesByGrade(uint grade) public view returns(string[] memory,string[] memory){
        return (_nftImages[grade],_nftNames[grade]);
    }
    function addNftImage(uint gradeId,string memory imageHash,string memory imageName) public isOwner{
        require( 4 > gradeId &&  gradeId > 0,"Level does not exist");
        _nftImages[gradeId].push(imageHash);
        _nftNames[gradeId].push(imageName); 
    }
    function getTokensIdByType(address owner,uint256 quality)public view returns(uint256[] memory){
        uint256[] memory qualityToken = new uint256[](1000);
        uint256[] memory nftIds = getTokensOfOwner(owner);
        for(uint i = 0;i< nftIds.length;i++){
            uint256 tokenQuality = getGradeByNftId(nftIds[i]);
            if(tokenQuality == quality){
                qualityToken[i] = nftIds[i];
            }
        }
        uint256 tokenLength = getTokenLength(qualityToken);
        uint256[] memory result = new uint256[](tokenLength);
        uint x=0;
        for(uint j = 0;j < qualityToken.length; j++){
            if(qualityToken[j] != 0){
                result[x] = qualityToken[j];
                x++;
            }
        }
        return result;
    }
    function getTokenLength(uint256[] memory qualityToken)private pure returns(uint256){
        uint256 tokenLength = 0;
        for(uint i = 0;i < qualityToken.length; i++){
            if(qualityToken[i] != 0){
                tokenLength++;
            }
        }
        return tokenLength;
    }
    function setTotal(uint grade,uint count) public isOwner{
        _gradeTotal[grade] = count;
    }
    function getGradeByNftId(uint256 tokenId)public view returns(uint256){
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");
        return _nftGrade[tokenId];
    }   
    function getNftName(uint256 nftId)public view returns(string memory){
        return _nftInfo[nftId];
    }
    function getNftPower(uint nftId) public view returns(uint256){
        uint256 grade = getGradeByNftId(nftId);
        return(_power[grade]);
    }
    function getGradeAllNftNames(uint grade)public view returns(string[] memory){
        return _nftNames[grade];
    }
}