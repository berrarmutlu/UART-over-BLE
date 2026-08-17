//
//  DeviceDashboardView.swift
//  UART over BLE
//
//  Created by Berra Armutlu on 7.08.2026.
//

import SwiftUI

struct DeviceDashboardView: View {
    
    @ObservedObject var bluetoothManager: BluetoothManager
    @State private var message = ""
    @State private var selectedCommand: Command? //kullanicinin sectigi komut
    
    
    private var machineDateText: String {
        guard let dateTime = bluetoothManager.dateTime else {
            return "--"
        }

        let parts = dateTime.split(separator: " ")

        guard parts.count == 2 else {
            return "--"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = DeviceDateFormat.date

        guard let date = formatter.date(from: String(parts[0])) else {
            return "--"
        }

        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = DisplayDateFormat.date

        return displayFormatter.string(from: date)
    }

    private var machineTimeText: String {
        guard let dateTime = bluetoothManager.dateTime else {
            return "--"
        }

        let parts = dateTime.split(separator: " ")

        guard parts.count == 2 else {
            return "--"
        }

        let timeString = String(parts[1])

        guard timeString.count >= 4 else {
            return "--"
        }

        let hour = timeString.prefix(2)
        let minute = timeString.dropFirst(2).prefix(2)

        return "\(hour):\(minute)"
    }
    
    
    
    var body: some View {
        if bluetoothManager.isConnected {
            ScrollView {
                
                VStack(alignment: .leading, spacing: 16) {
                    
                    
                    HStack {
                        Text(machineDateText)
                        
                        Spacer()
                        
                        Text(machineTimeText)
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    
                    
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Dashboard")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text(bluetoothManager.connectedDeviceName)
                                .font(.headline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()

                        VStack(alignment: .trailing, spacing: 6) {
                            Text("Connected")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.green)

                            NavigationLink {
                                InformationView(bluetoothManager: bluetoothManager)
                            } label: {
                                Label("Information", systemImage: "info.circle")
                                    .font(.subheadline)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        
                        VStack(spacing: 12) { //temperature ve humidity ekranda alt alta dizilir
                            
                            //temperature sicaklik
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(spacing: 8) {
                                    Image(systemName: "thermometer.medium")
                                        .font(.title2)
                                        .foregroundStyle(.blue)
                                    Text("Temperature")
                                        .font(.headline)
                                }
                                if let temperature = bluetoothManager.temperature {
                                    Text("\(temperature, specifier: "%.2f") °C") //__,__ seklindeki gosterim
                                        .font(.system(size: 32, weight: .bold))
                                } else {
                                    Text("-- °C")
                                        .font(.system(size: 32, weight: .bold))
                                }
                            }
                            
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            
                            //humidity nem
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(spacing: 8) {
                                    Image(systemName: "humidity")
                                        .font(.title2)
                                        .foregroundStyle(.blue)

                                    Text("Humidity")
                                        .font(.headline)
                                }

                                if let humidity = bluetoothManager.humidity {
                                    Text("\(humidity, specifier: "%.0f") %")                                        .font(.system(size: 32, weight: .bold))
                                } else {
                                    Text("-- %")
                                        .font(.system(size: 32, weight: .bold))
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        
                        //level kademe
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 8) {
                                Image(systemName: "gearshape.2")
                                    .font(.title2)
                                    .foregroundStyle(.blue)

                                Text("Machine Level")
                                    .font(.headline)
                            }

                            if let level = bluetoothManager.level {
                                Text("\(Int(level), specifier: "%02d")")                                    .font(.system(size: 32, weight: .bold))
                            } else {
                                Text("--")
                                    .font(.system(size: 32, weight: .bold))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        
                        //mesaj alani
                        HStack(spacing: 8) {
                            Picker("Select command...", selection: $selectedCommand) {
                                Text("Select command...")
                                    .tag(Command?.none)

                                Text("Temperature")
                                    .tag(Command?.some(.temperature))

                                Text("Humidity")
                                    .tag(Command?.some(.humidity))

                                Text("Machine Level")
                                    .tag(Command?.some(.level))

                                Text("Date / Time")
                                    .tag(Command?.some(.dateTime))
                            }
                            .pickerStyle(.menu)

                            Button {
                                if let selectedCommand {
                                    bluetoothManager.send(message: selectedCommand.rawValue)
                                    self.selectedCommand = nil
                                }
                            } label: {
                                Image(systemName: "arrow.up")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .frame(width: 34, height: 34)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                            .padding(.trailing, 8)
                        }
                        .frame(height: 50)
                        .background(Color(.systemGray6))
                        .clipShape(Capsule())
                        
                        if !bluetoothManager.commandStatus.isEmpty { //commandStatus bos degilse UI gosterir
                            Text(bluetoothManager.commandStatus)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
            }
        }
    }
}

#Preview {
    DeviceDashboardView(
        bluetoothManager: BluetoothManager()
    )
}
