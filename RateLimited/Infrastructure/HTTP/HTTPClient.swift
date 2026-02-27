import Foundation

protocol HTTPClient: Sendable {
    func data(for request: URLRequest) async throws -> Data
}

struct URLSessionHTTPClient: HTTPClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func data(for request: URLRequest) async throws -> Data {
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw UsageServiceError("Unexpected non-HTTP response")
        }

        guard (200 ..< 300).contains(httpResponse.statusCode) else {
            throw HTTPClientStatusError(statusCode: httpResponse.statusCode, responseBodyData: data)
        }

        return data
    }
}

struct HTTPClientStatusError: LocalizedError, Sendable {
    let statusCode: Int
    let responseBodyData: Data

    var errorDescription: String? {
        "HTTP \(statusCode)"
    }
}
