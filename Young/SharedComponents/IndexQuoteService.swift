import UIKit
struct IndexQuote: Codable {
    let c: Double?   // current price
    let d: Double?   // change
    let dp: Double?  // percent change
    let h: Double?   // high
    let l: Double?   // low
    let o: Double?   // open
    let pc: Double?  // previous close
    let t: Int?      // timestamp
}

class StockQuoteService {
    
    static let shared = StockQuoteService()
    private init() {}

    private let baseURL = "https://finnhub.io/api/v1/quote"
    private let apiKey = "d1slsjhr01qhe5ran430d1slsjhr01qhe5ran43g"
    
    func fetchQuotes(for symbols: [String], completion: @escaping ([String: IndexQuote]) -> Void) {
        var result: [String: IndexQuote] = [:]
        let group = DispatchGroup()

        for symbol in symbols {
            group.enter()
            
            var components = URLComponents(string: baseURL)!
            components.queryItems = [
                URLQueryItem(name: "symbol", value: symbol),
                URLQueryItem(name: "token", value: apiKey)
            ]
            
            guard let url = components.url else {
                group.leave()
                continue
            }

            let task = URLSession.shared.dataTask(with: url) { data, _, error in
                defer { group.leave() }

                guard let data = data, error == nil else {
                    LogHandler.debugLog("❌ Error for \(symbol): \(error?.localizedDescription ?? "Unknown")")
                    return
                }

                if let quote = try? JSONDecoder().decode(IndexQuote.self, from: data) {
                    result[symbol] = quote
                } else {
                    LogHandler.debugLog("❌ Failed to decode for \(symbol)")
                }
            }
            
            task.resume()
        }

        group.notify(queue: .main) {
            completion(result)
        }
    }
}
