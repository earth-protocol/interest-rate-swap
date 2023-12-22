pragma solidity ^0.8.4;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../src/strategies/common/interfaces/IStrategy.sol";
import "../src/vaults/RiveraAutoCompoundingVaultV2Public.sol";
import "@openzeppelin/token/ERC20/IERC20.sol";

contract CheckVaults is Script {
    address _vaultParent = 0x78b3b52617e275f2a8507aD70E0eCa326F17b5B8;
    address _vaultAsset0 = 0x18207ac1041EFd5B733Ba0EbeA1285a8ee016056;
    address _vaultAsset1 = 0x0cE9E05f72Ae84f15a89Ca3BDA949422Bf459a1b;

    function run() public {
        IStrategy parentStrategy = RiveraAutoCompoundingVaultV2Public(_vaultParent)
            .strategy();
        IStrategy asset0Strategy = RiveraAutoCompoundingVaultV2Public(_vaultAsset0)
            .strategy();
        IStrategy asset1Strategy = RiveraAutoCompoundingVaultV2Public(_vaultAsset1)
            .strategy();



        uint256 balanceOfParent = parentStrategy.balanceOf();
        uint256 balanceOfAsset0 = asset0Strategy.balanceOf();
        uint256 balanceOfAsset1 = asset1Strategy.balanceOf();
        bool epochRunning = parentStrategy.epochRunning();
        if (epochRunning) {
            console.log("running");
        } else {
            console.log("not running");
        }
        console2.log(balanceOfParent);
        console2.log(balanceOfAsset0);
        console2.log(balanceOfAsset1);
    }
}

// forge script script/CheckVaults.s.sol:CheckVaults --rpc-url http://127.0.0.1:8545/  --broadcast -vvv --legacy --slow
