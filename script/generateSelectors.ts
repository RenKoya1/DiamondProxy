import { ethers } from "ethers";
import * as path from "path";

const args = process.argv.slice(2);

if (args.length !== 1) {
  console.log(`please supply the correct parameters:
    facetName
  `);
  process.exit(1);
}

async function printSelectors(
  contractName: string,
  artifactFolderPath: string = "../out"
): Promise<void> {
  const contractFilePath = path.join(
    artifactFolderPath,
    `${contractName}.sol`,
    `${contractName}.json`
  );

  const contractArtifact = require(contractFilePath) as {
    abi: ethers.utils.Fragment[];
    bytecode: string;
  };
  const factory = new ethers.ContractFactory(
    contractArtifact.abi,
    contractArtifact.bytecode
  );
  const signatures = Object.keys(factory.interface.functions);

  const selectors = signatures.reduce((acc: string[], val: string) => {
    if (val !== "init(bytes)") {
      acc.push(factory.interface.getSighash(val) as string);
    }
    return acc;
  }, []);
  const abiCoder = new ethers.utils.AbiCoder();
  const coded = abiCoder.encode(["bytes4[]"], [selectors]);

  process.stdout.write(coded);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
printSelectors(args[0], args[1])
  .then(() => process.exit(0))
  .catch((error: Error) => {
    console.log(error);
    process.exit(1);
  });
