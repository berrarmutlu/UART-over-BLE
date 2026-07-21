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

            Image(systemName: "bluetooth") //bluetooth ikonunu goster
                .font(.system(size: 64)) // ikonun boyutu
                .foregroundStyle(.tint) // ikonun rengi, uygulamanin ana rengi

            Text("UART over BLE") // ekrana yazi yaz yazma
                .font(.title2) // yaziyi buyutme
                .fontWeight(.semibold) // yaziyi kalinlastir

          
            Button("Scan Devices") {
                bluetoothManager.scan()
            }
            List {
                ForEach(bluetoothManager.discoveredPeripherals, id: \.identifier) { peripheral in
                    
                    Button { //kullanici cihaz adina dokundugunda connect(to:) calisir
                        bluetoothManager.connect(to: peripheral)
                    } label: {
                        Text(peripheral.name ?? "Unknown Device")
                    }
                }
            }
            .buttonStyle(.borderedProminent) // butonun gorunusu

            Spacer() // bos alan
        }
        .padding() // ekranin kenarlarinda bosluk birakma
    }
}

#Preview {
    ContentView()
}
