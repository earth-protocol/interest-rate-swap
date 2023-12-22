// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../src/strategies/staking/EarthLpStaking.sol";
import "../src/strategies/staking/CommonStrat.sol";
import "../src/strategies/common/interfaces/IStrategy.sol";
import "../src/vaults/RiveraAutoCompoundingVaultV2Public.sol";

contract DeployEarthAsset1VaultWithCommonStrategy is Script {
    address parentStrategy = 0xE1B0Fe3af433a220b0868b4adE41Bd672B0a7562;
    address _lp1Token = 0xdEAddEaDdeadDEadDEADDEAddEADDEAddead1111; // wEth token
    uint256 _stratUpdateDelay = 172800;
    uint256 _vaultTvlCap = 10000e18;

    function setUp() public {}

    function run() public {
        uint privateKey = 0xfc2f8cc0abd2d9d05229c8942e8a529d1ba9265eb1b4c720c03f7d074615afbb;
        address acc = vm.addr(privateKey);
        console.log("Account", acc);

        vm.startBroadcast(privateKey);
        RiveraAutoCompoundingVaultV2Public wethVault = new RiveraAutoCompoundingVaultV2Public(
                _lp1Token,
                "Earth-ACE-Vault",
                "Earth-ACE-Vault",
                _stratUpdateDelay,
                _vaultTvlCap
            );
        CommonStrat wethStrategy = new CommonStrat(
            address(wethVault),
            address(parentStrategy),
            1,
            100
        );
        wethVault.init(IStrategy(address(wethStrategy)));
        console.log("ACE Vault");
        console2.logAddress(address(wethVault));
        console.log("ACE Strategy");
        console2.logAddress(address(wethStrategy));
        vm.stopBroadcast();
    }
}
/*     Account 0x69605b7A74D967a3DA33A20c1b94031BC6cAF27c
  ACE Vault
  0x0cE9E05f72Ae84f15a89Ca3BDA949422Bf459a1b
  ACE Strategy
  0x8866C8697867DF2211d02641f034c00d7dD50D31
  */

// forge script script/DPV1.s.sol:DeployEarthAsset1VaultWithCommonStrategy --rpc-url http://127.0.0.1:8545/ --broadcast -vvv --legacy --slow
