//
//DeviceListView.swift
//  UART over BLE
//
//  Created by Berra Armutlu on 7.08.2026.
//

import SwiftUI
import CoreBluetooth

struct DeviceListView: View {
    
    @ObservedObject var bluetoothManager: BluetoothManager
    @State private var navigateToDashboard = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                
                HStack {
                    Text("UART over BLE")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    
                    Text("CİHAZLARIM")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
                    if bluetoothManager.previouslyConnectedDevices.isEmpty {
                        Text("Kayıtlı cihaz bulunamadı")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(
                            bluetoothManager.previouslyConnectedDevices,
                            id: \.identifier
                        ) { peripheral in
                            Button {
                                if bluetoothManager.isConnected {
                                    navigateToDashboard = true
                                } else {
                                    bluetoothManager.connect(to: peripheral)
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "dot.radiowaves.left.and.right")
                                        .foregroundStyle(.blue)
                                    
                                    Text(peripheral.name ?? "Bilinmeyen Cihaz")
                                    
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
                
                
                VStack(alignment: .leading, spacing: 10) {
                    
                    Text("DİĞER CİHAZLAR")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
                    if bluetoothManager.discoveredPeripherals.isEmpty {
                        Text("Cihaz bulunamadı")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(
                            bluetoothManager.discoveredPeripherals,
                            id: \.identifier
                        ) { peripheral in
                            Button {
                                if bluetoothManager.isConnected {
                                    navigateToDashboard = true
                                } else {
                                    bluetoothManager.connect(to: peripheral)
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "dot.radiowaves.left.and.right")
                                        .foregroundStyle(.blue)
                                    
                                    Text(peripheral.name ?? "Bilinmeyen Cihaz")
                                    
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
                
                VStack(alignment: .leading) {
                    Button {
                        bluetoothManager.scan()
                    } label: {
                        Label("Tara", systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
            .onChange(of: bluetoothManager.isConnected) {
                if bluetoothManager.isConnected {
                    navigateToDashboard = true
                }
            }
            .navigationDestination(isPresented: $navigateToDashboard) {
                DeviceDashboardView(bluetoothManager: bluetoothManager)
            }
        }
    }
}



#Preview {
    DeviceListView(bluetoothManager: BluetoothManager())
}
