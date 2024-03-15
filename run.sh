#!/bin/sh -e

port=6$(id -u)

# build once
#docker build -t docker-gui .
# or if using a rootless docker installation
#docker -c rootless build --build-arg hostname=`hostname` -t docker-gui-reg "$(dirname $0)"

# Building may need a license file - if you don't have it yet, comment-out the offending line in Dockerfile, run the container without it, go through the activation process (run PtGUI inside the container, enter your key when prompted and activate), then copy the .dat file outside of the container.
# Then save the license .dat to the current directory with a name corresponding to this machine's hostname, uncomment in Dockerfile and re-build.

# The docker image/container "docker-gui-reg" denotes the licese file is already there.

echo
echo "VNC server will run on port $port. You can set up port forwarding with e.g."
echo "  'ssh -L 5901:127.0.0.1:$port $USER@this_server'"
echo "  and then connect to vnc://localhost:5901 (or manually: in a VNC client use the hostname 'localhost' and port '5901')"
echo

docker -c rootless run --rm -it -p 127.0.0.1:"$port":5901 -v "$PWD":/work -v /work -v /projects/:/projects --name docker-gui-reg docker-gui-reg
#docker run --rm -it -p 127.0.0.1:"$port":5901 -u $(id -u):$(id -g) -v "$PWD":/work -v /work --name docker-gui docker-gui
