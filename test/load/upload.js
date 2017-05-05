'use strict';

const sync = require('synchronize');
const fiber = sync.fiber;
const await = sync.await;
const defer = sync.defer;

const fs = require('fs');
const path = require('path');
const logger = require('storj-cli/bin/logger')(3);

const async = require('async');
const storj = require('storj-lib');
const utils = require('storj-lib/lib/utils');
const sleep = require('sleep');
const cluster = require('cluster');

// ##########   Config here
const api = 'https://api.storj.io';
const user = 'username';
const password = 'password';
let uploads_per_user = 100;  // sum of all uploads to process
let max_concurrent_uploads = 5;  // concurrent uploads per thread
let workers = process.env.WORKERS || require('os').cpus().length + 1;  // thread count
let upload_file_name = '/path/to/file.data';
const tmp_path = 'temp/'; // path for symlink and crypted data
process.env.STORJ_TEMP = tmp_path;
// #########


if (!fs.existsSync(tmp_path)){
    fs.mkdirSync(tmp_path);
}

function randomstring() {
    var str = '';
    var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

    for (var i = 0; i < 6; i++) {
        str += possible.charAt(Math.floor(Math.random() * possible.length));
    }
    return str;
}

var do_upload = function(client, upload_file_name, bucket, callback) {

    var timeout = setTimeout(function () {
        logger.log.error('Timeout of reached - PID: %s', process.pid);
        callback();
        clearTimeout(timeout);
    }, 10 * 60 * 1000);

    var secret = new storj.DataCipherKeyIv();
    var encrypter = new storj.EncryptStream(secret);

    var randompart = randomstring();
    var filepath = tmp_path + '/tmp_' + randompart + '.data';
    fs.symlink(upload_file_name, filepath, function () {});

    var tmppath = tmp_path + '/tmp_' + randompart + '.crypt';

    sleep.msleep(500);

    fs.createReadStream(filepath)
        .pipe(encrypter)
        .pipe(fs.createWriteStream(tmppath)).on('finish', function (err) {
        if (err) {
            client._logger.log.error('%s', err.message);
            callback();
            clearTimeout(timeout);
            fs.unlink(tmppath);
            fs.unlink(filepath);
            return;
        }

        // Create token for uploading to bucket by bucketid
        client.createToken(bucket, 'PUSH', function (err, token) {
            if (err) {
                fs.unlink(tmppath);
                fs.unlink(filepath);
                client._logger.log.error('%s', err.message);
                callback();
                clearTimeout(timeout);
                return;
            }

            client.storeFileInBucket(bucket, token.token, tmppath, function (err, file) {
                if (err) {
                    client._logger.log.error('%s', err.message);
                    callback();
                    clearTimeout(timeout);
                    fs.unlink(tmppath);
                    fs.unlink(filepath);
                    return;
                }

                fs.unlink(tmppath);
                fs.unlink(filepath);
                callback();

            });
        });
    })
};


var run = function (login) {

    var client = storj.BridgeClient(api, {basicAuth: login, logger: logger.log,
        concurrency: 6, requestTimeout: 90000});

    fiber(function() {
        var bucket = null;
        var buckets = await( client.getBuckets( defer() ) );
        var bucketInfo = { name: Math.random().toString(36).replace(/[^a-z]+/g, '').substr(0, 8) };

        if (!buckets.length) {
            bucket = await( client.createBucket(bucketInfo, defer()) ).id;
        }
        else { bucket = buckets[0].id; }

        async.forEachLimit(new Array(uploads_per_user), max_concurrent_uploads, function (fileID, callback) {
            do_upload(client, upload_file_name, bucket, callback);
        }, function (err) {
            logger.log.warn('all items have been processed - exit PID: %s', process.pid);
            if (err) {
                logger.log.error('crashed - exit PID: %s', process.pid);
            }
            process.exit(0)
        });
    });
};

if (cluster.isMaster) {

    console.log('start cluster with %s workers', workers);

    for (let i = 0; i < workers; ++i) {
        let worker = cluster.fork().process;
        logger.log.error('worker %s started.', worker.pid);
    }

    cluster.on('exit', function(worker) {
        logger.log.error('worker %s died. restart...', worker.process.pid);
        cluster.fork();
    });

} else {
    run({email: user, password: password});
}

process.on('uncaughtException', function(error) {
    logger.log.error('pid: %s - uncaughtException: %s', process.pid, error.message);
    process.exit(1);
});
