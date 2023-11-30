pragma solidity ^0.8.4;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "@earth/strategies/common/interfaces/IStrategy.sol";
import "@earth/vaults/EarthAutoCompoundingVaultPublic.sol";
import "@openzeppelin/token/ERC20/IERC20.sol";

contract CheckVaults is Script {
    address _vaultParent = 0x1E8D2C1efbF80e7BCaf2347AfA4F559756DE90B3;
    address _vaultAsset0 = 0x7F0F5AAF002Fd32b964a2D77Ce21C9F2F9e2e18E;
    address _vaultAsset1 = 0x0DAb8d11ed0DA724FE6AaFdd0527b78E425eD507;

    function run() public {
        IStrategy parentStrategy = EarthAutoCompoundingVaultPublic(_vaultParent)
            .strategy();
        IStrategy asset0Strategy = EarthAutoCompoundingVaultPublic(_vaultAsset0)
            .strategy();
        IStrategy asset1Strategy = EarthAutoCompoundingVaultPublic(_vaultAsset1)
            .strategy();

        // IStrategy parentStrategy = IStrategy(
        //     0xBeC9acF7e1b102EFD92747Ddb0F9eD175BFa375f
        // );
        // IStrategy asset0Strategy = IStrategy(
        //     0x81a904f1F7296015c5Df2E9280AdEe0eeCc4D95c
        // );
        // IStrategy asset1Strategy = IStrategy(
        //     0xaBff647aF832e876F9d2e515D58d4eA4778ca3aA
        // );

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
