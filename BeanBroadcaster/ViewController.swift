//
//  ViewController.swift
//  BeanBroadcaster
//
//  Created by Evan Mckee on 9/3/14.
//  Copyright (c) 2014 Evan Mckee. All rights reserved.
//



import UIKit



class ViewController: UIViewController, PTDBeanManagerDelegate, PTDBeanDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    let beanManager = PTDBeanManager()
    
    var bean: PTDBean?
    var scratchVal: ScratchData?
    var beanList: [BeanContainer] = []
    var autoConnect: Bool = true
    var globalDataType = ScratchData.DataType.UTF8
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var connectionStatusLabel: UILabel!
    @IBOutlet weak var consoleTextView: UITextView!
    @IBOutlet weak var targetScratchNumberLabel: UILabel!
    @IBOutlet weak var scratchUpdateTextField: UITextField!

    @IBOutlet weak var typeButtonField: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        beanManager.delegate = self;
        typeButtonField.setTitle(globalDataType.description(), forState: UIControlState.Normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

    
    

    
    
//////////////////////////////////////////////////////////////////////
    //   Delegate stuff
    
    // PTDBeanManager Delegate stuff
    
    func beanManagerDidUpdateState(beanManager: PTDBeanManager!) {
        if beanManager.state == BeanManagerState.PoweredOn {
            beanManager.startScanningForBeans_error(nil)
            
            let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(15 * Double(NSEC_PER_SEC)))
            dispatch_after(delay, dispatch_get_main_queue(), {
                self.autoReconnect()
            })
            printToIphone("Scanning for Beans")
        } else if beanManager.state == BeanManagerState.Resetting {
                printToIphone("BeanManager resetting")
        } else if beanManager.state == BeanManagerState.PoweredOff {
            printToIphone("BeanManager powered off")
        } else {
            printToIphone("BeanManager: something went wrong")
        }
    }


    func BeanManager(beanManager: PTDBeanManager!, didDiscoverBean bean: PTDBean!, error: NSError!) {
        printToIphone("Discovered bean: \(bean.name)")
        
        // check if bean is new, update it if it isnt
        var matchingBeanIndex: Int? = nil
        for (index, beanInList) in enumerate(beanList) {
            if beanInList.bean.identifier == bean.identifier {
                matchingBeanIndex = index
                continue
            }
        }
        if matchingBeanIndex != nil {
            beanList[matchingBeanIndex!].bean = bean
            beanList[matchingBeanIndex!].isSelected = false
        } else {
            beanList.append(BeanContainer(bean: bean, shouldConnect: true, isSelected: false))
        }
        //should check core data or elsewhere here or in init of BC to see if shouldConnect should be true

        if autoConnect == true && beanList.last!.shouldConnect == true {
            connectToBean(beanList.last!.bean)
        }
        checkGlobalConnectionStatus()
    }
    
    func BeanManager(beanManager: PTDBeanManager!, didConnectToBean bean: PTDBean!, error: NSError!){
        printToIphone("Connected to \(bean.name)")
        checkGlobalConnectionStatus()
    }
    
    func BeanManager(beanManager: PTDBeanManager!, didDisconnectBean bean: PTDBean!, error: NSError!){
        printToIphone("Disconnected from \(bean.name)")
        checkGlobalConnectionStatus()
    }
    // end of bean manager delegate stuff

    // PTDBean delegates
   
    func bean(bean: PTDBean!, didUpdateScratchBank bank: Int, data: NSData!) {
        let index = findBeanIndex(bean)
        if index == nil {
            println("bean:didUpdateScratchBank failed because \(bean.name) not found in beanList")
            return
        }
        beanList[index!].savedScratchVals[bank].data = data
        beanList[index!].savedScratchVals[bank].currentValueWasSet = false
    }
    
    //UITextField delegate:
    func textFieldShouldReturn(field:UITextField){
        if (field == self.scratchUpdateTextField) {
            scratchUpdateTextField.resignFirstResponder()
        }
    }
    
    ////////////////////////////////////////////////////////////////////
    // TableView Data Source
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beanList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let thisBean = beanList[indexPath.row]
        var cell: BeanSelectionCell = tableView.dequeueReusableCellWithIdentifier("beanTableCell", forIndexPath: indexPath) as BeanSelectionCell
        cell.beanNameLabel.text = thisBean.bean.name
        if thisBean.bean.state == BeanState.ConnectedAndValidated {
            cell.statusLabel.text = "Connected"
        } else if thisBean.bean.state == BeanState.AttemptingConnection {
            cell.statusLabel.text = "Connecting"
        } else {
            cell.statusLabel.text = "Disconnected"
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        if thisBean.isSelected == true {
            cell.backgroundColor = UIColor.cyanColor()
        } else {
            cell.backgroundColor = UIColor.clearColor()
        }
        cell.configButton.tag = indexPath.row
        
        return cell
    }
    
    // TableView Delegate


    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var cell = tableView.cellForRowAtIndexPath(indexPath) as BeanSelectionCell
        beanList[indexPath.row].isSelected = !beanList[indexPath.row].isSelected
        if beanList[indexPath.row].isSelected {
            cell.backgroundColor = UIColor.cyanColor()
        } else {
            cell.backgroundColor = UIColor.clearColor()
        }
    }
/*
    func tableView(tableView: UITableView, didUnhighlightRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
*/

    
    
    
    
