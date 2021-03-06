//
//  BeanContainer.swift
//  BeanBroadcaster
//
//  Created by Evan Mckee on 9/27/14.
//  Copyright (c) 2014 Evan Mckee. All rights reserved.
//  

import Foundation



struct BeanContainer {
    
    var bean: PTDBean
    var savedScratchVals = [ScratchData](count:6, repeatedValue: ScratchData())  // since I don't anticipate having to iterate through 
    // these I include an extra instance so indexing is natural in when dealing with scratch numbers.
    var shouldConnect: Bool
    var isSelected: Bool
    
    
    init(bean: PTDBean, shouldConnect: Bool, isSelected: Bool){
        self.bean = bean
        self.shouldConnect = shouldConnect
        self.isSelected = isSelected
    }
    

    
}