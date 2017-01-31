#!/usr/bin/env node
var storj = require('/usr/src/app/node_modules/storj-lib');

var key = storj.KeyPair().getPrivateKey();

//fs.writeFileSync('/opt/storj/.storjshare/id_ecdsa', encryptedKey);

console.log('%s', key);
