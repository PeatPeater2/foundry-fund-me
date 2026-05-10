# FundMe Smart Contract (Foundry)

A decentralized crowdfunding smart contract built with Solidity and Foundry. It allows users to fund ETH with a minimum USD requirement and enables the owner to withdraw funds securely.

## Features
- Accept ETH funding from users
- Enforces minimum funding amount in USD (via Chainlink Price Feeds)
- Owner-only withdrawal function
- Tested using Foundry framework
- Deployment scripts included

## Tech Stack
- Solidity
- Foundry (Forge, Cast, Anvil)
- Chainlink Price Feeds
- Ethereum (Sepolia / Local Anvil)

## Project Structure
```
src/        → Smart contracts
script/     → Deployment scripts
test/       → Test files
lib/        → Dependencies
Makefile    → Automation commands
```

## Setup
```bash
git clone <your-repo-url>
cd foundry-fund-me
forge install
forge build
```

## Environment Variables
```
PRIVATE_KEY=0xYOUR_PRIVATE_KEY
SEPOLIA_RPC_URL=https://your-rpc-url
ETHERSCAN_API_KEY=your_api_key
```

## Run Tests
```bash
forge test -vvv
```

## Deployment
```bash
# Local
make anvil
make deploy

# Sepolia
make deploy-sepolia
```

## How It Works
1. Users send ETH to the contract
2. ETH value is converted to USD using Chainlink Price Feeds
3. Contract checks if funding meets minimum requirement
4. Owner can withdraw all funds securely

## What I Learned
- Solidity smart contract development
- Chainlink oracle integration
- Foundry testing and scripting
- Deployment automation using Makefile

This project is for learning purposes and demonstrates a basic crowdfunding mechanism in Web3.
