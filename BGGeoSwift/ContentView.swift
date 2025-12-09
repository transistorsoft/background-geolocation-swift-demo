//
//  ContentView.swift
//  BGGeoSwift
//
//  Created by Christopher Scott on 2025-12-09.
//

import SwiftUI
import Combine
import TSLocationManager
import CoreLocation

// Observable class to hold state JSON
class StateHolder: ObservableObject {
    @Published var jsonString: String = ""
}

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var stateHolder = StateHolder()
    
    @State private var trackingEnabled: Bool = false
    @State private var isMoving: Bool = false
    @State private var providerEnabled: Bool = false
    @State private var currentActivity: String = "unknown"
    @State private var lastLocation: CLLocation? = nil
    @State private var odometerKm: Double = 0
    @State private var odometerErrorKm: Double? = nil
    @State private var menuVisible: Bool = false
    @State private var statusMessage: String = "Idle"
    @State private var stateViewVisible: Bool = false
    
    private static var isConfigured = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    // Header with title, subtitle, and menu button
                    HStack {
                        VStack(alignment: .leading) {
                            Text("BG Geolocation")
                                .font(.largeTitle)
                                .bold()
                            Text("SwiftUI Demo App")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button(action: {
                            menuVisible.toggle()
                        }) {
                            Image(systemName: "line.horizontal.3")
                                .font(.title2)
                                .foregroundColor(.accentColor)
                                .padding(8)
                                .background(Color(.systemGray5))
                                .clipShape(Circle())
                        }
                        .accessibilityLabel("Menu")
                    }
                    .padding(.horizontal)
                    
                    // Status cards row - EQUAL SIZES
                    HStack(spacing: 12) {
                        // GPS Provider card
                        VStack(spacing: 8) {
                            Text("GPS Provider")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Circle()
                                .fill(providerEnabled ? Color.green : Color.red)
                                .frame(width: 16, height: 16)
                            
                            Text(providerEnabled ? "Enabled" : "Disabled")
                                .font(.subheadline)
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)

                        // Activity card
                        VStack(spacing: 8) {
                            Text("Activity")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(activityIcon(for: currentActivity))
                                .font(.title2)
                            
                            Text(currentActivity.capitalized)
                                .font(.subheadline)
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)

                        // Odometer card
                        VStack(spacing: 8) {
                            Text("Odometer")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            HStack(alignment: .firstTextBaseline, spacing: 2) {
                                Text(String(format: "%.1f", odometerKm))
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.accentColor)
                                Text("km")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            if let error = odometerErrorKm {
                                Text("±\(String(format: "%.0f", error)) km")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Controls card
                    VStack(spacing: 16) {
                        Toggle(isOn: $trackingEnabled) {
                            VStack(alignment: .leading) {
                                Text("Enable Tracking")
                                    .font(.headline)
                                Text("Start or stop background geolocation tracking")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .onChange(of: trackingEnabled) { newValue in
                            handleToggleTracking(newValue)
                        }
                        
                        VStack(spacing: 8) {
                            Text("Motion State")
                                .font(.headline)
                            
                            Button(action: {
                                handleChangePace()
                            }) {
                                Text(isMoving ? "❚❚" : "▶")
                                    .font(.system(size: 48))
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(.white)
                                    .background(
                                        trackingEnabled ?
                                            (isMoving ? Color.red : Color.green)
                                            : Color.gray.opacity(0.5)
                                    )
                                    .clipShape(Circle())
                                    .shadow(radius: 4)
                            }
                            .disabled(!trackingEnabled)
                            .accessibilityLabel(isMoving ? "Pause Motion" : "Start Motion")
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Last Location card
                    if let location = lastLocation {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Last Location")
                                .font(.headline)
                                .padding(.bottom, 4)
                            
                            HStack {
                                Text("Latitude:")
                                    .font(.subheadline)
                                Spacer()
                                Text(String(format: "%.6f", location.coordinate.latitude))
                                    .font(.subheadline)
                                    .monospacedDigit()
                            }
                            
                            HStack {
                                Text("Longitude:")
                                    .font(.subheadline)
                                Spacer()
                                Text(String(format: "%.6f", location.coordinate.longitude))
                                    .font(.subheadline)
                                    .monospacedDigit()
                            }
                            
                            HStack {
                                Text("Speed:")
                                    .font(.subheadline)
                                Spacer()
                                if location.speed >= 0 {
                                    Text(String(format: "%.2f m/s", location.speed))
                                        .font(.subheadline)
                                        .monospacedDigit()
                                } else {
                                    Text("N/A")
                                        .font(.subheadline)
                                }
                            }
                            
                            HStack {
                                Text("Accuracy:")
                                    .font(.subheadline)
                                Spacer()
                                Text(String(format: "%.2f m", location.horizontalAccuracy))
                                    .font(.subheadline)
                                    .monospacedDigit()
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // Get Current Position button
                    Button(action: {
                        handleGetCurrentPosition()
                    }) {
                        HStack {
                            Image(systemName: "location.fill")
                            Text("Get Current Position")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
                .padding(.top)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $menuVisible) {
                NavigationStack {
                    List {
                        Section(header: Text("Actions")) {
                            Button("Request Permission") {
                                menuVisible = false
                                handleRequestPermission()
                            }
                            Button("Reset Odometer") {
                                menuVisible = false
                                handleResetOdometer()
                            }
                            Button("Sync") {
                                menuVisible = false
                                handleSync()
                            }
                            Button("Get State") {
                                handleGetState()
                            }
                            Button("Email Log") {
                                menuVisible = false
                                handleEmailLog()
                            }
                            Button("Destroy Log") {
                                menuVisible = false
                                handleDestroyLog()
                            }
                            Button("Destroy Locations") {
                                menuVisible = false
                                handleDestroyLocations()
                            }
                        }
                    }
                    .navigationTitle("Menu")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") {
                                menuVisible = false
                            }
                        }
                    }
                }
            }
            .onAppear {
                configureBGGeoIfNeeded()
            }
            // State View Sheet
            .sheet(isPresented: $stateViewVisible) {
                NavigationStack {
                    ScrollView {
                        Text(stateHolder.jsonString.isEmpty ? "No state data" : stateHolder.jsonString)
                            .font(.system(size: 12, design: .monospaced))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .textSelection(.enabled)
                    }
                    .navigationTitle("Current State")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                stateViewVisible = false
                                stateHolder.jsonString = "" // Clear when closing
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Configuration
    
    private func configureBGGeoIfNeeded() {
        guard !Self.isConfigured else { return }
        
        let config = TSConfig.sharedInstance()
        
        // --- Geolocation ---
        config.geolocation.desiredAccuracy = kCLLocationAccuracyBest
        config.geolocation.distanceFilter = 10 // meters
        config.geolocation.locationAuthorizationRequest = "Always"
        config.geolocation.showsBackgroundLocationIndicator = true
        
        // --- HTTP ---
        config.http.url = "https://YOUR.SERVER.COM/locations"
        config.http.method = "POST"
        config.http.autoSync = false
        config.http.autoSyncThreshold = 0
        
        // --- App / lifecycle ---
        config.app.stopOnTerminate = false
        config.app.startOnBoot = true
        
        config.logger.debug = true
        config.logger.logLevel = .verbose
        
        let bgGeo = BackgroundGeolocation.sharedInstance()
        
        bgGeo.onLocation({ event in
            NSLog("[onLocation] \(event.toDictionary())")
            
            let loc = event.location
            // Use the provided CLLocation directly
            if let last = self.lastLocation {
                let incrementalDistance = loc.distance(from: last) / 1000.0
                self.odometerKm += incrementalDistance
                // Placeholder for odometer error calculation
                self.odometerErrorKm = 0.05 * self.odometerKm
            }
            self.lastLocation = loc
            self.statusMessage = "Location updated"
        }, failure: { error in
            print("❌ Location error: \(error)")
            self.statusMessage = "Location error"
        })
        
        bgGeo.onMotionChange { event in
            self.isMoving = event.isMoving
            let loc = event.location
            self.lastLocation = loc
        }
        
        bgGeo.onActivityChange { event in
            self.currentActivity = event.activity
        }
        
        bgGeo.onProviderChange { event in
            self.providerEnabled = event.enabled
        }
        
        bgGeo.ready()
        
        // Set current UI state.
        self.trackingEnabled = config.enabled
        self.isMoving = config.isMoving
        // Update odometer
        let odometer = TSOdometer.sharedInstance()
        self.odometerKm = odometer.odometer / 1000.0  // Convert meters to km
        self.odometerErrorKm = odometer.odometerError / 1000.0
        
        print("Initial state loaded - Tracking: \(self.trackingEnabled), Moving: \(self.isMoving)")
        
        Self.isConfigured = true
    }
    
    // MARK: - Actions
    
    private func handleToggleTracking(_ value: Bool) {
        trackingEnabled = value
        configureBGGeoIfNeeded()
        
        let bgGeo = BackgroundGeolocation.sharedInstance()
        if value {
            bgGeo.start()
            statusMessage = "Started"
        } else {
            bgGeo.stop()
            isMoving = false
            statusMessage = "Stopped"
        }
    }
    
    private func handleChangePace() {
        guard trackingEnabled else { return }
        
        let newState = !isMoving
        BackgroundGeolocation.sharedInstance().changePace(newState)
        // Optimistic UI update; onMotionChange will update isMoving again
        isMoving = newState
    }
    
    private func handleGetCurrentPosition() {
        configureBGGeoIfNeeded()

        let request = TSCurrentPositionRequest.make(
            type: .current,
            success: { event in
                NSLog("[Swift][getCurrentPosition] SUCCESS: \(event.data)")
            },
            failure: { error in
                print("[Swift][getCurrentPosition] ERROR: \(error)")
            }
        )
        request.timeout = 10
        request.desiredAccuracy = kCLLocationAccuracyBest
        request.maximumAge = 5000                  // ms
        request.samples = 3
        request.extras = [
            "getCurrentPosition": true
        ];
        
        request.persist = true

        let bgGeo = BackgroundGeolocation.sharedInstance()
        bgGeo.getCurrentPosition(request)
    }
    
    private func handleDestroyLog() {
        BackgroundGeolocation.sharedInstance().destroyLog()
    }
    
    private func handleRequestPermission() {
        //BackgroundGeolocation.sharedInstance().requestPermission("Always")
    }
    
    private func handleResetOdometer() {
        odometerKm = 0
        odometerErrorKm = nil
        statusMessage = "Odometer reset"
    }
    
    private func handleEmailLog() {
        //BackgroundGeolocation.sharedInstance().emailLog("chris@transistorsoft.com")
    }
    
    private func handleSync() {
        //BackgroundGeolocation.sharedInstance().sync()
    }
    
    private func handleDestroyLocations() {
        BackgroundGeolocation.sharedInstance().destroyLocations()
    }
    
    private func handleGetState() {
        // Get state and convert to JSON immediately
        let state = TSConfig.sharedInstance().toDictionary()
        
        if let stateDict = state as? [String: Any],
           let jsonData = try? JSONSerialization.data(withJSONObject: stateDict, options: [.prettyPrinted]),
           let json = String(data: jsonData, encoding: .utf8) {
            // Use the StateHolder to set the JSON
            stateHolder.jsonString = json
            print("Set stateHolder.jsonString, length: \(stateHolder.jsonString.count)")
        } else {
            stateHolder.jsonString = "Failed to get state"
        }
        
        // Close menu and show state view
        menuVisible = false
        stateViewVisible = true
    }
    
    // MARK: - Helpers
    
    private func activityIcon(for activity: String) -> String {
        switch activity.lowercased() {
            case "in_vehicle": return "🚗"
            case "on_bicycle": return "🚲"
            case "on_foot": return "🚶"
            case "running": return "🏃"
            case "still": return "🛑"
            case "unknown": return "❓"
            case "tilting": return "📱"
            case "walking": return "🚶"
            default: return "❓"
        }
    }
}

#Preview {
    ContentView()
}
