import Foundation
import Supabase

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var expenses: [Expense] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published private(set) var isDemo = false

    var totalOwed: Double {
        expenses.filter { !$0.settled }.reduce(0) { $0 + $1.amount }
    }

    var settledCount: Int {
        expenses.filter { $0.settled }.count
    }

    private func userId() async -> UUID? {
        try? await AppSupabase.client.auth.session.user.id
    }

    func fetchExpenses() async {
        isLoading = true
        errorMessage = nil

        guard let uid = await userId() else {
            // No auth session — demo mode with sample data
            isDemo = true
            if expenses.isEmpty {
                expenses = Self.sampleExpenses
            }
            isLoading = false
            return
        }

        isDemo = false
        do {
            let result: [Expense] = try await AppSupabase.client
                .from("expenses")
                .select()
                .eq("user_id", value: uid.uuidString)
                .order("created_at", ascending: false)
                .execute()
                .value
            expenses = result
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func addExpense(_ expense: InsertExpense) async {
        if isDemo {
            let local = Expense(
                id: UUID(),
                createdAt: Date(),
                userId: expense.userId,
                title: expense.title,
                amount: expense.amount,
                category: expense.category,
                paidBy: expense.paidBy,
                splitWith: expense.splitWith,
                settled: false
            )
            expenses.insert(local, at: 0)
            return
        }

        errorMessage = nil
        do {
            try await AppSupabase.client
                .from("expenses")
                .insert(expense)
                .execute()
            await fetchExpenses()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleSettled(_ expense: Expense) async {
        if isDemo {
            if let i = expenses.firstIndex(where: { $0.id == expense.id }) {
                let e = expenses[i]
                expenses[i] = Expense(
                    id: e.id, createdAt: e.createdAt, userId: e.userId,
                    title: e.title, amount: e.amount, category: e.category,
                    paidBy: e.paidBy, splitWith: e.splitWith, settled: !e.settled
                )
            }
            return
        }

        do {
            try await AppSupabase.client
                .from("expenses")
                .update(["settled": !expense.settled])
                .eq("id", value: expense.id.uuidString)
                .execute()
            await fetchExpenses()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteExpense(_ expense: Expense) async {
        if isDemo {
            expenses.removeAll { $0.id == expense.id }
            return
        }

        do {
            try await AppSupabase.client
                .from("expenses")
                .delete()
                .eq("id", value: expense.id.uuidString)
                .execute()
            await fetchExpenses()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Sample data for demo mode

    private static let demoId = UUID()

    private static let sampleExpenses: [Expense] = [
        Expense(id: UUID(), createdAt: Date(), userId: demoId,
                title: "Dinner at Sweetgreen", amount: 34.50, category: "Food",
                paidBy: "Me", splitWith: "Alex", settled: false),
        Expense(id: UUID(), createdAt: Date().addingTimeInterval(-86400), userId: demoId,
                title: "Uber to Airport", amount: 28.00, category: "Transport",
                paidBy: "Jordan", splitWith: "Me", settled: false),
        Expense(id: UUID(), createdAt: Date().addingTimeInterval(-172800), userId: demoId,
                title: "Netflix Subscription", amount: 15.99, category: "Entertainment",
                paidBy: "Me", splitWith: "Sam", settled: true),
        Expense(id: UUID(), createdAt: Date().addingTimeInterval(-259200), userId: demoId,
                title: "Groceries", amount: 62.30, category: "Shopping",
                paidBy: "Me", splitWith: "Alex, Jordan", settled: false),
        Expense(id: UUID(), createdAt: Date().addingTimeInterval(-345600), userId: demoId,
                title: "Electric Bill", amount: 89.00, category: "Bills",
                paidBy: "Sam", splitWith: "Me", settled: true),
    ]
}
