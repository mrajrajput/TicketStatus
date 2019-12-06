# TicketStatus
Getting the status of 2 different systems using Powershell Rest API


## ```List of projects```
```
Java method com/staus/common/StatusFinder/projects() calling Rest API of 'Microsoft Azure DevOps' using
the script findProjects.ps1 with input parameters provided by UI to give us list of projects.
```

### Location of Project list file

![](src/main/webapp/images/projectListAtTomcatWorkingDirectory.png1)


### Project list file

![](src/main/webapp/images/projectListAtTomcatWorkingDirectory_LIST.png1)


## ```Status of a project```
```
Java method com/staus/common/StatusFinder/status() calling Rest API of both 'Microsoft ServicePortal' and 'Microsoft Azure DevOps' using the script appStatus.psm1 with input parameters provided by UI to give us status at both platform 
```

### Location of Status file


![](src/main/webapp/images/StatusFilesLocation.png1)



### Status file

![](src/main/webapp/images/StatusFiles_Results.png1)


# How to run 

```
https://K/TicketStatus/faces/welcome.xhtml
```

Where
```-K``` = ServerINFO or if you are running localhost then arrange things to get "user.name". AD gets it for you.


# Screens output

![](src/main/webapp/images/howToRun.gif1)






