//
//  PanicTrackWidgetBundle.swift
//  PanicTrackWidget
//
//  Created by Tofus on 2025/3/19.
//

import WidgetKit
import SwiftUI

@main
struct PanicTrackWidgetBundle: WidgetBundle {
    var body: some Widget {
        PanicTrackWidget()
        PanicTrackWidgetControl()
        PanicTrackWidgetLiveActivity()
    }
}
