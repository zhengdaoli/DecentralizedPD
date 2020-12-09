// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.4.2 <0.8.0;
pragma experimental ABIEncoderV2;

import "./PatentDepartment.sol";


contract PatentAPI {


    struct Patent {
        bytes32 patentID;
        address owner;
        
        string name;
        string description;
        string method;
        string imageLink;
        uint createTime;
    }
    
        
    struct Selling {
        bytes32 id;
        uint256 price;
        uint256 likes;
    }
    
    PatentDepartment department;
    
    function debugGetTotalPC() public view returns(uint256){
        return department.debugGetTotalPC();
    }

    function debugGetBankCreateAdr() public view returns(address){
        return department.debugGetBankCreateAdr();
    }
    
    constructor(address department_address) public {
        department_address = department_address;
        department = PatentDepartment(department_address);
    }
    
    function createPatent(string memory name, 
                          string memory description,
                          string memory method,    
                          string memory imageLink) public returns (string memory){
        
        uint nameLen = Tools.getStringLen(name);
        uint descriptionLen = Tools.getStringLen(description); 
        uint methodLen = Tools.getStringLen(method); 
        uint imageLinkLen = Tools.getStringLen(imageLink);
    
        require((nameLen > 0) && (nameLen < department.NAME_LEN()), "The nameLen is not correct.");
        require((descriptionLen > 0) && (descriptionLen < department.METHOD_LEN()), "The descriptionLen is not correct.");
        require((methodLen > 0) && (methodLen < department.DESCRIPTION_LEN()), "The methodLen is not correct.");
        require((imageLinkLen > 0) && (imageLinkLen < department.IMAGELINK_LEN()), "The imageLinkLen is not correct.");
        
        bytes32 patentID = keccak256(abi.encodePacked(name, description));
        
        // we need store patent in Storage.
        uint createTime = block.timestamp;
        Patent memory patent = Patent(patentID, msg.sender, name, description, method, imageLink, createTime);
        submitPatent(patent);
        
        return bytes32ToString(patentID);
    }


    function submitPatent(PatentAPI.Patent memory patent) public payable returns (bool){
        require(patent.owner == msg.sender, "owner has no access to this patent!");
        return department.storePatent(patent, msg.sender);
    }
    
    function retrievePatent(bytes32 id) public view returns (PatentAPI.Patent memory) {
        return department.retrievePatent(id);
    }
    
    function sellPatent(bytes32 patentID, uint256 price) public {
        
        department.sellPatent(patentID,price,  msg.sender);
    }
    
    function onSelling() view public returns (Selling[] memory) {
        return department.onSelling();
    }
    
    function buyPatent(bytes32 patentID) public returns (bool){
        return department.buyPatent(patentID, msg.sender);
    }
    
    function withdrawPatent(bytes32 patentID) public {
        department.withdrawPatent(patentID, msg.sender);
    }

    function myBalance() public view returns (uint256){
        return department.getBalance(msg.sender);
    }
    
    function getBankAddress() public view returns(address){
        return department.getBankAddress();
    }
    
    
    
    function bytes32ToString(bytes32 _bytes32) public pure returns (string memory) {
        uint8 i = 0;
        while(i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }
}

