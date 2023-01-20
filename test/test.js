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

    await expect(contract.connect(burner).distribute(receiver.address, 3, [])).to.be.revertedWith("AccessControl: account 0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc is missing role 0xfbd454f36a7e1a388bd6fc3ab10d434aa4578f811acbbcf33afb1c697486313c");
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

    await contract.connect(receiver).safeTransferFrom(receiver.address, burner.address, 1, 2, []);

    expect(await contract.balanceOf(receiver.address, 1)).to.equal(1);
  });


  it("Transferable owners count is one after distributing.", async function () {
    const [admin, distributor, burner, receiver] = await ethers.getSigners();

    const Contract = await ethers.getContractFactory("RepTokens");
    const contract = await Contract.deploy();

    let BURNER_ROLE = await contract.BURNER_ROLE();
    let DISTRIBUTOR_ROLE = await contract.DISTRIBUTOR_ROLE();
    await contract.grantRole(DISTRIBUTOR_ROLE, distributor.address);
    await contract.grantRole(BURNER_ROLE, burner.address);

    await contract.connect(distributor).distribute(receiver.address, 3, []);

    expect(await contract.getOwnersOfTokenIDLength(1)).to.equals(1);
  });


  it("Transferable owners count is two after transferring some tokens from one address to another", async function () {
    const [admin, distributor, burner, receiver] = await ethers.getSigners();

    const Contract = await ethers.getContractFactory("RepTokens");
    const contract = await Contract.deploy();

    let BURNER_ROLE = await contract.BURNER_ROLE();
    let DISTRIBUTOR_ROLE = await contract.DISTRIBUTOR_ROLE();
    await contract.grantRole(DISTRIBUTOR_ROLE, distributor.address);
    await contract.grantRole(BURNER_ROLE, burner.address);

    await contract.connect(distributor).distribute(receiver.address, 3, []);

    await contract.connect(receiver).safeTransferFrom(receiver.address, burner.address, 1, 2, []);

    expect(await contract.getOwnersOfTokenIDLength(1)).to.equals(2);
  });


  it("Transferable owners count is one after transferring ALL tokens from one address to another", async function () {
    const [admin, distributor, burner, receiver] = await ethers.getSigners();

    const Contract = await ethers.getContractFactory("RepTokens");
    const contract = await Contract.deploy();

    let BURNER_ROLE = await contract.BURNER_ROLE();
    let DISTRIBUTOR_ROLE = await contract.DISTRIBUTOR_ROLE();
    await contract.grantRole(DISTRIBUTOR_ROLE, distributor.address);
    await contract.grantRole(BURNER_ROLE, burner.address);

    await contract.connect(distributor).distribute(receiver.address, 3, []);

    await contract.connect(receiver).safeTransferFrom(receiver.address, burner.address, 1, 3, []);

    expect(await contract.getOwnersOfTokenIDLength(1)).to.equals(1);
  });

  it("succesfully transfer tokens to burner accounts and transferable arrays remain consistent.", async function () {
    const [admin, distributor, burner, receiver, receiver2, receiver3, receiver4] = await ethers.getSigners();

    const Contract = await ethers.getContractFactory("RepTokens");
    const contract = await Contract.deploy();

    let BURNER_ROLE = await contract.BURNER_ROLE();
    let DISTRIBUTOR_ROLE = await contract.DISTRIBUTOR_ROLE();
    await contract.grantRole(DISTRIBUTOR_ROLE, distributor.address);
    await contract.grantRole(BURNER_ROLE, burner.address);

    //distributes to 4 different addresses, therefore getTransferableOwnerLength is == 4
    await contract.connect(distributor).distribute(receiver.address, 3, []);
    await contract.connect(distributor).distribute(receiver2.address, 3, []);
    await contract.connect(distributor).distribute(receiver3.address, 3, []);
    await contract.connect(distributor).distribute(receiver4.address, 3, []);

    //transferred some tokens from receiver2 address to burner address.
    //add burner address to transferable owners array.
    //keeps receiver2 address in transferable array.
    //total count = 5
    await contract.connect(receiver2).safeTransferFrom(receiver2.address, burner.address, 1, 2, []);
    
    //transferred ALL tokens from receiver3 to burner.
    //remove receiver3 from transferable owners array.
    //total count = 4
    await contract.connect(receiver3).safeTransferFrom(receiver3.address, burner.address, 1, 3, []);

    expect(await contract.getOwnersOfTokenIDLength(1)).to.equals(4);
  });


  it("Succesfully transfer soulbound tokens using a designated wallet address", async function () {
    const [admin, distributor, burner, receiver, soulboundTransferer, receiver2] = await ethers.getSigners();

    const Contract = await ethers.getContractFactory("RepTokens");
    const contract = await Contract.deploy();

    let BURNER_ROLE = await contract.BURNER_ROLE();
    let DISTRIBUTOR_ROLE = await contract.DISTRIBUTOR_ROLE();
    let SOULBOUND_TOKEN_TRANSFERER_ROLE = await contract.SOULBOUND_TOKEN_TRANSFERER_ROLE();

    await contract.grantRole(DISTRIBUTOR_ROLE, distributor.address);
    await contract.grantRole(BURNER_ROLE, burner.address);
    await contract.grantRole(SOULBOUND_TOKEN_TRANSFERER_ROLE, soulboundTransferer.address);

    await contract.connect(distributor).distribute(receiver.address, 3, []);

    console.log("receiving addr: " + receiver.address);
    console.log("receiving2 addr: " + receiver2.address);

    let owners1 = await contract.getOwnersOfTokenID(0);
    console.log("pre: " + owners1);
    
    await contract.connect(receiver).setApprovalForAll(soulboundTransferer.address, true);
    let s = await contract.connect(soulboundTransferer).fulfillTransferSoulboundTokensRequest(receiver.address, receiver2.address);

    //WILL FAIL SINCE ONLY SOULBOUND TRANSFERER HAS THE ABILITY TO TRANSFER TOKENS NO MATTER WHAT
    // await contract.connect(receiver).setApprovalForAll(distributor.address, true);
    // let s = await contract.connect(distributor).safeTransferFrom(receiver.address, burner.address, 0, 1, []);

    let owners2 = await contract.getOwnersOfTokenID(0);
    console.log("post: " + owners2);
    
    expect(true);
  });
});