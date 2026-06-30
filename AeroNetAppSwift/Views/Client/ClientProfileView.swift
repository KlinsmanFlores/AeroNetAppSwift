import SwiftUI

struct ClientProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel = ClientProfileViewModel()
    @State private var editName = ""
    @State private var editPhone = ""
    @State private var editDocType = "DNI"
    @State private var editDocNumber = ""
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.theme.backgroundGradientTop, Color.theme.backgroundGradientBottom]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.theme.accent.opacity(0.15))
                                .frame(width: 90, height: 90)
                            
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(Color.theme.accent)
                        }
                        .padding(.top, 20)
                        
                        Text(viewModel.customer?.full_name ?? authManager.currentUser?.email ?? "Usuario")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(authManager.currentUser?.email ?? "Sin correo")
                            .font(.system(size: 14))
                            .foregroundColor(Color.theme.textMuted)
                    }
                    
                    if viewModel.isLoading {
                        ProgressView("Cargando perfil...")
                            .foregroundColor(.white)
                    } else {
                        // Formulario de edición
                        GlassCard(cornerRadius: 20, padding: 20) {
                            VStack(spacing: 18) {
                                Text("DATOS PERSONALES")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(Color.theme.textSecondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                // Nombre
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Nombre Completo")
                                        .font(.caption)
                                        .foregroundColor(Color.theme.textMuted)
                                    TextField("Tu nombre", text: $editName)
                                        .foregroundColor(.white)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(Color.theme.surface)
                                        .cornerRadius(8)
                                }
                                
                                // Teléfono
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Teléfono")
                                        .font(.caption)
                                        .foregroundColor(Color.theme.textMuted)
                                    TextField("Tu teléfono", text: $editPhone)
                                        .foregroundColor(.white)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(Color.theme.surface)
                                        .cornerRadius(8)
                                }
                                
                                // Tipo Documento
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Tipo de Documento")
                                        .font(.caption)
                                        .foregroundColor(Color.theme.textMuted)
                                    Picker("Tipo Doc", selection: $editDocType) {
                                        Text("DNI").tag("DNI")
                                        Text("RUC").tag("RUC")
                                        Text("Pasaporte").tag("Pasaporte")
                                        Text("CE").tag("CE")
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                    .padding(.vertical, 4)
                                }
                                
                                // Número Documento
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Número de Documento")
                                        .font(.caption)
                                        .foregroundColor(Color.theme.textMuted)
                                    TextField("Nº de documento", text: $editDocNumber)
                                        .foregroundColor(.white)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 12)
                                        .background(Color.theme.surface)
                                        .cornerRadius(8)
                                }
                                
                                if let error = viewModel.errorMessage {
                                    Text(error)
                                        .font(.caption)
                                        .foregroundColor(Color.theme.danger)
                                }
                                
                                if let success = viewModel.successMessage {
                                    Text(success)
                                        .font(.caption)
                                        .foregroundColor(Color.theme.success)
                                }
                                
                                Button(action: {
                                viewModel.updateProfile(
                                    fullName: editName,
                                    phone: editPhone,
                                    documentType: editDocType,
                                    documentNumber: editDocNumber
                                ) { _ in }
                                }) {
                                    if viewModel.isSaving {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: Color.theme.background))
                                    } else {
                                        Text("Guardar Cambios")
                                    }
                                }
                                .primaryButton(isDisabled: viewModel.isSaving)
                                .disabled(viewModel.isSaving)
                                .buttonStyle(ScaleButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Botón cerrar sesión
                    Button(action: {
                        authManager.logout()
                    }) {
                        Text("Cerrar Sesión")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.theme.danger.opacity(0.1))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationTitle("Mi Perfil")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.fetchProfile()
            if let customer = viewModel.customer {
                editName = customer.full_name ?? ""
                editPhone = customer.phone ?? ""
                editDocType = customer.document_type ?? "DNI"
                editDocNumber = customer.document_number ?? ""
            }
        }
    }
}

struct ClientProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ClientProfileView()
            .environmentObject(AuthManager())
    }
}
