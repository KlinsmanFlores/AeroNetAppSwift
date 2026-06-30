import SwiftUI

struct CustomersListView: View {
    @StateObject private var viewModel = CustomersViewModel()
    @State private var selectedCustomer: Customer? = nil
    @State private var editName = ""
    @State private var editPhone = ""
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.theme.backgroundGradientTop, Color.theme.backgroundGradientBottom]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                if viewModel.isLoading && viewModel.customers.isEmpty {
                    ProgressView("Cargando clientes...")
                        .foregroundColor(.black)
                } else if let error = viewModel.errorMessage {
                    EmptyStateView(iconName: "exclamationmark.triangle", title: "Error", message: error)
                } else if viewModel.customers.isEmpty {
                    EmptyStateView(iconName: "person.3", title: "Sin Clientes", message: "No se encontraron clientes registrados en el sistema.")
                } else {
                    customersList
                }
            }
        }
        .navigationTitle("Clientes")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.fetchCustomers()
                    
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(Color.theme.accent)
                }
            }
        }
        .onAppear {
            viewModel.fetchCustomers()
        }
        .sheet(item: $selectedCustomer) { customer in
            NavigationView {
                ZStack {
                    Color.theme.background
                        .ignoresSafeArea()
                    
                    Form {
                        Section(header: Text("Información Básica").foregroundColor(Color.theme.textMuted)) {
                            TextField("Nombre Completo", text: $editName)
                                .foregroundColor(.black)
                            TextField("Teléfono", text: $editPhone)
                                .foregroundColor(.black)
                        }
                        .listRowBackground(Color.theme.surface)
                    }
                    .background(Color.clear)
                }
                .navigationTitle("Editar Cliente")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancelar") {
                            selectedCustomer = nil
                        }
                        .foregroundColor(.red)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Guardar") {
                                viewModel.updateCustomer(
                                    id: customer.id ?? "",
                                    fullName: editName,
                                    phone: editPhone,
                                    address: ""
                                ) { success in
                                    if success {
                                        selectedCustomer = nil
                                    }
                                }
                        }
                        .foregroundColor(Color.theme.accent)
                    }
                }
            }
        }
    }
    
    private var customersList: some View {
        List {
            ForEach(viewModel.customers) { customer in
                customerRow(customer)
                    .padding(.vertical, 8)
                    .listRowBackground(Color.theme.cardBackground.opacity(0.6))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedCustomer = customer
                        editName = customer.full_name ?? ""
                        editPhone = customer.phone ?? ""
                    }
            }
        }
        .listStyle(PlainListStyle())
        .background(Color.clear)
    }
    
    private func customerRow(_ customer: Customer) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(customer.full_name ?? "Sin nombre")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.black)
            
            Text(customer.email ?? "Sin email")
                .font(.system(size: 14))
                .foregroundColor(Color.theme.textMuted)
            
            HStack {
                if let phone = customer.phone, !phone.isEmpty {
                    Label(phone, systemImage: "phone.fill")
                        .font(.caption)
                        .foregroundColor(Color.theme.accent)
                }
                Spacer()
                BadgeView(text: customer.statusLabel, status: customer.status ?? "pending")
            }
        }
    }
}

struct CustomersListView_Previews: PreviewProvider {
    static var previews: some View {
        CustomersListView()
    }
}
