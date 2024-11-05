//
//  DashboardView.swift
//  todos-auth-fluent
//
//  Created by Mac Long on 2024-11-04.
//

struct DashboardView {
    let name: String
    
    func render() -> String {
        """
        <section>
            <h1>Welcome Back, \(name)</h1>
            <!-- TODO: Implement Todos Logic -->
        </section>
        """
    }
}
