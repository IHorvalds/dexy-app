//
//  DefinitionLookupTableViewController.swift
//  Dexy
//
//  Created by Tudor Croitoru on 13/02/2021.
//

import UIKit
import Alamofire

class DefinitionLookupTableViewController: UITableViewController, DefinitionCellPopoverDelegate, UIPopoverPresentationControllerDelegate {

    private let url = "https://dexonline.ro/definitie##DICT##/##WORD##/json"
    private let searchUrl = "https://dexonline.ro/ajax/searchComplete.php?term=##SEARCH##"
    
    private var definition: DefinitionLookup?
    private var searchTerm: String?
    private var dictionary: String?
    private var searchResults: [String] = []
    
    var resultsController: SearchResultsTableViewController!
    var searchController: UISearchController!
    
    let activityIndicator = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "DefinitionTableViewCell", bundle: nil), forCellReuseIdentifier: "definitioncell")
        setupSearchBar()
        setupActivityIndicator()
        update()
    }
    
    fileprivate func setupSearchBar() {
        resultsController = SearchResultsTableViewController()
        resultsController.delegate = self
        searchController = UISearchController(searchResultsController: resultsController)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "cuvânt"
        searchController.searchBar.delegate = self
        searchController.searchBar.autocapitalizationType = .none
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    fileprivate func setupActivityIndicator() {
        let indicatorButton = UIBarButtonItem(customView: activityIndicator)
        navigationItem.rightBarButtonItem = indicatorButton
        activityIndicator.hidesWhenStopped = true
    }
    
    fileprivate func update() {
        guard let searchTerm = searchTerm else { return }
        let newUrl = url.replacingOccurrences(of: "##WORD##", with: searchTerm.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? searchTerm)
                        .replacingOccurrences(of: "##DICT##", with: (self.dictionary != nil && !self.dictionary!.isEmpty) ? "-\(self.dictionary!)" : "")
        
        self.activityIndicator.startAnimating()
        AF.request(newUrl).response { [weak self] response in
            guard let self = self else { return }
            
            switch response.result {
            case .success(let data):
                if let data = data,
                   let definition = DefinitionLookup(data: data) {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        
                        self.definition = definition
                        self.tableView.reloadData()
                        self.activityIndicator.stopAnimating()
                    }
                }
            case .failure(let error):
                if self.checkConnectivity() {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Am dat cu mucii-n fasole...",
                                                      message: "Uite eroarea: \(String(describing: error))",
                                                      preferredStyle: .alert)
                        alert.addAction(.init(title: "Bine", style: .default))
                        self.present(alert, animated: true)
                    }
                } else {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Nu-ți merge netul",
                                                      message: "Incearcă să pornești WiFi-ul sau datele mobile din setări",
                                                      preferredStyle: .alert)
                        alert.addAction(.init(title: "Haide!", style: .default, handler: { _ in
                            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                                return
                            }

                            if UIApplication.shared.canOpenURL(settingsUrl) {
                                UIApplication.shared.open(settingsUrl)
                            }
                        }))
                        alert.addAction(.init(title: "Mai încolo", style: .cancel))
                        self.present(alert, animated: true)
                    }
                }
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    
    private func checkConnectivity() -> Bool {
        NetworkReachabilityManager.default?.isReachable ?? false
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return DefinitionLookup.dictionaryName(url: self.dictionary ?? "")
        } else {
            return ""
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return (definition != nil) ? 1 : 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return definition?.definitions.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "definitioncell", for: indexPath) as! DefinitionTableViewCell

        if let definition = definition {
            
            cell.def = definition.definitions[indexPath.row]
            cell.delegate = self 
        } else {
            cell.def = nil
        }

        return cell
    }
    
    func openPopover(sourceView: UIView, sourceRect: CGRect, footnote: String) {
        let footnoteVC = UIStoryboard(name: "Popovers", bundle: nil).instantiateViewController(identifier: "footnoteviewcontroller") as! FootnoteViewController
        footnoteVC.footnote = footnote
        footnoteVC.modalPresentationStyle = .popover
        
        if let popoverPresentationController = footnoteVC.popoverPresentationController {
            popoverPresentationController.permittedArrowDirections = [.up, .down]
            popoverPresentationController.sourceView = sourceView
            popoverPresentationController.sourceRect = sourceRect
            popoverPresentationController.delegate = self
            present(footnoteVC, animated: true, completion: nil)
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

}

extension DefinitionLookupTableViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        
        if let searchTerm = searchController.searchBar.text {
            
            let newUrl = searchUrl.replacingOccurrences(of: "##SEARCH##", with: searchTerm)
            activityIndicator.startAnimating()
            AF.request(newUrl).responseJSON { [weak self] response in
                guard let self = self else { return }
                
                
                switch response.result {
                case .success(let json):
                    if let results = json as? Array<String> {
                        self.resultsController.searchResults = results
                        self.resultsController.tableView.reloadData()
                    }
                case .failure(let error):
                    print(error)
                }
                
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationItem.title = "Definiții"
        searchController.dismiss(animated: true)
    }
}

extension DefinitionLookupTableViewController: SearchResultsDelegate {
    
    func didSelectDictionary(dictionary: String) {
        self.dictionary = dictionary
        update()
    }
    
    func didSelectWord(word: String) {
        self.searchTerm = word
        self.searchController.searchBar.text = word
        self.navigationItem.title = "\"\(word)\""
        update()
        searchController.dismiss(animated: true)
    }
}
