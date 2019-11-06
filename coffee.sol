pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

contract CoffeeProxy 
{
    // address[] producers = [address(0)];
    // address[] transporters = [address(0)];
    // address[] modifiers = [address(0)];
    
    address[] coffeeContracts;
    
    constructor () public 
    {
        
    }
    
    function generateNewContract(string memory _batchId, string[] memory _bagIds) public returns (address coffeeContract)
    {
        Coffee cf = new Coffee(msg.sender, _batchId, _bagIds);
        coffeeContracts.push(address(cf));
        return address(cf);
    }
    
    function getContracts() public returns (address[] memory contracts)
    {
        return coffeeContracts;
    }
    
}



contract Payment
{
    address payable public from;
    address payable public to;
    address public allowedToWatch;
    address public coffeeContract;
    uint private minamount;
    uint private amountPayed;
    bool public approved = false;
    
    constructor (address _coffeeContract, address payable _to, address payable _from, uint _minamount) public
    {
        coffeeContract = _coffeeContract;
        to = _to;
        from = _from;
        minamount = _minamount;
    }
    
    function grantAccess(address approver) public returns(bool success)
    {
        if (msg.sender == from || msg.sender == to)
        {
            allowedToWatch = approver;
            return true;
        }
        return false;
    }
    
    function revokeAccess() public returns(bool success)
    {
        if (msg.sender == from || msg.sender == to || msg.sender == allowedToWatch)
        {
            allowedToWatch = address(0);
            return true;
        }
        return false;
    }
    
    function getPayment() public returns(bool success, uint amount)
    {
        if (msg.sender == to || msg.sender == from || msg.sender == allowedToWatch)
        {
            return (true,amountPayed);
        }
        return (false,0);
        
    }
    
    function approve() public payable 
    {
        if (!approved) 
        {
            if (msg.sender == from) 
            {
                if (msg.value >= minamount)
                {
                    to.transfer(msg.value);
                    Coffee(coffeeContract).approveTransferOwnership();
                    amountPayed = msg.value; 
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
    
    uint public minimumPricePerBag = 1;
    uint public minimumPrice;
    
    constructor (address _o, string memory _batchId, string[] memory _bagIds) public
    {
        batchId = _batchId;
        owner = _o;
        bagIds = _bagIds;
        locationOwner = _o;
        minimumPrice = minimumPricePerBag * _bagIds.length;
    }
    
    // Approve section
    address private approver = 0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c;
    bool public approved = false;
    
    function approve() public returns(bool success)
    {
        if (msg.sender == approver) 
        {
            approved = true;
            return true;
        } 
        return false;
    }
    ////////////////////////////////////////////////////
    
    // Owner section
    
    address public owner;
    address public futureOwner;
    
    struct TransferOwnershipEntry
    {
        address from;
        address to;
        address payment;
    }   
    
    event TransferCompleted
    (
        address from,
        address to,
        string batchId
    );
    
    
    
    TransferOwnershipEntry[] transferslog;
    address payment;
    bool inTransfer = false;


    function transferOwnership(address newOwner) public returns(address paymentContract)
    {
        if (!approved)
        {
            return address(0);
        }
        // Payment
        if (msg.sender == owner && !inTransfer)
        {
            Payment p = new Payment(address(this), address(uint160(owner)) , address(uint160(newOwner)) ,minimumPrice);
            payment = address(p);
            inTransfer = true;
            futureOwner = newOwner;
            return payment;
        }
        return address(0);
    }
    
    function approveTransferOwnership() external payable
    {
        if (msg.sender == payment) 
        {
            transferslog.push(TransferOwnershipEntry(owner,futureOwner,payment));
            emit TransferCompleted(msg.sender,futureOwner,batchId);
            inTransfer = false;
            owner = futureOwner;
            futureOwner = address(0);
            payment = address(0);
        }
    }
    
    ////////////////////////////////////////////////////////////////
    
    //Transfer location 
    
    address public locationOwner;
    address public newLocationOwner;
    bool public islocationbeingtransfered = false;
    TransferLocationEntry[] locationTransfersLog;
    
    struct TransferLocationEntry
    {
        address from;
        address to;
    }
    
    function transferLocation(address _newLocationOwner) public returns(bool success)
    {
        if (!approved)
        {
            return false;
        }
        if (msg.sender == locationOwner && !islocationbeingtransfered) 
        {
            newLocationOwner = _newLocationOwner;
            islocationbeingtransfered = true;
            return true;
        }
        return false;
    }
    
    function approveTransferLocation(string[] memory _bagIds) public returns(bool success)
    {
        if (!approved)
        {
            return false;
        }
        if (msg.sender ==  newLocationOwner && islocationbeingtransfered)
        {
            if (keccak256(abi.encode(bagIds)) == keccak256(abi.encode(_bagIds))) 
            {
                locationTransfersLog.push(TransferLocationEntry(locationOwner,newLocationOwner));
                locationOwner = newLocationOwner;
                newLocationOwner = address(0);
                islocationbeingtransfered = false;
                return true;
            }
        }
        return false;
    }
    
//////////////////////////////////////////////////////////////////////    
    
    //Transfer bagIds
    
    struct TransferBagEntry
    {
        address mod;
        string[] previousBagIds;
        string[] newBagIds;
    }
    
    
    TransferBagEntry[] transferBagLog;
    address public mod;
    
    function setModifier(address _mod)public returns(bool success)
    {
        if (!approved)
        {
            return false;
        }
        if (msg.sender == owner)
        {
            mod = _mod;
            return true;
        }
        return false;
    }
    
    function revokeModifier() public returns(bool success)
    {
        if (msg.sender == owner || msg.sender == mod)
        {
            mod = address(0);
            return true;
        }
        return false;
    }
    
    function transferBags(string[] memory newBagIds) public returns(bool success) 
    {
        if (!approved)
        {
            return false;
        }
        if (locationOwner == msg.sender && mod == msg.sender)
        {
            transferBagLog.push(TransferBagEntry(mod,bagIds,newBagIds));
            bagIds = newBagIds;
            mod = address(0);
            return true;
        }
        return false;
    } 
    
    
    /////////////////////////////////////////////////////
    
    
    function getOwnershipTransfersLog() public returns(TransferOwnershipEntry[] memory allTransfers){
        return transferslog;
    }
    
    function getLocationTransfersLog() public returns(TransferLocationEntry[] memory allTransfers){
        return locationTransfersLog;
    }
    
    function getTransferBagLog() public returns(TransferBagEntry[] memory allTransfers){
        return transferBagLog;
    }
    
    
}