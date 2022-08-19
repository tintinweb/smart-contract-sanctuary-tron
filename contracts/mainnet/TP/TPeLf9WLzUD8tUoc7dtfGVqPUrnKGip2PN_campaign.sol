//SourceUnit: campaign.sol

//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.0;


abstract contract owned {
 address payable public owner;

 constructor () {
 owner = payable(msg.sender);
 }

 modifier onlyOwner {
 require(msg.sender == owner,"only owner method");
 _;
 }

 function transferOwnership(address payable newOwner) onlyOwner public {
 owner = newOwner;
 }
}

interface ITRC20 {
 function totalSupply() external view returns (uint256);
 function balanceOf(address account) external view returns (uint256);
 function transfer(address recipient, uint256 amount) external returns (bool);
 function allowance(address owner, address spender) external view returns (uint256);
 function approve(address spender, uint256 amount) external returns (bool);
 function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
 event Transfer(address indexed from, address indexed to, uint256 value);
 event Approval(address indexed owner, address indexed spender, uint256 value);
 function withdraw(uint256 wad) external;
}

abstract contract ERC20Holder is owned {
 mapping (address => bool) acceptedTokens;
 function modToken(address token,bool accepted) public onlyOwner {
 acceptedTokens[token] = accepted;
 }
 
 function tokenFallback(address _from, uint _value, bytes32 _data) pure public returns (bytes32 hash) {
 bytes32 tokenHash = keccak256(abi.encodePacked(_from,_value,_data));
 return tokenHash;
 }
 
 receive() external payable {}
 
 function withdraw() onlyOwner public {
 owner.transfer(address(this).balance);
 }
 
 function transferToken (address token,address to,uint256 val) public onlyOwner {
 ITRC20 erc20 = ITRC20(token);
 erc20.transfer(to,val);
 }
 
}

contract oracleClient is ERC20Holder {
 
 address oracle;
 
 function setOracle(address a) public onlyOwner {
 
 oracle = a;
 }
}

interface IOracle {
 function ask (uint8 typeSN, string calldata idPost,string calldata idUser, bytes32 idRequest) external;
 function askBounty (uint8 typeSN, string calldata idPost,string calldata idUser, bytes32 idProm) external;
 
}


