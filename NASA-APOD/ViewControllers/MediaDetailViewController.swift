//
//  MediaDetailViewController.swift
//  NASA-APOD
//
//

import CoreData
import UIKit

class MediaDetailViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var explanationLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var favouriteButton: UIButton!

    //MARK: - Properties

    let imageCache = ImageCache.shared
    let coreDataService = CoreDateService()
    var mediaItem: APODMediaItem?
    var cachedMediaItem: MediaItem?

    //MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        reset()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let mediaItem = mediaItem {
            cachedMediaItem = coreDataService.fetchMediaItem(forDate: mediaItem.date)
            updateView(mediaItem: mediaItem)
        }
    }

    //MARK: - Functions

    func reset() {
        self.title = nil
        dateLabel.text = ""
        titleLabel.text = ""
        explanationLabel.text = ""
        imageView.image = nil
    }

    func updateView(mediaItem: APODMediaItem) {
        guard let date = DateFormatters.service.date(from: mediaItem.date) else { return }
        let dateText = DateFormatters.userInterface.string(from: date)
        self.navigationItem.title = "A.P.O.D. - \(dateText)"
        self.mediaItem = mediaItem
        dateLabel.text = dateText
        titleLabel.text = mediaItem.title
        explanationLabel.text = mediaItem.explanation
        loadRegularImage(mediaItem: mediaItem)
        updateFavouriteButton(item: cachedMediaItem)
    }

    private func updateFavouriteButton(item: MediaItem?) {
        guard let cachedMediaItem = cachedMediaItem else { return }
        let imageName = cachedMediaItem.isFavourite ? "star.slash.fill" : "star.fill"
        favouriteButton.setTitle(nil, for: .normal)
        favouriteButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    private func loadRegularImage(mediaItem: APODMediaItem) {
        activityIndicatorView.startAnimating()
        imageCache.fetchMediaImage(media: mediaItem, quality: .regular) { [weak self] image, error in
            if let image = image {
                DispatchQueue.main.async {
                    self?.imageView.image = image
                    self?.activityIndicatorView.stopAnimating()
                    self?.loadHDImage(mediaItem: mediaItem)
                }
            }
        }
    }

    private func loadHDImage(mediaItem: APODMediaItem) {
        imageCache.fetchMediaImage(media: mediaItem, quality: .hd) { [weak self] image, error in
            if let image = image {
                DispatchQueue.main.async {
                    self?.imageView.image = image
                }
            }
        }
    }

    //MARK: - Actions

    @IBAction func favouriteButtonPressed(sender: UIButton) {
        guard let mediaItem = cachedMediaItem else { return }
        cachedMediaItem = coreDataService.toggleFavouriteMediaItem(mediaItem)
        updateFavouriteButton(item: cachedMediaItem)
    }
}
