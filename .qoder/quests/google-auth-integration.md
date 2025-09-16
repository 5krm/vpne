# Google Authentication Integration Design

## 1. Overview

This document outlines the design for integrating Google authentication into the Eclipse VPN application. The integration will allow users to create accounts and sign in using their Google credentials, providing a simplified and secure authentication experience.

The implementation will involve:
- Backend modifications to support Google OAuth2 authentication
- Frontend (Flutter) integration with Google Sign-In SDK
- Database schema updates to accommodate Google user data
- API endpoint additions for Google authentication

### 1.1 Current Authentication System

The Eclipse VPN application currently implements a dual-mode authentication system:
1. **Device-based guest access**: Users can access basic features using only their device ID
2. **Email/password registration**: Users can create full accounts with email, password, and phone number

The Google authentication integration will add a third authentication method while maintaining compatibility with existing systems.

### 1.2 Account Linking Scenarios

The implementation will handle several account linking scenarios:
1. **New Google User**: A user authenticates with Google for the first time
2. **Existing Email User**: A user with an existing email/password account links their Google account
3. **Existing Guest User**: A guest user (device-only) upgrades to a Google account
4. **Cross-Platform Users**: Users accessing their account from different devices

## 2. Architecture

### 2.1 System Components

``mermaid
graph TD
    A[Flutter App] --> B[Google Sign-In SDK]
    A --> C[Backend API]
    B --> D[Google OAuth2]
    C --> E[Database]
    C --> D
```

### 2.2 Authentication Flow

``mermaid
sequenceDiagram
    participant U as User
    participant F as Flutter App
    participant G as Google
    participant B as Backend API
    participant D as Database

    U->>F: Tap Google Sign-In
    F->>G: Request Google Authentication
    G->>F: Return ID Token
    F->>B: Send ID Token for Verification
    B->>G: Verify ID Token
    G->>B: Token Valid + User Info
    B->>D: Check if User Exists
    D->>B: User Data
    B->>F: Return Auth Token
    F->>U: Navigate to Home Screen
```

## 3. Backend Implementation

### 3.1 Dependencies

Add the required packages to `composer.json`:
```json
{
  "require": {
    "google/apiclient": "^2.12.0"
  }
}
```

### 3.2 Database Schema

The existing `users` table will be extended to support Google authentication. A migration will be created to add the `google_id` column:

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('google_id')->nullable()->unique()->after('id');
            $table->index('google_id');
        });
    }

    public function down()
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropIndex(['google_id']);
            $table->dropColumn('google_id');
        });
    }
};
```

Updated `users` table schema:

| Column | Type | Description |
|--------|------|-------------|
| id | bigint(20) UNSIGNED | Primary key |
| google_id | varchar(255) | Google user ID (nullable, unique) |
| name | varchar(100) | User's full name |
| email | varchar(255) | User's email (unique) |
| phone | varchar(255) | Phone number |
| password | varchar(255) | Password hash (nullable for Google users) |
| otp | varchar(6) | One-time password |
| expires_at | timestamp | OTP expiration timestamp |
| is_verified | tinyint(1) | Email verification status |
| login_mode | varchar(20) | 'guest', 'pro', or 'google' |
| device_id | varchar(255) | Device identifier |
| profile_image | text | Profile image URL |
| status | tinyint(3) | Account status |
| remember_token | varchar(100) | Remember me token |
| created_at | timestamp | Creation timestamp |
| updated_at | timestamp | Last update timestamp |

### 3.3 API Endpoints

#### 3.3.1 Google Authentication Endpoint

**POST** `/api/auth/google`

**Request Body:**
```json
{
  "google_token": "string",
  "device_id": "string"
}
```

**Response (Success):**
```json
{
  "status": "success",
  "message": "Authentication successful.",
  "data": {
    "user": {
      "id": 1,
      "name": "John Doe",
      "email": "john.doe@gmail.com",
      "login_mode": "google",
      "device_id": "device123",
      "profile_image": "https://...",
      "created_at": "2023-01-01T00:00:00.000000Z",
      "updated_at": "2023-01-01T00:00:00.000000Z"
    },
    "access_token": "1|abcdefghijk...",
    "token_type": "Bearer"
  }
}
```

**Response (Account Linking Required):**
```json
{
  "status": "account_linking_required",
  "message": "An account with this email already exists. Please link your Google account.",
  "data": {
    "email": "john.doe@gmail.com",
    "login_mode": "pro"
  }
}
```

### 3.4 Controller Implementation

Create a new controller `GoogleAuthController.php`:

```php
<?php

