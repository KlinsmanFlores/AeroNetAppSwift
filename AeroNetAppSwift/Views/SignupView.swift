import SwiftUI

struct SignupView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel = SignupViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.theme.backgroundGradientTop, Color.theme.backgroundGradientBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    
                    VStack(spacing: 8) {
                        Text("Crear Cuenta")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(Color.theme.textPrimary)
                        
                        Text("Regístrate para obtener servicios y pagar en línea")
                            .font(.system(size: 14))
                            .foregroundColor(Color.theme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 60)
                    
                    // Contenedor Glassmorphism (Semana 9)
                    GlassCard(cornerRadius: 24, padding: 24) {
                        VStack(spacing: 20) {
                            
                            // Campo Nombre Completo
                            VStack(alignment: .leading, spacing: 6) {
                                Text("NOMBRE COMPLETO")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color.theme.textSecondary)
                                
                                HStack {
                                    Image(systemName: "person.fill")
                                        .foregroundColor(Color.theme.accent)
                                    TextField("Ej. Juan Pérez", text: $viewModel.fullName)
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(Color.theme.surface)
                                .cornerRadius(12)
                            }
                            
                            // Campo Correo
                            VStack(alignment: .leading, spacing: 6) {
                                Text("CORREO ELECTRÓNICO")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color.theme.textSecondary)
                                
                                HStack {
                                    Image(systemName: "envelope.fill")
                                        .foregroundColor(Color.theme.accent)
                                    TextField("correo@ejemplo.com", text: $viewModel.email)
                                        .foregroundColor(.white)
                                        .autocapitalization(.none)
                                        .keyboardType(.emailAddress)
                                }
                                .padding()
                                .background(Color.theme.surface)
                                .cornerRadius(12)
                            }
                            
                            // Campo Contraseña
                            VStack(alignment: .leading, spacing: 6) {
                                Text("CONTRASEÑA")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(Color.theme.textSecondary)
                                
                                HStack {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(Color.theme.accent)
                                    SecureField("Mínimo 6 caracteres", text: $viewModel.password)
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(Color.theme.surface)
                                .cornerRadius(12)
                            }
                            
                            if let error = viewModel.errorMessage {
                                Text(error)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(Color.theme.danger)
                                    .multilineTextAlignment(.center)
                            }
                            
                            Button(action: {
                                Task {
                                    await viewModel.signup(authManager: authManager)
                                }
                            }) {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: Color.theme.background))
                                } else {
                                    Text("Registrarme")
                                }
                            }
                            .primaryButton(isDisabled: viewModel.isLoading)
                            .disabled(viewModel.isLoading)
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Text("¿Ya tienes una cuenta?")
                                .foregroundColor(Color.theme.textSecondary)
                            Text("Inicia Sesión")
                                .foregroundColor(Color.theme.accent)
                                .fontWeight(.semibold)
                        }
                        .font(.system(size: 14))
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }
}
