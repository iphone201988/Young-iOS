import UIKit
import Photos

@objcMembers public class Settings : NSObject {
    public static let shared = Settings()
    
    @objcMembers public class Fetch : NSObject {
        
        @objcMembers public class Album : NSObject {
            /// Fetch options for albums/collections
            public lazy var options: PHFetchOptions = {
                let fetchOptions = PHFetchOptions()
                return fetchOptions
            }()
            
            /// Fetch results for asset collections you want to present to the user
            /// Some other fetch results that you might wanna use:
            ///                PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumFavorites, options: options),
            ///                PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: options),
            ///                PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumSelfPortraits, options: options),
            ///                PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumPanoramas, options: options),
            ///                PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumVideos, options: options),
            public lazy var fetchResults: [PHFetchResult<PHAssetCollection>] = [
                PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: options),
            ]
        }
        
        @objcMembers public class Assets : NSObject {
            /// Fetch options for assets
            
            /// Simple wrapper around PHAssetMediaType to ensure we only expose the supported types.
            public enum MediaTypes {
                case image
                case video
                
                fileprivate var assetMediaType: PHAssetMediaType {
                    switch self {
                    case .image:
                        return .image
                    case .video:
                        return .video
                    }
                }
            }
            public lazy var supportedMediaTypes: Set<MediaTypes> = [.image]
            
            public lazy var options: PHFetchOptions = {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [
                    NSSortDescriptor(key: "creationDate", ascending: false)
                ]
                
                let rawMediaTypes = supportedMediaTypes.map { $0.assetMediaType.rawValue }
                let predicate = NSPredicate(format: "mediaType IN %@", rawMediaTypes)
                fetchOptions.predicate = predicate
                
                return fetchOptions
            }()
        }
        
        public class Preview : NSObject {
            public lazy var photoOptions: PHImageRequestOptions = {
                let options = PHImageRequestOptions()
                options.isNetworkAccessAllowed = true
                
                return options
            }()
            
            public lazy var livePhotoOptions: PHLivePhotoRequestOptions = {
                let options = PHLivePhotoRequestOptions()
                options.isNetworkAccessAllowed = true
                return options
            }()
            
            public lazy var videoOptions: PHVideoRequestOptions = {
                let options = PHVideoRequestOptions()
                options.isNetworkAccessAllowed = true
                return options
            }()
        }
        
        /// Album fetch settings
        public lazy var album = Album()
        
        /// Asset fetch settings
        public lazy var assets = Assets()
        
        /// Preview fetch settings
        public lazy var preview = Preview()
    }
    
    /// Fetch settings
    public lazy var fetch = Fetch()
}
