package com.exceptiom.common;
/**
 * Thrown while Fetching of result from SercicePortak and Azure API ends up in error.
 */
public class FetchProjectListFromApiException extends Exception {
	private static final long serialVersionUID = 1L;

	public FetchProjectListFromApiException(String message) {
		super(message);
	}

	public FetchProjectListFromApiException(Throwable cause) {
		super(cause);
	}

	public FetchProjectListFromApiException(String message, Throwable cause) {
		super(message, cause);
	}

}