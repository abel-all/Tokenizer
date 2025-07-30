// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.0/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.0/contracts/access/Ownable.sol";

contract MultiSignContract is ERC20, Ownable {
    uint256 public requiredSignatures;
    mapping(address => bool) public isOwner;
    address[] public owners;
    uint256 public ownerCount;
    
    struct Transaction {
        address to;
        uint256 amount;
        bytes data;
        bool executed;
        uint256 confirmations;
        mapping(address => bool) isConfirmed;
        string operation;
    }
    
    mapping(uint256 => Transaction) public transactions;
    uint256 public transactionCount;
    
    event RequiredSignaturesChanged(uint256 requiredSignatures);
    event TransactionSubmitted(uint256 indexed transactionId, address indexed submitter);
    event TransactionConfirmed(uint256 indexed transactionId, address indexed owner);
    event TransactionExecuted(uint256 indexed transactionId);
    event TransactionRevoked(uint256 indexed transactionId, address indexed owner);
    
    modifier onlyOwners() {
        require(isOwner[msg.sender], "Not an owner");
        _;
    }
    
    modifier transactionExists(uint256 _transactionId) {
        require(_transactionId < transactionCount, "Transaction does not exist");
        _;
    }
    
    modifier notExecuted(uint256 _transactionId) {
        require(!transactions[_transactionId].executed, "Transaction already executed");
        _;
    }
    
    modifier notConfirmed(uint256 _transactionId) {
        require(!transactions[_transactionId].isConfirmed[msg.sender], "Transaction already confirmed");
        _;
    }
    
    constructor(
        uint256 initialSupply,
        address[] memory _owners,
        uint256 _requiredSignatures
    ) ERC20("Abel42", "ABL42") {
        require(_owners.length > 0, "Owners required");
        require(_requiredSignatures > 0 && _requiredSignatures <= _owners.length, "Invalid required signatures");
        
        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "Invalid owner address");
            require(!isOwner[owner], "Duplicate owner");
            
            isOwner[owner] = true;
            owners.push(owner);
        }
        
        ownerCount = _owners.length;
        requiredSignatures = _requiredSignatures;
        
        _mint(address(this), initialSupply * (10**18));
    }
    
    function submitTransaction(
        address _to,
        uint256 _amount,
        bytes memory _data,
        string memory _operation
    ) public onlyOwners returns (uint256) {
        uint256 transactionId = transactionCount;
        
        Transaction storage txn = transactions[transactionId];
        txn.to = _to;
        txn.amount = _amount;
        txn.data = _data;
        txn.executed = false;
        txn.confirmations = 0;
        txn.operation = _operation;
        
        transactionCount++;
        
        emit TransactionSubmitted(transactionId, msg.sender);
        return transactionId;
    }
    
    function confirmTransaction(uint256 _transactionId)
        public
        onlyOwners
        transactionExists(_transactionId)
        notExecuted(_transactionId)
        notConfirmed(_transactionId)
    {
        Transaction storage txn = transactions[_transactionId];
        txn.isConfirmed[msg.sender] = true;
        txn.confirmations++;
        
        emit TransactionConfirmed(_transactionId, msg.sender);
        
        if (txn.confirmations >= requiredSignatures) {
            executeTransaction(_transactionId);
        }
    }
    
    function executeTransaction(uint256 _transactionId)
        public
        onlyOwners
        transactionExists(_transactionId)
        notExecuted(_transactionId)
    {
        Transaction storage txn = transactions[_transactionId];
        require(txn.confirmations >= requiredSignatures, "Not enough confirmations");
        
        txn.executed = true;
        
        if (keccak256(abi.encodePacked(txn.operation)) == keccak256(abi.encodePacked("transfer"))) {
            _transfer(address(this), txn.to, txn.amount);
        } else if (keccak256(abi.encodePacked(txn.operation)) == keccak256(abi.encodePacked("burn"))) {
            _burn(txn.to, txn.amount);
        
        emit TransactionExecuted(_transactionId);
    }
    
    function revokeConfirmation(uint256 _transactionId)
        public
        onlyOwners
        transactionExists(_transactionId)
        notExecuted(_transactionId)
    {
        Transaction storage txn = transactions[_transactionId];
        require(txn.isConfirmed[msg.sender], "Transaction not confirmed by sender");
        
        txn.isConfirmed[msg.sender] = false;
        txn.confirmations--;
        
        emit TransactionRevoked(_transactionId, msg.sender);
    }
    
    function multisigTransfer(address _to, uint256 _amount) public onlyOwners returns (uint256) {
        return submitTransaction(_to, _amount, "", "transfer");
    }

    function multisigBurn(address _from, uint256 _amount) public onlyOwners returns (uint256) {
        return submitTransaction(_from, _amount, "", "burn");
    }
    
    function getOwners() public view returns (address[] memory) {
        return owners;
    }
    
    function getTransactionCount() public view returns (uint256) {
        return transactionCount;
    }
    
    function getTransaction(uint256 _transactionId)
        public
        view
        returns (
            address to,
            uint256 amount,
            bytes memory data,
            bool executed,
            uint256 confirmations,
            string memory operation
        )
    {
        Transaction storage txn = transactions[_transactionId];
        return (txn.to, txn.amount, txn.data, txn.executed, txn.confirmations, txn.operation);
    }
    
    function isTransactionConfirmed(uint256 _transactionId, address _owner)
        public
        view
        returns (bool)
    {
        return transactions[_transactionId].isConfirmed[_owner];
    }
    
}