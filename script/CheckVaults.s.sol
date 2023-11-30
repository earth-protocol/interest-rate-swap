pragma solidity ^0.8.4;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../src/strategies/common/interfaces/IStrategy.sol";
import "../src/vaults/RiveraAutoCompoundingVaultV2Public.sol";
import "@openzeppelin/token/ERC20/IERC20.sol";

contract CheckVaults is Script {
    address _vaultParent = 0x33e47Fe37FeF6AB1d83e54AAD6c8D01C048171E1;
    address _vaultAsset0 = 0x4dCAdE22009eb0354cF44DbB777131CA2bFd3dcb;
    address _vaultAsset1 = 0x821F88928C950F638a94b74cD44A1b676D51a310;

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

// forge script script/CheckVaults.s.sol:CheckVaults --rpc-url https://zetachain-athens-evm.blockpi.network/v1/rpc/public --broadcast -vvv --legacy --slow
