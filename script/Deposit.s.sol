pragma solidity ^0.8.4;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../src/strategies/common/interfaces/IStrategy.sol";
import "../src/vaults/RiveraAutoCompoundingVaultV2Public.sol";
import "@openzeppelin/token/ERC20/IERC20.sol";

contract Deposit is Script {
    address _vaultParent = 0x78b3b52617e275f2a8507aD70E0eCa326F17b5B8; //Parent Valut
    address _parentStrat = 0xE1B0Fe3af433a220b0868b4adE41Bd672B0a7562; //Parent Strat
    address _vaultAsset0 = 0x18207ac1041EFd5B733Ba0EbeA1285a8ee016056; //WZETA Vault
    address _vaultAsset1 = 0x0cE9E05f72Ae84f15a89Ca3BDA949422Bf459a1b; //ACE Vault
    address _lp0Token = 0x09Bc4E0D864854c6aFB6eB9A9cdF58aC190D0dF9; //WZETA ZetaTest
    address _lp1Token = 0xdEAddEaDdeadDEadDEADDEAddEADDEAddead1111; //ACE Token
    address _stake = 0x5f247B216E46fD86A09dfAB377d9DBe62E9dECDA; //WZETA-ACE Lp

    function run() public {
        // string memory seedPhrase = vm.readFile(".secret");
        // uint256 ownerPrivateKey = vm.deriveKey(seedPhrase, 0);
        // uint256 userPrivateKey = vm.deriveKey(seedPhrase, 1);
        // address owner = vm.addr(ownerPrivateKey);
        // address user = vm.addr(userPrivateKey);

        uint privateKeyOwn = 0xd68f5d8c457f5675592a7d486aeb7de973a76b12e02430e7dc01956b27af0370;
        uint userPrivateKey = 0xd68f5d8c457f5675592a7d486aeb7de973a76b12e02430e7dc01956b27af0370;
        address user = vm.addr(userPrivateKey);
        address owner = vm.addr(privateKeyOwn);
        console2.log("user", user);

        uint256 depositAmountParent = IERC20(_stake).balanceOf(user) / 4;
        uint256 depositAmountAsset0 = IERC20(_lp0Token).balanceOf(user) / 4;
        uint256 depositAmountAsset1 = IERC20(_lp1Token).balanceOf(user) / 4;

        vm.startBroadcast(userPrivateKey);
        IERC20(_lp0Token).approve(_vaultAsset0, depositAmountAsset0);
        IERC20(_lp0Token).approve(_stake, depositAmountAsset0);
        IERC20(_lp1Token).approve(_vaultAsset1, depositAmountAsset1);
        IERC20(_stake).approve(_vaultParent, depositAmountParent);
        // IStrategy(_parentStrat).unpause();
         
        // RiveraAutoCompoundingVaultV2Public(_stake).deposit(
        //     depositAmountAsset0,
        //     user
        // ); 
        
        RiveraAutoCompoundingVaultV2Public(_vaultParent).deposit(
            depositAmountParent,
            user
        );
        RiveraAutoCompoundingVaultV2Public(_vaultAsset0).deposit(
            depositAmountAsset0,
            user
        );
        RiveraAutoCompoundingVaultV2Public(_vaultAsset1).deposit(
            depositAmountAsset1,
            user
        );
        vm.stopBroadcast();
    }
}

// forge script script/Deposit.s.sol:Deposit --rpc-url http://127.0.0.1:8545/  --broadcast -vvv --legacy --slow
