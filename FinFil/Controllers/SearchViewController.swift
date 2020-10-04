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
    @IBOutlet weak var searchButton: UIButton!
    
    
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
        
        // setup search button
        searchButton.layer.borderColor = UIColor.white.cgColor
        searchButton.layer.borderWidth = 1
        searchButton.layer.masksToBounds = true
        searchButton.titleLabel?.textAlignment = NSTextAlignment.center
        searchButton.layer.cornerRadius = searchButton.frame.height / 2
        searchButton.backgroundColor = .clear
        searchButton.setTitle(NSLocalizedString("Search", comment: ""), for: .normal)
        searchButton.setTitleColor(.white, for: .normal)
        
        // set up back ground color
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
        //
        self.view.addSubview(infoLabel)
        self.view.addSubview(textField)
        self.view.addSubview(searchButton)
    }
    
    func refreshViews() {
        textField.text = ""
        textField.resignFirstResponder()
    }
    
    @IBAction func tapSideMenuButton(_ sender: UIBarButtonItem) {
        // show sidemenu
        sideMenuController?.revealMenu()
    }
    
    @IBAction func tapSearchButton(_ sender: UIButton) {
        textField.resignFirstResponder()
        if ifInputRight() {
            sendSearchRequest()
        }
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
    
    private func sendSearchRequest() {
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
    }
    
    private func ifInputRight() -> Bool {
        if textField.text!.isEmpty {
            Utils().okButtonAlertView(
                title: NSLocalizedString("Input_Cant_Nil", comment: ""),
                controller: self,
                block: nil)
            return false
        }
        
        if !Utils().ifOnlyEnglish(textField.text!) {
            Utils().okButtonAlertView(
                title: NSLocalizedString("Only_English_Allowed", comment: ""),
                controller: self,
                block: nil)
            return false
        }
        
        if !Utils().ifOnlyWordAndNumber(textField.text!) {
            Utils().okButtonAlertView(
                title: NSLocalizedString("Wrrong_Char_Used", comment: ""),
                controller: self,
                block: nil)
            return false
        }
        
        return true
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
        
        if ifInputRight() {
            sendSearchRequest()
            return true
        }
        else {
            return false
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
}
