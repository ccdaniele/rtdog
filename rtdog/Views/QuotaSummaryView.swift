import SwiftUI

struct QuotaSummaryView: View {
    @ObservedObject var workDayManager: WorkDayManager
    
    private var monthlyQuota: MonthlyQuota {
        workDayManager.getMonthlyQuota(for: workDayManager.currentMonth)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Monthly Quota Summary")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 12) {
                QuotaRow(
                    title: "Required Office Days",
                    value: "\(monthlyQuota.requiredOfficeDays)",
                    color: .primary
                )
                
                QuotaRow(
                    title: "Completed Office Days",
                    value: "\(monthlyQuota.completedOfficeDays)",
                    color: .blue
                )
                
                QuotaRow(
                    title: "Remaining Office Days",
                    value: "\(monthlyQuota.remainingOfficeDays)",
                    color: monthlyQuota.remainingOfficeDays > 0 ? .orange : .green
                )
                
                QuotaRow(
                    title: "Banked Days",
                    value: "\(monthlyQuota.bankedDays)",
                    color: .green
                )
            }
            
            // Status indicator
            HStack {
                Image(systemName: monthlyQuota.isQuotaMet ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                    .foregroundColor(monthlyQuota.isQuotaMet ? .green : .orange)
                
                Text(monthlyQuota.isQuotaMet ? "Monthly quota met!" : "Working towards quota")
                    .font(.caption)
                    .foregroundColor(monthlyQuota.isQuotaMet ? .green : .orange)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct QuotaRow: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
    }
} 