/////////////////////////////////////////////////////
    ////////    IBACTIONS   ??????????????????
    
    
    @IBAction func broadcastButtonPressed(sender: UIButton) {
        scratchUpdateTextField.resignFirstResponder()
        sendDataToSelectedBeans(targetScratchNumberLabel.text!.toInt()!, message: scratchUpdateTextField.text)
        scratchUpdateTextField.resignFirstResponder()
    }
    
    @IBAction func readButtonPressed(sender: UIButton) {
        let num:Int = targetScratchNumberLabel.text!.toInt()!
        //updateScratchDisplay(num) //this should take a target var
        updateScratchBanksForSelectedBeans(num)
    }
    @IBAction func scratchNumberStepperPressed(sender: UIStepper) {
        self.targetScratchNumberLabel.text = Int(sender.value).description
    }
    
    
    @IBAction func managementButtonPressed(sender: UIButton) {
        //for management view launch. toggles autoconnect for now
//        autoConnect = !autoConnect
//        printToIphone("autoConnect set to \(autoConnect)")
        
    }

    
    @IBAction func typeButtonPressed(sender: UIButton) {
        //should toggle type var, possibly class var of MessageConverter class
        // for now it will just toggle a dummy (typeDummy)
        globalDataType = globalDataType.next()
        typeButtonField.setTitle(globalDataType.description(), forState: UIControlState.Normal)
    }


    
    
    ///////////////////////////////////////
    // segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let senderIndex = (sender! as UIButton).tag
        let NavVC = segue.destinationViewController as UINavigationController
        let mtvc = NavVC.viewControllers[0] as ManagementTableViewController
        mtvc.beanContainer = beanList[senderIndex]
    }
    
    ///////////////////////////////////////
    // bean interaction
    
    
    func sendDataToSelectedBeans(scratchNum:NSNumber, message:String) {
        for beanItem in beanList {
            if beanItem.isSelected == true {
                let rawData = ScratchData.strToDataWithTrail(message) // implement something here for conversion of different types
                beanItem.bean.setScratchBank(Int(scratchNum), data: rawData)
                beanItem.savedScratchVals[Int(scratchNum)].data = rawData
                beanItem.savedScratchVals[Int(scratchNum)].type = ScratchData.DataType.UTF8
                beanItem.savedScratchVals[Int(scratchNum)].currentValueWasSet = true
            }
        }
    }
    
    
    func connectToBean(bean:PTDBean){
        var error: NSError?
        bean.delegate = self
        beanManager.connectToBean(bean, error: &error)
        if error != nil {
            println("connectToBean: Error connecting to \(bean.name),  \(error)")
        }
    }
    
    
    func updateScratchBanksForSelectedBeans(scratchNumber:Int){
        //var beansToRevisit:[NSUUID] = [] // this is used in case the list changes while waiting for
        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
        for listedBean in beanList {
            if listedBean.isSelected {
                listedBean.bean.readScratchBank(scratchNumber)
                //beansToRevisit.append(listedBean.bean.identifier)
                
                dispatch_after(delay, dispatch_get_main_queue(), {
                    if listedBean.savedScratchVals[scratchNumber].data != nil {
                        self.printToIphone("Bean: \( listedBean.bean.name ) Number: \(scratchNumber), Value: \(listedBean.savedScratchVals[scratchNumber].text)")
                    } else {
                        println("scratch \(scratchNumber) for \(listedBean.bean.name) still nil")
                    }
                })
            }
        }
    }
    
    
    
    ///////////////////////////////////////
    // assorted helpers
    
    
    func printToIphone(message:String) {
        consoleTextView.text = String(consoleTextView.text) + "\n" + message
    }


    
//    func updateScratchDisplay(scratchNumber:Int){
//
//        if beanList.isEmpty == false && beanList[0].bean.state == BeanState.ConnectedAndValidated {
//            beanList[0].bean.readScratchBank(scratchNumber)
//            let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
//            dispatch_after(delay, dispatch_get_main_queue(), {
//                if self.beanList[0].savedScratchVals[scratchNumber].data != nil {
//                    self.printToIphone("Bean: \( self.beanList[0].bean.name ) Number: \(scratchNumber), Value: \(self.beanList[0].savedScratchVals[scratchNumber].text)")
//                } else {
//                    println("scratchlastUpdated still nil")
//                }
//            })
//        } else {
//            println("bean nil")
//        }
//    }
    
    func checkGlobalConnectionStatus() -> Int{
        tableView.reloadData()
        var connectedCount = 0
        for beanContainer in beanList {
            if beanContainer.bean.state == BeanState.ConnectedAndValidated {
                connectedCount += 1
            }
        }
        if connectedCount > 0 {
            connectionStatusLabel.text = "(\(connectedCount)/\(beanList.count)) Connected"
            connectionStatusLabel.backgroundColor = UIColor.greenColor()
        } else {
            connectionStatusLabel.text = "(0/\(beanList.count)) Connected"
            connectionStatusLabel.backgroundColor = UIColor.redColor()
        }
        return connectedCount
    }

    
    func autoReconnect(){
        //get beans in need of connection
        //var toConnect:[PTDBean] = []
        if beanList.isEmpty != true && self.autoConnect == true {
            for bc in beanList {
                if bc.shouldConnect == true && (bc.bean.state == BeanState.Discovered || bc.bean.state == BeanState.Unknown) {
                    connectToBean(bc.bean)
                    println("Attempting to autoreconnect to \(bc.bean.name)")
                }
            }
        }
        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(12 * Double(NSEC_PER_SEC)))
        dispatch_after(delay, dispatch_get_main_queue(), {
            self.autoReconnect()
        })
    }
    
    func findBeanIndex(bean:PTDBean) -> Int? {
        for (index,beanContainer) in enumerate(beanList) {
            if beanContainer.bean.identifier == bean.identifier {
                return index
            }
        }
        return nil
    }
    
}



