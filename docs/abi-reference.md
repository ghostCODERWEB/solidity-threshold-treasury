# ABI reference

Generated from the successfully compiled primary contract. Includes inherited methods. Authorization and economic semantics are documented in the source.

| Signature | Type | Mutability | Returns |
|---|---|---|---|
| `constructor(address[] owners,uint256 required,uint64 wait)` | constructor | nonpayable |  |
| `ReentrancyGuardReentrantCall()` | error |  |  |
| `Approved(uint256 id,address signer)` | event |  |  |
| `Deposited(address sender,uint256 amount)` | event |  |  |
| `Executed(uint256 id,bytes result)` | event |  |  |
| `Revoked(uint256 id,address signer)` | event |  |  |
| `Submitted(uint256 id,address proposer,address target,uint256 value)` | event |  |  |
| `approve(uint256 id)` | function | nonpayable |  |
| `approved(uint256 ,address )` | function | view | bool  |
| `delay()` | function | view | uint64  |
| `execute(uint256 id)` | function | nonpayable |  |
| `isSigner(address )` | function | view | bool  |
| `revoke(uint256 id)` | function | nonpayable |  |
| `signers(uint256 )` | function | view | address  |
| `submit(address target,uint256 value,bytes data)` | function | nonpayable | uint256 id |
| `threshold()` | function | view | uint256  |
| `transaction(uint256 id)` | function | view | tuple  |
| `transactionCount()` | function | view | uint256  |
