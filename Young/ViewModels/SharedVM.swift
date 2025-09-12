import Foundation
import Combine
import UIKit

final class SharedVM: ObservableObject {
    
    // MARK: Published Variables -
    @Published var requestResponse = RequestResponse()
    @Published var usersList: [UserDetails] = []
    @Published var isUsersListLastPage = false
    @Published var isUsersListLoading = false
    
    @Published var sharePostsList: [PostDetails] = []
    @Published var isSharePostsListLastPage = false
    @Published var isSharePostsListLoading = false
    
    @Published var streamPostsList: [PostDetails] = []
    @Published var isStreamPostsListLastPage = false
    @Published var isStreamPostsListLoading = false
    
    @Published var vaultsList: [PostDetails] = []
    @Published var isVaultsListLastPage = false
    @Published var isVaultsListLoading = false
    
    @Published var particularShareDetails: PostDetails?
    @Published var particularStreamDetails: PostDetails?
    @Published var particularVaultDetails: PostDetails?
    
    @Published var comments = [Comment]()
    @Published var triggeredEvent: Events?
    @Published var commentPagination: Pagination?
    
    @Published var trendingTopics = [Topic]()
    @Published var groupedUsers = [String : [UserDetails]]()
    
    @Published var updatedPostStatusIndex: UpdatedRow?
    @Published var updatedCommentStatusIndex: UpdatedRow?
    
    @Published var particularUserDetails: UserDetails?
    
    @Published var updatedRating: Double?
    
    @Published var inboxChats = [Chat]()
    @Published var messages = [Chat]()
    
    @Published var ratingData: RatingData?
    
    @Published var calendarEvents = [Event]()
    @Published var isCalendarEventsListLoading = false
    @Published var isCalendarEventsListLastPage = false
    
    @Published var ecosystemUsers = [UserDetails]()
    @Published var paymentCards = [CardDetails]()
    
    @Published var documentVerifiedStatus: DocumentVerified?
    
    @Published var createdStreamingDetails: PostDetails?
    @Published var downloadedHistory = [PostDetails]()
    
    @Published var ads = [UserDetails]()
    @Published var isAdsListLastPage = false
    @Published var isAdsListLoading = false
    
    @Published var mediaData = [MediaData]()
    
    // MARK: Shared Variables -
    var cancellables = Set<AnyCancellable>()
    
    // MARK: deinit -
    deinit{ cancellables.forEach { $0.cancel() } }
}

extension SharedVM {
    
