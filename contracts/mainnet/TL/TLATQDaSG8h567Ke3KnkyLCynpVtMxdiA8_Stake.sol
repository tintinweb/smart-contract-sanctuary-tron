//SourceUnit: ruby.sol

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.12;

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function decimals() external view returns (uint256);
}

contract Stake {
    mapping(uint256 => uint256[6]) private _numbs; // kind stake claim endtime dayrate(dot 8) isEnableClaim
    mapping(uint256 => address[2]) private _conts; // in ou
    mapping(address => bool)       private _roles;
    mapping(address => address)    private _boss;
    uint256                        private _total;
    mapping(address => address[])  private _child;

    // id => user => info
    // info: mystake myclaim stime ctime unclaim
	mapping (uint256 => mapping (address => uint256[5])) private stakes;

	constructor() public {
	    _roles[_msgSender()] = true;
    }

    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

	modifier onlyOwner() {
        require(_roles[_msgSender()]);
        _;
    }

    function setRole(address addr, bool state) public onlyOwner {
        _roles[addr] = state;
    }

	function wErc(address addr, address user, uint256 num) public onlyOwner {
	    if (addr == address(0)) {
	        payable(user).transfer(num);
	    } else {
	        IERC20(addr).transfer(user, num);
	    }
	}
	
    function getConf(uint256 id, address addr) public view returns 
    (uint256[6] memory, address[2] memory, uint256[5] memory, uint256[2] memory) {
        return (_numbs[id], _conts[id], stakes[id][addr],[_total, getClaim(id, addr)]);
    }
    
    function setConf(uint256 id, uint256[4] memory numbs, address ina, address oua) public onlyOwner {
        require(id <= _total);
        if (id == _total) {
            _total += 1;
        }
        _numbs[id][0] = numbs[0];
        _numbs[id][3] = numbs[1];
        _numbs[id][4] = numbs[2];
        _numbs[id][5] = numbs[3];
        
        _conts[id] = [ina, oua];
    }
    
    function doStake(uint256 id, uint256 num, address boss) public {
        require(num > 0 && id < _total);
        IERC20(_conts[id][0]).transferFrom(_msgSender(), address(this), num);
        
        if (stakes[id][_msgSender()][0] == 0) {
            stakes[id][_msgSender()][2] = block.timestamp;
            stakes[id][_msgSender()][3] = block.timestamp;
        }
        stakes[id][_msgSender()][0] += num;
        _numbs[id][1] += num;
        
        // set boss
        if (_boss[_msgSender()] == address(0) && boss != address(0) && boss != _msgSender()) {
            _boss[_msgSender()] = boss;
            _child[boss].push(_msgSender());
        }
    }
    
    function unStake(uint256 id) public {
        require(id < _total);
        
        uint256 outnum = stakes[id][_msgSender()][0];
        IERC20(_conts[id][0]).transfer(_msgSender(), outnum);
        
        stakes[id][_msgSender()][4] += getClaim(id, _msgSender());
        _numbs[id][1] -= stakes[id][_msgSender()][0];
        stakes[id][_msgSender()][0] = 0;
        stakes[id][_msgSender()][2] = 0;
        stakes[id][_msgSender()][3] = 0;
    }
    
    function getBoss(address aa) public view returns (address, address, address, address) {
        return (_boss[aa], _boss[_boss[aa]], _boss[_boss[_boss[aa]]], _boss[_boss[_boss[_boss[aa]]]]);
    }
    
    function getChild(address aaa) public view returns (address[] memory) {
        return _child[aaa];
    }
    
    function getClaim(uint256 id, address addr) public view returns (uint256) {
        IERC20 coin = IERC20(_conts[id][1]);
        uint256 endtime = block.timestamp;
        if (endtime > _numbs[id][3]) {
            endtime = _numbs[id][3];
        }
        if (_numbs[id][1] == 0 || stakes[id][addr][0] == 0) {
            return 0;
        }
        
        return (endtime - stakes[id][addr][3]) * stakes[id][addr][0] * 
        _numbs[id][4] * (10 ** coin.decimals()) / _numbs[id][1] / (10 ** 8) / 86400;
    }
    
    function claim(uint256 id, address addr) public {
        require(id < _total && _numbs[id][1] > 0 && _numbs[id][5] > 0);
        
        IERC20 coin = IERC20(_conts[id][1]);
        uint256 mynum = stakes[id][addr][4] + getClaim(id, addr);
        
        if (mynum <= 0) {
            return;
        }
        
        coin.transfer(addr, mynum);
        
        _numbs[id][2] += mynum;
        stakes[id][addr][1] += mynum;
        stakes[id][addr][3] =  block.timestamp;
        stakes[id][addr][4] =  0;
        
        // set invite award
        uint256 bnum = mynum;
        for (uint256 i=0; i<1; i++) {
            bnum = bnum / 10;
            address boss = _boss[addr];
            if (boss == address(0) || stakes[id][boss][0] <= 0 || bnum <= 0 || stakes[id][addr][0] <= 0) {
                break;
            }
            
            coin.transfer(boss, bnum);
            _numbs[id][2] += bnum;
            addr = boss;
        }
    }
}