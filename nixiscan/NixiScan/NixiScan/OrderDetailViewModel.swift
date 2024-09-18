import Foundation

class OrderDetailViewModel: ObservableObject {
    @Published var orderId: String
    @Published var boxesQty: String = ""
    @Published var scannedCode: String? = nil

    init(orderId: String) {
        self.orderId = orderId
    }
    
    func confirmOrder() {
        // Lógica de confirmación
        print("Orden \(orderId) confirmada con \(boxesQty) cajas. Código escaneado: \(scannedCode ?? "No se escaneó código")")
    }
}
