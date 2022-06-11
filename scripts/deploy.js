// scripts/deploy.js
async function main () {
    // We get the contract to deploy
    const Rep = await ethers.getContractFactory('Reputation');
    console.log('Deploying Rep...');
    const rep = await Rep.deploy();
    await rep.deployed();
    console.log('Reputation deployed to:', rep.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error);
      process.exit(1);
    });