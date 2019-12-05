#param(testOrg  manjul.kumar@abc.xyz  5m2yu2sfdfbmivzxxekdjc434346u4svbej7nxghi57lumdt4h6mwwmba, $modulePath, $AzureProjectsFilePath)
Import-Module -Force  C:\D\Workspace\TicketStatus\.metadata\.plugins\org.eclipse.wst.server.core\tmp4\wtpwebapps\TicketStatus\PSfiles\appStatus.psm1
Get-ResultsFromAPIs  testOrg  ProjectFoo  manjul.kumar@abc.xyz  5m2yu2sfdfbmivzxxekdjc434346u4svbej7nxghi57lumdt4h6mwwmba  manjul.kumar  DesktopPassword  C:\D\Workspace\TicketStatus\.metadata\.plugins\org.eclipse.wst.server.core\tmp3\wtpwebapps\TicketStatus\Temp\manjul.kumar@abc.xyz_statusFile.csv


#AzureOrgName  AzureLoginOrEmailId  AzurePAT ProjectName ServicePortalLogin ServicePortalPasswordWhichIsDesktopPassword
#orgName = (should be your Azure organizational name)