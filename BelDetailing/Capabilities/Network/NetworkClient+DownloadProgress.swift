import Foundation

final class ProgressURLSessionDelegate: NSObject, URLSessionDataDelegate {
    weak var progressManager: DownloadProgressManager?

    private var expectedContentLength: Int64 = NSURLSessionTransferSizeUnknown
    private var received: Int64 = 0

    init(progressManager: DownloadProgressManager?) {
        self.progressManager = progressManager
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse,
                    completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        expectedContentLength = response.expectedContentLength
        received = 0
        Task { @MainActor in
            progressManager?.begin(indeterminate: expectedContentLength == NSURLSessionTransferSizeUnknown)
        }
        completionHandler(.allow)
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        received += Int64(data.count)
        Task { @MainActor in
            progressManager?.updateProgress(received: received, expected: expectedContentLength)
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        Task { @MainActor in
            progressManager?.end()
        }
    }
}

extension NetworkClient {
    func downloadWithProgress(
        endPoint: APIEndPoint,
        urlDict: [String: Any?]? = nil,
        timeout: TimeInterval = 120
    ) async -> APIResponse<Data> {
        await MainActor.run { loadingManager?.begin() }
        defer { Task { @MainActor in loadingManager?.end() } }

        guard var url = url(endPoint: endPoint) else {
            return .failure(.urlError)
        }
        if let urlDict {
            url = NetworkClient.urlFor(url: url, urlDict: urlDict)
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpointMapperClass.method(for: endPoint).rawValue
        request.allHTTPHeaderFields = NetworkClient.defaultHeaders
        request.timeoutInterval = timeout

        let delegate = ProgressURLSessionDelegate(progressManager: downloadProgressManager)
        let session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)

        do {
            let (data, response) = try await session.data(for: request)
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
