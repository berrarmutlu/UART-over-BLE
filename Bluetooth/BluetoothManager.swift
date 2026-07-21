//
//  BluetoothManager.swift
//  UART over BLE
//
//  Created by Berra Armutlu on 14.07.2026.
//

import Combine
import CoreBluetooth

final class BluetoothManager: NSObject,
                              ObservableObject,
                              CBCentralManagerDelegate,
                              CBPeripheralDelegate {
    @Published private(set) var isBluetoothReady = false
    @Published private(set) var statusMessage = "Bluetooth hazırlanıyor"
    
    private var centralManager: CBCentralManager?
    @Published private(set) var discoveredPeripherals: [CBPeripheral] = [] //bulunan cihazlar listeye eklenir
    private var discoveredPeripheral: CBPeripheral?
    
    private var txCharacteristic: CBCharacteristic?
    private var rxCharacteristic: CBCharacteristic?
    private let uartServiceUUID = CBUUID(string: "FFE0") //degisememeleri gerektiginden let
    private let uartCharacteristicUUID = CBUUID(string: "FFE1")
    
    override init() {
        super.init()
        centralManager = CBCentralManager(
            delegate: self, //delegate haber verme mekanizmasi, self o anda icinde bulunulan nesne
            queue: nil
        )
    }
    
    //bluetooth durumunun kontrol eder ve uygulamayi gunceller
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            isBluetoothReady = true //isbluetoothready sadece true false tutar
            statusMessage = "Bluetooth hazır" //statusmassage metni tutar
        case .poweredOff:
            isBluetoothReady = false
            statusMessage = "Bluetooth kapalı"
        case .unauthorized:
            isBluetoothReady = false
            statusMessage = "Bluetooth izni yok"
        case .unsupported:
            isBluetoothReady = false
            statusMessage = "Bu cihaz Bluetooth'u desteklemiyor"
        case .resetting:
            isBluetoothReady = false
            statusMessage = "Bluetooth yeniden başlatılıyor"
        case .unknown:
            isBluetoothReady = false
            statusMessage = "Bluetooth durumu bilinmiyor"
        @unknown default:
            isBluetoothReady = false
            statusMessage = "Bluetooth durumu bilinmiyor"
        }
    }
    
    //scan baslatma asamasi
    func scan() { //disariya acik, gorevi bildiriyor, bu fonk cagirilacak buradan startscan fonk erisilecek
        guard isBluetoothReady else { //bluetooth hazir mi degil mi
            return
        }
        startScan()
    }
    
    private func startScan() { //CB asil isi burada yapiyor
        centralManager?.scanForPeripherals( // ? optional chaining - satir 16, BLE cihazlarini tara
            withServices: nil, //nill cunku filtreleme yapmasin istiyoruz, cevredeki butun cihazlari bulur
            options: nil
        )
    }
    
    //cihaz adi al kaydet
    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral, //CBPeripheral, apple'in buldugu ble cihazini temsil eden nesne
        advertisementData: [String : Any],
        rssi RSSI: NSNumber
    ) {
        guard let deviceName = peripheral.name else { //guard let burada optional degeri guvenli sekilde acar
            return
        }
        
        let alreadyExists = // bulunan cihaz listede var mi kontrol et
        discoveredPeripherals // daha once bulunan BLE cihazlarinin listesi
            .contains { device in // listedeki her cihaz icin kontrol yap
                device.identifier == peripheral.identifier // UUID'ler ayniysa cihaz zaten listede vardir
            }
        
        if !alreadyExists { //eger bu cihaz daha once listede yoksa listeye ekle, ! not operatoru degeri tersine cevirir
            discoveredPeripherals.append(peripheral)
        }
        
        print("Bulunan cihaz: \(deviceName)")
    }
    
    //secilen cihaza baglanti istegi gonderir
    func connect(to peripheral: CBPeripheral) {
        centralManager?.connect(peripheral)
    }
    
    //baglanti kuruldugunda ihazin servislerini kesfetmeye baslar
    func centralManager(
        _ central: CBCentralManager,
        didConnect peripheral: CBPeripheral
    ) {
        discoveredPeripheral = peripheral
        peripheral.delegate = self // callbackler bluetoothmanagera gelsin
        peripheral.discoverServices(nil) // hm10un butun servislerini istemek
    }
    
    //bagli cihazin servislerini kontrol eder ve uart servisi bulursa characteristic kesfini baslatir
    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverServices error: Error? //error var mi varsa if let blogu calisir
    ) {
        if let error = error {
            print("Servisler bulunamadı: \(error)")
            return
        }
        guard let services = peripheral.services else { //hata yoksa servisleri al
            return
        }
        for service in services { //bulunan butun servisleri geziyoruz
            print(service.uuid) //servisin kimligi, uuidsini al
            if service.uuid == uartServiceUUID {
                peripheral.discoverCharacteristics(nil, for: service) //servisin characteristiclerini kesfet
            }
        }
    }
    
    //notify ile gelen veriyi alir ve datadan stringe donusturur
    func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?
    ) {
        if let error = error {
            print("Characteristic'ler bulunamadı: \(error)")
            return
        }
        guard let characteristics = service.characteristics else {
            return
        }
        for characteristic in characteristics {
            print(characteristic.uuid)
            
            if characteristic.uuid == uartCharacteristicUUID { //characteristic bulundugunda
                txCharacteristic = characteristic //characteristic sakla
                rxCharacteristic = characteristic
                
                guard let rxCharacteristic else {
                    return
                }
                peripheral.setNotifyValue(true, for: rxCharacteristic)
            }
        }
    }
    
    //notify ile gelen veriyi alir ve datadan stringe donusturur
    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateValueFor characteristic: CBCharacteristic, //yeni veri geldi mi
        error: Error?
    ) {
        if let error = error { //hata kontrolu
            print("Veri alınamadı: \(error.localizedDescription)")
            return
        }
        guard characteristic.uuid == uartCharacteristicUUID else {
            return
        }
        guard let data = characteristic.value else { //byte data olarak tasinir
            return
        }
        guard let message = String(data: data, encoding: .utf8) else {
            return
        }
        print("Gelen veri: \(message)")
    }
    
    //notify ozelliginin acilip acilmadigini kontrol eder
    func peripheral(
        _ peripheral: CBPeripheral,
        didUpdateNotificationStateFor characteristic: CBCharacteristic, //notify istegi basarili oldu mu
        error: Error?
    ) {
        if let error = error {
            print("Notify açılamadı: \(error.localizedDescription)")
            return
        }
        guard characteristic.uuid == uartCharacteristicUUID else {
            return
        }
        if characteristic.isNotifying {
            print("Notify başarıyla açıldı.")
        } else {
            print("Notify kapandı.")
        }
    }
    
    // CoreBluetooth yalnizca Data (byte dizisi) gönderebildigi icin
    // Stringi UTF-8 kullanarak Datya donusturuyoruz
    func send(message: String) {
        guard let data = message.data(using: .utf8) else {
            return
        }
        guard let txCharacteristic else {
            return
        }
        guard let discoveredPeripheral else { //elimizde bagli oldugumuz bir peripheral olmali
            return
        }
        discoveredPeripheral.writeValue(
            data,
            for: txCharacteristic, //verinin yazilacagi characteristic
            type: .withResponse //yazma islemi tammalandiginda apple callback gonderir
        )
    }
    
    //gonderilen verinin basariyla yazilip yazilmadigini kontrol eder
    func peripheral(
        _ peripheral: CBPeripheral,
        didWriteValueFor characteristic: CBCharacteristic,
        error: Error?
    ) {
        if let error = error {
            print("Veri gönderilemedi: \(error.localizedDescription)")
            return
        }
        guard characteristic.uuid == uartCharacteristicUUID else {
            return
        }
        print("Veri başarıyla gönderildi.")
    }
}
