# ClickUp Integration API Contract for Mobile Team

This document outlines the subset of **ClickUp Integration Endpoints** actively used in production. All payloads are represented in standard JSON format (without TypeScript interfaces) for seamless integration with Dart/Flutter models.

---

## 1. Global Response Envelope
All Requra API endpoints wrap their response payloads in a standard envelope structure:

```json
{
  "isSuccess": true,
  "statusCode": 200,
  "message": "Success",
  "data": {},
  "errors": null
}
```

### Envelope Key Definitions
*   **`isSuccess`** (`bool`): Indicates if the API request completed successfully on the backend.
*   **`statusCode`** (`int`): The HTTP status code of the response.
*   **`message`** (`String`): A human-readable message describing the outcome.
*   **`data`** (`Map` / `List` / `null`): The payload representing the core data requested, or `null` if no data is returned.
*   **`errors`** (`List<String>` / `null`): Lists details about validation errors or execution exceptions if `isSuccess` is `false`.

---

## 2. ClickUp Authentication Flow (OAuth 2.0)

To connect ClickUp, the application uses an OAuth 2.0 flow. The mobile app requests a redirect URL, navigates the user to ClickUp's secure consent screen, captures the authorization code, and registers the connection on our backend.

### 2.1 Initiate ClickUp Connection
Generates the secure ClickUp OAuth 2.0 authorization URL to redirect the user.

*   **Method:** `GET`
*   **Path:** `/api/ClickUp/auth/authorize`
*   **Query Parameters:**
    *   `projectId` (String, required): The UUID of the project to associate with the connection.
*   **Full Success Response Example:**
    ```json
    {
      "isSuccess": true,
      "statusCode": 200,
      "message": "Authorized url successfully generated",
      "data": {
        "authUrl": "https://app.clickup.com/api?client_id=YOUR_CLIENT_ID&redirect_uri=https%3A%2F%2Fapi.requra.com%2Fapi%2FClickUp%2Fauth%2Fcallback&state=PROJECT_UUID",
        "projectId": "7df6a504-20b3-40f4-842b-548f498f3ab2"
      },
      "errors": null
    }
    ```

#### **Field Explanations inside `data`:**
*   **`authUrl`** (`String`): The consent URL hosted by ClickUp. The Flutter app must open this URL in a browser or inside an interactive `WebView` so the user can log in and authorize the integration.
*   **`projectId`** (`String`): The UUID of the Requra project associated with the request.

---

### 2.2 Complete ClickUp Connection (OAuth Callback)
Handles the code exchange returned by ClickUp's redirect and saves the credentials securely on the backend.

*   **Method:** `POST`
*   **Path:** `/api/ClickUp/auth/callback`
*   **Request Headers:**
    *   `Content-Type: application/json`
*   **Request Body JSON:**
    ```json
    {
      "code": "cl_oauth_code_here",
      "projectId": "7df6a504-20b3-40f4-842b-548f498f3ab2"
    }
    ```
*   **Full Success Response Example:**
    ```json
    {
      "isSuccess": true,
      "statusCode": 200,
      "message": "ClickUp connection successfully authorized",
      "data": null,
      "errors": null
    }
    ```

#### **Field Explanations:**
*   **`data`** is `null` here. The Flutter app should check that `isSuccess` is `true` to confirm that the connection has been successfully established and saved.

---

## 3. ClickUp Connection Management

### 3.1 Get ClickUp Connection Status
Checks if ClickUp is currently linked to the project and returns configuration details.

*   **Method:** `GET`
*   **Path:** `/api/ClickUp/status/{projectId}`
*   **Full Success Response Example (Connected):**
    ```json
    {
      "isSuccess": true,
      "statusCode": 200,
      "message": "Loaded status",
      "data": {
        "isConnected": true,
        "teamId": "9002013",
        "spaceId": "3450912",
        "listId": "900502123485",
        "tokenExpired": false,
        "expiresAt": "2026-11-17T11:49:31.000Z"
      },
      "errors": null
    }
    ```
*   **Full Success Response Example (Not Connected):**
    ```json
    {
      "isSuccess": true,
      "statusCode": 200,
      "message": "Loaded status",
      "data": {
        "isConnected": false,
        "teamId": null,
        "spaceId": null,
        "listId": null,
        "tokenExpired": false,
        "expiresAt": null
      },
      "errors": null
    }
    ```

