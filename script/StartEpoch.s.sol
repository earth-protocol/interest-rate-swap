pragma solidity ^0.8.4;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../src/strategies/common/interfaces/IStrategy.sol";
import "../src/vaults/RiveraAutoCompoundingVaultV2Public.sol";
import "@openzeppelin/token/ERC20/IERC20.sol";

contract StartEpoch is Script {
    address _vaultParent = 0x33e47Fe37FeF6AB1d83e54AAD6c8D01C048171E1;
    address _vaultAsset0 = 0x4dCAdE22009eb0354cF44DbB777131CA2bFd3dcb;
    address _vaultAsset1 = 0x821F88928C950F638a94b74cD44A1b676D51a310;

    function run() public {
        // string memory seedPhrase = vm.readFile(".secret");
        // uint256 ownerPrivateKey = vm.deriveKey(seedPhrase, 0);
        // address owner = vm.addr(ownerPrivateKey);
        // vm.startBroadcast(ownerPrivateKey);

        uint privateKeyOwn = 0xfc2f8cc0abd2d9d05229c8942e8a529d1ba9265eb1b4c720c03f7d074615afbb;
        uint userPrivateKey = 0xd68f5d8c457f5675592a7d486aeb7de973a76b12e02430e7dc01956b27af0370;
        address user = vm.addr(userPrivateKey);
        address owner = vm.addr(privateKeyOwn);
        console2.log("user", user);

        vm.startBroadcast(privateKeyOwn);
        ///start epoch
        IStrategy parentStrategy = RiveraAutoCompoundingVaultV2Public(_vaultParent)
            .strategy();
        IStrategy asset0Strategy = RiveraAutoCompoundingVaultV2Public(_vaultAsset0)
            .strategy();
        IStrategy asset1Strategy = RiveraAutoCompoundingVaultV2Public(_vaultAsset1)
            .strategy();
        address[] memory strategiesChild = new address[](2);
        strategiesChild[0] = address(asset0Strategy);
        strategiesChild[1] = address(asset1Strategy);
        parentStrategy.startEpoch(strategiesChild);
        vm.stopBroadcast();
    }
}

// forge script script/StartEpoch.s.sol:StartEpoch --rpc-url https://zetachain-athens-evm.blockpi.network/v1/rpc/public --broadcast -vvv --legacy --slow
