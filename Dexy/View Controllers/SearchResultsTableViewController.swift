//
//  SearchResultsTableViewController.swift
//  Dexy
//
//  Created by Tudor Croitoru on 17/02/2021.
//

import UIKit

protocol SearchResultsDelegate: AnyObject {
    func didSelectDictionary(dictionary: String)
    func didSelectWord(word: String)
}

class SearchResultsTableViewController: UITableViewController {

    var searchResults: [String] = []
    var searchTerm: String?
    var dictionary: String?
    
    weak var delegate: SearchResultsDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Dicționar"
        }
        
        return "Opțiuni"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if indexPath.section == 0 {
            cell.textLabel?.text = DefinitionLookup.dictionaryName(url: self.dictionary ?? "")
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.textLabel?.text = searchResults[indexPath.row]
            cell.textLabel?.textColor = .systemBlue
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 0 {
            let dictionaryPicker = TablePickerViewController()
            dictionaryPicker.options = DefinitionLookup.dictionaryUrls
            dictionaryPicker.labels = DefinitionLookup.dictionaryUrls.map( {DefinitionLookup.dictionaryName(url: $0 as! String)} )
            dictionaryPicker.delegate = self
            
            let navController = UINavigationController(rootViewController: dictionaryPicker)
            navController.navigationBar.prefersLargeTitles = false
            dictionaryPicker.navigationItem.title = "Dicționar"
            
            self.show(navController, sender: self)
        } else {
            searchTerm = searchResults[indexPath.row]
            delegate?.didSelectWord(word: searchResults[indexPath.row])
        }
    }

}

extension SearchResultsTableViewController: TablePickerDelegate {
    func didSelectItem(item: Any) {
        if let dict = item as? String {
            self.dictionary = dict
            delegate?.didSelectDictionary(dictionary: dict)
            tableView.reloadData()
        }
    }
}
