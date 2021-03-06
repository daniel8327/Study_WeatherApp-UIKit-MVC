//
//  DetailWeatherBaseVC.swift
//  Weather
//
//  Created by moonkyoochoi on 2021/05/06.
//

import CoreLocation
import UIKit

class DetailWeatherPageVC: UIViewController {
    
    private(set) var items: [LocationVO] {
        didSet {
            pageControl.numberOfPages = items.count
        }
    }
    
    private var index: Int {
        didSet {
            self.pageControl.currentPage = index
        }
    }
    
    private lazy var pageVC: UIPageViewController = {
        
        let pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [:])
        
        addChild(pageVC)
        view.addSubview(pageVC.view)
        pageVC.didMove(toParent: self)
        
        pageVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageVC.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        return pageVC
    }()
    
    private lazy var pageControl: UIPageControl = {
        
        let pageControl = UIPageControl(frame: .zero)
        
        view.addSubview(pageControl)
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageControl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageControl.topAnchor.constraint(equalTo: pageVC.view.bottomAnchor),
            pageControl.heightAnchor.constraint(equalToConstant: 100),
            pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pageControl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        let weatherButton = UIButton(frame: .zero)
        let locationsButton = UIButton(frame: .zero)
        
        weatherButton.setImage(UIImage(named: "theweather.png"), for: .normal)
        weatherButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToWeb)))
        weatherButton.isUserInteractionEnabled = true
        
        locationsButton.setImage(UIImage(systemName: "list.bullet"), for: .normal)
        locationsButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addLocation)))
        locationsButton.isUserInteractionEnabled = true
        
        pageControl.addSubview(weatherButton)
        pageControl.addSubview(locationsButton)
        
        weatherButton.translatesAutoresizingMaskIntoConstraints = false
        locationsButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            weatherButton.leadingAnchor.constraint(equalTo: pageControl.leadingAnchor, constant: 16),
            weatherButton.centerYAnchor.constraint(equalTo: pageControl.centerYAnchor),
            weatherButton.heightAnchor.constraint(equalToConstant: 25),
            weatherButton.widthAnchor.constraint(equalToConstant: 25),
            
            locationsButton.trailingAnchor.constraint(equalTo: pageControl.trailingAnchor, constant: -16),
            locationsButton.centerYAnchor.constraint(equalTo: pageControl.centerYAnchor),
            locationsButton.heightAnchor.constraint(equalToConstant: 25),
            locationsButton.widthAnchor.constraint(equalToConstant: 25),
        ])
        
        return pageControl
    }()
    
    init(items: [LocationVO], index: Int) {
        self.items = items
        self.index = index
        //super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [:])
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ????????? X ????????? ????????????????????? modal ????????? PageViewController??? ?????????????????? ??????????????????
        // PageControl ???????????? ????????? ????????? ????????? ????????? ???????????? ???????????????. https://swiftking.tistory.com/12
        self.view.backgroundColor = .systemBackground
        
        pageVC.dataSource = self
        pageVC.delegate = self
        
        pageControl.numberOfPages = items.count
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkItems()
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
    
    // MARK: Selector
    
    @objc func goToWeb() {
        UIApplication.shared
            .open(URL(string: "https://weather.com/")!,
                  options: [:],
                  completionHandler: nil)
    }
    
    @objc func addLocation() {
        let vc = MainVC()
        
        vc.modalClosedAlias = { index, items in
            self.index = index
            self.items = items
            self.checkItems()
        }
        
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    // MARK: User Functions
    
    func checkItems() {
        
        if items.isEmpty {
            addLocation()
        } else {
            pageVC.setViewControllers([instantiateViewController(index: self.index)] as [UIViewController],
                                    direction: .forward,
                                    animated: true) { _ in
                //self.setupPageControl()
                
                if #available(iOS 14.0, *) {
                    self.pageControl.setIndicatorImage(UIImage(systemName: "location.fill"), forPage: 0)
                }
            }
        }
    }
    
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

//    /// presentationCount, presentationIndex ??? ???????????? setupPageControl, UIPageViewControllerDelegate ??? ????????? ????????? ??????.
//    func presentationCount(for pageViewController: UIPageViewController) -> Int {
//        return items.count // ooo??????
//    }
//
//    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
//        return self.index // ooo ?????? ?????????
//    }
}

extension DetailWeatherPageVC: UIPageViewControllerDelegate {
    
    //  ???????????? ???????????? ????????? ???????????? ??????????????????. ????????? ????????? ???????????? ?????????????????? ?????????????????????
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool
    ) {
        //  ????????? ????????? ???????????? ?????? ??????
        guard completed else { return }

        //  ????????? ????????? ?????? ????????? ????????? ???????????? ?????????????????? ??????????????????
        if let vc = pageViewController.viewControllers?.first as? DetailWeatherVC {
            self.pageControl.currentPage = vc.index
        }
    }
}
