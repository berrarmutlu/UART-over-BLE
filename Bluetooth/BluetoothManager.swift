//
//  BluetoothManager.swift
//  UART over BLE
//
//  Created by Berra Armutlu on 14.07.2026.
//

import Combine
import CoreBluetooth

enum Command: String { //komut(lar)
    case temperature = "?T"
    case humidity = "?H"
    case level = "?L"
    case dateTime = "?D"
    
    }

final class BluetoothManager: NSObject,
                              ObservableObject,
                              CBCentralManagerDelegate,
                              CBPeripheralDelegate {
    //view un takip edecegi state bilgileri
    @Published private(set) var isBluetoothReady = false
    @Published private(set) var statusMessage = "Bluetooth hazırlanıyor"
    @Published private(set) var isConnected = false
    @Published private(set) var receivedMessage = "" //kontrol amacli
    @Published private(set) var humidity: Double?
    @Published private(set) var temperature: Double?
    @Published private(set) var level: Double?
    @Published private(set) var dateTime: String?
    @Published private(set) var commandStatus = ""
    
    private var centralManager: CBCentralManager?
    @Published private(set) var discoveredPeripherals: [CBPeripheral] = [] //bulunan cihazlar listeye eklenir
    private var connectedPeripheral: CBPeripheral?
    
    private var pendingCommand: Command? //su anda hangi komutun cevabini bekliyorum
    
    private var txCharacteristic: CBCharacteristic? //UART TX -> BLE Write
    private var rxCharacteristic: CBCharacteristic? //UART RX -> BLE Notify
    private let uartServiceUUID = CBUUID(string: "FFE0") //degisememeleri gerektiginden let
    private let uartCharacteristicUUID = CBUUID(string: "FFE1") //baglandiktan sonra dogru haberlesme kanalini secmek
    
    
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
            isBluetoothReady = true
            statusMessage = "Bluetooth hazır"
            
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
        statusMessage = "Taranıyor..."
        discoveredPeripherals = [] //eski liste temizlenir
        startScan()
    }
    
    private func startScan() { //CB asil isi burada yapiyor
        centralManager?.scanForPeripherals( // ? optional chaining - satir 16, BLE cihazlarini tara
            withServices: nil, //nill cunku filtreleme yapmasin istiyoruz, cevredeki butun cihazlari bulur
            options: nil
        )
    }
    
    private func stopScan() {
        centralManager?.stopScan()
        print("Tarama durduruldu.") //consol ciktisi
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
        
        guard deviceName.contains("INDOR") else { //cihaz adinda INDOR geciyor mu
            return
        }
        
        let alreadyExists = // bulunan cihaz listede var mi kontrol et
        discoveredPeripherals // daha once bulunan BLE cihazlarinin listesi
            .contains { device in // listedeki her cihaz icin kontrol yap
                device.identifier == peripheral.identifier // UUID'ler ayniysa cihaz zaten listede vardir
            }
        
        if !alreadyExists { //eger bu cihaz daha once listede yoksa listeye ekle, ! not operatoru degeri tersine cevirir
            discoveredPeripherals.append(peripheral)
            print("Bulunan cihaz: \(deviceName)")
        }
    }
    
    //secilen cihaza baglanti istegi gonderir
    func connect(to peripheral: CBPeripheral) {
        statusMessage = "Bağlanıyor..."
        centralManager?.connect(peripheral, options: nil)
    }
    
    //secilen cihaza baglanti kesme istegi gonderir
    func disconnect() {
        guard let connectedPeripheral else {
            return
        }
        centralManager?.cancelPeripheralConnection(connectedPeripheral)
    }
    
    //baglanti kuruldugunda cihazin servislerini kesfetmeye baslar
    func centralManager(
        _ central: CBCentralManager,
        didConnect peripheral: CBPeripheral
    ) {
        
        stopScan() //didConnect icinde cunku baglanti kurulduktan sonra scan dursun istiyoruz
        
        connectedPeripheral = peripheral
        isConnected = true
        statusMessage = "Bağlandı"
        peripheral.delegate = self // callbackler bluetoothmanagera gelsin
        peripheral.discoverServices(nil) // hm10un butun servislerini istemek
    }
    
    //baglanti basarisizsa cagirilir
    func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: Error?
    ) {
        statusMessage = "Bağlantı başarısız"
        print("Bağlanılamadı")
        
        if let error {
            print(error.localizedDescription)
        }
    }
    
    //baglanti kesilirse cagirilir
    func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Error?
    ) {
        statusMessage = "Bağlantı kesildi"
        print("Bağlantı kesildi")
        connectedPeripheral = nil
        txCharacteristic = nil //baglanti kesildiginde gecerli olamazlar
        rxCharacteristic = nil
        pendingCommand = nil
        isConnected = false
        
        if let error {
            print(error.localizedDescription)
        }
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
    
    //servis icindeki characteristicleri kontrol eder ve UART characteristicini hazirlar
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
        receivedMessage = message //kontrol amacli
        
        let cleanMessage = message.trimmingCharacters(in: .whitespacesAndNewlines) //gelen stringi temizleme
        let parts = cleanMessage.split(separator: "_") //mesaji parcalara ayirir (komut_deger)
        guard parts.count == 2 else { //iki parca mi kontrolu
            print("Geçersiz cevap formatı: \(cleanMessage)")
            return
        }
        let responseCommand = String(parts[0])
        let responseValue = String(parts[1])
        
        print("Cevap komutu: \(responseCommand)")
        print("Cevap değeri: \(responseValue)")
        
        //komut cevabi bekleniyor mu
        guard let pendingCommand else {
            print("Beklenen bir komut cevabı yok.")
            return
        }
        
        //gelen cevap gonderilen komuta ait mi
        guard responseCommand == pendingCommand.rawValue else {
            print("Beklenmeyen cevap: \(responseCommand)")
            print("Beklenen cevap: \(pendingCommand.rawValue)")
            return
        }
        
        switch pendingCommand { //gelen degeri cevabi beklenen komuta gore isler
        case .temperature:
            guard let value = Double(responseValue) else { //sicakalik verisi kendi icinde double cevrilir
                print("Sıcaklık değeri sayıya çevrilemedi: \(responseValue)")
                return
            }
            temperature = value
            commandStatus = "Cevap alındı"
            print("Sıcaklık güncellendi: \(value)")
            
        case .humidity:
            guard let value = Double(responseValue) else { //nem verisi kendi icinde double cevrilir
                print("Nem değeri sayıya çevrilemedi: \(responseValue)")
                return
            }
            humidity = value
            commandStatus = "Cevap alındı"
            print("Nem güncellendi: \(value)")
            
        case .level:
            guard let value = Double(responseValue) else { //kademe verisi kendi icinde double cevrilir
                print("Kademe değeri sayıya çevrilemedi: \(responseValue)")
                return
            }
            level = value
            commandStatus = "Cevap alındı"
            print("Kademe güncellendi: \(value)")
            
        case .dateTime:
            dateTime = responseValue
            commandStatus = "Cevap alındı"
            print("Tarih-Saat güncellendi: \(responseValue)")
        }
        self.pendingCommand = nil
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
    
    
    //String komutu BLE üzerinden gönderir
    func send(message: String) {
        //girilen mesaj tanimli bir komutsa command icine alir
        guard let command = Command(rawValue: message) else {
            commandStatus = "Geçersiz komut"
            print("Geçersiz komut: \(message)")
            return
        }
        //String veriyi BLE'nin gönderebileceği Data tipine cevirir
        guard let data = message.data(using: .utf8) else {
            return
        }
        guard let txCharacteristic else {
            return
        }
        guard let connectedPeripheral else {
            return
        }
        //hangi komutun cevabini bekledigimizi saklar
        pendingCommand = command
        commandStatus = "Cevap bekleniyor..."
        
        connectedPeripheral.writeValue(
            data,
            for: txCharacteristic,
            type: .withoutResponse
        )
    }
    
}
