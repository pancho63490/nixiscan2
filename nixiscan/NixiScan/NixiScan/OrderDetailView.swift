import SwiftUI
import ExternalAccessory

struct OrderDetailView: View {
    @ObservedObject var viewModel: OrderDetailViewModel
    @State private var selectedExternalPrinter: EAAccessory? = nil
    @State private var showAlert = false
    @State private var scannedCode: String? = nil
    @State private var isPrintingSuccess = false
    @State private var showAnimation = false  // Controla la animación de éxito/falla

    var body: some View {
        ZStack {
            Color(UIColor.systemGray6).ignoresSafeArea()

            VStack(spacing: 20) {
                VStack(spacing: 10) {
                    Text("Detalles de la Orden")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.top,50)

                    HStack {
                        Text("Order ID:")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Spacer()
                        Text(viewModel.orderId)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.gray.opacity(0.3), radius: 8, x: 0, y: 4)

                    Divider().padding(.vertical, 10)

                    if let code = scannedCode {
                        HStack {
                            Text("Código Escaneado:")
                                .font(.headline)
                                .foregroundColor(.gray)
                            Spacer()
                            Text(code)
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.gray.opacity(0.3), radius: 8, x: 0, y: 4)
                    } else {
                        Text("No se ha escaneado ningún código.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                // Campo para la cantidad de cajas
                VStack(alignment: .leading, spacing: 10) {
                    Text("Cantidad de Cajas")
                        .font(.headline)
                        .foregroundColor(.gray)
                    TextField("Introduce la cantidad de cajas", text: $viewModel.boxesQty)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.gray.opacity(0.3), radius: 8, x: 0, y: 4)
                }

                // Botón para seleccionar la impresora
                Button(action: {
                    ViewController().updateConnectedAccessories()
                    selectedExternalPrinter = ViewController().connectedAccessories.first
                }) {
                    HStack {
                        Image(systemName: "printer")
                            .foregroundColor(.white)
                        Text("Seleccionar Impresora")
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                    .shadow(color: Color.blue.opacity(0.6), radius: 10, x: 0, y: 5)
                }

                // Botón para imprimir
                Button(action: {
                    if let externalPrinter = selectedExternalPrinter {
                        ViewController().connectEaAccessory(eaAccessory: externalPrinter)
                        simulatePrintAnimation()
                    } else {
                        print("Por favor selecciona una impresora.")
                    }
                }) {
                    HStack {
                        Image(systemName: "doc.on.doc.fill")
                            .foregroundColor(.white)
                        Text("Imprimir")
                            .foregroundColor(.white)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(12)
                    .shadow(color: Color.green.opacity(0.6), radius: 10, x: 0, y: 5)
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .onTapGesture {
                UIApplication.shared.hideKeyboard()
            }

            // Animación de éxito o fallo de impresión
            if showAnimation {
                VStack {
                    if isPrintingSuccess {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 100))
                        Text("Impresión Exitosa")
                            .font(.headline)
                    } else {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .font(.system(size: 100))
                        Text("Impresión Fallida")
                            .font(.headline)
                    }
                }
                .transition(.scale)
            }
        }
        .navigationTitle("Detalles de la Orden")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Simular la animación de impresión
    private func simulatePrintAnimation() {
        withAnimation {
            showAnimation = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showAnimation = false
            }
        }
    }
}
