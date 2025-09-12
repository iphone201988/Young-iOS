import UIKit
import LinkPresentation

class CustomMovieActivityItemSource: NSObject, UIActivityItemSource {
    let title: String
    let desc: String
    let url: URL
    let image: UIImage?
    
    init(title: String, description: String, url: URL, image: UIImage?) {
        self.title = title
        self.desc = description
        self.url = url
        self.image = image
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return url
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        // Return different content based on the sharing destination
        switch activityType {
        case .message, .mail:
            return "\(title)\n\n\(desc)\n\n\(url.absoluteString)"
        default:
            return url
        }
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return title
    }
    
    @available(iOS 13.0, *)
    func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.originalURL = url
        metadata.url = url
        metadata.title = title
        
        if let image = image {
            metadata.imageProvider = NSItemProvider(object: image)
        }
        
        return metadata
    }
}
