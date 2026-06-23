import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Fondo Degradado
                LinearGradient(
                    colors: [Color.theme.backgroundGradientTop, Color.theme.backgroundGradientBottom],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 35) {
                        
                        // Encabezado
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.theme.accent.opacity(0.1))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "wifi.router.fill")
                                    .font(.system(size: 38))
                                    .foregroundColor(Color.theme.accent)
                            }
                            .padding(.top, 50)
                            
                            Text("AeroNet")
                                .font(.system(size: 38, weight: .bold, design: .rounded))
                                .foregroundColor(Color.theme.textPrimary)
                                .tracking(3)
                            
                            Text("Conectividad veloz y confiable")
                                .font(.system(size: 15))
                                .foregroundColor(Color.theme.textSecondary)
                        }
                        
                        // Tarjeta de Formulario Glassmorphism (Semana 9)
                        GlassCard(cornerRadius: 24, padding: 24) {
                            VStack(spacing: 20) {
                                Text("INICIAR SESIÓN")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(Color.theme.textPrimary)
                                    .tracking(1.5)
                                    .padding(.bottom, 5)
                                
                                // Correo
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("CORREO ELECTRÓNICO")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(Color.theme.textSecondary)
                                    
                                    HStack {
                                        Image(systemName: "envelope.fill")
                                            .foregroundColor(Color.theme.accent)
                                        TextField("usuario@ejemplo.com", text: $viewModel.email)
                                            .foregroundColor(.white)
                                            .autocapitalization(.none)
                                            .keyboardType(.emailAddress)
                                    }
                                    .padding()
                                    .background(Color.theme.surface)
                                    .cornerRadius(12)
                                }
                                
                                // Contraseña
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("CONTRASEÑA")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(Color.theme.textSecondary)
                                    
                                    HStack {
                                        Image(systemName: "lock.fill")
                                            .foregroundColor(Color.theme.accent)
                                        SecureField("Contraseña", text: $viewModel.password)
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
                                    viewModel.login(authManager: authManager)
                                    
                                }) {
                                    if viewModel.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: Color.theme.background))
                                    } else {
                                        Text("Ingresar")
                                    }
                                }
                                .primaryButton(isDisabled: viewModel.isLoading)
                                .disabled(viewModel.isLoading)
                                .buttonStyle(ScaleButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Link a Registro
                        NavigationLink(destination: SignupView()) {
                            HStack {
                                Text("¿No tienes cuenta?")
                                    .foregroundColor(Color.theme.textSecondary)
                                Text("Regístrate aquí")
                                    .foregroundColor(Color.theme.accent)
                                    .fontWeight(.bold)
                            }
                            .font(.system(size: 14))
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.bottom, 30)
                    }
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthManager())
    }
}
