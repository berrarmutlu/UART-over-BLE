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
            return "\(days) gün kaldı"
        } else if days < 0 {
            return "\(abs(days)) gün gecikti"
        } else {
            return "Kalibrasyon gerekli"
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
        
            VStack(alignment: .leading, spacing: 0) {

                Text("İyonizörlü Koku Giderme Cihazı")
                    .font(.title2)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 12)
                    .padding(.bottom, 24)


                VStack(spacing: 0) {

                    HStack {
                        Text("Seri Numarası")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Spacer()

                        Text(bluetoothManager.serialNumber ?? "--")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .padding(.vertical, 12)

                    Divider()

                    HStack {
                        Text("Kalibrasyon")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Spacer()

                        Text(calibrationText)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .padding(.vertical, 12)

                    Divider()

                    HStack {
                        Text("Makine Tarihi")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Spacer()

                        Text(machineDateText)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .padding(.vertical, 12)

                    Divider()

                    HStack {
                        Text("Makine Saati")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Spacer()

                        Text(machineTimeText)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .padding(.vertical, 12)
                


                Button("Tarih & Saat Ayarla") {
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
                .frame(maxWidth: .infinity)
                .padding(.top, 28)

            }
            .padding(.horizontal, 32)
        }
        
        
        VStack(alignment: .leading, spacing: 12) {
            
            Text("ÜRETİCİ")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 4)

            HStack(spacing: 14) {
                
                Image("PCSLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90, height: 90)
                
                VStack(alignment: .center, spacing: 6) {
                    
                    Text("PCS Elektronik")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("Mühendislik ve Danışmanlık")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 16)

            VStack(spacing: 0) {

                Link(
                    "pcselektronik.com.tr",
                    destination: URL(string: "https://pcselektronik.com.tr")!
                )
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 12)

                Divider()

                Link(
                    "info@pcselektronik.com.tr",
                    destination: URL(string: "mailto:info@pcselektronik.com.tr")!
                )
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 12)

                Divider()

                Link(
                    "+90 (535) 465 29 17",
                    destination: URL(string: "tel:+905354652917")!
                )
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 12)

                Divider()

                Link(
                    "+90 (216) 489 17 20",
                    destination: URL(string: "tel:+902164891720")!
                )
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 12)
            }
            .padding(.horizontal, 32)
        }
        .padding(.top, 40)

        .safeAreaInset(edge: .bottom) {
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
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6))
            .clipShape(Capsule())
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }

        .navigationTitle("Bilgi Ekranı")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    InformationView(
        bluetoothManager: BluetoothManager()
    )
}
