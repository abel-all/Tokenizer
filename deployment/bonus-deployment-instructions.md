# Deploying Abel42 Token With MultiSign Feature

## Prerequisites
- **MetaMask wallet** connected to **Sepolia Testnet**
- **ETH for gas** from [Google Cloud Web3](https://cloud.google.com/application/web3/faucet/ethereum/sepolia)
- Access to [Remix IDE](https://cloud.google.com/application/web3/faucet/ethereum/sepolia)

## Steps
1. Open **Remix** and paste `MultiSignContract.sol` into a new file.  
2. Ensure the **Solidity compiler** is set to version `^0.8.0`.  
3. Compile the contract.  
4. Go to the **"Deploy & Run Transactions"** tab.  
5. Select **"Injected Provider - MetaMask"**.  
6. Enter the constructor arguments in Remix’s **Deploy** panel:
   - **`initialSupply`** (`uint256`, e.g., `1000000`)  
   - **`_owners`** (`address[]`, e.g., `["0xOwner1…", "0xOwner2…"]`)  
   - **`_requiredSignatures`** (`uint256`, e.g., `2`)  
   then click **"Deploy"** and confirm the transaction in MetaMask.  

## Contract Info
- **Deployed Address:** `0x000`
- **Network:** Sepolia Testnet
