//
//  ViewController.swift
//  Prework
//
//  Created by lika on 2/2/22.
//  Copyright © 2022 lika. All rights reserved.
//


import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var modeSwitcher: UISwitch!
    @IBOutlet weak var billAmountTextField: UITextField!
    
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var tipControl: UISegmentedControl!
    @IBOutlet weak var tipSlider: UISlider!
    @IBOutlet weak var splitAmount: UILabel!

    @IBOutlet weak var calcButton: UIButton!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var tipAmountLabel: UILabel!
    @IBOutlet weak var totalPerPersonLabel: UILabel!
    @IBOutlet weak var totalPerPersonText: UILabel!
    
    @IBOutlet weak var resultView: UIView!
    
    var tipPercentage = [3, 10, 30];
    var tipPIndex = 0;
    var changingValues = true
    
    var savedState = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        billAmountTextField.becomeFirstResponder()
        totalPerPersonText.isHidden = true
        totalPerPersonLabel.isHidden = true
        print(tipPIndex)
    
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self,
        selector: #selector(ViewController.onResume),
        name: UIApplication.willEnterForegroundNotification,
        object: nil)
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self,
        selector: #selector(enteredBackground),
        name: UIApplication.didEnterBackgroundNotification,
        object: nil)
    }

    @objc func onResume() {
        let closedDate = savedState.object(forKey: "dateClo") as! NSDate?
        if(closedDate != nil) {
            let currentDateTime = NSDate()
            let diffTimeInSec = currentDateTime.timeIntervalSince(closedDate! as Date)
            let diffTimeInMin = diffTimeInSec/60
            if (diffTimeInMin < 10) {
                billAmountTextField.text = savedState.string(forKey: "billAmount")
                tipPercentage[0] = savedState.integer(forKey: "tip1")
                tipPercentage[1] = savedState.integer(forKey: "tip2")
                tipPercentage[2] = savedState.integer(forKey: "tip3")
                tipPIndex = savedState.integer(forKey: "tipInxed")
                additionalUpdates()
                splitAmount.text = savedState.string(forKey: "splitAmount")
                modeSwitcher.isOn = savedState.bool(forKey: "darkMode")
                changeMode(changeToDark: modeSwitcher.isOn == true)
            }
            else {
                tipPIndex = 0
                tipControl.selectedSegmentIndex = tipPIndex
                billAmountTextField.text = ""
                tipPercentage[0] = 3
                tipPercentage[1] = 10
                tipPercentage[2] = 30
                tipPIndex = 0
                additionalUpdates()
                splitAmount.text = "1"
                modeSwitcher.isOn = false
                changeMode(changeToDark: modeSwitcher.isOn == true)
                changingValues = true
                updateChange()
            }
        }
}

    @objc func enteredBackground () {
        savedState.setValue(billAmountTextField.text, forKey: "billAmount")
        savedState.setValue(tipPercentage[0], forKey: "tip1")
        savedState.setValue(tipPercentage[1], forKey: "tip2")
        savedState.setValue(tipPercentage[2], forKey: "tip3")
        savedState.setValue(tipControl.selectedSegmentIndex, forKey: "tipInxed")
        savedState.setValue(splitAmount.text, forKey: "splitAmount")
        let currentDateTime = NSDate()
        savedState.setValue(currentDateTime, forKey: "dateClo")
        savedState.setValue(modeSwitcher.isOn, forKey: "darkMode")
    }
    
    
    @IBAction func modeSwitch(_ sender: UISwitch) {
        updateChange()
        changeMode(changeToDark: sender.isOn == true)
    }
    
    @IBAction func billEdit(_ sender: Any) {
         updateChange()
    }
    
    @IBAction func manageTip(_ sender: Any) {
        updateChange()
        tipPIndex = tipControl.selectedSegmentIndex
        tipSlider.value = Float(tipPercentage[tipPIndex])
        tipLabel.text = String(tipPercentage[tipPIndex]) + "%"
    }

    @IBAction func tipSlider(_ sender: UISlider) {
        updateChange()
        tipControl.setTitle(String(Int(tipSlider.value)) + "%", forSegmentAt: tipPIndex)
        tipPercentage[tipPIndex] = Int(tipSlider.value);
        tipLabel.text = String(Int(tipSlider.value)) + "%"
    }
    
    @IBAction func splitStepper(_ sender: UIStepper) {
        updateChange()
        self.splitAmount.text = Int(sender.value).description
    }
    
    @IBAction func calc(_ sender: Any) {
        let bill = Double(billAmountTextField.text!) ?? 0
        let tip = bill * Double(tipPercentage[tipPIndex]) / 100
        let total = bill + tip
        
        tipAmountLabel.text = String(format: "%.2f", tip)
        totalLabel.text = String(format: "%.2f", total)
        
        changingValues = false
        UIView.animate(withDuration: 1.0, animations: {
            self.resultView.alpha = 1.0
            if(self.splitAmount.text != "1") {
                self.totalPerPersonText.isHidden = false
                self.totalPerPersonLabel.isHidden = false
                
                let totalPPerson = total / Double(Int(self.splitAmount.text ?? "1")!)
                self.totalPerPersonLabel.text = String(format: "%.2f", totalPPerson)
            }
            else {
                self.totalPerPersonText.isHidden = true
                self.totalPerPersonLabel.isHidden = true
            }
        })
    }
    
    func updateChange() {
        if(!changingValues) {
            changingValues = true
            UIView.animate(withDuration: 1.0) {
                self.resultView.alpha = 0.5
            }
            self.totalPerPersonLabel.text = "0.00"
            self.totalLabel.text = "0.00"
            self.tipAmountLabel.text = "0.00"
        }
    }

    func changeMode(mode: UIUserInterfaceStyle, keyBoard: UIKeyboardAppearance,  color: UIColor, text: UIColor) {
        billAmountTextField.keyboardAppearance = keyBoard
        calcButton.setTitleColor(text, for: .normal)
        view.backgroundColor = color
        view.window?.backgroundColor = color
        UIApplication.shared.windows.forEach {
            window in window.overrideUserInterfaceStyle = mode
        }
    }
    
    func additionalUpdates() {
        tipSlider.value = Float(tipPercentage[tipPIndex])
        tipControl.selectedSegmentIndex = tipPIndex
        tipControl.setTitle(String(tipPercentage[0]) + "%", forSegmentAt: 0)
        tipControl.setTitle(String(tipPercentage[1]) + "%", forSegmentAt: 1)
        tipControl.setTitle(String(tipPercentage[2]) + "%", forSegmentAt: 2)
        tipLabel.text = String(tipPercentage[tipPIndex]) + "%"
        changingValues = true
        updateChange()
    }
    
    func changeMode(changeToDark: Bool) {
        if(changeToDark) {
            changeMode(mode: .dark, keyBoard: .dark, color: UIColor.black, text: .white)
        }
        else {
            changeMode(mode: .light, keyBoard: .light, color: UIColor.white, text: .black)
        }
    }
}

