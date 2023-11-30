// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../src/strategies/staking/EarthLpStaking.sol";
import "../src/strategies/staking/CommonStrat.sol";
import "../src/strategies/common/interfaces/IStrategy.sol";
import "../src/vaults/RiveraAutoCompoundingVaultV2Public.sol";

contract DeployEarthAsset1VaultWithCommonStrategy is Script {
    address parentStrategy = 0x23b3022BD63E6F7FE9aF5371f3AFC981449930af;
    address _lp1Token = 0x1320f70ab72E867d3e54840929659fF75cA88210; // ACE token
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
/*  Account 0x69605b7A74D967a3DA33A20c1b94031BC6cAF27c
  ACE Vault
  0x821F88928C950F638a94b74cD44A1b676D51a310
  ACE Strategy
  0xb642f6F85fc68876700FB2699963611632AD8644*/

// forge script script/DPV1.s.sol:DeployEarthAsset1VaultWithCommonStrategy --rpc-url https://zetachain-athens-evm.blockpi.network/v1/rpc/public --broadcast -vvv --legacy --slow
