import Foundation

struct AuthModel: Codable {
    let success: Bool?
    let message: String?
    let data: UserDetails?
}

// MARK: - UserDetails
struct UserDetails: Codable, Equatable {
    var _id, userId, role: String?
    var qrCodeUrl, secret, token: String?
    var firstName, lastName, username, email, countryCode, phone, name: String?
    var isRegistrationCompleted, is2FAEnabled, isVerified: Bool?
    var following: Int?
    var followers: Int?
    var customers: Int?
    var sharesCount: Int?
    //var formUpload: [String]?
    //var savedPosts: [String]?
    var additionalPhotos, formUpload: [String]?
    var profileImage: String?
    var areaOfExpertise, crdNumber, packageName, productsOffered, about: String?
    var lastLogin: String?
    var website, city, state, company: String?
    var race, gender, ageRange, age, maritalStatus, createdAt, yearFounded: String?
    var investors, retirement, investmentRealEstate, investmentAccounts, fairnessForward: Bool?
    var certificates: String?
    var occupation: String?
    var yearsInFinancialIndustry: String?
    var yearsEmployed: String?
    var salaryRange: String?
    var riskTolerance: String?
    var topicsOfInterest: [String]?
    var goals: String?
    var financialExperience: String?
    var industriesSeeking, seeking: String?
    var stageOfBusiness, fundsRaised, fundsRaising, businessRevenue: String?
    var servicesProvided: String?
    var children, educationLevel, residenceStatus: String?
    var stockInvestments: String?
    var specificStockSymbols: String?
    var cryptoInvestments: String?
    var specificCryptoSymbols: String?
    var otherSecurityInvestments: String?
    var realEstate: String?
    var retirementAccount: String?
    var savings: String?
    var startups: String?
    var isRated, averageRating: Double?
    var ratings: [Rating]?
    //var ratings: Double?
    var isFollowed, isConnectedWithProfile: Bool?
    var chatId: String?
    var isReported: Bool?
    var isDocumentVerified: String?
    var file: String?
    var updatedAt: String?
    var status: String?
    var newsLink: String?
    var servicesInterested: String?
}
