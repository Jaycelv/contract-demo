require('dotenv').config();
const Web3 = require('web3').default;
const HDWalletProvider = require('@truffle/hdwallet-provider');
const cfgInfo = require('../config/x-ballot-nft-UC.json');
const abiCfg = require('../erc20-demo/artifacts/contracts/USDCToken.sol/USDCToken.json');
const ERC20_TOKEN_ABI = abiCfg.abi;
const opPortAddress = cfgInfo.sendUniversalPacket.optimism.portAddr;
const basePortAddress = cfgInfo.sendUniversalPacket.base.portAddr;
const privateKey = removePrefix(process.env.PRIVATE_KEY_1);
const OP_ERC20_TOKEN_ADDRESS = '0x6297f7bAACdf1746613D884466e7E644c884aaCD'; // need to be replaced after erc20 token deployed
const BASE_ERC20_TOKEN_ADDRESS = '0x7F9C7F1Dc2D0Ac49C9728Bc4A3Ba4654c2D76a5D'; // need to be replaced after erc20 token deployed

function removePrefix(privateKey) {
    if (privateKey.startsWith('0x')) {
        return privateKey.slice(2);
    }
    return privateKey;
}

async function main(from) {
    console.log(from)
    let url = (from === 'op' ? 'https://sepolia.optimism.io' : 'https://sepolia.base.org')
    const provider = new HDWalletProvider([privateKey], url);
    const web3 = new Web3(provider);
    const contract = new web3.eth.Contract(ERC20_TOKEN_ABI, from === 'op' ? OP_ERC20_TOKEN_ADDRESS : BASE_ERC20_TOKEN_ADDRESS);
    const method = contract.methods.changeManager(from === 'op' ? opPortAddress : basePortAddress);
    const accountList = await web3.eth.getAccounts();
    const account = accountList[0];
    const tx = await method.send({ from: account });
    console.log(`${from} auth tx hash:`, tx.transactionHash)
    process.exit(0);

}
main(process.argv[2]).catch(console.error);
