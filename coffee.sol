pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

contract Coffee
{
    
    struct TransferEntry{
        address from;
        address to;
    }
    
    
    string public batchId;
    
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
    
    
    
    
    address public owner;
    TransferEntry[] transfers;
    
    event TransferCompleted(
        address from,
        address to,
        string batchId
    );
    
    constructor (string memory _batchId) public
    {
        batchId = _batchId;
        owner = msg.sender;
    }
    
    
    
    // function changeContractID(string memory _batchId) public {
    //     batchId = _cid;
    // }
    
    function transferOwnership(address newOwner) public returns(bool success){
        if (msg.sender == owner){
            owner = newOwner;
            transfers.push(TransferEntry(msg.sender,owner)); 
            emit TransferCompleted(msg.sender,newOwner,batchId);
            return true;
        }
        return false;
    }
    
    function getTransfers() public returns(TransferEntry[] memory allTransfers){
        return transfers;
    }
    
    // function getContractID() public returns (string contractId){ 
    //     return contractId;
    // }
    
}