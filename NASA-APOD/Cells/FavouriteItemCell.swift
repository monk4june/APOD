//
//  FavouriteItemCell.swift
//  NASA-APOD
//
//

import UIKit

class FavouriteItemCell: UITableViewCell {
    //MARK: - Outlets

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var mediaImageView: UIImageView!

    //MARK: - Properties

    static let identifier = "\(FavouriteItemCell.self)"
    var onRemovePressed: ExecutionHandler?

    //MARK: - UITableViewCell

    override func prepareForReuse() {
        super.prepareForReuse()
        dateLabel.text = nil
        titleLabel.text = nil
        mediaImageView.image = nil
    }

    //MARK: - Actions

    @IBAction func removeButtonPressed(sender: UIButton) {
        onRemovePressed?()
    }
}
