```
# in a new terminal, run the Forge script
export PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
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
7. Run: Perform test swap.

Hook.s.sol

This script is responsible for setting up the initial environment for testing the hook. Here are the steps it performs:

1. Initialize: It creates two mock tokens (Token A and Token B) and assigns them to tokenA and tokenB based on their addresses. It also deploys a PoolManager and a UniswapV4Router and assigns them to manager and router respectively. A UniswapV4Caller is also deployed with the router and manager as parameters.

2. Approve Tokens: It approves the router to spend the maximum amount of both tokenA and tokenB.
   BinanceHook.s.sol

This script is responsible for deploying and testing the Binance hook. Here are the steps it performs:

1. Setup: It retrieves the private key from the environment and starts broadcasting transactions from the address corresponding to this private key. It also calls the initialize function from Hook.s.sol to set up the initial environment.

2. Deploy Hook: It deploys a BinanceHook using the CREATE2 opcode, which allows for deterministic contract address calculation. It then sets the attestation station, issuer, and attestation key on the hook.

3. Initialize Pool: It initializes a new pool on the PoolManager with the two tokens, the dynamic fee flag, a fee of 60, and the deployed hook.

4. Add Liquidity: It adds liquidity to the pool at different price ranges using the UniswapV4Caller.

5. Attestation Registry: It deploys an AttestationStation and issues an attestation for the address corresponding to the private key with the key "binance" and a value of 100.

6. Run: It performs a test swap of tokenA for tokenB using the UniswapV4Caller. It also contains commented out code for removing liquidity and depositing tokens.

These scripts together set up a test environment, deploy a hook, initialize a pool with this hook, add liquidity to the pool, and perform a swap to test that the hook works as expected.
