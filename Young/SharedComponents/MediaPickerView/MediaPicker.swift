
import Foundation
import UIKit
import AVKit
import AVFoundation
import Photos
import MobileCoreServices
import PhotosUI

//MARK:- MEDIA PICKER CLASS
public class MediaPicker : NSObject {
    
    static let shared = MediaPicker()
    fileprivate var currentVC: UIViewController?
    fileprivate var isFrontCameraDefault: Bool?
    static var cameraPosition: CameraPosition?
    static var cameraComponents: CameraComponents?
    static var attachmentContent: AttachmentType?
    static var galleryComponents: GalleryComponents?
    static var myPickerController = UIImagePickerController()
    static var movieIdentifier = UTType.movie.identifier
    static var imageIdentifier = UTType.image.identifier
    static var selectedAssets: (([PHAsset]) -> Void)?
    static var selectionLimit: Int = 0
    static var IsVideoAttachmentEnable: Bool = false
    
    //MARK: - INTERNAL PROPERTIES
    public var imagePickedBlock: ((UIImage) -> Void)?
    public var filePickedBlock: ((URL) -> Void)?
    public var capturedMediaFromCameraBlock: ((URL, UIImage) -> Void)?
    
    //MARK:- ENUM ATTACHMENT TYPE FOR THIS CLASS
    public enum AttachmentType: String {
        case camera, photoLibrary, bothMedia
    }
    
    //MARK:- ENUM CAMERA COMPONENTS
    public enum CameraComponents: String {
        case onlyImageCamera, onlyVideoCamera
    }
    
    public enum GalleryComponents: String {
        case onlyImage, onlyVideo
    }
    
    //MARK:- ENUM CAMERA POSITION
    public enum CameraPosition: String {
        case frontCamera, backCamera
    }
    
    //MARK:- ENUM FILE EXTENSION
    public enum FileExtension: String {
        case image = ".jpg"
        case video = ".mov"
    }
    
    //MARK:- CLASS CONSTANTS
    struct Constants {
        static let actionFileTypeHeading = "Choose File"
        static let actionFileTypeDescription = ""
        static let camera = "Camera"
        static let phoneLibrary = "Photo Library"
        static let settingsBtnTitle = "Settings"
        static let cancelBtnTitle = "Cancel"
    }
    
    //MARK: - SHOW CAMERA ON A BUTTON ACTION
    public func showCamera(_ vc: UIViewController) {
        currentVC = vc
        self.askForCameraPermission()
    }
    
    //MARK: - SHOW ATTACHMENT ACTION SHEET FOR VARIOUS OPTIONS
    // This function is used to show the attachment sheet for image, video, photo and file.
    public func showAttachmentActionSheet(_ vc: UIViewController) {
        currentVC = vc
        let actionSheet = UIAlertController(title: Constants.actionFileTypeHeading, message: Constants.actionFileTypeDescription, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: Constants.camera, style: .default, handler: { (action) -> Void in
            self.askForCameraPermission()
        }))
        
        actionSheet.addAction(UIAlertAction(title: Constants.phoneLibrary, style: .default, handler: { (action) -> Void in
            self.askForPhotoLibraryPermission()
        }))
        
        actionSheet.addAction(UIAlertAction(title: Constants.cancelBtnTitle, style: .cancel, handler: nil))
        
