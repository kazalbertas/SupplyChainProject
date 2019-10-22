pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

contract Payment
{
    address payable public from;
    address payable public to;
    uint public amount;
    bool public approved = false;
    
    constructor (address payable _to, address payable _from, uint _amount) public
    {
        to = _to;
        from = _from;
        amount = _amount;
    }
    
    function approve(uint sum) public payable {
        if (!approved) {
            if (msg.sender == from) {
                if (sum >= amount){
                    // to.send(amount);
                    approved = true;
                }
            }
        }
    }
}


contract Coffee
{
    
    
    string public batchId;
    string[] public bagIds;
    
    int public minimumPricePerBag = 1;
    int public minimumPrice;
    
    constructor (string memory _batchId, string[] memory _bagIds) public
    {
        batchId = _batchId;
        owner = msg.sender;
        bagIds = _bagIds;
        locationOwner = msg.sender;
    }
    
    
    
    // Approve section
    address private approver = 0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c;
    bool public approved = false;
    
    function approve() public returns(bool success){
        if (msg.sender == approver) {
            approved = true;
            return true;
        } 
        return false;
    }
    ////////////////////////////////////////////////////
    
    // Owner section
    
    address public owner;
    address public futureOwner;
    
    struct TransferOwnershipEntry{
        address from;
        address to;
        address payment;
    }   
    
    event TransferCompleted(
        address from,
        address to,
        string batchId
    );
    
    
    TransferOwnershipEntry[] transfers;


    function transferOwnership(address newOwner) public returns(bool success){
        // Payment
        if (msg.sender == owner){
            owner = newOwner;
            // transfers.push(TransferOwnershipEntry(msg.sender,owner)); 
            emit TransferCompleted(msg.sender,newOwner,batchId);
            return true;
        }
        return false;
    }
    
    ////////////////////////////////////////////////////////////////
    
    //Transfer location 
    
    address public locationOwner;
    address public newLocationOwner;
    bool public islocationbeingtransfered = false;
    TransferLocationEntry[] locationTransfers;
    
    struct TransferLocationEntry{
        address from;
        address to;
    }
    
    
    function transferLocation(address _newLocationOwner) public returns(bool success){
        if (msg.sender == locationOwner && !islocationbeingtransfered) {
            newLocationOwner = _newLocationOwner;
            islocationbeingtransfered = true;
            return true;
        }
        return false;
    }
    
    function approveTransferLocation(string[] memory _bagIds) public returns(bool success){
        if (msg.sender ==  newLocationOwner && islocationbeingtransfered){
            if (keccak256(abi.encode(bagIds)) == keccak256(abi.encode(_bagIds))) {
                locationTransfers.push(TransferLocationEntry(locationOwner,newLocationOwner));
                locationOwner = newLocationOwner;
                newLocationOwner = address(0);
                islocationbeingtransfered = false;
                return true;
            }
        }
        return false;
    }
    
//////////////////////////////////////////////////////////////////////    
    
    
    struct TransferBagEntry{
        address mod;
        string[] previousBagIds;
        string[] newBagIds;
    }
    
    
    

    
    
    
    
    /////////////////////////////////////////////////////
    

    
    
    
    // function changeContractID(string memory _batchId) public {
    //     batchId = _cid;
    // }
    
    
    
    function getTransfers() public returns(TransferOwnershipEntry[] memory allTransfers){
        return transfers;
    }
    
    // function getContractID() public returns (string contractId){ 
    //     return contractId;
    // }
    
}