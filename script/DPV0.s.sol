// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../src/strategies/irs/EarthLpStaking.sol";
import "../src/strategies/irs/CommonStrat.sol";
import "../src/strategies/common/interfaces/IStrategy.sol";
import "../src/vaults/EarthAutoCompoundingVaultPublic.sol";

contract DeployEarthAsset0VaultWithCommonStrategy is Script {
    address parentStrategy = 0x23b3022BD63E6F7FE9aF5371f3AFC981449930af;
    address _lp0Token = 0x0A67e05a87b87f210277542267ABD87F9D29CB67; //WZETA ZetaTest

    uint256 _stratUpdateDelay = 172800;
    uint256 _vaultTvlCap = 10000e18;

    function setUp() public {}

    function run() public {
        uint privateKey = vm.envUint("PRIVATE_KEY");
        address acc = vm.addr(privateKey);
        console.log("Account", acc);

        vm.startBroadcast(privateKey);
        EarthAutoCompoundingVaultPublic cloudVault = new EarthAutoCompoundingVaultPublic(
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
 Account 0xFaBcc4b22fFEa25D01AC23c5d225D7B27CB1B6B8
  WZETA Vault
  0x7F0F5AAF002Fd32b964a2D77Ce21C9F2F9e2e18E
  WZETA Strategy
  0x606e5cc263cA1c8c72331a1B69b48f84c2289EE9 */

// forge script script/DPV0.s.sol:DeployEarthAsset0VaultWithCommonStrategy --rpc-url https://zetachain-athens-evm.blockpi.network/v1/rpc/public --broadcast -vvv --legacy --slow
