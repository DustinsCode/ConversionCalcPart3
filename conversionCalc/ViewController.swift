//
//  ViewController.swift
//  conversionCalc
//
//  Created by Dustin Thurston and Dylan Kernohan
//  9/17/18.
//  Copyright © 2018 dndmobile. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SettingsViewControllerDelegate,  HistoryTableViewControllerDelegate{
    
    func selectEntry(entry: Conversion) {
        self.mode = entry.mode
        self.fromField.text = "\(entry.fromVal)"
        self.fromLabel.text = entry.fromUnits
        self.toField.text = "\(entry.toVal)"
        self.toLabel.text = entry.toUnits
    }
    
    //Functions for the delegate handling
    func settingsChanged(fromUnits: LengthUnit, toUnits: LengthUnit, fromLengthIndex: Int, toLengthIndex: Int) {
        self.fromUnitsLength = fromUnits
        self.toUnitsLength = toUnits
        self.fromLengthIndex = fromLengthIndex
        self.toLengthIndex = toLengthIndex
        
        self.fromLabel.text? = fromUnits.rawValue
        self.toLabel.text? = toUnits.rawValue
    }
    
    //Functions for the delegate handling
    func settingsChanged(fromUnits: VolumeUnit, toUnits: VolumeUnit, fromVolumeIndex: Int, toVolumeIndex: Int) {
        self.fromUnitsVolume = fromUnits
        self.toUnitsVolume = toUnits
        self.fromVolumeIndex = fromVolumeIndex
        self.toVolumeIndex = toVolumeIndex
        
        self.fromLabel.text? = fromUnits.rawValue
        self.toLabel.text? = toUnits.rawValue
    }
    
   
    //Array of conversion instances
//    var entries : [Conversion] = []
    var entries : [Conversion] = [
        Conversion(fromVal: 1, toVal: 1760, mode: .Length, fromUnits: LengthUnit.Miles.rawValue, toUnits:
            LengthUnit.Yards.rawValue, timestamp: Date.distantPast),
        Conversion(fromVal: 1, toVal: 4, mode: .Volume, fromUnits: VolumeUnit.Gallons.rawValue, toUnits:
            VolumeUnit.Quarts.rawValue, timestamp: Date.distantFuture)]
    
    //Tracks mode and current length/volume selections
    var mode = CalculatorMode.Length
    var toUnitsLength = LengthUnit.Meters
    var fromUnitsLength = LengthUnit.Yards
    var toUnitsVolume = VolumeUnit.Liters
    var fromUnitsVolume = VolumeUnit.Gallons
    
    //Indexes to persist picker selections between views and modes
    var fromLengthIndex : Int = 1
    var toLengthIndex : Int = 0
    var fromVolumeIndex : Int = 1
    var toVolumeIndex : Int = 0

    //Outlets for the labels
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var fromField: UITextField!
    @IBOutlet weak var toField: UITextField!
    @IBOutlet weak var toLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = BACKGROUND_COLOR
        //Setting up UITapGesture for making the keyboard go away
        let detectTouch = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(detectTouch)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    //Handles delegates and passing variables between views
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? SettingsViewController {
            
            //initializing variables in SettingsViewController
            if segue.identifier == "settingsSegue" {
                dest.delegate = self
                dest.mode = self.mode
                dest.fromLength = self.fromUnitsLength
                dest.toLength = self.toUnitsLength
                dest.fromVolume = self.fromUnitsVolume
                dest.toVolume = self.toUnitsVolume
                dest.fromLengthIndex = self.fromLengthIndex
                dest.toLengthIndex = self.toLengthIndex
                dest.toVolumeIndex = self.toVolumeIndex
                dest.fromVolumeIndex = self.fromVolumeIndex
                
            }
        }
        
        if let dest = segue.destination as? HistoryTableViewController {
            if segue.identifier == "historySegue" {
                dest.historyDelegate = self
                dest.entries = self.entries
                //dest.mode = self.mode
            }
        }
    }
    
    //Hides the keyboard
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    //Handling the calculate button.  Searches dictionary based on current mode and
    //unit selections
    @IBAction func calculateButtonPressed(_ sender: UIButton) {
        dismissKeyboard()
        
        if mode == .Length{
            if self.fromField.text != "" {
                let key = LengthConversionKey(toUnits: toUnitsLength, fromUnits: fromUnitsLength)
                let conversionVal = lengthConversionTable[key]
                self.toField.text = String(Double(self.fromField.text!)! * conversionVal!)
            }else if self.toField.text != ""{
                let key = LengthConversionKey(toUnits: fromUnitsLength, fromUnits: toUnitsLength)
                let conversionVal = lengthConversionTable[key]
                self.fromField.text = String(Double(self.toField.text!)! * conversionVal!)
            }
            
            let conv = Conversion(fromVal: Double(self.fromField.text!)!, toVal: Double(toField.text!)!, mode: mode, fromUnits: fromUnitsLength.rawValue, toUnits: toUnitsLength.rawValue, timestamp: Date())
            entries.append(conv)
            
        }else if mode == .Volume {
            if self.fromField.text != "" {
                let key = VolumeConversionKey(toUnits: toUnitsVolume, fromUnits: fromUnitsVolume)
                let conversionVal = volumeConversionTable[key]
                self.toField.text = String(Double(self.fromField.text!)! * conversionVal!)
            }else if self.toField.text != ""{
                let key = VolumeConversionKey(toUnits: fromUnitsVolume, fromUnits: toUnitsVolume)
                let conversionVal = volumeConversionTable[key]
                self.fromField.text = String(Double(self.toField.text!)! * conversionVal!)
            }
            
            let conv = Conversion(fromVal: Double(self.fromField.text!)!, toVal: Double(toField.text!)!, mode: mode, fromUnits: fromUnitsVolume.rawValue, toUnits: toUnitsVolume.rawValue, timestamp: Date())
            
            entries.append(conv)
        }
        
        
    }
    
    
   
    @IBAction func FromFieldPressed(_ sender: ConversionCalcTextField) {
        self.toField.text? = ""
    }
    
    @IBAction func ToFieldPressed(_ sender: ConversionCalcTextField) {
        self.fromField.text? = ""
    }
    
    //Clears the fields
    @IBAction func clearButtonPressed(_ sender: UIButton) {
        dismissKeyboard()
        self.fromField.text? = ""
        self.toField.text? = ""
    }
    
    //Switches between volume and length mode
    @IBAction func modeButtonPressed(_ sender: UIButton) {
        
        dismissKeyboard()
        if mode == .Length{
            mode = .Volume
            self.titleLabel?.text? = "Volume Conversion Calculator"
            self.fromLabel?.text? = fromUnitsVolume.rawValue
            self.toLabel.text? = toUnitsVolume.rawValue
            
        }else{
            mode = .Length
            self.titleLabel?.text? = "Length Conversion Calculator"
            self.fromLabel.text? = fromUnitsLength.rawValue
            self.toLabel.text? = toUnitsLength.rawValue
        }
    }
    
    //Handles the cancel button.  It doesn't appear connected, but when i delete this code
    //the cancel and save button no longer work
    @IBAction func cancelButtonPressed(segue: UIStoryboardSegue){

    }
    
}

