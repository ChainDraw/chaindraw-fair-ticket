// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script} from "forge-std/Script.sol";
import {LotteryEscrow} from "../../src/escrow/LotteryEscrow.sol";
import "forge-std/console.sol";

contract DeployLotteryEscrow is Script {
    function run() external {
        // 使用 vm.env 读取环境变量
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // 部署 LotteryEscrow 合约
        LotteryEscrow esceow = new LotteryEscrow(0x36FE82fB67DFEA5a469f1502f88044b78C3e97C2,10010, 2 ,"NORMAL" ,"yuduotiangaung" ,1 ,"www.test.com" ,1 ,1716529495,1716529495);
        console.log("LotteryEscrow deployed to:", address(esceow));
        vm.stopBroadcast();
    }
}
