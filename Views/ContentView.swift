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
    @State private var message = "" //kullanicinin yazdigi metni tutar
    var body: some View {
        
        
        VStack(spacing: 16) { //iki eleman arasinda 16 point bosluk
            Spacer() //bos alan
            
            Text("UART over BLE")
                .font(.title2) // yaziyi buyutme
                .fontWeight(.semibold) // yaziyi kalinlastir
            
            Text(bluetoothManager.statusMessage) //bluetooth durumu
            
            if !bluetoothManager.isConnected {
                Button("Scan Devices") {
                    bluetoothManager.scan()
                }
                .buttonStyle(.borderedProminent) //butonun gorunusu
                
                if bluetoothManager.discoveredPeripherals.isEmpty {
                    Text("Henüz cihaz bulunamadı.")
                        .foregroundStyle(.secondary)
                } else {
                    List {
                        ForEach(bluetoothManager.discoveredPeripherals, id: \.identifier) { peripheral in
                            
                            Button {
                                bluetoothManager.connect(to: peripheral)
                                
                            } label: {
                                Text(peripheral.name ?? "Unknown Device")
                            }
                        }
                    }
                    .frame(height: 250)
                }
            }
            
            if bluetoothManager.isConnected {
                            
                Button("Disconnect") {
                    bluetoothManager.disconnect()
                }
                .buttonStyle(.bordered)
                
                HStack(spacing: 12) { //temperature ve humidity ekranda yan yana dizilir
                    
                    //temperature sicaklik
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Temperature")
                            .font(.headline)
                        if let temperature = bluetoothManager.temperature {
                            Text("\(temperature, specifier: "%.1f") °C") //__,_ seklindeki gosterim
                                .font(.system(size: 32, weight: .bold))
                        } else {
                            Text("-- °C") //veri yoksa bos gorunum
                                .font(.system(size: 32, weight: .bold))
                                .frame(maxWidth: .infinity, alignment: .leading) //yan yana, sola yatik
                        }
                    }
                    
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    //humidity nem
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Humidity")
                            .font(.headline)
                        
                        if let humidity = bluetoothManager.humidity {
                            Text("\(humidity, specifier: "%.1f") %")
                                .font(.system(size: 32, weight: .bold))
                        } else {
                            Text("-- %")
                                .font(.system(size: 32, weight: .bold))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Level")
                        .font(.headline)
                    
                    if let level = bluetoothManager.level {
                        Text("\(level, specifier: "%.0f")")
                            .font(.system(size: 32, weight: .bold))
                    } else {
                        Text("--")
                            .font(.system(size: 32, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Date Time")
                        .font(.headline)
                    
                    if let dateTime = bluetoothManager.dateTime {
                        Text(dateTime)
                            .font(.system(size: 32, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        Text("--")
                            .font(.system(size: 32, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                //mesaj alani
                HStack { //komut girisi ve gonderme butonunu yan yana gosterir
                    TextField("Enter command (?T, ?H, ?L, ?D)", text: $message)
                        .textFieldStyle(.roundedBorder)
                    
                    Button("Send") {
                        bluetoothManager.send(message: message)
                        message = ""
                    }
                    .buttonStyle(.borderedProminent)
                }
                
                if !bluetoothManager.commandStatus.isEmpty { //commandStatus bos degilse UI gosterir
                    Text(bluetoothManager.commandStatus)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                //ui kontrolu amacli
//                Text("Received Data")
//                    .font(.headline)
//                Text(bluetoothManager.receivedMessage)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding()
//                    .background(Color(.systemGray6))
//                    .cornerRadius(12)
            }
            
            
            Spacer() // bos alan
        }
        .padding() // ekranin kenarlarinda bosluk birakma
    }
}

#Preview {
    ContentView()
}
