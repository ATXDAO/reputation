const { expect } = require("chai");

describe("Soulbound Tokens", function () {
  it("Reverts when token holder is trying to send tokens.", async function () {
    const [addr1, multisig] = await ethers.getSigners();

    const Contract = await ethers.getContractFactory("SoulboundRepToken");
    const contract = await Contract.deploy();
    
    let tx = await contract.setMultisig(multisig.address);
    await expect(contract.connect(addr1).transfer(multisig.address, 5)).to.be.revertedWith("Only the multi-sig is able to transfer tokens!");
  });

  it("Sends tokens to an address using the contract's multi-sig.", async function () {
    const [addr1, multisig] = await ethers.getSigners();
    const Contract = await ethers.getContractFactory("SoulboundRepToken");
    const contract = await Contract.deploy();

    await contract.setMultisig(multisig.address);

    await contract.connect(multisig).mintToSender(10);
    await contract.connect(multisig).transfer(addr1.address, 5);

    await expect(true);
  });
});

describe("Transferable Tokens", function () {
  it("Reverts because token holder is attempting to send to an address not assigned to the multi-sig associated with the contract.", async function () {
    const [addr1, addr2, multisig] = await ethers.getSigners();
    const Contract = await ethers.getContractFactory("TransferableRepToken");
    const contract = await Contract.deploy();

    await contract.setMultisig(multisig.address);

    await contract.connect(addr1).mintToSender(10);

    await expect(contract.connect(addr1).transfer(addr2.address, 5)).to.be.revertedWith("Cannot send tokens to anywhere except multisig!");
  });

  it("Sends tokens to multi-sig associated with the contract.", async function () {
    const [addr1, addr2, multisig] = await ethers.getSigners();
    const Contract = await ethers.getContractFactory("TransferableRepToken");
    const contract = await Contract.deploy();
    
    await contract.setMultisig(multisig.address);

    await contract.connect(addr1).mintToSender(10);
    await contract.connect(addr1).transfer(multisig.address, 5);

    await expect(true);
  });
});