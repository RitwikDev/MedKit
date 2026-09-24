//
//  CalendarPageViewController.swift
//  MedKit
//
//  Created by Ritwik Dev on 13/07/26.
//

import SwiftUI

struct CalendarPageViewController: UIViewControllerRepresentable {
    @Binding var currentDate: Date
    var viewModel: CalendarViewModel
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIPageViewController {
        let pageViewController = UIPageViewController(
            transitionStyle: .pageCurl,
            navigationOrientation: .horizontal,
            options: nil,
        )
        pageViewController.dataSource = context.coordinator
        pageViewController.delegate = context.coordinator
        pageViewController.view.clipsToBounds = false
        
        let initialVC = context.coordinator.makeViewController(for: currentDate)
        pageViewController.setViewControllers([initialVC], direction: .forward, animated: false, completion: nil)
        
        return pageViewController
    }

    func updateUIViewController(_ uiViewController: UIPageViewController, context: Context) {
        if let currentVC = uiViewController.viewControllers?.first as? CalendarHostingController,
           !Calendar.current.isDate(currentVC.pageDate, equalToMonthOf: currentDate) {
            let direction: UIPageViewController.NavigationDirection = currentDate > currentVC.pageDate ? .forward : .reverse
            let targetVC = context.coordinator.makeViewController(for: currentDate)
            uiViewController.setViewControllers([targetVC], direction: direction, animated: true, completion: nil)
        }
    }

    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: CalendarPageViewController
        let calendar = Calendar.current
        
        init(_ parent: CalendarPageViewController) {
            self.parent = parent
        }
        
        func makeViewController(for date: Date) -> CalendarHostingController {
            let contentView = CalendarPageContentView(date: date)
                .environment(parent.viewModel)
            return CalendarHostingController(rootView: AnyView(contentView), pageDate: date)
        }
        
        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerBefore viewController: UIViewController,
        ) -> UIViewController? {
            guard let currentVC = viewController as? CalendarHostingController else { return nil }
            guard let targetDate = calendar.date(byAdding: .month, value: -1, to: currentVC.pageDate) else { return nil }
            return makeViewController(for: targetDate)
        }
        
        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerAfter viewController: UIViewController,
        ) -> UIViewController? {
            guard let currentVC = viewController as? CalendarHostingController else { return nil }
            guard let targetDate = calendar.date(byAdding: .month, value: 1, to: currentVC.pageDate) else { return nil }
            return makeViewController(for: targetDate)
        }
        
        func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            if completed, let visibleVC = pageViewController.viewControllers?.first as? CalendarHostingController {
                parent.currentDate = visibleVC.pageDate
            }
        }
    }
}
