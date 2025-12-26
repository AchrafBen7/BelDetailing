import Foundation

extension NetworkClient {
    func downloadAbsolute(urlString: String,
                          timeout: TimeInterval = 60) async -> APIResponse<Data> {
        await MainActor.run { loadingManager?.begin() }
        defer { Task { @MainActor in loadingManager?.end() } }

        guard let url = URL(string: urlString) else {
            return .failure(.urlError)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = timeout

        // Headers (si besoin d’Authorization même sur signed URL, sinon commentez)
        for (key, vie) in NetworkClient.defaultHeaders {
            request.setValue(vie, forHTTPHeaderField: key)
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                return .failure(.unknownError)
            }
            NetworkClient.logRequest(request: request, urlResponse: http, data: data)

            if (200...299).contains(http.statusCode) {
                return .success(data)
            } else {
                return .failure(.serverError(statusCode: http.statusCode))
            }
        } catch {
            return .failure(.from(error: error))
        }
    }
}
