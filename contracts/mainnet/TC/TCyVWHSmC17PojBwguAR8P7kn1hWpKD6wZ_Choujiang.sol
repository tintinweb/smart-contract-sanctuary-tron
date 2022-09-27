//SourceUnit: luckdraw.sol

pragma solidity 0.5.10;

library SafeMath {

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Choujiang {
  using SafeMath for uint256;
  address payable internal owner;
  uint256 constant public SET_RULE_FEE = 20;
  struct ActiInfo {
		string title;
    string desc;
    mapping (address => bool) accountStatus;
    address[] hasCJAddress;
    address[] luckyAddress;
    uint256 luckycount;
    uint256 hascjcount;
    bool isStart;
    address payable ruleMakeAddress;
		uint256 luckynum;
		uint256 totalnum;
	}
  
  mapping (string => ActiInfo) public activities;

  constructor() public {
    owner = msg.sender;
  }

  modifier ownerable() {
    require(msg.sender == owner,'只有管理员可以设置抽奖规则！');
    _;
  }

  modifier canCJ(string memory key) {
    require(activities[key].isStart,'抽奖暂未开始！');
    _;
  }

  function setRule(address payable makerAddress,string memory title,string memory desc,string memory key,uint256 luckynumarg,uint256 totalnumarg) public payable returns(string memory) {
    if(msg.value >= SET_RULE_FEE * 1e6) {
      activities[key].title = title;
      activities[key].desc = desc;
      activities[key].isStart = true;
      activities[key].ruleMakeAddress = makerAddress;
      activities[key].luckynum = luckynumarg;
      activities[key].totalnum = totalnumarg;
      return 'ok';
    }else {
      return 'fail';
    }
  }

  function startAct(address payable makerAddress,string memory key) public {
    require(!(activities[key].ruleMakeAddress == address(0)),'没有此次活动！');
    require(activities[key].ruleMakeAddress == makerAddress,'不是活动发起人！');
    require(!activities[key].isStart,'活动已经开启！');
    activities[key].isStart = true;
  }
  
  function getLuckMan(address useradress,string memory key) public returns(address[] memory) {
    if(!(activities[key].ruleMakeAddress == address(0))) {
      if(activities[key].isStart) {
        if(activities[key].hascjcount < activities[key].totalnum) {
          if(activities[key].luckycount < activities[key].luckynum) {
            if(!activities[key].accountStatus[useradress]) {
              uint256 luckManFlag = uint256(keccak256(abi.encodePacked((block.timestamp)
                            .add(block.difficulty)
                            .add((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now))
                            .add(block.gaslimit)
                            .add((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now))
                            .add(block.number)))) % 2;
              activities[key].accountStatus[useradress] = true;
              activities[key].hasCJAddress.push(useradress);
              activities[key].hascjcount =  activities[key].hascjcount.add(1);
              if(luckManFlag == 1) {
                activities[key].luckyAddress.push(useradress);
                activities[key].luckycount = activities[key].luckycount.add(1);
              }
            }
          }
        }
      }
    }
    return  activities[key].luckyAddress;
  }

  function getResultInfo(string memory key) public view returns(address[] memory,address[] memory) {
    return (activities[key].luckyAddress,activities[key].hasCJAddress);
  }
  function transfer(uint256 amount) ownerable public {
    owner.transfer(amount);
  }
}