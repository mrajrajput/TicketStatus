package com.staus.common;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Serializable;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Stream;

import javax.annotation.PostConstruct;
import javax.enterprise.context.SessionScoped;
import javax.faces.application.FacesMessage;
import javax.faces.context.FacesContext;
import javax.faces.model.SelectItem;
import javax.inject.Inject;
import javax.inject.Named;
import javax.servlet.ServletContext;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVParser;
import org.apache.commons.csv.CSVRecord;
import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;

import com.constants.common.Constants;
import com.exceptiom.common.FetchProjectListFromApiException;
import com.exceptiom.common.FetchStatusListFromApiException;
import com.exceptiom.common.FetchTempFileFromApiException;
import com.om.common.Authorization;
import com.om.common.StatusInfo; 
import com.profesorfalken.jpowershell.PowerShell;

@Named
@SessionScoped
public class StatusFinder implements Serializable {
	private static Logger log = Logger.getLogger(StatusFinder.class);
	private static final long serialVersionUID = 1L;

	@Inject
	private Authorization auth;
	@Inject
	private transient ServletContext context;
	private List<SelectItem> applications_SI;
	private List<StatusInfo> statusInfoTable;
	private transient Path tempDir;
	private String modulePath;
	private String scriptPath;

	@PostConstruct
	public void init() {
		applications_SI = new ArrayList<>();
		context = (ServletContext) FacesContext.getCurrentInstance().getExternalContext().getContext();
		modulePath = context.getRealPath(File.separator + Constants.PSfiles + File.separator + Constants.AppStatusModule);
		scriptPath = context.getRealPath(File.separator + Constants.PSfiles + File.separator + Constants.FindStatus);
		try {
			//Getting created at for example: C:\Users\manjul.kumar\AppData\Local\Temp\1\Temp8371797832587079139
			tempDir = Files.createTempDirectory("Temp");
		} catch (IOException e) {
			log.error("Error while created a temp directory.", e);
		}
	}

	public String projects() {
		String logHelp = "processing of getting list of available Azure projects: " + auth.getProjectName() + ", User: "
				+ auth.getAzureUserName();
		log.info("Inside projects() method for " + logHelp);

		try (PowerShell powerShell = PowerShell.openSession()) {
			BufferedReader brApplications = new BufferedReader(new InputStreamReader(context
					.getResourceAsStream(File.separator + Constants.PSfiles + File.separator + Constants.FindProjects)));
			String dropdownPath = context.getRealPath(File.separator + "Temp" + File.separator + auth.getAzureUserName() + "_projectListFile.csv");
			String list = powerShell.executeScript(brApplications, auth.getAuthProjectInfo() + "\t" + modulePath + "\t" + dropdownPath).getCommandOutput();
			if(StringUtils.isBlank(list)) {
				throw new FetchProjectListFromApiException("Error while get list of projects from Azure API. ");
			}

			applications_SI = new ArrayList<>();
			Files.lines(Paths.get(dropdownPath), StandardCharsets.UTF_8).forEach(s -> {
				SelectItem si = new SelectItem();
				CSVParser csvParser;
				try {
					csvParser = CSVParser.parse(s, CSVFormat.DEFAULT);
					for (CSVRecord val : csvParser) {
						si.setLabel(val.get(0));
						si.setValue(val.get(0));
						applications_SI.add(si);
					}
				} catch (Exception e) {
					log.error("Error while preparing Select Item list of projects from CSV Parser.", e);
				}
			});
			log.info("Done. " + logHelp);
		} catch (IOException ioe) {
			log.error(new FetchTempFileFromApiException("Error while get list of Project at Temp file. "));
		} catch (FetchProjectListFromApiException fe) {
			log.error("Azure API exception, check module and log file for more help.", fe);
		} catch (Exception e) {
			log.error("Error while getting list of available Azure projects.", e);
		}
		return Constants.WelcomePage;
	}
	
	
	/**
	 * <p>This method is to call Rest API of both ServicePortal and Azure DevOps using the script appStatus.psm1 using
	 * input parameters provided by UI. There are no parameters, its taking input parameters to feed rest api by taking 
	 * values from {@code}Authorization java object</p>
	 * 
	 * @return To the same page where request is generated from.
	 * @author MKumar-001
	 */
	public String status(){
		if(StringUtils.isBlank(auth.getProjectName()) || StringUtils.equals("Select One", auth.getProjectName().trim())) {
			FacesContext.getCurrentInstance().addMessage(null, new FacesMessage(FacesMessage.SEVERITY_ERROR, "No project is selected from dropdown", ""));
			return Constants.WelcomePage;
		}
		statusInfoTable = new ArrayList<>();
		String logHelp = "processing of API for application: " + auth.getProjectName() + ", User: "
				+ auth.getAzureUserName();
		log.info("Inside status() method for " + logHelp);

		String outputFilePath = tempDir + File.separator + auth.getAzureUserName().trim() + "_"
				+ auth.getProjectName().trim().replace(" ", "%20") + "_statusFile.csv";
		try {
			Files.deleteIfExists(Paths.get(outputFilePath));
			String command = Constants.Powershell + "\t" + scriptPath + "\t" + auth.getAuthStatusInfo() + modulePath + "\t"
					+ outputFilePath;
			Process powerShellProcess = Runtime.getRuntime().exec(command);
			powerShellProcess.getOutputStream().close();
			if(readResponse(powerShellProcess)) {
				throw new FetchStatusListFromApiException("Error while fetch of status results while running module");
			}
			Thread.sleep(2000);
			log.info("Done calling api ");

			log.info("processing file for table");
			try (Stream<String> input = Files.lines(Paths.get(outputFilePath), StandardCharsets.UTF_8)) {
				input.forEach(s -> {
					StatusInfo si = new StatusInfo();
					try {
						si = setValues(s, si);
					} catch (IOException e) {
						log.error("Error while preparing Select Item list of applications from CSV Parser. ", e);
					}
					if (StringUtils.equalsIgnoreCase(si.getAzureId().toString().trim(), "AzureId")) {
						// ignore
					} else {
						statusInfoTable.add(si);
					}
				});
			} catch (IOException ioe) {
				throw new FetchTempFileFromApiException("Error while get list of status at Temp file", ioe);
			}
		} catch (FetchStatusListFromApiException e) {
			log.error("Error while Getting results from both/either APIs: ", e);
		} catch (IOException e) {
			log.error("IOException during processing of script to get status file.", e);
		}catch (Exception e) {
			log.error("Exception while getting and/or preparing status file.", e);
		}
		log.info("Total status records size is: " + statusInfoTable.size());
		log.info("Done. " + logHelp);
		return Constants.WelcomePage;
	}

