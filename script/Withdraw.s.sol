pragma solidity ^0.8.4;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../src/strategies/common/interfaces/IStrategy.sol";
import "../src/vaults/RiveraAutoCompoundingVaultV2Public.sol";
import "@openzeppelin/token/ERC20/IERC20.sol";

contract Withdraw is Script {
    address _vaultParent = 0x78b3b52617e275f2a8507aD70E0eCa326F17b5B8;
    address _vaultAsset0 = 0x18207ac1041EFd5B733Ba0EbeA1285a8ee016056;
    address _vaultAsset1 = 0x0cE9E05f72Ae84f15a89Ca3BDA949422Bf459a1b;

    function run() public {
        // string memory seedPhrase = vm.readFile(".secret");
        // uint256 ownerPrivateKey = vm.deriveKey(seedPhrase, 0);
        // uint256 userPrivateKey = vm.deriveKey(seedPhrase, 1);
        // address owner = vm.addr(ownerPrivateKey);
        // address user = vm.addr(userPrivateKey);
        // console2.log("user", user);
        uint privateKeyOwn = 0xd68f5d8c457f5675592a7d486aeb7de973a76b12e02430e7dc01956b27af0370;
        uint userPrivateKey = 0xd68f5d8c457f5675592a7d486aeb7de973a76b12e02430e7dc01956b27af0370;
        address user = vm.addr(userPrivateKey);
        address owner = vm.addr(privateKeyOwn);
        console2.log("user", user);

        uint256 withdrawAmountParent = RiveraAutoCompoundingVaultV2Public(
            _vaultParent
        ).maxWithdraw(user);
        uint256 withdrawAmountAsset0 = RiveraAutoCompoundingVaultV2Public(
            _vaultAsset0
        ).maxWithdraw(user);
        uint256 withdrawAmountAsset1 = RiveraAutoCompoundingVaultV2Public(
            _vaultAsset1
        ).maxWithdraw(user);
        console2.log(withdrawAmountParent);
        console2.log(withdrawAmountAsset0);
        console2.log(withdrawAmountAsset1);

        vm.startBroadcast(userPrivateKey);

        RiveraAutoCompoundingVaultV2Public(_vaultParent).withdraw(
            withdrawAmountParent,
            user,
            user
        );
        RiveraAutoCompoundingVaultV2Public(_vaultAsset0).withdraw(
            withdrawAmountAsset0,
            user,
            user
        );
        RiveraAutoCompoundingVaultV2Public(_vaultAsset1).withdraw(
            withdrawAmountAsset1,
            user,
            user
        );
        vm.stopBroadcast();
    }
}
// forge script script/Withdraw.s.sol:Withdraw --rpc-url http://127.0.0.1:8545/ --broadcast -vvv --legacy --slow
