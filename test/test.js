const { expect } = require("chai");

describe("Tokens 1155", function () {
  it("Reverts due to transferring the soulbound token.", async function () {
    const [admin, distributor, burner, receiver] = await ethers.getSigners();

    const Contract = await ethers.getContractFactory("Tokens1155");
    const contract = await Contract.deploy();

    let BURNER_ROLE = await contract.BURNER_ROLE();
    let DISTRIBUTOR_ROLE = await contract.DISTRIBUTOR_ROLE();
    await contract.grantRole(DISTRIBUTOR_ROLE, distributor.address);
    await contract.grantRole(BURNER_ROLE, burner.address);

    await contract.connect(distributor).distribute(receiver.address, 3, []);

    await expect(contract.connect(receiver).safeTransferFrom(receiver.address, burner.address, 0, 2, [])).to.be.revertedWith("Cannot trade soulbound token!");
  });

  it("An address, ditributed with tokens, should succesfully send an amount of transferable tokens to a qualified burner address.", async function () {
    const [admin, distributor, burner, receiver] = await ethers.getSigners();

    const Contract = await ethers.getContractFactory("Tokens1155");
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