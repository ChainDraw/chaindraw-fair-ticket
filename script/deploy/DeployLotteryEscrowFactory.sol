// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {LotteryEscrowFactory} from "../../src/escrow/LotteryEscrowFactory.sol";
import "forge-std/console.sol";

contract DeployLotteryEscrowFactory is Script {
    function run() external {
        // 使用 vm.env 读取环境变量
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // 部署 LotteryEscrowFactory 合约
        LotteryEscrowFactory factory = new LotteryEscrowFactory();
        console.log("LotteryEscrowFactory deployed to:", address(factory));
        vm.stopBroadcast();
    }
}
