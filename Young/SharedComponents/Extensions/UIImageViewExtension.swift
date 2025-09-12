import Foundation
import  UIKit
import AVFoundation

extension UIImageView {
    // Generate Video Thumbnail
    final func generateVideoThumbnail(videoURL: URL, completion: @escaping ((_ image: UIImage?) ->Void)) {
        DispatchQueue.global().async {
            let asset = AVAsset(url: videoURL)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            var time = asset.duration
            time.value = min(time.value, 2)
            var image: UIImage?
            do {
                let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                image = UIImage(cgImage: cgImage)
            } catch { DispatchQueue.main.async { completion(nil) } }
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
}

