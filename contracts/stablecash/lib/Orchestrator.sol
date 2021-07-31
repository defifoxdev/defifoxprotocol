// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./Operator.sol";

contract Orchestrator is Operator {
    struct Transaction {
        bool enabled;
        address destination;
        bytes4 data;
    }
    event TransactionFailed(address indexed destination, uint index, bytes data);
    
    Transaction[] public transactions;
    
     /**
     * @notice Adds a transaction that gets called for a downstream receiver of rebases
     * @param destination Address of contract destination
     * @param data Transaction data payload
     */
    function addTransaction(address destination, string memory data)
        external
        onlyOperator
    {
        Transaction memory tran = Transaction({
            enabled: true,
            destination: destination,
            data: bytes4(keccak256(bytes(data)))
        });
        transactions.push(tran);
    }

    /**
     * @param index Index of transaction to remove.
     *              Transaction ordering may have changed since adding.
     */
    function removeTransaction(uint index)
        external
        onlyOperator
    {
        require(index < transactions.length, "index out of bounds");
        if (index < transactions.length - 1) {
            transactions[index] = transactions[transactions.length - 1];
        }
        transactions.pop();
    }
    
    /**
     * @param index Index of transaction. Transaction ordering may have changed since adding.
     * @param enabled True for enabled, false for disabled.
     */
    function setTransactionEnabled(uint index, bool enabled)
        external
        onlyOperator
    {
        require(index < transactions.length, "index must be in range of stored tx list");
        transactions[index].enabled = enabled;
    }
    
    /**
     * @return Number of transactions, both enabled and disabled, in transactions list.
     */
    function transactionsSize()
        external
        view
        returns (uint256)
    {
        return transactions.length;
    }
    
    function externalCall() public {
        for (uint i = 0; i < transactions.length; i++) {
            Transaction storage t = transactions[i];
            if (t.enabled) {
                _externalCall(t.destination,t.data);
            }
        }
    }
    
    /**
     *  wrapper to call the encoded transactions on downstream consumers.
     *  destination Address of destination contract.
     *  data The encoded data payload.
     *  True on success
     */
    function _externalCall(address destination, bytes4 selector) 
        internal
    {
        (bool success, bytes memory data) = destination.call(abi.encodeWithSelector(selector));
        require(success && (data.length == 0 || abi.decode(data, (bool))), "Orchestrator: Transaction Failed");
    }
    
}