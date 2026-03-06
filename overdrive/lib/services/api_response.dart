/*
 ##
 ## OverDrive 2026
 ## All Technical rights reserved
 ##
 ## api_response.dart - Generic wrapper for API success/failure responses.
 ##
 */

class ApiResponse<T> {
    final T? data;
    final String? error;
    final bool isSuccess;

    const ApiResponse.success(this.data)
        : error = null,
        isSuccess = true;

    const ApiResponse.failure(this.error)
        : data = null,
        isSuccess = false;
}
