//
//  ViewController.swift
//  NASA-APOD
//
//

import UIKit

class SearchViewController: UIViewController {
    //MARK: - Outlets

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var datePickerView: UIDatePicker!
    @IBOutlet weak var closeDatePickerButtonItem: UIBarButtonItem!
    @IBOutlet weak var searchMediaButtonItem: UIBarButtonItem!
    @IBOutlet weak var dateInputStackView: UIStackView!

    //MARK: - Properties

    let service = APODMediaService()
    let coreDataService = CoreDateService()
    var mediaDetailViewController: MediaDetailViewController?
    let networkReacability = NetworkReachability()
    var lastSelectedDate: String?

    //MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        if let reachability = networkReacability.reachability, reachability.connection != .unavailable {
            loadAPODMedia(date: lastSelectedDate)
        } else if let lastCachedMediaItem = coreDataService.fetchAllMediaItems().first,
                  let item = lastCachedMediaItem.toModel() {
            updateMediaDetail(item: item, cachedMediaItem: lastCachedMediaItem)
        } else {
           showNetworkUnreachableAlert()
        }
    }

    //MARK: - Functions

    private func setupView() {
        let searchDatePickerButtonItem = UIBarButtonItem(image: UIImage(systemName: "calendar"), style: .done, target: self, action: #selector(SearchViewController.searchDatePickerButtonPressed))
        navigationItem.rightBarButtonItem = searchDatePickerButtonItem
        //Default date is current date
        let desiredDate = Date()
        lastSelectedDate = DateFormatters.service.string(from: desiredDate)
        searchMediaButtonItem.title = "Search media for \(DateFormatters.userInterface.string(from: desiredDate))"
        datePickerView.date = Date()
        datePickerView.maximumDate = Date()
    }

    private func showNetworkUnreachableAlert() {
        let alertController = UIAlertController(title: "Network unreachable", message: "Please check network connectivity", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }

    private func loadAPODMedia(date: String? = nil) {
        mediaDetailViewController?.view.isHidden = true
        mediaDetailViewController?.reset()
        activityIndicatorView.startAnimating()
        if let date = date,
            let cachedMediaItem = coreDataService.fetchMediaItem(forDate: date),
           let item = cachedMediaItem.toModel()
        {
            updateMediaDetail(item: item, cachedMediaItem: cachedMediaItem)
            activityIndicatorView.stopAnimating()
        } else {
            service.fetchMedia(date: date) { [weak self] item, error in
                if let item = item {
                    //Persist item in core data
                    let cachedMediaItem = self?.coreDataService.saveMediaItem(item)
                    DispatchQueue.main.async {
                        self?.activityIndicatorView.stopAnimating()
                        self?.updateMediaDetail(item: item, cachedMediaItem: cachedMediaItem)
                    }
                } else {
                    DispatchQueue.main.async {
                        //Fetch last published media
                        self?.loadAPODMedia(date: nil)
                    }
                }
            }
        }
    }

    private func updateMediaDetail(item: APODMediaItem, cachedMediaItem: MediaItem?) {
        guard let date = DateFormatters.service.date(from: item.date) else { return }
        self.navigationItem.title = "A.P.O.D. - \(DateFormatters.userInterface.string(from: date))"
        mediaDetailViewController?.cachedMediaItem = cachedMediaItem
        mediaDetailViewController?.updateView(mediaItem: item)
        mediaDetailViewController?.view.isHidden = false
    }

    //MARK: - Actions

    @objc private func searchDatePickerButtonPressed(sender: UIButton) {
        guard let lastSelectedDate = lastSelectedDate else { return }
        searchMediaButtonItem.title = "Search media for \(lastSelectedDate)"
        guard let selectedDate = DateFormatters.service.date(from: lastSelectedDate) else { return }
        datePickerView.date = selectedDate
        view.bringSubviewToFront(dateInputStackView)
        dateInputStackView.isHidden = false
    }

    @IBAction private func closeDatePickerButtonPressed(sender: UIButton) {
        dateInputStackView.isHidden = true
    }

    @IBAction private func searchMediaButtonPressed(sender: UIButton) {
        guard
            let reachability = networkReacability.reachability,
            reachability.connection != .unavailable
        else {
            showNetworkUnreachableAlert()
            return
        }
        dateInputStackView.isHidden = true
        loadAPODMedia(date: lastSelectedDate)
    }

    @IBAction private func datePickerValueChanged(_ sender: UIDatePicker) {
        lastSelectedDate = DateFormatters.service.string(from: sender.date)
        searchMediaButtonItem.title = "Search media for \(DateFormatters.userInterface.string(from: sender.date))"
    }

    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedMediaDetail" {
            mediaDetailViewController = segue.destination as? MediaDetailViewController
        }
    }
}

