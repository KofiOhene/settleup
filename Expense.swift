import Foundation

struct Expense: Codable, Identifiable {
    let id: UUID
    let createdAt: Date
    let userId: UUID
    let title: String
    let amount: Double
    let category: String
    let paidBy: String
    let splitWith: String?
    let settled: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case userId = "user_id"
        case title
        case amount
        case category
        case paidBy = "paid_by"
        case splitWith = "split_with"
        case settled
    }
}

struct InsertExpense: Codable {
    let userId: UUID
    let title: String
    let amount: Double
    let category: String
    let paidBy: String
    let splitWith: String?
    let settled: Bool

    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case title
        case amount
        case category
        case paidBy = "paid_by"
        case splitWith = "split_with"
        case settled
    }
}
