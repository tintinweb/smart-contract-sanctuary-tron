//SourceUnit: TronVegas.sol

// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.7.0;


contract TronVegas{
    
    address public owner;
    address payable a;
   
    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() public {
        owner = msg.sender;
        a = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param _newOwner The address to transfer ownership to.
     */
    function transferOwnership(address _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param _newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address _newOwner) internal {
        require(_newOwner != address(0));
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }

    struct User{
        bool referred;
        address referred_by;
        uint256 total_invested_amount;
        uint256 referal_profit;
        uint256 total_referral_profit;
    }
    
    struct Referal_levels{
        uint256 level_1;
        uint256 level_2;
        uint256 level_3;
        uint256 level_4;
        uint256 level_5;
    }

    struct Panel_1{
        uint256 invested_amount;
        uint256 profit;
        uint256 profit_withdrawn;
        uint256 start_time;
        uint256 exp_time;
        bool time_started;
        uint256 remaining_inv_prof;
    }

    struct Panel_2{
        uint256 invested_amount;
        uint256 profit;
        uint256 profit_withdrawn;
        uint256 start_time;
        uint256 exp_time;
        bool time_started;
        uint256 remaining_inv_prof;
    }
    
    struct Panel_3{
        uint256 invested_amount;
        uint256 profit;
        uint256 profit_withdrawn;
        uint256 start_time;
        uint256 exp_time;
        bool time_started;
        uint256 remaining_inv_prof;
    }




    mapping(address => Panel_1) public panel_1;
    mapping(address => Panel_2) public panel_2;
    mapping(address => Panel_3) public panel_3;
    

    mapping(address => User) public user_info;
    mapping(address => Referal_levels) public refer_info;
    uint public totalcontractamount;



    // -------------------- PANEL 1 -------------------------------  
    // 1% : 365 days

function invest_panel1() public payable {
        // 50,000,000 = 50 trx
        require((msg.value>=100000000 && msg.value<=1000000000000) , 'Please Enter Amount no less than 100');
        totalcontractamount += msg.value;
        
        
        if( panel_1[msg.sender].time_started == false){
            panel_1[msg.sender].start_time = now;
            panel_1[msg.sender].time_started = true;
            panel_1[msg.sender].exp_time = now + 365 days; //20*24*60*60  = 45 days
        }
        
            panel_1[msg.sender].invested_amount += msg.value;
            user_info[msg.sender].total_invested_amount += msg.value; 
            
            referral_system(msg.value);
            
            //neg
            if(panel1_days() <= 365){ //365
                panel_1[msg.sender].profit += ((msg.value*1*(365 - panel1_days()))/(100)); // 365 - panel_days()
            }

    }

    function is_plan_completed_p1() public view returns(bool){
        if(panel_1[msg.sender].exp_time != 0){
            if(now >= panel_1[msg.sender].exp_time){
                return true;
            }
        if(now < panel_1[msg.sender].exp_time){
            return false;
            }
        }else{
            return false;
        }
    }
    function plan_completed_p1() public  returns(bool){
        if( panel_1[msg.sender].exp_time != 0){
        if(now >= panel_1[msg.sender].exp_time){
            reset_panel_1();
            return true;
        }
        if(now < panel_1[msg.sender].exp_time){
            return false;
            }
        }

    }

    function current_profit_p1() public view returns(uint256){
        uint256 local_profit ;
        if(now <= panel_1[msg.sender].exp_time){
            if((((panel_1[msg.sender].profit + panel_1[msg.sender].profit_withdrawn)*(now-panel_1[msg.sender].start_time))/(365*(1 days))) > panel_1[msg.sender].profit_withdrawn){  // 45 * 1 days
                local_profit = (((panel_1[msg.sender].profit + panel_1[msg.sender].profit_withdrawn)*(now-panel_1[msg.sender].start_time))/(365*(1 days))) - panel_1[msg.sender].profit_withdrawn; // 20*24*60*60
                return local_profit;
            }else{
                return 0;
            }
        }
        if(now > panel_1[msg.sender].exp_time){
            return panel_1[msg.sender].profit;
        }
    }

    function panel1_days() public view returns(uint256){
        if(panel_1[msg.sender].time_started == true){
            return ((now - panel_1[msg.sender].start_time)/(1 days)); // change to 24*60*60   1 days
        }
        else {
            return 0;
        }
    }
    
    function withdraw_profit_panel1(uint256 amount) public payable {
        uint256 current_profit = current_profit_p1();
        require(amount <= current_profit, ' Amount sould be less than profit');
        panel_1[msg.sender].profit_withdrawn = panel_1[msg.sender].profit_withdrawn + amount;
        //neg
        panel_1[msg.sender].profit = panel_1[msg.sender].profit - amount;
        msg.sender.transfer(amount - ((5*amount)/100));
        a.transfer((5*amount)/100);
    }

    

    function reset_panel_1() private{
        panel_1[msg.sender].remaining_inv_prof = panel_1[msg.sender].profit + panel_1[msg.sender].invested_amount;

        panel_1[msg.sender].invested_amount = 0;
        panel_1[msg.sender].profit = 0;
        panel_1[msg.sender].profit_withdrawn = 0;
        panel_1[msg.sender].start_time = 0;
        panel_1[msg.sender].exp_time = 0;
        panel_1[msg.sender].time_started = false;
    }  

    function withdraw_all_p1() public payable{
    
        msg.sender.transfer(panel_1[msg.sender].remaining_inv_prof);
        panel_1[msg.sender].remaining_inv_prof = 0;

    }


    
    // --------------------------------- PANEL 2 ----------------------
    // 2% : 100 days
    
    function invest_panel2() public payable {
        // 50,000,000 = 50 trx
        require((msg.value>=100000000 && msg.value<=1000000000000), 'Please Enter Amount no less than 100');
        totalcontractamount += msg.value;
        
        if( panel_2[msg.sender].time_started == false){
            panel_2[msg.sender].start_time = now;
            panel_2[msg.sender].time_started = true;
            panel_2[msg.sender].exp_time = now + 100 days; //20*24*60*60  = 45 days
        }
        
            panel_2[msg.sender].invested_amount += msg.value;
            user_info[msg.sender].total_invested_amount += msg.value; 
            
            referral_system(msg.value);
            
            //neg
            if(panel2_days() <= 100){ //20
                panel_2[msg.sender].profit += ((msg.value*2*(100 - panel2_days()))/(100)); // 20 - panel_days()
            }

    }

    function is_plan_completed_p2() public view returns(bool){
        if(panel_2[msg.sender].exp_time != 0){
            if(now >= panel_2[msg.sender].exp_time){
                return true;
            }
        if(now < panel_2[msg.sender].exp_time){
            return false;
            }
        }else{
            return false;
        }
    }
    function plan_completed_p2() public  returns(bool){
        if( panel_2[msg.sender].exp_time != 0){
        if(now >= panel_2[msg.sender].exp_time){
            reset_panel_2();
            return true;
        }
        if(now < panel_2[msg.sender].exp_time){
            return false;
            }
        }

    }

    function current_profit_p2() public view returns(uint256){
        uint256 local_profit ;
        if(now <= panel_2[msg.sender].exp_time){
            if((((panel_2[msg.sender].profit + panel_2[msg.sender].profit_withdrawn)*(now-panel_2[msg.sender].start_time))/(100*(1 days))) > panel_2[msg.sender].profit_withdrawn){  // 45 * 1 days
                local_profit = (((panel_2[msg.sender].profit + panel_2[msg.sender].profit_withdrawn)*(now-panel_2[msg.sender].start_time))/(100*(1 days))) - panel_2[msg.sender].profit_withdrawn; // 20*24*60*60
                return local_profit;
            }else{
                return 0;
            }
        }
        if(now > panel_2[msg.sender].exp_time){
            return panel_2[msg.sender].profit;
        }
    }

    function panel2_days() public view returns(uint256){
        if(panel_2[msg.sender].time_started == true){
            return ((now - panel_2[msg.sender].start_time)/(1 days)); // change to 24*60*60   1 days
        }
        else {
            return 0;
        }
    }
    
    function withdraw_profit_panel2(uint256 amount) public payable {
        uint256 current_profit = current_profit_p2();
        require(amount <= current_profit, ' Amount sould be less than profit');
        panel_2[msg.sender].profit_withdrawn = panel_2[msg.sender].profit_withdrawn + amount;
        //neg
        panel_2[msg.sender].profit = panel_2[msg.sender].profit - amount;
        msg.sender.transfer(amount - ((5*amount)/100));
        a.transfer((5*amount)/100);
    }

    

    function reset_panel_2() private{
        panel_2[msg.sender].remaining_inv_prof = panel_2[msg.sender].profit + panel_2[msg.sender].invested_amount;

        panel_2[msg.sender].invested_amount = 0;
        panel_2[msg.sender].profit = 0;
        panel_2[msg.sender].profit_withdrawn = 0;
        panel_2[msg.sender].start_time = 0;
        panel_2[msg.sender].exp_time = 0;
        panel_2[msg.sender].time_started = false;
    }  

    function withdraw_all_p2() public payable{
    
        msg.sender.transfer(panel_2[msg.sender].remaining_inv_prof);
        panel_2[msg.sender].remaining_inv_prof = 0;

    }


    // --------------------------------- PANEL 3 ---------------------------

    // 2.5% : 80 days

    function invest_panel3() public payable {
        
        require((msg.value>=100000000 && msg.value<=1000000000000), 'Please Enter Amount no less than 100');
        
        totalcontractamount += msg.value;
        
        if(panel_3[msg.sender].time_started == false){
            panel_3[msg.sender].start_time = now;
            panel_3[msg.sender].time_started = true;
            panel_3[msg.sender].exp_time = now + 80 days; //10*24*60*60  = 10 days
        }
        
            panel_3[msg.sender].invested_amount += msg.value;
            user_info[msg.sender].total_invested_amount += msg.value; 
            
            referral_system(msg.value);
            
            //neg
            if(panel3_days() <= 80){ //10
                panel_3[msg.sender].profit += ( ( (msg.value*5*(80 - panel3_days()))/2)/(100) ); // 25 - panel_days()
            }

    }

    function is_plan_completed_p3() public view returns(bool){
        if(panel_3[msg.sender].exp_time != 0){
            if(now >= panel_3[msg.sender].exp_time){
                return true;
            }
        if(now < panel_3[msg.sender].exp_time){
            return false;
            }
        }else{
            return false;
        }
    }
    function plan_completed_p3() public  returns(bool){
        if( panel_3[msg.sender].exp_time != 0){
        if(now >= panel_3[msg.sender].exp_time){
            reset_panel_3();
            return true;
        }
        if(now < panel_3[msg.sender].exp_time){
            return false;
            }
        }

    }

    function current_profit_p3() public view returns(uint256){
        uint256 local_profit ;
        if(now <= panel_3[msg.sender].exp_time){
            if((((panel_3[msg.sender].profit + panel_3[msg.sender].profit_withdrawn)*(now-panel_3[msg.sender].start_time))/(80*(1 days))) > panel_3[msg.sender].profit_withdrawn){  // 25 * 1 days
                local_profit = (((panel_3[msg.sender].profit + panel_3[msg.sender].profit_withdrawn)*(now-panel_3[msg.sender].start_time))/(80*(1 days))) - panel_3[msg.sender].profit_withdrawn; // 25*24*60*60
                return local_profit;
            }else{
                return 0;
            }

        }
        if(now > panel_3[msg.sender].exp_time){
            return panel_3[msg.sender].profit;
        }
    }
    
    function panel3_days() public view returns(uint256){
        if(panel_3[msg.sender].time_started == true){
            return ((now - panel_3[msg.sender].start_time)/(1 days)); // change to 24*60*60   1 days
        }
        else {
            return 0;
        }
    }
    
    function withdraw_profit_panel3(uint256 amount) public payable {
        uint256 current_profit = current_profit_p3();
        require(amount <= current_profit, ' Amount sould be less than profit');
        panel_3[msg.sender].profit_withdrawn = panel_3[msg.sender].profit_withdrawn + amount;

        //neg
        panel_3[msg.sender].profit = panel_3[msg.sender].profit - amount;
        msg.sender.transfer(amount - ((5*amount)/100));
        a.transfer((5*amount)/100);
    }
    
    
    function reset_panel_3() private{
        panel_3[msg.sender].remaining_inv_prof = panel_3[msg.sender].profit + panel_3[msg.sender].invested_amount;

        panel_3[msg.sender].invested_amount = 0;
        panel_3[msg.sender].profit = 0;
        panel_3[msg.sender].profit_withdrawn = 0;
        panel_3[msg.sender].start_time = 0;
        panel_3[msg.sender].exp_time = 0;
        panel_3[msg.sender].time_started = false;
    }

    function withdraw_all_p3() public payable{
    
        msg.sender.transfer(panel_3[msg.sender].remaining_inv_prof);
        panel_3[msg.sender].remaining_inv_prof = 0;

    }

    // ---------------------------------------------------------------------------------------------------------------





 //------------------- Referal System ------------------------

    function refer(address ref_add) public {
        require(user_info[msg.sender].referred == false, ' Already referred ');
        require(ref_add != msg.sender, ' You cannot refer yourself ');
        
        user_info[msg.sender].referred_by = ref_add;
        user_info[msg.sender].referred = true;        
        
        address level1 = user_info[msg.sender].referred_by;
        address level2 = user_info[level1].referred_by;
        address level3 = user_info[level2].referred_by;
        address level4 = user_info[level3].referred_by;
        address level5 = user_info[level4].referred_by;
        
        if( (level1 != msg.sender) && (level1 != address(0)) ){
            refer_info[level1].level_1 += 1;
        }
        if( (level2 != msg.sender) && (level2 != address(0)) ){
            refer_info[level2].level_2 += 1;
        }
        if( (level3 != msg.sender) && (level3 != address(0)) ){
            refer_info[level3].level_3 += 1;
        }
        if( (level4 != msg.sender) && (level4 != address(0)) ){
            refer_info[level4].level_4 += 1;
        }
        if( (level5 != msg.sender) && (level5 != address(0)) ){
            refer_info[level5].level_5 += 1;
        }
        
    }

    function referral_system(uint256 amount) private {
        address level1 = user_info[msg.sender].referred_by;
        address level2 = user_info[level1].referred_by;
        address level3 = user_info[level2].referred_by;
        address level4 = user_info[level3].referred_by;
        address level5 = user_info[level4].referred_by;

        if( (level1 != msg.sender) && (level1 != address(0)) ){
            user_info[level1].referal_profit += (amount*10)/(100);
        }
        if( (level2 != msg.sender) && (level2 != address(0)) ){
            user_info[level2].referal_profit += (amount*5)/(100);
        }
        if( (level3 != msg.sender) && (level3 != address(0)) ){
            user_info[level3].referal_profit += (amount*3)/(100);
        }
        if( (level4 != msg.sender) && (level4 != address(0)) ){
            user_info[level4].referal_profit += (amount*1)/(100);
        }
        if( (level5 != msg.sender) && (level5 != address(0)) ){
            user_info[level5].referal_profit += ((amount*1)/2)/(100);
        }
    }

    function referal_withdraw() public payable{
        uint rar = user_info[msg.sender].referal_profit;
        user_info[msg.sender].total_referral_profit = user_info[msg.sender].total_referral_profit+ rar;
        user_info[msg.sender].referal_profit = 0;        
        msg.sender.transfer(rar);
    }  

    function SendTRXFromContract(address payable _address, uint256 _amount) public payable onlyOwner returns (bool){
        require(_address != address(0), "error for transfer from the zero address");
        _address.transfer(_amount);
        return true;
    }
   
    function SendTRXToContract() public payable returns (bool){
        return true;
    }

}