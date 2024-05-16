-include .env

.PHONY: all test clean deploy help install update build format

help:
	@echo "Usage:"
	@echo "  make deploy [ARGS=...]\n    example: make deploy ARGS=\"--network bsc_testnet\""
	@echo ""

all: clean install update build

# Clean the repo
clean:; forge clean

# Install dependencies
install:; forge install

# Update dependencies
update:; forge update

# Build contracts
build:; forge build

# Run tests
test:; forge test

# Format code
format:; forge fmt

# Define default network arguments
NETWORK_ARGS := --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

# Override network arguments for BSC testnet
ifeq ($(findstring --network bsc_testnet,$(ARGS)),--network bsc_testnet)
	NETWORK_ARGS := --rpc-url $(BSC_TESTNET_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast
endif

ifeq ($(findstring --network sepolia,$(ARGS)),--network sepolia)
    NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast
endif

# Deploy LotteryEscrowFactory contract
deploy:
	@forge script script/DeployLotteryEscrowFactory.s.sol:DeployLotteryEscrowFactory $(NETWORK_ARGS)
