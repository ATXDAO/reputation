const { NFTStorage, File} = require('nft.storage');
require('dotenv').config()
const fs = require("fs");

// images CID: bafybeidr6demas4y4ounbj564npugalan74patc5xdhbbo6zywvzdr3gbq
// jsons CID: bafybeih3e3hyanol5zjsnyzxss72p3fosy6jsw46wr77e5rlstz5zapxru
async function main() {

    let token0Obj = {};
    token0Obj.name = "Lifetime Token";
    token0Obj.description = "Represents a member's long standing reputation with the DAO and cannot be transferred.";
    token0Obj.image = "ipfs://bafybeiaywvtmm2rqa2idup57z44s24booowx7ikl5z36gqs2vjoyzrftce/lifetimetoken.jpg";
    
    token0Obj.attributes = [];
    token0Obj.attributes.push( { "trait_type" : "Transfer Type", "value": "Soulbound" })

    let token1Obj = {};
    token1Obj.name = "Redeemable Token";
    token1Obj.description = "Exchangeable for rewards, event entry, membership discounts, etc.";
    token1Obj.image = "ipfs://bafybeiaywvtmm2rqa2idup57z44s24booowx7ikl5z36gqs2vjoyzrftce/redeemabletoken.jpg";

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
