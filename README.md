Author: Jacob Homanics 

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
$ make deployReputationTokensStandaloneWithData ARGS="--network $NETWORK"
```

### Extra

```shell
forge coverage --report lcov
```