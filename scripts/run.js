const main = async () => {
	const gameContractFactory = await hre.ethers.getContractFactory("MyEpicGame");
	const gameContract = await gameContractFactory.deploy(
		["Tony", "Spidy", "Hulk"],
		[
			"https://bit.ly/3uI2t7Z",
			"https://bit.ly/37djmhX",
			"https://bit.ly/37kUPHx",
		],
		["300", "250", "450"],
		["100", "50", "150"],
		"Thanos",
		"https://bit.ly/3y6F4NT",
		"10000",
		"50"
	);
	await gameContract.deployed();
	console.log("Contract Deployed to : ", gameContract.address);

	let txn;
	txn = await gameContract.mintCharacterNFT(0);
	await txn.wait();

	// let returnedTokenURI = await gameContract.tokenURI(1);
	// console.log("Token URI:", returnedTokenURI);
	txn = await gameContract.attackBoss();
	txn = await gameContract.attackBoss();
	// await txn.wait();
};

const runMain = async () => {
	try {
		await main();
		process.exit(0);
	} catch (err) {
		console.log(err);
		process.exit(1);
	}
};

runMain();
