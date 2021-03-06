//
//  ViewController.swift
//  Dexy
//
//  Created by Tudor Croitoru on 10/02/2021.
//

import UIKit
import Kingfisher
import Alamofire

class WotdVC: UITableViewController {
    
    private let url = "https://dexonline.ro/cuvantul-zilei/##DATE##/json"
    var date: Date = Date()
    private var wordOfTheDay: WordOfTheDay?
    
    private let dateFormatter = DateFormatter()
    
    // MARK: - DiffableDataSource
    private enum Section {
        case selected
        case others
    }
    
    private var dataSource: TableDiffableDataSource<Section, AnyHashable>! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "YYYY/MM/dd"
        
        tableView.register(UINib(nibName: "WotdTableViewCell", bundle: nil), forCellReuseIdentifier: "wotdcell")
        tableView.register(UINib(nibName: "SmallWotdTableViewCell", bundle: nil), forCellReuseIdentifier: "smallwotdcell")
        
        setupDataSource()
        tableView.delegate = self
        update()
    }
    
    fileprivate func setupDataSource() {
        dataSource = TableDiffableDataSource<Section, AnyHashable>(tableView: tableView, cellProvider: { [weak self] tbv, indx, wotd in
            guard let self = self else { return UITableViewCell() }
            
            return self.ConfigureCell(tableView: tbv, index: indx, wordOfTheDay: wotd)
        })
        
        self.dataSource.titles = TitleForHeader
        
        self.dataSource.defaultRowAnimation = .fade
    }
    
    fileprivate func TitleForHeader(section: Int) -> String {
        if section == 0 {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            return "Cuvîntul zilei \(dateFormatter.string(from: self.date))"
        } else {
            return "Cuvinte din alți ani"
        }
    }
    
    fileprivate func ConfigureCell(tableView: UITableView, index: IndexPath, wordOfTheDay wotd: AnyHashable) -> UITableViewCell {
        if index.section == 0,
           let wotd = wotd as? WordOfTheDay {
            let wotdCell: WotdTableViewCell = tableView.dequeueReusableCell(withIdentifier: "wotdcell") as! WotdTableViewCell
            
            wotdCell.wotd = wotd
            
            return wotdCell
        } else {
            let smallWotdCell: SmallWotdTableViewCell = tableView.dequeueReusableCell(withIdentifier: "smallwotdcell") as! SmallWotdTableViewCell
            
            if let wotd = wotd as? WordOfTheDay.SmallWordOfTheDay {
                smallWotdCell.otherWotd = wotd
            } else {
                smallWotdCell.otherWotd = nil
            }
            
            return smallWotdCell
        }
    }
    
    private func update() {
        
        let newUrl = url.replacingOccurrences(of: "##DATE##", with: dateFormatter.string(from: self.date))
        
        AF.request(newUrl).response { [weak self] response in
            guard let self = self else { return }
            
            switch response.result {
                case .success(let data):
                    if let data = data,
                       let wotd = WordOfTheDay(data: data) {
                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else { return }
                            
                            self.wordOfTheDay = wotd
                            var snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()
                            
                            snapshot.appendSections([.selected, .others])
                            snapshot.appendItems([wotd], toSection: .selected)
                            snapshot.appendItems(wotd.others, toSection: .others)
                            
                            self.dataSource.apply(snapshot, animatingDifferences: true)
                            snapshot.reloadSections([.selected])
                        }
                    }
                case .failure(let error):
                    if self.checkConnectivity() {
                        let alert = UIAlertController(title: "Am dat cu mucii-n fasole...",
                                                      message: "Uite eroarea: \(String(describing: error))",
                                                      preferredStyle: .alert)
                        alert.addAction(.init(title: "Bine", style: .default))
                        self.present(alert, animated: true)
                    } else {
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
        }
    }
    
    private func checkConnectivity() -> Bool {
        NetworkReachabilityManager.default?.isReachable ?? false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showdaypickersegue",
           let destVC = segue.destination as? DayPickerViewController {
            destVC.currentDate = self.date
            destVC.delegate = self
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            return "Cuvîntul zilei \(dateFormatter.string(from: self.date))"
        } else {
            return "Cuvinte din alți ani"
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1,
           let wotd = wordOfTheDay {
            self.date = wotd.others[indexPath.row].date
            update()
        }
    }
}

extension WotdVC: DayPickerDelegate {
    func didPickDate(date: Date) {
        self.date = date
        self.update()
    }
}

