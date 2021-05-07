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
        
        // 아이폰 X 종류의 디스플레이에서 modal 처리시 PageViewController의 백그라운드가 투명해지므로
        // PageControl 뒷부분에 부모의 화면이 보이기 때문에 배경색을 처리해준다. https://swiftking.tistory.com/12
        self.view.backgroundColor = .systemBackground
        
        self.dataSource = self
        self.delegate = self
        
        self.setViewControllers([instantiateViewController(index: self.index)] as [UIViewController],
                                direction: .forward,
                                animated: true) { _ in
            //self.setupPageControl()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        for view in view.subviews {
            if let pg = view as? UIPageControl {
                if self.traitCollection.userInterfaceStyle == .dark {
                    pg.pageIndicatorTintColor = .gray
                    pg.currentPageIndicatorTintColor = .white
                } else {
                    pg.pageIndicatorTintColor = .lightGray
                    pg.currentPageIndicatorTintColor = .black
                }
            }
        }
    }
    
    // MARK: User Functions
    
    private func instantiateViewController(index: Int) -> UIViewController {
        
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

extension DetailWeatherPageVC: UIPageViewControllerDataSource {
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        
        guard var index = (viewController as? DetailWeatherVC)?.index else {
            return nil
        }
        
        if index == 0 || index == NSNotFound { return nil }
        
        index -= 1
        return instantiateViewController(index: index)
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        
        guard var index = (viewController as? DetailWeatherVC)?.index else {
            return nil
        }
        
        if index == NSNotFound { return nil }
        
        index += 1
        
        if index ==  items.count { return nil }
        
        return instantiateViewController(index: index)
    }

    /// presentationCount, presentationIndex 를 구현하면 setupPageControl, UIPageViewControllerDelegate 을 구현할 필요가 없다.
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return items.count // ooo갯수
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return self.index // ooo 초기 셋팅값
    }
}

extension DetailWeatherPageVC: UIPageViewControllerDelegate {
    
//    //  스와이프 제스쳐가 끝나면 호출되는 메서드입니다. 여기서 페이지 컨트롤의 인디케이터를 움직여줄꺼에요
//    func pageViewController(_ pageViewController: UIPageViewController,
//                            didFinishAnimating finished: Bool,
//                            previousViewControllers: [UIViewController],
//                            transitionCompleted completed: Bool
//    ) {
//        //  페이지 이동이 안됐으면 그냥 종료
//        guard completed else { return }
//
//        //  페이지 이동이 됐기 때문에 페이지 컨트롤의 인디케이터를 갱신해줍시다
//        if let vc = pageViewController.viewControllers?.first {
//            self.pageControl?.currentPage = vc.view.tag
//        }
//    }
}
