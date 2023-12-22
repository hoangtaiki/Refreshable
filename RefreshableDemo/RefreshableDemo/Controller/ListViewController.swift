//
//  ListViewController.swift
//  iOS Example
//
//  Created by Hoangtaiki on 7/29/18.
//  Copyright © 2018 toprating. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "List Header Style"
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let headerStyle = HeaderStyle(at: indexPath) else { return }

        let refreshViewController = RefreshViewController(headerStyle: headerStyle)
        navigationController?.pushViewController(refreshViewController, animated: true)
    }
}
