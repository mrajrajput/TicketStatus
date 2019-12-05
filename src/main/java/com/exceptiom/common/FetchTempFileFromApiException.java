package com.exceptiom.common;
/**
 * Thrown while Fetching of Status/Project file results in error.
 */
public class FetchTempFileFromApiException extends Exception {
	private static final long serialVersionUID = 1L;

	public FetchTempFileFromApiException(String message) {
		super(message);
	}

	public FetchTempFileFromApiException(Throwable cause) {
		super(cause);
	}

	public FetchTempFileFromApiException(String message, Throwable cause) {
		super(message, cause);
	}

}