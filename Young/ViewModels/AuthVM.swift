import Foundation
import Combine
import UIKit

final class AuthVM: ObservableObject {
    
    // MARK: Published Variables -
    @Published var sendOTPResp: AuthModel?
    @Published var validatedData: Validator?
    @Published var requestResponse = RequestResponse()
    @Published var fieldsValidationStatus = ValidationStatus()
    
    // MARK: Shared Variables -
    var cancellables = Set<AnyCancellable>()
    
    // MARK: deinit -
    deinit{ cancellables.forEach { $0.cancel() } }
}

extension AuthVM {
    
    func validateFieldsValue(firstName: String? = nil,
                             lastName: String? = nil,
                             username: String? = nil,
                             email: String? = nil,
                             phoneNumber: String? = nil,
                             password: String? = nil,
                             confirmPassword: String? = nil) {
        do {
            validatedData = try Validator(firstName: firstName,
                                          lastName: lastName,
                                          username: username,
                                          email: email,
                                          phoneNumber: phoneNumber,
                                          password: password,
                                          confirmPassword: confirmPassword)
            fieldsValidationStatus = .valid()
        } catch let error as ValidationError  {
            if let errMessage = error.validationErrorData.errMessage {
                fieldsValidationStatus = .invalid(errMessage, type: error.validationErrorData.errType)
            }
        } catch {}
    }
    
