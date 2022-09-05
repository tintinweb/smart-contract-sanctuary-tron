//SourceUnit: ITRC20.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface of the TRC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see {TRC20Detailed}.
 */
interface ITRC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


//SourceUnit: SafeMath.sol

pragma solidity ^0.5.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
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
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
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
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


//SourceUnit: TRC20.sol

pragma solidity ^0.5.0;

import "./ITRC20.sol";
import "./SafeMath.sol";

/**
 * @dev Implementation of the {ITRC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {TRC20Mintable}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of TRC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {ITRC20-approve}.
 */
contract TRC20 is ITRC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    /**
     * @dev See {ITRC20-totalSupply}.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {ITRC20-balanceOf}.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {ITRC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See {ITRC20-allowance}.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {ITRC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev See {ITRC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {TRC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `value`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {ITRC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {ITRC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "TRC20: transfer from the zero address");
        require(recipient != address(0), "TRC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "TRC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

     /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "TRC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "TRC20: approve from the zero address");
        require(spender != address(0), "TRC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
     * @dev Destoys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}


//SourceUnit: TRC20Detailed.sol

pragma solidity ^0.5.0;

import "./ITRC20.sol";

/**
 * @dev Optional functions from the TRC20 standard.
 */
contract TRC20Detailed is ITRC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {ITRC20-balanceOf} and {ITRC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}



//SourceUnit: Tron.sol

pragma solidity ^0.5.0;

import "./TRC20.sol";
import "./TRC20Detailed.sol";

