pragma solidity ^0.8.4;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "@earth/strategies/common/interfaces/IStrategy.sol";
import "@earth/vaults/EarthAutoCompoundingVaultPublic.sol";
import "@openzeppelin/token/ERC20/IERC20.sol";

contract StartEpoch is Script {
    address _vaultParent = 0x1E8D2C1efbF80e7BCaf2347AfA4F559756DE90B3;
    address _vaultAsset0 = 0x7F0F5AAF002Fd32b964a2D77Ce21C9F2F9e2e18E;
    address _vaultAsset1 = 0x0DAb8d11ed0DA724FE6AaFdd0527b78E425eD507;

    function run() public {
        // string memory seedPhrase = vm.readFile(".secret");
        // uint256 ownerPrivateKey = vm.deriveKey(seedPhrase, 0);
        // address owner = vm.addr(ownerPrivateKey);
        // vm.startBroadcast(ownerPrivateKey);

        uint privateKeyOwn = vm.envUint("OWNER_KEY");
        uint userPrivateKey = vm.envUint("PRIVATE_KEY");
        address user = vm.addr(userPrivateKey);
        address owner = vm.addr(privateKeyOwn);
        console2.log("user", user);

        vm.startBroadcast(privateKeyOwn);
        ///start epoch
        IStrategy parentStrategy = EarthAutoCompoundingVaultPublic(_vaultParent)
            .strategy();
        IStrategy asset0Strategy = EarthAutoCompoundingVaultPublic(_vaultAsset0)
            .strategy();
        IStrategy asset1Strategy = EarthAutoCompoundingVaultPublic(_vaultAsset1)
            .strategy();
        address[] memory strategiesChild = new address[](2);
        strategiesChild[0] = address(asset0Strategy);
        strategiesChild[1] = address(asset1Strategy);
        parentStrategy.startEpoch(strategiesChild);
        vm.stopBroadcast();
    }
}

// forge script script/StartEpoch.s.sol:StartEpoch --rpc-url https://zetachain-athens-evm.blockpi.network/v1/rpc/public --broadcast -vvv --legacy --slow