namespace App\Http\Controllers\Api\Auth;

use App\Http\Controllers\Api\BaseController;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Google_Client;

class GoogleAuthController extends BaseController
{
    public function authenticate(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'google_token' => 'required|string',
                'device_id' => 'required|string|max:255',
            ]);

            if ($validator->fails()) {
                return $this->validationErrorResponse($validator);
            }

            // Verify Google token
            $client = new Google_Client(['client_id' => env('GOOGLE_CLIENT_ID')]);
            $payload = $client->verifyIdToken($request->google_token);
            
            if (!$payload) {
                return $this->formatResponse(null, 'Invalid Google token.', 401);
            }

            // Extract user info from Google payload
            $googleId = $payload['sub'];
            $email = $payload['email'];
            $name = $payload['name'] ?? '';
            $profileImage = $payload['picture'] ?? null;

            // Find or create user
            $user = User::where('google_id', $googleId)->first();
            
            if (!$user) {
                // Check if user already exists with this email
                $existingUser = User::where('email', $email)->first();
                
                if ($existingUser) {
                    // User exists with email but not linked to Google
                    if ($existingUser->login_mode !== 'google') {
                        // For security, we require explicit account linking
                        // rather than automatically linking accounts
                        return $this->accountLinkingRequiredResponse($email, $existingUser->login_mode);
                    }
                    $user = $existingUser;
                } else {
                    // Create new user
                    $user = User::create([
                        'google_id' => $googleId,
                        'name' => $name,
                        'email' => $email,
                        'device_id' => $request->device_id,
                        'login_mode' => 'google',
                        'profile_image' => $profileImage,
                        'status' => 0,
                    ]);
                }
            } else {
                // Update device ID if different
                if ($user->device_id !== $request->device_id) {
                    $user->update(['device_id' => $request->device_id]);
                }
            }

            // Generate access token
            $token = $user->createToken('user_token')->plainTextToken;
            
            return $this->successResponse($user, $token, 'Authentication successful.');

        } catch (\Exception $e) {
            return $this->handleException($e);
        }
    }

    // New endpoint for explicit account linking
    public function linkAccount(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'google_token' => 'required|string',
                'email' => 'required|email',
                'password' => 'required|string',
            ]);

            if ($validator->fails()) {
                return $this->validationErrorResponse($validator);
            }

            // Verify Google token
            $client = new Google_Client(['client_id' => env('GOOGLE_CLIENT_ID')]);
            $payload = $client->verifyIdToken($request->google_token);
            
            if (!$payload) {
                return $this->formatResponse(null, 'Invalid Google token.', 401);
            }

            // Verify email/password credentials
            $user = User::where('email', $request->email)->first();
            
            if (!$user || !\Illuminate\Support\Facades\Hash::check($request->password, $user->password)) {
                return $this->formatResponse(null, 'Invalid email or password.', 401);
            }

            // Extract Google ID
            $googleId = $payload['sub'];
            $profileImage = $payload['picture'] ?? null;

            // Link Google account
            $user->update([
                'google_id' => $googleId,
                'login_mode' => 'google',
                'profile_image' => $profileImage,
            ]);

            // Generate access token
            $token = $user->createToken('user_token')->plainTextToken;
            
            return $this->successResponse($user, $token, 'Account linked successfully.');

        } catch (\Exception $e) {
            return $this->handleException($e);
        }
    }

    private function successResponse($user, $token, $message)
    {
        return response()->json([
            'status' => 'success',
            'message' => $message,
            'data' => [
                'user' => $user->only(
                    'id', 'name', 'email', 'login_mode', 'device_id', 
                    'profile_image', 'created_at', 'updated_at'
                ),
                'access_token' => $token,
                'token_type' => 'Bearer'
            ]
        ], 200);
    }

    private function accountLinkingRequiredResponse($email, $loginMode)
    {
        return response()->json([
            'status' => 'account_linking_required',
            'message' => 'An account with this email already exists. Please link your Google account.',
            'data' => [
                'email' => $email,
                'login_mode' => $loginMode
            ]
        ], 409);
    }
}
```

### 3.5 Route Configuration

Add the following routes to `routes/api.php`:

```php
// Google Auth API
Route::post('auth/google', [GoogleAuthController::class, 'authenticate']);
Route::post('auth/google/link', [GoogleAuthController::class, 'linkAccount']);
```

### 3.6 Environment Configuration

Add the following to `.env` file:

```env
GOOGLE_CLIENT_ID=your_google_client_id_here
```

## 4. Flutter Implementation

### 4.1 Dependencies

Add the following dependencies to `pubspec.yaml`:

```yaml
dependencies:
  google_sign_in: ^5.4.4
