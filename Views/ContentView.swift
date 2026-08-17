//
//  ContentView.swift
//  UART over BLE
//
//  Created by Berra Armutlu on 13.07.2026.
//

import SwiftUI
import CoreBluetooth

struct ContentView: View {
    @StateObject private var bluetoothManager = BluetoothManager()
    
    var body: some View {
        NavigationStack {
            DeviceListView(bluetoothManager: bluetoothManager)
        }
    }
}

#Preview {
    ContentView()
}
