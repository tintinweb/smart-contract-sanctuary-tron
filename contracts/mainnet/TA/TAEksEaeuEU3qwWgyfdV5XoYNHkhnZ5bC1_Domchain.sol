//SourceUnit: domchain.sol

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.6;

contract Domchain {
    address public Owner;
    
    constructor(){
        Owner = msg.sender;
    }
    modifier onlyOwner {
        require(msg.sender == Owner);
        _;
    }
    modifier isDomainExist (string memory _domain) {
        require(bytes(DomainList[_domain].domain).length > 0, "Domain not exist");
        _;
    }
    modifier initCheck (string memory _domain) {
        require(bytes(_domain).length > 0, "Domain is null");
        require(bytes(DomainList[_domain].domain).length <= 0, "Domain already exist");
        _;
    }

    struct Domain {
        uint32 owner;
        string domain;
    }

    mapping(string => Domain) public DomainList;

    event InitialDomain(string indexed _domain);
    event TransferDomain(string indexed _domain,uint32 indexed _newOwner);
    event PurchaseDomain(string indexed _domain,uint32 indexed _owner);

    function initialDomain(string memory _domain) public onlyOwner initCheck(_domain) {
        DomainList[_domain]=Domain(0,_domain);
        emit InitialDomain(_domain);
    }
    function transferDomain(string memory _domain, uint32 _newOwner) public onlyOwner isDomainExist(_domain) {
        DomainList[_domain].owner=_newOwner;
        emit TransferDomain(_domain,_newOwner);
    }
    function purchaseDomain(string memory _domain, uint32 _owner) public onlyOwner isDomainExist(_domain) {
        emit PurchaseDomain(_domain, _owner);
    }
}