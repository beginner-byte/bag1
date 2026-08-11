import Foundation

/// Worker 换票成功后返回的内存凭据；调用方不得持久化或记录 token。
struct CoHereWorkExchangeResult {
    /// Worker Bearer token，仅注入当前 FlutterEngine 内存。
    let token: String

    /// ios-client 用户映射得到的 Worker 公共用户 ID。
    let workerUserID: String
}

/// ios-client 用户声明换取 Worker 会话时可能产生的安全边界错误。
private enum CoHereWorkExchangeError: LocalizedError {
    case invalidConfiguration
    case invalidUser
    case invalidResponse
    case rejected

    /// 返回不包含用户标识、服务响应正文或 token 的通用错误文案。
    var errorDescription: String? {
        switch self {
        case .invalidConfiguration:
            return "Worker service configuration is invalid."
        case .invalidUser:
            return "Current ios-client user is unavailable."
        case .invalidResponse:
            return "Worker service returned an invalid response."
        case .rejected:
            return "Worker session exchange was rejected."
        }
    }
}

/// 调用 Worker 公共换票端点，不读取 ios-client token，也不持久化 Worker 会话。
final class CoHereWorkExchangeService {
    /// Worker HTTPS API 根地址。
    private let baseURL: URL

    /// 无 Cookie、无磁盘缓存的临时 URLSession，避免换票响应落盘。
    private let session: URLSession

    /// 使用经过校验的 Worker [baseURL] 创建换票服务。
    ///
    /// 仅接受 HTTPS 且必须包含主机名；无效配置返回 nil，防止身份声明发往非预期地址。
    init?(baseURL: URL) {
        guard baseURL.scheme?.lowercased() == "https", baseURL.host?.isEmpty == false else {
            return nil
        }
        self.baseURL = baseURL
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 15
        configuration.timeoutIntervalForResource = 20
        configuration.httpCookieStorage = nil
        configuration.urlCache = nil
        self.session = URLSession(configuration: configuration)
    }

    /// 从 CandyTalk Info.plist 读取 `WorkerAPIBaseURL` 并创建安全换票服务。
    ///
    /// 返回 nil 表示配置缺失、URL 格式错误或并非 HTTPS。
    static func configuredService(bundle: Bundle = .main) -> CoHereWorkExchangeService? {
        guard
            let rawValue = bundle.object(forInfoDictionaryKey: "WorkerAPIBaseURL") as? String,
            let url = URL(string: rawValue.trimmingCharacters(in: .whitespacesAndNewlines))
        else {
            return nil
        }
        return CoHereWorkExchangeService(baseURL: url)
    }

    /// 使用当前 ios-client [user] 和安装信息换取可撤销 Worker 会话。
    ///
    /// [completion] 总在主线程返回；返回的数据任务只供上层在用户切换时取消。
    /// 安全边界：服务端按已确认方案直接信任 `userUID`，此请求不构成用户所有权证明。
    @discardableResult
    func exchange(
        user: NoaUserModel,
        deviceID: String,
        deviceName: String,
        completion: @escaping (Result<CoHereWorkExchangeResult, Error>) -> Void
    ) -> URLSessionDataTask? {
        let userUID = user.userUID.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedDeviceID = deviceID.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedDeviceName = deviceName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !userUID.isEmpty, !normalizedDeviceID.isEmpty, !normalizedDeviceName.isEmpty else {
            DispatchQueue.main.async { completion(.failure(CoHereWorkExchangeError.invalidUser)) }
            return nil
        }

        let endpoint = baseURL.appendingPathComponent("v1/auth/ios/exchange")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let payload = ExchangeRequest(
            userUid: userUID,
            displayName: user.nickname,
            avatarUrl: user.avatar,
            deviceId: normalizedDeviceID,
            deviceName: normalizedDeviceName,
            platform: "ios"
        )
        do {
            request.httpBody = try JSONEncoder().encode(payload)
        } catch {
            DispatchQueue.main.async { completion(.failure(CoHereWorkExchangeError.invalidUser)) }
            return nil
        }

        let task = session.dataTask(with: request) { data, response, error in
            let result = Self.parseResponse(data: data, response: response, error: error)
            DispatchQueue.main.async { completion(result) }
        }
        task.resume()
        return task
    }

    /// 校验 HTTP 状态、统一业务码以及必需身份字段，且不向上层暴露原始响应正文。
    private static func parseResponse(
        data: Data?,
        response: URLResponse?,
        error: Error?
    ) -> Result<CoHereWorkExchangeResult, Error> {
        if let error {
            return .failure(error)
        }
        guard
            let httpResponse = response as? HTTPURLResponse,
            (200 ... 299).contains(httpResponse.statusCode),
            let data,
            let envelope = try? JSONDecoder().decode(ExchangeEnvelope.self, from: data)
        else {
            return .failure(CoHereWorkExchangeError.invalidResponse)
        }
        guard
            envelope.code == 0,
            let payload = envelope.data,
            !payload.token.isEmpty,
            !payload.workerUserId.isEmpty
        else {
            return .failure(CoHereWorkExchangeError.rejected)
        }
        return .success(
            CoHereWorkExchangeResult(token: payload.token, workerUserID: payload.workerUserId)
        )
    }
}

/// Worker `/v1/auth/ios/exchange` 请求体；字段名与 Go API 合同一致。
private struct ExchangeRequest: Encodable {
    /// 客户端直接声明的稳定 ios-client 用户标识。
    let userUid: String

    /// 同步到 Worker 的当前昵称，允许为空并由服务端提供默认值。
    let displayName: String

    /// 同步到 Worker 的当前头像地址，允许为空。
    let avatarUrl: String

    /// 当前安装的稳定设备标识，用于 Worker 会话撤销与替换。
    let deviceId: String

    /// 用户可读的设备名称。
    let deviceName: String

    /// 固定平台值，服务端只接受 ios。
    let platform: String
}

/// Worker 统一响应外壳；失败 message 故意不向 UI 或日志透传。
private struct ExchangeEnvelope: Decodable {
    /// 业务码，只有 0 表示换票成功。
    let code: Int

    /// 成功时的 Worker 凭据数据。
    let data: ExchangePayload?
}

/// Worker 换票成功数据。
private struct ExchangePayload: Decodable {
    /// 仅供 Flutter 内存会话使用的 Worker JWT。
    let token: String

    /// Worker 公共用户标识。
    let workerUserId: String
}
