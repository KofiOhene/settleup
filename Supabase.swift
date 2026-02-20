import Foundation
import Supabase

enum AppSupabase {
    static let url = URL(string: "https://qegmvdnshewmmdodlpkx.supabase.co")!
    static let anonKey = "sb_publishable_Kw2xsAZmgRSpkhLx5X3tQg_pOh3vHYg"

    static let client = SupabaseClient(supabaseURL: url, supabaseKey: anonKey)
}
