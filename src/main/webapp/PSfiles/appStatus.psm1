    class AppConfig {
        static [String] $File_allItemsSP   = "${HOME}\.$User $Project $(Get-Date -Format fff)fileServicePortal.json"
        static [String] $File_Azure   = "${HOME}\.$User $Project $(Get-Date -Format fff)fileAzure.csv"
        static [String] $Logfile = "${HOME}\.AzureAndServicePortal.log"
        
	    [String] $OrgName
	    [String] $Project
	    [String] $User
	    [String] $Token
		[String] $UserName_SP
	    [String] $Password_SP
		[String] $Language_SP
        [String] $Token_SP
		[String] $ApiId_SP

	    AppConfig([String] $OrgName, [String] $Project, [String] $User, [String] $Token, $UserName_SP, [String] $Password_SP) {
	   		Add-Content -Path $this::Logfile -Value "Calling Constructor with all parameters."
	        $this.OrgName=$OrgName
	        $this.Project=$Project
	        $this.User=$User
	        $this.Token=$Token	
            $this.UserName_SP = $UserName_SP
	        $this.Password_SP = $Password_SP
			$this.Language_SP = "ENU"	
			$this.populateServicePortal();
	    }
		
		#Azure items
        AppConfig([String] $OrgName, [String] $Project, [String] $User, [String] $Token) {
	        $this.OrgName=$OrgName
	        $this.Project=$Project
	        $this.User=$User
	        $this.Token=$Token	
	    }

		#Service Portal items
		AppConfig([String] $UserName_SP, [String] $Token_SP, [String] $ApiId_SP) {
	        $this.UserName_SP = $UserName_SP
	        $this.Token_SP = $Token_SP
			$this.ApiId_SP = $ApiId_SP
	    }

        AppConfig() {
             Add-Content -Path $this::Logfile -Value "Called Empty Constructor."	         
	    }
	    
	    [void] populateServicePortal() {
            # Calling Servie Portal API to get UserId and AccessToken and save in file as well with supplied parameters
            $credentials = @{
                 UserName=$this.UserName_SP
                 Password=$this.Password_SP
                 LanguageCode="ENU"
            }
            #"https://serviceportal.company.com/api/V3/Authorization/GetToken"
            $url_forToken = "https://serviceportal.company.com/api/V3/Authorization/GetToken"
            $jsonCredentials = $credentials | ConvertTo-Json

            $apiKeyToken = Invoke-RestMethod $url_forToken -Method POST -Body $jsonCredentials -ContentType 'application/json' 
            $uri_forUserId = "https://serviceportal.company.com/api/V3/User/IsUserAuthorized?userName=$((ConvertFrom-Json $jsonCredentials).UserName)&domain="
            
            $ApiId = Invoke-RestMethod  $uri_forUserId -Method POST -ContentType "application/json" -Headers @{"AUTHORIZATION"="Token "+$apiKeyToken} 
            $this.ApiId_SP = $ApiId.Id
            $this.Token_SP = $apiKeyToken
	    } 
		
	    [hashtable] GetHeaders(){
	        $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $this.User, $this.Token)))
	        return @{Authorization=("Basic {0}" -f $base64AuthInfo)} 
	    }
	}
	########################################################################################################################################
	###################################		FETCH PROJECTS FOR THIS Azure User - START	    ################################################
	########################################################################################################################################
	<#
	.SYNOPSIS
	Pulls all the projects using the below configured organization.
	
	.PARAMETER OrgName
    The OrgName(should be your Azure organizational name), at is it appears in its web url.

    .PARAMETER User
    The UserName of Azure, it should be your firstname.lastname@abc.xyz

    .PARAMETER Token
    The Current active Token of Azure.

    .PARAMETER AzureProjectsFilePath
    This is the path of file where your projects list will be stored. 
   
	.EXAMPLE 
	Find-Project -OrgName (should be your Azure organizational name) -User manjul.kumar@abc.xyz -Token @#$%%^^ -AzureProjectsFilePath c:/fakePath/
	#>
	function Find-Projects() {
	    [CmdletBinding()]
        Param(
	        [Parameter(Mandatory=$true)][String] $OrgName,
	        [Parameter(Mandatory=$true)][String] $User,
	        [Parameter(Mandatory=$true)][String] $Token,
	        [Parameter(Mandatory=$true)][String] $AzureProjectsFilePath
	    ) 
        $config = [AppConfig]::new($OrgName, '', $User, $Token)
        
	    $uri = "https://dev.azure.com/$($config.OrgName)/_apis/projects?api-version=5.0-preview.3"
	    $result = Invoke-RestMethod -Uri $uri -Method Get -ContentType "application/json" -Headers $config.GetHeaders()
	    if($result -Is [String]) {
	        Write-Error $result
	        throw "Rest Method Find-Projects() Failed!"
	    }
	    
	    Set-Content -Path "$AzureProjectsFilePath" -Value $result.value.name -Force -Encoding ASCII
	    return $result
	}
	########################################################################################################################################
	#########################################			END                  ###############################################################
	########################################################################################################################################
	
	
	########################################################################################################################################
	###################################		FETCH STATUS FROM AZURE AND SERVICE PORTAL FOR THIS User - START	############################
	########################################################################################################################################
	<#
	.SYNOPSIS
	Pulls The status from Service Portal and Azure Rest API using the below configured organization and stores in file given in path.
    
    .NOTES
    This is used with press of submit button to get status from Java. 
    working is:
    Instantiate class and store the input parameters into variables.
    Getting all items from service potal and storing the results in a file
    Getting all Azure work item and get Service portal status(by traversing the file) for each individula work item 
	
	.PARAMETER OrgName
    The OrgName(should be your Azure organizational name), at is it appears in its web url. This is required parameter.

    .PARAMETER User
    The UserName of Azure, it should be your firstname.lastname@abc.xyz. This is required parameter.

    .PARAMETER Token
    The Current active Token of Azure. This is required parameter.

    .PARAMETER UserName_SP
    The UserName of Service Portal, it should be your firstname.lastname. This is required parameter.

    .PARAMETER Password_SP
    The Password of Service Portal, it should be your STN(Desktop) Password. This is required parameter.

    .PARAMETER outputFilePath
    This is the path of file where your projects list will be stored. This is required parameter.
   
	.EXAMPLE 
	PS> Get-ResultsFromAPIs -OrgName (should be your Azure organizational name) -Project ProjectFoo -User manjul.kumar@abc.xyz 
                            -Token @#$%%^^  -UserName_SP manjul.kumar -Password_SP DesktopPass  -outputFilePath c:/fakePath/

    157	Active	Completed	SR569425
    155	Closed	Completed	SR567048
    710	Closed	Completed	SR628942
	#>
    function Get-ResultsFromAPIs {
	    [CmdletBinding()]
	    Param(
	        [Parameter(Mandatory=$true)][String] $OrgName,
	        [Parameter(Mandatory=$true)][String] $Project,
	        [Parameter(Mandatory=$true)][String] $User,
	        [Parameter(Mandatory=$true)][String] $Token,

			[Parameter(Mandatory=$true)][String] $UserName_SP,
	        [Parameter(Mandatory=$true)][String] $Password_SP,
	        [Parameter(Mandatory=$true)][String] $outputFilePath 
	    ) 
        $config     = [AppConfig]::new($OrgName, $Project, $User, $Token, $UserName_SP, $Password_SP)
        $LogFile    = [AppConfig]::Logfile
        $configFile = [AppConfig]::File_Azure
        "Called Constructor with all parameters and now calling service portal" | Out-File $LogFile -Append
        #Save all Tickets from Service Portal
        Get-AllItemsFromSP($config)
        #Save all Work items from Azure
        "Calling Azure and getting all items" | Out-File $LogFile -Append
        Get-WorkItemsFromAzure($config)
        "Moving all contents of file." | Out-File $LogFile -Append
        Move-Item -path  $configFile  -Destination "$outputFilePath" -Force
       # Add-Content -Path $outputFilePath -Value $contenta -Force -Encoding UTF8
       # (Get-Content $configFile) | Out-File $outputFilePath -Force -Encoding UTF8
	}
	
    <#
	.SYNOPSIS
	Pulls The status from Service Portal using the below configure object and stores in file given in path.
    
    .NOTES
    This cannot be called individually, but by Get-ResultsFromAPIs function only.  Get-ResultsFromAPIs > Get-AllItemsFromSP 
    working is:
    Instantiate class and store the input parameters into configure oject which gets passed to this function as configure.
    $resultNew.Title -replace "[^0-9]" , ''   Regex - to get number from title. 
    if($stateValue -ne "Cldosed") {           Take parameter from parent parameter and place instead of "Cldosed" 
    We are converting $result to json using convertTo-Json to get results in json file.
	
	.PARAMETER AzureConfig 
    The AzureConfig contins all metadata information. This is required parameter.

    .PARAMETER outputFilePath
    This is the path of file where your projects list will be stored. This is required parameter.
   
	.OUTPUT 
	@[{
     "statusValue":  "Completed",
     "AzureIdFromSP":  "4332",
     "srIDValue":  "SR689547"
     },
     {
        "statusValue":  "Completed",
        "AzureIdFromSP":  "987",
        "srIDValue":  "SR689546"
     }]
	#>
    function Get-AllItemsFromSP() { 
        #Assinged to my team
	    [CmdletBinding()]
	     Param(
	        [AppConfig] $config
	    )
         
        $credentials = @{
            UserName=$config.UserName
            Password=$config.Password
            LanguageCode='ENU'
        }
	    
        #Show all teams data
        #https://catserviceportal.company.com/api/V3/WorkItem/GetMyTeamRequest?userId=0129ad3c-a386-e3432444b-65e4-3966f4bd3992&showInactiveItems=true&isScoped=false	    

        #Assinged to my team:  Show STN\OCIO Support Web Dev  in Assigned To section at service portal website ==> isScoped = only false works. showActivities and showInactiveItems flipping doesnt matter :|
        #https://catserviceportal.company.com/api/V3/WorkItem/GetGridWorkItemsMyGroups?userId=0129ad3c-a3433243286-e44b-65e4-3966f4bd3992&isScoped=false&showActivities=false&showInactiveItems=true		
         
        #Fetch all Assinged to my team
        $uri = "https://serviceportal.company.com/api/V3/WorkItem/GetGridWorkItemsMyGroups?userId=$($config.ApiId_SP)&isScoped=false&showActivities=false&showInactiveItems=true"
	    $result = Invoke-RestMethod  $uri -Method GET -ContentType "application/json" -Headers @{"AUTHORIZATION"="Token "+$($config.Token_SP)} 
        
	    if($result -Is [String]) {
	        Write-Error $result
	        throw "Rest Method Failed!"
	    }
	    $numMembers =  $result.values.Length
        if($numMembers -eq 0) {
            Write-Error "Error: Service Portal API for finding tickets resulted in NO results"
            throw "Rest Method Failed with 0 output from Service Portal Rest API!"
        }
        
        $configFile = [AppConfig]::File_allItemsSP  
        $numMembers =  $result.values.Length
        for ($i = 0; $i -le $numMembers - 1; $i++) {
            $resultNew = $result.GetValue($i)
            $srIDValue = $resultNew.Id
            $AzureIdFromSP = ''
            if($resultNew.Title.toString() -match "#[0-9]"){
                $AzureIdFromSP = $resultNew.Title -replace "[^0-9]" , ''
            }
            #$AzureIdFromSP = ({""},$resultNew.Title)[$resultNew.Title.toString() -match "#[0-9]"]
            $statusValue = $resultNew.Status
            if($stateValue -ne "Cldosed") {
                 $output = ConvertTo-Json @{
	                statusValue=$statusValue
	                srIDValue=$srIDValue
	                AzureIdFromSP=$AzureIdFromSP
	             }
                ConvertTo-Json $output -depth 100
                #some dirty hack to convert to JSON, I should know better. -Manjul Kumar
                if($i -eq 0){
                    "[$output," | Out-File $configFile -Append
                }elseif($i -ne $numMembers - 1){
                   "$output," | Out-File $configFile -Append
                }else{
                    "$output]" | Out-File $configFile -Append
                }
	        }#Ending Closed status if
        }#Ending for loop for traversing result from API.

	    #return $result
	}
	
    <#
	.SYNOPSIS
	Pulls The status from Service Portal using the below configure object and stores in file given in path.
    
    .NOTES
    This cannot be called individually, but by Get-ResultsFromAPIs function only.  
    Get-ResultsFromAPIs > Get-WorkItemsFromAzure Then calling Get-spItemStatus
    Working is:
    Instantiate class and store the input parameters into configure oject which gets passed to this function as configure.
    Retuning back as error with message if NO results are found. 
    $result = $result | ConvertTo-Json | ConvertFrom-Json   =   data corruption issue fix, basically converting the data into readbable form
    #$rState = $result  =  for state
    if($stateValue -ne "Cldosed") {     =      Take parameter from parent parameter and place instead of "Cldosed" 
    We are converting $result to json using convertTo-Json to get results in json file.
        
	
	.PARAMETER AzureConfig 
    The AzureConfig contins all metadata information. This is required parameter.

    .PARAMETER outputFilePath
    This is the path of file where your projects list will be stored. This is required parameter.
   
	.OUTPUT 
	376	     New	 CREATED	 SR25632
    1042	 New	 NOT FOUND	 NOT FOUND

	#>
	function Get-WorkItemsFromAzure() {
	    [CmdletBinding()]
	     Param(
	        [AppConfig] $config
	    ) 
        $configFile = [AppConfig]::File_allItemsSP  
        $configFileAzure = [AppConfig]::File_Azure  

        $newResult = "";
        $uri = "https://dev.azure.com/$($config.OrgName)/$($config.Project)/_apis/wit/reporting/workitemrevisions?includeLatestOnly=TRUE&api-version=5.0"
        DO {
            $result = Invoke-RestMethod -Uri $uri -Method GET -ContentType "application/json" -Headers  $config.GetHeaders()
             if($result -Is [String]) {
	            Write-Error $result
	            throw "Rest Method Failed!"
	        }
	        $numMembers =  $result.values.Length
            if($numMembers -eq 0) {
	            Write-Error "Error: Azure API for WorkItem resulted in NO results"
	            throw "Rest Method Failed with 0 output from Azure Rest API!"
	        }

            #There are next items, so add these to big var unless its empty(if empty, just put to big var)
            if($newResult -ne ""){
                foreach ($property in $result.psobject.Properties) {
                    foreach ($array in $result.$($property.Name)) {
                            $newResult.$($property.Name) += $array
                    }
                }
            }else{
                #if empty, 1st time, just put to big var
                $newResult = $result
            }


            if($result.isLastBatch.ToString() -eq "False"){
                  $uri = $result.nextLink
            }
            #Write-Host $result.NextLink
        } While ($result.isLastBatch.ToString() -eq "False" -and $result.NextLink.ToString() -ne "")
        
        #for state
        $rState = $newResult
		$result = $newResult | ConvertTo-Json | ConvertFrom-Json
        $result.values = $newResult.values | Sort-Object -Property  @{Expression = "id"; Descending = $False}, @{Expression = "rev"; Descending = $True}
        $preValue = "0";
        for ($i = 0; $i -le $numMembers - 1; $i++) {
            $resultAzure = $result.values[$i]
            $idValue_Azure = $resultAzure.id
            if($preValue -ne $idValue_Azure){
                $preValue = $idValue_Azure;
                $stateValue_Azure = $rState.values[$i].fields.'System.State'
                #if(Status -ne "closed"){ write to file}
                if($stateValue -ne "Cldosed") {
                    #go check Service portal file stored locally for this id: $idValue
                    $objectFromSP = Get-spItemStatus($idValue_Azure)
                    if($objectFromSP -ne "NOT FOUND"){
                        $objSP = ConvertTo-Json -InputObject $objectFromSP
                        $srIDValueSP = (ConvertFrom-Json $objSP)."srIDValue"
                        $statusValueSP = (ConvertFrom-Json $objSP)."statusValue"   
                    }else{
                        $srIDValueSP = $objectFromSP
                        $statusValueSP = $objectFromSP
                    }
                    #"$idValue_Azure, $stateValue_Azure, $statusValueSP, $srIDValueSP" | Out-File $configFileAzure -Append
                    Add-Content -Path $configFileAzure -Value "$idValue_Azure, $stateValue_Azure, $statusValueSP, $srIDValueSP"
	            }
            }
        }


        
	}
	
	#Get-ResultsFromAPIs > Get-WorkItemsFromAzure > Get-spItemStatus
    function  Get-spItemStatus([String] $idValue){
        [CmdletBinding()]
        #Get file store from drive        
        $configFile = [AppConfig]::File_allItemsSP     
        if( !(Get-Item $configFile -ErrorAction SilentlyContinue)){
	        throw "$configFile not found!  Use Set-AppConfig" 
	    }
	   
        $result = ConvertFrom-Json (Get-Content -Path $configFile | Out-String)
        #$JSON = Get-Content -Path $configFile  | ConvertFrom-Json
        $placeHolder = "";
        $result | ForEach-Object {
            if($idValue -eq $_.AzureIdFromSP){
               $placeHolder =  $_
             }
        }
        if($placeHolder -ne ""){
            return $placeHolder
        } else {
            return "NOT FOUND"
        }
    }
	########################################################################################################################################
	#########################################			END                  ###############################################################
	########################################################################################################################################
	
	
	

    #Test Method for Service Portal Items
    function Get-spItem() {
	    [CmdletBinding()]
        $url_forToken = "https://serviceportal.company.com/api/V3/Authorization/GetToken"
        $credentials = @{
            UserName='manjul.kumar'
            Password='xxxxxxx Desktop password'
            LanguageCode='ENU'
        }
        $jsonCredentials = $credentials | ConvertTo-Json
	    
        $apiKey = Invoke-RestMethod $url_forToken -Method POST -Body $jsonCredentials -ContentType 'application/json' 
        $uri_forUserId = "https://serviceportal.company.com/api/V3/User/IsUserAuthorized?userName=$((ConvertFrom-Json $jsonCredentials).UserName)&domain="
        $result = Invoke-RestMethod  $uri_forUserId -Method POST -ContentType "application/json" -Headers @{"AUTHORIZATION"="Token "+$apiKey} 
        write-host $result.Id

	    return $result
	}
	#Test Method for Azure single WorkItem
    function Get-WorkItem {
	    [CmdletBinding()]
	    Param(
		    [Parameter(Position=1, Mandatory=$true)][int] $id,
			[string[]] $fields,
			[string[]] $expand, # None, Relations, Fields, Links, All
			
	        [Parameter(Mandatory=$true)][String] $OrgName,
	        [Parameter(Mandatory=$true)][String] $Project,
	        [Parameter(Mandatory=$true)][String] $User,
	        [Parameter(Mandatory=$true)][String] $Token
	    )
        Set-Content -Path "${HOME}\.fileAzure.json" -Value "Id      AzureStatus     ServicePortalStatus"
	    
		#config is object of AppConfig
	    $config = [AppConfig]::load() 
	    $config = [AppConfig]::new($conf.OrgName, $conf.Project, $conf.User, $plaintext)
	    $uri = "https://dev.azure.com/$($config.OrgName)/$($config.Project)/_apis/wit/workitems/${id}?api-version=4.1"

	    if( $fields ){
		$uri += "&fields=$fields"
	    }

	   if( $expand ){
		# this needs a literal $ in the variable name!
		$uri += "&`$expand=$expand"
	   }

	    write-verbose $uri
	    $result = Invoke-RestMethod -Uri $uri -Method Get -ContentType "application/json" -Headers $config.GetHeaders()
	    if($result -Is [String]) {
	        Write-Error $result
	        throw "Rest Method Failed!"
	    }

        $result = ConvertTo-Json -InputObject $result
        $stateValue = (ConvertFrom-Json $result).fields."System.State"
        $idValue = (ConvertFrom-Json $result).id   
        if($stateValue -ne "Closed") {
           Add-Content -Path "${HOME}\.fileAzure.json" -Value "$idValue      $stateValue     "
	    }                
        
	    return $result
	}     
	function Set-AppConfig {
	    [CmdletBinding()]
	    Param(
	        [Parameter(Mandatory=$true)][String] $OrgName,
	        [Parameter(Mandatory=$true)][String] $Project,
	        [Parameter(Mandatory=$true)][String] $User,
	        [Parameter(Mandatory=$true)][String] $Token,

			[Parameter(Mandatory=$true)][String] $UserName_SP,
	        [Parameter(Mandatory=$true)][String] $Password_SP,
	        [Parameter(Mandatory=$true)][String] $outputFilePath 
	    ) 
		#config is object of AppConfig
	    $config = [AppConfig]::new($OrgName, $Project, $User, $Token, $UserName_SP, $Password_SP)
        #Save all Tickets from Service Portal
        Get-AllItemsFromSP($config)
        #Save all Work items from Azure
        Get-WorkItemsFromAzure($config)
        #this is html conversion
        (Get-Content [AppConfig]::File_Azure) | Out-File $outputFilePath -Force -Encoding UTF8
        #Import-Csv [AppConfig]::File_Azure > $outHTMLfile
	}
	
 
	Export-ModuleMember AppConfig
	#This is for finding projects/appications
	Export-ModuleMember Find-Projects
	#This is for finding status list
    Export-ModuleMember Get-ResultsFromAPIs
    Export-ModuleMember Get-AllItemsFromSP
    Export-ModuleMember Get-WorkItemsFromAzure
    Export-ModuleMember Get-spItemStatus
    #This is for test
    Export-ModuleMember Set-AppConfig
	Export-ModuleMember Get-WorkItem
	Export-ModuleMember Get-spItem