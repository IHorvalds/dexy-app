//
//  TablePickerViewController.swift
//  Dexy
//
//  Created by Tudor Croitoru on 28/02/2021.
//

import UIKit


protocol TablePickerDelegate: AnyObject {
    
    func didSelectItem(item: Any)
    
}

class TablePickerViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    open var options: NSOrderedSet!
    open var labels: [String]!
    
    private var filteredOptions = [Any]()
    private var filteredLabels = [String]()
    
    private var selectedIndex: IndexPath?
    
    public weak var delegate: TablePickerDelegate?
    
    var searchController: UISearchController!

    override func viewDidLoad() {
        super.viewDidLoad()
        assert(options.count == labels.count, "Different numbers of options and labels.")
        
        filteredOptions = options.array
        filteredLabels = labels
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "dicționar"
        searchController.searchBar.delegate = self
        searchController.searchBar.autocapitalizationType = .none
        navigationItem.searchController = searchController
        definesPresentationContext = false
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredOptions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        cell.textLabel?.text = filteredLabels[indexPath.row]
        if indexPath == selectedIndex {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedIndex = indexPath
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        
        delegate?.didSelectItem(item: filteredOptions[indexPath.row] as Any)
        
        self.dismiss(animated: true, completion: nil)
    }

}

extension TablePickerViewController {
    func updateSearchResults(for searchController: UISearchController) {
        if let search = searchController.searchBar.text?.lowercased(),
           !search.isEmpty {
            var _opts = [Any]()
            var _labs = [String]()
            for i in 0..<options.count {
                if labels[i].lowercased().contains(search) {
                    _opts.append(options[i])
                    _labs.append(labels[i])
                }
            }
            
            filteredOptions = _opts
            filteredLabels = _labs
        } else {
            filteredOptions = options.array
            filteredLabels = labels
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
