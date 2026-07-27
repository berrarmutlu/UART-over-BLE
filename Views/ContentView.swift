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
            
            Text(bluetoothManager.statusMessage) //bluetooth durumunu ekrana yazdirir
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            
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
            
            if bluetoothManager.isConnected {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Temperature") //sicaklik verisi
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
                
                HStack { //sola yatik yan yana
                    TextField("Mesaj giriniz", text: $message)
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
                
                Text("Received Data")
                    .font(.headline)
                Text(bluetoothManager.receivedMessage)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }
            
            Spacer() // bos alan
        }
        .padding() // ekranin kenarlarinda bosluk birakma
    }
}

#Preview {
    ContentView()
}
