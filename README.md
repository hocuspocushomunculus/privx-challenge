# Challenge for PrivX / 2022 /

## **Repository structure**

```
.
├── assignment
│   ├── README.txt
│   ├── requirements.txt
│   └── server
│       ├── items.py
│       └── server.py
├── Dockerfile_robot
├── Dockerfile_server
├── notes.md
├── privx.robot
├── README.md
├── resources
│   ├── lib_privx.py
│   └── variables.py
└── results
    ├── log.html
    ├── output.xml
    └── report.html
```

## **Test Cases**

- User is able to list all items
- User is able to filter items
- User is able to get item by name
- User is able to add new item
- User is able to delete an item by name

No missing tests from the server implementation point of view, all API endpoints have been included.


## **Usage (example instructions for Ubuntu 20.04)**

1. Build docker images for both server and robot tests
2. Create a network that will be shared among the Docker containers
3. Start REST API server using the previously created network
4. Configure REST API server iptables rules
5. Run robot tests
6. Clean up REST API server Docker container

### **1. Build docker images**

```bash
# Build image for server
docker build -f ./Dockerfile_server -t privx_rest_api_server .

# Build image for robot tests
docker build -f ./Dockerfile_robot -t privx_robot_tests .
```

### **2. Create network**

```bash
docker network create privx-challenge
```

### **3. Start REST API server**

- We'll start the Docker container for the REST API server in the background.

```bash
export SERVER_HOME="/opt/rest_api_server" && \
docker run --rm -it --privileged \
--name rest_api_server \
--network=privx-challenge \
--network-alias=rest_api_server \
--cap-add=NET_ADMIN \
-p 5000:5000 \
-e PYTHONPATH="$SERVER_HOME:$SERVER_HOME/server" \
-w $SERVER_HOME \
privx_rest_api_server \
python3 server/server.py&
```

### **4. Configure REST API server**

- Extra configuration needed for the REST API server, since the server is
  running on 127.0.0.1 inside the container which is unreachable from other
  containers even on the same network. 
  We'll forward traffic from eth0 to localhost and vice-versa:

```bash
export IP_ADDRESS=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' rest_api_server) && \
docker exec -it rest_api_server sysctl -w net.ipv4.conf.all.route_localnet=1 && \
docker exec -it rest_api_server iptables -t nat -I PREROUTING -p tcp --dport 5000 -d $IP_ADDRESS/24 -j DNAT --to-destination 127.0.0.1:5000
```

- We could have avoided this step if server.py had:

```python
if __name__ == '__main__':
    app.run(host='0.0.0.0')

# Instead of:
if __name__ == '__main__':
    app.run()

# But the instructions said not to touch server.py implementation
```

### **5. Run robot tests**

- Thanks to the test setup keyword, we are able to run the suite consecutively multiple times

```bash
export WORKSPACE="/opt/robot_tests" && \
docker run --rm -it \
--name robot_tests \
--network=privx-challenge \
-w $WORKSPACE \
-v $(pwd)/resources:$WORKSPACE/resources \
-v $(pwd)/privx.robot:$WORKSPACE/privx.robot \
-v $(pwd)/results:$WORKSPACE/results \
privx_robot_tests \
robot --outputdir $WORKSPACE/results \
--loglevel INFO \
--pythonpath ":.:resources:" ./privx.robot
```

### **6. Clean up**

- Since we started the REST API server in the background, it needs to be stopped:

```bash
docker container stop rest_api_server
```
