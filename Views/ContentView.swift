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
        VStack(spacing: 16) { // iki eleman arasinda 16 point bosluk
            Spacer() //bos alan
            
            Text("UART over BLE") // ekrana yazi yaz yazma
                .font(.title2) // yaziyi buyutme
                .fontWeight(.semibold) // yaziyi kalinlastir
            
            Text(bluetoothManager.statusMessage) //bluetooth durumunu ekrana yazdirir
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            
            Button("Scan Devices") {
                bluetoothManager.scan()
            }
            .buttonStyle(.borderedProminent) // butonun gorunusu
            
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
            Spacer() // bos alan
        }
        .padding() // ekranin kenarlarinda bosluk birakma
    }
}

#Preview {
    ContentView()
}
