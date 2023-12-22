// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../src/strategies/staking/EarthLpStaking.sol";
import "../src/strategies/staking/CommonStrat.sol";
import "../src/strategies/common/interfaces/IStrategy.sol";
import "../src/vaults/RiveraAutoCompoundingVaultV2Public.sol";

contract EarthLpStakingScript is Script {
    address _stake = 0x5f247B216E46fD86A09dfAB377d9DBe62E9dECDA; //ACE-WZETA
    uint256 _poolId = 2;
    address _chef = 0xB8775999484624E8545379981576a66083616Bf1; //Randome address for now
    address _router = 0xDd0840118bF9CCCc6d67b2944ddDfbdb995955FD; // fusionx v2
    address _reward = 0x09Bc4E0D864854c6aFB6eB9A9cdF58aC190D0dF9; //Randome address for now
    address _lp0Token = 0x09Bc4E0D864854c6aFB6eB9A9cdF58aC190D0dF9; //usdc mantle
    address _lp1Token = 0xdEAddEaDdeadDEadDEADDEAddEADDEAddead1111; //wEth mantle
    address _factory = 0xE5020961fA51ffd3662CDf307dEf18F9a87Cce7c; //fusionx v2 factory

    address riveraVault = 0x5f247B216E46fD86A09dfAB377d9DBe62E9dECDA; // rivera usdc-weth vault

    // fees params

    address protocol;
    address partner;
    uint256 partnerFee;
    uint256 protocolFee;
    uint256 fundManagerFee;
    uint256 withdrawFee;
    uint256 feeDecimals;



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
            riveraVault,
            _rewardToLp0Route,
            _rewardToLp1Route,
            _lp0Token,
            _factory
        );


        EarthFeesParams memory feesParams = EarthFeesParams(
            protocol,
            partner,
            partnerFee,
            protocolFee,
            fundManagerFee,
            feeDecimals,
            withdrawFee
            );

        //Deploying the parantStrategy

        EarthLpStaking parentStrategy = new EarthLpStaking(
            earthLpStakingParams,
            _commonAddresses,
            feesParams
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
  0xE1B0Fe3af433a220b0868b4adE41Bd672B0a7562
  ParentVault
  0x78b3b52617e275f2a8507aD70E0eCa326F17b5B8
  ParentStrategy
  0xE1B0Fe3af433a220b0868b4adE41Bd672B0a7562

*/

// anvil --fork-url https://node.rivera.money/ --mnemonic "disorder pretty oblige witness close face food stumble name material couch planet"

//forge script script/EarthLpStaking.s.sol:EarthLpStakingScript --rpc-url http://127.0.0.1:8545/ --broadcast -vvv --legacy --slow
