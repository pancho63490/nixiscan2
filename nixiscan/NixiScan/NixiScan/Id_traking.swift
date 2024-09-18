import SwiftUI

struct OrderListView: View {
    let orders = ["12345", "67890", "54321","87567", "54386", "74732","87567", "54386", "74732"]
    
    // Generar aleatoriamente un estado para cada orden
    func getStatusColor(for order: String) -> Color {
        let status = Int.random(in: 1...3)  // Genera aleatoriamente un número entre 1 y 3
        switch status {
        case 1:
            return .red  // Pendiente
        case 2:
            return .yellow  // En proceso
        default:
            return .green  // Completada
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Banner con logotipo centrado
                VStack {
                    Image("LOGO")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 120, height: 55)
                    
                    Text("NIXISCAN")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.top, 10)
                }
                .frame(maxWidth: .infinity)
                .background(Color.white)
              
                .padding(.horizontal)
                .padding(.bottom, 20)
                
                // Lista de órdenes con bolitas de estado
                List(orders, id: \.self) { orderId in
                    HStack {
                        // Bolita de estatus
                        Circle()
                            .fill(getStatusColor(for: orderId))  // Color según el estado
                            .frame(width: 20, height: 20)  // Tamaño de la bolita
                        
                        // Enlace a la vista de detalles de la orden
                        NavigationLink(destination: OrderDetailView(viewModel: OrderDetailViewModel(orderId: orderId))) {
                            Text("Orden \(orderId)")
                                .padding()
                                .font(.system(size: 18))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .padding(.vertical, 5)  // Espacio entre las filas
                }
                .listStyle(PlainListStyle())  // Estilo plano para la lista
            }
            .navigationTitle("Lista de Órdenes")
        }
    }
}

struct OrderListView_Previews: PreviewProvider {
    static var previews: some View {
        OrderListView()
    }
}
#Preview {
    OrderListView()
}
