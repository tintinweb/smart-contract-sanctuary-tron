//SourceUnit: ts.sol

pragma solidity ^0.6.12;
 // SPDX-License-Identifier: Unlicensed

library Math {
   
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

  
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {
     
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}


library SafeMath {
   
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

 
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


interface IERC20 {
   
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

   
    function transfer(address recipient, uint256 amount) external returns (bool);

    function mint(address account, uint amount) external;

  
    function allowance(address owner, address spender) external view returns (uint256);

   
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function burn(uint256 amount) external;

    event Transfer(address indexed to, uint256 value);


    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library Address {
  
    function isContract(address account) internal view returns (bool) {
       
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        
        assembly {codehash := extcodehash(account)}
        return (codehash != 0x0 && codehash != accountHash);
    }

   
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }


  
}


library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
      
        require((value == 0) || (token.allowance(address(this), spender) == 0),
     
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {
      
        // require(address(token).isContract(), "SafeERC20: call to non-contract");

       
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


contract TokenWrapper {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    mapping(address=>bool) internal  governance;
    // address internal erylpaddress;
    // address internal eoilpaddress;
    // address internal eryad;
    // address internal eoiad;
    // address internal eunad;

    address internal erylpaddress;
    address internal eoilpaddress;
    address internal eryad;
    address internal eoiad;
    address internal eunad;

    event Transfer(IERC20 token,address toad,uint256 amount);
    event transferFrom(address token,address toad,uint256 amount);
    event  TreeAprove(IERC20 token,address toad,uint256 amount);
    function transfromcoin(address coinaddress,address fromad,address toad,uint256 amount) internal {
        // usdt.safeApprove(toad,amount);
        IERC20(coinaddress).safeTransferFrom(fromad,toad,amount);
        emit transferFrom(fromad,toad,amount);
    }
  
	function transcoin(address coinaddress,address toad,uint256 amount) internal {
        IERC20(coinaddress).safeTransfer(toad, amount);
        emit Transfer(IERC20(coinaddress),toad,amount);
    } 

}

contract tswork is TokenWrapper {
    using SafeMath for uint256;
    struct deposit{
        uint256 erycount;//折算ery数量
        uint256 lpcount;//lp的数量
        uint256 day;//质押天数
        uint256 times;//质押时间
        uint256 withdrawtimes;//收割时间
        bool isover;//是否赎回
        uint256 types;//0为ery lp,1为eoi lp
    }
    struct users{
        deposit[] Deopsit;//质押情况
        address referer;//推荐人
        uint256 tzbonusery;//投资奖励
        uint256 tzbonuseoi;//投资奖励
        uint256 tzbonuseun;//投资奖励
        uint256 referbonusery;//推荐奖励
        uint256 referbonuseoi;//推荐奖励
        uint256 referbonuseun;//推荐奖励
        address[] myson;//我推荐了谁 
    }
    address private _governance_;


    // 总共可挖剩余
    uint256  private mintery;//ery
    uint256  private minteoi;//eoi
    uint256  private minteun;//eun
    // 总共推荐奖励剩余
    uint256  private eryrefer;//ery
    uint256  private eoirefer;//eoi
    uint256  private eunrefer;//eun
    // 代币已经挖了多少
    uint256  private minteryyet;//ery
    uint256  private minteoiyet;//eoi
    uint256  private minteunyet;//eun
    // 推荐奖励已经发出了多少
    uint256  private eryreferyet;//ery
    uint256  private eoireferyet;//eoi
    uint256  private eunreferyet;//eun

    //30,60,90场次限制
    uint256 private lperycount30;
    uint256 private lperycount60;
    uint256 private lperycount90;
    uint256 private lpeoicount30;
    uint256 private lpeoicount60;
    uint256 private lpeoicount90;

    //已经购买过的
    uint256 private lperycount30ed;
    uint256 private lperycount60ed;
    uint256 private lperycount90ed;

    uint256 private lpeoicount30ed;
    uint256 private lpeoicount60ed;
    uint256 private lpeoicount90ed;

    //设置私募场次
    uint256 private smcount;
    uint256 private smcounted;
    //锁仓量
    mapping(address=>uint256) private _lockerybalance_;
    mapping(address=>uint256) private _islock;

    // 挖矿开始时间
    uint256 private minteoistarttime;// eoi
    uint256 private minteunstarttime;// eun
    

    //每级拿到的收益百分比
    // uint256[4]  private CLASSBONUSSUM=[80,160,320,480];
    uint256[3]  private CLASSBONUSSUM=[30,70,150];
    // mapping(uint256=>uint256) private idays;//投资天数
    //百分比常量
    uint256 constant private PERCENT=1000;

    //总锁仓量
    uint256 private erylplockall;
    //总锁仓量lp
    uint256 private eoilplockall;
    
    //总收益
    uint256 private eryprofitall;
    uint256 private eoiprofitall;
    uint256 private eunprofitall;
    mapping (uint=>uint) private PROFIT;
    uint256 private decimals;
    address private uad;

    address payable public walletad;

    constructor () public {
        _governance_=msg.sender;
        governance[msg.sender] = true;
        walletad=address(0x416cf3cec05695eff7b5533e46c684b81cc5d46018);
        //收益比例
        PROFIT[30]=5680;
        PROFIT[60]=12800;
        PROFIT[90]=21600;
        PROFIT[20000]=3360000;
        decimals=10**6;
        lpeoicount30=4;
        lpeoicount60=4;
        lpeoicount90=4;
        lperycount30=4;
        lperycount60=4;
        lperycount90=4;
        smcount=1000;
        //币地址
        // erylpaddress = 0x818bDD6cFFbEb318EEFa466d2eE2f4ad6Be57A25;
        // eoilpaddress = 0x7528302a5Bb7a0c50B14f8B059DE06602624c0b5;
        // eryad = 0xF290BA682A09c05Fc4CE25874f68C16C4aE6C694;
        // eoiad = 0x685f7771AD517443166a40111e4ec33923a546D7;
        // eunad = 0x68d2e1728bf6c1108E67FaFbB7411b6b3269730c;
        // uad=0x6a12EacAb697B84Cb85939E84D2bfBe682a7203E;
        erylpaddress = address(0x417e3fe75df973f91dc63f99b70c353da1a105ad94);
        eoilpaddress = address(0x417e3fe75df973f91dc63f99b70c353da1a105ad94);
        eryad = address(0x41ef87f2e05913564f11963c545a104b28497cc103);
        eoiad = address(0x410e002fc66176ddba7ddd6774a8cc1a3ce418053c);
        eunad = address(0x410e002fc66176ddba7ddd6774a8cc1a3ce418053c);
        uad=address(0x41a614f803b6fd780986a42c78ec9c7f77e6ded13c);
        //总共可挖剩余
        mintery = 10*10000*decimals;//ery
        minteoi = 1300*10000*decimals;//eoi
        minteun = 1300*10000*decimals;//eun
        //总共推荐奖励剩余
        eryrefer = 10*10000*decimals;//ery
        eoirefer = 500*10000*decimals;//eoi
        eunrefer = 500*10000*decimals;//eun
        unlocklpcount=100*decimals;
        lpstarttime=block.timestamp;
        //挖矿开始时间
        minteoistarttime = block.timestamp; //eoi于ery结束12小时后上线
        minteunstarttime = block.timestamp+400*timevalue;//eun
    }

    //uint256 timevalue=24*3600;
    uint256 timevalue=60;
    mapping (address => users) internal Users;
    //24小时内添加流动性
    uint256 private lpstarttime;
    uint256 private unlocklpcount;
    
    //用户的可用余额
    mapping(address=>uint256) internal _erybalance_;
    mapping(address=>uint256) internal _eoibalance_;
    mapping(address=>uint256) internal _eunbalance_;
    

    uint256[] internal tmp12;

    /**参数说明
    *fromad投资人地址
    *ireferrer推荐人地址
    *priceu当前tree价格 
    *amount质押的tree数量
    *day质押天数
    */
    function invest(address fromad,address ireferer,uint256 amount,uint256 itype,uint256 ddays) public{
        //初始化用户
        users storage user = Users[fromad];
    	//如果用户没有推荐人，并且推荐人不是自己,则推荐关系成立
        if(lpstarttime+timevalue>=block.timestamp && _islock[fromad]==1 && amount>=unlocklpcount){
                _islock[fromad]=2;
        }
        
    
        addrefer(fromad,ireferer);
        addmyson(fromad,ireferer);
        address tmpad;
        if(itype==0){
            if(ddays==30){
                require(lperycount30>lperycount30ed,'sell out');
                lperycount30ed=lperycount30ed.add(1);
            }else if(ddays==60){
                require(lperycount60>lperycount60ed,'sell out');
                lperycount60ed=lperycount60ed.add(1);
            }else if(ddays==90){
                require(lperycount90>lperycount90ed,'sell out');
                lperycount90ed=lperycount90ed.add(1);
            }
            uint256 equalery;
            tmpad=erylpaddress;
            equalery=amount.mul(IERC20(eryad).balanceOf(erylpaddress)).div(IERC20(erylpaddress).totalSupply());
            // equalery=amount.mul(eryad.balanceOf((erylpaddress))).div(erylpaddress.totalSupply());
            // equalery=100;
            
            //添加总锁仓
            erylplockall=erylplockall.add(amount);
            user.Deopsit.push(deposit(equalery,amount,ddays,
            block.timestamp,block.timestamp,false,0));
        }else if(itype==1){
            if(ddays==30){
                require(lpeoicount30>lpeoicount30ed,'sell out');
                lpeoicount30ed=lpeoicount30ed.add(1);
            }else if(ddays==60){
                require(lpeoicount60>lpeoicount60ed,'sell out');
                lpeoicount60ed=lpeoicount60ed.add(1);
            }else if(ddays==90){
                require(lpeoicount90>lpeoicount90ed,'sell out');
                lpeoicount90ed=lpeoicount90ed.add(1);
            }
            tmpad=eoilpaddress;
             eoilplockall=eoilplockall.add(amount);
            user.Deopsit.push(deposit(0,amount,ddays,
            block.timestamp,block.timestamp,false,1));
        }

        //转币到合约
        super.transfromcoin(tmpad,fromad,address(this),amount);
    }

    function addmyson(address fromad,address irefer) internal returns(bool){
        bool flag=false;
        for(uint i=0;i<Users[irefer].myson.length;i++){
            if(Users[irefer].myson[i]==fromad || fromad==irefer){
                flag=true;
                break;
            }
        }
        if(flag==false){
            Users[irefer].myson.push(fromad);
        }
    }
    //添加推荐人
    function addrefer(address fromad,address irefer) internal returns(bool){
        if (Users[fromad].referer == address(0)  && irefer != fromad) {
            Users[fromad].referer = irefer;
            return true;
        }else{
            return false;
        }
    }

    //返回用户所有的投资 fromad为用户地址，返回的是投资的次数
    function getdeposit(address fromad) public view returns(uint){
        users storage user=Users[fromad];
        return user.Deopsit.length;
    }

    function gettypeindex(address fromad,uint256 ddays,uint256 iitype) public  returns(uint256[] memory){
        //初始化用户
        // require(fromad==msg.sender);
        users storage user = Users[fromad]; 
        delete tmp12;
        for(uint256 i=0;i<user.Deopsit.length;i++){
            // uint256 depositindex;
            // uint256 lpget;
            if(user.Deopsit[i].isover==false && user.Deopsit[i].types==iitype && user.Deopsit[i].day==ddays){
                tmp12.push(i);
            }
        }
        return tmp12;
    }
    //返回用户每次的投资信息，fromad为用户地址 ，depositindex为投资的某一次
    function getdepositinfo(address fromad,uint256 depositindex) public
     view returns(uint256,uint256,uint256,bool,uint256){
        users storage user=Users[fromad];
        return (user.Deopsit[depositindex].lpcount,user.Deopsit[depositindex].day,
        user.Deopsit[depositindex].times,user.Deopsit[depositindex].isover,
        user.Deopsit[depositindex].types);

    }

  
    //用户按钮状态,传参与以往说明相同，返回值为0，调用收割，返回值为1，调用赎回，返回值为2，显示过期 ，返回值为3 ，为灵活赎回的
    function menustatus(address fromad,uint256 depositindex) public view returns(uint){
        
        users storage user=Users[fromad];
        
        if(user.Deopsit[depositindex].isover==true){
            return 2;
        }
        else if (user.Deopsit[depositindex].day == 20000 &&user.Deopsit[depositindex].isover==false){
            return 3;
        } 
        else if(user.Deopsit[depositindex].day*timevalue+user.Deopsit[depositindex].times
            ==user.Deopsit[depositindex].withdrawtimes){
              return 1;
          }
         else{
            return 0;
        }
    }
    //我的可用
    function getbalance(address fromad,uint256 itype) public view returns(uint256){
        if(itype==0){
            return _erybalance_[fromad];
        }else if(itype==1){
            return _eoibalance_[fromad];
        }else if(itype==2){
            return _eunbalance_[fromad];
        }    
    }

    //返回总收益
    function getallprofit(uint256 itype) public view returns(uint256){
        if(itype==0){
            return eryprofitall;
        }else if(itype==1){
            return eoiprofitall;
        }else{
            return eunprofitall;
        }
    }
    //返回总锁仓
    function getlockcountall(uint256 itype) public view returns(uint256){
        if(itype==0){
            return erylplockall;
        }else if(itype==1){
            return eoilplockall;
        }
    }
    //个人总锁仓量
    function getpersonallock(address fromad,uint256 itype) public view returns(uint256){
        users storage user=Users[fromad];
        uint256 tmppersonallock;
        for(uint i=0;i<user.Deopsit.length;i++){
            if(user.Deopsit[i].isover==false&&user.Deopsit[i].types==itype){
                tmppersonallock=tmppersonallock.add(user.Deopsit[i].lpcount);
            }
        }
        return tmppersonallock;
    }
    
    //我的市场质押量
    function getmygroup(address fromad,uint256 itype) public view returns(uint256){
        users storage user=Users[fromad];
        uint256 tmpmygroup;
        for(uint256 i=0;i<user.myson.length;i++){
            for(uint256 j=0;j<Users[user.myson[i]].Deopsit.length;j++){
                if(Users[user.myson[i]].Deopsit[j].types==itype){
                    tmpmygroup=tmpmygroup+Users[user.myson[i]].Deopsit[j].lpcount;
                }   
            }      
        }
        return tmpmygroup;
    }
    //我的市场收益
    function getmygroupprofit(address fromad,uint256 itype) public view returns(uint256){
        users storage user=Users[fromad];
        uint256 tmpmygroup;
        for(uint256 i=0;i<user.myson.length;i++){
            for(uint256 j=0;j<Users[user.myson[i]].Deopsit.length;j++){
                if(Users[user.myson[i]].Deopsit[j].types==itype){
                    if(itype==0){
                        tmpmygroup=tmpmygroup+Users[user.myson[i]].referbonusery;
                    }else if(itype==1){
                        tmpmygroup=tmpmygroup+Users[user.myson[i]].referbonuseoi;
                    }else if(itype==2){
                        tmpmygroup=tmpmygroup+Users[user.myson[i]].referbonuseun;
                    }
                    
                }   
            }     
        }
        
        // tmpmygroup=user.referbonus;
        return tmpmygroup;
    }
    //我的推荐市场(一级)
    function getmyson(address fromad) public view returns(address[] memory){
        users storage user=Users[fromad];
        return user.myson;
    }
    
        
    //获取推荐人
    function getmyrefer(address fromad) public view returns(address){
        return Users[fromad].referer;
    }
    //提取
    function geteth(uint256 amount) public payable{
        require(msg.value>=amount);
        walletad.transfer(amount);
    }
    //后台调用提现
    function withdraw(address coinad,address toad,uint256 amount) public { 
        require(msg.sender==walletad,'require ownered');
        super.transcoin(coinad,toad,amount);
    }
    // function withdrawn(address fromad,uint256 amount,uint256 itype) public{
    //     require(fromad==msg.sender);
    //     if(itype==0){
    //         require(_erybalance_[fromad]>=amount,"balance is not enough");
    //         _erybalance_[fromad]=_erybalance_[fromad].sub(amount);
    //         super.transcoin(eryad,fromad,amount);
    //     }else if(itype==1){
    //         require(_eoibalance_[fromad]>=amount,"balance is not enough");
    //         _eoibalance_[fromad]=_eoibalance_[fromad].sub(amount);
    //         super.transcoin(eoiad,fromad,amount);
    //     }else if(itype==2){
    //         require(_eunbalance_[fromad]>=amount,"balance is not enough");
    //         _eunbalance_[fromad]=_eunbalance_[fromad].sub(amount);
    //         super.transcoin(eunad,fromad,amount);
    //     }
        
    // }
   


   

      //收割lp,用户地地址，投资id
    function harvesterylp(address fromad,uint256 iindex,uint256 itype) public {
        //初始化用户
        require(fromad==msg.sender);
        users storage user = Users[fromad]; 
        // if (user.Deopsit[iindex].day!=20000){
        //     require(block.timestamp >= user.Deopsit[iindex].times+user.Deopsit[iindex].day*timevalue);
        // }
       
        uint256 lpget;
        if(user.Deopsit[iindex].isover==false){
            if (user.Deopsit[iindex].day == 20000){
                //计算收益
                lpget=PROFIT[user.Deopsit[iindex].day]*user.Deopsit[iindex].lpcount*
                    (block.timestamp-user.Deopsit[iindex].withdrawtimes)/
                    user.Deopsit[iindex].day/timevalue/PERCENT;
            }else{
                lpget=getmyvalueindex(fromad,iindex,itype);
            }
            
            if(itype==0){
                if (mintery <= lpget){
                    lpget = mintery;
                    mintery = 0;
                }else{
                    mintery -= lpget;
                }
                minteryyet += lpget;

                _erybalance_[fromad]=_erybalance_[fromad].add(lpget);
                user.tzbonusery=user.tzbonusery.add(lpget);
                eryprofitall=eryprofitall.add(lpget);
            }else if(itype==1){
                if (minteoi <= lpget){
                    lpget = minteoi;
                    minteoi = 0;
                }else{
                    minteoi -= lpget;
                }
                minteoiyet += lpget;

                _eoibalance_[fromad]=_eoibalance_[fromad].add(lpget);
                user.tzbonuseoi=user.tzbonuseoi.add(lpget);
                eoiprofitall=eoiprofitall.add(lpget);
            }else{
                if (minteun < lpget){
                    lpget = minteun;
                    minteun = 0;
                }else{
                    minteun -= lpget;
                }
                minteunyet += lpget;

                _eunbalance_[fromad]=_eunbalance_[fromad].add(lpget);
                user.tzbonuseun=user.tzbonuseun.add(lpget);
                eunprofitall=eunprofitall.add(lpget);
            }

            // 重置收割时间
            if(block.timestamp>=user.Deopsit[iindex].times+user.Deopsit[iindex].day*timevalue ){
                user.Deopsit[iindex].withdrawtimes = user.Deopsit[iindex].times+user.Deopsit[iindex].day*timevalue;
            }else{
                user.Deopsit[iindex].withdrawtimes = block.timestamp;
            }
            

            // 发放收益
            uint256 tmpallprofit;
            
            if(user.referer!= address(0)){
                address upline=user.referer;
                for(uint j=0;j<=2;j++){
                    if(upline!=address(0)){
                        uint256 referget = lpget*CLASSBONUSSUM[j]/PERCENT;

                        if(itype==0){
                            // 剩余可推荐不足，
                            if (eryrefer == 0 ){
                                return ;
                            }
                            if (eryrefer <= referget){
                                referget = eryrefer;
                                eryrefer = 0;
                            }else{
                                eryrefer -= referget;
                            }
                            eryreferyet += lpget;
                            
                            Users[upline].referbonusery=Users[upline].referbonusery+referget;
                            _erybalance_[upline]=_erybalance_[upline]+referget;
                            tmpallprofit=tmpallprofit.add(referget);
                        }else if(itype==1){
                            if (eoirefer == 0 ){
                                return ;
                            }
                            if (eoirefer <= referget){
                                referget = eoirefer;
                                eoirefer = 0;
                            }else{
                                eoirefer -= referget;
                            }
                            eoireferyet += lpget;

                            Users[upline].referbonuseoi=Users[upline].referbonuseoi+referget;
                            _eoibalance_[upline]=_eoibalance_[upline]+referget;
                            tmpallprofit=tmpallprofit.add(referget);
                        }else{
                            if (eunrefer == 0 ){
                                return ;
                            }
                            if (eunrefer <= referget){
                                referget = eunrefer;
                                eunrefer = 0;
                            }else{
                                eunrefer -= referget;
                            }
                            eunreferyet += lpget;

                            Users[upline].referbonuseun=Users[upline].referbonuseun+referget;
                            _eunbalance_[upline]=_eunbalance_[upline]+referget;
                            tmpallprofit=tmpallprofit.add(referget);
                        }
                        
                        upline=Users[upline].referer;
                    }else{
                        break;
                    }
                    
                }
                        
            }
            if(itype==0){
                eryprofitall=eryprofitall.add(tmpallprofit);
            }else if(itype==1){
                eoiprofitall=eoiprofitall.add(tmpallprofit);
            }else if(itype==2){
                eunprofitall=eunprofitall.add(tmpallprofit);
            }
            
        }
    }

    //个人总锁仓量lp
    function getlppersonallock(address fromad,uint256 itype) public view returns(uint256){
        users storage user=Users[fromad];
        uint256 tmppersonallock;
        for(uint i=0;i<user.Deopsit.length;i++){
            if(user.Deopsit[i].isover==false&&user.Deopsit[i].types==itype){
                tmppersonallock=tmppersonallock.add(user.Deopsit[i].lpcount);
            }
        }
  
        return tmppersonallock;
    }

    
    function setgoverance(address _governance) public {
        require(msg.sender == _governance_||governance[_governance]==true, "!governance");
        _governance_=_governance;
        governance[_governance] = true;
        // _governance_[governance] = true;
    }
    function getgoverance() public view returns(address){
        return _governance_;
    }
   //个人总收益
   function getpersonalprofit(address fromad,uint256 itype) public view returns(uint256){
       users storage user=Users[fromad];
       if(itype==0){
           return (user.tzbonusery+user.referbonusery);
       }else if(itype==1){
           return (user.tzbonuseoi+user.referbonuseoi);
       }else{
           return (user.tzbonuseun+user.referbonuseun);
       }
       
   }
   //质押中的价值
   function getdepositvalue(address fromad,uint256 ddays,uint256 itype) public view returns(uint256){
       users storage user =Users[fromad];
       uint256 tmp;
       for(uint256 i=0;i<user.Deopsit.length;i++){
           if(user.Deopsit[i].types==itype && user.Deopsit[i].isover==false && user.Deopsit[i].day==ddays){
               tmp=tmp.add(user.Deopsit[i].lpcount);
           }
       }
       return tmp;
   }

 

   //我的可提取收益
   function getmyvalue(address fromad,uint256 ddays,uint256 itype) public view  returns(uint256){
        users  storage user=Users[fromad];
        uint256 tmp;
        uint256 harvesttimes;
        uint256 tmppersonallockery;
        for(uint i=0;i<user.Deopsit.length;i++){
                if(user.Deopsit[i].isover==false&&user.Deopsit[i].types==0){
                    tmppersonallockery=tmppersonallockery.add(user.Deopsit[i].erycount);
                }
            }
        if (tmppersonallockery<500 &&itype==0){
            return 0;
        }
        for(uint256 i=0;i<user.Deopsit.length;i++){
            uint256 depositindex=i;
            if(user.Deopsit[depositindex].isover==false&&user.Deopsit[depositindex].types==itype && user.Deopsit[depositindex].day==ddays){
                //计算收益
                if(block.timestamp>=user.Deopsit[depositindex].times+user.Deopsit[depositindex].day*timevalue ){
                    harvesttimes=user.Deopsit[depositindex].times+user.Deopsit[depositindex].day*timevalue;
                }else{
                    harvesttimes=block.timestamp;
                }
                uint256 tmpprofit=PROFIT[user.Deopsit[depositindex].day]*user
                .Deopsit[depositindex].lpcount*
                (harvesttimes-user.Deopsit[depositindex].withdrawtimes)/
                user.Deopsit[depositindex].day/timevalue/PERCENT;
                tmp=tmp.add(tmpprofit);
                
            } 
        }
        return tmp;
   }

      //我的可提取收益单个
   function getmyvalueindex(address fromad,uint256 index1,uint256 itype) public  view returns(uint256){
        users  storage user=Users[fromad];
        uint256 tmp;
        uint256 harvesttimes;
        uint256 tmppersonallockery;
        for(uint i=0;i<user.Deopsit.length;i++){
                if(user.Deopsit[i].isover==false&&user.Deopsit[i].types==0){
                    tmppersonallockery=tmppersonallockery.add(user.Deopsit[i].erycount);
                }
            }
        if (tmppersonallockery<500 &&itype==0){
            return 0;
        }
        // for(uint256 i=0;i<user.Deopsit.length;i++){
        uint256 depositindex=index1;
        if(user.Deopsit[depositindex].isover==false&&user.Deopsit[depositindex].types==itype ){
            //计算收益
            if(block.timestamp>=user.Deopsit[depositindex].times+user.Deopsit[depositindex].day*timevalue ){
                harvesttimes=user.Deopsit[depositindex].times+user.Deopsit[depositindex].day*timevalue;
            }else{
                harvesttimes=block.timestamp;
            }
            uint256 tmpprofit=PROFIT[user.Deopsit[depositindex].day]*user
            .Deopsit[depositindex].lpcount*
            (harvesttimes-user.Deopsit[depositindex].withdrawtimes)/
            user.Deopsit[depositindex].day/timevalue/PERCENT;
            tmp=tmp.add(tmpprofit);
            
        } 
        // }
        return tmp;
   }

    // 收割ery lp
    function harvestery(address fromad,uint256 iindex,uint256 itype) public {
        require((itype == 0 || itype == 1),"invalid type");
        if (itype == 0 ){
            users storage user=Users[fromad];
            uint256 tmppersonallockery; // ery count
            for(uint i=0;i<user.Deopsit.length;i++){
                if(user.Deopsit[i].isover==false&&user.Deopsit[i].types==0){
                    tmppersonallockery=tmppersonallockery.add(user.Deopsit[i].erycount);
                }
            }
            if (tmppersonallockery>=500 && mintery>0){
                harvesterylp(fromad, iindex, 0);
            }
            if (block.timestamp>=minteoistarttime && minteoi>0){
                harvesterylp(fromad, iindex, 1);
            }
            
            
        }
        
        if ((itype == 0 || itype == 1) && (block.timestamp>=minteunstarttime) && minteun>0){
            // 收割eun
            harvesterylp(fromad, iindex, 2);
        }
        
    }

    //用户赎回lp，使用 itype 区分类型
    function redeemlp(address fromad, uint iindex,uint256 itype ) public{
        require(fromad==msg.sender);
        require(itype == 0 || itype == 1,"wrong type");
        users storage user= Users[fromad];
        deposit storage theDeopsit = user.Deopsit[iindex];
        //解锁
        if(theDeopsit.times+30*timevalue>=block.timestamp){
            if(_lockerybalance_[fromad]>0 && _islock[fromad]==2){
                _erybalance_[fromad]=_erybalance_[fromad].add(_lockerybalance_[fromad]);
                _lockerybalance_[fromad]=0;
                _islock[fromad]=3;
            }
        }
        if (theDeopsit.day == 20000){// 灵活收割先赎回
            harvesterylp(fromad, iindex, itype);
        }else{ 
            require(block.timestamp >= theDeopsit.times + theDeopsit.day*timevalue,"time is not over");
        }
        
        require(theDeopsit.types==itype ,"different invest type");
        require(theDeopsit.isover==false ,"already redeem");
        // require(menustatus(fromad, iindex) == 1,"invalid status");// 状态错误

        address theLpAddress ;
        if (itype == 0){   // ery lp
            require(erylplockall  >=theDeopsit.lpcount,"all locked erylp not enough");
            erylplockall=erylplockall.sub(theDeopsit.lpcount);
            theLpAddress = erylpaddress;
        }else  if (itype == 1){ // eoi lp
            require(eoilplockall  >=theDeopsit.lpcount,"all locked erylp not enough");
            eoilplockall=eoilplockall.sub(theDeopsit.lpcount);
            theLpAddress = eoilpaddress;
        }
        user.Deopsit[iindex].isover=true;

        // 转lp币到个人钱包
        super.transcoin(theLpAddress,fromad,theDeopsit.lpcount);
    }
    
    // 设置挖币开始时间
    function setmintstarttime(uint256 starttime,uint itype) public{
        require(governance[msg.sender]==true || _governance_ == msg.sender ,"not have privilige!");
        require(starttime!=0,"invalid start time");
        if (itype == 1){    // eoi
            minteoistarttime = starttime;
        }else if (itype == 2){// eun
            minteunstarttime = starttime;
        }
    }
    // 查询挖币开始时间
    function getmintstarttime(uint itype) public view returns(uint256){
        if (itype == 1){    // eoi
            return minteoistarttime;
        }else if (itype == 2){// eun
            return minteunstarttime;
        }
    }
    // 查询已经挖出的币的数量
    function getmintyet(uint itype) public view returns(uint256){
        if (itype == 0){   //ery
            return minteryyet;
        }else if (itype == 1){//eoi
            return minteoiyet;
        }else if (itype == 2){//eun
            return minteunyet;
        }
    }
    // 查询已经奖励出去的数量
    function getreferyet(uint itype) public view returns(uint256){
        if (itype == 0){   //ery
            return eryreferyet;
        }else if (itype == 1){//eoi
            return eoireferyet;
        }else if (itype == 2){//eun
            return eunreferyet;
        }
    }

    function sm(address fromad,uint256 amount) public{
        require(amount>=100*decimals,"must greater than 100U");
        require(_islock[fromad]==0,"You already bought it");
        require(smcount>smcounted,"sm is over");
        super.transcoin(eryad,fromad,150*decimals);
        // _erybalance_[fromad]=_erybalance_[fromad].add(150);
        // _lockerybalance_[fromad]=_lockerybalance_[fromad].add(100);
        // _islock[fromad]=1;
        smcounted=smcounted.add(1);
        super.transfromcoin(uad,fromad,address(this),amount);

    }
    //是否私募过
    function issm(address fromad) public view returns(uint256){
        return _islock[fromad];
    }
    //设置私募场次
    function setamount(uint256 amount) public{
        require(governance[msg.sender]==true || _governance_ == msg.sender ,"not have privilige!");
        smcount=amount;
    }

    //取得私募还有多少份
    function getsmamount() public view returns(uint256){
        return smcount-smcounted;
    }

    //设置解锁私募的条件
    function setunlocklpcount(uint256 amount) public{
        require(governance[msg.sender]==true || _governance_ == msg.sender ,"not have privilige!");
        unlocklpcount=amount;
    }

    function setamount(uint256 flag,uint256 amount,uint256 lpflag) public{
        require(governance[msg.sender]==true || _governance_ == msg.sender ,"not have privilige!");
        if(lpflag==0){
            if(flag==1){
                lperycount30=amount;
            }else if(flag==2){
                lperycount60=amount;
            }else if(flag==3){
                lperycount90=amount;
            }
        }else if(lpflag==1){
            if(flag==1){
                lpeoicount30=amount;
            }else if(flag==2){
                lpeoicount60=amount;
            }else if(flag==3){
                lpeoicount90=amount;
            }
        }
        
    }



    //返回剩余场次
    function getlperyamount(uint256 flag) public view returns(uint256){
        if(flag==1){
            return lperycount30-lperycount30ed;
        }else if(flag==2){
            return lperycount60-lperycount60ed;
        }else if(flag==3){
            return lperycount90-lperycount90ed;
        }else{
            return 0;
        }
        
    }

//返回剩余场次
    function getlpeoiamount(uint256 flag) public view returns(uint256){
        if(flag==1){
            return lpeoicount30-lpeoicount30ed;
        }else if(flag==2){
            return lpeoicount60-lpeoicount60ed;
        }else if(flag==3){
            return lpeoicount90-lpeoicount90ed;
        }else{
            return 0;
        }
        
    }


}