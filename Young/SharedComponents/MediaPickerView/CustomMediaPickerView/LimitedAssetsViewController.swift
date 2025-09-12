//
//  LimitedAssetsViewController.swift
//  WodHopperPhone
//
//  Created by Michael Kloster on 24/11/23.
//  Copyright © 2023 Amagisoft LLC. All rights reserved.
//

import UIKit
import Photos

class LimitedAssetsViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.registerCellFromNib(cellID: LimitedAssetPreviewCell.identifier)
        }
    }
    
    //MARK: Variables
    private var fetchResult: PHFetchResult<PHAsset> = PHFetchResult<PHAsset>()
    public var settings: Settings = Settings()
    private let imageManager = PHCachingImageManager()
    private let durationFormatter = DateComponentsFormatter()
    var selectedAssets = [PHAsset]()
    var selectionLimit: Int = 0
    var previousSelectedIndexPath: IndexPath? = nil
    
    var imageSize: CGSize = .zero {
        didSet {
            imageManager.stopCachingImagesForAllAssets()
        }
    }
    
    lazy var albums: [PHAssetCollection] = {
        let fetchOptions = settings.fetch.assets.options.copy() as! PHFetchOptions
        fetchOptions.fetchLimit = 1
        return settings.fetch.album.fetchResults.filter {
            $0.count > 0
        }.flatMap {
            $0.objects(at: IndexSet(integersIn: 0..<$0.count))
        }.filter {
            let assetsFetchResult = PHAsset.fetchAssets(in: $0, options: fetchOptions)
            return assetsFetchResult.count > 0
        }
    }()
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    //MARK: Controller's Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        durationFormatter.unitsStyle = .positional
        durationFormatter.zeroFormattingBehavior = [.pad]
        durationFormatter.allowedUnits = [.minute, .second]
        // Observe photo library changes
        PHPhotoLibrary.shared().register(self)
        if let album = albums.first {
            showAssets(in: album)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.post(name: .update_media_content_via_limited_assets_vc, object: selectedAssets)
        
        // Usage
//        NotificationCenter.default.addObserver(self, selector: #selector(updateMediaContentViaLimitedAssetsVC(_:)),
//                                               name: .updateMediaContentViaLimitedAssetsVC,
//                                               object: nil)
//        
//        @objc func updateMediaContentViaLimitedAssetsVC(_ notify: NSNotification) {
//            if let selectedAssets = notify.object as? [PHAsset], selectedAssets.count > 0 {
//                var count = 1
//                for asset in selectedAssets {
//                    if let _ = MediaPicker.toImage(asset: asset) {
//                        asset.getURL { responseURL in
//                            if let responseURL {
//                                self.mediaAttachmentURL.append(responseURL)
//                            }
//                            if count == selectedAssets.count {
//                                DispatchQueue.main.async {
//                                    self.collectionView.reloadData()
//                                    self.hideShowCollectionView()
//                                }
//                            }
//                            count += 1
//                        }
//                    }
//                }
//            }
//        }
    }
    
    @IBAction func tappedManage(_ sender: Any) {
        let actionSheet = UIAlertController(title: "",
                                            message: "Select more photos or go to Settings to allow access to all photos.",
                                            preferredStyle: .actionSheet)
        
        let selectPhotosAction = UIAlertAction(title: "Select more photos",
                                               style: .default) { [unowned self] (_) in
            // Show limited library picker
            PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
        }
        actionSheet.addAction(selectPhotosAction)
        
        let allowFullAccessAction = UIAlertAction(title: "Allow access to all photos",
                                                  style: .default) { [unowned self] (_) in
            // Open app privacy settings
            self.gotoAppPrivacySettings()
        }
        actionSheet.addAction(allowFullAccessAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)
        present(actionSheet, animated: true, completion: nil)
    }
    
    func showAssets(in album: PHAssetCollection) {
        fetchResult = PHAsset.fetchAssets(in: album, options: settings.fetch.assets.options)
        collectionView.reloadData()
        collectionView.setContentOffset(.zero, animated: false)
    }
    
    fileprivate func gotoAppPrivacySettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else {
            assertionFailure("Not able to open App privacy settings")
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

//MARK: CollectionView's Delegates and Datasource
extension LimitedAssetsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        fetchResult.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.collectionView.frame.size.width - 10)/2
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LimitedAssetPreviewCell.identifier,
                                                      for: indexPath) as! LimitedAssetPreviewCell
        let asset = fetchResult[indexPath.row]
        
        if asset.mediaType == .video {
            cell.durationLbl.text = durationFormatter.string(from: asset.duration)
        } else {
            cell.durationLbl.text = ""
        }
        
        loadMediaFromAsset(for: asset, in: cell)
        
        if selectedAssets.contains(asset) {
            cell.selectUnselectIcon.image = UIImage(systemName: "checkmark.circle.fill")
        } else {
            cell.selectUnselectIcon.image = UIImage(systemName: "circle")
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectionLimit == 1 {
            selectedAssets.removeAll()
            if let previousSelectedIndexPath {
                self.collectionView.reloadItems(at: [previousSelectedIndexPath])
            }
        }
        previousSelectedIndexPath = indexPath
        let asset = fetchResult[indexPath.row]
        if selectedAssets.contains(asset) {
            if let indexValue = selectedAssets.firstIndex(of: asset) {
                selectedAssets.remove(at: indexValue)
            }
        } else {
            selectedAssets.append(asset)
        }
        self.collectionView.layer.removeAllAnimations()
        self.collectionView.reloadItems(at: [indexPath])
    }
    
    private func loadMediaFromAsset(for asset: PHAsset, in cell: LimitedAssetPreviewCell) {
        // Cancel any pending image requests
        if cell.tag != 0 {
            imageManager.cancelImageRequest(PHImageRequestID(cell.tag))
        }
        
        // Request image
        cell.tag = Int(imageManager.requestImage(for: asset,
                                                 targetSize: imageSize,
                                                 contentMode: .aspectFill,
                                                 options: settings.fetch.preview.photoOptions) { (image, _) in
            guard let image = image else { return }
            cell.thumbnail.image = image
        })
    }
}

