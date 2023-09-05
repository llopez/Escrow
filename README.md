[![test](https://github.com/llopez/Escrow/actions/workflows/test.yml/badge.svg)](https://github.com/llopez/Escrow/actions/workflows/test.yml)

## Escrow

The escrow holds the deposited tokens until the payment conditions are satisfied.

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ source .env
$ forge script script/Deploy.s.sol:Deploy --rpc-url $GOERLI_RPC_URL --broadcast --verify -vvvv
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
