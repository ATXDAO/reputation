const { expect } = require("chai");

describe("Rep Tokens", function () {
  it("Reverts due to attempting to distribute tokens using an address which does not have the DISTRIBUTOR_ROLE.", async function () {
    const [admin, distributor, burner, receiver] = await ethers.getSigners();

    const Contract = await ethers.getContractFactory("RepTokens");
    const contract = await Contract.deploy();

    let BURNER_ROLE = await contract.BURNER_ROLE();
    let DISTRIBUTOR_ROLE = await contract.DISTRIBUTOR_ROLE();
    await contract.grantRole(DISTRIBUTOR_ROLE, distributor.address);
    await contract.grantRole(BURNER_ROLE, burner.address);

    await expect(contract.connect(burner).distribute(receiver.address, 3, [])).to.be.revertedWith("Only a distributor may succesfully call this function!");
    
  });

  it("Reverts due to attempting to send a transferrable token to an address, of which does not have the BURNER_ROLE.", async function () {
    const [admin, distributor, burner, receiver] = await ethers.getSigners();

    const Contract = await ethers.getContractFactory("RepTokens");
    const contract = await Contract.deploy();

    let BURNER_ROLE = await contract.BURNER_ROLE();
    let DISTRIBUTOR_ROLE = await contract.DISTRIBUTOR_ROLE();
    await contract.grantRole(DISTRIBUTOR_ROLE, distributor.address);
    await contract.grantRole(BURNER_ROLE, burner.address);

    await contract.connect(distributor).distribute(receiver.address, 3, []);

    await expect(contract.connect(receiver).safeTransferFrom(receiver.address, distributor.address, 1, 2, [])).to.be.revertedWith("Only a burner may succesfully be a recipient of a transferable token");
  });

  it("Reverts due to attempting to transfer a soulbound token.", async function () {
    const [admin, distributor, burner, receiver] = await ethers.getSigners();

    const Contract = await ethers.getContractFactory("RepTokens");
    const contract = await Contract.deploy();

    let BURNER_ROLE = await contract.BURNER_ROLE();
    let DISTRIBUTOR_ROLE = await contract.DISTRIBUTOR_ROLE();
    await contract.grantRole(DISTRIBUTOR_ROLE, distributor.address);
    await contract.grantRole(BURNER_ROLE, burner.address);

    await contract.connect(distributor).distribute(receiver.address, 3, []);

    await expect(contract.connect(receiver).safeTransferFrom(receiver.address, burner.address, 0, 2, [])).to.be.revertedWith("Cannot trade soulbound token!");
  });

  it("An address, ditributed with tokens, should succesfully send an amount of transferable tokens to a an address with the BURNER_ROLE.", async function () {
    const [admin, distributor, burner, receiver] = await ethers.getSigners();

    const Contract = await ethers.getContractFactory("RepTokens");
    const contract = await Contract.deploy();

    let BURNER_ROLE = await contract.BURNER_ROLE();
    let DISTRIBUTOR_ROLE = await contract.DISTRIBUTOR_ROLE();
    await contract.grantRole(DISTRIBUTOR_ROLE, distributor.address);
    await contract.grantRole(BURNER_ROLE, burner.address);

    await contract.connect(distributor).distribute(receiver.address, 3, []);

    let bo1 =  await contract.balanceOf(receiver.address, 0);
    let bo2 =  await contract.balanceOf(receiver.address, 1);

    await contract.connect(receiver).safeTransferFrom(receiver.address, burner.address, 1, 2, []);

    let bo3 =  await contract.balanceOf(receiver.address, 0);
    let bo4 =  await contract.balanceOf(receiver.address, 1);

    expect(bo4 < bo2);
    

  });
});