package com.exceptiom.common;
/**
 * Thrown while Fetching of result from SercicePortak and Azure API ends up in error.
 */
public class FetchStatusListFromApiException extends Exception {
	private static final long serialVersionUID = 1L;

	public FetchStatusListFromApiException(String message) {
		super(message);
	}

	public FetchStatusListFromApiException(Throwable cause) {
		super(cause);
	}

	public FetchStatusListFromApiException(String message, Throwable cause) {
		super(message, cause);
	}

}