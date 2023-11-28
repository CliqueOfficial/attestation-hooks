## Uniswap v4 Hooks with Clique's Connector

This repository demonstrates the use of Uniswap v4 hooks in conjunction with Clique's Connector smart contract. The purpose is to showcase how projects can integrate and develop their own hooks using our connector.

## Overview

Uniswap v4 hooks are a powerful feature that allows developers to customize and extend the functionality of Uniswap v4 pools. In this repository, we use these hooks to query for EAS and Verax attestations and verify them directly within the hooks.

The hooks are implemented in the `EASAttestationHook` and `VeraxAttestationHook` contracts. These contracts inherit from the `BaseHook` contract and override the `beforeSwap` function to perform the attestation checks.

The `IConnector` interface is used to interact with the Clique's Connector smart contract. This contract provides functions to get attestations and their values.

## Key Code Snippets

The `beforeSwap` function in the `EASAttestationHook` contract queries for an EAS attestation and verifies it:

```solidity
    function beforeSwap(
        address,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata,
        bytes calldata
    ) external override returns (bytes4) {
        bytes32 attestationId = _connector.getReceivedAttestationUIDs(
            tx.origin,
            _schema,
            0,
            1,
            false
        )[0];

        bytes memory value = _connector.getAttestationValueById(
            _connector.VERAX(),
            attestationId
        );
```

Similarly, the `beforeSwap` function in the `VeraxAttestationHook` contract queries for a Verax attestation and verifies it:

```solidity
    function beforeSwap(
        address,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata,
        bytes calldata
    ) external override returns (bytes4) {
        bytes32 attestationId = _connector.getAttestationIdsBySubjectBySchema(
            abi.encode(tx.origin),
            _schema
        )[0];

        bytes memory value = _connector.getAttestationValueById(
            _connector.EAS(),
            attestationId
        );
```
