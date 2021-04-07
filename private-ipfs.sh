#!/bin/sh

command="$1"

BOOTSTRAP_LOG_FILE=./private-network/logs/bootstrap_logs.log

# Remove the swarm.key file
clean () {

    echo "Cleaning files..."

    if [ -d ./private-network/bootstrap_node ]; then
        sudo rm -rf ./private-network/bootstrap_node
    fi

    if [ -d ./private-network/ipfs_node ]; then
        sudo rm -rf ./private-network/ipfs_node
    fi

    if [ -f ./peer-id-bootstrap-node ]; then
        sudo rm ./peer-id-bootstrap-node
    fi  

    if [ -f ./peer-id-ipfs-node ]; then
        sudo rm ./peer-id-ipfs-node
    fi
      
}

# Start ipfs bootstrap node
startBootstrap () {

    echo "Setting up an ipfs bootstrap node..."

    stopContainers

    clean

    echo "Setting up directories..."

    if [ ! -d private-network/bootstrap_node/ ]; then
        mkdir private-network/bootstrap_node/
        mkdir private-network/bootstrap_node/ipfs
    fi

    swarmKey

    # init.sh executable
    chmod +x private-network/init.sh

    # Run the bootstrap ipfs node
    docker-compose up -d bootstrap_node

    # Number of seconds to wait
    echo "Waiting for start up..."
    sleep 15
    
    echo "Saving the peer id for the bootstrap node"
    cat private-network/bootstrap_node/ipfs/config | grep "PeerID" > peer-id-bootstrap-node

}

# Start ipfs node
startIpfs () {

    echo "Starting an ipfs node..."

    echo "Setting up directories..."
    
    if [ ! -d private-network/ipfs_node/ ]; then
        mkdir private-network/ipfs_node/
        mkdir private-network/ipfs_node/ipfs
    fi

    # init.sh executable
    chmod +x private-network/init.sh

    # Run the bootstrap ipfs node
    docker-compose up -d ipfs_node

    # Number of seconds to wait
    echo "Waiting for start up..."
    sleep 15

    echo "Saving the peer id for the bootstrap node"
    cat private-network/ipfs_node/ipfs/config | grep "PeerID" > peer-id-bootstrap-node

}

# Generate a swarm key
swarmKey () {

    echo "Generating a swarm key..."

    # Generate a swarm key and output into a file 
    docker run --rm golang:1.9 sh -c 'go get github.com/Kubuxu/go-ipfs-swarm-key-gen/ipfs-swarm-key-gen && ipfs-swarm-key-gen' >> private-network/bootstrap_node/ipfs/swarm.key
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

