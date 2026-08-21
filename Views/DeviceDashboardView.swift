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
            VStack(spacing: 0) {
                
                
                HStack(spacing: 8) {
                    Text(machineDateText)
                    Text(machineTimeText)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)
                
                
                // Tarih/saat ile sıcaklık-nem arasında boşluk
                Spacer()
                    .frame(height: 70)
                
                HStack(spacing: 40) {
                    
                    // Temperature
                    VStack(alignment: .center, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "thermometer.medium")
                                .font(.title2)
                                .foregroundStyle(.blue)
                            
                            Text("Sıcaklık")
                                .font(.headline)
                        }
                        
                        if let temperature = bluetoothManager.temperature {
                            Text("\(temperature, specifier: "%.2f") °C")
                                .font(.system(size: 28, weight: .bold))
                        } else {
                            Text("-- °C")
                                .font(.system(size: 28, weight: .bold))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    
                    // Humidity
                    VStack(alignment: .center, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "humidity")
                                .font(.title2)
                                .foregroundStyle(.blue)
                            
                            Text("Nem")
                                .font(.headline)
                        }
                        
                        if let humidity = bluetoothManager.humidity {
                            Text("\(humidity, specifier: "%.0f") %")
                                .font(.system(size: 28, weight: .bold))
                        } else {
                            Text("-- %")
                                .font(.system(size: 28, weight: .bold))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(.horizontal, 20)
                
                
                // Machine Level
                VStack(spacing: 16) {
                    
                    HStack(spacing: 8) {
                        Image(systemName: "gearshape.2")
                            .font(.title2)
                            .foregroundStyle(.blue)
                        
                        Text("Cihaz Seviyesi")
                            .font(.headline)
                    }
                    
                    ZStack {
                        // Arka plan çemberi
                        Circle()
                            .stroke(
                                Color(.systemGray5),
                                style: StrokeStyle(lineWidth: 16)
                            )
                        
                        // Aktif bolum
                        Circle()
                            .trim(
                                from: 0,
                                to: bluetoothManager.level.map { CGFloat($0) / 10 } ?? 0
                            )
                            .stroke(
                                Color.blue,
                                style: StrokeStyle(
                                    lineWidth: 16,
                                    lineCap: .round
                                )
                            )
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 0.4), value: bluetoothManager.level)
                        
                        ForEach(0..<10) { index in
                            Rectangle()
                                .fill(Color.black)
                                .frame(width: 3, height: 8)
                                .offset(y: -80)
                                .rotationEffect(.degrees(Double(index) * 36))
                        }
                        

                        VStack(spacing: 4) {
                            Text("Seviye")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                            
                            if let level = bluetoothManager.level {
                                Text("\(Int(level))")
                                    .font(.system(size: 56, weight: .bold))
                            } else {
                                Text("--")
                                    .font(.system(size: 56, weight: .bold))
                            }
                        }
                    }
                    .frame(width: 175, height: 175)
                }
                .padding(.top, 35)
                
                HStack {
                    Button {
                        bluetoothManager.send(message: LevelCommand.decrease.rawValue)
                    } label: {
                        Image(systemName: "minus")
                            .font(.title2)
                            .frame(width: 50, height: 50)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(bluetoothManager.level == 1)

                    Spacer()

                    Button {
                        bluetoothManager.send(message: LevelCommand.increase.rawValue)
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                            .frame(width: 50, height: 50)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(bluetoothManager.level == 10)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 25)
                .padding(.top, 20)
                
                
                Spacer()
            }
            .padding(.top, 10)
            .padding(.horizontal, 20)
            .safeAreaInset(edge: .bottom) {
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
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .clipShape(Capsule())
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }
            
            .navigationTitle("Kontrol Paneli")
            .navigationBarTitleDisplayMode(.inline)
            
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        NavigationLink {
                            InformationView(
                                bluetoothManager: bluetoothManager
                            )
                        } label: {
                            Label(
                                "Bilgi Ekranı",
                                systemImage: "info.circle"
                            )
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.title3)
                    }
                }
            }
        }
    }
}

#Preview {
    DeviceDashboardView(
        bluetoothManager: BluetoothManager()
    )
}
