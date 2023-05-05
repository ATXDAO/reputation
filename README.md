# Rep Token Smart Contracts

Rep Tokens are a modification of the ERC1155 standard. It implements several OpenZeppelin standards and the ERC2771 standard, which allows for gasless transactions.

There are several roles that are important to keeping the smart contract's instances safe and manageable.  
`DEFAULT_ADMIN_ROLE` - Allows for the ability to grant/revoke others' roles.  
`MINTER_ROLE` - Addresses granted this role can mint new tokens to other addresses with the `DISTRIBUTOR_ROLE`  
`DISTRIBUTOR_ROLE` - Addresses granted this role can freely send its Rep Tokens anywhere.  
`TOKEN_MIGRATOR_ROLE` - Addresses granted this role can freely send other addresses' Rep Tokens anywhere (assuming setApprovalForAll(TokenMigrator, true)) has been called prior.

`RepTokens.sol` - A modification of the ERC1155 standard which limits transferability of tokens, makes use of OpenZeppelin's AccessControl, and implements gasless transaction support.   

`IRepTokens.sol` - Interface for the Rep Tokens functions.   

`SingleRecipientPaymaster.sol` a smart contract that inherits from @opengsn/contracts/BasePaymaster which allows for an instance of this smart contract to act as a 'bank' for an instance of RepTokens.sol. Ultimately allowing for users wishing to change the state of a RepToken's instance without directly paying gas fees.   

There are additional steps needed in order to set up gasless transactions after deployment. Please follow the instructions here:   
https://docs.google.com/document/d/1iNZiTUfMc78hvt2lS2KEXkKb5WbplgDtjSw8vy3Czvk/edit?usp=sharing


# Deployment
Simple deployment through hardhat by running `npx hardhat run scripts/deploy.js --network NETWORK`.    
`deploy.js` deploys a new instance of `RepTokens.sol`, references that instance and creates a new instance of `SingleRecipientPaymaster.sol`.

# Testing
Simple testing through hardhat by running `npx hardhat test` which runs the tests found at `test/test.js`.   