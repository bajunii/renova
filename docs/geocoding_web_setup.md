# Geocoding on Web Platform - Setup Guide

## Issue
The location name is not showing in the EcoSpots "Your Location" section when running on web. Instead, it displays coordinates like "Lat: X.XXXX, Long: Y.YYYY" or "Current Location".

## Root Cause
The `geocoding` package has different implementations for different platforms:
- **Android/iOS**: Uses native platform APIs (works out of the box)
- **Web**: Requires Google Maps JavaScript API with an API key

Without proper configuration, geocoding on web fails silently and falls back to showing coordinates.

## Solution Options

### Option 1: Add Google Maps API Key (Recommended for Production)

#### Step 1: Get Google Maps API Key
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing one
3. Enable these APIs:
   - **Maps JavaScript API**
   - **Geocoding API**
4. Go to **Credentials** → **Create Credentials** → **API Key**
5. Copy your API key
6. (Optional but recommended) Restrict the API key:
   - Application restrictions: HTTP referrers
   - Add your domain (e.g., `localhost:*`, `yourdomain.com/*`)
   - API restrictions: Select only Maps JavaScript API and Geocoding API

#### Step 2: Add API Key to web/index.html
Update `web/index.html` to include the Google Maps JavaScript API:

```html
<!DOCTYPE html>
<html>
<head>
  <base href="$FLUTTER_BASE_HREF">
  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="description" content="Renew + Innovate through recycling and art.">

  <!-- iOS meta tags & icons -->
  <meta name="mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black">
  <meta name="apple-mobile-web-app-title" content="renova">
  <link rel="apple-touch-icon" href="icons/Icon-192.png">

  <!-- Favicon -->
  <link rel="icon" type="image/png" href="favicon.png"/>

  <title>Renova - Eco Management</title>
  <link rel="manifest" href="manifest.json">
  
  <!-- Google Maps JavaScript API for Geocoding -->
  <script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY_HERE&libraries=places"></script>
</head>
<body>
  <script src="flutter_bootstrap.js" async></script>
</body>
</html>
```

**Replace `YOUR_API_KEY_HERE` with your actual API key.**

#### Step 3: Test
1. Rebuild your web app: `flutter build web`
2. Or hot restart if running in debug: Press `R` in terminal
3. Click "Get Current Location" button
4. Should now show readable address instead of coordinates

---

### Option 2: Use Alternative Reverse Geocoding Service (Free Tier Available)

If you don't want to use Google Maps, you can integrate alternative services:

#### Using Nominatim (OpenStreetMap)
Free and open-source, but has usage limits.

1. Add `http` package to `pubspec.yaml`:
```yaml
dependencies:
  http: ^1.1.0
```

2. Create a custom geocoding service:

```dart
// lib/services/nominatim_geocoding.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class NominatimGeocoding {
  static Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?format=json'
        '&lat=$latitude'
        '&lon=$longitude'
        '&zoom=18'
        '&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'RenovaApp/1.0', // Required by Nominatim
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['display_name'] != null) {
          return data['display_name'] as String;
        }
        
        // Alternative: Build from address components
        final address = data['address'];
        if (address != null) {
          List<String> parts = [];
          
          if (address['road'] != null) parts.add(address['road']);
          if (address['suburb'] != null) parts.add(address['suburb']);
          if (address['city'] != null) parts.add(address['city']);
          if (address['state'] != null) parts.add(address['state']);
          if (address['country'] != null) parts.add(address['country']);
          
          if (parts.isNotEmpty) {
            return parts.join(', ');
          }
        }
      }
      
      return null;
    } catch (e) {
      debugPrint('Nominatim geocoding error: $e');
      return null;
    }
  }
}
```

3. Update `_getCurrentLocation()` to use Nominatim:

```dart
// In group_dashboard.dart
import '../services/nominatim_geocoding.dart';

// Replace the geocoding section with:
String address = 'Location retrieved';
try {
  // Try Nominatim first (works on all platforms including web)
  final nominatimAddress = await NominatimGeocoding.getAddressFromCoordinates(
    position.latitude,
    position.longitude,
  );
  
  if (nominatimAddress != null && nominatimAddress.isNotEmpty) {
    address = nominatimAddress;
  } else {
    // Fallback to package geocoding
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    // ... rest of existing code
  }
} catch (e) {
  debugPrint('Geocoding error: $e');
  address = 'Current Location';
}
```

**Note:** Nominatim has usage limits:
- Maximum 1 request per second
- Not suitable for high-volume applications
- Consider self-hosting for production

---

### Option 3: Use Current Implementation (No Real Address on Web)

Keep the current implementation which shows:
- "Current Location" on web (when geocoding fails)
- Actual address on mobile (Android/iOS native geocoding works)

**Pros:**
- No additional setup required
- No API costs
- Works immediately

**Cons:**
- Less user-friendly on web
- Only shows coordinates or generic "Current Location"

**Current Implementation:**
The code now shows "Current Location" instead of raw coordinates when geocoding is unavailable, making it more user-friendly than before.

