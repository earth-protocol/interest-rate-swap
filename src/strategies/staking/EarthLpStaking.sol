pragma solidity ^0.8.0;

import "@openzeppelin/token/ERC20/IERC20.sol";
import "@openzeppelin/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/access/Ownable.sol";
import "@openzeppelin/security/Pausable.sol";
import "@openzeppelin/security/ReentrancyGuard.sol";

import "@pancakeswap-v2-exchange-protocol/interfaces/IPancakeRouter02.sol";
import "@pancakeswap-v2-core/interfaces/IPancakePair.sol";
import "./interfaces/ICommonStrat.sol";
import "./interfaces/IMasterChef.sol";
import "./interfaces/IPancakeFactory.sol";
import "./interfaces/IRivera.sol";
import "../common/AbstractStrategy.sol";
import "../utils/StringUtils.sol";

struct EarthLpStakingParams {
    address stake;
    uint256 poolId;
    address chef;
    address riveraVault;
    address[] rewardToLp0Route;
    address[] rewardToLp1Route;
    address baseCurrency;
    address factory;
}

struct ComonStratData {
    uint256 stakedInNative;
    uint256 returnAmountNative;
}

struct EarthFeesParams {
    address protocol;
    address partner;
    uint256 protocolFee;
    uint256 partnerFee;
    uint256 fundManagerFee;
    uint256 feeDecimals;
    uint256 withdrawFee;
}



