import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        ZStack {
            // Fondo Dark Teal
            Color.theme.background
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                
                // Títulos inspirados en la imagen
                VStack(spacing: 10) {
                    Text("Aeronet")
                        .font(.system(size: 40, weight: .light, design: .default))
                        .foregroundColor(Color.theme.textPrimary)
                    
                    Text("Welcome back, please sign in")
                        .font(.system(size: 18, weight: .regular, design: .default))
                        .foregroundColor(Color.theme.textSecondary)
                }
                .padding(.top, 80)
                
                Spacer()
                
                // Formulario
                VStack(spacing: 20) {
                    TextField("Email", text: $viewModel.email)
                        .padding()
                        .background(Color.theme.surface)
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .accentColor(Color.theme.accentGold)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $viewModel.password)
                        .padding()
                        .background(Color.theme.surface)
                        .cornerRadius(12)
                        .foregroundColor(.white)
                        .accentColor(Color.theme.accentGold)
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // Botón dorado
                Button(action: {
                    viewModel.login()
                }) {
                    ZStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .theme.background))
                        } else {
                            Text("Login")
                                .font(.system(size: 20, weight: .medium))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.theme.accentGold)
                    .foregroundColor(Color.theme.background)
                    .cornerRadius(15)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
                .disabled(viewModel.isLoading)
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