contract Tron is TRC20, TRC20Detailed {
    
    uint256 total_amount = 97000000000000;
    uint256 marketing_amount = 3000000000000;
    uint256 team_amount = 10000000000000;
    uint256 insurance_amount = 3000000000000;

    string tokeName = "USDFX";
    string tokenSymbol = "USDFX";
    
    uint256[] unlock_date_user;
    uint256[] unlock_date_team;
    uint256[] unlock_date_insurance;
    
    uint date = 1669852800;//2022-12-1

    uint launch_Date = 1671408000; // date + 86400 * 18 = 2022-12-19
    
    mapping (address => uint256) public locked_amount_user;
    mapping (address => uint256) public unlock_amount_user;
    mapping (address => uint256) public unlock_amount_team;
    mapping (address => uint256) public unlock_amount_insurance;
    
    mapping (address => uint256) public claim_time_pre;
    mapping (address => uint256) public swap_time;

    uint256[12] unlock_percent_user = [1200, 800, 800, 800, 800, 800, 800, 800, 800, 800, 800, 800];
    uint256[18] unlock_percent_team = [900, 700, 700, 700, 700, 700, 650, 650, 650, 500, 500, 450, 450, 350, 350, 350, 350, 350];
    uint256[24] unlock_percent_insurance = [600, 600, 400, 400, 400, 400, 400, 400, 400, 400, 400, 400, 400, 400, 400, 400, 400, 400, 400, 400, 400, 400, 400, 400];
    
    mapping (address => bool) public privateWallets;
    
    constructor () public TRC20Detailed(tokeName, tokenSymbol, 6) {
        _mint(msg.sender, 100000000000000);
        for (uint256 i=0; i<12; i++){
            unlock_date_user.push(launch_Date + i * 2592000);
        }
        for (uint256 i=0; i<18; i++){
            unlock_date_team.push(launch_Date + i * 2592000);
        }
        for (uint256 i=0; i<24; i++){
            unlock_date_insurance.push(launch_Date + i * 2592000);
        }
    }
    
    
    function sePrivatetWallet(address _wallet) public{
        privateWallets[_wallet]=true;
    }
    
    function contains(address _wallet) public view returns (bool){
        return privateWallets[_wallet];
    }
    
    function get_Time(address from) public view returns(uint256){
        uint256 Time = claim_time_pre[from];
        return Time;
    }
    function get_lock_amount(address from) public view returns(uint256){
        uint256 locked_user_amount = locked_amount_user[from];
        return locked_user_amount;
    }
    
    function get_unlock_amount(address from) public view returns(uint256){
         uint256 unlock_user_amount = unlock_amount_user[from];
         return unlock_user_amount;
    }
    
    function swap(address from, uint256 amount) public returns(uint256) {
        swap_time[from] = block.timestamp;
        
        if ( swap_time[from] > launch_Date){
            uint256 USDFX_amount = amount * 95 / 100;
            _transfer(msg.sender, from, USDFX_amount);
        } else {
            bool check = contains(from);
        
            if (check == true){
                uint256 USDFX_amount = amount * 120 / 50;
                locked_amount_user[from] += USDFX_amount;
                return 0;
            }else {
                uint256 USDFX_amount = amount * 120 / 75;
                locked_amount_user[from] += USDFX_amount / 1000000;
                return 0;
            }
        }
    }
    
    function claim_token(address from) public returns(uint256){
        uint256 claim_time = block.timestamp;

        uint256 num_one = 0;
        uint256 num_two = 0;
        
        
        if (claim_time_pre[from] > launch_Date){
            uint256 diff_days = (claim_time - claim_time_pre[from]) / 86400;
            if (diff_days > 30){
                 for (uint256 i=0; i< unlock_date_user.length; i++ ){
                    if (unlock_date_user[i] < claim_time &&  claim_time < unlock_date_user[i+1]){
                      num_one = i;
                    }
                    if (unlock_date_user[i] < claim_time_pre[from] ||  claim_time_pre[from] < unlock_date_user[i+1]){
                      num_two = i;
                    }
                }
                for (uint256 j = num_one; j > num_two; j--){
                    uint256 percent = 0;
                    percent += unlock_percent_user[j];
                    unlock_amount_user[from] = (percent / 100) * locked_amount_user[from] / 100;
                    locked_amount_user[from] -= unlock_amount_user[from];
                    claim_time_pre[from] = claim_time;
                    _transfer(msg.sender, from, unlock_amount_user[from]);
                }
            }
        }
        else {
            if ( claim_time > launch_Date){
                uint256 diff_days = (claim_time - launch_Date) / 86400;
                if (diff_days > 0 ){
                    for (uint256 i=0; i< unlock_date_user.length; i++ ){
                        if (unlock_date_user[i] < claim_time &&  claim_time < unlock_date_user[i+1]){
                            num_one = i;
                        }
                    }
                    for (uint256 j = 0; j< num_one + 1 ; j++){
                        uint256 percent = 0;
                        percent += unlock_percent_user[j];
                        unlock_amount_user[from] = locked_amount_user[from] * (percent / 100) / 100;
                        locked_amount_user[from] -= unlock_amount_user[from];
                        claim_time_pre[from] = claim_time;
                        _transfer(msg.sender, from, unlock_amount_user[from]);
                    }
                }
            }
            else{
             return 0;   
            }
        }
    }
    

    function team_unlock(address from) public returns(uint256){
        uint256 claim_time = block.timestamp;

        uint256 num_one = 0;
        uint256 num_two = 0;
        
        
        if (claim_time_pre[from] > launch_Date){
            uint256 diff_days = (claim_time - claim_time_pre[from]) / 86400;
            if (diff_days > 30){
                 for (uint256 i=0; i< unlock_date_team.length; i++ ){
                    if (unlock_date_team[i] < claim_time &&  claim_time < unlock_date_team[i+1]){
                      num_one = i;
                    }
                    if (unlock_date_team[i] < claim_time_pre[from] ||  claim_time_pre[from] < unlock_date_team[i+1]){
                      num_two = i;
                    }
                }
                for (uint256 j = num_one; j > num_two; j--){
                    uint256 percent = 0;
                    percent += unlock_percent_team[j];
                    unlock_amount_team[from] = (percent / 100) * team_amount / 100;
                    team_amount -= unlock_amount_team[from];
                    claim_time_pre[from] = claim_time;
                    _transfer(msg.sender, from, unlock_amount_team[from]);
                }
            }
        }
        else {
            // uint256 claim_time = block.timestamp;
            uint256 diff_days = (claim_time - launch_Date) / 86400; //86400
            if (diff_days > 0 ){
                for (uint256 i=0; i< unlock_date_team.length; i++ ){
                    if (unlock_date_team[i] < claim_time &&  claim_time < unlock_date_team[i+1]){
                        num_one = i;
                    }
                }
                for (uint256 j = 0; j< num_one + 1 ; j++){
                    uint256 percent = 0;
                    percent += unlock_percent_team[j];
                    unlock_amount_team[from] = team_amount * (percent / 100) / 100;
                    team_amount -= unlock_amount_team[from];
                    claim_time_pre[from] = claim_time;
                    _transfer(msg.sender, from, unlock_amount_team[from]);
                }
            }
            else{
                return 0;
            }
        }
    }
    
    function insurance_unlock(address from) public returns(uint256){
        uint256 claim_time = block.timestamp;
        uint256 num_one = 0;
        uint256 num_two = 0;
        if (claim_time_pre[from] > launch_Date){
            uint256 diff_days = (claim_time - claim_time_pre[from]) / 86400;
            if (diff_days > 30){
                 for (uint256 i=0; i< unlock_date_insurance.length; i++ ){
                    if (unlock_date_insurance[i] < claim_time &&  claim_time < unlock_date_insurance[i+1]){
                      num_one = i;
                    }
                    if (unlock_date_insurance[i] < claim_time_pre[from] ||  claim_time_pre[from] < unlock_date_insurance[i+1]){
                      num_two = i;
                    }
                }
                for (uint256 j = num_one; j > num_two; j--){
                    uint256 percent = 0;
                    percent += unlock_percent_insurance[j];
                    unlock_amount_insurance[from] = (percent / 100) * insurance_amount / 100;
                    insurance_amount -= unlock_amount_insurance[from];
                    claim_time_pre[from] = claim_time;
                    _transfer(msg.sender, from, unlock_amount_insurance[from]);
                }
            }
        }
        else {
            // uint256 claim_time = block.timestamp;
            uint256 diff_days = (claim_time - launch_Date) / 86400; //86400
            if (diff_days > 0 ){
                for (uint256 i=0; i< unlock_date_insurance.length; i++ ){
                    if (unlock_date_insurance[i] < claim_time &&  claim_time < unlock_date_insurance[i+1]){
                        num_one = i;
                    }
                }
                for (uint256 j = 0; j< num_one + 1 ; j++){
                    uint256 percent = 0;
                    percent += unlock_percent_insurance[j];
                    unlock_amount_insurance[from] = insurance_amount * (percent / 100) / 100;
                    insurance_amount -= unlock_amount_insurance[from];
                    claim_time_pre[from] = claim_time;
                    _transfer(msg.sender, from, unlock_amount_insurance[from]);
                }
            }
            else{
                return 0;
            }
        }
    }
}