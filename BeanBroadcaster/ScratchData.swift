//
//  ScratchData.swift
//  BeanBroadcaster
//
//  Created by Evan Mckee on 9/25/14.
//  Copyright (c) 2014 Evan Mckee. All rights reserved.
//

import Foundation

class ScratchData {
    

    
    var bean: PTDBean
    var number: Int
    var data: NSData
    
    var text:String {
        get {
            //including PLACEHOLDER (Until text slicing improved) for makeshift fix for extra char on messages of length 1 or 2
            var tempVal = NSString(data: self.data, encoding: NSUTF8StringEncoding)
            if tempVal.length > 2 {
                return tempVal
            } else {
                return tempVal
            }
        }
    }
    
    
    init(sendingBean:PTDBean, number:NSNumber, data:NSData){
        self.bean = sendingBean
        self.number = number
        self.data = data
    }
    
    class func strToData(message:String) -> NSData {
        return NSData(data: message.dataUsingEncoding(NSUTF8StringEncoding)!)
    }
    
    class func strToDataWithTrail (message:String) ->NSData {
        let messageWithTrail = message + String(UnicodeScalar(extraDigit.x))
        extraDigit.x = (extraDigit.x < 255 ? extraDigit.x + 1 : 0)
        return NSData(data: messageWithTrail.dataUsingEncoding(NSUTF8StringEncoding)!)
        
    }
    

   //workaround for lack of class variables. This stores the change digit to append to strToDataWithTrail
    struct extraDigit {
        static var x:UInt8 = 0
    }
    
}


