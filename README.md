# Threshold native treasury

Immutable-owner multisig treasury with transaction approvals, revocation, delay and exactly-once execution.

An original AI-assisted Solidity reference project with OpenZeppelin security primitives, event-driven accounting, executable local-EVM tests and reproducible compilation. This is distinct contract logic on shared build/test infrastructure. No production deployment or independent audit is claimed.

## Run

Node.js 22+; dependencies are pinned in the lockfile.

```sh
npm ci
npm test
```

Tests compile with solc 0.8.30, optimizer 200 runs, and the Shanghai EVM target, then deploy to an in-process local chain. Tests require no RPC account, wallet key or funds. `npm run compile` emits ABI, bytecode, storage layouts and contract-size metadata under `artifacts/`.

## Contract behavior

Signer set and threshold are immutable. Delay starts at submission, not when quorum is reached. Calls can execute arbitrary target code after quorum; target failures revert execution and keep the transaction retryable. No signer rotation or signature-based approvals.

Read [the contract](contracts/ThresholdTreasury.sol), [behavior tests](test/suite.mjs), [architecture](docs/architecture.md), [threat model](docs/threat-model.md) and [deployment guide](docs/deployment.md) and [ABI reference](docs/abi-reference.md).

## Security properties

- Explicit state transition and authorization checks.
- SafeERC20 transfers and exact incoming custody where applicable.
- Reentrancy protection around external transfers and calls.
- Checks/effects/interactions ordering for settlements.
- Replay or settlement flags where applicable.
- Two-step admin ownership and pause controls where the suite uses an administrator.
- Tests for successful flows, rejected transitions, timing and accounting.

## Status

Reference version 0.1.0. Mocks have unrestricted minting and are test-only. No claim of mainnet safety, formal verification, protocol compatibility or economic security. No tokens were deployed to a public chain.

MIT licensed.
