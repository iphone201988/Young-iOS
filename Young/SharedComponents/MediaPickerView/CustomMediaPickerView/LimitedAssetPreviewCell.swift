//
//  LimitedAssetPreviewCell.swift
//  WodHopperPhone
//
//  Created by Michael Kloster on 24/11/23.
//  Copyright © 2023 Amagisoft LLC. All rights reserved.
//

import UIKit

class LimitedAssetPreviewCell: UICollectionViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var selectUnselectIcon: UIImageView!
    
    //MARK: Variables
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    //MARK: Controller's Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
