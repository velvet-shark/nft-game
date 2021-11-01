const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory("MyEpicGame");
  const gameContract = await gameContractFactory.deploy(
    ["Leo", "Lana", "VelvetShark", "Roboto", "Crazy Dino"], // Names
    [
      "https://i.imgur.com/vKMSigt.jpg", // Images
      "https://i.imgur.com/5Y6Kf01.jpg",
      "https://i.imgur.com/dloWkEt.jpg",
      "https://i.imgur.com/c4ulSGj.png",
      "https://i.imgur.com/nYTYkSC.png",
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

  let txn;
  txn = await gameContract.mintCharacterNFT(2);
  await txn.wait();

  txn = await gameContract.attackBoss();
  await txn.wait();

  // // Get the value of the NFT's URI.
  // let returnedTokenUri = await gameContract.tokenURI(1);
  // console.log("Token URI:", returnedTokenUri);
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
