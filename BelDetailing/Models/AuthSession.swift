struct AuthSession: Codable {
    let user: UserLite
    let accessToken: String
    let refreshToken: String
    let userRole: String?
    
    enum CodingKeys: String, CodingKey {
        case user
        case accessToken
        case refreshToken
        case userRole
    }
}
