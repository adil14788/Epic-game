# Epic Game 

This project demonstrates a basic NFT game. In this game there are several game characters that a user will be able to mint to attack the boss.
ERC721 has been used as a token standard for creating NFT. On chain metadata have been used. 

Features :
  1. The user can mint a character out of the available characters.
  2. The user can attack the boss which lives in the contract and is not a NFT.
  3. When a player attacks on the boss they boss also attacks the player.
  4. When boss and player attack each other each hp is reduced in propotional to their attacking damage
  5. Function to check if a player has already minted a character.
  
# Tech Stack 
  1. Solidity
  2. Javascript
  3. Hardhat 
  
  
# To test the contract 
  1. Clone this repo
  2. npm install 
  3. npx hardhat run ./scripts/run.js 

# Other useful commands
```shell
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
node scripts/sample-script.js
npx hardhat help
```
