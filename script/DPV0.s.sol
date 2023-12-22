// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../src/strategies/staking/EarthLpStaking.sol";
import "../src/strategies/staking/CommonStrat.sol";
import "../src/strategies/common/interfaces/IStrategy.sol";
import "../src/vaults/RiveraAutoCompoundingVaultV2Public.sol";

contract DeployEarthAsset0VaultWithCommonStrategy is Script {
    address parentStrategy = 0xE1B0Fe3af433a220b0868b4adE41Bd672B0a7562;
    address _lp0Token = 0x09Bc4E0D864854c6aFB6eB9A9cdF58aC190D0dF9; //USDC Mantle

    uint256 _stratUpdateDelay = 172800;
    uint256 _vaultTvlCap = 10000e6;

    function setUp() public {}

    function run() public {
        uint privateKey = 0xfc2f8cc0abd2d9d05229c8942e8a529d1ba9265eb1b4c720c03f7d074615afbb;
        address acc = vm.addr(privateKey);
        console.log("Account", acc);

        vm.startBroadcast(privateKey);
        RiveraAutoCompoundingVaultV2Public cloudVault = new RiveraAutoCompoundingVaultV2Public(
                _lp0Token,
                "Earth-WZETA-Vault",
                "Earth-WZETA-Vault",
                _stratUpdateDelay,
                _vaultTvlCap
            );
        CommonStrat cloudStrategy = new CommonStrat(
            address(cloudVault),
            address(parentStrategy),
            2,
            100
        );
        cloudVault.init(IStrategy(address(cloudStrategy)));
        console.log("WZETA Vault");
        console2.logAddress(address(cloudVault));
        console.log("WZETA Strategy");
        console2.logAddress(address(cloudStrategy));

        vm.stopBroadcast();
    }
}
/* 
    Account 0x69605b7A74D967a3DA33A20c1b94031BC6cAF27c
  WZETA Vault
  0x18207ac1041EFd5B733Ba0EbeA1285a8ee016056
  WZETA Strategy
  0x7A514e638F87ffF531C4C723D272fE214F0C382A */

// forge script script/DPV0.s.sol:DeployEarthAsset0VaultWithCommonStrategy --rpc-url http://127.0.0.1:8545/  --broadcast -vvv --legacy --slow