contract campaign is oracleClient {
 
 struct cpRatio {
 uint256 likeRatio;
 uint256 shareRatio;
 uint256 viewRatio;
 uint256 reachLimit;
 }
 
 struct bountyUnit {
 uint256 minRange;
 uint256 maxRange;
 uint256 typeSN;
 uint256 amount;
 }
 
 struct Campaign {
 address advertiser;
 string dataUrl; 
 uint64 startDate;
 uint64 endDate;
 uint64 nbProms;
 uint64 nbValidProms;
 mapping (uint64 => bytes32) proms;
 address token;
 uint256 amount;
 mapping(uint8 => cpRatio) ratios;
 bountyUnit[] bounties;
 }
 
 struct Fund {
 address token;
 uint256 amount;
 }
 
 struct Result {
 bytes32 idProm;
 uint64 likes;
 uint64 shares;
 uint64 views;
 }
 
 struct promElement {
 address influencer;
 bytes32 idCampaign;
 bool isAccepted;
 bool isPayed;
 address token;
 uint256 amount;
 uint8 typeSN;
 string idPost;
 string idUser;
 uint64 nbResults;
 mapping (uint64 => bytes32) results;
 bytes32 prevResult;
 }

 
 mapping (bytes32 => Campaign) public campaigns;
 mapping (bytes32 => promElement) public proms;
 mapping (bytes32 => Result) public results;
 mapping (bytes32 => bool) public isAlreadyUsed;
 
 
 event CampaignCreated(bytes32 indexed id,uint64 startDate,uint64 endDate,string dataUrl);
 event CampaignFundsSpent(bytes32 indexed id );
 event CampaignApplied(bytes32 indexed id ,bytes32 indexed prom );
 event PromAccepted(bytes32 indexed id );
 event PromPayed(bytes32 indexed id ,uint256 amount);
 event CampaignFunded(bytes32 indexed id,uint256 amount);
 
 
 
 function priceRatioCampaign(bytes32 idCampaign,uint8 typeSN,uint256 likeRatio,uint256 shareRatio,uint256 viewRatio,uint256 limit) internal {
 require(campaigns[idCampaign].advertiser == msg.sender,"campaign owner mismatch");
 campaigns[idCampaign].ratios[typeSN] = cpRatio(likeRatio,shareRatio,viewRatio,limit);
 }
 
 
 
 function fundCampaign (bytes32 idCampaign,address token,uint256 amount) public {
 require(campaigns[idCampaign].endDate > block.timestamp,"campaign ended");
 require(campaigns[idCampaign].token == address(0) || campaigns[idCampaign].token == token,"token mismatch");
 
 ITRC20 erc20 = ITRC20(token);
 erc20.transferFrom(msg.sender,address(this),amount);
 uint256 prev_amount = campaigns[idCampaign].amount;
 uint256 added_amount;
 
 //if(token == 0xDf49C9f599A0A9049D97CFF34D0C30E468987389 || token == 0x448BEE2d93Be708b54eE6353A7CC35C4933F1156) {
 added_amount = amount*95/100;
// }
// else {
// added_amount = amount*85/100;
// }
 campaigns[idCampaign].amount =added_amount+prev_amount;
 campaigns[idCampaign].token =token;
 emit CampaignFunded(idCampaign,added_amount); 
 }
 
 
 function createPriceFundAll(
 string memory dataUrl,
 uint64 startDate,
 uint64 endDate,
 
 uint256[] memory ratios,
 address token,
 uint256 amount) public returns (bytes32 idCampaign) {
 
 
 
 require(endDate > block.timestamp,"end date too early");
 require(endDate > startDate,"end date early than start");
 
 bytes32 campaignId = keccak256(abi.encodePacked(msg.sender,dataUrl,startDate,endDate,block.timestamp));
 Campaign storage c = campaigns[campaignId];
 c.advertiser = msg.sender;
 c.dataUrl = dataUrl;
 c.startDate = startDate;
 c.endDate = endDate;
 c.nbProms = 0;
 c.nbValidProms = 0;
 c.token = address(0);
 c.amount = 0;
 //campaigns[campaignId] = Campaign(msg.sender,dataUrl,startDate,endDate,0,0,Fund(address(0),0));
 emit CampaignCreated(campaignId,startDate,endDate,dataUrl);

 for (uint8 i=0;i<ratios.length;i=i+4) {
 priceRatioCampaign(campaignId,(i/4)+1,ratios[i],ratios[i+1],ratios[i+2],ratios[i+3]);
 }
 
 
 
 fundCampaign(campaignId,token,amount);
 return campaignId;
 }
 
 function createPriceFundBounty(
 string memory dataUrl,
 uint64 startDate,
 uint64 endDate,
 
 uint256[] memory bounties,
 address token,
 uint256 amount) public returns (bytes32 idCampaign) {
 
 
 require(endDate > block.timestamp,"end date too early");
 require(endDate > startDate,"end date early than start");
 
 bytes32 campaignId = keccak256(abi.encodePacked(msg.sender,dataUrl,startDate,endDate,block.timestamp));
 Campaign storage c = campaigns[campaignId];
 c.advertiser = msg.sender;
 c.dataUrl = dataUrl;
 c.startDate = startDate;
 c.endDate = endDate;
 c.nbProms = 0;
 c.nbValidProms = 0;
 c.token = address(0);
 c.amount = 0;
 for (uint i=0;i<bounties.length;i=i+4) {
 c.bounties.push(bountyUnit(bounties[i],bounties[i+1],bounties[i+2],bounties[i+3]));
 }
 
 emit CampaignCreated(campaignId,startDate,endDate,dataUrl);
 
 
 fundCampaign(campaignId,token,amount);
 return campaignId;
 }
 
 function applyCampaign(bytes32 idCampaign,uint8 typeSN, string memory idPost, string memory idUser) public returns (bytes32 idProm) {
 bytes32 prom = keccak256(abi.encodePacked(idCampaign,typeSN,idPost,idUser));
 require(campaigns[idCampaign].endDate > block.timestamp,"campaign ended");
 require(!isAlreadyUsed[prom],"link already sent");
 bytes32 newIdProm = keccak256(abi.encodePacked( msg.sender,typeSN,idPost,idUser,block.timestamp));
 promElement storage p = proms[newIdProm];
 p.influencer = msg.sender;
 p.idCampaign = idCampaign;
 p.isAccepted = false;
 p.token = address(0);
 p.amount = 0;
 p.typeSN = typeSN;
 p.idPost = idPost;
 p.idUser = idUser;
 p.nbResults = 0;
 p.prevResult = 0;
 //proms[idProm] = promElement(msg.sender,idCampaign,false,Fund(address(0),0),typeSN,idPost,idUser,0,0);
 campaigns[idCampaign].proms[campaigns[idCampaign].nbProms++] = newIdProm;
 
 bytes32 idRequest = keccak256(abi.encodePacked(typeSN,idPost,idUser,block.timestamp));
 results[idRequest] = Result(newIdProm,0,0,0);
 proms[newIdProm].results[0] = proms[newIdProm].prevResult = idRequest;
 proms[newIdProm].nbResults = 1;
 
 //ask(typeSN,idPost,idUser,idRequest);
 
 isAlreadyUsed[prom] = true;
 
 emit CampaignApplied(idCampaign,newIdProm);
 return newIdProm;
 }
 
 function validateProm(bytes32 idProm) public {
 Campaign storage cmp = campaigns[proms[idProm].idCampaign];
 require(cmp.endDate > block.timestamp,"campaign ended");
 require(cmp.advertiser == msg.sender,"campaign owner mismatch");
 
 proms[idProm].isAccepted = true;
 cmp.nbValidProms++;

 emit PromAccepted(idProm);
 }

 function validateProms(bytes32[] memory idProms) public {
 for(uint64 i = 0;i < idProms.length ;i++) {
 validateProm(idProms[i]);
 }
 }
 
 
 
 
 function updateCampaignStats(bytes32 idCampaign) public {
 for(uint64 i = 0;i < campaigns[idCampaign].nbProms ;i++)
 {
 bytes32 idProm = campaigns[idCampaign].proms[i];
 if(proms[idProm].isAccepted) {
 bytes32 idRequest = keccak256(abi.encodePacked(proms[idProm].typeSN,proms[idProm].idPost,proms[idProm].idUser,block.timestamp));
 results[idRequest] = Result(idProm,0,0,0);
 proms[idProm].results[proms[idProm].nbResults++] = idRequest;
 ask(proms[idProm].typeSN,proms[idProm].idPost,proms[idProm].idUser,idRequest);
 }
 }
 }
 
 function updatePromStats(bytes32 idProm) public returns (bytes32 requestId) {
 require(proms[idProm].isAccepted,"link not validated"); 
 bytes32 idRequest = keccak256(abi.encodePacked(proms[idProm].typeSN,proms[idProm].idPost,proms[idProm].idUser,block.timestamp));
 results[idRequest] = Result(idProm,0,0,0);
 proms[idProm].results[proms[idProm].nbResults++] = idRequest;
 ask(proms[idProm].typeSN,proms[idProm].idPost,proms[idProm].idUser,idRequest);
 return idRequest;
 }
 
 function updateBounty(bytes32 idProm) public {
 require(proms[idProm].isAccepted,"link not validated");
 askBounty(proms[idProm].typeSN,proms[idProm].idPost,proms[idProm].idUser,idProm);
 }
 
 
 
 function ask(uint8 typeSN, string memory idPost,string memory idUser,bytes32 idRequest) public {
 IOracle o = IOracle(oracle);
 o.ask(typeSN,idPost,idUser,idRequest);
 }
 
 function askBounty(uint8 typeSN, string memory idPost,string memory idUser,bytes32 idProm) public {
 IOracle o = IOracle(oracle);
 o.askBounty(typeSN,idPost,idUser,idProm);
 }
 
 function updateBounty(bytes32 idProm,uint256 nbAbos) external returns (bool ok) {
 require(msg.sender == oracle,"oracle mismatch");
 
 promElement storage prom = proms[idProm];
 require(!prom.isPayed,"link already paid");
 prom.isPayed= true;
 prom.token = campaigns[prom.idCampaign].token;
 
 uint256 gain = 0;
 for(uint256 i = 0;i<campaigns[prom.idCampaign].bounties.length;i++){
 if(nbAbos >= campaigns[prom.idCampaign].bounties[i].minRange && nbAbos < campaigns[prom.idCampaign].bounties[i].maxRange && prom.typeSN == campaigns[prom.idCampaign].bounties[i].typeSN)
 {
 gain = campaigns[prom.idCampaign].bounties[i].amount;
 }
 }
 
 if(campaigns[prom.idCampaign].amount <= gain )
 {
 //campaigns[prom.idCampaign].endDate = uint64(block.timestamp);
 prom.amount += campaigns[prom.idCampaign].amount;
 campaigns[prom.idCampaign].amount = 0;
 emit CampaignFundsSpent(prom.idCampaign);
 return true;
 }
 campaigns[prom.idCampaign].amount -= gain;
 prom.amount += gain;
 return true;
 
 }
 
 function update(bytes32 idRequest,uint64 likes,uint64 shares,uint64 views) external returns (bool ok) {
 require(msg.sender == oracle,"oracle mismatch");
 
 
 promElement storage prom = proms[results[idRequest].idProm];
 
 results[idRequest].likes = likes;
 results[idRequest].shares = shares;
 results[idRequest].views = views;
 
 uint256 gain = 0;
 
 if(likes > results[prom.prevResult].likes)
 gain += (likes - results[prom.prevResult].likes)* campaigns[prom.idCampaign].ratios[prom.typeSN].likeRatio;
 if(shares > results[prom.prevResult].shares)
 gain += (shares - results[prom.prevResult].shares)* campaigns[prom.idCampaign].ratios[prom.typeSN].shareRatio;
 if(views > results[prom.prevResult].views)
 gain += (views - results[prom.prevResult].views)* campaigns[prom.idCampaign].ratios[prom.typeSN].viewRatio;
 prom.prevResult = idRequest;
 
 //
 // warn campaign low credits
 //
 
 
 if(prom.token == address(0))
 {
 prom.token = campaigns[prom.idCampaign].token;
 }
 if(campaigns[prom.idCampaign].amount <= gain )
 {
 //campaigns[prom.idCampaign].endDate = uint64(block.timestamp);
 prom.amount += campaigns[prom.idCampaign].amount;
 campaigns[prom.idCampaign].amount = 0;
 emit CampaignFundsSpent(prom.idCampaign);
 return true;
 }
 campaigns[prom.idCampaign].amount -= gain;
 prom.amount += gain;
 return true;
 }
 


function getGains(bytes32 idProm,bool wrapped) public {
 require(proms[idProm].influencer == msg.sender,"link owner mismatch");
 uint256 amount = proms[idProm].amount;
ITRC20 erc20 = ITRC20(proms[idProm].token);
 proms[idProm].amount = 0;

 if (wrapped)
 {
 erc20.withdraw(amount);
 payable(proms[idProm].influencer).transfer(amount);
 }
 else 
 {
 erc20.transfer(proms[idProm].influencer,amount);
 }
 emit PromPayed(idProm,amount);
 }


 
 
 
 function getRemainingFunds(bytes32 idCampaign) public {
 require(campaigns[idCampaign].advertiser == msg.sender,"campaign owner mismatch");
 require(campaigns[idCampaign].endDate < block.timestamp,"campaign not ended");
 ITRC20 erc20 = ITRC20(campaigns[idCampaign].token);
 uint256 amount = campaigns[idCampaign].amount;
 campaigns[idCampaign].amount = 0;
 erc20.transfer(campaigns[idCampaign].advertiser,amount);
 }
 
 function getProms (bytes32 idCampaign) public view returns (bytes32[] memory cproms)
 {
 uint nbProms = campaigns[idCampaign].nbProms;
 cproms = new bytes32[](nbProms);
 
 for (uint64 i = 0;i<nbProms;i++)
 {
 cproms[i] = campaigns[idCampaign].proms[i];
 }
 return cproms;
 }
 
 function getRatios (bytes32 idCampaign) public view returns (uint8[] memory types,uint256[] memory likeRatios,uint256[] memory shareRatios,uint256[] memory viewRatios,uint256[] memory limits )
 { 
 uint8 l = 10;
 types = new uint8[](l);
 likeRatios = new uint256[](l);
 shareRatios = new uint256[](l);
 viewRatios = new uint256[](l);
 limits = new uint256[](l);
 for (uint8 i = 0;i<l;i++)
 {
 types[i] = i+1;
 likeRatios[i] = campaigns[idCampaign].ratios[i+1].likeRatio;
 shareRatios[i] = campaigns[idCampaign].ratios[i+1].shareRatio;
 viewRatios[i] = campaigns[idCampaign].ratios[i+1].viewRatio;
 limits[i] = campaigns[idCampaign].ratios[i+1].reachLimit;
 }
 return (types,likeRatios,shareRatios,viewRatios,limits);
 }
 
 function getBounties (bytes32 idCampaign) public view returns (uint256[] memory bounty )
 { 
 bounty = new uint256[](campaigns[idCampaign].bounties.length*4);
 for (uint8 i = 0; i<campaigns[idCampaign].bounties.length; i++)
 {
 bounty[i*4] = campaigns[idCampaign].bounties[i].minRange;
 bounty[i*4+1] = campaigns[idCampaign].bounties[i].maxRange;
 bounty[i*4+2] = campaigns[idCampaign].bounties[i].typeSN;
 bounty[i*4+3] = campaigns[idCampaign].bounties[i].amount;
 }
 return bounty;
 }
 
 
 function getResults (bytes32 idProm) public view returns (bytes32[] memory creq)
 {
 uint nbResults = proms[idProm].nbResults;
 creq = new bytes32[](nbResults);
 for (uint64 i = 0;i<nbResults;i++)
 {
 creq[i] = proms[idProm].results[i];
 }
 return creq;
 }
 

 
 function getIsUsed(bytes32 idCampaign,uint8 typeSN, string memory idPost, string memory idUser) public view returns (bool) {
 bytes32 prom = keccak256(abi.encodePacked(idCampaign,typeSN,idPost,idUser));
 return isAlreadyUsed[prom];
 }
 
 
}