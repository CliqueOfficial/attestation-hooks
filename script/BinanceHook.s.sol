// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// Importing required libraries and contracts
import "forge-std/Script.sol";
import {FeeLibrary} from "v4-core/libraries/FeeLibrary.sol";
import {Hooks, IHooks} from "v4-core/libraries/Hooks.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {IHooks} from "v4-core/interfaces/IHooks.sol";
import {BinanceHook} from "../src/BinanceHook.sol";
import {HookMiner} from "../test/utils/HookMiner.sol";
import {CurrencyLibrary, Currency} from "v4-core/types/Currency.sol";
import {TickMath} from "v4-core/libraries/TickMath.sol";
import {AttestationStation} from "../src/mocks/AttestationStation.sol";
import {PoolKey} from "v4-core/types/PoolId.sol";
import {HookScript} from "./Hook.s.sol";
import {Fees} from "v4-core/Fees.sol";
import {PoolId, PoolIdLibrary} from "v4-core/types/PoolId.sol";

// Main contract
contract DeployBinanceHook is HookScript {
    using CurrencyLibrary for Currency;
    using PoolIdLibrary for PoolKey;

    // State variables
    PoolKey poolKey;
    uint256 privateKey;
    address signerAddr;
    AttestationStation attestationStation;
    BinanceHook hook;

    // Constant variables
    address constant CREATE2_DEPLOYER =
        address(0x4e59b44847b379578588920cA78FbF26c0B4956C);

    // Setup function
    function setUp() public {
        // Initial setup
        privateKey = vm.envUint("PRIVATE_KEY");
        signerAddr = vm.addr(privateKey);
        vm.startBroadcast(privateKey);
        _attestationRegistry();
        HookScript.initialize();

        // Deploy the hook
        uint160 flags = uint160(Hooks.BEFORE_SWAP_FLAG | Hooks.AFTER_SWAP_FLAG);
        (address hookAddress, bytes32 salt) = HookMiner.find(
            CREATE2_DEPLOYER,
            flags,
            1000,
            type(BinanceHook).creationCode,
            abi.encode(address(manager))
        );
        hook = new BinanceHook{salt: salt}(manager);
        require(address(hook) == hookAddress, "hook: hook address mismatch");
        console.log("Deployed hook to address %s", address(hook));

        // Set hook parameters
        hook.setAttestationStation(address(attestationStation));
        hook.setIssuer(signerAddr);
        hook.setAttestationKey(bytes32("binance"));

        // Pool setup
        poolKey = PoolKey(
            Currency.wrap(address(tokenA)),
            Currency.wrap(address(tokenB)),
            FeeLibrary.DYNAMIC_FEE_FLAG,
            60,
            hook
        );
        manager.initialize(poolKey, SQRT_RATIO_1_TO_1, "");

        // Provide liquidity to the pool
        caller.addLiquidity(poolKey, signerAddr, -60, 60, 10e18);
        caller.addLiquidity(poolKey, signerAddr, -120, 120, 20e18);
        caller.addLiquidity(
            poolKey,
            signerAddr,
            TickMath.minUsableTick(60),
            TickMath.maxUsableTick(60),
            30e18
        );

        vm.stopBroadcast();
    }

    // Run function
    function run() public {
        vm.startBroadcast(privateKey);

        // Perform a test swap
        caller.swap(poolKey, signerAddr, signerAddr, poolKey.currency0, 1e18);
        console.log("swapped token 0 for token 1");

        // Uncomment below lines to remove liquidity and deposit token
        // caller.removeLiquidity(poolKey, signerAddr, -60, 60, 4e18);
        // console.log("removed liquidity");
        // caller.deposit(address(tokenA), signerAddr, signerAddr, 6e18);
        // vm.stopBroadcast();
    }

    // Attestation registry function
    function _attestationRegistry() internal {
        bytes32 attestationKey = bytes32("binance");
        attestationStation = new AttestationStation();
        console.log(
            "AttestationStation deployed at: %s",
            address(attestationStation)
        );
        attestationStation.attest(signerAddr, attestationKey, abi.encode(100));
        console.log("Attestation issued");
    }
}