        //BELOW FUNCTIONALITY HANDLE ACTION SHEET FOR IPAD AS ACTION SHEET WILL NOT WORK FOR IPAD
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = vc.view //to set the source of your alert
            popoverController.sourceRect = CGRect(x: vc.view.bounds.midX, y: vc.view.frame.size.height, width: 0, height: 0)
            // you can set this as per your requirement.
            popoverController.permittedArrowDirections = [] //to hide the arrow of any particular direction
        }
        vc.present(actionSheet, animated: true, completion: nil)
    }
    
    // Request permission to access camera
    func askForCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized: openCamera()
        case .denied: showAlertWhenPermissionDenied()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
                if response {
                    //access granted
                    self.openCamera()
                } else {
                    self.showAlertWhenPermissionDenied()
                }
            }
        case .restricted: showAlertWhenPermissionDenied()
        default: break
        }
    }
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            DispatchQueue.main.async { self.mediaPickerSetup(sourceType: .camera) }
        } else {
            Toast.show(message: "Camera Not Available")
        }
    }
    
    // Request permission to access photo library
    func askForPhotoLibraryPermission() {
        if #available(iOS 14.0, *) {
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            switch status {
            case .authorized: openPhotoLibrary()
                
            case .denied: showAlertWhenPermissionDenied()
                
            case .limited:
                DispatchQueue.main.async {
                    let destVC = self.currentVC?.storyboard?.instantiateViewController(withIdentifier: "LimitedAssetsViewController") as! LimitedAssetsViewController
                    if MediaPicker.IsVideoAttachmentEnable {
                        destVC.settings.fetch.assets.supportedMediaTypes = [.image, .video]
                    } else {
                        destVC.settings.fetch.assets.supportedMediaTypes = [.image]
                    }
                    destVC.selectionLimit = MediaPicker.selectionLimit
                    self.currentVC?.navigationController?.pushViewController(destVC, animated: true)
                }
                
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                    switch status {
                    case .authorized:
                        self.openPhotoLibrary()
                        
                    case .limited:
                        DispatchQueue.main.async {
                            let destVC = self.currentVC?.storyboard?.instantiateViewController(withIdentifier: "LimitedAssetsViewController") as! LimitedAssetsViewController
                            if MediaPicker.IsVideoAttachmentEnable {
                                destVC.settings.fetch.assets.supportedMediaTypes = [.image, .video]
                            } else {
                                destVC.settings.fetch.assets.supportedMediaTypes = [.image]
                            }
                            destVC.selectionLimit = MediaPicker.selectionLimit
                            self.currentVC?.navigationController?.pushViewController(destVC, animated: true)
                        }
                        
                    default: self.showAlertWhenPermissionDenied()
                    }
                }
            case .restricted: showAlertWhenPermissionDenied()
            default: break
            }
        } else {
            // Fallback call
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                DispatchQueue.main.async { self.mediaPickerSetup(sourceType: .photoLibrary) }
            }
        }
    }
    
    func openPhotoLibrary() {
        DispatchQueue.main.async {
            var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
            config.selectionLimit = MediaPicker.selectionLimit
            if MediaPicker.IsVideoAttachmentEnable {
                
            } else {
                config.filter = .images
            }
            let picker = PHPickerViewController(configuration: config)
            picker.delegate = self
            self.currentVC?.present(picker, animated: true, completion: nil)
        }
    }
    
    func showAlertWhenPermissionDenied() {
        showAlert(title: "Alert", message: "Permission Denied , Please Provide Permission From iPhone's Settings")
    }
    
    //MARK: - Alert For Class usage
    public func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.default, handler: nil))
            self.currentVC?.present(alert , animated: true, completion: nil)
        }
    }
    
    fileprivate func mediaPickerSetup(sourceType: UIImagePickerController.SourceType) {
        MediaPicker.myPickerController.delegate = self
        MediaPicker.myPickerController.sourceType = sourceType
        MediaPicker.myPickerController.allowsEditing = true
        MediaPicker.myPickerController.showsCameraControls = true
        MediaPicker.myPickerController.cameraDevice = UIImagePickerController.isCameraDeviceAvailable(.front) ? .front : .rear
        
        if MediaPicker.galleryComponents == .onlyVideo || MediaPicker.cameraComponents == .onlyVideoCamera {
            MediaPicker.myPickerController.mediaTypes = [UTType.movie.identifier] as [String]
            
        } else if MediaPicker.galleryComponents == .onlyImage || MediaPicker.cameraComponents == .onlyImageCamera {
            MediaPicker.myPickerController.mediaTypes = [UTType.image.identifier] as [String]
            
        } else {
            if MediaPicker.IsVideoAttachmentEnable {
                MediaPicker.myPickerController.mediaTypes = [UTType.movie.identifier, UTType.image.identifier] as [String]
            } else {
                MediaPicker.myPickerController.mediaTypes = [UTType.image.identifier] as [String]
            }
        }
        
        self.currentVC?.present(MediaPicker.myPickerController, animated: true, completion: nil)
    }
}

