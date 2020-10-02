//
//  SettingViewController.swift
//  FinFil
//
//  Created by 张桀硕 on 2020/9/30.
//  Copyright © 2020年 jieshuo.zhang. All rights reserved.
//

import Foundation
import UIKit

class SettingViewController: UIViewController {
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var infoLabel1: UILabel!
    @IBOutlet weak var descripLabel1: UILabel!
    @IBOutlet weak var infoLabel2: UILabel!
    @IBOutlet weak var descripLabel2: UILabel!
    
    @IBOutlet weak var switch1: UISwitch!
    @IBOutlet weak var switch2: UISwitch!
    
    
    // MARK:-
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareData()
        setupViews()
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {}
    
    
}

extension SettingViewController {
    
    func prepareData() {
        infoLabel1.text = NSLocalizedString("Network_Listening", comment: "")
        descripLabel1.text = NSLocalizedString("Network_Listening_Description", comment: "")
        infoLabel2.text = NSLocalizedString("Read_Overview", comment: "")
        descripLabel2.text = NSLocalizedString("Read_Overview_Description", comment: "")
    }
    
    func setupViews() {
        switch1.addTarget(self, action: #selector(switchOneDidChange(_:)), for: .valueChanged)
        switch2.addTarget(self, action: #selector(switchTwoDidChange(_:)), for: .valueChanged)
    }
    
    func refreshViews() {
        // refresh switch1 status
        if DefaultBase().getAppType() == DefaultBase.listeningNetwork {
            switch1.isOn = true
        }
        else {
            switch1.isOn = false
        }
        
        // refresh switch2 status
        if DefaultBase().getSoundType() == DefaultBase.soundOn {
            switch2.isOn = true
        }
        else {
            switch2.isOn = false
        }
    }
    
    // Menu按键
    @IBAction func tapSideMenuButton(_ sender: UIBarButtonItem) {
        // 调用侧边栏
        sideMenuController?.revealMenu()
    }
    
    @objc func switchOneDidChange(_ sender: UISwitch){
        if sender.isOn {
            DefaultBase().setAppType(string: DefaultBase.listeningNetwork)
        }
        else {
            DefaultBase().setAppType(string: DefaultBase.unLiseningNetwork)
        }
    }
    
    @objc func switchTwoDidChange(_ sender: UISwitch){
        if sender.isOn {
            DefaultBase().setSoundType(string: DefaultBase.soundOn)
        }
        else {
            DefaultBase().setSoundType(string: DefaultBase.soundOff)
        }
    }
}
