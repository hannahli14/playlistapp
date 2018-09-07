//
//  NewPostViewController.swift
//  DataPractice
//
//  Created by Hannah Li on 8/23/18.
//  Copyright © 2018 Hannah Li. All rights reserved.
//

import UIKit

class NewPostViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTV: UITableView!
    @IBOutlet weak var topView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        searchBar.delegate = self
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        performAction()
    }
    
    func performAction() {
        topView.isHidden = true
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
