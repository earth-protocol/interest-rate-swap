pragma solidity ^0.8.4;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "../src/strategies/common/interfaces/IStrategy.sol";
import "../src/vaults/RiveraAutoCompoundingVaultV2Public.sol";
import "@openzeppelin/token/ERC20/IERC20.sol";

contract Deposit is Script {
    address _vaultParent = 0x33e47Fe37FeF6AB1d83e54AAD6c8D01C048171E1; //Parent Valut
    address _parentStrat = 0x8a1b62c438B7b1d73A7a323C6b685fEc021610aC; //Parent Strat
    address _vaultAsset0 = 0x4dCAdE22009eb0354cF44DbB777131CA2bFd3dcb; //WZETA Vault
    address _vaultAsset1 = 0x821F88928C950F638a94b74cD44A1b676D51a310; //ACE Vault
    address _lp0Token = 0x0A67e05a87b87f210277542267ABD87F9D29CB67; //WZETA ZetaTest
    address _lp1Token = 0x1320f70ab72E867d3e54840929659fF75cA88210; //ACE Token
    address _stake = 0xB8775999484624E8545379981576a66083616Bf1; //WZETA-ACE Lp

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
        IERC20(_lp1Token).approve(_vaultAsset1, depositAmountAsset1);
        IERC20(_stake).approve(_vaultParent, depositAmountParent);
        // IStrategy(_parentStrat).unpause();

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

// forge script script/Deposit.s.sol:Deposit --rpc-url https://zetachain-athens-evm.blockpi.network/v1/rpc/public --broadcast -vvv --legacy --slow
