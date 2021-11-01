const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory("MyEpicGame");
  const gameContract = await gameContractFactory.deploy(
    ["Leo", "Lana", "VelvetShark", "Roboto", "Crazy Dino"], // Names
    [
      "QmR3aib9MDWrsgdsH6yfzQ3dXDKNkXi5SbRQzADQmA5jSg", // Images
      "QmcCAcCiPJC3zHcGVZkB7sTBseK8RPeE1RXih5BA6A68JD",
      "QmYWc3WzUhSHyvthvp31gWk4Sty1biNFtjCdiySjrYU9Lx",
      "QmV63naK62HjJ7fLs5gVUVZ8VTpStuookhvae7i3QWfPrE",
      "QmXMXNrXGTxkUM5pvsDeDtHk6ga3XPEvUipDSizpLbndH2",
    ],
    [100, 200, 300, 400, 500], // HP values
    [100, 80, 60, 40, 30], // Attack damage values
    [10, 20, 30, 40, 50], // Min defense values
    [50, 60, 70, 80, 100], // Max defense values
    "Death & Taxes", // Boss name
    "https://i.imgur.com/26wXLTV.jpg", // Boss image
    [10000], // Boss hp
    [80], // Boss attack damage
    [50] // Boss max defense
  );
  await gameContract.deployed();
  console.log("Contract deployed to:", gameContract.address);

  // let txn;
  // txn = await gameContract.mintCharacterNFT(0);
  // await txn.wait();
  // console.log("Minted NFT #1");

  // txn = await gameContract.attackBoss();
  // await txn.wait();

  // txn = await gameContract.attackBoss();
  // await txn.wait();

  // console.log("Done!");

  //   txn = await gameContract.mintCharacterNFT(1);
  //   await txn.wait();
  //   console.log("Minted NFT #2");

  //   txn = await gameContract.mintCharacterNFT(2);
  //   await txn.wait();
  //   console.log("Minted NFT #3");

  //   txn = await gameContract.mintCharacterNFT(3);
  //   await txn.wait();
  //   console.log("Minted NFT #4");

  //   txn = await gameContract.mintCharacterNFT(4);
  //   await txn.wait();
  //   console.log("Minted NFT #5");

  //   console.log("Done deploying and minting!");
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();
