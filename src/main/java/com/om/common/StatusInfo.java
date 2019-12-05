package com.om.common;

import java.io.Serializable;

public class StatusInfo implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private Integer azureId;
	private String azureStatus;
	private String servicePortalStatus;
	private String servicePortalID;
	
	
	public Integer getAzureId() {
		return azureId;
	}
	public void setAzureId(Integer azureId) {
		this.azureId = azureId;
	}
	public String getAzureStatus() {
		return azureStatus;
	}
	public void setAzureStatus(String azureStatus) {
		this.azureStatus = azureStatus;
	}
	public String getServicePortalStatus() {
		return servicePortalStatus;
	}
	public void setServicePortalStatus(String servicePortalStatus) {
		this.servicePortalStatus = servicePortalStatus;
	}
	public String getServicePortalID() {
		return servicePortalID;
	}
	public void setServicePortalID(String servicePortalID) {
		this.servicePortalID = servicePortalID;
	}
}
