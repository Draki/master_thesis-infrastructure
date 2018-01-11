# Created by: Daniel Rodriguez Rodriguez
#


$servicename="helloworld"


echo "======> before creating services ..."
docker-machine ssh manager1 "docker service ls"

# create service:
#   The docker service create command creates the service.
#   The --name flag names the service helloworld.
#   The --replicas flag specifies the desired state of 1 running instance.
#   The arguments alpine ping docker.com define the service as an Alpine Linux container that executes the command ping docker.com.
echo "======> NOW creating services ..."
docker-machine ssh manager1 "docker service create --replicas 2 --name $servicename alpine ping docker.com"

#  list of running services
echo "======> after creating services ..."
docker-machine ssh manager1 "docker service ls"

# docker service inspect --pretty <SERVICE-ID> to display the details about a service in an easily readable format.
#  To return the service details in json format, run the same command without the --pretty flag.
echo "======> inspect the service ..."
docker-machine ssh manager1 "docker service inspect --pretty $servicename"

# Run docker service ps <SERVICE-ID> to see which nodes are running the service:
echo "======> nodes running the service ..."
docker-machine ssh manager1 "docker service ps $servicename"

# Run docker ps on the node where the task is running to see details about the container for the task.
echo "======> ps on one node running the service ..."
$noderunningservice="manager1"
docker-machine ssh $noderunningservice "docker ps"


# Run docker service scale <SERVICE-ID>=<NUMBER-OF-TASKS> to scale the service
echo "======> service scalation ..."
docker-machine ssh manager1 "docker service scale $servicename=5"

echo "======> nodes running the service ..."
docker-machine ssh manager1 "docker service ps $servicename"


# Remove the service with  docker service rm <SERVICE-ID>
echo "======> removing the service ..."
docker-machine ssh manager1 "docker service rm $servicename"


echo "======> check that the service no longer exists ..."
docker-machine ssh manager1 "docker service inspect --pretty $servicename"

echo "======> check that no nodes are running the service ..."
docker-machine ssh manager1 "docker service ps $servicename"



docker-machine ssh manager1 "docker network ls"
$networkname="my-network"
docker-machine ssh manager1 "docker network create --driver overlay $networkname"
docker-machine ssh manager1 "docker service update --network-add $networkname $servicename"
docker-machine ssh manager1 "docker service update --network-rm $networkname $servicename"


# Volumen create https://docs.docker.com/engine/reference/commandline/volume_create/
docker service create \
  --mount src=<VOLUME-NAME>,dst=<CONTAINER-PATH> \
  --name myservice \
  <IMAGE>

# filesystem PATH from the host: (you can add ",readonly" after ",dst=<CONTAINER-PATH>"
docker service create \
  --mount type=bind,src=<HOST-PATH>,dst=<CONTAINER-PATH>,readonly \
  --name myservice \
  <IMAGE>


docker-machine ssh manager1 "docker stack deploy --compose-file docker-stack.yml stackdemo"
