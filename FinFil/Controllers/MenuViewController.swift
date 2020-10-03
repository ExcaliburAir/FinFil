//
//  ViewController.swift
//  UMS_pay
//
//  Created by 张桀硕 on 2019/2/13.
//  Copyright © 2019年 jieshuo.zhang. All rights reserved.
//

import Foundation
import UIKit

class Preferences {
    static let shared = Preferences()
    var enableTransitionAnimation = false
}

// Used by SideMenu tableview
class SelectionCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleImage: UIImageView!
}

class MenuViewController: UIViewController {
    
    var isDarkModeEnabled = false
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.separatorStyle = .none
        }
    }
    @IBOutlet weak var selectionTableViewHeader: UILabel!
    @IBOutlet weak var selectionMenuTrailingConstraint: NSLayoutConstraint!
    
    private var themeColor = UIColor.white
    
    @IBOutlet weak var backTopView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var headImageView: UIImageView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var verLabel: UILabel!
    
    let cellHeight: CGFloat = 42
    
    // MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        inputContentViews()
    }

    // use when scream transition
    override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator)
    {
        super.viewWillTransition(to: size, with: coordinator)

        let sidemenuBasicConfiguration =
            SideMenuController.preferences.basic
        let showPlaceTableOnLeft =
            (sidemenuBasicConfiguration.position == .under) != (sidemenuBasicConfiguration.direction == .right)
        selectionMenuTrailingConstraint.constant = showPlaceTableOnLeft ? SideMenuController.preferences.basic.menuWidth - size.width : 0
        view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

extension MenuViewController {
    
    // setup sidemenu views
    func setupViews() {
        sideMenuController?.delegate = self
        isDarkModeEnabled = SideMenuController.preferences.basic.position == .under
        
        // dark model
        if isDarkModeEnabled {
            themeColor = UIColor(red: 0.03, green: 0.04, blue: 0.07, alpha: 1.00)
            selectionTableViewHeader.textColor = .white
        }
        else {
            selectionMenuTrailingConstraint.constant = 0
            themeColor = UIColor(red: 0.98, green: 0.97, blue: 0.96, alpha: 1.00)
        }
        
        let sidemenuBasicConfiguration = SideMenuController.preferences.basic
        let showPlaceTableOnLeft =
            (sidemenuBasicConfiguration.position == .under) != (sidemenuBasicConfiguration.direction == .right)
        if showPlaceTableOnLeft {
            selectionMenuTrailingConstraint.constant =
                SideMenuController.preferences.basic.menuWidth - view.frame.width
        }
        
        // setup colors
        view.backgroundColor = themeColor
        tableView.backgroundColor = themeColor
        backTopView.backgroundColor = themeColor
        contentView.backgroundColor = themeColor
        
        // head
        let radius = headImageView.frame.height / 2
        headImageView.layer.cornerRadius = radius
        headImageView.layer.borderWidth = 0
        headImageView.layer.masksToBounds = false
        // head shadow
        headImageView.layer.shadowColor = UIColor.gray.cgColor
        headImageView.layer.shadowOpacity = 0.5
        headImageView.layer.shadowRadius = 2.0
        headImageView.layer.shadowOffset = CGSize.init(width: 2, height: 2)
        
        // infos
        label1.text = NSLocalizedString("Menu_Title", comment: "")
        label1.font = UIFont(name: "PingFangSC-Regular", size: 13)
        label2.text = NSLocalizedString("Menu_SubTitle", comment: "")
        label2.font = UIFont(name: "PingFangSC-Regular", size: 11)
        
        // version
        verLabel.text = Utils.getAppVersion()
        verLabel.font = UIFont(name: "PingFangSC-Regular", size: 13)
        
        // settings button
        settingButton.backgroundColor = UIColor.clear
        let buttonHeight = settingButton.frame.height
        // settings button image
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: buttonHeight, height: buttonHeight))
        imageView.image = UIImage(named: "menu_setting")
        settingButton.addSubview(imageView)
        // settings button frame
        let labelX = imageView.frame.width + 20
        let labelWidth = settingButton.frame.width - labelX
        let label = UILabel(frame: CGRect(x: labelX, y: 0, width: labelWidth, height: buttonHeight))
        label.text = NSLocalizedString("Menu_Setting", comment: "")
        let settingSize: CGFloat = 13
        label.font = UIFont(name: "PingFangSC-Regular", size: settingSize)
        settingButton.addSubview(label)
    }
    
    // input content views
    func inputContentViews() {
        // the second view: My Favorite
        sideMenuController?.cache(viewControllerGenerator: {
            self.storyboard?.instantiateViewController(withIdentifier: "SecondViewController")
        }, with: "1")
        
        // the third view: Settings
        sideMenuController?.cache(viewControllerGenerator: {
            self.storyboard?.instantiateViewController(withIdentifier: "ThirdViewController")
        }, with: "2")
    }
    
    @IBAction func tapSettingButton(_ sender: UIButton) {
        // set sidemenu flag
        Utils().setMenuInt(int: SelectedSideMenu.setting)
        tableView.reloadData()
        
        // push to settings view
        sideMenuController?.setContentViewController(with: "2", animated: Preferences.shared.enableTransitionAnimation)
        sideMenuController?.hideMenu()
        // print info
        if let identifier = sideMenuController?.currentCacheIdentifier() {
            print("[Example] View Controller Cache Identifier: \(identifier)")
        }
    }
}

