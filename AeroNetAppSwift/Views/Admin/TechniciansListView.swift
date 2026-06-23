import SwiftUI

struct TechniciansListView: View {
    @StateObject private var viewModel = TechniciansViewModel()
    @State private var showCreateSheet = false
    @State private var newEmail = ""
    @State private var newPassword = ""
    @State private var newFullName = ""
    @State private var newPhone = ""
    @State private var newDocNumber = ""
    @State private var newSpecialty = ""
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.theme.backgroundGradientTop, Color.theme.backgroundGradientBottom]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                if viewModel.isLoading && viewModel.technicians.isEmpty {
                    ProgressView("Cargando técnicos...")
                        .foregroundColor(.white)
                } else if let error = viewModel.errorMessage {
                    EmptyStateView(iconName: "exclamationmark.triangle", title: "Error", message: error)
                } else if viewModel.technicians.isEmpty {
                    EmptyStateView(iconName: "wrench.and.screwdriver", title: "Sin Técnicos", message: "No hay técnicos registrados. Agrega uno nuevo.")
                } else {
                    techList
                }
            }
        }
        .navigationTitle("Personal Técnico")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton().foregroundColor(Color.theme.accent)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showCreateSheet = true }) {
                    Image(systemName: "plus")
                        .foregroundColor(Color.theme.accent)
                }
            }
        }
        .onAppear {
            viewModel.fetchTechnicians()
        }
        .sheet(isPresented: $showCreateSheet) {
            NavigationView {
                ZStack {
                    Color.theme.background
                        .ignoresSafeArea()
                    
                    Form {
                        Section(header: Text("Acceso").foregroundColor(.gray)) {
                            TextField("Correo electrónico", text: $newEmail)
                                .foregroundColor(.white)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                            SecureField("Contraseña", text: $newPassword)
                                .foregroundColor(.white)
                        }
                        .listRowBackground(Color.theme.surface)
                        
                        Section(header: Text("Perfil del Técnico").foregroundColor(.gray)) {
                            TextField("Nombre Completo", text: $newFullName)
                                .foregroundColor(.white)
                            TextField("Teléfono", text: $newPhone)
                                .foregroundColor(.white)
                            TextField("Documento Identidad", text: $newDocNumber)
                                .foregroundColor(.white)
                            TextField("Especialidad", text: $newSpecialty)
                                .foregroundColor(.white)
                        }
                        .listRowBackground(Color.theme.surface)
                    }
                    .background(Color.clear)
                }
                .navigationTitle("Registrar Técnico")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancelar") {
                            showCreateSheet = false
                            clearFields()
                        }
                        .foregroundColor(.red)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Guardar") {
                                viewModel.createTechnician(
                                    email: newEmail,
                                    password: newPassword,
                                    fullName: newFullName,
                                    phone: newPhone.isEmpty ? nil : newPhone,
                                    docNumber: newDocNumber.isEmpty ? nil : newDocNumber,
                                    specialty: newSpecialty.isEmpty ? nil : newSpecialty
                                ) { success in
                                    if success {
                                        showCreateSheet = false
                                        clearFields()
                                    }
                                }
                        }
                        .foregroundColor(Color.theme.accent)
                    }
                }
            }
        }
    }
    
    private var techList: some View {
        List {
            ForEach(viewModel.technicians) { tech in
                VStack(alignment: .leading, spacing: 6) {
                    Text(tech.displayName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Especialidad: \(tech.specialty ?? "Fibra Óptica")")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color.theme.accent)
                    
                    HStack {
                        if let phone = tech.phone, !phone.isEmpty {
                            Label(phone, systemImage: "phone.fill")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        BadgeView(text: tech.status ?? "activo", status: tech.status ?? "active")
                    }
                }
                .padding(.vertical, 6)
                .listRowBackground(Color.theme.cardBackground.opacity(0.6))
            }
            .onDelete(perform: deleteTechnician)
        }
        .listStyle(PlainListStyle())
        .background(Color.clear)
    }
    
    private func deleteTechnician(at offsets: IndexSet) {
        for index in offsets {
            let tech = viewModel.technicians[index]
            viewModel.deleteTechnician(id: tech.id) { _ in }
        }
    }
    
    private func clearFields() {
        newEmail = ""
        newPassword = ""
        newFullName = ""
        newPhone = ""
        newDocNumber = ""
        newSpecialty = ""
    }
}

struct TechniciansListView_Previews: PreviewProvider {
    static var previews: some View {
        TechniciansListView()
    }
}
