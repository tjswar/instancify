import SwiftUI

struct CostOverviewSection: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cost Overview")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 16) {
                // Current Costs
                HStack {
                    VStack(alignment: .leading) {
                        Text("Today's Cost")
                            .foregroundColor(.secondary)
                        Text("$\(viewModel.todayCost, specifier: "%.2f")")
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("This Month")
                            .foregroundColor(.secondary)
                        Text("$\(viewModel.monthCost, specifier: "%.2f")")
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)
                    }
                }
                
                Divider()
                
                // Projected Cost
                HStack {
                    Text("Projected Cost")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("$\(viewModel.projectedCost, specifier: "%.2f")")
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.semibold)
                }
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
} 