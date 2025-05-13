//
//  SolemateApp.swift
//  Solemate
//
//  Created by sashank.yalamanchili on 29.04.25.
//

import SwiftUI

@main
struct SolemateApp: App {
    
    init() {
        HealthManager.shared.requestAuthorization()
    }
    
    var body: some Scene {
        WindowGroup {
            Root()
        }
    }
}
