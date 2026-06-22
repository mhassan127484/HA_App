# HA E-Commerce — Firebase Setup Guide

## 1. Create Firebase Project

1. Go to [console.firebase.google.com](https://console.firebase.google.com)
2. Click **Add project** → name it `ha-ecommerce`
3. Enable Google Analytics (recommended)

---

## 2. Register App Platforms

### Android
1. Package name: `com.ha.ecommerce`
2. Download `google-services.json` → place in `android/app/`
3. SHA-1 fingerprint (for Google Sign-In, optional):
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```

### iOS
1. Bundle ID: `com.ha.ecommerce`
2. Download `GoogleService-Info.plist` → place in `ios/Runner/`

### Web
1. Register web app → copy config
2. Place in `web/index.html` or use `firebase_options.dart`

### macOS / Windows
- Use the same config as web (Firebase supports desktop via `firebase_options.dart`)

---

## 3. Run FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=ha-ecommerce
```

This generates `lib/firebase_options.dart` automatically.

---

## 4. Enable Firebase Services

### Authentication
- Email/Password ✅
- Google Sign-In (optional)

### Firestore Database
- Start in **production mode**
- Deploy rules: `firebase deploy --only firestore:rules`

### Storage
```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /products/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && 
                   firestore.get(/databases/(default)/documents/users/$(request.auth.uid)).data.role 
                   in ['super_admin', 'admin', 'product_manager'];
    }
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

### Cloud Messaging (FCM)
- Enable in Firebase Console → Cloud Messaging
- Android: `google-services.json` already includes FCM config
- iOS: Upload APNs Auth Key (Settings → Cloud Messaging → APNs Authentication Key)

---

## 5. Firestore Collection Schema

### `users/{uid}`
```json
{
  "uid": "string",
  "email": "string",
  "displayName": "string | null",
  "photoUrl": "string | null",
  "phoneNumber": "string | null",
  "role": "customer | product_manager | support_agent | admin | super_admin",
  "isEmailVerified": "boolean",
  "isActive": "boolean",
  "fcmToken": "string | null",
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

### `products/{id}`
```json
{
  "id": "string",
  "name": "string",
  "description": "string",
  "price": "number",
  "salePrice": "number | null",
  "images": ["url1", "url2"],
  "categoryId": "string",
  "category": "string",
  "stockQuantity": "number",
  "sku": "string",
  "isActive": "boolean",
  "isFeatured": "boolean",
  "isFlashSale": "boolean",
  "rating": "number",
  "reviewCount": "number",
  "soldCount": "number",
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

### `categories/{id}`
```json
{
  "id": "string",
  "name": "string",
  "icon": "string (emoji or icon name)",
  "color": "string (hex)",
  "imageUrl": "string | null",
  "isActive": "boolean",
  "order": "number"
}
```

### `orders/{id}`
```json
{
  "id": "string",
  "userId": "string",
  "items": [
    {
      "productId": "string",
      "productName": "string",
      "productImage": "string",
      "quantity": "number",
      "price": "number",
      "total": "number",
      "variantId": "string | null",
      "variantName": "string | null"
    }
  ],
  "subtotal": "number",
  "deliveryFee": "number",
  "totalSavings": "number",
  "total": "number",
  "address": {
    "fullName": "string",
    "phone": "string",
    "addressLine1": "string",
    "addressLine2": "string",
    "city": "string",
    "state": "string",
    "postalCode": "string",
    "country": "string"
  },
  "paymentMethod": "cash_on_delivery",
  "status": "pending | confirmed | processing | shipped | delivered | cancelled",
  "statusHistory": [
    { "status": "string", "timestamp": "Timestamp", "note": "string" }
  ],
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

### `banners/{id}`
```json
{
  "id": "string",
  "title": "string",
  "subtitle": "string | null",
  "imageUrl": "string",
  "targetUrl": "string | null",
  "isActive": "boolean",
  "order": "number",
  "startDate": "Timestamp | null",
  "endDate": "Timestamp | null"
}
```

---

## 6. Required Firestore Indexes

Create these composite indexes in Firebase Console → Firestore → Indexes:

| Collection | Fields | Query Scope |
|------------|--------|-------------|
| `products` | `isActive ASC`, `isFeatured DESC`, `createdAt DESC` | Collection |
| `products` | `isActive ASC`, `isFlashSale DESC`, `createdAt DESC` | Collection |
| `products` | `isActive ASC`, `categoryId ASC`, `createdAt DESC` | Collection |
| `orders` | `userId ASC`, `createdAt DESC` | Collection |
| `orders` | `status ASC`, `createdAt DESC` | Collection |

---

## 7. Seed Initial Data

### Create Admin User
1. Register via the app with your email
2. In Firestore Console → `users/{your-uid}` → set `role` to `super_admin`
3. The admin panel will now be accessible

### Seed Categories (run once in Firestore Console)
```javascript
// Sample categories to add via Firebase Console or a seed script
const categories = [
  { id: 'electronics', name: 'Electronics', icon: '📱', color: '#3B82F6' },
  { id: 'clothing', name: 'Clothing', icon: '👗', color: '#EC4899' },
  { id: 'books', name: 'Books', icon: '📚', color: '#F59E0B' },
  { id: 'home_kitchen', name: 'Home & Kitchen', icon: '🏠', color: '#10B981' },
  { id: 'sports', name: 'Sports', icon: '⚽', color: '#EF4444' },
];
```

---

## 8. Run the App

```bash
# Install dependencies
flutter pub get

# Run on specific platform
flutter run -d android
flutter run -d ios
flutter run -d chrome
flutter run -d windows
flutter run -d macos

# Build release
flutter build apk --release
flutter build ios --release
flutter build web --release
```

---

## 9. Role Hierarchy

| Role | Permissions |
|------|-------------|
| `customer` | Browse, cart, orders (own), profile |
| `support_agent` | Read all orders, update status |
| `product_manager` | CRUD products, read orders |
| `admin` | All above + manage users |
| `super_admin` | Full access including delete |
