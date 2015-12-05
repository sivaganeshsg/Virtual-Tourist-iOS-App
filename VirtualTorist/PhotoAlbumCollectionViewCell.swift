//
//  PhotoAlbumCollectionViewCell.swift
//  VirtualTorist
//
//  Created by Siva Ganesh on 28/11/15.
//  Copyright © 2015 Siva Ganesh. All rights reserved.
//

import UIKit

class PhotoAlbumCollectionViewCell: UICollectionViewCell {
 
    @IBOutlet weak var urlLabel: UILabel!
    
    @IBOutlet weak var albumImage: UIImageView!
    
    @IBOutlet weak var imageLoadingIndicator: UIActivityIndicatorView!
}
