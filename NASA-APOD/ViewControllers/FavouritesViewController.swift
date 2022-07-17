//
//  FavouritesViewController.swift
//  NASA-APOD
//
//

import UIKit
import CoreData

class FavouritesViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Properties
    
    var favouriteItems = [MediaItem]()
    let coreDataService = CoreDateService()
    let imageCache = ImageCache.shared
    var lastSelectedIndexPath: IndexPath?
    
    //MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        updateView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateView()
    }
    
    //MARK: - Functions
    
    private func setupView() {
        tableView.register(UINib(nibName: FavouriteItemCell.identifier, bundle: nil),
                           forCellReuseIdentifier: FavouriteItemCell.identifier)
    }
    
    private func updateView() {
        favouriteItems = coreDataService.fetchFavouriteMediaItems()
        tableView.reloadData()
    }
    
    private func removeFavourite(item: MediaItem) {
        coreDataService.toggleFavouriteMediaItem(item)
        updateView()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMediaDetail" {
            guard
                let mediaDetailViewController = segue.destination as? MediaDetailViewController,
                let indexPath = lastSelectedIndexPath,
                favouriteItems.count > indexPath.row
            else {
                return
            }
            let item = favouriteItems[indexPath.row]
            mediaDetailViewController.cachedMediaItem = item
            guard let mediaItem = item.toModel() else { return }
            mediaDetailViewController.mediaItem = mediaItem
        }
    }
}

// MARK: - UITableViewDataSource
extension FavouritesViewController: UITableViewDataSource {
    //MARK: - Functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favouriteItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FavouriteItemCell.identifier, for: indexPath) as? FavouriteItemCell else {
            return UITableViewCell()
        }
        guard favouriteItems.count > indexPath.row else { return UITableViewCell() }
        let item = favouriteItems[indexPath.row]
        guard let date = DateFormatters.service.date(from: item.date) else { return UITableViewCell() }
        let dateText = DateFormatters.userInterface.string(from: date)
        cell.dateLabel.text = dateText
        cell.titleLabel.text = item.title
        cell.onRemovePressed = { [weak self] in
            self?.removeFavourite(item: item)
        }
        guard let mediaItem = item.toModel() else { return cell }
        imageCache.fetchMediaImage(media: mediaItem, quality: .regular) { image, error in
            if let image = image {
                DispatchQueue.main.async {
                    cell.mediaImageView.image = image
                }
            }
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension FavouritesViewController: UITableViewDelegate {
    //MARK: - Functions
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        lastSelectedIndexPath = indexPath
        performSegue(withIdentifier: "showMediaDetail", sender: self)
    }
}
