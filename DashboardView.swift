import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = DashboardViewModel()
    @State private var showAddExpense = false

    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("settle")
                            .font(.system(size: 26, weight: .bold))
                        Text("Dashboard")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Button {
                        Task { await authVM.signOut() }
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 18))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)

                // Summary Cards
                HStack(spacing: 12) {
                    SummaryCard(
                        title: "Unsettled",
                        value: String(format: "$%.2f", vm.totalOwed),
                        icon: "dollarsign.circle.fill",
                        color: .red
                    )
                    SummaryCard(
                        title: "Settled",
                        value: "\(vm.settledCount)",
                        icon: "checkmark.circle.fill",
                        color: .green
                    )
                    SummaryCard(
                        title: "Total",
                        value: "\(vm.expenses.count)",
                        icon: "list.bullet.circle.fill",
                        color: .blue
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)

                // Activity List
                if vm.isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if vm.expenses.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.system(size: 48))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("No expenses yet")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.gray)
                        Text("Tap + to add your first expense")
                            .font(.system(size: 14))
                            .foregroundColor(.gray.opacity(0.7))
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(vm.expenses) { expense in
                                ExpenseRow(expense: expense) {
                                    Task { await vm.toggleSettled(expense) }
                                } onDelete: {
                                    Task { await vm.deleteExpense(expense) }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 80)
                    }
                }

                if let error = vm.errorMessage {
                    Text(error)
                        .font(.system(size: 13))
                        .foregroundColor(.red)
                        .padding(.horizontal, 20)
                }
            }

            // FAB
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        showAddExpense = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 56, height: 56)
                            .background(Color.black)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showAddExpense) {
            AddExpenseView(vm: vm)
        }
        .task {
            await vm.fetchExpenses()
        }
    }
}

// MARK: - Summary Card

private struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
        )
    }
}

// MARK: - Expense Row

private struct ExpenseRow: View {
    let expense: Expense
    let onToggle: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            CategoryIcon(category: expense.category)

            VStack(alignment: .leading, spacing: 3) {
                Text(expense.title)
                    .font(.system(size: 16, weight: .medium))
                    .strikethrough(expense.settled, color: .gray)
                HStack(spacing: 6) {
                    Text(expense.paidBy)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                    if let split = expense.splitWith, !split.isEmpty {
                        Text("with \(split)")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(String(format: "$%.2f", expense.amount))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(expense.settled ? .green : .primary)
                Text(expense.settled ? "Settled" : "Pending")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(expense.settled ? .green : .orange)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
        )
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) { onDelete() } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .contextMenu {
            Button { onToggle() } label: {
                Label(
                    expense.settled ? "Mark Unsettled" : "Mark Settled",
                    systemImage: expense.settled ? "xmark.circle" : "checkmark.circle"
                )
            }
            Button(role: .destructive) { onDelete() } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

// MARK: - Category Icon

private struct CategoryIcon: View {
    let category: String

    private var iconName: String {
        switch category.lowercased() {
        case "food": return "fork.knife"
        case "transport": return "car.fill"
        case "entertainment": return "film"
        case "shopping": return "bag.fill"
        case "bills": return "doc.text.fill"
        case "rent": return "house.fill"
        default: return "dollarsign.circle"
        }
    }

    private var iconColor: Color {
        switch category.lowercased() {
        case "food": return .orange
        case "transport": return .blue
        case "entertainment": return .purple
        case "shopping": return .pink
        case "bills": return .gray
        case "rent": return .brown
        default: return .black
        }
    }

    var body: some View {
        Image(systemName: iconName)
            .font(.system(size: 18))
            .foregroundColor(iconColor)
            .frame(width: 40, height: 40)
            .background(iconColor.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

#if DEBUG
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DashboardView()
                .environmentObject(AuthViewModel())
        }
    }
}
#endif
