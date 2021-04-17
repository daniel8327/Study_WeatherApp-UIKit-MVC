//
//  ViewController.swift
//  Weather
//
//  Created by 장태현 on 2021/04/17.
//

import CoreData
import UIKit

class MainVC: UIViewController {
    
    lazy var locations: [NSManagedObject] = [NSManagedObject]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    lazy var tableView: UITableView = {
        
        let tbv = UITableView()
        
        view.addSubview(tbv)
        tbv.translatesAutoresizingMaskIntoConstraints = false
        tbv.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tbv.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tbv.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tbv.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        tbv.delegate = self
        tbv.dataSource = self
        
        return tbv
    }()

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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        ///TODO: coredata 검색 후 도시 없으면 물어보기
        if self.locations.isEmpty {
            print("no data")
            let alert = UIAlertController(title: "", message: "로케이션 설정", preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "확인", style: .default) { _ in
                
                //self.save(cityName: "Hanam", cityCode: "124421")
            }
            alert.addAction(confirmAction)
            
            self.present(alert, animated: true)
        }
        
        ///TODO: 도시 검색
        let vc = AddLocationVC()
        
        vc.saveDelegate = { result in
            self.save(cityName: result.0, cityCode: result.1)
        }
        self.present(vc, animated: true)
        
        ///TODO: 로케이션 허용후 현 위치 처리
        
        
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
