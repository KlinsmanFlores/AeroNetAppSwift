import SwiftUI

struct PlansListView: View {
    @StateObject private var viewModel = PlansViewModel()
    @State private var showCreateSheet = false
    @State private var newName = ""
    @State private var newPrice = ""
    @State private var newSpeed = ""
    @State private var newDescription = ""
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.theme.backgroundGradientTop, Color.theme.backgroundGradientBottom]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack {
                if viewModel.isLoading && viewModel.plans.isEmpty {
                    ProgressView("Cargando planes...")
                        .foregroundColor(.white)
                } else if let error = viewModel.errorMessage {
                    VStack {
                        Text(error)
                            .foregroundColor(.white)
                            .padding()
                        
                        Button("Reintentar") {
                            viewModel.fetchPlans()
                            
                        }
                        .primaryButton()
                        .padding()
                    }
                } else if viewModel.plans.isEmpty {
                    EmptyStateView(iconName: "wifi.slash", title: "Sin Planes", message: "No hay planes configurados. Registra uno nuevo.")
                } else {
                    List {
                        ForEach(viewModel.plans) { plan in
                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(plan.name ?? "Plan Sin Nombre")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    Text("\(Int(plan.speed_mbps ?? 0)) Mbps")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(Color.theme.accent)
                                    
                                    if let desc = plan.description, !desc.isEmpty {
                                        Text(desc)
                                            .font(.system(size: 12))
                                            .foregroundColor(Color.theme.textMuted)
                                    }
                                }
                                
                                Spacer()
                                
                                Text((plan.price ?? 0).currencyPEN)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .padding(.vertical, 6)
                            .listRowBackground(Color.theme.cardBackground.opacity(0.6))
                        }
                        .onDelete(perform: deletePlan)
                    }
                    .listStyle(PlainListStyle())
                    .background(Color.clear)
                    .animation(.spring())
                }
            }
        }
        .navigationTitle("Catálogo de Planes")
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
            viewModel.fetchPlans()
        }
        .sheet(isPresented: $showCreateSheet) {
            NavigationView {
                ZStack {
                    Color.theme.background
                        .ignoresSafeArea()
                    
                    Form {
                        Section(header: Text("Detalles del Plan").foregroundColor(Color.theme.textMuted)) {
                            TextField("Nombre del Plan", text: $newName)
                                .foregroundColor(.white)
                            TextField("Precio (S/.)", text: $newPrice)
                                .keyboardType(.decimalPad)
                                .foregroundColor(.white)
                            TextField("Velocidad (Mbps)", text: $newSpeed)
                                .keyboardType(.decimalPad)
                                .foregroundColor(.white)
                            TextField("Descripción", text: $newDescription)
                                .foregroundColor(.white)
                        }
                        .listRowBackground(Color.theme.surface)
                    }
                    .background(Color.clear)
                }
                .navigationTitle("Nuevo Plan")
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
                        Button("Crear") {
                                guard let price = Double(newPrice), let speed = Double(newSpeed) else { return }
                                viewModel.createPlan(
                                    name: newName,
                                    price: price,
                                    speedMbps: speed,
                                    description: newDescription
                                ) { success in
                                    if success {
                                        showCreateSheet = false
                                        clearFields()
                                        // Recargar con caché
                                        viewModel.fetchPlans()
                                    }
                                }
                        }
                        .foregroundColor(Color.theme.accent)
                    }
                }
            }
        }
    }
    
    private func deletePlan(at offsets: IndexSet) {
        for index in offsets {
            let plan = viewModel.plans[index]
            viewModel.deletePlan(id: plan.id ?? "") { _ in
                // Recargar con caché
                viewModel.fetchPlans()
            }
        }
    }
    
    private func clearFields() {
        newName = ""
        newPrice = ""
        newSpeed = ""
        newDescription = ""
    }
}

struct PlansListView_Previews: PreviewProvider {
    static var previews: some View {
        PlansListView()
    }
}
