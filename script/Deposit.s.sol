pragma solidity ^0.8.4;

import "forge-std/Script.sol";
import "forge-std/console2.sol";
import "@earth/strategies/common/interfaces/IStrategy.sol";
import "@earth/vaults/EarthAutoCompoundingVaultPublic.sol";
import "@openzeppelin/token/ERC20/IERC20.sol";

contract Deposit is Script {
    address _vaultParent = 0x1E8D2C1efbF80e7BCaf2347AfA4F559756DE90B3; //Parent Valut
    address _parentStrat = 0x23b3022BD63E6F7FE9aF5371f3AFC981449930af; //Parent Strat
    address _vaultAsset0 = 0x7F0F5AAF002Fd32b964a2D77Ce21C9F2F9e2e18E; //WZETA Vault
    address _vaultAsset1 = 0x0DAb8d11ed0DA724FE6AaFdd0527b78E425eD507; //ACE Vault
    address _lp0Token = 0x0A67e05a87b87f210277542267ABD87F9D29CB67; //WZETA ZetaTest
    address _lp1Token = 0x1320f70ab72E867d3e54840929659fF75cA88210; //ACE Token
    address _stake = 0xB8775999484624E8545379981576a66083616Bf1; //WZETA-ACE Lp

    function run() public {
        // string memory seedPhrase = vm.readFile(".secret");
        // uint256 ownerPrivateKey = vm.deriveKey(seedPhrase, 0);
        // uint256 userPrivateKey = vm.deriveKey(seedPhrase, 1);
        // address owner = vm.addr(ownerPrivateKey);
        // address user = vm.addr(userPrivateKey);

        uint privateKeyOwn = vm.envUint("OWNER_KEY");
        uint userPrivateKey = vm.envUint("PRIVATE_KEY");
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

        EarthAutoCompoundingVaultPublic(_vaultParent).deposit(
            depositAmountParent,
            user
        );
        EarthAutoCompoundingVaultPublic(_vaultAsset0).deposit(
            depositAmountAsset0,
            user
        );
        EarthAutoCompoundingVaultPublic(_vaultAsset1).deposit(
            depositAmountAsset1,
            user
        );
        vm.stopBroadcast();
    }
}

// forge script script/Deposit.s.sol:Deposit --rpc-url https://zetachain-athens-evm.blockpi.network/v1/rpc/public --broadcast -vvv --legacy --slow