	private boolean readResponse(Process powerShellProcess) throws IOException {
		boolean isError = false;
		String line;
		log.warn("Standard Output:");
		BufferedReader stdout = new BufferedReader(new InputStreamReader(powerShellProcess.getInputStream()));
		while ((line = stdout.readLine()) != null) {
			//line
		}
		stdout.close();
		BufferedReader stderr = new BufferedReader(new InputStreamReader(powerShellProcess.getErrorStream()));
		while ((line = stderr.readLine()) != null) {
			if (StringUtils.contains(line, "Error: ")) {
				FacesContext.getCurrentInstance().addMessage(null, new FacesMessage(FacesMessage.SEVERITY_ERROR, line.replace("Get-WorkItemsFromAzure :", ""), ""));
			}
			log.error(line);
			isError = true;
		}
		stderr.close();
		return isError;
	}
	
	private StatusInfo setValues(String s, StatusInfo si) throws IOException {
		CSVParser csvParser;
		try {
			csvParser = CSVParser.parse(s, CSVFormat.DEFAULT);
			for (CSVRecord val : csvParser) {
				si.setAzureId(Integer.parseInt(val.get(0)));
				si.setAzureStatus(val.get(1));
				si.setServicePortalStatus(val.get(2));
				si.setServicePortalID(val.get(3));
			}
			return si;
		} catch (IOException e) {
			log.error("Error while parsing the csv from API output ", e);
			throw e;
		}
	}
	
	public static void main(String[] args) {
		String str = "Get-WorkItemsFromAzure : Error: Azure API for WorkItem resulted in NO results";
		str.replaceFirst("Get-[A-Z].?\\s:", "");
		System.out.println(java.util.regex.Pattern.compile("(Get-WorkItemsFromAzure :).?").matcher(str).matches()); 
		System.out.println(str);
	}

	public Authorization getAuth() {
		return auth;
	}

	public void setAuth(Authorization auth) {
		this.auth = auth;
	}

	public String resetSpPassword() {
		auth.setSpPassword(null);
		return Constants.WelcomePage;
	}

	public String resetAzureToken() {
		auth.setAzureToken(null);
		return Constants.WelcomePage;
	}

	public List<StatusInfo> getStatusInfoTable() {
		return statusInfoTable;
	}

	public void setStatusInfoTable(List<StatusInfo> statusInfoTable) {
		this.statusInfoTable = statusInfoTable;
	}

	public List<SelectItem> getApplications_SI() {
		return applications_SI;
	}

	public void setApplications_SI(List<SelectItem> applications_SI) {
		this.applications_SI = applications_SI;
	}
}