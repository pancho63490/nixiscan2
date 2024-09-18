import Foundation

class BrotherPrinterDiscoveryController: NSObject, ObservableObject, NetServiceBrowserDelegate, NetServiceDelegate {
    @Published var availablePrinters: [NetService] = []  // Lista de impresoras descubiertas
    private var serviceBrowser: NetServiceBrowser!

    override init() {
        super.init()
        serviceBrowser = NetServiceBrowser()
        serviceBrowser.delegate = self

    }

    // Iniciar la búsqueda de impresoras Brother en la red local
    func startDiscovery() {
        availablePrinters.removeAll()  // Limpiar lista de impresoras
        serviceBrowser.searchForServices(ofType: "_printer._tcp.", inDomain: "local.")
    }

    // Delegado: Cuando se encuentra una impresora en la red
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        availablePrinters.append(service)
        service.delegate = self
        service.resolve(withTimeout: 10)
        
        // Actualizamos la lista en tiempo real
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }

    // Delegado: Cuando una impresora está lista para su uso
    func netServiceDidResolveAddress(_ sender: NetService) {
        let printerIP = sender.hostName ?? "Desconocido"
        let printerPort = sender.port  // El puerto es un Int, no opcional
        
        print("Impresora encontrada: \(sender.name) con IP: \(printerIP) y Puerto: \(printerPort)")
    }

    // Delegado: Error al resolver la impresora
    func netService(_ sender: NetService, didNotResolve errorDict: [String : NSNumber]) {
        print("No se pudo resolver la impresora: \(sender.name)")
    }
}
