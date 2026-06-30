import SwiftUI

struct ClientServiceDetailView: View {
    let service: ServiceModel // Tu modelo existente de servicios
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.theme.backgroundGradientTop, Color.theme.backgroundGradientBottom]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    
                    // 📡 CARD SUPERIOR: Estado de Conexión
                    VStack(spacing: 12) {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green.opacity(0.3))
                            .clipShape(Circle())
                        
                        // 🚀 CORRECCIÓN: Accedemos mediante la relación correcta de tu objeto plan
                        Text(service.plan?.name ?? "Plan Contratado")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                        
                        HStack {
                            Circle().fill(Color.green).frame(width: 8, height: 8)
                            Text("Servicio Activo en Línea")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(16)
                    
                    // 📊 DETALLE TÉCNICO INTERNET
                    VStack(alignment: .leading, spacing: 14) {
                        Text("DETALLE DE INTERNET")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color.theme.accent)
                        
                        HStack {
                            Label("Velocidad de Bajada:", systemImage: "arrow.down.circle.fill")
                            Spacer()
                            // 🚀 CORRECCIÓN: Accedemos dinámicamente al entero de speed_mbps del plan
                            Text("\(Int(service.plan?.speed_mbps ?? 0)) Mbps").bold()
                        }
                        .foregroundColor(.white)
                        
                        HStack {
                            Label("Tecnología:", systemImage: "fiberchannel")
                            Spacer()
                            Text("Fibra Óptica FTTH").bold()
                        }
                        .foregroundColor(.white)
                        
                        HStack {
                            Label("Ancho de Banda:", systemImage: "gauge.medium")
                            Spacer()
                            Text("Ilimitado").bold()
                        }
                        .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.white.opacity(0.12))
                    .cornerRadius(16)
                    
                    // 🛠️ SERVICIOS COMPLEMENTARIOS HABILITADOS
                    VStack(alignment: .leading, spacing: 14) {
                        Text("SERVICIOS Y PAQUETES DE RED")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color.theme.accent)
                        
                        FilaServicioEstado(nombre: "Wi-Fi Dual Band (2.4GHz / 5GHz)", habilitado: true)
                        FilaServicioEstado(nombre: "Dirección IP Dinámica Pública", habilitado: true)
                        FilaServicioEstado(nombre: "Soporte Técnico Especializado 24/7", habilitado: true)
                        FilaServicioEstado(nombre: "IP Fija / Dedicada Comercial", habilitado: false)
                        FilaServicioEstado(nombre: "Filtro de Control Parental Avanzado", habilitado: false)
                    }
                    .padding()
                    .background(Color.white.opacity(0.12))
                    .cornerRadius(16)
                    
                    // 📍 UBICACIÓN DE INSTALACIÓN
                    VStack(alignment: .leading, spacing: 12) {
                        Text("DATOS DE INSTALACIÓN")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Color.theme.accent)
                        
                        // 🚀 CORRECCIÓN UNWRAP: Forzamos el desempaquetado seguro con ?? para evitar el crash del compilador
                        Label(service.address_text ?? "Sin dirección", systemImage: "mappin.and.ellipse")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                        
                        Text("Ciclo de Facturación: Día \(service.billing_day ?? 21) de cada mes")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.12))
                    .cornerRadius(16)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
        }
        .navigationTitle("Detalle de mi Servicio")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Sub-componente de fila de estados
struct FilaServicioEstado: View {
    let nombre: String
    let habilitado: Bool
    
    var body: some View {
        HStack {
            Text(nombre)
                .font(.system(size: 14))
                .foregroundColor(.white)
            Spacer()
            Text(habilitado ? "Activo" : "Desactivado")
                .font(.caption)
                .bold()
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(habilitado ? Color.green.opacity(0.25) : Color.red.opacity(0.25))
                .foregroundColor(habilitado ? .green : .red)
                .cornerRadius(6)
        }
    }
}
