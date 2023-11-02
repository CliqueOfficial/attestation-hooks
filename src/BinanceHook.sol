// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IHooks} from "v4-core/interfaces/IHooks.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {BalanceDelta} from "v4-core/types/BalanceDelta.sol";
import {AttestationStation} from "./mocks/AttestationStation.sol";
import {BaseHook} from "./BaseHook.sol";
import {BaseFactory} from "./BaseFactory.sol";
import {Hooks} from "v4-core/libraries/Hooks.sol";
import {FeeLibrary} from "v4-core/libraries/FeeLibrary.sol";
import {Currency, CurrencyLibrary} from "v4-core/types/Currency.sol";
import {Fees} from "v4-core/Fees.sol";

contract BinanceHook is BaseHook {
    using FeeLibrary for uint24;

    bytes32 attestationKey;
    address attestationIssuer;
    address _currentSwapper;

    AttestationStation public attestationStation;
    uint256 public BINANCE_SCORE_THRESHOLD = 100;
    bytes32 binanceAttestationSchema;

    mapping(address swapper => bool feeExempt) public feeExemptions;

    error MustUseDynamicFee();

    constructor(IPoolManager _poolManager) BaseHook(_poolManager) {}

    function setAttestationStation(address _attestationStation) external {
        attestationStation = AttestationStation(_attestationStation);
    }

    function collectHookFees(
        address recipient,
        Currency currency,
        uint256 amount
    ) external {
        Fees(address(poolManager)).collectHookFees(recipient, currency, amount);
    }

    function getFee(
        address,
        PoolKey calldata,
        IPoolManager.SwapParams calldata,
        bytes calldata
    ) external view returns (uint24) {
        if (!feeExemptions[_currentSwapper]) return 100_000;
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
        if (!key.fee.isDynamicFee()) revert MustUseDynamicFee();

        _currentSwapper = tx.origin;

        bytes memory attestationValue = attestationStation.attestations(
            attestationIssuer,
            _currentSwapper,
            attestationKey
        );

        if (attestationValue.length == 0) {
            return BaseHook.beforeSwap.selector;
        }

        uint256 binanceScore = abi.decode(attestationValue, (uint256));

        if (binanceScore >= BINANCE_SCORE_THRESHOLD) {
            feeExemptions[_currentSwapper] = true;
        }

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

    function setIssuer(address issuer) external {
        attestationIssuer = issuer;
    }

    function setAttestationKey(bytes32 key) external {
        attestationKey = key;
    }
}

contract BinanceHookFactory is BaseFactory {
    constructor() BaseFactory(address(uint160(Hooks.BEFORE_SWAP_FLAG))) {}

    function deploy(
        IPoolManager poolManager,
        bytes32 salt
    ) public override returns (address) {
        return address(new BinanceHook{salt: salt}(poolManager));
    }

    function _hashBytecode(
        IPoolManager poolManager
    ) internal pure override returns (bytes32 bytecodeHash) {
        bytecodeHash = keccak256(
            abi.encodePacked(
                type(BinanceHook).creationCode,
                abi.encode(poolManager)
            )
        );
    }
}
