import Foundation

// MARK: - PostModel
struct PostModel: Codable {
    let success: Bool?
    let message: String?
    let data: PostsData?
    let pagination: Pagination?
}

// MARK: - UsersListModel
struct UsersListModel: Codable {
    let success: Bool?
    let message: String?
    let data: UsersData?
    let pagination: Pagination?
}

// MARK: - UsersData
struct UsersData: Codable {
    let users: [UserDetails]?
}

// MARK: - Pagination
struct Pagination: Codable {
    let page, limit, totalPages, total: Int?
}

// MARK: - PostsData
struct PostsData: Codable {
    let posts: [PostDetails]?
    let streams: [PostDetails]?
    let vaults: [PostDetails]?
    let vaultId: String?
    let postId: String?
    let streamId: String?
    let commentId: String?
    let ratings: Double?
    let post: PostDetails?
}

// MARK: - PostDetails
struct PostDetails: Codable {
    var _id: String?
    var admin: UserDetails?
    var title, topic, description, image: String?
    var createdAt: String?
    var isDeleted: Bool?
    var likesCount, commentsCount, savesCount: Int?
    var isSaved, isLiked: Bool?
    var members: [UserDetails]?
    var access: String?
    var category: [String]?
    var isMember: Bool?
    var userId: UserDetails?
    var symbol, symbolValue: String?
    var type, scheduleDate: String?
    var isPublished: Bool?
    var ratings: Double?
    var isReported: Bool?
    var streamUrl: String?
    var chatId: String?
}

struct UpdatedRow {
    let index: Int
    let event: SavedOptions
    let key: PostKeys
}

// MARK: - ParticularPostModel
struct ParticularPostModel: Codable {
    let success: Bool?
    let message: String?
    let data: ParticularPostData?
}

// MARK: - ParticularPostData
struct ParticularPostData: Codable {
    let post: PostDetails?
    let stream: PostDetails?
    let vault: PostDetails?
    let comments: [Comment]?
    let comment: Comment?
    let pagination: Pagination?
}

// MARK: - Comment
struct Comment: Codable {
    var _id: String?
    var userId: UserDetails?
    var vaultId, comment, type, createdAt: String?
    var isLiked: Bool?
    var likesCount: Int?
}

// MARK: - TrendingModel
struct TrendingModel: Codable {
    let success: Bool?
    let message: String?
    let data: TrendingData?
}

// MARK: - TrendingData
struct TrendingData: Codable {
    let topics: [Topic]?
}

// MARK: - Topic
struct Topic: Codable {
    let count: Int?
    let topic: String?
    let image: String?
}

struct UserModel: Codable {
    let success: Bool?
    let message: String?
    let data: Users?
}

// MARK: - Users
struct Users: Codable {
    let users: [UserDetails]?
}

// MARK: - ParticularUserModel
struct ParticularUserModel: Codable {
    let success: Bool?
    let message: String?
    let data: UserData?
}

// MARK: - UserData
struct UserData: Codable {
    let user: UserDetails?
    let isDocumentVerified: String?
}

// MARK: - NewsModel
struct NewsModel: Codable {
    let success: Bool?
    let message: String?
    let data: News?
}

// MARK: - News
struct News: Codable {
    let news: [UserDetails]?
}

// MARK: - Rating
struct Rating: Codable, Equatable {
    var _id: String?
    var ratings: Double?
}

// MARK: - ChatModel
struct ChatModel: Codable {
    let success: Bool?
    let message: String?
    let data: ChatsData?
}

// MARK: - ChatsData
struct ChatsData: Codable {
    let chats: [Chat]?
    let messages: [Chat]?
}

// MARK: - Chat
struct Chat: Codable {
    let _id: String?
    let chatUsers: [UserDetails]?
    let hasUnreadMessages: Bool?
    let createdAt: String?
    let lastMessage: LastMessage?
    let chatID: String?
    let senderId: UserDetails?
    let message: String?
    let isRead: Bool?
}

// MARK: - LastMessage
struct LastMessage: Codable {
    let _id, message: String?
}


// MARK: - RatingModel
struct RatingModel: Codable {
    let success: Bool?
    let message: String?
    let data: RatingData?
}

// MARK: - RatingData
struct RatingData: Codable {
    let totalCount: Int?
    let ratingsCount: [String: Int]?
    let averageRating: Double?
}


// MARK: - CalendarEventsModel
struct CalendarEventsModel: Codable {
    let success: Bool?
    let message: String?
    let data: EventData?
}

// MARK: - EventData
struct EventData: Codable {
    let event: Event?
    let events: [Event]?
    let pagination: Pagination?
}

// MARK: - Event
struct Event: Codable {
    var _id, userId, title, topic: String?
    var description, file, scheduledDate, type: String?
    var createdAt: String?
    var eventScheduledDate: Date?
    var isDeleted: Bool?
}

// MARK: - PaymentCardsModel
struct PaymentCardsModel: Codable {
    let success: Bool?
    let message: String?
    let data: CardData?
}

// MARK: - CardData
struct CardData: Codable {
    let paymentMethods: [CardDetails]?
}

// MARK: - CardDetails
struct CardDetails: Codable {
    let id, type: String?
    let card: Card?
}

// MARK: - Card
struct Card: Codable {
    let brand, last4: String?
    let expMonth, expYear: Int?
}

// MARK: - AdsModel
struct AdsModel: Codable {
    let success: Bool?
    let message: String?
    let data: Ads?
    let pagination: Pagination?
}

// MARK: - Ads
struct Ads: Codable {
    let ads: [UserDetails]?
}

// MARK: - StockInfo
struct StockInfo {
    var symbol: String
    var value: String
    var isdown: Bool
}

// MARK: - MediaDetails
struct MediaDetails: Codable {
    let success: Bool?
    let message: String?
    let data: [MediaData]?
}

// MARK: - MediaData
struct MediaData: Codable {
    let _id, title, imageUrl, createdAt: String?
    let updatedAt: String?
    // cache height once loaded
    var calculatedHeight: CGFloat?
}
