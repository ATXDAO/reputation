# REP TOKEN

## Setup

##### WARNING THIS FILE IS NOT IGNORED BY GIT. BE WEARY OF PUTTING SENSITIVE DATA IN IT

1. `cp .env.example_THIS_FILE_IS_NOT_IGNORED .env` and set those environment variables

##### WARNING THIS FILE IS NOT IGNORED BY GIT. BE WEARY OF PUTTING SENSITIVE DATA IN IT

1. install deps via `yarn install`
1. `npm i -g hardhat-shorthand` to install `hh`
1. compile contracts for hardhat tasks `hh compile`

## Testing

1. install [forge](https://github.com/gakonst/foundry)
   - install [rust](https://www.rust-lang.org/tools/install) via
     `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`
   - install `foundryup`: `curl https://raw.githubusercontent.com/gakonst/foundry/master/foundryup/install | bash`
   - run `foundryup`
1. `yarn test` in project directory
