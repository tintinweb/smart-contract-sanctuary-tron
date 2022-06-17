//SourceUnit: guessing.sol

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;

contract Guessing  {

	
	address public admin;
	
	struct aList{
		address add1;
		address add2;
		address add3;
		address add4;
	}

	struct aList1{
		address adc1;
		address adc2;
		address adc3;
		address adc4;
		address adc5;
		address adc6;
		address adc7;
		address adc8;
		address adc9;
		address adc10;
	}

	mapping(int=>aList) public list ;
	mapping(int=>aList1) public list1 ;


	modifier onlyAdmin {
		require(msg.sender == admin,"You Are not admin");
		_;
	}
	constructor(){
		admin=msg.sender;
	}


	function setAdmin(
		address _admin
	) external onlyAdmin {
		admin = address(_admin);
	}


	//两面设置
	function setAParam(
		address _a1,
		address _a2,
		address _a3,
		address _a4
	) external onlyAdmin {

		list[1]=aList(_a1,_a2,_a3,_a4);
	}

	//组合设置
	function setBParam(
		address _a1,
		address _a2,
		address _a3,
		address _a4
	) external onlyAdmin {

		list[2]=aList(_a1,_a2,_a3,_a4);
	}

	//龙虎合设置
	function setCParam(
		address _a1,
		address _a2,
		address _a3
	) external onlyAdmin {
		list[3]=aList(_a1,_a2,_a3,address(0));
	}

	//百家乐设置
	function setDParam(
		address _a1,
		address _a2,
		address _a3
	) external onlyAdmin {
	list[4]=aList(_a1,_a2,_a3,address(0));
	}

	//独胆设置
	function setEParam(
		address _a1,
		address _a2,
		address _a3,
		address _a4,
		address _a5,
		address _a6,
		address _a7,
		address _a8,
		address _a9,
		address _a10
	) external onlyAdmin {
		list1[10]=aList1(_a1,_a2,_a3,_a4,_a5,_a6,_a7,_a8,_a9,_a10);
	}

  

	
	

}