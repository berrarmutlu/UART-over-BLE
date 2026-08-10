//
//      DeviceListView.swift
//  UART over BLE
//
//  Created by Berra Armutlu on 7.08.2026.
//

import SwiftUI
import CoreBluetooth

struct DeviceListView: View {
    
    @ObservedObject var bluetoothManager: BluetoothManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("UART over BLE")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                    
                    Spacer()
                    
                    Button {
                        bluetoothManager.scan()
                    } label: {
                        Label("Scan", systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(.bordered)
                }
                
                // daha onceden baglanmis cihazlarin listesi
                VStack(alignment: .leading, spacing: 10) {
                    Text("My Devices")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    if bluetoothManager.previouslyConnectedDevices.isEmpty {
                        Text("No saved devices")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(
                            bluetoothManager.previouslyConnectedDevices,
                            id: \.identifier
                        ) { peripheral in
                            Button {
                                bluetoothManager.connect(to: peripheral)
                            } label: {
                                HStack {
                                    Image(systemName: "dot.radiowaves.left.and.right")
                                        .foregroundStyle(.blue)
                                    
                                    Text(peripheral.name ?? "Unknown Device")
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.secondary)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                // daha once baglanmamis ama baglanmaya uygun cihazlarin listesi
                VStack(alignment: .leading, spacing: 10) {
                    Text("Other Devices")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    if bluetoothManager.discoveredPeripherals.isEmpty {
                        Text("No devices found")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(
                            bluetoothManager.discoveredPeripherals,
                            id: \.identifier
                        ) { peripheral in
                            Button {
                                bluetoothManager.connect(to: peripheral)
                            } label: {
                                HStack {
                                    Image(systemName: "dot.radiowaves.left.and.right")
                                        .foregroundStyle(.blue)
                                    
                                    Text(peripheral.name ?? "Unknown Device")
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.secondary)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                if !bluetoothManager.statusMessage.isEmpty {
                    Text(bluetoothManager.statusMessage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        }
    }
}

#Preview {
    DeviceListView(bluetoothManager: BluetoothManager())
}