contract EarthLpStaking is AbstractStrategy, ReentrancyGuard {
    using SafeERC20 for IERC20;

    //fixed vaults map
    mapping(address => ComonStratData) public assetStrategyMap;
    address[] public assetStrategies;

    uint256 eachLevAmountInBase;
    bool public epochRunning = false;

    address public baseCurrency;
    address public factory;

    // Tokens used
    address public reward;
    address public stake;
    address public lpToken0;
    address public lpToken1;

   // rivera Vaults

   address public riveraVault;

    //fees parameters

    address public protocol;
    address public partner;
    uint256 public protocolFee;
    uint256 public partnerFee;
    uint256 public fundManagerFee;
    uint256 public feeDecimals;
    uint256 public withdrawFee;


    // Third party contracts
    address public chef;
    uint256 public poolId;

    uint256 public lastHarvest;
    string public pendingRewardsFunctionName;

    // Routes
    address[] public rewardToLp0Route;
    address[] public rewardToLp1Route;

    //Events
    event StratHarvest(
        address indexed harvester,
        uint256 stakeHarvested,
        uint256 tvl
    );
    event Deposit(uint256 tvl, uint256 amount);
    event Withdraw(uint256 tvl, uint256 amount);

    ///@dev
    ///@param _earthLpStakingParams: Has the cake pool specific params
    ///@param _commonAddresses: Has addresses common to all vaults, check Rivera Fee manager for more info
    constructor(
        EarthLpStakingParams memory _earthLpStakingParams,
        CommonAddresses memory _commonAddresses,
        EarthFeesParams memory _fessPrarms

    ) AbstractStrategy(_commonAddresses) {
        stake = _earthLpStakingParams.stake;
        poolId = _earthLpStakingParams.poolId;
        chef = _earthLpStakingParams.chef;
        baseCurrency = _earthLpStakingParams.baseCurrency;
        factory = _earthLpStakingParams.factory;
        riveraVault = _earthLpStakingParams.riveraVault;

        protocol = _fessPrarms.protocol;
        partner = _fessPrarms.partner;
        protocolFee = _fessPrarms.protocolFee;
        partnerFee = _fessPrarms.partnerFee;
        fundManagerFee = _fessPrarms.fundManagerFee;
        withdrawFee = _fessPrarms.withdrawFee;
        feeDecimals = _fessPrarms.feeDecimals;

        address[] memory _rewardToLp0Route = _earthLpStakingParams
            .rewardToLp0Route;
        address[] memory _rewardToLp1Route = _earthLpStakingParams
            .rewardToLp1Route;

        reward = _rewardToLp0Route[0];

        // setup lp routing
        lpToken0 = _rewardToLp0Route[1];
        require(_rewardToLp0Route[0] == reward, "!rewardToLp0Route");
        require(
            _rewardToLp0Route[_rewardToLp0Route.length - 1] == lpToken0,
            "!rewardToLp0Route"
        );
        rewardToLp0Route = _rewardToLp0Route;

        lpToken1 = _rewardToLp1Route[1];
        require(_rewardToLp1Route[0] == reward, "!rewardToLp1Route");
        require(
            _rewardToLp1Route[_rewardToLp1Route.length - 1] == lpToken1,
            "!rewardToLp1Route"
        );
        rewardToLp1Route = _rewardToLp1Route;

        _giveAllowances();
    }

    // puts the funds to work
    function deposit() public {
        onlyVault();
        // require(!epochRunning);
        if (epochRunning == true) revert();
        _deposit();
    }

    function _deposit() internal whenNotPaused nonReentrant {
        //Entire LP balance of the strategy contract address is deployed to the farm to earn CAKE
        uint256 stakeBal = IERC20(stake).balanceOf(address(this));

        if (stakeBal > 0) {
            // IMasterChef(chef).deposit(poolId, stakeBal);
            emit Deposit(balanceOf(), stakeBal);
        }
    }

    function withdraw(uint256 _amount) external nonReentrant {
        onlyVault();
        if (epochRunning == true) revert();
        //Pretty Straight forward almost same as AAVE strategy
        uint256 stakeBal = IERC20(stake).balanceOf(address(this));

        if (stakeBal < _amount) {
            // IMasterChef(chef).withdraw(poolId, _amount - stakeBal);
            stakeBal = IERC20(stake).balanceOf(address(this));
        }

        if (stakeBal > _amount) {
            stakeBal = _amount;
        }

        IERC20(stake).safeTransfer(vault, stakeBal);

        emit Withdraw(balanceOf(), stakeBal);
    }

    function beforeDeposit() external virtual {}

    function harvest() external virtual {
        _harvest();
    }

    function managerHarvest() external {
        onlyManager();
        _harvest();
    }

    // compounds earnings and charges performance fee
    function _harvest() internal whenNotPaused {
        IMasterChef(chef).deposit(poolId, 0); //Deopsiting 0 amount will not make any deposit but it will transfer the CAKE rewards owed to the strategy.
        //This essentially harvests the yeild from CAKE.
        uint256 rewardBal = IERC20(reward).balanceOf(address(this)); //reward tokens will be CAKE. Cake balance of this strategy address will be zero before harvest.
        if (rewardBal > 0) {
            addLiquidity();
            uint256 stakeHarvested = balanceOfStake();
            _deposit(); //Deposits the LP tokens from harvest

            lastHarvest = block.timestamp;
            emit StratHarvest(msg.sender, stakeHarvested, balanceOf());
        }
    }

    // Adds liquidity to AMM and gets more LP tokens.
    function addLiquidity() internal {
        //Should convert the CAKE tokens harvested into WOM and BUSD tokens and depost it in the liquidity pool. Get the LP tokens and stake it back to earn more CAKE.
        uint256 rewardHalf = IERC20(reward).balanceOf(address(this)) / 2; //It says IUniswap here which might be inaccurate. If the address is that of pancake swap and method signatures match then the call should be made correctly.
        if (lpToken0 != reward) {
            //Using Uniswap to convert half of the CAKE tokens into Liquidity Pair token 0
            IPancakeRouter02(router).swapExactTokensForTokens(
                rewardHalf,
                0,
                rewardToLp0Route,
                address(this),
                block.timestamp
            );
        }

        if (lpToken1 != reward) {
            //Using Uniswap to convert half of the CAKE tokens into Liquidity Pair token 1
            IPancakeRouter02(router).swapExactTokensForTokens(
                rewardHalf,
                0,
                rewardToLp1Route,
                address(this),
                block.timestamp
            );
        }
        _addLiquidity();
    }

    function _addLiquidity() internal {
        uint256 lp0Bal = IERC20(lpToken0).balanceOf(address(this));
     
        IRivera(riveraVault).deposit(lp0Bal, address(this));
    }

    function startEpoch(address[] memory _strategies) public {
        _checkOwner();
        require(_strategies.length == 2);
        if (epochRunning == true) revert();
        assetStrategies = _strategies;
        uint256 deposits0InBase = tokenAToTokenBConversion(
            ICommonStrat(_strategies[0]).asset(),
            baseCurrency,
            ICommonStrat(_strategies[0]).balanceOfAsset()
        ); ///strategy 0 total deposits in base token

        uint256 deposits1InBase = tokenAToTokenBConversion(
            ICommonStrat(_strategies[1]).asset(),
            baseCurrency,
            ICommonStrat(_strategies[1]).balanceOfAsset()
        ); ///strategy 1 total deposits in base token

        eachLevAmountInBase = deposits0InBase <= deposits1InBase
            ? deposits0InBase
            : deposits1InBase; ///Amout to be taken from eact strategy in base token

        uint256 asset0AmountInNative = tokenAToTokenBConversion(
            baseCurrency,
            ICommonStrat(_strategies[0]).asset(),
            eachLevAmountInBase
        );

        uint256 asset1AmountInNative = tokenAToTokenBConversion(
            baseCurrency,
            ICommonStrat(_strategies[1]).asset(),
            eachLevAmountInBase
        ); ///Amout to be taken from  strategy 1 in their asset token

        IERC20(ICommonStrat(_strategies[0]).asset()).safeTransferFrom(
            _strategies[0],
            address(this),
            asset0AmountInNative
        );
        IERC20(ICommonStrat(_strategies[1]).asset()).safeTransferFrom(
            _strategies[1],
            address(this),
            asset1AmountInNative
        );
        assetStrategyMap[_strategies[0]] = ComonStratData(
            asset0AmountInNative,
            _calculatFixedReturnNative(asset0AmountInNative, _strategies[0])
        );
        assetStrategyMap[_strategies[1]] = ComonStratData(
            asset1AmountInNative,
            _calculatFixedReturnNative(asset1AmountInNative, _strategies[1])
        );

        address asset0 = ICommonStrat(_strategies[0]).asset();
        address asset1 = ICommonStrat(_strategies[1]).asset();
        
        address[] memory _asset1Toasset0Route = new address[](2);
        _asset1Toasset0Route[0] = asset1;
        _asset1Toasset0Route[1] = asset0;
        address[] memory _asset0Toasset1Route = new address[](2);
        _asset0Toasset1Route[0] = asset0;
        _asset0Toasset1Route[1] = asset1;

        // Convert token1 to token0(dai)
        uint256 conv1 = IERC20(asset1).balanceOf(address(this));
        IPancakeRouter02(router).swapExactTokensForTokens(
            conv1,
            0,
            _asset1Toasset0Route,
            address(this),
            block.timestamp
        );



        _addLiquidity();
        // _deposit();
        epochRunning = true;
    }

    function endEpoch() public {
        _checkOwner();
        if (epochRunning == false) revert();
        // _harvest();
        address[] memory assetStrategiesArr = assetStrategies;
        address asset0 = ICommonStrat(assetStrategiesArr[0]).asset();
        address asset1 = ICommonStrat(assetStrategiesArr[1]).asset();
       
        uint256 lpBal = IRivera(riveraVault).balanceOf(address(this));
        uint amDai = IRivera(riveraVault).redeem(
            lpBal,
            address(this),
            address(this)
        );

        address[] memory _asset1Toasset0Route = new address[](2);
        _asset1Toasset0Route[0] = asset1;
        _asset1Toasset0Route[1] = asset0;
        address[] memory _asset0Toasset1Route = new address[](2);
        _asset0Toasset1Route[0] = asset0;
        _asset0Toasset1Route[1] = asset1;

        uint256 balanceofAsset0 = IERC20(asset0).balanceOf(address(this));

        uint256 rtrnAmntStart1Inasset1 = assetStrategyMap[assetStrategiesArr[1]]
            .returnAmountNative;

        uint256 rtrnAmntStart1Inasset0 = tokenAToTokenBConversion(
            asset1,
            asset0,
            rtrnAmntStart1Inasset1
        );


        uint256 rtrnAmntStart0Inasset0 = assetStrategyMap[assetStrategiesArr[0]]
            .returnAmountNative;


        //convert rtrnAmntStart1Inasset0 of asset0 tokens to asset1 to transfer to strat1
        IPancakeRouter02(router).swapExactTokensForTokens(
            rtrnAmntStart1Inasset0,
            0,
            _asset0Toasset1Route,
            address(this),
            block.timestamp
        );  


        uint256 tbal = IERC20(asset1).balanceOf(address(this));
        IERC20(asset1).safeTransfer(assetStrategiesArr[1], tbal);
        IERC20(asset0).safeTransfer(
            assetStrategiesArr[0],
            rtrnAmntStart0Inasset0
        );  
    

       
        _addLiquidity();
        
        delete assetStrategyMap[assetStrategiesArr[0]];
        delete assetStrategyMap[assetStrategiesArr[1]];
        delete assetStrategies;
        epochRunning = false;
    }

    function _swapTokens(uint256 amountIn, address[] memory path) internal {
        IPancakeRouter02(router).swapExactTokensForTokens(
            amountIn,
            0,
            path,
            address(this),
            block.timestamp
        );
    }


    function _calculatFixedReturnNative(
        uint256 amount,
        address strategy
    ) internal returns (uint256) {
        return
            amount +
            ((amount * ICommonStrat(strategy).interest()) /
                ICommonStrat(strategy).interestDecimals());
    }

    function arrangeTokens(
        address tokenA,
        address tokenB
    ) public pure returns (address, address) {
        return tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    }

    function tokenAToTokenBConversion(
        address tokenA,
        address tokenB,
        uint256 amount
    ) public view returns (uint256) {
        if (tokenA == tokenB) {
            return amount;
        }
        address lpAddress = IPancakeFactory(factory).getPair(tokenA, tokenB);
        (uint112 _reserve0, uint112 _reserve1, ) = IPancakePair(lpAddress)
            .getReserves();
        (address token0, address token1) = arrangeTokens(tokenA, tokenB);
        return
            token0 == tokenA
                ? ((amount * _reserve1) / _reserve0)
                : ((amount * _reserve0) / _reserve1);
    }

    function baseTokenToLpTokenConversion(
        address lpToken,
        uint256 amount
    ) public view returns (uint256 lpTokenAmount) {
        (uint112 _reserve0, uint112 _reserve1, ) = IPancakePair(lpToken)
            .getReserves();
        address token0 = IPancakePair(lpToken).token0();
        address token1 = IPancakePair(lpToken).token1();
        uint256 reserve0InBaseToken = tokenAToTokenBConversion(
            token0,
            baseCurrency,
            _reserve0
        );
        uint256 reserve1InBaseToken = tokenAToTokenBConversion(
            token1,
            baseCurrency,
            _reserve1
        );

        uint256 lpTotalSuppy = IPancakePair(lpToken).totalSupply();
        return ((lpTotalSuppy * amount) /
            (reserve0InBaseToken + reserve1InBaseToken));
    }

    function tokenToLpTokenConversion(
        address token,
        uint256 amount
    ) public view returns (uint256) {
        uint256 amountInBase = tokenAToTokenBConversion(
            token,
            baseCurrency,
            amount
        );
        return baseTokenToLpTokenConversion(stake, amountInBase);
    }

    function _calculatFixedReturnLp() internal view returns (uint256) {
        uint256 fixedReturnInLp;
        for (uint256 index = 0; index < assetStrategies.length; index++) {
            fixedReturnInLp =
                fixedReturnInLp +
                tokenToLpTokenConversion(
                    ICommonStrat(assetStrategies[index]).asset(),
                    assetStrategyMap[assetStrategies[index]].returnAmountNative
                );
        }
        return fixedReturnInLp;
    }


    function _calculatFixedReturnRivera() internal view returns(uint256){
        uint256 fixedReturns;
         
         for(uint256 index = 0; index < assetStrategies.length; index++){
            fixedReturns = fixedReturns + tokenAToTokenBConversion(
            ICommonStrat(assetStrategies[index]).asset(),lpToken0,assetStrategyMap[assetStrategies[index]].returnAmountNative
            );
         }
        
        
        return IRivera(riveraVault).convertToShares(fixedReturns);

        // return fixedReturns;
    }

    // calculate the total underlaying 'stake' held by the strat.
    function balanceOf() public view returns (uint256) {
        return balanceOfStake() - _calculatFixedReturnRivera();
    }

    // it calculates how much 'stake' this contract holds.
    function balanceOfStake() public view returns (uint256) {
        return IERC20(stake).balanceOf(address(this));
    }


    function balanceOfRivera() public view returns(uint256){
        uint256 balR = IRivera(riveraVault).balanceOf(address(this));
    }

     function _chargeFees(address _token) internal {
        uint256 tokenBal = IERC20(_token).balanceOf(address(this));

        uint256 protocolFeeAmount = (tokenBal * protocolFee) / feeDecimals;
        IERC20(_token).safeTransfer(manager, protocolFeeAmount);

        uint256 fundManagerFeeAmount = (tokenBal * fundManagerFee) /
            feeDecimals;
        IERC20(_token).safeTransfer(owner(), fundManagerFeeAmount);

        uint256 partnerFeeAmount = (tokenBal * partnerFee) / feeDecimals;
        IERC20(_token).safeTransfer(partner, partnerFeeAmount);

        uint256 wFee = (tokenBal * withdrawFee) / feeDecimals;
        IERC20(_token).transfer(protocol, wFee);
    }


    // function setPendingRewardsFunctionName(
    //     string calldata _pendingRewardsFunctionName
    // ) external {
    //     onlyManager();
    //     //Interesting! function name that has to be used itself can be treated as an arguement
    //     pendingRewardsFunctionName = _pendingRewardsFunctionName;
    // }

    // // returns rewards unharvested
    // function rewardsAvailable() public view returns (uint256) {
    //     //Returns the rewards available to the strategy contract from the pool
    //     string memory signature = StringUtils.concat(
    //         pendingRewardsFunctionName,
    //         "(uint256,address)"
    //     );
    //     bytes memory result = Address.functionStaticCall(
    //         chef,
    //         abi.encodeWithSignature(signature, poolId, address(this))
    //     );
    //     return abi.decode(result, (uint256));
    // }

    // called as part of strat migration. Sends all the available funds back to the vault.
    function retireStrat() external {
        onlyVault();
        uint256 stakeBal = IERC20(stake).balanceOf(address(this));
        IERC20(stake).safeTransfer(vault, stakeBal);
    }

    // pauses deposits and withdraws all funds from third party systems.
    function panic() public {
        onlyManager();
        pause();
        uint256 tbal = balanceOfRivera();
        IRivera(riveraVault).redeem(tbal,address(this),address(this));
    }

    function pause() public {
        onlyManager();
        _pause();

        _removeAllowances();
    }

    function unpause() external {
        onlyManager();
        _unpause();

        _giveAllowances();

        _deposit();
    }

    function _giveAllowances() internal {
        IERC20(stake).safeApprove(chef, type(uint256).max);
        IERC20(reward).safeApprove(router, type(uint256).max);

        IERC20(lpToken0).safeApprove(router, 0);
        IERC20(lpToken0).safeApprove(router, type(uint256).max);

        IERC20(lpToken1).safeApprove(router, 0);
        IERC20(lpToken1).safeApprove(router, type(uint256).max);


        IERC20(reward).safeApprove(riveraVault, type(uint256).max);

        IERC20(lpToken0).safeApprove(riveraVault, 0);
        IERC20(lpToken0).safeApprove(riveraVault, type(uint256).max);

        IERC20(lpToken1).safeApprove(riveraVault, 0);
        IERC20(lpToken1).safeApprove(riveraVault, type(uint256).max);
    }

    function _removeAllowances() internal {
        IERC20(stake).safeApprove(chef, 0);
        IERC20(reward).safeApprove(router, 0);
        IERC20(lpToken0).safeApprove(router, 0);
        IERC20(lpToken1).safeApprove(router, 0);
    }

    function rewardToLp0() external view returns (address[] memory) {
        return rewardToLp0Route;
    }

    function rewardToLp1() external view returns (address[] memory) {
        return rewardToLp1Route;
    }
}
