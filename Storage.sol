// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.4.16 <0.8.0;
pragma experimental ABIEncoderV2;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 */
 //other people also can run this contract??? so there are many number or storage ????
 // this add2str also has multiple versions due to there are multiple contract Storage???
 
// I want this Storage to be a general Storage, it stores any types of object. why? It can be applied on other applications or if I change my application or add some
// other Objects, I don't want add more structs in this Storage. Impossibile? 

library Tools {
    
    struct Object {
        bytes32 id;
        address owner;
        bytes[] values;
        uint createTime;
    }
    
    
    function getStringLen(string memory s) public pure returns (uint) {
        return bytes(s).length;
    }
    
    function createObject(bytes32 id, address owner, bytes[] memory values, uint createTime) public pure returns (Object memory) {
        Object memory obj = Object(id, owner, values, createTime);
        return obj;
    }
    
}

contract Storage {
    
    mapping(bytes32 => Tools.Object) database;
    mapping(bytes32 => bool) exists;

    function store(bytes32 id, Tools.Object memory obj) public {
        database[id] = obj;
        exists[id] = true;
    }
    
    function retrieve(bytes32 id) public view returns (Tools.Object memory) {
        require(exists[id], "id not exists!!");
        Tools.Object memory obj = database[id];
        return obj;
    }
    
    
    function remove(bytes32 id, address caller) public {
        require(exists[id], "id not exists!!");
        address owner = database[id].owner;
        require(owner == caller, "Caller has no access!!!");
        delete database[id];
        exists[id] = false;
        
    }
    
    
}