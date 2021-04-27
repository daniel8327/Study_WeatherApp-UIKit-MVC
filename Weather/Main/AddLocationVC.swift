//
//  AddLocationVC.swift
//  Weather
//
//  Created by 장태현 on 2021/04/18.
//

import MapKit
import UIKit

typealias SaveLocationAlias = ([String]) -> Void
protocol SaveLocationDelegate: class { func requestSave(locationElements: [String]) }

class AddLocationVC: UIViewController {
    
    static let identifier = "AddLocationVC"
    private var searchCompleter = MKLocalSearchCompleter()
    private var searchResults = [MKLocalSearchCompletion]()
    
    weak var saveDelegate: SaveLocationDelegate?
    var saveLocationAlias: SaveLocationAlias?
    
    var guideLabel: UILabel!
    
    lazy var searchBar: UISearchBar = {
        let aa = UISearchBar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
        
        view.addSubview(aa)
        aa.translatesAutoresizingMaskIntoConstraints = false
        aa.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        aa.topAnchor.constraint(equalTo: guideLabel.bottomAnchor).isActive = true
        aa.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        aa.delegate = self
        aa.showsCancelButton = true
        aa.becomeFirstResponder()
        return aa
    }()
    
    lazy var searchResultTable: UITableView = {
        
        let tbv = UITableView()
        tbv.separatorStyle = .none
        
        view.addSubview(tbv)
        tbv.translatesAutoresizingMaskIntoConstraints = false
        tbv.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tbv.topAnchor.constraint(equalTo: searchBar.bottomAnchor).isActive = true
        tbv.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tbv.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        tbv.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        return tbv
    }()
    
    
    //var delegate: SearchViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = UILabel(frame: .zero)
        guideLabel = label
        
        label.text = "Enter city, zip code, airport lcoation"
        label.textAlignment = .center
        label.textColor = .lightGray
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        label.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        view.backgroundColor = .systemBackground
        
        searchBar.delegate = self
        
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .query
        
        searchResultTable.delegate = self
        searchResultTable.dataSource = self
    }
}

extension AddLocationVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            searchResults.removeAll()
            searchResultTable.reloadData()
        }
      // 사용자가 search bar 에 입력한 text를 자동완성 대상에 넣는다
        searchCompleter.queryFragment = searchText
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension AddLocationVC: MKLocalSearchCompleterDelegate {
  // 자동완성 완료시 결과를 받는 method
  func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        searchResultTable.reloadData()
    }
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}

extension AddLocationVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        else { fatalError() }
        
        let searchResult = searchResults[indexPath.row]
        cell.textLabel?.text = searchResult.title
        return cell
    }
    
}

extension AddLocationVC: UITableViewDelegate {
  // 선택된 위치의 정보 가져오기
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedResult = searchResults[indexPath.row]
        let searchRequest = MKLocalSearch.Request(completion: selectedResult)
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            guard error == nil else {
                print(error?.localizedDescription)
                return
            }
            guard let placeMark = response?.mapItems[0].placemark else {
                return
            }
            
            // CoreData 저장 델리게이트 SaveLocationDelegate
            self.saveDelegate?.requestSave(locationElements: [placeMark.title ?? "", "", placeMark.coordinate.longitude.description, placeMark.coordinate.latitude.description])
                
            print("placeMark : \(placeMark)")
//            let coordinate = Coordinate(coordinate: placeMark.coordinate)
//            self.delegate?.userAdd(newLocation: Location(coordinate: coordinate, name: "\(placeMark.locality ?? selectedResult.title)"))
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension AddLocationVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.searchBar.resignFirstResponder()
    }
}