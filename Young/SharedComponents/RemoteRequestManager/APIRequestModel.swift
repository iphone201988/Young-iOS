import Foundation

struct APIRequestParams {
    var endpoint: APIEndpoints
    var methodType: APIRequestMethodType
    var contentType: APIRequestContentType?
    var requestModelData: Data?
    var params: [String: Any]?
    let mediaContent: [MultipartMediaRequestParams]?
    var isHideLoadingIndicator: Bool = false
    var remoteRequestTail: String?
    var deleteSelectedNotifications: Bool? = false
    var arrParams: [String: Any]?
    
    init(endpoint: APIEndpoints,
         methodType: APIRequestMethodType,
         contentType: APIRequestContentType? = nil,
         requestModelData: Data? = nil,
         params: [String: Any]? = nil,
         mediaContent: [MultipartMediaRequestParams]? = nil,
         isHideLoadingIndicator: Bool = false,
         remoteRequestTail: String? = nil,
         deleteSelectedNotifications: Bool? = false,
         arrParams: [String: Any]? = nil) {
        
        self.endpoint = endpoint
        self.methodType = methodType
        self.contentType = contentType
        self.requestModelData = requestModelData
        self.params = params
        self.mediaContent = mediaContent
        self.isHideLoadingIndicator = isHideLoadingIndicator
        self.remoteRequestTail = remoteRequestTail
        self.deleteSelectedNotifications = deleteSelectedNotifications
        self.arrParams = arrParams
    }
}

struct MultipartMediaRequestParams {
    var filename: String
    var data: Data
    var keyname: MediaFileKeyname
    var contentType: MediaContentType
    
    enum MediaContentType: String {
        case imageJPEG = "image/jpeg"
        case imagePNG = "image/png"
        case videoMP4 = "video/mp4"
        case videoMOV = "video/quicktime"
        case audio = "audio/mp3"
    }
    
    enum MediaFileKeyname: String {
        case licenseImage = "licenseImage"
        case profileImage = "profileImage"
        case additionalPhotos = "additionalPhotos"
        case postImage = "image"
        case formUpload = "formUpload"
        case screenshots = "screenshots"
        case file = "file"
    }
}

// MARK: - SuccessResponse
struct SuccessResponse: Codable {
    let status: Int?
    let message: String?
    let data: Int?
    let userId: String?
}

// MARK: - ResponseErrorWithoutDataModel
struct ResponseErrorWithoutDataModel: Codable {
    let status: Int?
    let message: String?
}

// MARK: - ResponseErrorModel
struct ResponseErrorModel: Codable {
    let status: Int?
    let message: String?
    let data: ResponseErrorData?
}

// MARK: - ResponseErrorData
struct ResponseErrorData: Codable {
    let allWarningMessages, allNonErrorMessages, allErrorMessages: [String]?
    
    enum CodingKeys: String, CodingKey {
        case allWarningMessages = "all_warning_messages"
        case allNonErrorMessages = "all_non_error_messages"
        case allErrorMessages = "all_error_messages"
    }
}

struct RequestResponse: Codable {
    var status: Int?
    var isSuccess: Bool?
    var error: String?
    var request: APIEndpoints?
    var message: String?
}

extension RequestResponse {
    static func success(for request: APIEndpoints? = nil, msg: String? = nil) -> Self {
        .init(isSuccess: true, error: nil, request: request, message: msg)
    }

    static func failure(_ error: String, request: APIEndpoints? = nil) -> Self {
        .init(isSuccess: false, error: error, request: request)
    }
}
