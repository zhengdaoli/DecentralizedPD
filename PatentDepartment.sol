// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.2 <0.8.0;
pragma experimental ABIEncoderV2;


import "./Storage.sol";
import "./PatentAPI.sol";
import "./PCoinBank.sol";

/**
* @title Storage
* @dev Store & retrieve value in a variable
*/
//other people also can run this contract??? so there are many number or storage ????
// this add2str also has multiple versions due to there are multiple contract Storage???
// so if I start a application, other people also can start a same one without my source code, because the know my contract address
// if they don't know my code, how they can know the contract functions? 
// can this website store my source code???
// store in local, uploading before running?????
// how to create directory?????


contract PatentDepartment {
 
    uint public NAME_LEN = 50;         
    uint public METHOD_LEN = 300;      
    uint public DESCRIPTION_LEN = 200; 
    uint public IMAGELINK_LEN = 100;   
    
    uint256 public REWARD = 1;

    enum UserState{
        Black,
        White,
        Normal
    }
    
    address departmentAddress;
    Storage private db;
    PCoinBank bank;

    
    mapping (address => UserState) private blacklist;
    PatentAPI.Selling[] private sellingList;
    
    mapping (address => bytes32[]) private owner2Patents;


    constructor(address storage_addrees) public {
        db = Storage(storage_addrees);
        bank = new PCoinBank();
        departmentAddress = bank.getCreater();
    }
    
    function debugGetTotalPC() public view returns(uint256){
        return getBalance(departmentAddress);
    }

    function debugGetBankCreateAdr() public view returns(address){
        return bank.getCreater();
    }
    

    function storePatent(PatentAPI.Patent memory patent, address caller) public payable returns (bool){
        
        // save to owner2Patents
        bytes32[] storage pts = owner2Patents[caller];
        bytes32 patentID = patent.patentID;
        if (search(pts, patentID) < 0){
            pts.push(patentID);
        }
        
        // store in db:
        db.store(patent.patentID, encode(patent));
        
        // get reward:
        return bank.transferFrom(departmentAddress, caller, REWARD);
    }

    function retrievePatent(bytes32 patentID) public view returns (PatentAPI.Patent memory){
        Tools.Object memory obj = db.retrieve(patentID);
        PatentAPI.Patent memory patent = decode(obj);
        return patent;
    }


    function withdrawPatent(bytes32 patentID, address caller) public {
        db.remove(patentID, caller);
        
        // remove from owner2Patents!
        bytes32[] storage pts = owner2Patents[caller];
        int index = search(pts, patentID);
        if (index > -1){
            delete pts[uint(index)];   
        }
        owner2Patents[caller] = pts;
        
        // remove from sellingList
        (uint256 index1, bool find) = findFromSellingList(patentID);
        // TODO: add remove states function:
        if (find){
            delete sellingList[index1];
        }
        // deeper delete:
        if (sellingList.length > 1000) {
            PatentAPI.Selling[] storage sellingListNew;
            for (uint i=0; i<sellingList.length; i++){
                if (sellingList[i].id > 0){
                    sellingListNew.push(sellingList[i]);
                }
            }
            sellingList = sellingListNew;
        }
    }

    function sellPatent(bytes32 patentID, uint256 price, address caller) public payable{
        require(search(owner2Patents[caller], patentID) > -1, "Owner does not has this Patent!!!!");
        PatentAPI.Selling memory sell = PatentAPI.Selling(patentID, price, 0);
        sellingList.push(sell);
    }

    function onSelling() public view returns (PatentAPI.Selling[] memory){
        return sellingList;
    }
    
    function buyPatent(bytes32 patentID, address buyer) public returns(bool){
        (uint256 index, bool find)= findFromSellingList(patentID);
        require(find, "this patent is not on selling!");
        
        PatentAPI.Selling memory sell = sellingList[index];
        require(getBalance(buyer) >= sell.price, "not enough money!");
        
        // modify owner of Patent.
        PatentAPI.Patent memory pt = retrievePatent(patentID);
        address owner_pre = pt.owner;
        
        pt.owner = buyer;
        // update in db:
        db.store(patentID, encode(pt));
        
        
        // transfer money:
        bank.transferFrom(departmentAddress, owner_pre, sell.price);
        
        
        // clear status. owner2Patents:
        bytes32[] storage pts = owner2Patents[buyer];
        pts.push(patentID);
        owner2Patents[buyer] = pts;
        
        
        bytes32[] storage pts_pre = owner2Patents[owner_pre];
        int index_pre = search(pts_pre, patentID);
        delete pts_pre[uint256(index_pre)];
        
        // remove from selling:
        
        delete sellingList[index];
    }
    
    function getBankAddress() public view returns (address){
        return address(bank);
    }
    
    function findFromSellingList(bytes32 patentID) private returns (uint256, bool){
        uint index = 0;
        bool find = false;
        for (uint i = 0; i< sellingList.length; i++) {
            if (sellingList[i].id == patentID){
               index = i;
               find = true;
               return (index, find);
            }    
        }
        return (0, false);
    }

    function getBalance(address caller) public view returns (uint256) {
        return bank.balanceOf(caller);
    }

    function search(bytes32[] storage arrs, bytes32 target) private view returns (int){
        for (uint i = 0; i< arrs.length; i++) {
            if (arrs[i] == target){
                return int(i);
            }    
        }
        return -1;
    }
    

    function encode(PatentAPI.Patent memory patent) private pure returns (Tools.Object memory){
        bytes[] memory values = new bytes[](5);
        values[0] = abi.encodePacked(patent.patentID);
        
        values[1] = abi.encodePacked(patent.name);
        values[2] = abi.encodePacked(patent.description);
        values[3] = abi.encodePacked(patent.method);
        values[4] = abi.encodePacked(patent.imageLink);
        
        Tools.Object memory obj = Tools.createObject(patent.patentID, patent.owner, values, patent.createTime);
        return obj;
    }

        
    function decode(Tools.Object memory obj) private pure returns (PatentAPI.Patent memory patent){
        
        bytes32 patentID = abi.decode(obj.values[0], (bytes32));
        address owner = obj.owner;
        
        string memory name  =string(obj.values[1]);
        string memory description =string(obj.values[2]);
        string memory method = string(obj.values[3]);
        string memory imageLink = string(obj.values[4]);
        uint createTime = obj.createTime;
        
        
        patent = PatentAPI.Patent(patentID, owner, name, description, method, imageLink, createTime);
        // ----------end ------------
        // patent = PatentAPI.Patent(patentID,  selled, onSelling, owner, name, description, method, imageLink);
        return patent;
    }
}