---

## Current Code Behavior

### What Happens Now:
1. **On Android/iOS**: Full address is retrieved and displayed
2. **On Web (without API key)**: Shows "Current Location" + coordinates below
3. **On Geocoding Failure**: Shows "Current Location" instead of error

### Debug Information:
The code now includes debug logging to help diagnose geocoding issues:
```dart
debugPrint('Fetching address for: ${position.latitude}, ${position.longitude}');
debugPrint('Placemarks found: ${placemarks.length}');
debugPrint('Placemark details:');
debugPrint('  - locality: ${place.locality}');
// ... more debug info
```

**To see debug logs:**
1. Open Chrome DevTools (F12)
2. Go to Console tab
3. Look for debug messages when clicking "Get Current Location"

---

## Comparison of Options

| Option | Cost | Setup Difficulty | Web Support | Mobile Support | Limitations |
|--------|------|------------------|-------------|----------------|-------------|
| Google Maps API | Free tier (28,500 req/month) then $5/1000 req | Medium | ✅ Excellent | ✅ Excellent | Billing required after free tier |
| Nominatim OSM | Free | Easy | ✅ Good | ✅ Good | 1 req/sec limit, less accurate |
| Current (Native only) | Free | None | ❌ No address | ✅ Excellent | Web shows generic location |

---

## Recommended Approach

### For Development/Testing:
Use **Option 3** (current implementation) - shows "Current Location" on web

### For Production:
Use **Option 1** (Google Maps API) if:
- You have budget for API costs
- You need accurate geocoding on web
- You expect high user volume

Use **Option 2** (Nominatim) if:
- You want free reverse geocoding
- You have low to medium traffic
- You can accept 1-second delays between requests

---

## Testing Geocoding

### Test on Different Platforms:

#### Web (Chrome):
```bash
flutter run -d chrome
```
- Without API key: Shows "Current Location"
- With API key: Shows full address

#### Android Emulator:
```bash
flutter run -d emulator-5554
```
- Should show full address (uses Android native geocoding)

#### Check Debug Console:
Look for these messages:
```
Fetching address for: 37.4219999, -122.0840575
Placemarks found: 1
Placemark details:
  - locality: Mountain View
  - administrativeArea: California
  - country: United States
Final address: Mountain View, California, United States
```

---

## Troubleshooting

### "Current Location" shown on web:
**Cause:** Geocoding package doesn't work on web without Google Maps API

**Solution:** 
1. Add Google Maps API key to `web/index.html` (Option 1)
2. Or use alternative service like Nominatim (Option 2)
3. Or accept generic "Current Location" text (Option 3 - current)

### "Failed to get location" error:
**Cause:** Location permissions not granted or location services disabled

**Solution:**
1. Check browser location permissions
2. Ensure HTTPS (location API requires secure context on web)
3. Click "Allow" when browser prompts for location

### Raw coordinates showing:
**Cause:** Old version of code, now fixed to show "Current Location"

**Solution:**
1. Hot restart: Press `R` in terminal
2. Or rebuild: `flutter run -d chrome`

### Empty address components:
**Cause:** Geocoding returned empty placemark data

**Solution:**
1. Check internet connection
2. Verify coordinates are valid
3. Try different location (some areas have poor geocoding data)

---

## Files Modified

### Current Changes:
- ✅ `lib/screens/dashboards/group_dashboard.dart` - Improved geocoding with better fallbacks
- ✅ Added debug logging for troubleshooting

### If Implementing Option 1 (Google Maps):
- 📝 `web/index.html` - Add Google Maps API script tag

### If Implementing Option 2 (Nominatim):
- 📝 `lib/services/nominatim_geocoding.dart` - New file
- 📝 `pubspec.yaml` - Add `http` package
- 📝 `lib/screens/dashboards/group_dashboard.dart` - Integrate Nominatim

---

## Cost Estimates (Google Maps API)

### Free Tier:
- **$200 credit per month**
- ~28,500 Geocoding API requests/month free
- After that: **$5 per 1,000 requests**

### Example Costs:
- **Small app** (100 users, 10 locations/day): ~30,000 req/month = Free
- **Medium app** (1000 users, 5 locations/day): ~150,000 req/month = ~$40/month
- **Large app** (10,000 users, 3 locations/day): ~900,000 req/month = ~$230/month

**Optimization Tips:**
1. Cache geocoded addresses
2. Limit frequency of location refreshes
3. Use geohashing to group nearby locations
4. Only geocode when necessary (not on every map view)

---

## Summary

**Current Status:** ✅ Code updated to show "Current Location" instead of raw coordinates when geocoding unavailable

**Web Geocoding:** ❌ Requires Google Maps API key (not configured)

**Mobile Geocoding:** ✅ Works natively on Android/iOS

**Next Steps:**
1. For production web app → Add Google Maps API key
2. For budget-conscious solution → Implement Nominatim
3. For mobile-first app → Current implementation is fine

Choose based on your needs and budget! 🌍📍
