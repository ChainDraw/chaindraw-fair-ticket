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
	NETWORK_ARGS := --rpc-url $(BSC_TESTNET_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(BSCSCAN_API_KEY)
endif

ifeq ($(findstring --network sepolia,$(ARGS)),--network sepolia)
    NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY)
endif

# Deploy LotteryEscrowFactory contract
deploy:
	@forge script script/deploy/DeployLotteryEscrowFactory.s.sol:DeployLotteryEscrowFactory $(NETWORK_ARGS)


# Verify LotteryEscrowFactory contract
#example: make verify CONTRACT=LotteryEscrowFactory ADDRESS=0xb63695De4787d338725f0F281380d0dC82768f43 ARGS="--network bsc_testnet" 
verify:
	@echo "Verifying contract $(CONTRACT) at address $(ADDRESS)"
	@if [ -z "$(CONTRACT)" ] || [ -z "$(ADDRESS)" ]; then \
		echo "Error: CONTRACT and ADDRESS must be specified"; \
		exit 1; \
	fi
	@forge verify-contract --watch --chain ${CHAIN_ID} --compiler-version v0.8.20+commit.a1b79de6 --etherscan-api-key $(BSCSCAN_API_KEY) $(ADDRESS) $(CONTRACT)

# Define default verification arguments
SOLC_VERSION := v0.8.20+commit.a1b79de6
CHAIN_ID := 1 # Default to Ethereum mainnet
ETHERSCAN_API_KEY := $(ETHERSCAN_API_KEY) # Default to Etherscan API key from .env

# Override verification arguments for BSC testnet
ifeq ($(findstring --network bsc_testnet,$(ARGS)),--network bsc_testnet)
	CHAIN_ID := 97 # BSC testnet chain ID
	ETHERSCAN_API_KEY := $(BSCSCAN_API_KEY)
endif

ifeq ($(findstring --network sepolia,$(ARGS)),--network sepolia)
    CHAIN_ID := 11155111 # Sepolia testnet chain ID
    ETHERSCAN_API_KEY := $(ETHERSCAN_API_KEY)
endif