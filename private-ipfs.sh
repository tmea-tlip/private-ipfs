#!/bin/sh

command="$1"

BOOTSTRAP_LOG_FILE=./private-network/logs/bootstrap_logs.log

# Remove the swarm.key file
clean () {

    echo "Cleaning files"

    if [ -f ./private-network/.ipfs/swarm.key ]; then
        sudo rm ./private-network/ipfs/swarm.key
    fi

    if [ -f ./ipfs.bootstrap.container ]; then
        sudo rm ./ipfs.bootstrap.container
    fi   

    if [ -f ./ipfs.node.container ]; then
        sudo rm ./ipfs.node.container
    fi  

    if [ -f ./peer-id-bootstrap-node ]; then
        sudo rm ./peer-id-bootstrap-node
    fi  

    if [ -f ./peer-id-ipfs-node ]; then
        sudo rm ./peer-id-ipfs-node
    fi  
}

# Create missing directory
volumeSetup () {

    echo "Setting up directories"

    if [ ! -d private-network/ipfs/ ]; then
        mkdir private-network/ipfs/
    fi

    if [ ! -d private-network/logs ]; then
        mkdir private-network/logs
    fi
    
}

# Start ipfs bootstrap node
startBootstrap () {

    echo "Setting up an ipfs bootstrap node"

    stopContainers

    clean

    volumeSetup

    swarmKey

    # init.sh executable
    chmod +x private-network/init.sh

    # Run the bootstrap ipfs node
    docker-compose run -d --rm bootstrap_node > ipfs.bootstrap.container

    # Number of seconds to wait
    echo "Waiting for 15 seconds ... ⏳"
    sleep 15
    docker logs $(cat ./ipfs.bootstrap.container) | grep "PeerID" > peer-id-bootstrap-node
}

# Start ipfs node
startIpfs () {

    echo "Starting an ipfs node..."

    # init.sh executable
    chmod +x private-network/init.sh

    # Run the bootstrap ipfs node
    docker-compose run -d --rm ipfs_node > ipfs.node.container

    # Number of seconds to wait
    echo "Waiting for 15 seconds for IPFS node to boot up..."
    sleep 15
    docker logs $(cat ./ipfs.node.container) | grep "PeerID" > peer-id-ipfs-node

}

# Generate a swarm key
swarmKey () {

    echo "Generating a swarm key..."

    # Generate a swarm key and output into a file 
    docker run --rm golang:1.9 sh -c 'go get github.com/Kubuxu/go-ipfs-swarm-key-gen/ipfs-swarm-key-gen && ipfs-swarm-key-gen' >> private-network/.ipfs/swarm.key
}

# Stop all containers
stopContainers () {

  echo "Stopping containers..."
	docker-compose --log-level ERROR down -v --remove-orphans
}

# Show help
help () {
  echo "usage: private-ipfs.sh [start-bootstrap|start-ipfs|stop]"
}


# Start, stop, remove
case "${command}" in
        "help")
    help
    ;;
        "start-bootstrap")
    startBootstrap
    ;;
        "start-ipfs")
    startIpfs
    ;;
         "stop")
    stopContainers
    ;;
  *)
    echo "Command not Found."
    help
    exit 127;
    ;;
esac

