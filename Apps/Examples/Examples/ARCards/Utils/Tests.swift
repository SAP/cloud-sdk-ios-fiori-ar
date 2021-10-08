//
//  TestCases.swift
//  Examples
//
//  Created by O'Brien, Patrick on 5/5/21.
//

import SwiftUI

public enum Tests {
    public static let carEngineCardItems = [StringIdentifyingCardItem(id: "WasherFluid",
                                                                      title_: "Recommended Washer Fluid",
                                                                      subtitle_: "Rain X",
                                                                      detailImage_: nil,
                                                                      actionText_: nil,
                                                                      icon_: nil),
                                            
                                            StringIdentifyingCardItem(id: "Coolant",
                                                                      title_: "Genuine Coolant",
                                                                      subtitle_: "Price: 20.99",
                                                                      detailImage_: nil,
                                                                      actionText_: "Order",
                                                                      icon_: "cart.fill"),
                                            
                                            StringIdentifyingCardItem(id: "Oilstick",
                                                                      title_: "Check Oil Stick",
                                                                      subtitle_: "Suggested Date: 06/02/2021",
                                                                      detailImage_: UIImage(named: "Schedule")?.pngData(),
                                                                      actionText_: "Schedule",
                                                                      icon_: "calendar"),
                                            
                                            StringIdentifyingCardItem(id: "BrakeFluid",
                                                                      title_: "Brake Fluid Manual",
                                                                      subtitle_: nil,
                                                                      detailImage_: nil,
                                                                      actionText_: "Open Car Manual",
                                                                      icon_: "book.fill"),
                                            
                                            StringIdentifyingCardItem(id: "Battery",
                                                                      title_: "Jump Battery",
                                                                      subtitle_: "Instructional Video",
                                                                      detailImage_: UIImage(named: "Battery")?.pngData(),
                                                                      actionText_: "Play Video",
                                                                      icon_: "play.fill"),
                                            
                                            StringIdentifyingCardItem(id: "Fusebox",
                                                                      title_: "Service App",
                                                                      subtitle_: "Change Fuse",
                                                                      detailImage_: nil,
                                                                      actionText_: "Open App",
                                                                      icon_: "link")]
}
