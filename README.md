Author: Jacob Homanics 

## Deployments
Version | Network | Deployment
--- | --- | --- |
0.1 | Optimism | [0x65ad2263e658e75762253076e2ebfc9211e05d2f](https://optimistic.etherscan.io/address/0x65ad2263e658e75762253076e2ebfc9211e05d2f)
0.2 | Base | [0x93b0593cae9544d677dc7c9a18cb791e634bf8d9](https://basescan.org/address/0x93b0593cae9544d677dc7c9a18cb791e634bf8d9)
0.1 | Polygon | [0x57AA5fd0914A46b8A426cC33DB842D1BB1aeADa2](https://polygonscan.com/address/0x57AA5fd0914A46b8A426cC33DB842D1BB1aeADa2)

## Reputation Tokens

Reputation Tokens is a customized ERC1155 smart contract built to be deployed standalone, proxied, or through Diamonds.
They allow for an entity to track trust with another entity in relation to eachother.
Additionally, they allow an entity to burn their tokens in exchange for a reward from the other entity.
The system handles minting, distributing, burning, token migration, and destination wallets.

### Overview

Admin -> Grants/Revokes Minter, Distributor, Burner, and Token Migrator roles.

### Minting

Minter -> mints tokens to -> Distributor 

An authorized entity can mint tokens ONLY to a distributor.

### Distributor

Distributor -> distributes tokens to -> Users

An authorized entity can distribute (transfer) tokens to ANY user.

### User

User -> burns tokens to -> Burner

Any user with a balance can send tokens ONLY with an ID of 1 to ONLY Burners.
NOTE: There is no role defined for User. If an address does not contain distributor role, then it can be assumed a User.

### Token Migrator

User -> Approves for Token Migrator to send the user's tokens on their behalf -> Token Migrator -> sends tokens to -> a new User.

## Usage

### Test

```shell
$ forge test
```

### Coverage

```shell
$ forge coverage
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Deploy

```shell
cp .env.example .env
#Fill out .env with appropriate properties

$ make deployReputationTokensStandaloneWithData ARGS="--network $NETWORK"
```

### Extra

```shell
forge coverage --report lcov
```