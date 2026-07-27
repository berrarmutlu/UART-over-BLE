// Şu an BluetoothManager ObservableObject olduğu için
// test uygulamasında ViewModel görevini de üstlenmektedir.
// İleride gerçek MVVM yapısına ayrılacaktır.

import Combine

final class BluetoothViewModel: ObservableObject { //bluetoothviewmodel yeni ara katman, ekran bilgisi degisebilir
    @Published private(set) var isBluetoothReady = false //ekranin kullanima hazir mi diye bakacagi bilgi
    @Published private(set) var statusMessage = "Bluetooth hazırlanıyor"
    //published bilgiler degisirse swiftui ekrani otomatik yeniler
    //private(set) okunabilir ama degistirilemez, viewmodel degistirebilir 

    private let bluetoothManager = BluetoothManager() //viewmodel bluetoothmanageri icinde tutar
}
