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
import "forge-std/Test.sol";

contract AttestationHook is BaseHook, Test {
    using FeeLibrary for uint24;

    address _currentSwapper;
    address _veraxPortal;
    bytes32 _protocolId;

    error MustUseDynamicFee();

    constructor(IPoolManager _poolManager) BaseHook(_poolManager) {}

    // --- VERAX CONFIGURATION ---
    function setVeraxPortal(address veraxPortal) external {
        _veraxPortal = veraxPortal;
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
        _currentSwapper = tx.origin;

        return BaseHook.beforeSwap.selector;
    }

    function afterSwap(
        address,
        PoolKey calldata,
        IPoolManager.SwapParams calldata,
        BalanceDelta,
        bytes calldata
    ) external override returns (bytes4) {
        _currentSwapper = address(0);
        return BaseHook.afterSwap.selector;
    }
}

contract AttestationHookFactory is BaseFactory {
    constructor() BaseFactory(address(uint160(Hooks.BEFORE_SWAP_FLAG))) {}

    function deploy(
        IPoolManager poolManager,
        bytes32 salt
    ) public override returns (address) {
        return address(new AttestationHook{salt: salt}(poolManager));
    }

    function _hashBytecode(
        IPoolManager poolManager
    ) internal pure override returns (bytes32 bytecodeHash) {
        bytecodeHash = keccak256(
            abi.encodePacked(
                type(AttestationHook).creationCode,
                abi.encode(poolManager)
            )
        );
    }
}
