# Uniswap v4 Hooks with Clique's Connector

This repository demonstrates the use of Uniswap v4 hooks in conjunction with Clique's Connector smart contract. The purpose is to showcase how projects can integrate and develop their own hooks using our connector.

## Overview

Uniswap v4 hooks are a powerful feature that allows developers to customize and extend the functionality of Uniswap v4 pools. In this repository, we use these hooks to query for EAS and Verax attestations and verify them directly within the hooks.

The hooks are implemented in the AttestationHook contract. This contract inherits from the BaseHook contract and overrides the beforeSwap function to perform the attestation checks. The type of attestation (EAS or Verax) can be toggled using the toggleAttestationType function.

The IConnector interface is used to interact with the Clique's Connector smart contract. This contract provides functions to get attestations and their values.

## Key Code Snippets

The beforeSwap function in the AttestationHook contract queries for an attestation (EAS or Verax, depending on the current configuration) and verifies it:

```solidity
function beforeSwap(
    address,
    PoolKey calldata,
    IPoolManager.SwapParams calldata,
    bytes calldata
) external view override returns (bytes4) {
    bytes memory value = _attestationType == AttestationType.EAS
        ? _easAttestation()
        : _veraxAttestation();

    if (abi.decode(value, (bool)) != true) revert AttestationNotValid();

    return BaseHook.beforeSwap.selector;
}
```

The toggleAttestationType function allows to switch between EAS and Verax attestations:

```solidity
function toggleAttestationType() public onlyOwner {
    _attestationType = _attestationType == AttestationType.EAS
        ? AttestationType.VERAX
        : AttestationType.EAS;
}
```
