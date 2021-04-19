//
//  ViewController.swift
//  Weather
//
//  Created by 장태현 on 2021/04/17.
//

import CoreData
import CoreLocation
import UIKit


enum FahrenheitOrCelsius: String {
    case Fahrenheit
    case Celsius
}

extension FahrenheitOrCelsius {
    var stringValue: String {
        return "\(self)"
    }
    
    var emoji: String {
        switch self {
        case .Celsius:
            return "℃"
        case .Fahrenheit:
            return "℉"
        }
    }
}

class MainVC: UIViewController {
    
    lazy var locationManager: CLLocationManager = {
    
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()// 포그라운드에서 권한 요청
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
                
        return locationManager
    }()
    
    lazy var locations: [NSManagedObject] = [NSManagedObject]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var currentLocation: String?
    
    lazy var tableView: UITableView = {
        
        let tbv = UITableView()
        
        view.addSubview(tbv)
        tbv.translatesAutoresizingMaskIntoConstraints = false
        tbv.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tbv.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tbv.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tbv.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        //tbv.backgroundColor = .red
        
        tbv.separatorStyle = .none
                
        tbv.delegate = self
        tbv.dataSource = self
        
        // xib 호출 방법1
        if let loadedNib = Bundle.main.loadNibNamed("LocationFooter", owner: self, options: nil) {
            if let view = loadedNib[1] as? UIView {
                tbv.tableFooterView = view
                
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(addLocation),
                                                       name: Notification.Name("ADD_LOCATION"),
                                                       object: nil)
                
                NotificationCenter.default.addObserver(self,
                                                       selector: #selector(changeNotation),
                                                       name: Notification.Name("CHANGE_NOTATION"),
                                                       object: nil)
            }
        }
        
        // xib 호출 방법2
        //if let aa = UINib(nibName: "LocationFooter", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView //xib의 1번째
        /*if let aa = UINib(nibName: "LocationFooter", bundle: nil).instantiate(withOwner: self, options: nil)[1] as? UIView { // xib의 두번째
            tbv.tableFooterView = aa
            
        }*/
        
        return tbv
    }()
    
    var count: Int = 0
    
    var fahrenheitOrCelsius: FahrenheitOrCelsius = .Fahrenheit
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        locations = fetch()
        
        Indicator.INSTANCE.startAnimating()
        
        view.backgroundColor = .systemBackground
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            Indicator.INSTANCE.stopAnimating()

            guard let self = self else {
                return
            }
        }
        
        // 아이폰 설정에서의 위치 서비스가 켜진 상태라면
        if CLLocationManager.locationServicesEnabled() {
            print("위치 서비스 On 상태")
            locationManager.startUpdatingLocation() //위치 정보 받아오기 시작 CLLocationManagerDelegate
            print(locationManager.location?.coordinate)
        } else {
            print("위치 서비스 Off 상태")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 설정된 도시 없으면 물어보기
        if self.locations.isEmpty {
            print("no data")
            let alert = UIAlertController(title: "지역 선택", message: "날씨 정보를 받아볼 지역을 검색하세요.", preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
                self.addLocation()
            }
            let cancelAction = UIAlertAction(title: "취소", style: .cancel)
            alert.addAction(confirmAction)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true)
        }
        
        
        
        
    }
    
    @objc func changeNotation() {
        
        fahrenheitOrCelsius = (fahrenheitOrCelsius == FahrenheitOrCelsius.Celsius) ? .Fahrenheit : .Celsius
        
        // footer 바꾸기
        let footer = self.tableView.tableFooterView as! LocationFooter
        
        let attributeString = NSMutableAttributedString(string: footer.notation.text ?? "")
        
        let str = footer.notation.text!
        
        let r1 = str.range(of: fahrenheitOrCelsius.emoji)!
        // String range to NSRange:
        let n1 = NSRange(r1, in: str)
        
        attributeString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: n1)

        footer.notation.attributedText = attributeString
        
        // 전체 리스트 바꾸기
        
        
    }
    
    @objc func addLocation() {
        
        // 도시 검색
        let vc = AddLocationVC()
        
        vc.saveDelegate = self // SaveLocationDelegate
        
        vc.saveLocationAlias = { locationElements in //[weak self] locationElements in
            self.save(cityName: locationElements.0, cityCode: locationElements.1)
        }
        self.present(vc, animated: true)
    }
    
    /// CoreData Fetch
    /// - Returns: [Location]
    func fetch() -> [NSManagedObject] {
        let context = _AD.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Location")
        
        // 정렬 속성
        do {
            let sort = NSSortDescriptor(key: "regdate", ascending: false)
            fetchRequest.sortDescriptors = [sort]
            
            let result = try context.fetch(fetchRequest)
            
            return result
        } catch let error {
            print(error.localizedDescription)
            return []
        }
    }
    
    @discardableResult
    func save(cityName: String, cityCode: String) -> Bool {
                
        let context = _AD.persistentContainer.viewContext
        
        let object = NSEntityDescription.insertNewObject(forEntityName: "Location", into: context)
        
        object.setValue(cityName, forKey: "city")
        object.setValue(cityCode, forKey: "code")
        object.setValue(Date(), forKey: "regdate")
        
        do {
            try context.save()
            locations.insert(object, at: 0)
            //list.append(object)
            return true
        } catch {
            context.rollback()
            return false
        }
    }
    
    func delete(object: NSManagedObject) -> Bool {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        context.delete(object)
        
        do {
            try context.save()
            return true
        } catch {
            context.rollback()
            return false
        }
    }
    
    func edit(object: NSManagedObject, city: String, cityCode: String) -> Bool {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        object.setValue(city, forKey: "city")
        object.setValue(cityCode, forKey: "code")
        object.setValue(Date(), forKey: "regdate")
        
        do {
            try context.save()
            return true
        } catch {
            context.rollback()
            return false
        }
    }
    
    func convertToAddressWith(coordinate: CLLocation) {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(coordinate) { (placemarks, error) -> Void in
            if error != nil {
                NSLog("\(error)")
                return
            }
            
            guard let placemark = placemarks?.first,
                  let addrList = placemark.addressDictionary?["FormattedAddressLines"] as? [String]
            else { return }
                  
            let address = addrList.joined(separator: " ")
            
            print(address)
            print("placemark: \(placemark)")
            
            self.currentLocation = placemark.name
            
            let headerView = UITableViewCell(style: .subtitle, reuseIdentifier: "Header")
            headerView.textLabel?.text = self.currentLocation
            headerView.detailTextLabel?.text = placemark.country ?? "UnKnown"
            
            self.tableView.tableHeaderView = headerView
        }
    }
}