    @MainActor
    func logout() {
        
        let requestParams = APIRequestParams(
            endpoint: .logout,
            methodType: .get,
            contentType: .json
        )
        
        RemoteRequestManager.shared.dataTask(type: AuthModel.self, requestParams: requestParams)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case .errorMessage(let err):
                        self?.requestResponse = .failure(err)
                    default: break
                    }
                default: break
                }
            }, receiveValue: { [weak self] response in
                UserDefaults.standard.clearAllLocallySavedData()
                self?.requestResponse = .success(for: .logout)
            }).store(in: &cancellables)
    }
    
    @MainActor
    func getUserProfile(anotherUserID: String? = nil, forDocumentVerificationStatus: Bool = false) {
        LoaderUtil.shared.showLoading()
        var params = [String: Any]()
        
        if let anotherUserID {
            params["userId"] = anotherUserID
        }
        
        let requestParams = APIRequestParams(
            endpoint: .getUserProfile,
            methodType: .get,
            contentType: .json,
            params: params
        )
        
        RemoteRequestManager.shared.dataTask(type: ParticularUserModel.self, requestParams: requestParams)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case .errorMessage(let err):
                        self?.requestResponse = .failure(err)
                    default: break
                    }
                default: break
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    LoaderUtil.shared.hideLoading()
                }
                
            }, receiveValue: { [weak self] response in
                if let userDetails = response.data?.user {
                    if forDocumentVerificationStatus {
                        let isDocumentVerified = userDetails.isDocumentVerified ?? ""
                        self?.documentVerifiedStatus = DocumentVerified(rawValue: isDocumentVerified)
                    } else {
                        self?.particularUserDetails = userDetails
                        if anotherUserID == nil {
                            UserDefaults.standard[.loggedUserDetails] = userDetails
                            let firstName = userDetails.firstName ?? ""
                            let lastName = userDetails.lastName ?? ""
                            UserDefaults.standard[.loggedUserDetails]?.name = "\(firstName) \(lastName)"
                        }
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        LoaderUtil.shared.hideLoading()
                    }
                }
            }).store(in: &cancellables)
    }
    
    @MainActor
    func getUnauthUser(params: [String: String]) {
        
        let requestParams = APIRequestParams(
            endpoint: .getUnauthUser,
            methodType: .get,
            contentType: .json,
            params: params
        )
        
        RemoteRequestManager.shared.dataTask(type: ParticularUserModel.self, requestParams: requestParams)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case .errorMessage(let err):
                        self?.requestResponse = .failure(err)
                    default: break
                    }
                default: break
                }
            }, receiveValue: { [weak self] response in
                if let isDocumentVerified = response.data?.isDocumentVerified {
                    self?.documentVerifiedStatus = DocumentVerified(rawValue: isDocumentVerified)
                }
            }).store(in: &cancellables)
    }
    
    @MainActor
    func followUnfollowUser(userID: String) {
        
        let requestParams = APIRequestParams(
            endpoint: .followUnfollowUser,
            methodType: .put,
            contentType: .json,
            remoteRequestTail: userID
        )
        
        RemoteRequestManager.shared.dataTask(type: AuthModel.self, requestParams: requestParams)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case .errorMessage(let err):
                        self?.requestResponse = .failure(err)
                    default: break
                    }
                default: break
                }
            }, receiveValue: { [weak self] response in
                self?.requestResponse = .success(for: .followUnfollowUser, msg: response.message ?? "")
            }).store(in: &cancellables)
    }
    
    @MainActor
    func createPost(params: [String: Any], mediaData: Data?, event: SavedOptions) {
        LoaderUtil.shared.showLoading()
        var updatedParams = [String: Any]()
        updatedParams = params.filter{ !("\($0.value)".isEmpty) }
        if event != .vault {
            updatedParams["type"] = "\(event)"
        }
        var multipartParams = [MultipartMediaRequestParams]()
        if let mediaData {
            let timeStamp = Int(Date().timeIntervalSince1970)
            let fileName = "image_\(timeStamp).jpg"
            let params = MultipartMediaRequestParams(filename: fileName,
                                                     data: mediaData,
                                                     keyname: .postImage,
                                                     contentType: .imageJPEG)
            multipartParams.append(params)
        }
        
        let endpoint: APIEndpoints = event == .share ? .share : event == .stream ? .share : .vault
        
        let requestParams = APIRequestParams(
            endpoint: endpoint,
            methodType: .post,
            contentType: .multipartFormData,
            params: updatedParams,
            mediaContent: multipartParams
        )
        
        RemoteRequestManager.shared.uploadTask(type: PostModel.self, requestParams: requestParams)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    LoaderUtil.shared.hideLoading()
                    switch error {
                    case .errorMessage(let err):
                        self?.requestResponse = .failure(err)
                    default: break
                    }
                default: break
                }
            }, receiveValue: { [weak self] response in
                if event == .stream {
                    self?.createdStreamingDetails = response.data?.post
                }
                self?.requestResponse = .success(msg: response.message ?? "")
                LoaderUtil.shared.hideLoading()
            }).store(in: &cancellables)
    }
    
    @MainActor
    func getPosts(params: [String: Any],
                  limit: Int,
                  event: SavedOptions,
                  isfetchSavedData: Bool = false) {
        
        var updatedParams = params
        
        updatedParams = params.filter{ !("\($0.value)".isEmpty) }
        
        var endpoint: APIEndpoints = .share
        
        if isfetchSavedData {
            endpoint = event == .share ? .getSavedPosts : event == .stream ? .getSavedPosts : .getSavedVaults
        } else {
            endpoint = event == .share ? .share : event == .stream ? .share : .vault
        }
        
        let requestParams = APIRequestParams(
            endpoint: endpoint,
            methodType: .get,
            contentType: .json,
            params: updatedParams
        )
        
        RemoteRequestManager.shared.dataTask(type: PostModel.self, requestParams: requestParams)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case .errorMessage(let err):
                        self?.requestResponse = .failure(err)
                    default: break
                    }
                default: break
                }
            }, receiveValue: { [weak self] response in
                
                let pageNo = params["page"] as? Int ?? 1
                if pageNo == 1 {
                    self?.sharePostsList.removeAll()
                    self?.streamPostsList.removeAll()
                    self?.vaultsList.removeAll()
                }
                
                let shares = response.data?.posts ?? []
                let streams = response.data?.posts ?? []
                let vaults = response.data?.vaults ?? []
                
                switch event {
                case .share:
                    if shares.count < limit {
                        self?.isSharePostsListLastPage = true
                    }
                    
                    var loadedList = self?.sharePostsList ?? []
                    loadedList.append(contentsOf: shares)
                    self?.sharePostsList = loadedList
                    self?.isSharePostsListLoading = false
                    
                case .stream:
                    if streams.count < limit {
                        self?.isStreamPostsListLastPage = true
                    }
                    
                    var loadedList = self?.streamPostsList ?? []
                    loadedList.append(contentsOf: streams)
                    self?.streamPostsList = loadedList
                    self?.isStreamPostsListLoading = false
                    
                case .vault:
                    if vaults.count < limit {
                        self?.isVaultsListLastPage = true
                    }
                    
                    var loadedList = self?.vaultsList ?? []
                    loadedList.append(contentsOf: vaults)
                    self?.vaultsList = loadedList
                    self?.isVaultsListLoading = false
                    
                default: break
                }
                
                self?.requestResponse = .success(for: endpoint)
            }).store(in: &cancellables)
    }
    
    @MainActor
    func saveUnsaveVault(postID: String, event: SavedOptions) {
        
        let endpoint: APIEndpoints = event == .share ? .saveUnsavePost : event == .stream ? .saveUnsavePost : .saveUnsaveVault
        
        let tail = "\(postID)?type=\(event)"
        
        let requestParams = APIRequestParams(
            endpoint: endpoint,
            methodType: .put,
            contentType: .json,
            remoteRequestTail: tail
        )
        
        RemoteRequestManager.shared.dataTask(type: PostModel.self, requestParams: requestParams)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case .errorMessage(let err):
                        self?.requestResponse = .failure(err)
                    default: break
                    }
                default: break
                }
            }, receiveValue: { [weak self] response in
                var respID = ""
                var respEvent: SavedOptions = .share
                
                if let postID = response.data?.postId {
                    respEvent = .share
                    respID = postID
                }
                
                if let streamId = response.data?.streamId {
                    respEvent = .stream
                    respID = streamId
                }
                
                if let vaultId = response.data?.vaultId {
                    respEvent = .vault
                    respID = vaultId
                }
                
                self?.updatePostKeyStatus(key: .save, event: event, postID: respID)
                self?.requestResponse = .success(for: .saveUnsaveVault, msg: response.message ?? "")
            }).store(in: &cancellables)
    }
    
    @MainActor
    func likeDislikePost(postID: String, event: SavedOptions) {
        
        let endpoint: APIEndpoints = event == .share ? .likeDislikePost : event == .stream ? .likeDislikePost : .likeDislikePost
        
        let tail = "\(postID)?type=\(event)"
        
        let requestParams = APIRequestParams(
            endpoint: endpoint,
            methodType: .put,
            contentType: .json,
            remoteRequestTail: tail
        )
        
        RemoteRequestManager.shared.dataTask(type: PostModel.self, requestParams: requestParams)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case .errorMessage(let err):
                        self?.requestResponse = .failure(err)
                    default: break
                    }
                default: break
                }
            }, receiveValue: { [weak self] response in
                var respID = ""
                var respEvent: SavedOptions = .share
                
                if let postID = response.data?.postId {
                    respEvent = .share
                    respID = postID
                }
                
                if let streamId = response.data?.streamId {
                    respEvent = .stream
                    respID = streamId
                }
                
                if let vaultId = response.data?.vaultId {
                    respEvent = .vault
                    respID = vaultId
                }
                
                self?.updatePostKeyStatus(key: .like, event: event, postID: respID)
                self?.requestResponse = .success(for: .likeDislikePost, msg: response.message ?? "")
            }).store(in: &cancellables)
    }
    
    func updatePostKeyStatus(key: PostKeys,
                             event: SavedOptions,
                             postID: String,
                             rating: Double? = nil) {
        switch event {
        case .share:
            if let index = sharePostsList.firstIndex(where: { $0._id == postID }) {
                
                switch key {
                case .like:
                    let previousStatus = sharePostsList[index].isLiked ?? false
                    sharePostsList[index].isLiked = !previousStatus
                    
                    let previousCount = sharePostsList[index].likesCount ?? 0
                    if previousStatus {
                        sharePostsList[index].likesCount = previousCount - 1
                    } else {
                        sharePostsList[index].likesCount = previousCount + 1
                    }
                    
                case .save:
                    let previousStatus = sharePostsList[index].isSaved ?? false
                    sharePostsList[index].isSaved = !previousStatus
                    
                case .rating:
                    sharePostsList[index].ratings = rating
                    
                case .commentCount:
                    let previousCount = sharePostsList[index].commentsCount ?? 0
                    sharePostsList[index].commentsCount = previousCount + 1
                    
                case .deletePost:
                    if sharePostsList.indices.contains(index) {
                        sharePostsList.remove(at: index)
                    }
                    
                case .reportedPost:
                    sharePostsList[index].isReported = true
                    
                default: break
                }
                
                updatedPostStatusIndex = UpdatedRow(index: index, event: event, key: key)
            }
            
        case .stream:
            if let index = streamPostsList.firstIndex(where: { $0._id == postID }) {
                
                switch key {
                case .like:
                    let previousStatus = streamPostsList[index].isLiked ?? false
                    streamPostsList[index].isLiked = !previousStatus
                    
                    let previousCount = streamPostsList[index].likesCount ?? 0
                    if previousStatus {
                        streamPostsList[index].likesCount = previousCount - 1
                    } else {
                        streamPostsList[index].likesCount = previousCount + 1
                    }
                    
                case .save:
                    let previousStatus = streamPostsList[index].isSaved ?? false
                    streamPostsList[index].isSaved = !previousStatus
                    
                case .rating:
                    streamPostsList[index].ratings = rating
                    
                case .commentCount:
                    let previousCount = streamPostsList[index].commentsCount ?? 0
                    streamPostsList[index].commentsCount = previousCount + 1
                    
                case .deletePost:
                    if streamPostsList.indices.contains(index) {
                        streamPostsList.remove(at: index)
                    }
                    
                case .reportedPost:
                    streamPostsList[index].isReported = true
                    
                default: break
                }
                
                updatedPostStatusIndex = UpdatedRow(index: index, event: event, key: key)
            }
            
        case .vault:
            if let index = vaultsList.firstIndex(where: { $0._id == postID }) {
                
                switch key {
                case .like:
                    let previousStatus = vaultsList[index].isLiked ?? false
                    vaultsList[index].isLiked = !previousStatus
                    
                    let previousCount = vaultsList[index].likesCount ?? 0
                    if previousStatus {
                        vaultsList[index].likesCount = previousCount - 1
                    } else {
                        vaultsList[index].likesCount = previousCount + 1
                    }
                    
                case .save:
                    let previousStatus = vaultsList[index].isSaved ?? false
                    vaultsList[index].isSaved = !previousStatus
                    
                case .rating:
                    vaultsList[index].ratings = rating
                    
                case .commentCount:
                    let previousCount = vaultsList[index].commentsCount ?? 0
                    vaultsList[index].commentsCount = previousCount + 1
                    
                case .deletePost:
                    if vaultsList.indices.contains(index) {
                        vaultsList.remove(at: index)
                    }
                    
                case .reportedPost:
                    vaultsList[index].isReported = true
                    
                default: break
                }
                
                updatedPostStatusIndex = UpdatedRow(index: index, event: event, key: key)
            }
            
        default: break
        }
    }
    
    @MainActor
    func addComment(params: [String: Any], event: SavedOptions) {
        
        let requestParams = APIRequestParams(
            endpoint: .comment,
            methodType: .post,
            contentType: .json,
            params: params
        )
        
        RemoteRequestManager.shared.dataTask(type: ParticularPostModel.self, requestParams: requestParams)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case .errorMessage(let err):
                        self?.requestResponse = .failure(err)
                    default: break
                    }
                default: break
                }
            }, receiveValue: { [weak self] response in
                var loadedComments = self?.comments ?? []
                if let newComment = response.data?.comment {
                    loadedComments.append(newComment)
                }
                self?.triggeredEvent = .addComment
                self?.comments = loadedComments
            }).store(in: &cancellables)
    }
    
    @MainActor
    func getComments(params: [String: Any], event: SavedOptions) {
        
        let requestParams = APIRequestParams(
            endpoint: .comment,
            methodType: .get,
            contentType: .json,
            params: params
        )
        
        RemoteRequestManager.shared.dataTask(type: ParticularPostModel.self, requestParams: requestParams)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case .errorMessage(let err):
                        self?.requestResponse = .failure(err)
                    default: break
                    }
                default: break
                }
            }, receiveValue: { [weak self] response in
                self?.triggeredEvent = .getComments
                let loadedComments = response.data?.comments ?? []
                self?.comments = loadedComments
                self?.commentPagination = response.data?.pagination
            }).store(in: &cancellables)
    }
    
    @MainActor
    func getPost(by postID: String, event: SavedOptions) {
        
        let endpoint: APIEndpoints = event == .share ? .share : event == .stream ? .share : .vault
        
        let requestParams = APIRequestParams(
            endpoint: endpoint,
            methodType: .get,
            contentType: .json,
            remoteRequestTail: postID
        )
        
        RemoteRequestManager.shared.dataTask(type: ParticularPostModel.self, requestParams: requestParams)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case .errorMessage(let err):
                        self?.requestResponse = .failure(err)
                    default: break
                    }
                default: break
                }
            }, receiveValue: { [weak self] response in
                switch event {
                case .share:
                    self?.particularShareDetails = response.data?.post
                    
                case .stream:
                    self?.particularStreamDetails = response.data?.post
                    
                case .vault:
                    self?.particularVaultDetails = response.data?.vault
                    
                default: break
                }
                
                self?.requestResponse = .success()
            }).store(in: &cancellables)
    }
    
    @MainActor
    func joinLeaveVault(vaultID: String, event: SavedOptions) {
        
        let requestParams = APIRequestParams(
            endpoint: .joinLeaveVault,
            methodType: .put,
            contentType: .json,
            remoteRequestTail: vaultID
        )
        
        RemoteRequestManager.shared.dataTask(type: PostModel.self, requestParams: requestParams)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case .errorMessage(let err):
                        self?.requestResponse = .failure(err)
                    default: break
                    }
                default: break
                }
            }, receiveValue: { [weak self] response in
                switch event {
                case .share:
                    let previousStatus = self?.particularShareDetails?.isMember ?? false
                    self?.particularShareDetails?.isMember = !previousStatus
                    
                case .stream:
                    let previousStatus = self?.particularStreamDetails?.isMember ?? false
                    self?.particularStreamDetails?.isMember = !previousStatus
                    
                case .vault:
                    let previousStatus = self?.particularVaultDetails?.isMember ?? false
                    self?.particularVaultDetails?.isMember = !previousStatus
                    
                default: break
                }
                
                self?.requestResponse = .success(for: .joinLeaveVault, msg: response.message ?? "")
            }).store(in: &cancellables)
    }
    
    @MainActor
    func likeDislikeComment(id: String, event: SavedOptions) {
        
        let requestParams = APIRequestParams(
            endpoint: .comment,
            methodType: .put,
            contentType: .json,
            remoteRequestTail: id
        )
        
        RemoteRequestManager.shared.dataTask(type: PostModel.self, requestParams: requestParams)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case .errorMessage(let err):
                        self?.requestResponse = .failure(err)
                    default: break
                    }
                default: break
                }
            }, receiveValue: { response in
                ///Due to complications in reload particular row that's why update cell i.e. @objc func likeDislikeComment(_ sender: UIButton)
                //                if let index = self?.comments.firstIndex(where: { $0._id == response.data?.commentId }) {
                //                    let previousStatus = self?.comments[index].isLiked ?? false
                //                    self?.triggeredEvent = .likeDislikeComment
                //                    self?.comments[index].isLiked = !previousStatus
                //                    self?.updatedCommentStatusIndex = UpdatedRow(index: index, event: event)
                //                }
            }).store(in: &cancellables)
    }
    
    @MainActor
    func getTrendingTopics() {
        
        let requestParams = APIRequestParams(
            endpoint: .getTrendingTopics,
            methodType: .get,
            contentType: .json
        )
        
        RemoteRequestManager.shared.dataTask(type: TrendingModel.self, requestParams: requestParams)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case .errorMessage(let err):
                        self?.requestResponse = .failure(err)
                    default: break
                    }
                default: break
                }
            }, receiveValue: { [weak self] response in
                let topics = response.data?.topics ?? []
                self?.trendingTopics = topics
            }).store(in: &cancellables)
    }
    
    @MainActor
    func getLatestUsers(params: [String: Any] = [:]) {
        
        let requestParams = APIRequestParams(
            endpoint: .getLatestUsers,
            methodType: .get,
            contentType: .json,
            params: params
        )
        
        RemoteRequestManager.shared.dataTask(type: UserModel.self, requestParams: requestParams)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case .errorMessage(let err):
                        self?.requestResponse = .failure(err)
                    default: break
                    }
                default: break
                }
            }, receiveValue: { [weak self] response in
                let users = response.data?.users ?? []
                if !params.isEmpty {
                    self?.ecosystemUsers = users
                } else {
                    self?.groupedUsers = Dictionary(grouping: users, by: { $0.role ?? Categories.members.type })
                }
            }).store(in: &cancellables)
    }
    
    @MainActor
    func updateUser(params: [String: Any],
                    profileImageData: Data? = nil,
                    isDeactivated: Bool = false) {
        var updatedParams = [String: Any]()
        updatedParams = params.filter{ !("\($0.value)".isEmpty) }
        var multipartParams = [MultipartMediaRequestParams]()
        if let profileImageData {
            let timeStamp = Int(Date().timeIntervalSince1970)
            let fileName = "profileImage_\(timeStamp).jpg"
            let params = MultipartMediaRequestParams(filename: fileName,
                                                     data: profileImageData,
                                                     keyname: .profileImage,
                                                     contentType: .imageJPEG)
            multipartParams.append(params)
        }
        
        if let additionalPhotos = updatedParams["additionalPhotos"] as? [String] {
            let newAdditionalPhotos = additionalPhotos.filter { !$0.contains("/uploads") }
            for (index, path) in newAdditionalPhotos.enumerated() {
                if
                    let photo = UIImage(contentsOfFile: path),
                    let photoData = photo.jpegData(compressionQuality: 0.1) {
                    let timeStamp = Int(Date().timeIntervalSince1970)
                    let fileName = "additionalPhotos_\(index)_\(timeStamp).jpg"
                    let params = MultipartMediaRequestParams(filename: fileName,
                                                             data: photoData,
                                                             keyname: .additionalPhotos,
                                                             contentType: .imageJPEG)
                    multipartParams.append(params)
                }
            }
        }
        
        if let forms = updatedParams["formUpload"] as? [String] {
            let newForms = forms.filter { !$0.contains("/uploads") }
            for (index, path) in newForms.enumerated() {
                if
                    let form = UIImage(contentsOfFile: path),
                    let formData = form.jpegData(compressionQuality: 0.1) {
                    let timeStamp = Int(Date().timeIntervalSince1970)
                    let fileName = "formUpload_\(index)_\(timeStamp).jpg"
                    let params = MultipartMediaRequestParams(filename: fileName,
                                                             data: formData,
                                                             keyname: .formUpload,
                                                             contentType: .imageJPEG)
                    multipartParams.append(params)
                }
            }
        }
        
        updatedParams["additionalPhotos"] = nil
        updatedParams["formUpload"] = nil
        
        let additionalPhotosToBeRemoved = updatedParams["additionalPhotosToBeRemoved"] as? [String] ?? []
        updatedParams["additionalPhotosToBeRemoved"] = nil
        
        let formUploadToBeRemoved = updatedParams["formUploadToBeRemoved"] as? [String] ?? []
        updatedParams["formUploadToBeRemoved"] = nil
        
        let requestParams = APIRequestParams(
            endpoint: .updateUser,
            methodType: .put,
            contentType: .multipartFormData,
            params: updatedParams,
            mediaContent: multipartParams,
            arrParams: ["additionalPhotosToBeRemoved": additionalPhotosToBeRemoved,
                        "formUploadToBeRemoved": formUploadToBeRemoved]
        )
        
        RemoteRequestManager.shared.uploadTask(type: AuthModel.self, requestParams: requestParams)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case .errorMessage(let err):
                        self?.requestResponse = .failure(err)
                    default: break
                    }
                default: break
                }
            }, receiveValue: { [weak self] response in
                if isDeactivated {
                    DispatchQueue.main.async {
                        UserDefaults.standard.clearAllLocallySavedData()
                        if let vc = AppStoryboards.main.controller(LoginVC.self) {
                            SharedMethods.shared.navigateToRootVC(rootVC: vc)
                        }
                    }
                } else {
                    self?.requestResponse = .success(for: .updateUser, msg: response.message ?? "")
                }
            }).store(in: &cancellables)
    }
    
    @MainActor
    func addRating(params: [String: Any], completionHandler: @escaping () -> Void) {
        
        let requestParams = APIRequestParams(
            endpoint: .rating,
            methodType: .post,
            contentType: .json,
            params: params
        )
        
        RemoteRequestManager.shared.dataTask(type: PostModel.self, requestParams: requestParams)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case .errorMessage(let err):
                        self?.requestResponse = .failure(err, request: .rating)
                    default:
                        self?.requestResponse = .failure("An unknown error occurred.", request: .rating)
                        break
                    }
                default: break
                }
                completionHandler()
            }, receiveValue: { [weak self] response in
                self?.updatedRating = response.data?.ratings ?? 0.0
                completionHandler()
            }).store(in: &cancellables)
    }
    
    @MainActor
    func getChats(threadID: String? = nil) {
        let requestParams = APIRequestParams(
            endpoint: .chat,
            methodType: .get,
            contentType: .json,
            remoteRequestTail: threadID
        )
        
        RemoteRequestManager.shared.dataTask(type: ChatModel.self, requestParams: requestParams)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case .errorMessage(let err):
                        self?.requestResponse = .failure(err)
                    default: break
                    }
                default: break
                }
            }, receiveValue: { [weak self] response in
                if let _ = threadID {
                    self?.messages = response.data?.messages ?? []
                } else {
                    self?.inboxChats = response.data?.chats ?? []
                }
            }).store(in: &cancellables)
    }
    
    @MainActor
    func reportUser(params: [String: Any], screenshotData: Data?) {
        
        var multipartParams = [MultipartMediaRequestParams]()
        
        if let screenshotData {
            let timeStamp = Int(Date().timeIntervalSince1970)
            let fileName = "screenshot_\(timeStamp).jpg"
            let params = MultipartMediaRequestParams(filename: fileName,
                                                     data: screenshotData,
                                                     keyname: .screenshots,
                                                     contentType: .imageJPEG)
            multipartParams.append(params)
        }
        
        let requestParams = APIRequestParams(
            endpoint: .report,
            methodType: .post,
            contentType: .multipartFormData,
            params: params,
            mediaContent: multipartParams
        )
        
        RemoteRequestManager.shared.uploadTask(type: PostModel.self, requestParams: requestParams)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case .errorMessage(let err):
                        self?.requestResponse = .failure(err, request: .rating)
                    default:
                        self?.requestResponse = .failure("An unknown error occurred.", request: .rating)
                        break
                    }
                default: break
                }
            }, receiveValue: { [weak self] response in
                self?.requestResponse = .success(for: .report, msg: response.message ?? "")
            }).store(in: &cancellables)
    }
    
    @MainActor
    func getRating(params: [String: Any]) {
        
        let requestParams = APIRequestParams(
            endpoint: .rating,
            methodType: .get,
            contentType: .json,
            params: params
        )
        
        RemoteRequestManager.shared.dataTask(type: RatingModel.self, requestParams: requestParams)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case .errorMessage(let err):
                        self?.requestResponse = .failure(err)
                    default: break
                    }
                default: break
                }
            }, receiveValue: { [weak self] response in
                self?.ratingData = response.data
            }).store(in: &cancellables)
    }
    
    @MainActor
    func getEvents(params: [String: Any], limit: Int) {
        
        let requestParams = APIRequestParams(
            endpoint: .event,
            methodType: .get,
            contentType: .json,
            params: params
        )
        
        RemoteRequestManager.shared.dataTask(type: CalendarEventsModel.self, requestParams: requestParams)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case .errorMessage(let err):
                        self?.requestResponse = .failure(err)
                    default: break
                    }
                default: break
                }
            }, receiveValue: { [weak self] response in
                
                let pageNo = params["page"] as? Int ?? 1
                if pageNo == 1 {
                    self?.calendarEvents = []
                }
                
                var events = response.data?.events ?? []
                // Check if result is less than limit, meaning we are at the last page
                if events.count < limit {
                    self?.isCalendarEventsListLastPage = true
                }
                
                for (index, event) in events.enumerated() {
                    if let scheduledDate = event.scheduledDate {
                        let date = DateUtil.utcStringToLocalDate(utcString: scheduledDate)
                        events[index].eventScheduledDate = date
                    }
                }
                self?.isCalendarEventsListLoading = false
                var loadedCalendarEvents = self?.calendarEvents ?? []
                loadedCalendarEvents.append(contentsOf: events)
                self?.calendarEvents = loadedCalendarEvents
            }).store(in: &cancellables)
    }
    
    @MainActor
    func addCalendarEvent(params: [String: Any], fileData: Data?) {
        
        var multipartParams = [MultipartMediaRequestParams]()
        
        if let fileData {
            let timeStamp = Int(Date().timeIntervalSince1970)
            let fileName = "screenshot_\(timeStamp).jpg"
            let params = MultipartMediaRequestParams(filename: fileName,
                                                     data: fileData,
                                                     keyname: .file,
                                                     contentType: .imageJPEG)
            multipartParams.append(params)
        }
        
        let requestParams = APIRequestParams(
            endpoint: .event,
            methodType: .post,
            contentType: .multipartFormData,
            params: params,
            mediaContent: multipartParams
        )
        
        RemoteRequestManager.shared.uploadTask(type: CalendarEventsModel.self, requestParams: requestParams)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case .errorMessage(let err):
                        self?.requestResponse = .failure(err, request: .event)
                    default:
                        self?.requestResponse = .failure("An unknown error occurred.", request: .event)
                        break
                    }
                default: break
                }
            }, receiveValue: { [weak self] response in
                if var addedEvent = response.data?.event {
                    if let scheduledDate = addedEvent.scheduledDate {
                        let date = DateUtil.utcStringToLocalDate(utcString: scheduledDate)
                        addedEvent.eventScheduledDate = date
                    }
                    var loadedEvents = self?.calendarEvents ?? []
                    loadedEvents.append(addedEvent)
                    self?.calendarEvents = loadedEvents
                }
                self?.requestResponse = .success(for: .event, msg: response.message ?? "")
            }).store(in: &cancellables)
    }
    
    @MainActor
    func deleteAccount() {
        
        let requestParams = APIRequestParams(
            endpoint: .deleteAccount,
            methodType: .put,
            contentType: .json
        )
        
        RemoteRequestManager.shared.dataTask(type: AuthModel.self, requestParams: requestParams)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case .errorMessage(let err):
                        self?.requestResponse = .failure(err)
                    default: break
                    }
                default: break
                }
            }, receiveValue: { [weak self] response in
                UserDefaults.standard.clearAllLocallySavedData()
                self?.requestResponse = .success(for: .deleteAccount)
            }).store(in: &cancellables)
    }
    
    @MainActor
    func updateCustomers(anotherUserID: String) {
        
        let requestParams = APIRequestParams(
            endpoint: .updateCustomers,
            methodType: .put,
            contentType: .json,
            remoteRequestTail: anotherUserID
        )
        
        RemoteRequestManager.shared.dataTask(type: AuthModel.self, requestParams: requestParams)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case .errorMessage(let err):
                        self?.requestResponse = .failure(err)
                    default: break
                    }
                default: break
                }
            }, receiveValue: { [weak self] response in
                self?.requestResponse = .success(for: .updateCustomers, msg: response.message ?? "")
            }).store(in: &cancellables)
    }
    
    @MainActor
    func contactUs(params: [String: Any], fileData: Data?) {
        
        var multipartParams = [MultipartMediaRequestParams]()
        
        if let fileData {
            let timeStamp = Int(Date().timeIntervalSince1970)
            let fileName = "file_\(timeStamp).jpg"
            let params = MultipartMediaRequestParams(filename: fileName,
                                                     data: fileData,
                                                     keyname: .file,
                                                     contentType: .imageJPEG)
            multipartParams.append(params)
        }
        
        let requestParams = APIRequestParams(
            endpoint: .contactUs,
            methodType: .post,
            contentType: .multipartFormData,
            params: params,
            mediaContent: multipartParams
        )
        
        RemoteRequestManager.shared.uploadTask(type: PostModel.self, requestParams: requestParams)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case .errorMessage(let err):
                        self?.requestResponse = .failure(err, request: .event)
                    default:
                        self?.requestResponse = .failure("An unknown error occurred.", request: .event)
                        break
                    }
                default: break
                }
            }, receiveValue: { [weak self] response in
                self?.requestResponse = .success(for: .contactUs, msg: response.message ?? "")
            }).store(in: &cancellables)
    }
    
    @MainActor
    func reshare(id: String) {
        
        let requestParams = APIRequestParams(
            endpoint: .reshare,
            methodType: .put,
            contentType: .json,
            remoteRequestTail: id
        )
        
        RemoteRequestManager.shared.dataTask(type: PostModel.self, requestParams: requestParams)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case .errorMessage(let err):
                        self?.requestResponse = .failure(err)
                    default: break
                    }
                default: break
                }
            }, receiveValue: { [weak self] response in
                self?.requestResponse = .success(for: .reshare, msg: response.message ?? "")
            }).store(in: &cancellables)
    }
    
    @MainActor
    func deletePost(id: String, event: SavedOptions) {
        
        let endpoint: APIEndpoints = event == .share ? .share : event == .stream ? .share : .vault
        
        let requestParams = APIRequestParams(
            endpoint: endpoint,
            methodType: .delete,
            contentType: .json,
            remoteRequestTail: id
        )
        
        RemoteRequestManager.shared.dataTask(type: PostModel.self, requestParams: requestParams)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case .errorMessage(let err):
                        self?.requestResponse = .failure(err)
                    default: break
                    }
                default: break
                }
            }, receiveValue: { [weak self] response in
                self?.updatePostKeyStatus(key: .deletePost, event: event, postID: id)
            }).store(in: &cancellables)
    }
    
    @MainActor
    func getPaymentMethods() {
        
        let requestParams = APIRequestParams(
            endpoint: .getPaymentMethods,
            methodType: .get,
            contentType: .json
        )
        
        RemoteRequestManager.shared.dataTask(type: PaymentCardsModel.self, requestParams: requestParams)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case .errorMessage(let err):
                        self?.requestResponse = .failure(err)
                    default: break
                    }
                default: break
                }
            }, receiveValue: { [weak self] response in
                self?.paymentCards = response.data?.paymentMethods ?? []
            }).store(in: &cancellables)
    }
    
    @MainActor
    func createAds(params: [String: Any], mediaData: Data?) {
        var multipartParams = [MultipartMediaRequestParams]()
        if let mediaData {
            let timeStamp = Int(Date().timeIntervalSince1970)
            let fileName = "image_\(timeStamp).jpg"
            let params = MultipartMediaRequestParams(filename: fileName,
                                                     data: mediaData,
                                                     keyname: .file,
                                                     contentType: .imageJPEG)
            multipartParams.append(params)
        }
        
        let requestParams = APIRequestParams(
            endpoint: .ads,
            methodType: .post,
            contentType: .multipartFormData,
            params: params,
            mediaContent: multipartParams
        )
        
        RemoteRequestManager.shared.uploadTask(type: PostModel.self, requestParams: requestParams)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case .errorMessage(let err):
                        self?.requestResponse = .failure(err)
                    default: break
                    }
                default: break
                }
            }, receiveValue: { [weak self] response in
                self?.requestResponse = .success(msg: response.message ?? "")
            }).store(in: &cancellables)
    }
    
    @MainActor
    func getAds(params: [String: Any], limit: Int) {
        let requestParams = APIRequestParams(
            endpoint: .ads,
            methodType: .get,
            contentType: .json,
            params: params
        )
        
        RemoteRequestManager.shared.dataTask(type: AdsModel.self, requestParams: requestParams)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case .errorMessage(let err):
                        self?.requestResponse = .failure(err)
                    default: break
                    }
                default: break
                }
            }, receiveValue: { [weak self] response in
                let pageNo = params["page"] as? Int ?? 1
                if pageNo == 1 {
                    self?.ads.removeAll()
                }
                
                let newAds = response.data?.ads ?? []
                if newAds.count < limit {
                    self?.isAdsListLastPage = true
                }
                
                var loadedList = self?.ads ?? []
                loadedList.append(contentsOf: newAds)
                self?.ads = loadedList
                self?.isAdsListLoading = false
                //self?.requestResponse = .success()
            }).store(in: &cancellables)
    }
    
    @MainActor
    func getUsers(params: [String: Any], limit: Int) {
        
        var updatedParams = params
        
        updatedParams = params.filter{ !("\($0.value)".isEmpty) }
        
        let requestParams = APIRequestParams(
            endpoint: .getUsers,
            methodType: .get,
            contentType: .json,
            params: updatedParams
        )
        
        RemoteRequestManager.shared.dataTask(type: UsersListModel.self, requestParams: requestParams)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case .errorMessage(let err):
                        self?.requestResponse = .failure(err)
                    default: break
                    }
                default: break
                }
            }, receiveValue: { [weak self] response in
                
                let pageNo = params["page"] as? Int ?? 1
                if pageNo == 1 {
                    self?.usersList.removeAll()
                }
                
                let users = response.data?.users ?? []
                // Check if result is less than limit, meaning we are at the last page
                if users.count < limit {
                    self?.isUsersListLastPage = true
                }
                var loadedList = self?.usersList ?? []
                loadedList.append(contentsOf: users)
                self?.usersList = loadedList
                self?.isUsersListLoading = false
                self?.requestResponse = .success()
            }).store(in: &cancellables)
    }
    
    @MainActor
    func downloadHistory() {
        let requestParams = APIRequestParams(
            endpoint: .downloadHistory,
            methodType: .get,
            contentType: .json
        )
        
        RemoteRequestManager.shared.dataTask(type: PostModel.self, requestParams: requestParams)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case .errorMessage(let err):
                        self?.requestResponse = .failure(err)
                    default: break
                    }
                default: break
                }
            }, receiveValue: { [weak self] response in
                self?.downloadedHistory = response.data?.posts ?? []
            }).store(in: &cancellables)
    }
    
    func validateFields(title: String?,
                        topic: String?,
                        description: String?,
                        symbolValue: String?,
                        image: UIImage? = nil,
                        isSchedule: Bool = false,
                        scheduleDate: String = "",
                        isShare: Bool = false) -> ValidationResult {
        
        guard let title = title, !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            return .failure("Please enter a title.")
        }
        
        guard let topic = topic, !topic.trimmingCharacters(in: .whitespaces).isEmpty else {
            return .failure("Please select a topic.")
        }
        
        guard let description = description, !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .failure("Please enter a description.")
        }
        
        if isShare {
            guard let symbol = symbolValue, !symbol.trimmingCharacters(in: .whitespaces).isEmpty else {
                return .failure("Please enter the symbol value.")
            }
        }
        
        //        guard image != nil else {
        //            return .failure("Please add an image.")
        //        }
        
        if isSchedule && scheduleDate.isEmpty {
            return .failure("Please select a schedule date.")
        }
        
        return .success
    }
    
    @MainActor
    func getUploadedMedia() {
        
        let requestParams = APIRequestParams(
            endpoint: .getUploadedMedia,
            methodType: .get,
            contentType: .json
        )
        
        RemoteRequestManager.shared.dataTask(type: MediaDetails.self, requestParams: requestParams)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case .errorMessage(let err):
                        self?.requestResponse = .failure(err)
                    default: break
                    }
                default: break
                }
            }, receiveValue: { [weak self] response in
                let data = response.data ?? []
                self?.mediaData = data
            }).store(in: &cancellables)
    }
}