```

Note: We only need `google_sign_in` package since the Eclipse VPN app already includes Firebase dependencies.

### 4.2 Google Auth Controller

Extend the existing `AuthController` with Google authentication methods:

```dart
import 'package:google_sign_in/google_sign_in.dart';

class AuthController extends GetxController {
  
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
  );
  
  Future<ResponseModel> googleSignIn() async {
    _isLoading = true;
    update();
    
    try {
      // Sign out from previous sessions
      await _googleSignIn.signOut();
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        _isLoading = false;
        update();
        return ResponseModel(false, 'Google sign in aborted by user.');
      }
      
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;
      
      // Validate that we have an ID token
      if (googleAuth.idToken == null || googleAuth.idToken!.isEmpty) {
        _isLoading = false;
        update();
        return ResponseModel(false, 'Failed to get Google ID token.');
      }
      
      String deviceId = await getDeviceId();
      
      Response response = await googleAuthClient(
        googleToken: googleAuth.idToken!,
        deviceId: deviceId,
      );
      
      if (response.statusCode == 200) {
        RegisterModel registerModel = registerModelFromJson(response.body);
        saveUserToken(registerModel.data?.accessToken ?? '');
        _isLoading = false;
        update();
        return ResponseModel(true, response.body);
      } else if (response.statusCode == 409) {
        // Account linking required
        _isLoading = false;
        update();
        return ResponseModel(false, response.body, 409);
      } else {
        _isLoading = false;
        update();
        return ResponseModel(false, response.body, response.statusCode);
      }
    } catch (e) {
      _isLoading = false;
      update();
      return ResponseModel(false, 'Google sign in failed: ${e.toString()}');
    }
  }
  
  Future<ResponseModel> linkGoogleAccount(String email, String password) async {
    _isLoading = true;
    update();
    
    try {
      // Get current Google user
      final GoogleSignInAccount? googleUser = await _googleSignIn.signInSilently();
      
      if (googleUser == null) {
        _isLoading = false;
        update();
        return ResponseModel(false, 'No Google account found.');
      }
      
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;
      
      // Validate that we have an ID token
      if (googleAuth.idToken == null || googleAuth.idToken!.isEmpty) {
        _isLoading = false;
        update();
        return ResponseModel(false, 'Failed to get Google ID token.');
      }
      
      Response response = await googleLinkAccountClient(
        googleToken: googleAuth.idToken!,
        email: email,
        password: password,
      );
      
      if (response.statusCode == 200) {
        RegisterModel registerModel = registerModelFromJson(response.body);
        saveUserToken(registerModel.data?.accessToken ?? '');
        _isLoading = false;
        update();
        return ResponseModel(true, response.body);
      } else {
        _isLoading = false;
        update();
        return ResponseModel(false, response.body, response.statusCode);
      }
    } catch (e) {
      _isLoading = false;
      update();
      return ResponseModel(false, 'Account linking failed: ${e.toString()}');
    }
  }
  
  Future<Response> googleAuthClient({
    required String googleToken,
    required String deviceId,
  }) async {
    return await apiClient.postData(MyHelper.googleAuthUrl, {
      "google_token": googleToken,
      "device_id": deviceId,
    });
  }
  
  Future<Response> googleLinkAccountClient({
    required String googleToken,
    required String email,
    required String password,
  }) async {
    return await apiClient.postData(MyHelper.googleLinkAccountUrl, {
      "google_token": googleToken,
      "email": email,
      "password": password,
    });
  }
  
  // Method to disconnect Google account
  Future<void> disconnectGoogleAccount() async {
    await _googleSignIn.disconnect();
  }
}
```

### 4.3 UI Integration

Add Google Sign-In button to both login and registration screens:

#### Login Screen Modification

In `login_screen.dart`, add the Google Sign-In button:

```dart
// Add after the "Create Account" button
const SizedBox(height: 20),

// Google Sign-In Button
GetBuilder<AuthController>(builder: (authController) {
  return ModernButton(
    text: 'Sign In with Google',
    icon: Icons.account_circle_outlined,
    isLoading: authController.isLoading,
    isOutlined: true,
    onPressed: () {
      FocusScope.of(context).unfocus();
      authController.googleSignIn().then((responseModel) {
        if (responseModel.isSuccess) {
          homeController.getUsers();
          Navigator.of(context).pop();
          FadeScreenTransition(
            screen: const HomeScreen(),
          ).navigate(context);
        } else {
          MySnakeBar.showSnakeBar(
            'Google Sign In',
            responseModel.message ?? '',
          );
        }
      }).catchError((error) {
        MySnakeBar.showSnakeBar(
          'Google Sign In',
          'Something went wrong!',
        );
        authController.updateError();
      });
    },
  );
}),
```

#### Registration Screen Modification

In `register_screen.dart`, add the Google Sign-In option:

```dart
// Add after the "Cancel" button
const SizedBox(height: 20),

