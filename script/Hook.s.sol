// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {PoolManager} from "v4-core/PoolManager.sol";
import {TickMath} from "v4-core/libraries/TickMath.sol";
import {MockToken} from "../src/mocks/MockToken.sol";
import {UniswapV4Router} from "../src/router/UniswapV4Router.sol";
import {UniswapV4Caller} from "../src/router/UniswapV4Caller.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";

contract HookScript is Script {
    uint160 public constant MIN_PRICE_LIMIT = TickMath.MIN_SQRT_RATIO + 1;
    uint160 public constant MAX_PRICE_LIMIT = TickMath.MAX_SQRT_RATIO - 1;
    uint160 public constant SQRT_RATIO_1_TO_1 = 79228162514264337593543950336;
    bytes constant EmptyResults = hex"";
    uint256 constant MaxAmount = type(uint128).max;

    IPoolManager manager;
    MockToken tokenA;
    MockToken tokenB;
    UniswapV4Router router;
    UniswapV4Caller caller;

    function initialize() public {
        console.log("test sender %s", address(this));

        MockToken _tokenA = new MockToken("Token A", "TOKA", MaxAmount);
        MockToken _tokenB = new MockToken("Token B", "TOKB", MaxAmount);

        // pools alphabetically sort tokens by address
        // so align `token0` with `pool.token0` for consistency
        if (address(_tokenA) < address(_tokenB)) {
            tokenA = _tokenA;
            tokenB = _tokenB;
        } else {
            tokenA = _tokenB;
            tokenB = _tokenA;
        }
        console.log("token0 %s", address(tokenA));
        console.log("token1 %s", address(tokenB));

        manager = new PoolManager(500000);
        console.log("pool manager %s", address(manager));

        // Deploy a generic router
        router = new UniswapV4Router(manager);
        console.log("router %s", address(router));
        caller = new UniswapV4Caller(router, manager);
        console.log("caller %s", address(caller));

        tokenA.approve(address(router), MaxAmount);
        tokenB.approve(address(router), MaxAmount);
    }
}
