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

# set up the dashboard
dashboard (){

    cd dashboard
    curl -L https://github.com/ipfs/ipfs-webui/releases/download/v2.11.4/ipfs-webui.tar.gz > ipfs-webui.tar.gz
    tar --extract --file ipfs-webui.tar.gz
    rm ipfs-webui.tar.gz
    docker-compose up -d dashboard

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

    # The network is created to support the containers
    docker network prune -f
    
    # Ensure the script does not stop if it has not been pruned
    set +e
    docker network create "private-ipfs"
    set -e

    # Generate swarm key
    swarmKey

    # init.sh executable
    chmod +x private-network/init.sh

    # Run the bootstrap ipfs node
    docker-compose --log-level ERROR up -d bootstrap_node

    # Number of seconds to wait
    echo "Waiting for start up..."
    sleep 15
    
    echo "Saving the peer id for the bootstrap node"
    cat private-network/bootstrap_node/ipfs/config | grep "PeerID" > peer-id-bootstrap-node

    # Start the dashboard
    dashboard
}

# Start ipfs node
startIpfs () {

    echo "Starting an ipfs node..."

    echo "Setting up directories..."
    
    if [ ! -d private-network/ipfs_node/ ]; then
        mkdir private-network/ipfs_node/
        mkdir private-network/ipfs_node/ipfs
    fi

    # Ensure the script does not stop if it has not been pruned
    set +e
    docker network create "private-ipfs"
    set -e

    # init.sh executable
    chmod +x private-network/init.sh

    # Run the bootstrap ipfs node
    docker-compose --log-level ERROR up -d ipfs_node

    # Number of seconds to wait
    echo "Waiting for start up..."
    sleep 15

    echo "Saving the peer id for the bootstrap node"
    cat private-network/ipfs_node/ipfs/config | grep "PeerID" > peer-id-bootstrap-node

    # Start the dashboard
    dashboard
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

