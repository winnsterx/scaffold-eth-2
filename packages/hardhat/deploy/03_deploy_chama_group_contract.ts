import { Contract } from "ethers";
import { DeployFunction } from "hardhat-deploy/types";
import { HardhatRuntimeEnvironment } from "hardhat/types";

/**
 * Deploys a contract named "ChamaGroup" using the deployer account and
 * constructor arguments set to the deployer address
 *
 * @param hre HardhatRuntimeEnvironment object.
 */
const deployChamaGroup: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  /*
    On localhost, the deployer account is the one that comes with Hardhat, which is already funded.

    When deploying to live networks (e.g `yarn deploy --network goerli`), the deployer account
    should have sufficient balance to pay for the gas fees for contract creation.

    You can generate a random account with `yarn generate` which will fill DEPLOYER_PRIVATE_KEY
    with a random private key in the .env file (then used on hardhat.config.ts)
    You can run the `yarn account` command to check your balance in every network.
  */
  const { deployer } = await hre.getNamedAccounts();
  const { deploy, get } = hre.deployments;

  const rolesDeployment = await get("Roles");
  const hitchensUnorderedKeySetDeployment = await get("HitchensUnorderedKeySet");

  await deploy("ChamaGroup", {
    from: deployer,
    log: true,
    autoMine: true,
    libraries: {
      Roles: rolesDeployment.address,
      HitchensUnorderedKeySet: hitchensUnorderedKeySetDeployment.address,
    },
  });

  console.log("ChamaGroup contract deployed!");

  const chamaGroupContract = await hre.ethers.getContract<Contract>("ChamaGroup", deployer);
  console.log("ChamaGroup contract address:", chamaGroupContract.address);
};

export default deployChamaGroup;

deployChamaGroup.tags = ["ChamaGroup"];
deployChamaGroup.dependencies = ["Roles", "HitchensUnorderedKeySet"];
