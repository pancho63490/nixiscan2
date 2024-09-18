import AVFoundation
import UIKit

class Barcodescannerviewcontroller: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var detectionRectangle: UIView!
    var completion: ((String?) -> Void)?  // Callback para pasar el código escaneado

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        checkCameraPermission()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
        updateDetectionRectangle()
    }

    func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            DispatchQueue.global(qos: .userInitiated).async {
                self.setupCamera()
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.setupCamera()
                    }
                }
            }
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.presentCameraSettings()
            }
        @unknown default:
            fatalError("Unknown authorization status")
        }
    }

    func setupCamera() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr, .ean8, .ean13, .code128] // Puedes agregar más tipos si lo necesitas
            metadataOutput.rectOfInterest = CGRect(x: 0, y: 0, width: 1, height: 1)

            DispatchQueue.main.async {
                self.setupPreviewLayer()
                self.setupDetectionRectangle()
                self.captureSession.startRunning()
            }
        } else {
            return
        }
    }

    func setupPreviewLayer() {
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.previewLayer.frame = self.view.layer.bounds
        self.previewLayer.videoGravity = .resizeAspectFill
        self.view.layer.addSublayer(self.previewLayer)
    }

    func setupDetectionRectangle() {
        self.detectionRectangle = UIView()
        self.detectionRectangle.layer.borderColor = UIColor.green.cgColor
        self.detectionRectangle.layer.borderWidth = 2
        self.view.addSubview(self.detectionRectangle)
        self.view.bringSubviewToFront(self.detectionRectangle)
        updateDetectionRectangle()
    }

    func updateDetectionRectangle() {
        if let previewLayer = previewLayer {
            let rectConverted = previewLayer.layerRectConverted(fromMetadataOutputRect: CGRect(x: 0.4, y: 0.2, width: 0.2, height: 0.6))
            detectionRectangle.frame = rectConverted
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }

            // Detener la sesión de captura una vez que se ha escaneado el código
            captureSession.stopRunning()

            // Llamar a la función de retorno con el código escaneado
            completion?(stringValue)

            // Opción para volver a iniciar la captura después de una pausa
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.captureSession.startRunning()
            }
        }
    }

    func presentCameraSettings() {
        let alertController = UIAlertController(title: "Permiso de Cámara", message: "La cámara está deshabilitada. Por favor, habilítela en la configuración.", preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Abrir Configuración", style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: nil)
            }
        })

        present(alertController, animated: true, completion: nil)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
}
