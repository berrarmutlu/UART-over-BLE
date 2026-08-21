//
//  InformationView.swift
//  UART over BLE
//
//  Created by Berra Armutlu on 11.08.2026.
//

import SwiftUI

struct InformationView: View {
    @ObservedObject var bluetoothManager: BluetoothManager
    @State private var selectedCommand: Command?
    
    private var calibrationText: String {
        guard let calibrationDate = bluetoothManager.calibrationDate else {
            return "--"
        }
        
        let today = Calendar.current.startOfDay(for: Date())
        let expiryDate = Calendar.current.startOfDay(for: calibrationDate)
        
        let days = Calendar.current.dateComponents(
            [.day],
            from: today,
            to: expiryDate
        ).day ?? 0
        
        if days > 0 {
            return "\(days) days remaining"
        } else if days < 0 {
            return "\(abs(days)) days overdue"
        } else {
            return "Calibration required"
        }
    }
    
    
    
    private var machineDateText: String {
        guard let dateTime = bluetoothManager.dateTime else {
            return "--"
        }

        let parts = dateTime.split(separator: " ")

        guard parts.count == 2 else {
            return "--"
        }

        let dateString = String(parts[0])

        let formatter = DateFormatter()
        formatter.dateFormat = DeviceDateFormat.date

        guard let date = formatter.date(from: dateString) else {
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

        guard timeString.count == 6 else {
            return "--"
        }

        let hour = timeString.prefix(2)
        let minute = timeString.dropFirst(2).prefix(2)
        let second = timeString.suffix(2)

        return "\(hour):\(minute):\(second)"
    }
    
    
    
    
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                
                
                Text("İyonizörlü Koku Giderme Cihazı")
                    .font(.headline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 12)
                    .padding(.bottom, 20)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Serial Number")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text(bluetoothManager.serialNumber ?? "--")
                        .font(.body)
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 20)
                
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Calibration")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text(calibrationText)
                        .font(.body)
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 20)
                
                Text("DATE & TIME")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                VStack(alignment: .leading, spacing: 14) {
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Machine Date")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text(machineDateText)
                            .font(.body)
                            .fontWeight(.medium)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Machine Time")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text(machineTimeText)
                            .font(.body)
                            .fontWeight(.medium)
                    }
                    
                    Button("Set Date & Time") {
                        let now = Date()

                        let formatter = DateFormatter()
                        formatter.dateFormat = DeviceDateFormat.dateTime

                        let dateString = formatter.string(from: now)

                        let weekdayFormatter = DateFormatter()
                        weekdayFormatter.locale = Locale(identifier: "tr_TR")
                        weekdayFormatter.dateFormat = DeviceDateFormat.weekday

                        let weekday = weekdayFormatter.string(from: now)

                        let command = "?D \(dateString)\(weekday)"

                        bluetoothManager.sendDateTime(command)
                    }
                    .buttonStyle(.bordered)
                }
                // picker command send
                HStack(spacing: 8) {
                    Picker("Select command...", selection: $selectedCommand) {
                        Text("Select command...")
                            .tag(Command?.none)
                        
                        Text("Serial Number")
                            .tag(Command?.some(.serialNumber))
                        
                        Text("Calibration")
                            .tag(Command?.some(.calibrationDate))
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
                .padding(.top, 50)
                .padding(.bottom, 20)
                .frame(maxWidth: .infinity) 
            }
            .padding(.horizontal, 32)
        }
        .navigationTitle("Information")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    InformationView(
        bluetoothManager: BluetoothManager()
    )
}
