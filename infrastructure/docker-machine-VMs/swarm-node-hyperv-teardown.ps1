# From:  https://github.com/docker/labs/blob/master/swarm-mode/beginner-tutorial/

$fromNow = Get-Date

### Warning: This will remove all docker machines running ###
docker-machine stop (docker-machine ls -q)
docker-machine rm --force (docker-machine ls -q)

$timeItTook = (new-timespan -Start $fromNow).TotalSeconds
echo "======>"
echo "======> The cleaning took: $timeItTook seconds"