import UIKit
import Security

protocol AddTopicModelProtocol {
    func canMakeRequest() -> Bool
    func incrementRequestCount()
    func remainingRequests() -> Int
    func generateWords(topic: String, language: String, completion: @escaping ([String]) -> Void)
}

private enum RequestLimitKeys {
    static let dailyRequestCount = "dailyRequestCountKeychain"
    static let lastResetDate = "lastResetDate"
}

/// URL of the backend proxy that wraps OpenAI. Replace `nil` with the full URL of your
/// deployed function (for example `https://your-app.vercel.app/api/generate-words`)
/// once the backend in `backend/api/generate-words.js` is deployed.
///
/// Until this is non-nil, custom-topic generation returns an empty list and the UI
/// shows the `backend_not_configured` message. Never embed the OpenAI key here —
/// the binary is public via the App Store.
private let backendURL: URL? = URL(string: "https://spy-game-lac-seven.vercel.app/api/generate-words")

final class AddTopicModel: AddTopicModelProtocol {
    private let maxRequests = 5

    static var isBackendConfigured: Bool { backendURL != nil }

    func canMakeRequest() -> Bool {
        let now = Date()
        let lastReset = readDateFromKeychain(key: RequestLimitKeys.lastResetDate) ?? now

        if !Calendar.current.isDate(now, inSameDayAs: lastReset) {
            saveDateToKeychain(date: now, key: RequestLimitKeys.lastResetDate)
            saveIntToKeychain(value: 0, key: RequestLimitKeys.dailyRequestCount)
        }

        let count = readIntFromKeychain(key: RequestLimitKeys.dailyRequestCount)
        return count < maxRequests
    }

    func incrementRequestCount() {
        var count = readIntFromKeychain(key: RequestLimitKeys.dailyRequestCount)
        count += 1
        saveIntToKeychain(value: count, key: RequestLimitKeys.dailyRequestCount)
    }

    func remainingRequests() -> Int {
        let count = readIntFromKeychain(key: RequestLimitKeys.dailyRequestCount)
        return max(0, maxRequests - count)
    }

    // MARK: - Backend request

    func generateWords(topic: String, language: String, completion: @escaping ([String]) -> Void) {
        guard let url = backendURL else {
            // No backend yet — caller surfaces a localized error.
            completion([])
            return
        }

        let parameters: [String: Any] = [
            "topic": topic,
            "language": language
        ]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters) else {
            completion([])
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let words = json["words"] as? [String] else {
                completion([])
                return
            }
            completion(words)
        }.resume()
    }
}

private func saveIntToKeychain(value: Int, key: String) {
    saveToKeychain(value: "\(value)", key: key)
}

private func readIntFromKeychain(key: String) -> Int {
    if let string = readFromKeychain(key: key), let intVal = Int(string) {
        return intVal
    }
    return 0
}

private func saveDateToKeychain(date: Date, key: String) {
    let formatter = ISO8601DateFormatter()
    saveToKeychain(value: formatter.string(from: date), key: key)
}

private func readDateFromKeychain(key: String) -> Date? {
    if let string = readFromKeychain(key: key) {
        return ISO8601DateFormatter().date(from: string)
    }
    return nil
}

private func saveToKeychain(value: String, key: String) {
    let data = value.data(using: .utf8)!
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: key,
        kSecValueData as String: data
    ]
    SecItemDelete(query as CFDictionary)
    SecItemAdd(query as CFDictionary, nil)
}

private func readFromKeychain(key: String) -> String? {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: key,
        kSecReturnData as String: kCFBooleanTrue!,
        kSecMatchLimit as String: kSecMatchLimitOne
    ]
    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    if status == errSecSuccess, let data = result as? Data {
        return String(data: data, encoding: .utf8)
    }
    return nil
}
