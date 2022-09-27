//SourceUnit: cc_tron.sol

pragma solidity ^0.5.14;

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
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
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


contract CryptillionClub {
    
    using SafeMath for uint256;
    
    mapping (address => address) private users;
    mapping (address => mapping (uint => mapping (uint => bool))) private relations;
    mapping (address => mapping (uint => mapping (uint => uint))) private levels;
    
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    
    
    address private owner;
    address private fund;
    bool private fundEnabled;

    uint private usersCounter;
    uint[6] private normalLevelPrice;
    uint private levelTime;
    
    uint sponsorPercent;
    uint buyerPercent;
    
    uint private discountCounter;
    uint private discountTimer;
    uint private discountFactor;
    bool private discountFirst;

    uint private _totalSupply;
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    
    event BuyLevel(address indexed user, address indexed sponsor, uint matrix, uint indexed level, uint amount);
    
    event NewPartner(address indexed user, address indexed sponsor, uint indexed level, uint matrix0, uint matrix1, uint matrix2, uint matrix3, uint matrix4, uint matrix5);
    
    event GotProfit(address indexed sponsor, address indexed user, uint etherAmount, uint tokenAmount, uint rate, uint matrix, uint level);
    event LostProfit(address indexed sponsor, address indexed user, uint etherAmount, uint tokenAmount, uint rate, uint matrix, uint level);
    
    event GotReward(address indexed sponsor, address indexed user, uint etherAmount, uint tokenAmount, uint rate,uint percent);
    event LostReward(address indexed sponsor, address indexed user, uint etherAmount, uint tokenAmount, uint rate,uint percent);

    event TokenRateChanged(uint indexed tokenRate);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Sell(address indexed seller, uint256 tokenAmount, uint256 rate, uint256 etherAmount);
    event Buy(address indexed buyer, address indexed sponsor, uint256 tokenAmount, uint256 rate, uint256 etherAmount);


    constructor() public {
        owner = msg.sender;
        fund = msg.sender;
        fundEnabled = true;

        usersCounter = 0;

        normalLevelPrice = [
            100000000,
            300000000,
            1000000000,
            3000000000,
            10000000000,
            30000000000
        ];
        levelTime = 31536000;
        
        sponsorPercent = 5;
        buyerPercent = 90;
        
        _name = "Cryptillion Club Token";
        _symbol = "CRION";
        _decimals = 6;
        
        emit TokenRateChanged(100000);
    }

    modifier onlyOwner() {
        require (_msgSender() == owner, 'Only for owner');
        _;
    }
    
    modifier maxLevel(uint _level) {
        require (_level >= 1 && _level <= 20, 'Min and max levels are 1-20');
        _;
    }
    
    modifier maxMatrix(uint _matrix) {
        require (_matrix >= 0 && _matrix <= 5, 'Min and max matrices are from 0 to 5 (1 - 6)');
        _;
    }


    function () external payable {
        revert();
    }

    function changeOwnerAddress(address _newOwner) external onlyOwner {
        owner = _newOwner;
        assert(owner == _newOwner);
    }
    
    function changefundAddress(address _newFund) external onlyOwner {
        fund = _newFund;
        assert(fund == _newFund);
    }
    
    function changeFundEnabled(bool _newFundEnabled) external onlyOwner {
        fundEnabled = _newFundEnabled;
        assert(fundEnabled == _newFundEnabled);
    }
    
    function changeNormalLevelPrice(uint _matrix, uint _newPrice) external maxMatrix(_matrix) onlyOwner {
        normalLevelPrice[_matrix] = _newPrice;
        assert(normalLevelPrice[_matrix] == _newPrice);
    }
    
    function changeLevelTime(uint _newTime) external onlyOwner {
        levelTime = _newTime;
        assert(levelTime == _newTime);
    }
    
    function changeSponsorPercent(uint _newSponsorPercent) external onlyOwner {
        require(_newSponsorPercent <= 10);
        sponsorPercent = _newSponsorPercent;
        assert(sponsorPercent == _newSponsorPercent);
    }
    
    function changeBuyerPercent(uint _newBuyerPercent) external onlyOwner {
        require(_newBuyerPercent >= 80 && _newBuyerPercent <= 100);
        buyerPercent = _newBuyerPercent;
        assert(buyerPercent == _newBuyerPercent);
    }
    
    function createDiscount(uint _counter, uint _timer, uint _factor, bool _first) external onlyOwner {
        discountCounter = _counter;
        discountTimer = _timer;
        discountFactor = _factor;
        discountFirst = _first;
    }
    
    function registerUser(address _sponsor) external payable {
        
        require (msg.value == levelPrice(0, 1), 'Wrong registration payment amount.');
        require (_sponsor != address(0) && levels[_sponsor][0][0] > 0, 'Please provide registered sponsor.');
        require (_sponsor != _msgSender(), 'You can\'t be your own sponsor.');
        require (levels[_msgSender()][0][0] == 0, 'You are already registered');
        
        users[_msgSender()] = _sponsor;
        relations[_msgSender()][0][0] = true;
        levels[_msgSender()][0][0] = 1;

        uint date = block.timestamp;
        
        address temp_sponsor = _sponsor;
            
        for (uint i = 1; i < 21 && temp_sponsor != address(0); ++i) {
            
            uint[6] memory matrices;
            
            for (uint n = 0; n < 6; ++n) {
                
                if(levels[temp_sponsor][n][i] >= date) {
                    
                    relations[_msgSender()][n][i] = true;
                    matrices[n] = 1;
                    
                } else {
                    matrices[n] = 0;
                }
            }
            emit NewPartner(_msgSender(), temp_sponsor, i, matrices[0], matrices[1], matrices[2], matrices[3], matrices[4], matrices[5]);
            temp_sponsor = users[temp_sponsor];
        }
        
        buyLevel(0, 1);
        
        ++usersCounter;
    }
    
    function createSuperUser(address _superUser, address _sponsor) external onlyOwner {
        
        for (uint i = 1; i < 21; ++i) {
        
            for (uint n = 0; n < 6; ++n) {
                levels[_superUser][n][0] = 1;
                levels[_superUser][n][i] = 11044857601;
            }
            emit NewPartner(_superUser, _sponsor, i, 1, 1, 1, 1, 1, 1);
        }
        ++usersCounter;
    }
    
    function buyLevel(uint _matrix, uint _level) public payable maxMatrix(_matrix) maxLevel(_level) {
        
        require(msg.value == levelPrice(_matrix, _level), 'Wrong TRON amount.');
        require(levels[_msgSender()][0][0] == 1, 'Please register.');
        
        if (_matrix > 0) {
            require(levels[_msgSender()][_matrix.sub(1)][1] >= _nowStamp(), 'Please activate the previous matrix first level.');
        }
        
        require(levels[_msgSender()][_matrix][_level] < _nowStamp().add(_levelTime()), 'No more than +2 years.');
        
        for (uint i = 1; i < _level; ++i) {
            require(levels[_msgSender()][_matrix][i] >= _nowStamp(), 'Please, activate the previous levels first.');
        }
        
        levels[_msgSender()][_matrix][0] = 1;
        
        if(levels[_msgSender()][_matrix][_level] <= _nowStamp()) {
            levels[_msgSender()][_matrix][_level] = _nowStamp().add(_levelTime());
        } else {
            levels[_msgSender()][_matrix][_level] = levels[_msgSender()][_matrix][_level].add(_levelTime());
        }
        
        (address sponsor, address nomSponsor) = getSponsor(_msgSender(), _matrix, _level);
    
        uint etherAmount = msg.value;
        (uint tokenAmount, uint rate) = tokenAmountForEther(etherAmount);
        
        if(_level == 2 && fundEnabled) {
            etherAmount = etherAmount.div(2);
            tokenAmount = tokenAmount.div(2);
            _mint(fund, tokenAmount);
        }
            
        if (sponsor != address(0)) {
            
            if (levels[sponsor][_matrix][_level] >= _nowStamp()) {
            
                _mint(sponsor, tokenAmount);
                emit GotProfit(sponsor, _msgSender(), etherAmount, tokenAmount, rate, _matrix, _level);
                assert(balanceOf(sponsor) >= tokenAmount);
                
            } else {
                
                emit LostProfit(sponsor, _msgSender(), etherAmount, tokenAmount, rate, _matrix, _level);
                emit TokenRateChanged(_tokenRate(0));
            }
        } else if (nomSponsor != address(0)) {
            
            emit LostProfit(nomSponsor, _msgSender(), etherAmount, tokenAmount, rate, _matrix, _level);
            emit TokenRateChanged(_tokenRate(0));
            
        } else {
            emit TokenRateChanged(_tokenRate(0));
        }
        
        emit BuyLevel(_msgSender(), sponsor, _matrix, _level, msg.value);
    }
    
    function buyTokens() public payable {
        
        uint etherAmount = msg.value;
        
        require (levels[_msgSender()][0][0] == 1, 'Please register.');
        require (levels[_msgSender()][0][1] >= _nowStamp(), 'Please activate first level of the first matrix.');
        require (etherAmount <= address(this).balance.sub(etherAmount), 'No more than the smart contract balance.');
        require (etherAmount >= normalLevelPrice[0], 'Wrong minimum amount.');
        
        (address sponsor, address nomSponsor) = getSponsor(_msgSender(), 0, 1);
        
        uint buyerPartEth = etherAmount.div(100).mul(buyerPercent);
        
        (uint tokenAmount, uint rate) = tokenAmountForEther(etherAmount);
        
        uint buyerPartToken = tokenAmount.div(100).mul(buyerPercent);
        
        uint totalSponsorPercent = sponsorPercent.add(calcAddPerc(nomSponsor));
        uint sponsorPartEth = etherAmount.div(100).mul(totalSponsorPercent);
        uint sponsorPartToken = tokenAmount.div(100).mul(totalSponsorPercent);

        if (sponsor != address(0)) {
            
            if (levels[sponsor][0][1] >= _nowStamp()) {
                _mint(sponsor, sponsorPartToken);
                assert(balanceOf(sponsor) >= sponsorPartToken);
                emit GotReward(sponsor, _msgSender(), sponsorPartEth, sponsorPartToken, rate, totalSponsorPercent);
            } else {
                emit LostReward(sponsor, _msgSender(), sponsorPartEth, sponsorPartToken, rate, totalSponsorPercent);
            }
            
        } else if (nomSponsor != address(0)) {
            
            emit LostReward(nomSponsor, _msgSender(), sponsorPartEth, sponsorPartToken, rate, totalSponsorPercent);
        }
        
        _mint(_msgSender(), buyerPartToken);
        assert(balanceOf(_msgSender()) >= buyerPartToken);
        
        emit Buy(_msgSender(), sponsor, buyerPartToken, rate, buyerPartEth);
        emit TokenRateChanged(_tokenRate(0));
    }
    
    function getSponsor(address _user, uint _matrix, uint _level) public view maxLevel(_level) maxMatrix(_matrix) returns (address sponsor, address nominalSponsor) {
        
        address temp_sponsor = users[_user];
        
        for (uint i = 2; i <= _level && temp_sponsor != address(0); ++i) {
            temp_sponsor = users[temp_sponsor];
        }
        
        if (!relations[_user][_matrix][_level]) {
            return (address(0), temp_sponsor);
        } else {
            return (temp_sponsor, temp_sponsor);
        }
    }
    
    function getRelation(uint _m, uint _l) external view returns (bool) {
        return relations[_msgSender()][_m][_l];
    }
    
    function calcAddPerc(address _user) public view returns (uint) {
        
        uint result = 0;
        
        for (uint i = 1; i <= 5; ++i) {

            uint matrixOpened = levels[_user][i][1];

            if (matrixOpened >= _nowStamp()) {
                result = result.add(1);
            } else {
                break;
            }
        }
        return result;
    }
    
    function getRelations(address _user, uint _matrix) external view returns (bool[21] memory) {
        
        bool[21] memory result;
        
        for (uint i = 0; i < 21; ++i) {
            result[i] = relations[_user][_matrix][i];
        }
        return result;
    }
    
    function levelPrice(uint _matrix, uint _level) public view maxLevel(_level) maxMatrix(_matrix) returns (uint) {
        if((_usersCounter() > _discountCounter() && block.timestamp > _discountTimer()) || levels[_msgSender()][_matrix][_level] != 0) {
            return _normalLevelPrice(_matrix);
        } else if (_discountFirst() == false || _level == 1) {
            return _normalLevelPrice(_matrix).div(_discountFactor());
        } else {
            return _normalLevelPrice(_matrix);
        }
    }
    
    function userInfo(address _user, uint _matrix) public view returns (address[21] memory _sponsors, uint[21] memory _levels) {
        
        address[21] memory sponsors;
        bool[21] memory temp_relations;
        
        for (uint i = 0; i < 21; ++i) {
            temp_relations[i] = relations[_user][_matrix][i];
        }
        
        address temp_sponsor = users[_user];
        sponsors[0] = temp_sponsor;
    
        for (uint n = 1; n < 21 && temp_sponsor != address(0); ++n) {
            if(temp_relations[n]) {
                sponsors[n] = temp_sponsor;
            }
            temp_sponsor = users[temp_sponsor];
        }
        
        uint[21] memory temp_levels;
        
        for (uint i = 0; i < 21; ++i) {
            temp_levels[i] = levels[_user][_matrix][i];
        }
            
        return (sponsors, temp_levels);
    }
    
    function _msgSender() internal view returns (address payable) {
        return msg.sender;
    }
    
    function _nowStamp() internal view returns (uint) {
        return block.timestamp;
    }
    
    function _usersCounter() public view returns (uint) {
        return usersCounter;
    }
    
    function _normalLevelPrice(uint _matrix) public view maxMatrix(_matrix) returns (uint) {
        return normalLevelPrice[_matrix];
    }
    
    function _levelTime() public view returns (uint) {
        return levelTime;
    }
    
    function _discountCounter() public view returns (uint) {
        return discountCounter;
    }
    
    function _discountTimer() public view returns (uint) {
        return discountTimer;
    }
    
    function _discountFactor() public view returns (uint) {
        return discountFactor;
    }
    
    function _discountFirst() public view returns (bool) {
        return discountFirst;
    }
	
	function _userSponsor(address _user) public view returns (address) {
        return users[_user];
    }

    function transfer(address _recipient, uint256 _tokenAmount) public returns (bool) {

        if (_recipient == address(this)) {

            uint rate = _tokenRate(0);
            uint etherAmount = _tokenAmount.mul(rate).div(10**6);
            
            _burn(_msgSender(), _tokenAmount);

            sendValue(_msgSender(), etherAmount);
            
            emit Sell(_msgSender(), _tokenAmount, rate, etherAmount);

        } else {
            _transfer(_msgSender(), _recipient, _tokenAmount);
        }
        return true;
    }
    
    function _transfer(address _sender, address _recipient, uint256 _amount) internal {
        require(_sender != address(0), "ERC20: transfer from the zero address");
        require(_recipient != address(0), "ERC20: transfer to the zero address");

        _balances[_sender] = _balances[_sender].sub(_amount, "ERC20: transfer amount exceeds balance");
        _balances[_recipient] = _balances[_recipient].add(_amount);
        emit Transfer(_sender, _recipient, _amount);
    }
    
    function approve(address _spender, uint256 _amount) public returns (bool) {
        _approve(_msgSender(), _spender, _amount);
        return true;
    }
    
    function transferFrom(address _sender, address _recipient, uint256 _amount) public returns (bool) {
        _transfer(_sender, _recipient, _amount);
        _approve(_sender, _msgSender(), _allowances[_sender][_msgSender()].sub(_amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }
    
    function _mint(address _account, uint256 _amount) internal {
        require(_account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(_amount);
        _balances[_account] = _balances[_account].add(_amount);
        emit Transfer(address(0), _account, _amount);
    }
    
    function _burn(address _account, uint256 _amount) internal {
        require(_account != address(0), "ERC20: burn from the zero address");

        _balances[_account] = _balances[_account].sub(_amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(_amount);
        emit Transfer(_account, address(0), _amount);
    }
    
    function _approve(address _owner, address _spender, uint256 _amount) internal {
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(_spender != address(0), "ERC20: approve to the zero address");

        _allowances[_owner][_spender] = _amount;
        emit Approval(_owner, _spender, _amount);
    }
    
    function sendValue(address payable _recipient, uint256 _amount) internal {
        require(address(this).balance >= _amount, "Address: insufficient balance");
        (bool success, ) = _recipient.call.value(_amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    
    function balanceOf(address _account) public view returns (uint256) {
        return _balances[_account];
    }
    
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return _allowances[_owner][_spender];
    }
    
    function _tokenRate(uint _sum) private view returns (uint) {
        
        uint ttlspl = _totalSupply;
        uint oldContractBalance = address(this).balance.sub(_sum);
        
        if (oldContractBalance == 0 || ttlspl == 0) {
            return 10**5;
        }
        
        return oldContractBalance.mul(10**6).div(ttlspl);
    }
    
    function tokenAmountForEther(uint _sum) private view returns (uint, uint) {
        uint rate = _tokenRate(_sum);
        uint result = _sum.mul(10**6).div(rate);
        return (result, rate);
    }
    
    function calcTokenRate() public view returns (uint) {
        uint ttlspl = _totalSupply;
        uint actualContractBalance = address(this).balance;
        if (actualContractBalance == 0 || ttlspl == 0) {
            return 10**5;
        }
        return actualContractBalance.mul(10**6).div(ttlspl);
    }
}