require("@nomiclabs/hardhat-waffle");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.1",
  networks :{
    rinkeby:{
      url:"https://eth-rinkeby.alchemyapi.io/v2/m20zQEDf8N8dxyGou4REDgErXZ7B710U",
      accounts : ['6d41260940bcd3a8913742c59fdc5126d27094f767a6f5d87d1f2aeb005a65f9']
    }
  }
};
