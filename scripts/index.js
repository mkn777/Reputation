async function main () {
    // Our code will go here
   // const accounts = await ethers.provider.listAccounts();
    //console.log(accounts);
    // Set up an ethers contract, representing our deployed Box instance
    const address = '0x5fbdb2315678afecb367f032d93f642f64180aa3';
    const Rep = await ethers.getContractFactory('Reputation');
    const rep = await Rep.attach(address);

    const test = await rep.addnewtoken();

    // Call the retrieve() function of the deployed Box contract
    const value = await rep.gettokencounts();
    console.log('reputation total tokens: ', value.toString());


  }
  
  main()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error);
      process.exit(1);
    });