# Stress Test May 31st 2017

##  Renter Proxy

#### Started hitting point where worker_connections are not enough
```
2017/05/31 16:39:29 [alert] 7#7: *1229428 6114 worker_connections are not enough while connecting to upstream, client: 10.128.0.7, server: ~^(?<hname>[a-zA-Z0-9\-]+)\.renters\.(?<env>[a-zA-Z0-9\-]+)\.storj\.io$, request: "POST / HTTP/1.1", upstream: "http://10.246.47.181:8400/", host: "renter-64.renters.prod.storj.io:8400"
```

#### Possibly need to add healthcheck for renters

Might need to scale up kube-dns container? kube-dns-autoscaler ? https://kubernetes.io/docs/tasks/administer-cluster/dns-horizontal-autoscaling/


## Renter
+ with just under 400 renters, we were getting shards per second (upload) 60/s ok, 200/s breaks

#### Renter crashes when it cannot connect to mongos proxy
```
/storj/complex/node_modules/mongodb/lib/mongos.js:256
        process.nextTick(function() { throw err; })
                                              ^
                                              MongoError: no mongos proxy available
                                                  at Timeout.<anonymous> (/storj/complex/node_modules/mongodb-core/lib/topologies/mongos.js:638:28)
      at ontimeout (timers.js:380:14)
      at tryOnTimeout (timers.js:244:5)
      at Timer.listOnTimeout (timers.js:214:5)
  </anonymous>
```

#### Renter crashes when it disconnects from rabbitmq
+ Issue: https://github.com/Storj/complex/issues/63

```
{"level":"info","message":"replying to message to d63205422d0347831571a44f8bd3f35fa28e548e","timestamp":"2017-06-01T00:21:11.515Z"}
events.js:160
      throw er; // Unhandled 'error' event
            ^

            Error: Connection closed: 320 (CONNECTION-FORCED) with message "CONNECTION_FORCED - broker forced connection closure with reason 'shutdown'"
                at Object.accept (/storj/complex/node_modules/amqplib/lib/connection.js:89:32)
      at Connection.mainAccept (/storj/complex/node_modules/amqplib/lib/connection.js:62:33)
      at Socket.go (/storj/complex/node_modules/amqplib/lib/connection.js:465:48)
      at emitNone (events.js:86:13)
      at Socket.emit (events.js:185:7)
      at emitReadable_ (_stream_readable.js:432:10)
      at emitReadable (_stream_readable.js:426:7)
      at readableAddChunk (_stream_readable.js:187:13)
      at Socket.Readable.push (_stream_readable.js:134:10)
      at TCP.onread (net.js:551:20)
```

#### Should we add configuration to the maxOffers number for the renters?
+ https://github.com/Storj/complex/blob/master/lib/renter.js#L569>

#### How do we calculate how many renters that we need based on the network size?
+ Renters can handle X number of offers/s (currently maxOffers: 24 (hard coded))
+ Farmers can handle X number of offers/s
+ Network size is X big
+ Peak load expected is X
+ Normal usage is X

#### Need to be able to scale renters much faster
Will be moving to deployment in kubernetes in place of statefulsets. Will need to design a way to have unique IP's or ports provided to each pod on startup. Will likely have to use a sidecar pod to control this.

## Database
#### Should we set readpreference to secondary?
+ I went ahead and set this.
+ Need metrics to measure potential performance increase.

```
db.getMongo().setReadPref('secondaryPreferred')
```

#### Getting SSL errors in the mongo logs
`May 31st 2017, 17:16:19.136    2017-05-31T21:16:19.136+0000 E NETWORK  [conn2521365] SSL: error:1409F07F:SSL routines:SSL3_WRITE_PENDING:bad write retry, SSL: error:1409F07F:SSL routines:SSL3_WRITE_PENDING:bad write retry`

## Kube DNS
It looks as if the kubernetes dns service might have been struggling to keep up with the number of requests since we don't cache DNS any longer. I've scaled the service up and that seems to have resolved the problem. Still need to look into this a bit more however.

## Questions
+ How do we keep the queue from backing up
+ How do we reduce or reuse the number of requests on the network
+ Do queue messages increase when adding more renters?
  + If so, does that increase messages to the network also? Duplicates?
