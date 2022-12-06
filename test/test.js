const { expect } = require("chai");

describe("Test", function () {
  it("Should return hello", async function () {
    const [owner] = await ethers.getSigners();

    const Contract = await ethers.getContractFactory("Test");

    const contract = await Contract.deploy();

    expect(await contract.sayHello()).to.equal("hello");
  });
});