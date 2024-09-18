import SwiftUI
import CoreBluetooth

struct PrinterSelectionView: View {
    @ObservedObject var printerManager: BluetoothPrinterManager
    @Binding var selectedPrinter: CBPeripheral?  // Aceptar selectedPrinter como un binding

    var body: some View {
        NavigationView {
            List(printerManager.discoveredPrinters, id: \.identifier) { peripheral in
                Button(action: {
                    selectedPrinter = peripheral  // Asigna la impresora seleccionada
                    print("Impresora seleccionada: \(selectedPrinter?.name ?? "Ninguna")")
                    printerManager.connectToPrinter(peripheral: peripheral)
                }) {
                    Text(peripheral.name ?? "Impresora Desconocida")
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .navigationTitle("Seleccionar Impresora")
            .onAppear {
                printerManager.scanForPrinters()
            }
        }
    }
}
