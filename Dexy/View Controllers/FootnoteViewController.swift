//
//  FootnoteViewController.swift
//  Dexy
//
//  Created by Tudor Croitoru on 26/02/2021.
//

import UIKit

class FootnoteViewController: UIViewController {

    @IBOutlet private weak var textView: UITextView!
    
    public var footnote: String?
    private var _footnotes: [NSRange:String]? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        textView.sizeToFit()
        
        let size = textView.contentSize
        self.preferredContentSize = size
     
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.attributedText = footnote?.formatString(baseFont: .systemFont(ofSize: 14.0), footnotes: &_footnotes)
        
    }

}