    @MainActor
    func login() {
        
        LoaderUtil.shared.showLoading()
        
        var params = [String: Any]()
        params = [
            "username": validatedData?.username ?? "",
            "email": validatedData?.email ?? "",
            "password": validatedData?.password ?? "",
            "deviceToken": UserDefaults.standard[.deviceToken] ?? "",
            "deviceType": Constants.deviceType,
            "latitude": CurrentLocation.latitude,
            "longitude": CurrentLocation.longitude
        ]
        
        params = params.filter{ !("\($0.value)".isEmpty) }
        
        let requestParams = APIRequestParams(
            endpoint: .login,
            methodType: .post,
            contentType: .json,
            params: params
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
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    LoaderUtil.shared.hideLoading()
                }
                
            }, receiveValue: { [weak self] response in
                if let data = response.data {
                    UserDefaults.standard[.loggedUserDetails] = data
                    UserDefaults.standard[.qrCodeUrl] = data.qrCodeUrl
                    UserDefaults.standard[.secret] = data.secret
                }
                self?.requestResponse = .success()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    LoaderUtil.shared.hideLoading()
                }
            }).store(in: &cancellables)
    }
    
    @MainActor
    func register(params: [String: Any]) {
        
        var updatedParams = params
        updatedParams["latitude"] = CurrentLocation.latitude
        updatedParams["longitude"] = CurrentLocation.longitude
        updatedParams = params.filter{ !("\($0.value)".isEmpty) }
        
        let requestParams = APIRequestParams(
            endpoint: .register,
            methodType: .post,
            contentType: .json,
            params: updatedParams
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
                if let data = response.data {
                    UserDefaults.standard[.loggedUserDetails] = data
                }
                self?.requestResponse = .success()
            }).store(in: &cancellables)
    }
    
    @MainActor
    func completeRegistration(params: [String: Any]) {
        
        var updatedParams = [String: Any]()
        updatedParams = params.filter{ !("\($0.value)".isEmpty) }
        
        updatedParams["userId"] = UserDefaults.standard[.loggedUserDetails]?._id ?? ""
        updatedParams["role"] = UserDefaults.standard[.loggedUserDetails]?.role ?? ""
        
        var multipartParams = [MultipartMediaRequestParams]()
        
//        if let profileImageData = updatedParams["profileImage"] as? Data {
//            let timeStamp = Int(Date().timeIntervalSince1970)
//            let fileName = "profileImage_\(timeStamp).jpg"
//            let params = MultipartMediaRequestParams(filename: fileName,
//                                                              data: profileImageData,
//                                                              keyname: .profileImage,
//                                                              contentType: .imageJPEG)
//            multipartParams.append(params)
//        }
//        
//        if let additionalPhotos = updatedParams["additionalPhotos"] as? [UIImage] {
//            for (index, photo) in additionalPhotos.enumerated() {
//                if photo != UIImage(),
//                    let data = photo.jpegData(compressionQuality: 0.1) {
//                    let timeStamp = Int(Date().timeIntervalSince1970)
//                    let fileName = "additionalPhotos_\(index)_\(timeStamp).jpg"
//                    let params = MultipartMediaRequestParams(filename: fileName,
//                                                                      data: data,
//                                                                      keyname: .additionalPhotos,
//                                                                      contentType: .imageJPEG)
//                    multipartParams.append(params)
//                }
//            }
//        }

        updatedParams["licenseImage"] = nil
        updatedParams["profileImage"] = nil
        updatedParams["additionalPhotos"] = nil
        
        let requestParams = APIRequestParams(
            endpoint: .completeRegistration,
            methodType: .put,
            contentType: .multipartFormData,
            params: updatedParams,
            mediaContent: multipartParams
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
                if let data = response.data {
                    UserDefaults.standard[.loggedUserDetails] = data
                    UserDefaults.standard[.qrCodeUrl] = data.qrCodeUrl
                    UserDefaults.standard[.secret] = data.secret
                }
                self?.requestResponse = .success()
            }).store(in: &cancellables)
    }

    @MainActor
    func verifyOtp(for event: OTPFor, otp: String, userID: String) {
        
        var params = ["userId": userID, "otp": otp, "type": event.rawValue]
        
        params = params.filter{ !("\($0.value)".isEmpty) }
        
        let requestParams = APIRequestParams(
            endpoint: .verifyOtp,
            methodType: .put,
            contentType: .json,
            params: params
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
                self?.requestResponse = .success(for: .verifyOtp)
            }).store(in: &cancellables)
    }
    
    @MainActor
    func sendOtp(for event: OTPFor, email: String) {
        
        var params = ["email": email, "type": event.rawValue]
        
        params = params.filter{ !("\($0.value)".isEmpty) }
        
        let requestParams = APIRequestParams(
            endpoint: .sendOtp,
            methodType: .put,
            contentType: .json,
            params: params
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
                self?.sendOTPResp = response
                self?.requestResponse = .success(for: .sendOtp)
            }).store(in: &cancellables)
    }
    
    @MainActor
    func verify2FA(userId: String, otp: String) {
        
        LoaderUtil.shared.showLoading()
        
        var params = ["userId": userId, "otp": otp]
        
        params = params.filter{ !("\($0.value)".isEmpty) }
        
        let requestParams = APIRequestParams(
            endpoint: .verify2FA,
            methodType: .put,
            contentType: .json,
            params: params
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
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    LoaderUtil.shared.hideLoading()
                }
                
            }, receiveValue: { [weak self] response in
                UserDefaults.standard[.accessToken] = response.data?.token ?? ""
                UserDefaults.standard[.loggedUserDetails]?.name = response.data?.name ?? ""
                UserDefaults.standard[.loggedUserDetails]?.role = response.data?.role ?? ""
                self?.requestResponse = .success(for: .verify2FA)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    LoaderUtil.shared.hideLoading()
                }
                
            }).store(in: &cancellables)
    }
    
    @MainActor
    func changePassword(userID: String, password: String) {
        var params = [String: Any]()
        params = ["userId": userID, "password": password]
        params = params.filter{ !("\($0.value)".isEmpty) }
        let requestParams = APIRequestParams(
            endpoint: .changePassword,
            methodType: .put,
            contentType: .json,
            params: params
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
                self?.requestResponse = .success()
            }).store(in: &cancellables)
    }
    
    @MainActor
    func updatePassword(params: [String: Any]) {
        let requestParams = APIRequestParams(
            endpoint: .resetPassword,
            methodType: .put,
            contentType: .json,
            params: params
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
                self?.requestResponse = .success(msg: response.message ?? "")
            }).store(in: &cancellables)
    }
}
