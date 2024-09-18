import SwiftUI
import AVFoundation

struct Barcodescannerview: UIViewControllerRepresentable {
    @Binding var scannedCode: String? // Valor del código escaneado que se enlaza con SwiftUI
    @Environment(\.dismiss) var dismiss // Para cerrar la vista al escanear

    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: Barcodescannerview

        init(parent: Barcodescannerview) {
            self.parent = parent
        }

        // Aquí se puede manejar el resultado del escaneo, pero lo hacemos en el controller
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> Barcodescannerviewcontroller {
        let viewController = Barcodescannerviewcontroller()

        // Configuramos el completion para obtener el código escaneado
        viewController.completion = { scannedValue in
            self.scannedCode = scannedValue
            self.dismiss() // Cerrar la vista automáticamente después de escanear
        }

        return viewController
    }

    func updateUIViewController(_ uiViewController: Barcodescannerviewcontroller, context: Context) {
        // No es necesario actualizar nada por ahora
    }
}
