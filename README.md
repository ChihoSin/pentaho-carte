# pentaho-carte
Docker image for running Pentaho 8.3+ jobs on Carte slave servers


## How to use
The easiest way to use this image is to layer your own changes on-top of it.
Do this by creating a Dockerfile to add your requirements
This is a fork of chihosin/pentaho-carte, and should get updated once a pull request is completed to incorporate a  couple of updates for PDI-8.3
Until then it's using an image from pjaol on dockerhub

Setup a project directory
```
mkdir myproject
mkdir myproject/transformations
```

Setup a file based repository
Repository Manager > Add > Other Repository > File Based Repository

Develop your transformations and jobs using spoon.
Spoon will create a repository file usually <USER_HOME>/.kettle/repository.xml
```
cd myproject
cp -r <USER_HOME>/.kettle/ kettle
```
* note the name change in .kettle -> kettle , just to make it easier to work with

Edit kettle/repositories.xml update your base_directory to use /opt/pentaho/repository
e.g. 

```
<?xml version="1.0" encoding="UTF-8"?>
<repositories>
  <repository>    <id>KettleFileRepository</id>
    <name>MyRepo</name>
    <description>File repository</description>
    <is_default>false</is_default>
        <base_directory>/opt/pentaho/repository/transformations</base_directory>
    <read_only>N</read_only>
    <hides_hidden_files>N</hides_hidden_files>
  </repository>  </repositories>

```

Create a Dockerfile in myproject
```
#FROM chihosin/pentaho-carte
FROM pjaol/pentaho-carte.git
ADD kettle /opt/pentaho/data-integration/.kettle
ADD transformations /opt/pentaho/repository/transformations
```

Now build
```
docker build -t my-pdi-carte .
```


## Run with command
```
docker run -rm --name pdi-carte -e SERVER_PASSWD=password -e ADMIN_PASSWD=password -p 7373:7373 my-pdi-carte
```

This lets carte run on http://localhost:7373/ (username: admin / password: password)

## To view transformations / jobs
While your docker instance is running 
Login with bash and access kitchen.sh and pan.sh )
```
docker exec -it pdi-carte bash
bash-4.3# pwd
/opt/pentaho/data-integration
bash-4.3# ./kitchen.sh -level Rowlevel -listrep -listdirs
....
....
2019/10/09 16:00:41 - Kitchen - Logging is at level : Row Level (very detailed)
2019/10/09 16:00:41 - Kitchen - Start of run.
2019/10/09 16:00:41 - Kitchen - Allocate new job.
2019/10/09 16:00:41 - Kitchen - List of repositories:
2019/10/09 16:00:41 - RepositoriesMeta - No repositories file found in the local directory: /opt/pentaho/data-integration/repositories.xml
2019/10/09 16:00:41 - RepositoriesMeta - Reading repositories XML file: /opt/pentaho/data-integration/.kettle/repositories.xml
2019/10/09 16:00:41 - RepositoriesMeta - We have 0 connections...
2019/10/09 16:00:41 - RepositoriesMeta - We have 1 repositories...
2019/10/09 16:00:41 - RepositoriesMeta - Looking at repository #0
2019/10/09 16:00:41 - RepositoriesMeta - Read at repository: MyRepo

```
## Run with docker compose
See [docker-compose.yml](https://raw.githubusercontent.com/ChihoSin/pentaho-carte/master/docker-compose.yml)
Update to include passwords as necessary

## Developing with Docker
Building the docker instance is time consuming each time, it is faster to build once and mount your transformations. To do this simply use a docker run time volume -v host_dir:server_dir

```
docker run -v $(pwd)/transformations:/opt/pentaho/repository/transformations -name pdi-carte -e SERVER_PASSWD=password -e ADMIN_PASSWD=password -p 7373:7373 my-pdi-carte
```


## Additional info

See [Offical Kitchen & Pan Documentation](https://help.pentaho.com/Documentation/8.3/Products/Use_Command_Line_Tools_to_Run_Transformations_and_Jobs)

See [PackT tutorial series on Kitchen & Pan](https://subscription.packtpub.com/book/big_data_and_business_intelligence/9781849696906/1/ch01lvl1sec17/dealing-with-the-execution-log-simple)


