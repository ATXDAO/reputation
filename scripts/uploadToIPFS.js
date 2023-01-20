const { NFTStorage, File} = require('nft.storage');
require('dotenv').config()
const fs = require("fs");

// images CID: bafybeidr6demas4y4ounbj564npugalan74patc5xdhbbo6zywvzdr3gbq
// jsons CID: bafybeih3e3hyanol5zjsnyzxss72p3fosy6jsw46wr77e5rlstz5zapxru
async function main() {

    let token0Obj = {};
    token0Obj.name = "Souldbound Token - 0.0.1";
    token0Obj.description = "This is a soulbound token.";
    token0Obj.image = "ipfs://bafybeidr6demas4y4ounbj564npugalan74patc5xdhbbo6zywvzdr3gbq/0.png";

    token0Obj.attributes = [];
    token0Obj.attributes.push( { "trait_type" : "Transfer Type", "value": "Soulbound" })

    let token1Obj = {};
    token1Obj.name = "Redeemable Token 0.0.1";
    token1Obj.description = "This is a redeemable token.";
    token1Obj.image = "ipfs://bafybeidr6demas4y4ounbj564npugalan74patc5xdhbbo6zywvzdr3gbq/1.png";

    token1Obj.attributes = [];
    token1Obj.attributes.push( { "trait_type" : "Transfer Type", "value": "Redeemable" })

    let file_0 = new File(JSON.stringify(token0Obj), (0).toString(), { type: 'text/json'});
    let file_1 = new File(JSON.stringify(token1Obj), (1).toString(), { type: 'text/json'});

    let arr = [];
    arr.push(file_0);
    arr.push(file_1);

    const client = new NFTStorage({ token: process.env.TOKEN });
    let cid = await client.storeDirectory(arr);
    console.log(cid);
}

main();
