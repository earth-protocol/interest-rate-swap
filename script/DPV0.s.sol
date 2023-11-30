// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../src/strategies/staking/EarthLpStaking.sol";
import "../src/strategies/staking/CommonStrat.sol";
import "../src/strategies/common/interfaces/IStrategy.sol";
import "../src/vaults/RiveraAutoCompoundingVaultV2Public.sol";

contract DeployEarthAsset0VaultWithCommonStrategy is Script {
    address parentStrategy = 0x23b3022BD63E6F7FE9aF5371f3AFC981449930af;
    address _lp0Token = 0x0A67e05a87b87f210277542267ABD87F9D29CB67; //WZETA ZetaTest

    uint256 _stratUpdateDelay = 172800;
    uint256 _vaultTvlCap = 10000e18;

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
  0x4dCAdE22009eb0354cF44DbB777131CA2bFd3dcb
  WZETA Strategy
  0x47C242E3336a523c2866F6c5c94dE03998064C30 */

// forge script script/DPV0.s.sol:DeployEarthAsset0VaultWithCommonStrategy --rpc-url https://zetachain-athens-evm.blockpi.network/v1/rpc/public --broadcast -vvv --legacy --slow
