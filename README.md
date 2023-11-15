```
# in a new terminal, run the Forge script
export PRIVATE_KEY=
forge script script/BinanceHook.sol \
     --rpc-url https://l2-uniswap-v4-hook-sandbox-6tl5qq8i4d.t.conduit.xyz \
    --broadcast
``
```

# Testing the Hook

1. Initialize: Create mock tokens, deploy PoolManager, UniswapV4Router, and UniswapV4Caller.
2. Approve Tokens: Approve router to spend tokens.
3. Setup: Retrieve private key, start broadcasting transactions, initialize environment.
4. Deploy Hook: Deploy BinanceHook, set attestation parameters.
5. Initialize Pool: Create new pool, add liquidity.
6. deploy AttestationStation, issue attestation
7. Run the swap transaction
8. Hook verifies the binance attestation meets the required threshold
9. Pending verification result, a fee exemption is or is not awarded
