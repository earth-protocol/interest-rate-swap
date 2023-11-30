// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../src/strategies/irs/EarthLpStaking.sol";
import "../src/strategies/irs/CommonStrat.sol";
import "../src/strategies/common/interfaces/IStrategy.sol";
import "../src/vaults/EarthAutoCompoundingVaultPublic.sol";

contract DeployEarthAsset1VaultWithCommonStrategy is Script {
    address parentStrategy = 0x23b3022BD63E6F7FE9aF5371f3AFC981449930af;
    address _lp1Token = 0x1320f70ab72E867d3e54840929659fF75cA88210; // ACE token
    uint256 _stratUpdateDelay = 172800;
    uint256 _vaultTvlCap = 10000e18;

    function setUp() public {}

    function run() public {
        uint privateKey = vm.envUint("PRIVATE_KEY");
        address acc = vm.addr(privateKey);
        console.log("Account", acc);

        vm.startBroadcast(privateKey);
        EarthAutoCompoundingVaultPublic wethVault = new EarthAutoCompoundingVaultPublic(
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
/* Account 0xFaBcc4b22fFEa25D01AC23c5d225D7B27CB1B6B8
  ACE Vault
  0x0DAb8d11ed0DA724FE6AaFdd0527b78E425eD507
  ACE Strategy
  0x7Da0c8f862be14501738808eea116129677b5CA5*/

// forge script script/DPV1.s.sol:DeployEarthAsset1VaultWithCommonStrategy --rpc-url https://zetachain-athens-evm.blockpi.network/v1/rpc/public --broadcast -vvv --legacy --slow