//MARK:- DELETGATE METHOD FOR MEDIA PICKER
extension MediaPicker: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK:- CANCELLING THE MEDIA PICKER
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { currentVC?.dismiss(animated: true, completion: nil) }
    
    //MARK:- PICKING IMAGE
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        currentVC?.dismiss(animated: true, completion: {
            
            var pickerImage:UIImage?
            
            if let image = info[UIImagePickerController.InfoKey.editedImage ] as? UIImage {
                self.imagePickedBlock?(image.fixedOrientation())
                pickerImage = image.fixedOrientation()
            }
            
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                self.imagePickedBlock?(image.fixedOrientation())
                pickerImage = image.fixedOrientation()
            }
            
            if let mediaUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
                self.filePickedBlock?(mediaUrl)
                self.handleCapturedMediaContentFromCamera(mediaUrl: mediaUrl, capturedImage: nil)
            }
            
            if let mediaUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL {
                self.filePickedBlock?(mediaUrl)
            }
            
            if info[UIImagePickerController.InfoKey.imageURL] == nil && info[UIImagePickerController.InfoKey.mediaURL] == nil {
                guard let capturedImage = pickerImage, let imageData = capturedImage.pngData() else { return }
                self.saveDataInDocumentDirectory(data: imageData, fileExtension: FileExtension.image.rawValue) { fileURL in
                    if let fileURL {
                        self.filePickedBlock?(fileURL)
                        self.handleCapturedMediaContentFromCamera(mediaUrl: fileURL, capturedImage: capturedImage)
                    }
                }
            }
        })
    }
    
    func handleCapturedMediaContentFromCamera(mediaUrl: URL, capturedImage: UIImage?) {
        if mediaUrl.isImageFile {
            self.capturedMediaFromCameraBlock?(mediaUrl, capturedImage ?? UIImage())
        } else {
            let imgView = UIImageView()
            imgView.generateVideoThumbnail(videoURL: mediaUrl) { thumbnail in
                self.capturedMediaFromCameraBlock?(mediaUrl, thumbnail ?? UIImage())
            }
        }
    }
    
    public func saveDataInDocumentDirectory(data: Data, fileExtension: String, completion: @escaping (_ fileURL: URL?) -> Void) {
        DispatchQueue.global().async {
            if let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let currentTimeStamp = NSDate().timeIntervalSince1970.toString()
                let fileURL = documentDirectoryURL.appendingPathComponent("\(currentTimeStamp)\(fileExtension)")
                try? data.write(to: fileURL, options: .atomic)
                DispatchQueue.main.async {
                    completion(fileURL)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
    
    func browsedImage(completion: @escaping (_ image: UIImage, _ imageURL: URL?) -> Void) {
        DispatchQueue.main.async {
            //MediaPicker.cameraComponents = .onlyImageCamera
            MediaPicker.selectionLimit = 1
            guard let rootViewController = getWindowRootViewController() else { return }
            guard let topController = getTopViewController(from: rootViewController) else { return }
            MediaPicker.shared.showAttachmentActionSheet(topController)
            if #available(iOS 14.0, *) {
                MediaPicker.selectedAssets = { phAssets in
                    for asset in phAssets {
                        if let image = MediaPicker.toImage(asset: asset) {
                            asset.getURL { responseURL in
                                completion(image, responseURL)
                            }
                        }
                    }
                }
                
                MediaPicker.shared.capturedMediaFromCameraBlock = { mediaURL, capturedImage in
                    completion(capturedImage, mediaURL)
                }
            } else {
                // Fallback call
                MediaPicker.shared.imagePickedBlock = { image in
                    MediaPicker.shared.filePickedBlock = { mediaURL in
                        completion(image, mediaURL)
                    }
                }
            }
        }
    }
}

@available(iOS 14, *)
extension MediaPicker: PHPickerViewControllerDelegate {
    
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        let dispatchGroup = DispatchGroup()
        var assets: [PHAsset] = []
        let identifiers = results.compactMap(\.assetIdentifier)
        for id in identifiers {
            dispatchGroup.enter()
            let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil)
            if let result = fetchResult.firstObject {
                assets.append(result)
            }
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main, execute: {
            MediaPicker.selectedAssets?(assets)
        })
    }
    
    static func toImage(asset: PHAsset) -> UIImage? {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = true
        var result: UIImage? = nil
        manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: options, resultHandler: { (image, _) in
            if let selectedImage = image {
                result = selectedImage
            }
        })
        return result
    }
    
    static func humanReadableSizeValue(_ sizeOnDisk: Int64) -> String {
        let byteCountFormatter = ByteCountFormatter()
        byteCountFormatter.allowedUnits = [.useMB]
        byteCountFormatter.countStyle = .file
        return (byteCountFormatter.string(fromByteCount: sizeOnDisk))
    }
}

extension PHAsset {
    func getURL(completion: @escaping ((_ responseURL : URL?) -> Void)) {
        if self.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return false
            }
            self.requestContentEditingInput(with: options,
                                            completionHandler: {(contentEditingInput: PHContentEditingInput?,
                                                                 info: [AnyHashable : Any]) -> Void in
                // Nil value cause crash, that's why implement if let {...} closure
                if let asset = contentEditingInput {
                    completion(asset.fullSizeImageURL)
                } else {
                    completion(nil)
                }
            })
        } else if self.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: self,
                                                    options: options,
                                                    resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl: URL = urlAsset.url as URL
                    completion(localVideoUrl)
                } else {
                    completion(nil)
                }
            })
        }
    }
    
    func getPHAssetSize() -> (String, Int64) {
        let byteCountFormatter = ByteCountFormatter()
        let resources = PHAssetResource.assetResources(for: self)
        guard
            let resource = resources.first,
            let unsignedInt64 = resource.value(forKey: "fileSize") as? CLong else {
            return ("Unknown", 0)
        }
        let sizeOnDisk = Int64(bitPattern: UInt64(unsignedInt64))
        byteCountFormatter.allowedUnits = [.useMB]
        byteCountFormatter.countStyle = .file
        return (byteCountFormatter.string(fromByteCount: sizeOnDisk), sizeOnDisk)
    }
}
