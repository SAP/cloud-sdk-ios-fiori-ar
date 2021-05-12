//
//  TestCases.swift
//  Examples
//
//  Created by O'Brien, Patrick on 5/5/21.
//

import SwiftUI

// TODO: Improve Test Examples
public enum Tests {
    
    public static let carEngineCardItems = [StringIdentifyingCardItem(id: "WasherFluid",
                                                                      title_: "Recommended Washer Fluid",
                                                                      descriptionText_: "Rain X",
                                                                      detailImage_: nil,
                                                                      actionText_: nil,
                                                                      icon_: nil),
                                            
                                            StringIdentifyingCardItem(id: "Coolant",
                                                                      title_: "Genuine Honda Coolant",
                                                                      descriptionText_: "Price: 20.99",
                                                                      detailImage_: Image("Coolant"),
                                                                      actionText_: "Order",
                                                                      icon_: Image(systemName: "cart.fill")),
                                            
                                            StringIdentifyingCardItem(id: "OilStick",
                                                                      title_: "Check Oil Stick",
                                                                      descriptionText_: "Suggested Date: 06/02/2021",
                                                                      detailImage_: nil,
                                                                      actionText_: "Schedule",
                                                                      icon_: Image(systemName: "calendar")),
                                            
                                            StringIdentifyingCardItem(id: "BrakeFluid",
                                                                      title_: "Brake Fluid Manual",
                                                                      descriptionText_: nil,
                                                                      detailImage_: nil,
                                                                      actionText_: "Open Manual",
                                                                      icon_: Image(systemName: "book.fill")),
                                            
                                            StringIdentifyingCardItem(id: "Battery",
                                                                      title_: "Jump Battery",
                                                                      descriptionText_: "Instructional Video",
                                                                      detailImage_: Image("Battery"),
                                                                      actionText_: "Play Video",
                                                                      icon_: Image(systemName: "play.fill")),
                                            
                                            StringIdentifyingCardItem(id: "Fusebox",
                                                                      title_: "Honda Service App",
                                                                      descriptionText_: "Change Fuse",
                                                                      detailImage_: nil,
                                                                      actionText_: "Open App",
                                                                      icon_: Image(systemName: "link"))]
    
}
