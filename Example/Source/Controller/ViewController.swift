//
//  ViewController.swift
//  iOS Example
//
//  Created by Hoangtaiki on 7/20/18.
//  Copyright © 2018 toprating. All rights reserved.
//

import UIKit
import Refreshable

class ViewController: UITableViewController {

    var numberRows = 10

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Refreshable"
        view.backgroundColor = UIColor(red: 210/255, green: 210/255, blue: 210/255, alpha: 1)

        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.register(SampleCell.nib(), forCellReuseIdentifier: SampleCell.reuseIdentifier)

        tableView.addPullToRefreshWithAction { [weak self] in
            self?.handleRefresh()
        }

        tableView.addLoadMoreWithAction { [weak self] in
            self?.handleLoadMore()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberRows
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 128
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SampleCell.reuseIdentifier, for: indexPath) as! SampleCell
        cell.isSeperationLineHidden = indexPath.row == numberRows - 1
        cell.indexNumberLabel.text = indexPath.row.description

        return cell
    }
}

extension ViewController {

    // Reset numberOfRows to original value
    // Reload data and enable load more
    fileprivate func handleRefresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.numberRows = 10
            self.tableView.reloadData()
            self.tableView.stopPullToRefresh()
            self.tableView.setLoadMoreEnable(true)
        }
    }

    fileprivate func updateLoadMoreEnable() {
        if numberRows < 16 { return }

        tableView.setLoadMoreEnable(false)
    }

    fileprivate func handleLoadMore() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.tableView.beginUpdates()
            self.numberRows += 3
            self.tableView.insertRows(at: [IndexPath(row: self.numberRows - 3, section: 0),
                                           IndexPath(row: self.numberRows - 2, section: 0),
                                           IndexPath(row: self.numberRows - 1, section: 0)],
                                      with: .automatic)
            self.tableView.endUpdates()
            self.tableView.stopLoadMore()

            // Check data to enable/disable load more
            self.updateLoadMoreEnable()
        }
    }
}