extension LimitedAssetsViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let assets = indexPaths.map { fetchResult[$0.row] }
        imageManager.startCachingImages(for: assets, targetSize: imageSize, contentMode: .aspectFill, options: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) { }
}

extension LimitedAssetsViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let changes = changeInstance.changeDetails(for: fetchResult) else { return }
        // Since we are gonna update UI, make sure we are on main
        DispatchQueue.main.async {
            if changes.hasIncrementalChanges {
                self.collectionView.performBatchUpdates({
                    self.fetchResult = changes.fetchResultAfterChanges
                    
                    // For indexes to make sense, updates must be in this order:
                    // delete, insert, move
                    if let removed = changes.removedIndexes, removed.count > 0 {
                        let removedItems = removed.map { IndexPath(item: $0, section:0) }
                        let removedSelections = self.collectionView.indexPathsForSelectedItems?.filter { return removedItems.contains($0) }
                        removedSelections?.forEach {
                            // TODO: Remove asset
                            _ = changes.fetchResultBeforeChanges.object(at: $0.row)
                        }
                        self.collectionView.deleteItems(at: removedItems)
                    }
                    if let inserted = changes.insertedIndexes, inserted.count > 0 {
                        self.collectionView.insertItems(at: inserted.map { IndexPath(item: $0, section:0) })
                    }
                    changes.enumerateMoves { fromIndex, toIndex in
                        self.collectionView.moveItem(at: IndexPath(item: fromIndex, section: 0),
                                                     to: IndexPath(item: toIndex, section: 0))
                    }
                })
                
                // "Use these indices to reconfigure the corresponding cells after performBatchUpdates"
                // https://developer.apple.com/documentation/photokit/phobjectchangedetails
                if let changed = changes.changedIndexes, changed.count > 0 {
                    self.collectionView.reloadItems(at: changed.map { IndexPath(item: $0, section:0) })
                }
            } else {
                self.fetchResult = changes.fetchResultAfterChanges
                self.collectionView.reloadData()
            }
        }
    }
}
