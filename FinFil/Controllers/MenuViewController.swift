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
    
    // cell高度
    let cellHeight: CGFloat = 42
    
    // MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 侧边栏设置，优先度低于AppDelegete里的设置
        setupViews()
        // 添加内部成分Views
        inputContentViews()
    }

    // 在屏幕旋转变形调用，本项目用不到，保留以备用
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
        view.layoutIfNeeded() // 重新layout
    }
    
    // 动态更新
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

// MARK:- 内部方法
extension MenuViewController {
    
    // 侧边栏设置
    func setupViews() {
        // 指定自己实现侧边栏的代理
        sideMenuController?.delegate = self
        
        // 判定侧边栏的模式是否是黑暗模式，本app不采用
        isDarkModeEnabled = SideMenuController.preferences.basic.position == .under
        
        // 暗影模式
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
        
        // 背景色
        view.backgroundColor = themeColor
        tableView.backgroundColor = themeColor
        backTopView.backgroundColor = themeColor
        contentView.backgroundColor = themeColor
        
        // 头像
        let radius = headImageView.frame.height / 2
        headImageView.layer.cornerRadius = radius
        headImageView.layer.borderWidth = 0
        headImageView.layer.masksToBounds = false
        // 阴影
        headImageView.layer.shadowColor = UIColor.gray.cgColor
        headImageView.layer.shadowOpacity = 0.5 //不透明度
        headImageView.layer.shadowRadius = 2.0 //设置阴影所照射的范围
        headImageView.layer.shadowOffset = CGSize.init(width: 2, height: 2) // 设置阴影的偏移量
        
        // 头像下的两行信息
        label1.text = NSLocalizedString("Menu_Title", comment: "")
        label1.font = UIFont(name: "PingFangSC-Regular", size: 13)
        label2.text = NSLocalizedString("Menu_SubTitle", comment: "")
        label2.font = UIFont(name: "PingFangSC-Regular", size: 11)
        
        // 版本号
        verLabel.text = Utils.getAppVersion()
        verLabel.font = UIFont(name: "PingFangSC-Regular", size: 13)
        
        // 设置按钮
        settingButton.backgroundColor = UIColor.clear
        let buttonHeight = settingButton.frame.height
        //
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: buttonHeight, height: buttonHeight))
        imageView.image = UIImage(named: "menu_setting")
        settingButton.addSubview(imageView)
        //
        let labelX = imageView.frame.width + 20
        let labelWidth = settingButton.frame.width - labelX
        let label = UILabel(frame: CGRect(x: labelX, y: 0, width: labelWidth, height: buttonHeight))
        label.text = NSLocalizedString("Menu_Setting", comment: "")
        let settingSize: CGFloat = 13
        label.font = UIFont(name: "PingFangSC-Regular", size: settingSize)
        settingButton.addSubview(label)
    }
    
    // 添加内部成分Views
    func inputContentViews() {
        // 侧边栏加入：喜欢
        sideMenuController?.cache(viewControllerGenerator: {
            self.storyboard?.instantiateViewController(withIdentifier: "SecondViewController")
        }, with: "1")
        
        // 侧边栏加入：设置
        sideMenuController?.cache(viewControllerGenerator: {
            self.storyboard?.instantiateViewController(withIdentifier: "ThirdViewController")
        }, with: "2")
    }
    
    @IBAction func tapSettingButton(_ sender: UIButton) {
        // 选中是设置相关的状态
        Utils().setMenuInt(int: SelectedSideMenu.setting)
        // 还是不让setting按钮变色了，太别扭
        tableView.reloadData()
        
        // 跳转到设置的界面
        sideMenuController?.setContentViewController(with: "2", animated: Preferences.shared.enableTransitionAnimation)
        sideMenuController?.hideMenu()
        //
        if let identifier = sideMenuController?.currentCacheIdentifier() {
            print("[Example] View Controller Cache Identifier: \(identifier)")
        }
    }
}

// MARK:- 实现SideMenuControllerDelegate方法
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
        
        // 发送隐藏键盘的通知
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
        // 菜单栏数量
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 设置一下cell
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "MenuCell",
            for: indexPath) as! SelectionCell
        cell.contentView.backgroundColor = themeColor
        let size: CGFloat = 16
        cell.titleLabel.font = UIFont(name: "PingFangSC-Regular", size: size)
        
        // 设置颜色，但是无效
        if indexPath.row == Utils().getMenuInt() {
            cell.textLabel?.textColor = UIColor.colorWith(hexString: "#007AFF")
        }
        else {
            cell.textLabel?.textColor = UIColor.black
        }
        
        // 每行
        let row = indexPath.row
        if row == 0 {
            cell.titleLabel?.text = NSLocalizedString("Menu_Search", comment: "")
            cell.titleImage?.image = UIImage(named: "menu_search")
        }
        else if row == 1 {
            cell.titleLabel?.text = NSLocalizedString("Menu_Liked", comment: "")
            cell.titleImage?.image = UIImage(named: "menu_liked")
        }
        
        // 暗影模式
        cell.titleLabel?.textColor = isDarkModeEnabled ? .white : .black
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 得到行数
        let row = indexPath.row
        
        // 设置从哪里跳转而来，必须和SelectedSideMenu顺序相同
        Utils().setMenuInt(int: row)
        tableView.reloadData()
        
        // todo：取消选中状态
        tableView.deselectRow(at: indexPath, animated: true)
        
        // 跳转到相应的界面
        sideMenuController?.setContentViewController(
            with: "\(row)",
            animated: Preferences.shared.enableTransitionAnimation)
        sideMenuController?.hideMenu()
        //
        if let identifier = sideMenuController?.currentCacheIdentifier() {
            print("[Example] View Controller Cache Identifier: \(identifier)")
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // 根据计算尺寸得到
        return cellHeight
    }
}


