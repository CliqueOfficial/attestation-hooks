// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.15;

// import "forge-std/Test.sol";
// import {GasSnapshot} from "forge-gas-snapshot/GasSnapshot.sol";
// import {IHooks} from "v4-core/interfaces/IHooks.sol";
// import {FeeLibrary} from "v4-core/libraries/FeeLibrary.sol";
// import {Hooks} from "v4-core/libraries/Hooks.sol";
// import {TickMath} from "v4-core/libraries/TickMath.sol";
// import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
// import {BalanceDelta} from "v4-core/types/BalanceDelta.sol";
// import {PoolKey, PoolId, PoolIdLibrary} from "v4-core/types/PoolId.sol";
// import {Deployers} from "v4-core-test/foundry-tests/utils/Deployers.sol";
// import {CurrencyLibrary, Currency} from "v4-core/types/Currency.sol";
// import {Pool} from "v4-core/libraries/Pool.sol";
// import {AttestationStation} from "../src/protocol/AttestationStation.sol";

// import {TestPoolManager} from "./utils/TestPoolManager.sol";
// import {BinanceHook, BinanceHookFactory} from "../src/BinanceHook.sol";

// contract BinanceHookTest is Test, TestPoolManager, Deployers, GasSnapshot {
//     using PoolIdLibrary for PoolKey;
//     using CurrencyLibrary for Currency;

//     BinanceHook hook;
//     PoolKey poolKey;

//     address user1 = makeAddr("user1");
//     address user2 = makeAddr("user2");

//     function setUp() public {
//         // Deploy AttestationStation
//         AttestationStation attestationStation = new AttestationStation();
//         attestationStation.attest(address(this), bytes32("binance"), abi.encode(696969));
//         console.logBytes(attestationStation.attestations(user1, user1, bytes32("binance")));

//         // creates the pool manager, test tokens and generic routers
//         TestPoolManager.initialize();

//         // // Deploy the factory contract
//         BinanceHookFactory factory = new BinanceHookFactory();
//         // // Use the factory to create a new hook contract
//         hook = BinanceHook(factory.mineDeploy(manager));
//         hook.setAttestationStation(address(attestationStation));

//         // Create the pool
//         poolKey = PoolKey(
//             Currency.wrap(address(tokenA)),
//             Currency.wrap(address(tokenB)),
//             FeeLibrary.DYNAMIC_FEE_FLAG,
//             60,
//             IHooks(hook)
//         );
//         manager.initialize(poolKey, SQRT_RATIO_1_1, "");

//         // Provide liquidity over different ranges to the pool
//         caller.addLiquidity(poolKey, address(this), -60, 60, 10 ether);
//         caller.addLiquidity(poolKey, address(this), -120, 120, 10 ether);
//         caller.addLiquidity(poolKey, address(this), TickMath.minUsableTick(60), TickMath.maxUsableTick(60), 10 ether);
//     }

//     // function test_Hook_Fee() public {
//     //     // Check the hook fee
//     //     (Pool.Slot0 memory slot0,,,) = manager.pools(poolKey.toId());
//     //     // assertEq(slot0.hookSwapFee, FeeLibrary.DYNAMIC_FEE_FLAG);
//     //     assertEq(slot0.hookFees, 0);

//     //     assertEq(manager.hookFeesAccrued(address(hook), poolKey.currency0), 0);
//     //     assertEq(manager.hookFeesAccrued(address(hook), poolKey.currency1), 0);
//     // }

//     function testSwap_AB() public {
//         // Swap tokenA for tokenB
//         console.log("caller", address(caller));
//         console.log("router", address(router));
//         vm.prank(user1);
//         bytes[] memory results = caller.swap(poolKey, address(this), address(this), poolKey.currency0, 100);

//         // Check settle result
//         BalanceDelta delta = abi.decode(results[0], (BalanceDelta));
//         assertEq(delta.amount0(), 100);
//         assertEq(delta.amount1(), -98);

//         // assertGt(manager.hookFeesAccrued(address(hook), poolKey.currency0), 0);
//         // assertEq(manager.hookFeesAccrued(address(hook), poolKey.currency1), 0);
//     }

//     // function testSwap_BA() public {
//     //     // Swap tokenB for tokenA
//     //     bytes[] memory results = caller.swap(poolKey, address(this), address(this), poolKey.currency1, 0);

//     //     // Check settle result
//     //     BalanceDelta delta = abi.decode(results[0], (BalanceDelta));
//     //     assertEq(delta.amount0(), -98);
//     //     assertEq(delta.amount1(), 100);
//     // }
// }
