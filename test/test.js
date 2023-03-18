const { expect } = require("chai");

describe("Rep Tokens", function () {

  let [admin, minter, distributor, burner, receiver, soulboundTokenTransferer, distributorTwo, receiver2, receiver3, receiver4, receiver5] = [];
  let Contract;
  let contract;

  let MINTER_ROLE;
  let BURNER_ROLE;
  let DISTRIBUTOR_ROLE;
  let SOULBOUND_TOKEN_TRANSFERER_ROLE;

  before(async function() {
    [admin, minter, distributor, burner, receiver, soulboundTokenTransferer, distributorTwo, receiver2, receiver3, receiver4, receiver5] = await ethers.getSigners();
    console.log(`admin: ${admin.address}`);
    console.log(`minter: ${minter.address}`);
    console.log(`distributor: ${distributor.address}`);
    console.log(`burner: ${burner.address}`);
    console.log(`receiver: ${receiver.address}`);
    console.log(`soulboundTokenTransferer: ${soulboundTokenTransferer.address}`);
    console.log(`distributorTwo: ${distributorTwo.address}`);
    console.log(`receiver2: ${receiver2.address}`);
    console.log(`receiver3: ${receiver3.address}`);
    console.log(`receiver4: ${receiver4.address}`);
    console.log(`receiver5: ${receiver5.address}`);
    
    Contract = await ethers.getContractFactory("RepTokens");
    contract = await Contract.deploy([admin.address], 500);;

    MINTER_ROLE = await contract.MINTER_ROLE();
    DISTRIBUTOR_ROLE = await contract.DISTRIBUTOR_ROLE();
    BURNER_ROLE = await contract.BURNER_ROLE();
    SOULBOUND_TOKEN_TRANSFERER_ROLE = await contract.SOULBOUND_TOKEN_TRANSFERER_ROLE();

    await contract.grantRole(MINTER_ROLE, minter.address);
    await contract.grantRole(DISTRIBUTOR_ROLE, distributor.address);
    await contract.grantRole(BURNER_ROLE, burner.address);
    await contract.grantRole(SOULBOUND_TOKEN_TRANSFERER_ROLE, soulboundTokenTransferer.address);
  });

  it("Reverts due to attempting to mint tokens using an address which does not have the MINTER_ROLE.", async function () {
    await expect(contract.mint(distributor.address, 50, [])).to.be.revertedWith(`AccessControl: account ${admin.address.toLowerCase()} is missing role ${MINTER_ROLE}`);
  });
  
  it("Reverts because minter can only mint tokens to distributor.", async function () {
    await expect(contract.connect(minter).mint(receiver.address, 50, [])).to.be.revertedWith("Minter can only mint tokens to distributors!");
  });

  it("Reverts because minting too many tokens in a single transaction.", async function () {
    await expect(contract.connect(minter).mint(distributor.address, 5000, [])).to.be.revertedWith(`Cannot mint that many tokens in a single transaction!`);
  });

  it ("Succesfully mints tokens to distributor.", async function () {
    await contract.connect(minter).mint(distributor.address, 450, []);
    expect(await contract.balanceOf(distributor.address, 0)).to.equals(450);
  });

  it("", async function () {

  });

  it("Reverts due to attempting to distribute tokens using an address which does not have the DISTRIBUTOR_ROLE.", async function () {
    await expect(contract.distribute(distributor.address, receiver.address, 45, [])).to.be.revertedWith(`AccessControl: account ${admin.address.toLowerCase()} is missing role ${DISTRIBUTOR_ROLE}`);
  });

  it("Reverts because distributor does not have the right to move other distributor tokens.", async function () {
    await contract.grantRole(DISTRIBUTOR_ROLE, distributorTwo.address);
    await expect(contract.connect(distributorTwo).distribute(distributor.address, receiver.address, 50, [])).to.be.revertedWith(`ERC1155: caller is not token owner nor approved`);
  });

  it("Succesfully distributes tokens to a receiver.", async function () {
    await contract.connect(distributor).distribute(distributor.address, receiver.address, 45, []);
    expect(await contract.balanceOf(receiver.address, 0)).to.equals(45);
    await contract.connect(distributor).distribute(distributor.address, receiver.address, 405, []);
  });


  it("Reverts due distributing trying to transfer more tokens than it has.", async function () {
    await expect(contract.connect(distributor).distribute(distributor.address, receiver.address, 45, [])).to.be.revertedWith(`ERC1155: insufficient balance for transfer`);
  });


  it("Transferable owners count is one after distributing.", async function () {
    expect(await contract.getOwnersOfTokenIDLength(1)).to.equals(1);
  });

  it("", async function () {

  });

  it("Reverts due to a burner attempting to send tokens", async function () {
    await expect(contract.connect(burner).safeTransferFrom(burner.address, receiver.address, 1, 2, [])).to.be.revertedWith("Burners cannot send tokens!");
  });

  it("Reverts due to attempting to send a lifetime token as an everyday user.", async function () {
    await expect(contract.connect(receiver).safeTransferFrom(receiver.address, burner.address, 0, 2, [])).to.be.revertedWith("Can only send a redeemable token!");
  });

  it("Reverts due to attempting to send a redeemable token to an address, of which does not have the BURNER_ROLE.", async function () {
    await expect(contract.connect(receiver).safeTransferFrom(receiver.address, distributor.address, 1, 2, [])).to.be.revertedWith("Can only send Redeemable Tokens to burners!");
  });

  it("Reverts due to everyday users not being able to send lifetime tokens!", async function () {
    await expect(contract.connect(receiver).safeTransferFrom(receiver.address, burner.address, 0, 2, [])).to.be.revertedWith("Can only send a redeemable token!");
  });

  it("Reverts due distributor calling the wrong function to distribute tokens!", async function () {
    await expect(contract.connect(distributor).safeTransferFrom(distributor.address, burner.address, 1, 2, [])).to.be.revertedWith("Distributors can only send tokens in pairs through the transferFromDistributor function!");
  });

  it("An address, ditributed with tokens, should succesfully send an amount of transferable tokens to a an address with the BURNER_ROLE.", async function () {
    await contract.connect(receiver).safeTransferFrom(receiver.address, burner.address, 1, 2, []);
    expect(await contract.balanceOf(burner.address, 1)).to.equal(2);
  });


  it("Transferable owners count is two after transferring some tokens from one address to another", async function () {
    expect(await contract.getOwnersOfTokenIDLength(1)).to.equals(2);
  });

  it("Transferable owners count is one after transferring ALL tokens from one address to another", async function () {
    await contract.connect(receiver).safeTransferFrom(receiver.address, burner.address, 1, 448, []);
    expect(await contract.getOwnersOfTokenIDLength(1)).to.equals(1);
  });

  it("succesfully transfer tokens to burner accounts and transferable arrays remain consistent.", async function () {
    await contract.connect(minter).mint(distributor.address, 12, []);
    //distributes to 4 different addresses, therefore getTransferableOwnerLength is == 4
    await contract.connect(distributor).distribute(distributor.address, receiver2.address, 3, []);
    await contract.connect(distributor).distribute(distributor.address, receiver3.address, 3, []);
    await contract.connect(distributor).distribute(distributor.address, receiver4.address, 3, []);
    await contract.connect(distributor).distribute(distributor.address, receiver5.address, 3, []);

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

  it ("Reverts due to attempting to transfer lifetime tokens using an address which does not have the LIFETIME_TRANSFERER_ROLE.", async function() {
    await contract.connect(receiver).setApprovalForAll(admin.address, true);
    await expect(contract.connect(admin).fulfillTransferSoulboundTokensRequest(receiver.address, receiver2.address)).to.be.revertedWith(`AccessControl: account ${admin.address.toLowerCase()} is missing role ${SOULBOUND_TOKEN_TRANSFERER_ROLE}`);

  });

  it("Succesfully transfer soulbound tokens using a designated wallet address", async function () {
    
    await contract.connect(receiver).setApprovalForAll(soulboundTokenTransferer.address, true);
    await contract.connect(soulboundTokenTransferer).fulfillTransferSoulboundTokensRequest(receiver.address, receiver2.address);

    expect((await contract.getOwnersOfTokenID(1)).length).to.equals(3);
    expect((await contract.getOwnersOfTokenID(0)).length).to.equals(4);
  });
});