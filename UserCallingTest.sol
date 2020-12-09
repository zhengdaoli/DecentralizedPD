// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.6.0 <0.8.0;

import "./PatentAPI.sol";
pragma experimental ABIEncoderV2;


contract UserCallingTest {

    PatentAPI api;
    address department;
    address bank;
    
    constructor(address department_address) public {
        api = new PatentAPI(department_address);
        bank = api.getBankAddress();
    }
    
    function testCreateAndSubmitPatent(string memory name) public returns (PatentAPI.Patent memory, bool) {
        PatentAPI.Patent memory patent = api.createPatent(name, "this is a decentralized patent Department On ETH!!!!!",
                         "based on solidity, MVC design, api and storage departed.",
                         "https://zhengdaoli.com");
                         
        
        return (patent, api.submitPatent(patent));
    }

    

    function testRetrieve(bytes32 id) public view returns (PatentAPI.Patent memory patent){
        patent = api.retrievePatent(id);
        return patent;
    }
    
    function testWithdrawPatent(bytes32 id) public{
        api.withdrawPatent(id);
    }
    
    function testSelling(bytes32 id, uint256 price) public{
        api.sellPatent(id, price);
    }
    
    function testOnSelling() view public returns (PatentAPI.Selling[] memory){
        PatentAPI.Selling[] memory sellingPt = api.onSelling();
        return sellingPt;
    }
    
    function testGetBalance() view public returns (uint256) {
        return api.myBalance();
    }
    
    function testBuy(bytes32 patentID) public returns(bool){
        api.buyPatent(patentID);
    }
}