#### **Field Explanations inside `data`:**
*   **`isConnected`** (`bool`): `true` if this project is currently connected to ClickUp, `false` otherwise.
*   **`teamId`** (`String` or `null`): The ID of the authenticated ClickUp Workspace.
*   **`spaceId`** (`String` or `null`): The ID of the connected ClickUp Space.
*   **`listId`** (`String` or `null`): The ID of the target ClickUp List where export tasks will be created.
*   **`tokenExpired`** (`bool`): `true` if the server's access token is no longer valid, requiring the user to disconnect and re-authenticate.
*   **`expiresAt`** (`String` or `null`): An ISO 8601 UTC timestamp showing when the token will expire.

---

### 3.2 Disconnect ClickUp Connection
Breaks the active connection, clearing authorization credentials server-side for the specified project.

*   **Method:** `POST`
*   **Path:** `/api/ClickUp/disconnect/{projectId}`
*   **Request Body:** Empty
*   **Full Success Response Example:**
    ```json
    {
      "isSuccess": true,
      "statusCode": 200,
      "message": "ClickUp disconnected successfully",
      "data": null,
      "errors": null
    }
    ```

---

## 4. Work Item Exporting

### 4.1 Push Approved User Stories to ClickUp
Pushes all currently **approved** user stories in Requra to the configured ClickUp List. It handles creating new tasks on ClickUp or updating existing ones if already linked.

*   **Method:** `POST`
*   **Path:** `/api/ClickUp/push/{projectId}/approved`
*   **Request Body:** Empty
*   **Full Success Response Example:**
    ```json
    {
      "isSuccess": true,
      "statusCode": 200,
      "message": "Approved stories exported to ClickUp successfully",
      "data": {
        "projectId": "7df6a504-20b3-40f4-842b-548f498f3ab2",
        "createdCount": 2,
        "updatedCount": 1,
        "failedCount": 0,
        "skippedCount": 0,
        "totalCount": 3,
        "details": [
          {
            "userStoryId": "US-001",
            "clickUpTaskId": "862k9v1b0",
            "action": "Created",
            "success": true,
            "message": null
          },
          {
            "userStoryId": "US-002",
            "clickUpTaskId": "862k9v1b1",
            "action": "Created",
            "success": true,
            "message": null
          },
          {
            "userStoryId": "US-003",
            "clickUpTaskId": "862k7x2yz",
            "action": "Updated",
            "success": true,
            "message": null
          }
        ],
        "message": "Export completed: 2 created, 1 updated."
      },
      "errors": null
    }
    ```

#### **Field Explanations inside `data`:**
*   **`projectId`** (`String`): The UUID of the Requra project.
*   **`createdCount`** (`int`): Count of user stories that had no existing link and were created as new tasks in ClickUp.
*   **`updatedCount`** (`int`): Count of pre-existing linked user stories whose task descriptions/titles were updated in ClickUp.
*   **`failedCount`** (`int`): Count of stories that failed to export.
*   **`skippedCount`** (`int`): Count of stories skipped (e.g., if they had not changed).
*   **`totalCount`** (`int`): Total count of approved user stories evaluated during this export.
*   **`message`** (`String`): A short status summary.
*   **`details`** (`List`): Individual push status for each story:
    *   **`userStoryId`** (`String`): The identifier of the story (e.g., `"US-001"`).
    *   **`clickUpTaskId`** (`String` or `null`): The task ID on ClickUp.
    *   **`action`** (`String`): Mapped to `"Created"`, `"Updated"`, `"Skipped"`, or `"Failed"`.
    *   **`success`** (`bool`): `true` if this individual task sync succeeded, `false` otherwise.
    *   **`message`** (`String` or `null`): Error details if `success` is `false`.

---

## 5. Standard Error Response Example
If an integration error or connection issue occurs, the backend returns a non-200 status code inside the payload.

```json
{
  "isSuccess": false,
  "statusCode": 401,
  "message": "ClickUp authorization token is invalid or expired. Please reconnect.",
  "data": null,
  "errors": ["OAuthTokenExpiredException"]
}
```
