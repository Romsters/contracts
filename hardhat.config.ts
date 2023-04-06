import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-ethers";

const config: HardhatUserConfig = {
  solidity: "0.8.18",
  networks: {
    goerli: {
      url: 'https://goerli.infura.io/v3/84842078b09946638c03157f83405213',
      accounts: [process.env.accountPrivateKey as string]
    } 
  }
};

export default config;
