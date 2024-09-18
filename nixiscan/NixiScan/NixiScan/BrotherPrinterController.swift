import Foundation
import PDFKit
import Network

class BrotherPrinterController {
    private var connection: NWConnection?
    private let printerIP: String
    private let printerPort: UInt16

    init(printerIP: String, printerPort: UInt16) {
        self.printerIP = printerIP
        self.printerPort = printerPort
    }

    // Conectarse a la impresora y enviar el PDF generado
    func connectToPrinter(orderId: String, scannedCode: String?, boxesQty: String) {
        let printerEndpoint = NWEndpoint.Host(printerIP)
        let port = NWEndpoint.Port(rawValue: printerPort)!

        connection = NWConnection(host: printerEndpoint, port: port, using: .tcp)

        connection?.stateUpdateHandler = { state in
            switch state {
            case .ready:
                print("Conectado a la impresora")
                self.sendPDFToPrinter(orderId: orderId, scannedCode: scannedCode, boxesQty: boxesQty)
            case .failed(let error):
                print("Error al conectarse: \(error)")
            default:
                break
            }
        }

        connection?.start(queue: .global())
    }

    // Enviar el PDF generado a la impresora
    func sendPDFToPrinter(orderId: String, scannedCode: String?, boxesQty: String) {
        let pdfData = createPDF(orderId: orderId, scannedCode: scannedCode, boxesQty: boxesQty)

        // Enviar el PDF a la impresora
        connection?.send(content: pdfData, completion: .contentProcessed({ error in
            if let error = error {
                print("Error al enviar el PDF: \(error)")
            } else {
                print("PDF enviado correctamente a la impresora")
            }
        }))
    }

    // Generar el PDF con los detalles de la orden
    func createPDF(orderId: String, scannedCode: String?, boxesQty: String) -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "NixiScan",
            kCGPDFContextAuthor: "NixiScan App",
            kCGPDFContextTitle: "Detalles de la Orden"
        ]

        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        let pageWidth = 8.5 * 72.0
        let pageHeight = 11.0 * 72.0
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight), format: format)

        let data = pdfRenderer.pdfData { (context) in
            context.beginPage()

            let font = UIFont.systemFont(ofSize: 18.0)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .left
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .paragraphStyle: paragraphStyle
            ]

            // Crear contenido del PDF
            let content = """
            Orden: \(orderId)
            Código escaneado: \(scannedCode ?? "No hay código")
            Cantidad de cajas: \(boxesQty)
            """
            content.draw(in: CGRect(x: 50, y: 100, width: pageWidth - 100, height: pageHeight - 200), withAttributes: attributes)
        }

        return data
    }
}