extension MainVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell!
        if let cell2 = tableView.dequeueReusableCell(withIdentifier: "Cell") {
            cell = cell2
        } else {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
            cell.separatorInset = UIEdgeInsets.zero // https://zeddios.tistory.com/235
        }
        
        let record = locations[indexPath.row]
        
        cell.textLabel?.text = record.value(forKey: "city") as? String
        cell.detailTextLabel?.text = record.value(forKey: "code") as? String
        
        return cell
    }}

extension MainVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(indexPath.row) selected")
        
        let object = locations[indexPath.row]
        let city = object.value(forKey: "city") as? String
        let code = object.value(forKey: "code") as? String
        
        let alert = UIAlertController(title: "Modify", message: nil, preferredStyle: .alert)
        
        alert.addTextField { $0.text = city }
        alert.addTextField { $0.text = code }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { (_) in
            guard let city = alert.textFields?.first?.text, let code = alert.textFields?.last?.text else {
                return
            }
            
            if self.edit(object: object, city: city, cityCode: code) {
                //self.tableView.reloadData()
                
                let cell = self.tableView.cellForRow(at: indexPath)
                cell?.textLabel?.text = city
                cell?.detailTextLabel?.text = code
                
                self.tableView.moveRow(at: indexPath, to: IndexPath(item: 0, section: 0))
            }
        }))
        self.present(alert, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let object = locations[indexPath.row]
        
        if self.delete(object: object) {
            //tableView.deleteRows(at: [indexPath], with: .fade)
            locations.remove(at: indexPath.row)
        }
    }
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        let object = locations[indexPath.row]
//
//        let uvc = self.storyboard?.instantiateViewController(identifier: "LogVC") as! LogVC
//        uvc.board = (object as! BoardMO)
//
//        self.show(uvc, sender: self)
    }
}

extension MainVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = manager.location {
            count += 1
            
            convertToAddressWith(coordinate: loc)
            print("\(count): \(loc.coordinate.longitude)")
            print("\(count): \(loc.coordinate.latitude)")
        }
    }
}

extension MainVC: SaveLocationDelegate {
    func requestSave(locationElements: (String, String, String)) {
        self.save(cityName: locationElements.0, cityCode: locationElements.1)
    }
}
