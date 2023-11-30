// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../src/strategies/irs/EarthLpStaking.sol";
import "../src/strategies/irs/CommonStrat.sol";
import "../src/strategies/common/interfaces/IStrategy.sol";
import "../src/vaults/EarthAutoCompoundingVaultPublic.sol";

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
        uint privateKey = vm.envUint("PRIVATE_KEY");
        address acc = vm.addr(privateKey);
        console.log("Account", acc);

        vm.startBroadcast(privateKey);
        //deploying the AutoCompounding vault
        EarthAutoCompoundingVaultPublic vault = new EarthAutoCompoundingVaultPublic(
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

/*   Account 0xFaBcc4b22fFEa25D01AC23c5d225D7B27CB1B6B8
  0x23b3022BD63E6F7FE9aF5371f3AFC981449930af
  ParentVault
  0x1E8D2C1efbF80e7BCaf2347AfA4F559756DE90B3
  ParentStrategy
  0x23b3022BD63E6F7FE9aF5371f3AFC981449930af

  //https://zetachain-athens-evm.blockpi.network/v1/rpc/public rpc endpoint for zeta testnet
*/

//forge script script/EarthLpStaking.s.sol:EarthLpStakingScript --rpc-url https://zetachain-athens-evm.blockpi.network/v1/rpc/public --broadcast -vvv --legacy --slow
