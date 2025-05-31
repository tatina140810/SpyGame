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
private let APIKEY = "🔐_REDACTED"


final class AddTopicModel: AddTopicModelProtocol {
    private let maxRequests = 5

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

        // MARK: - API Request

        func generateWords(topic: String, language: String, completion: @escaping ([String]) -> Void) {
            let apiKey = APIKEY
            let prompt = """
            Создай массив из 40 слов на тему «\(topic)» на языке \(language). Верни только JSON-массив строк. Никакого дополнительного текста.
            """

            let parameters: [String: Any] = [
                "model": "gpt-3.5-turbo",
                "messages": [["role": "user", "content": prompt]],
                "temperature": 0.7
            ]

            guard let url = URL(string: "https://api.openai.com/v1/chat/completions"),
                  let httpBody = try? JSONSerialization.data(withJSONObject: parameters) else {
                completion([])
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = httpBody

            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data else {
                    completion([])
                    return
                }

                do {
                    let result = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                    let rawText = result.choices.first?.message.content ?? ""

                    guard let jsonData = rawText.data(using: .utf8),
                          let words = try? JSONDecoder().decode([String].self, from: jsonData) else {
                        completion([])
                        return
                    }

                    completion(words)
                } catch {
                    completion([])
                }
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
