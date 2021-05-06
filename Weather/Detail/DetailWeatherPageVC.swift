//
//  DetailWeatherPageVC.swift
//  Weather
//
//  Created by moonkyoochoi on 2021/05/06.
//

import CoreLocation
import UIKit

class DetailWeatherPageVC: UIPageViewController {
    
    private(set) var items: [LocationVO]
    private let index: Int
    
    init(items: [LocationVO], index: Int) {
        self.items = items
        self.index = index
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [:])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.delegate = self
        
        self.setViewControllers([getViewController(index: self.index)] as [UIViewController],
                                direction: .forward,
                                animated: true) { _ in
            //self.setupPageControl()
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        for view in view.subviews {
            if view is UIPageControl {
                view.backgroundColor = UIColor.clear
            }
        }
    }
    
    // MARK: User Functions
    
    private func getViewController(index: Int) -> UIViewController {
        
        let object = items[index]
        
        let location = CLLocation(
            latitude: CLLocationDegrees(Double(object.latitude)!),
            longitude: CLLocationDegrees(Double(object.longitude)!)
        )
    
        let vc = DetailWeatherVC(locationName: object.city, locationCode: object.code, location: location, index: index)
    
        vc.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        
        return vc
    }
}

extension DetailWeatherPageVC: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard var index = (viewController as? DetailWeatherVC)?.index else {
            return nil
        }
        
        if index == 0 || index == NSNotFound { return nil }
        
        index -= 1
        return getViewController(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard var index = (viewController as? DetailWeatherVC)?.index else {
            return nil
        }
        
        if index == NSNotFound { return nil }
        
        index += 1
        
        if index ==  items.count { return nil }
        
        return getViewController(index: index)
    }
    
    /// presentationCount, presentationIndex 를 구현하면 setupPageControl 을 할 필요가 없다.
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return items.count // ooo갯수
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return self.index // ooo 초기 셋팅값
    }
}
