//
//  SearchViewController.swift
//  FinFil
//
//  Created by 张桀硕 on 2020/9/30.
//  Copyright © 2020年 jieshuo.zhang. All rights reserved.
//

import Foundation
import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    
    // MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareData()
        setupViews()
        addTapGesture()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        print( NSStringFromClass(self.classForCoder) + " deinit")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SearchToList" {
            if let viewController = segue.destination as? ListViewController {
                if sender != nil {
                    viewController.moviesInfo = sender as! [MovieInfo]
                }
            }
        }
    }
}

extension SearchViewController {
    
    func prepareData() {
        infoLabel.text = NSLocalizedString("Search_Movies", comment: "")
    }
    
    func setupViews() {
        textField.delegate = self
        
        // back ground color set
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        self.view.layer.addSublayer(gradientLayer)
        //
        let colerTop: UIColor = UIColor.colorWith(hexString: "#396D9B")
        let colerBottom: UIColor = UIColor.colorWith(hexString: "#2C3D4D")
        gradientLayer.colors = [colerTop.cgColor, colerBottom.cgColor]
        //
        let gradientLocations: [NSNumber] = [0.0, 1.0]
        gradientLayer.locations = gradientLocations
        gradientLayer.startPoint = CGPoint.init(x: 0.4, y: 0)
        gradientLayer.endPoint = CGPoint.init(x: 0.6, y: 1)
        
        self.view.addSubview(infoLabel)
        self.view.addSubview(textField)
    }
    
    func refreshViews() {
        textField.text = ""
        textField.resignFirstResponder()
    }
    
    @IBAction func tapSideMenuButton(_ sender: UIBarButtonItem) {
        // show sidemenu
        sideMenuController?.revealMenu()
    }
    
    // add tap gesure
    func addTapGesture() {
        // create gusture
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction(sender:)))
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(gesture)
    }
    
    @objc func tapGestureAction(sender: UITapGestureRecognizer) {
        textField.resignFirstResponder()
    }
}

// MARK:- UITextFieldDelegate
extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {}
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        // use search request
        NetworkAPI().get_search_request(
            controller: self,
            queryString: textField.text!,
            block: { movies in
                print(movies)
                if movies.count >= 1 {
                    self.performSegue(withIdentifier: "SearchToList", sender: movies)
                }
                else {
                    Utils().okButtonAlertView(
                        title: NSLocalizedString("Network_noResult_tryOther", comment: ""),
                        controller: self,
                        block: nil)
                }
        })
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
}
