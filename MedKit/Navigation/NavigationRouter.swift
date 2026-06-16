//
//  NavigationRouter.swift
//  MedKit
//
//  Created by Ritwik Dev on 30/05/26.
//


import SwiftUI

@Observable
class NavigationRouter {
    var path = NavigationPath()
    
    func navigate(to route: NavigationPathEnum) {
        path.append(route)
    }
    
    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func popToRoot() {
        path = NavigationPath()
    }
}
