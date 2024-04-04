### Project title
Polymer ERC20 token

### Team members
    Jaycelv

### Project Overview
I attempted to create a cross-chain bridge between Optimism and Base using the official library, and then created the same ERC20 token on both chains, allowing users to perform cross-chain operations on each chain respectively.
## 📋 Prerequisites

The repo is **compatible with both Hardhat and Foundry** development environments.

- Have [git](https://git-scm.com/downloads) installed
- Have [node](https://nodejs.org) installed (v18+)
- Have [Foundry](https://book.getfoundry.sh/getting-started/installation) installed (Hardhat will be installed when running `npm install`)
- Have [just](https://just.systems/man/en/chapter_1.html) installed (recommended but not strictly necessary)

You'll need some API keys from third party's:
- [Optimism Sepolia](https://optimism-sepolia.blockscout.com/account/api-key) and [Base Sepolia](https://base-sepolia.blockscout.com/account/api-key) Blockscout Explorer API keys
- Have an [Alchemy API key](https://docs.alchemy.com/docs/alchemy-quickstart-guide) for OP and Base Sepolia

Some basic knowledge of all of these tools is also required, although the details are abstracted away for basic usage.

## 🧰 Install dependencies

To compile your contracts and start testing, make sure that you have all dependencies installed.

From the root directory run:

```bash
just install
```

to install the [vIBC core smart contracts](https://github.com/open-ibc/vibc-core-smart-contracts) as a dependency.

Additionally Hardhat will be installed as a dev dependency with some useful plugins. Check `package.json` for an exhaustive list.

> Note: In case you're experiencing issues with dependencies using the `just install` recipe, check that all prerequisites are correctly installed. If issues persist with forge, try to do the individual dependency installations...

## ⚙️ Set up your environment variables

Convert the `.env.example` file into an `.env` file. This will ignore the file for future git commits as well as expose the environment variables. Add your private keys and update the other values if you want to customize (advanced usage feature).

```bash
cp .env.example .env
```
### Run-book

1. deploy ERC20 contract
```
cd erc20-demo
npm install
npx hardhat compile 
npx hardhat run scripts/deploy.js --network optimism
npx hardhat run scripts/deploy.js --network base
```
then you will get two erc20 token contract address

2. deploy bridge contract
```
cd ..
just install 
npx hardhat compile
just deploy optimism base
```
3. You will get 2 contract addresses as port address(current: 0x4e228D691c5A5608EF05666924F9bC49a933D41F and 0x3Ab9640a577331afb5df06EDbb09Da517a072be1)
4. Set the port address as the administrator:
    call ERC20 contract to change admin, param is port address from previous step, This function must be called on every chain.
    `function changeManager(address newManager) public onlyOwner {
        manager = newManager;
    }`
5. run frontend page
```
cd vue-demo
npm install && npm run serve
```
See http://localhost:8080/
6. Add erc20 token to op and base with metamask
    op: 0x7736dF337A660B58b57D114e45C2327825fb6123
    base: 0x3D82d3C85Dd36a660B7AA5dFdd02cC850cF35400
7. Connect wallet and send transaction

### Resources Used
- vue.js
- hardhat
- bignumber.js
- web3.js
- @open-ibc/vibc-core-smart-contracts

### Future Improvements
In the future, I will refactor the smart contract code, remove unnecessary demo code, integrate the bridge and ERC20 into one contract, and improve the UI.

### Testnet interaction
Optimism: https://optimism-sepolia.blockscout.com/address/0x4e228D691c5A5608EF05666924F9bC49a933D41F?tab=internal_txns
Base: https://base-sepolia.blockscout.com/address/0x3Ab9640a577331afb5df06EDbb09Da517a072be1?tab=internal_txns

### PortAddress
Op: 0x4e228D691c5A5608EF05666924F9bC49a933D41F
Base: 0x3Ab9640a577331afb5df06EDbb09Da517a072be1
 

### Licence
[Apache 2.0](LICENSE)



