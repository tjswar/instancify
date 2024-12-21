import SwiftUI

struct ServiceDetailView: View {
    @StateObject private var viewModel: ServiceDetailViewModel
    
    init(serviceType: AWSResourceType) {
        _viewModel = StateObject(wrappedValue: ServiceDetailViewModel(serviceType: serviceType))
    }
    
    var body: some View {
        List(viewModel.resources) { resource in
            ResourceRowView(resource: resource)
        }
        .task {
            await viewModel.fetchResources()
        }
        .navigationTitle(viewModel.serviceType.rawValue)
    }
} 