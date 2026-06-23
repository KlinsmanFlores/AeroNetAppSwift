import SwiftUI

struct ClientPlansView: View {
    @StateObject private var viewModel = ClientPlansViewModel()
    @State private var selectedPlan: Plan? = nil
    
    // Formulario de Solicitud de Servicio
    @State private var clientName = ""
    @State private var clientPhone = ""
    @State private var clientDocType = "DNI"
    @State private var clientDocNum = ""
    @State private var clientAddress = ""
    @State private var requestNotes = ""
    @State private var isSubmitting = false
    @State private var submitError: String? = nil
    @State private var submitSuccess = false
    
    var body: some View {
        ZStack {
            Color.theme.background
                .ignoresSafeArea()
            
            VStack {
                if viewModel.isLoading && viewModel.plans.isEmpty {
                    ProgressView("Cargando catálogo...")
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
                    EmptyStateView(iconName: "wifi.slash", title: "Sin Conexiones", message: "Actualmente no hay planes de red disponibles en la zona.")
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            Text("SELECCIONA TU PLAN")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(Color.theme.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                                .padding(.top, 16)
                            
                            ForEach(viewModel.plans) { plan in
                                GlassCard(cornerRadius: 20, padding: 20) {
                                    VStack(alignment: .leading, spacing: 14) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(plan.name ?? "Plan Fibra")
                                                    .font(.system(size: 18, weight: .bold))
                                                    .foregroundColor(.white)
                                                
                                                Text("\(Int(plan.speed_mbps ?? 0)) Mbps")
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(Color.theme.accent)
                                            }
                                            
                                            Spacer()
                                            
                                            Text((plan.price ?? 0).currencyPEN)
                                                .font(.system(size: 20, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                        
                                        if let desc = plan.description, !desc.isEmpty {
                                            Text(desc)
                                                .font(.system(size: 13))
                                                .foregroundColor(Color.theme.textSecondary)
                                        }
                                        
                                        Button(action: {
                                            selectedPlan = plan
                                        }) {
                                            Text("Solicitar Instalación")
                                                .font(.system(size: 14, weight: .bold))
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 10)
                                                .background(Color.theme.accent)
                                                .foregroundColor(Color.theme.background)
                                                .cornerRadius(10)
                                        }
                                        .buttonStyle(ScaleButtonStyle())
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Catálogo de Planes")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    viewModel.fetchPlans()
                    
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(Color.theme.accent)
                }
            }
        }
        .onAppear {
            viewModel.fetchPlans()
        }
        .sheet(item: $selectedPlan) { plan in
            NavigationView {
                ZStack {
                    Color.theme.background
                        .ignoresSafeArea()
                    
                    if submitSuccess {
                        VStack(spacing: 20) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(Color.theme.success)
                            
                            Text("Solicitud Enviada")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Hemos registrado tu solicitud de servicio para el plan \(plan.name ?? ""). Un asesor técnico se comunicará contigo a la brevedad.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 30)
                            
                            Button("Cerrar") {
                                selectedPlan = nil
                                submitSuccess = false
                            }
                            .primaryButton()
                            .padding(.horizontal, 30)
                        }
                    } else {
                        Form {
                            Section(header: Text("Plan Seleccionado").foregroundColor(.gray)) {
                                HStack {
                                    Text(plan.name ?? "")
                                        .bold()
                                    Spacer()
                                    Text((plan.price ?? 0).currencyPEN)
                                        .foregroundColor(Color.theme.accent)
                                }
                                .foregroundColor(.white)
                            }
                            .listRowBackground(Color.theme.surface)
                            
                            Section(header: Text("Tus Datos").foregroundColor(.gray)) {
                                TextField("Nombre Completo", text: $clientName)
                                    .foregroundColor(.white)
                                TextField("Teléfono", text: $clientPhone)
                                    .foregroundColor(.white)
                                Picker("Documento", selection: $clientDocType) {
                                    Text("DNI").tag("DNI")
                                    Text("RUC").tag("RUC")
                                }
                                .foregroundColor(.white)
                                TextField("Número de Documento", text: $clientDocNum)
                                    .foregroundColor(.white)
                            }
                            .listRowBackground(Color.theme.surface)
                            
                            Section(header: Text("Detalles de Conexión").foregroundColor(.gray)) {
                                TextField("Dirección de Instalación", text: $clientAddress)
                                    .foregroundColor(.white)
                                TextField("Notas Adicionales / Referencias", text: $requestNotes)
                                    .foregroundColor(.white)
                            }
                            .listRowBackground(Color.theme.surface)
                            
                            if let error = submitError {
                                Section {
                                    Text(error)
                                        .foregroundColor(Color.theme.danger)
                                        .font(.caption)
                                }
                                .listRowBackground(Color.theme.surface)
                            }
                        }
                        .background(Color.clear)
                        .scrollContentBackground(.hidden)
                    }
                }
                .navigationTitle("Solicitud de Conexión")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    if !submitSuccess {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancelar") {
                                selectedPlan = nil
                                clearFields()
                            }
                            .foregroundColor(.red)
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Enviar") {
                                isSubmitting = true
                                submitError = nil
                                
                                let req = CreateServiceWithTicketRequest(
                                    plan_id: plan.id,
                                    address_text: clientAddress,
                                    full_name: clientName,
                                    document_type: clientDocType,
                                    document_number: clientDocNum,
                                    phone: clientPhone,
                                    latitude: nil,
                                    longitude: nil,
                                    ticket_subject: "Nueva solicitud de instalación - \(plan.name ?? "")",
                                    ticket_description: requestNotes.isEmpty ? "Cliente solicita instalación." : requestNotes
                                )
                                
                                ServiceService.shared.requestWithTicket(req) { result in
                                    DispatchQueue.main.async {
                                        switch result {
                                        case .success(_):
                                            submitSuccess = true
                                            clearFields()
                                        case .failure(let error):
                                            submitError = "Error al procesar la solicitud: \(error.localizedDescription)"
                                        }
                                        isSubmitting = false
                                    }
                                }
                            }
                            .foregroundColor(Color.theme.accent)
                            .disabled(isSubmitting || clientName.isEmpty || clientPhone.isEmpty || clientAddress.isEmpty)
                        }
                    }
                }
            }
        }
    }
    
    private func clearFields() {
        clientName = ""
        clientPhone = ""
        clientDocType = "DNI"
        clientDocNum = ""
        clientAddress = ""
        requestNotes = ""
    }
}

struct ClientPlansView_Previews: PreviewProvider {
    static var previews: some View {
        ClientPlansView()
    }
}
