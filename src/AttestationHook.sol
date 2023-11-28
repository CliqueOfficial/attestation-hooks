// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IHooks} from "v4-core/interfaces/IHooks.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {BalanceDelta} from "v4-core/types/BalanceDelta.sol";
import {BaseHook} from "./base/BaseHook.sol";
import {BaseFactory} from "./base/BaseFactory.sol";
import {Hooks} from "v4-core/libraries/Hooks.sol";
import {FeeLibrary} from "v4-core/libraries/FeeLibrary.sol";
import {Currency, CurrencyLibrary} from "v4-core/types/Currency.sol";
import {Fees} from "v4-core/Fees.sol";
import {IConnector} from "./interfaces/IConnector.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract AttestationHook is BaseHook, Ownable {
    using FeeLibrary for uint24;

    enum AttestationType {
        EAS,
        VERAX
    }

    AttestationType public _attestationType;
    IConnector _connector;
    bytes32 _easSchema;
    bytes32 _veraxSchema;

    error AttestationNotValid();

    constructor(
        IPoolManager _poolManager,
        address connector,
        bytes32 easSchema,
        bytes32 veraxSchema
    ) BaseHook(_poolManager) {
        _connector = IConnector(connector);
        _easSchema = easSchema;
        _veraxSchema = veraxSchema;
    }

    function toggleAttestationType() public onlyOwner {
        _attestationType = _attestationType == AttestationType.EAS
            ? AttestationType.VERAX
            : AttestationType.EAS;
    }

    function collectHookFees(
        address recipient,
        Currency currency,
        uint256 amount
    ) external {
        Fees(address(poolManager)).collectHookFees(recipient, currency, amount);
    }

    function getFee(address, PoolKey calldata) external pure returns (uint24) {
        return 0x5533;
    }

    function getHooksCalls() public pure override returns (Hooks.Calls memory) {
        return
            Hooks.Calls({
                beforeInitialize: false,
                afterInitialize: false,
                beforeModifyPosition: false,
                afterModifyPosition: false,
                beforeSwap: true,
                afterSwap: true,
                beforeDonate: false,
                afterDonate: false
            });
    }

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

    function _easAttestation() internal view returns (bytes memory) {
        bytes32 attestationId = _connector.getReceivedAttestationUIDs(
            tx.origin,
            _easSchema,
            0,
            1,
            false
        )[0];

        return
            _connector.getAttestationValueById(
                _connector.VERAX(),
                attestationId
            );
    }

    function _veraxAttestation() internal view returns (bytes memory) {
        bytes32 attestationId = _connector.getReceivedAttestationUIDs(
            tx.origin,
            _veraxSchema,
            0,
            1,
            false
        )[0];

        return
            _connector.getAttestationValueById(
                _connector.VERAX(),
                attestationId
            );
    }
}