// MARK:- SideMenuControllerDelegate
extension MenuViewController: SideMenuControllerDelegate {
    
    func sideMenuController(
        _ sideMenuController: SideMenuController,
        animationControllerFrom fromVC: UIViewController,
        to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return BasicTransitionAnimator(options: .transitionFlipFromLeft, duration: 0.6)
    }

    func sideMenuController(
        _ sideMenuController: SideMenuController,
        willShow viewController: UIViewController,
        animated: Bool)
    {
        print("[Example] View controller will show [\(viewController)]")
    }

    func sideMenuController(
        _ sideMenuController: SideMenuController,
        didShow viewController: UIViewController,
        animated: Bool)
    {
        print("[Example] View controller did show [\(viewController)]")
    }

    func sideMenuControllerWillHideMenu(_ sideMenuController: SideMenuController) {
        print("[Example] Menu will hide")
    }

    func sideMenuControllerDidHideMenu(_ sideMenuController: SideMenuController) {
        print("[Example] Menu did hide.")
    }

    func sideMenuControllerWillRevealMenu(_ sideMenuController: SideMenuController) {
        print("[Example] Menu will reveal.")
        
        // send hide keyboard notification
        NotificationCenter.default.post(name: NSNotification.Name(NotificationName.hideKeyboard),
                                        object: nil,
                                        userInfo: nil)
    }

    func sideMenuControllerDidRevealMenu(_ sideMenuController: SideMenuController) {
        print("[Example] Menu did reveal.")
    }
}

// MARK:- UITableViewDelegate, UITableViewDataSource
extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // setup cell
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "MenuCell",
            for: indexPath) as! SelectionCell
        cell.contentView.backgroundColor = themeColor
        let size: CGFloat = 16
        cell.titleLabel.font = UIFont(name: "PingFangSC-Regular", size: size)
        
        // setup colors
        if indexPath.row == Utils().getMenuInt() {
            cell.textLabel?.textColor = UIColor.colorWith(hexString: "#007AFF")
        }
        else {
            cell.textLabel?.textColor = UIColor.black
        }
        
        // setup row
        let row = indexPath.row
        if row == 0 {
            cell.titleLabel?.text = NSLocalizedString("Menu_Search", comment: "")
            cell.titleImage?.image = UIImage(named: "menu_search")
        }
        else if row == 1 {
            cell.titleLabel?.text = NSLocalizedString("Menu_Liked", comment: "")
            cell.titleImage?.image = UIImage(named: "menu_liked")
        }
        
        // if dark mode
        cell.titleLabel?.textColor = isDarkModeEnabled ? .white : .black
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        
        // use sidemenu flag to know where to come
        Utils().setMenuInt(int: row)
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
        
        // push to view selected
        sideMenuController?.setContentViewController(
            with: "\(row)",
            animated: Preferences.shared.enableTransitionAnimation)
        sideMenuController?.hideMenu()
        // print info
        if let identifier = sideMenuController?.currentCacheIdentifier() {
            print("[Example] View Controller Cache Identifier: \(identifier)")
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
}


