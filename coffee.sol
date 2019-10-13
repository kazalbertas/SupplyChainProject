pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

contract Coffee
{
    
    struct TransferEntry{
        address from;
        address to;
    }
    
    string public contractId;

    address public owner;
    TransferEntry[] transfers;
    
    event TransferCompleted(
        address from,
        address to,
        string contractId
    );
    
    constructor (string memory _cid) public
    {
        contractId = _cid;
        owner = msg.sender;
    }
    
    function changeContractID(string memory _cid) public {
        contractId = _cid;
    }
    
    function transferOwnership(address newOwner) public returns(bool success){
        if (msg.sender == owner){
            owner = newOwner;
            transfers.push(TransferEntry(msg.sender,owner)); 
            emit TransferCompleted(msg.sender,newOwner,contractId);
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