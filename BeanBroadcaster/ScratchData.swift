//
//  ScratchData.swift
//  BeanBroadcaster
//
//  Created by Evan Mckee on 9/25/14.
//  Copyright (c) 2014 Evan Mckee. All rights reserved.
//
//



import Foundation

class ScratchData {
    
// Container stuff for read values

    var data: NSData? = nil
    var type:DataType? = nil  //nil for unknown- this will (eventually) make a scratch field display the data in whatever is the global type at that moment
    var currentValueWasSet = false // if this app has written to the bean's scratch bank since the last read of it then this is true (the data var is assumed)
    

    
//    init(data:NSData, type: DataType){
//        //self.bean = sendingBean
//        self.type = type
//        self.data = data
//    }
    
    
    enum DataType  {
        // add whatever types are supported for sending/receiving
        case UTF8, hex
        func description() -> String {
            switch self {
            case .UTF8:
                return "UTF8"
            case .hex:
                return "hex"
            }
        }
        func next() -> DataType{
            switch self {
            case .UTF8:
                return DataType.hex
            default:
                return DataType.UTF8
            }
        }
    }
    
    
//  class funcs and related stuff for converting data/messages for sending/receiving
    
    
    class func strToData(message:String) -> NSData {
        return NSData(data: message.dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    
    class func strToDataWithTrail (message:String) ->NSData {
        let messageWithTrail = message + String(UnicodeScalar(extraDigit.x))
        extraDigit.x = (extraDigit.x < 255 ? extraDigit.x + 1 : 0)
        return NSData(data: messageWithTrail.dataUsingEncoding(NSUTF8StringEncoding)!)
        
    }
    
    
   //workaround for lack of/broken class variables. This stores the change digit to append to strToDataWithTrail
    struct extraDigit {
        static var x:UInt8 = 0
    }
    
    
    
    
    
    // need to convert to function eg convertAndTrimMysteriousExtraChar
    var text:String {
        get {
            //including PLACEHOLDER (Until text slicing improved) for makeshift fix for extra char on messages of length 1 or 2
            if self.data == nil {
                println("ScratchData.text found data = nil")
                return ""
            }
            var tempVal = NSString(data: self.data!, encoding: NSUTF8StringEncoding)
            if tempVal!.length > 2 {
                return tempVal!
            } else {
                return tempVal!
            }
        }
    }

    
    
    
}


