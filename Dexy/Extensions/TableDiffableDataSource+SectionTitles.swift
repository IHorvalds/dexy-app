//
//  TableDiffableDataSource+SectionTitles.swift
//  Dexy
//
//  Created by Tudor Croitoru on 06/03/2021.
//

import UIKit

class TableDiffableDataSource<S, T>: UITableViewDiffableDataSource<S, T> where S: Hashable, T: Hashable {
    open var titles: ((Int) -> (String))? = nil
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if titles != nil {
            return titles!(section)
        } else {
            return super.tableView(tableView, titleForHeaderInSection: section)
        }
    }
}
