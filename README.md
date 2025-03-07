# Flutter OSRM Map API

This Flutter application demonstrates the integration of the Open Source Routing Machine (OSRM) API for map-based route planning and location visualization.

## Overview

This project provides a basic Flutter implementation that uses the OSRM API to display a map, track a user's location, and calculate routes between two points. It leverages `flutter_map` for map rendering, `location` for location services, and `flutter_polyline_points` to draw routes on the map.

## Technologies Used

* **Flutter:** Cross-platform mobile application development framework.
* **Dart:** Programming language for Flutter.
* **OSRM API:** Open Source Routing Machine API for routing and map data.
* **Packages:**
    * `latlong2: ^0.9.1` - Geographic coordinate calculations.
    * `flutter_map: ^8.1.0` - Interactive map display.
    * `flutter_map_location_marker: ^10.0.0` - Location marker implementation.
    * `location: ^8.0.0` - Location services access.
    * `http: ^1.3.0` - HTTP requests for API communication.
    * `flutter_polyline_points: ^2.1.0` - Polyline rendering for routes.

## Permissions

### Android

* `android.permission.ACCESS_FINE_LOCATION`: For precise location tracking.
* `android.permission.ACCESS_COARSE_LOCATION`: For approximate location tracking (fallback).
* `android.permission.INTERNET`: For network access to fetch map data and routing information.
* `android.permission.ACCESS_NETWORK_STATE`: To check network connectivity.
* `android.permission.ACCESS_BACKGROUND_LOCATION`: For location tracking in the background (if granted by the user).

### iOS

* `NSLocationWhenInUseUsageDescription`: (Add a description in `Info.plist`) Explains why the app needs location access while in use.
* `NSLocationAlwaysAndWhenInUseUsageDescription`: (Add a description in `Info.plist`) Explains why the app needs location access even when in the background.
* `NSLocationAlwaysUsageDescription`: (Add a description in `Info.plist`) Explains why the app needs always location access.
* `NSLocationUsageDescription`: (Add a description in `Info.plist`) general location usage description.
* `NSLocationDefaultAccuracyReduced`: (Add a description in `Info.plist`) if you use reduced accuracy.

**Note:** Ensure you add appropriate descriptions for these permissions in your `Info.plist` file, explaining why your application requires location access. Apple requires clear and concise descriptions for user privacy.

## Getting the OSRM API

OSRM is an open-source routing machine, and you have several options for accessing its API:

1.  **Public Demo Server:**
    * OSRM provides a public demo server that you can use for testing and development. However, this server might have usage limitations and is not recommended for production.
    * The base URL for the public demo server is typically `http://router.project-osrm.org/`.
2.  **Self-Hosting:**
    * For production use, it's recommended to set up your own OSRM server. This gives you full control over the routing data and performance.
    * To self-host, you'll need to download the OSRM software and map data, and set up a server.
    * To get OSRM follow this steps:
        * go to the OSRM website: [http://project-osrm.org/](http://project-osrm.org/)
        * follow the installation and usage instructions provided on the website.
        * Download the map data you need.
        * run the OSRM server.
3.  **Third-Party Providers:**
    * Several cloud-based providers offer OSRM APIs as a service. These providers typically handle the server setup and maintenance, and offer various pricing plans.
    * Search for "OSRM API providers" to find available options.

**Important:** When using the public demo server, be mindful of its limitations and avoid excessive requests. For production applications, self-hosting or using a third-party provider is strongly recommended.

## OSRM API Integration

This application relies on the OSRM API to fetch routing data. It sends HTTP requests to the OSRM server and parses the response to extract route information. The `flutter_polyline_points` package is then used to decode the polyline data and render it on the `flutter_map` widget.