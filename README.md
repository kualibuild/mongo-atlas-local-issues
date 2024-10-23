# Mongo atlas image issues

## Prerequites

- Docker
- Node

## Setup

Install dependencies

```sh
npm install
```

When running mongo in docker, you typically need to mount `/data/db` as a volume
if you want the data to persist across container restarts/removals. However, if
you are running the `mongodb/mongodb-atlas-local` image, you're likely doing so
in order to test replicaset behavior, atlas search, or vector search features.
In order for those to work across container restarts/removals, you'll need to
mound 2 additional volumes:

- `/data/configdb`
- `/data/mongot`

However, we've run across some unexpected behavior when you mount those folders.

To reproduce these issues, there are two different setups:

1. Run `mongodb/mongodb-atlas-local` with the three mounted volumes
2. Run `mongodb/mongodb-atlas-local` with one mounted volume that encompasses
   the three folders we need for persistent data.

## Issue with Three Mounted Folders

```sh
npm run start:3 # Starts the mongo-three-volumes container
node index.js # Prints out list of "messages". Run multiple times and you should see an accumulation of each message inserted.
npm run stop # Stops the docker containers
npm run start:3 # Restarts the mongo-three-volumes container
node index.js # Now this gets a "MongoServerError: not primary"
```

When looking at the logs for the mongo container, you start to see logs like:

```
{"t":{"$date":"2024-10-23T16:38:36.723+00:00"},"s":"I",  "c":"-",        "id":4939300, "ctx":"monitoring-keys-for-HMAC","msg":"Failed to refresh key cache","attr":{"error":"ReadConcernMajorityNotAvailableYet: Read concern majority reads are currently not possible.","nextWakeupMillis":3200}}
```

and

```
{"t":{"$date":"2024-10-23T16:38:42.733+00:00"},"s":"I",  "c":"SHARDING", "id":7012500, "ctx":"QueryAnalysisConfigurationsRefresher","msg":"Failed to refresh query analysis configurations, will try again at the next interval","attr":{"error":"PrimarySteppedDown: No primary exists currently"}}
```

To clean up the stored data, run:

```sh
npm run clean:3
```

## Issue with Single Mounted Folder

```sh
npm run start:1 # Starts the mongo-single-volume container
node index.js # Prints out list of "messages". Run multiple times and you should see an accumulation of each message inserted.
npm run stop # Stops the docker containers
npm run start:1 # Restarts the mongo-single-volume container
node index.js # Messages start over. Data was wiped out.
```

It seems that mounting `/data` instead of the `/data/db`, `/data/configdb/` and
`/data/mongot` individually makes mongo delete the data between restarts.

## Note

When using the image `mongodb/mongodb-atlas-local:7.0.12-20241017T134640Z`, the
issues seem to go away at least for the 3 mounted folders.
