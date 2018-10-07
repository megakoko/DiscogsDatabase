//
//  ReleaseViewController.swift
//  DiscogsDatabase
//
//  Created by Andy on 01/12/2017.
//  Copyright © 2017 Andy Chukavin. All rights reserved.
//

import UIKit

class ReleaseViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    private var model: ReleaseModel? = nil

    func setReleaseUrl(_ url: URL) {
        if model == nil {
            model = ReleaseModel()
        }
        model!.setReleaseUrl(url)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        artistLabel.text = nil
        genreLabel.text = nil
        yearLabel.text = nil

        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: ReleaseModel.dataUpdatedNotification),
                                               object: nil,
                                               queue: nil) { _ in
            self.artistLabel.text = self.model?.artist
            self.genreLabel.text = self.model?.genre
            self.yearLabel.text = self.model?.year
            self.tableView.reloadData()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Update table's header size to fit artist's description
        if let headerView = tableView.tableHeaderView {
            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var headerFrame = headerView.frame

            if height != headerFrame.size.height {
                headerFrame.size.height = height
                headerView.frame = headerFrame
                tableView.tableHeaderView = headerView
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return model!.trackCollections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model!.trackCollections[section].tracks.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "releaseCellIdentifier", for: indexPath)

        cell.textLabel?.text = model!.trackCollections[indexPath.section].tracks[indexPath.row].title

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model!.trackCollections[section].title
    }
}
