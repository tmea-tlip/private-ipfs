# docker-ipfs

This is a collection of files and configuration for setting up a private IPFS network.

## Private network setup

The following are steps for setting up a Private IPFS Network

### Run the bootstrap

To run the bootstrap, simply make the private-ipfs.sh file executable by running

```
chmod +x private-ipfs.sh
```

Once that is done, you can now run the bootstrap by running

```
./private-ipfs.sh start-bootstrap
```

## Add a node to the private IPFS Network

To run the ipfs node, ensure the private-ipfs.sh file is executable.

Copy over the swarm key generated from the bootstrap node in the directory /private-network/.ipfs/ to the same directory of your new node.

You can then run an ipfs node by running.

```
./private-ipfs.sh start-ipfs
```

To add an additional node to the bootstrap node, run the following commmand. Ensure you replace the:

- IP Address with the IP Address of the bootstrap node
- IP Address Peer with the IP Address of the peer that you want to join the private ipfs network
- The peerId with the peerId of the node you want to add. It should be the same as the value in the peer-id-ipfs-node located in the docker-ipfs/ folder

```
curl -X POST "http://(IP Address):5001/api/v0/bootstrap/add?arg=/ip4/(IP Address Peer)/tcp/4001/p2p/(peerId)"
```

To add the bootstrap node to the current node you are currently running, run the following command. Ensure you replace the:

- IP Address with the IP Address of the current IPFS node you are running
- IP Address Peer with the IP Address of the bootstrap node
- The peerId with the peerId of the bootstrap node you want to add. It should be the same as the value in the peer-id-bootstrap-node located in the docker-ipfs/ folder

```
curl -X POST "http://(IP Address of your ipfs node ):5001/api/v0/bootstrap/add?arg=/ip4/(IP Address of the bootstrap node)/tcp/4001/p2p/(peerId of the bootstrap node)"
```

## References

Good explanation for the role of private networks. With private networks each node specifies which other nodes it will connect to. Nodes in that network don't respond to communications from nodes outside that network.

**flyingzumwalt**
https://discuss.ipfs.io/t/how-to-create-a-private-network-of-ipfs/339/7

**Private networks**
https://github.com/ipfs/go-ipfs/blob/master/docs/experimental-features.md#private-networks

**IPFS HTTP API**
https://docs.ipfs.io/reference/http/api/
