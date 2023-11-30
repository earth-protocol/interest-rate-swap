// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../src/strategies/staking/EarthLpStaking.sol";
import "../src/strategies/staking/CommonStrat.sol";
import "../src/strategies/common/interfaces/IStrategy.sol";
import "../src/vaults/RiveraAutoCompoundingVaultV2Public.sol";

contract EarthLpStakingScript is Script {
    address _stake = 0xB8775999484624E8545379981576a66083616Bf1; //ACE-WZETA
    uint256 _poolId = 2;
    address _chef = 0xB8775999484624E8545379981576a66083616Bf1; //Randome address for now
    address _router = 0xf223609c70bA25e7bb286f008a50f934ee7B8A4A; // ACE router
    address _reward = 0xB8775999484624E8545379981576a66083616Bf1; //Randome address for now
    address _lp0Token = 0x0A67e05a87b87f210277542267ABD87F9D29CB67; //WZETA from AceSwap
    address _lp1Token = 0x1320f70ab72E867d3e54840929659fF75cA88210; //ACE token
    address _factory = 0xcE8614ECE9C7c160600ca956667d3c0f7B98a350; //ACE factory

    address[] _rewardToLp0Route = new address[](2);
    address[] _rewardToLp1Route = new address[](2);

    uint256 stratUpdateDelay = 172800;
    uint256 vaultTvlCap = 10000e18;

    function setUp() public {
        _rewardToLp0Route[0] = _reward;
        _rewardToLp0Route[1] = _lp0Token;
        _rewardToLp1Route[0] = _reward;
        _rewardToLp1Route[1] = _lp1Token;
    }

    function run() public {
        uint privateKey = 0xfc2f8cc0abd2d9d05229c8942e8a529d1ba9265eb1b4c720c03f7d074615afbb;
        address acc = vm.addr(privateKey);
        console.log("Account", acc);

        vm.startBroadcast(privateKey);
        //deploying the AutoCompounding vault
        RiveraAutoCompoundingVaultV2Public vault = new RiveraAutoCompoundingVaultV2Public(
                _stake,
                "Earth-WZETA-ACE-Vault",
                "Earth-WZETA-ACE-Vault",
                stratUpdateDelay,
                vaultTvlCap
            );
        CommonAddresses memory _commonAddresses = CommonAddresses(
            address(vault),
            _router
        );
        EarthLpStakingParams memory earthLpStakingParams = EarthLpStakingParams(
            _stake,
            _poolId,
            _chef,
            _rewardToLp0Route,
            _rewardToLp1Route,
            _lp0Token,
            _factory
        );

        //Deploying the parantStrategy

        EarthLpStaking parentStrategy = new EarthLpStaking(
            earthLpStakingParams,
            _commonAddresses
        );
        vault.init(IStrategy(address(parentStrategy)));
        console2.logAddress(address(vault.strategy()));
        console.log("ParentVault");
        console2.logAddress(address(vault));
        console.log("ParentStrategy");
        console2.logAddress(address(parentStrategy));
        vm.stopBroadcast();
    }
}

/*    Account 0x69605b7A74D967a3DA33A20c1b94031BC6cAF27c
  0x8a1b62c438B7b1d73A7a323C6b685fEc021610aC
  ParentVault
  0x33e47Fe37FeF6AB1d83e54AAD6c8D01C048171E1
  ParentStrategy
  0x8a1b62c438B7b1d73A7a323C6b685fEc021610aC

  //https://zetachain-athens-evm.blockpi.network/v1/rpc/public rpc endpoint for zeta testnet
*/

//forge script script/EarthLpStaking.s.sol:EarthLpStakingScript --rpc-url https://zetachain-athens-evm.blockpi.network/v1/rpc/public --broadcast -vvv --legacy --slow
