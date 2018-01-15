# From:  https://github.com/docker/labs/blob/master/swarm-mode/beginner-tutorial/
# Modified by: Daniel Rodriguez Rodriguez
#
# At the Hyper-V Manager app on Windows, create a Virtual Switch called "virtualPFC" as a "external network" under an "ethernet adapter"
# Run from PowerShell console as Administrator with the command:
#   powershell -executionpolicy bypass -File C:\Users\drago\IdeaProjects\master_thesisB\infrastructure\docker-machine-VMs\swarm-node-hyperv-setup.ps1


# Swarm mode using Docker Machine

$managers=1
$workers=3

# Change the SwitchName to the name of your virtual switch
$SwitchName = "virtualPFC"

# Chose a name for the stack and point the stack-descriptor file
$StackName="TheStackOfDani"
# $DockerStackFile="https://raw.githubusercontent.com/docker/example-voting-app/master/docker-stack.yml"
# $DockerStackFile="https://raw.githubusercontent.com/Draki/master_thesis/master/infrastructure/docker-stack.yml"
$DockerStackFile="https://raw.githubusercontent.com/Draki/master_thesis/master/infrastructure/docker-compose.yml"



$fromNow = Get-Date

# create manager machines
echo "======> Creating manager machines ..."
for ($node=1;$node -le $managers;$node++) {
	echo "======> Creating manager$node machine ..."
	docker-machine create -d hyperv --hyperv-virtual-switch $SwitchName --engine-label danir2.machine.role=manager ('manager'+$node)
}

# create worker machines
echo "======> Creating worker machines ..."
for ($node=1;$node -le $workers;$node++) {
	echo "======> Creating worker$node machine ..."
	docker-machine create -d hyperv --hyperv-virtual-switch $SwitchName --engine-label danir2.machine.role=worker ('worker'+$node)
}

# list all machines
docker-machine ls
echo "======> Initializing first swarm manager ..."
$manager1ip = docker-machine ip manager1

docker-machine ssh manager1 "docker swarm init --listen-addr $manager1ip --advertise-addr $manager1ip"

# get manager and worker tokens
$managertoken = docker-machine ssh manager1 "docker swarm join-token manager -q"
$workertoken = docker-machine ssh manager1 "docker swarm join-token worker -q"

# other masters join swarm
for ($node=2;$node -le $managers;$node++) {
	echo "======> manager$node joining swarm as manager ..."
	$nodeip = docker-machine ip manager$node
	docker-machine ssh "manager$node" "docker swarm join --token $managertoken --listen-addr $nodeip --advertise-addr $nodeip $manager1ip"
}
# show members of swarm
docker-machine ssh manager1 "docker node ls"

# workers join swarm
for ($node=1;$node -le $workers;$node++) {
	echo "======> worker$node joining swarm as worker ..."
	$nodeip = docker-machine ip worker$node
	docker-machine ssh "worker$node" "docker swarm join --token $workertoken --listen-addr $nodeip --advertise-addr $nodeip $manager1ip"
}

# show members of swarm
docker-machine ssh manager1 "docker node ls"



# GET THE DOCKER-STACK.YML FILE:
# docker-machine scp ../docker-stack.yml manager1:/home/docker/
# pscp docker-compose.yml docker@manager1:/home/docker/docker-compose.yml
docker-machine ssh manager1 "wget $DockerStackFile --no-check-certificate --output-document docker-stack.yml"

# And deploy it:
docker-machine ssh manager1 "docker stack deploy --compose-file docker-stack.yml $StackName"
# show the service
docker-machine ssh manager1 "docker stack services $StackName"

# docker-machine ssh manager1 "docker stack rm $StackName"


$timeItTook = (new-timespan -Start $fromNow).TotalSeconds
echo "======>"
echo "======> The deployment took: $timeItTook seconds"