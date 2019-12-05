package com.om.common;

import java.io.Serializable;

import javax.faces.context.FacesContext;
import javax.servlet.ServletContext;

public class Authorization implements Serializable {
	private static final long serialVersionUID = 1L;
	private ServletContext context;
	
	/*
	 * You can type all things here and they will show up at the start of page.
	 */
	public Authorization() {
		context = (ServletContext) FacesContext.getCurrentInstance().getExternalContext().getContext();
		this.setOrgName("testOrg");
		this.setAzureUserName(System.getProperty("user.name")+"@abc.xyz");
		this.setSpUserName(System.getProperty("user.name"));
		
		//remove below 2
		this.setAzureToken("bringYourOwnAzurePAT");
		this.setSpPassword("ServicePortalPassword");
	}
	
	
	public Authorization(String orgName, String azureUserName, String azureToken,
			String projectName, String spUserName, String spPassword) {
		super();
		this.orgName = orgName;
		this.azureUserName = azureUserName;
		this.azureToken = azureToken;
		this.projectName = projectName;
		this.spUserName = spUserName;
		this.spPassword = spPassword;
	}


	private String orgName;
	/*
	 * Should be email id
	 */
	private String azureUserName;
	/*
	 * make sure this is active one
	 */
	private String azureToken;
	/*
	 * Reading from a file using RestAPI, showing via dropdown
	 */
	private String projectName;
	/*
	 * Should be firstName.lastName
	 */
	private String spUserName;
	/*
	 * Your STN desktop password
	 */
	private String spPassword;

	public String getOrgName() {
		return orgName;
	}

	public void setOrgName(String orgName) {
		this.orgName = orgName;
	}

	public String getProjectName() {
		return projectName;
	}

	public void setProjectName(String projectName) {
		this.projectName = projectName;
	}

	public String getAzureUserName() {
		return azureUserName;
	}

	public void setAzureUserName(String azureUserName) {
		this.azureUserName = azureUserName;
	}

	public String getAzureToken() {
		return azureToken;
	}

	public void setAzureToken(String azureToken) {
		this.azureToken = azureToken;
	}

	public String getSpUserName() {
		return spUserName;
	}

	public void setSpUserName(String spUserName) {
		this.spUserName = spUserName;
	}

	public String getSpPassword() {
		return spPassword;
	}

	public void setSpPassword(String spPassword) {
		this.spPassword = spPassword;
	}
	
	public String getAuthProjectInfo() {
		return (getOrgName() + "\t" + getAzureUserName() + "\t" + getAzureToken() + "\t");
	}

	public String getAuthStatusInfo() {
//		String modulePath = context.getRealPath("/PSfiles/appStatus.psm1");
		return (getOrgName() + "\t" + getProjectName().replace(" ", "%20") + "\t" + getAzureUserName() + "\t"
				+ getAzureToken() + "\t" + getSpUserName() + "\t" + getSpPassword()+ "\t");
	}

	@Override
	public String toString() {
		return "Authorization [context=" + context + ", orgName=" + orgName + ", azureUserName=" + azureUserName
				+ ", azureToken=" + azureToken + ", projectName=" + projectName + ", spUserName=" + spUserName
				+ ", spPassword=" + spPassword + "]";
	}
}