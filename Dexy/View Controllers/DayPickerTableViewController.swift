//
//  DayPickerTableViewController.swift
//  Dexy
//
//  Created by Tudor Croitoru on 12/02/2021.
//

import UIKit

protocol DayPickerDelegate {
    func didPickDate(date: Date)
}

class DayPickerViewController: UIViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBAction func doneButton(_ sender: UIBarButtonItem) {
        delegate?.didPickDate(date: datePicker.date)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var delegate: DayPickerDelegate?
    var currentDate: Date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar(identifier: .gregorian)
        dateComponents.timeZone = TimeZone(abbreviation: "EET")
        dateComponents.year = 2012
        dateComponents.month = 1
        dateComponents.day = 1
        
        datePicker.date = currentDate
        
        datePicker.maximumDate = Date()
        datePicker.minimumDate = dateComponents.date // if it's not valid, it's nil so meh; it's ok
        
    }
    
    deinit {
        delegate = nil
    }

}