// Google Sign-In Button
GetBuilder<AuthController>(builder: (authController) {
  return ModernButton(
    text: 'Sign Up with Google',
    icon: Icons.account_circle_outlined,
    isLoading: authController.isLoading,
    isOutlined: true,
    onPressed: () {
      FocusScope.of(context).unfocus();
      authController.googleSignIn().then((responseModel) {
        if (responseModel.isSuccess) {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          homeController.getUsers();
          FadeScreenTransition(
            screen: const HomeScreen(),
          ).navigate(context);
        } else {
          MySnakeBar.showSnakeBar(
            'Google Sign Up',
            responseModel.message ?? '',
          );
        }
      }).catchError((error) {
        MySnakeBar.showSnakeBar(
          'Google Sign Up',
          'Something went wrong!',
        );
        authController.updateError();
      });
    },
  );
}),
```

### 4.4 Constants

Add the Google Auth URLs to `MyHelper` class:

```dart
class MyHelper {
  static String googleAuthUrl = '/auth/google';
  static String googleLinkAccountUrl = '/auth/google/link';
}
```

## 5. Error Handling and Edge Cases

### 5.1 Common Error Scenarios

1. **Invalid Google Token**: Handle expired or malformed Google ID tokens
2. **Network Issues**: Manage connectivity problems during Google authentication
3. **User Already Exists**: Handle cases where a Google user tries to register with an email that already exists
4. **Account Linking Conflicts**: Manage scenarios where a user tries to link a Google account to an existing email account
5. **Device ID Mismatches**: Handle cases where a user signs in from a different device

### 5.2 Error Response Format

All error responses will follow a consistent format:

```json
{
  "status": "error",
  "message": "Descriptive error message",
  "code": 400
}
```

## 6. Security Considerations

1. **Token Validation**: All Google ID tokens will be verified server-side using the official Google API client
2. **Data Protection**: User data will be stored securely with appropriate encryption
3. **Rate Limiting**: Implement rate limiting on authentication endpoints to prevent abuse
4. **Device Binding**: Maintain device ID binding for security purposes
5. **OAuth Scopes**: Only request necessary scopes from Google (email and profile)

## 7. Testing Strategy

### 7.1 Backend Testing

1. **Unit Tests**:
   - Token validation logic
   - User creation and linking
   - Error handling scenarios

2. **Integration Tests**:
   - Full authentication flow
   - Database operations
   - API endpoint responses
   - Account linking scenarios

3. **Security Tests**:
   - Invalid token handling
   - Rate limiting effectiveness
   - Data protection verification

### 7.2 Flutter Testing

1. **Widget Tests**:
   - Google Sign-In button rendering
   - Loading state handling
   - Error display

2. **Integration Tests**:
   - Authentication flow from UI to backend
   - Token storage and retrieval
   - Navigation after successful authentication
   - Account linking workflow

3. **Edge Case Tests**:
   - Network failure handling
   - User cancellation scenarios
   - Multiple account linking attempts

## 8. Deployment Considerations

1. **Environment Variables**: Ensure `GOOGLE_CLIENT_ID` is properly configured in production
2. **SSL Certificates**: Verify HTTPS is properly configured for secure token transmission
3. **Database Migrations**: Apply schema changes to accommodate Google user data
4. **Firebase Configuration**: Update Firebase settings for Google Sign-In in production
5. **Monitoring**: Set up logging and monitoring for authentication events

## 9. Monitoring and Metrics

### 9.1 Key Metrics to Track

1. **Authentication Success Rate**: Percentage of successful Google authentications
2. **Account Linking Rate**: Number of accounts linked to Google
3. **Error Rates**: Frequency of authentication failures
4. **Response Times**: API endpoint response times
5. **User Adoption**: Number of users choosing Google authentication

### 9.2 Logging Requirements

1. **Authentication Events**: Log all Google authentication attempts with timestamps
2. **Error Logging**: Detailed error logging for failed authentications
3. **Security Events**: Log suspicious activities or potential abuse
4. **Performance Metrics**: Track API response times and system performance