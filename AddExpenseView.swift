import SwiftUI

struct AddExpenseView: View {
    @ObservedObject var vm: DashboardViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var amount = ""
    @State private var category = "Food"
    @State private var paidBy = "Me"
    @State private var splitWith = ""
    @State private var isSaving = false

    private let categories = ["Food", "Transport", "Entertainment", "Shopping", "Bills", "Rent", "Other"]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Amount
                        VStack(spacing: 8) {
                            Text("Amount")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                            TextField("$0.00", text: $amount)
                                .font(.system(size: 40, weight: .bold))
                                .multilineTextAlignment(.center)
                                .keyboardType(.decimalPad)
                        }
                        .padding(.top, 20)

                        // Fields
                        VStack(spacing: 14) {
                            FormField(icon: "pencil", placeholder: "What was it for?", text: $title)

                            FormField(icon: "person", placeholder: "Paid by", text: $paidBy)

                            FormField(icon: "person.2", placeholder: "Split with (optional)", text: $splitWith)

                            // Category Picker
                            HStack(spacing: 12) {
                                Image(systemName: "tag")
                                    .foregroundColor(.gray)
                                Picker("Category", selection: $category) {
                                    ForEach(categories, id: \.self) { cat in
                                        Text(cat).tag(cat)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(.black)
                                Spacer()
                            }
                            .padding()
                            .frame(height: 54)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .stroke(Color.gray.opacity(0.18), lineWidth: 1)
                                    .background(Color.white.cornerRadius(14))
                            )
                        }
                        .padding(.horizontal, 20)

                        // Save Button
                        Button {
                            Task { await save() }
                        } label: {
                            Text(isSaving ? "Saving..." : "Add Expense")
                                .font(.system(size: 17, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(canSave ? Color.black : Color.gray)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .disabled(!canSave || isSaving)
                        .padding(.horizontal, 20)

                        if let error = vm.errorMessage {
                            Text(error)
                                .font(.system(size: 13))
                                .foregroundColor(.red)
                                .padding(.horizontal, 20)
                        }
                    }
                }
            }
            .navigationTitle("New Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var canSave: Bool {
        !title.isEmpty && (Double(amount) ?? 0) > 0
    }

    private func save() async {
        guard let amountValue = Double(amount) else { return }
        isSaving = true
        let uid = (try? await AppSupabase.client.auth.session.user.id) ?? UUID()
        let expense = InsertExpense(
            userId: uid,
            title: title,
            amount: amountValue,
            category: category,
            paidBy: paidBy,
            splitWith: splitWith.isEmpty ? nil : splitWith,
            settled: false
        )
        await vm.addExpense(expense)
        isSaving = false
        dismiss()
    }
}

// MARK: - Form Field

private struct FormField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.gray)
            TextField(placeholder, text: $text)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
        }
        .padding()
        .frame(height: 54)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.gray.opacity(0.18), lineWidth: 1)
                .background(Color.white.cornerRadius(14))
        )
    }
}
