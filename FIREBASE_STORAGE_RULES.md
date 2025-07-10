# Firebase Storage Rules Configuration

To fix the "Firebase Storage no object found" error, make sure your Firebase Storage rules allow uploads to the `profile_images` folder. 

## Go to the Firebase Console

1. Navigate to https://console.firebase.google.com
2. Select your project "teton-meal-app"
3. Click on "Storage" in the left sidebar
4. Click on "Rules" tab at the top

## Update Your Rules

Replace the default rules with these rules that allow authenticated users to upload profile images:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Allow anyone to read profile images
    match /profile_images/{profileImage} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Default rule - require authentication for all other operations
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Testing the Fix

After updating the rules:
1. Wait a few minutes for the rules to propagate
2. Try the profile image upload again
3. Check the debug logs for any additional errors

If you're still facing issues, you can temporarily use these more permissive rules for testing:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if true;
    }
  }
}
```

**Important**: Only use the permissive rules for testing. Switch back to more restrictive rules before deploying to production.
