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

contract VeraxAttestationHook is BaseHook, Test {
    using FeeLibrary for uint24;

    address _currentSwapper;
    IConnector _connector;
    bytes32 _schema;

    error AttestationNotValid();

    constructor(
        IPoolManager _poolManager,
        address connector,
        bytes32 schema
    ) BaseHook(_poolManager) {
        _connector = IConnector(connector);
        _schema = schema;
    }

    // --- ----------------------- ---

    function collectHookFees(
        address recipient,
        Currency currency,
        uint256 amount
    ) external {
        Fees(address(poolManager)).collectHookFees(recipient, currency, amount);
    }

    function getFee(address, PoolKey calldata) external view returns (uint24) {
        return 200_000;
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

        if (abi.decode(value, (bool)) != true) {
            revert AttestationNotValid();
        }

        return BaseHook.beforeSwap.selector;
    }
}
