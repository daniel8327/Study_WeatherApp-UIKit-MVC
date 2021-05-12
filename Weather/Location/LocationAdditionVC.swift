//
//  AddLocationVC.swift
//  Weather
//
//  Created by 장태현 on 2021/04/18.
//

import MapKit
import UIKit

import Alamofire
import SwiftyJSON

typealias SaveLocationAlias = (LocationVO) -> Void
protocol SaveLocationDelegate: class { func requestSave(vo: LocationVO) }

class LocationAdditionVC: UIViewController {
    
    static let identifier = "AddLocationVC"
    private var searchCompleter = MKLocalSearchCompleter()
    private var searchResults = [MKLocalSearchCompletion]()
    
    weak var saveDelegate: SaveLocationDelegate?
    var saveLocationAlias: SaveLocationAlias?
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
        
        view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.topAnchor.constraint(equalTo: view.topAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        searchBar.prompt = "Enter city, zip code, airport lcoation"
        
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.becomeFirstResponder()
        return searchBar
    }()
    
    lazy var searchResultTable: UITableView = {
        
        let tbv = UITableView()
        tbv.separatorStyle = .none
        
        view.addSubview(tbv)
        tbv.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tbv.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tbv.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tbv.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tbv.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        tbv.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        return tbv
    }()
    
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        searchBar.delegate = self
        
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .query
        
        searchResultTable.delegate = self
        searchResultTable.dataSource = self
    }
    
    // MARK: User Functions
    
    func manupulateResult(completion: MKLocalSearchCompletion) {
        
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            
            guard error == nil else {
                Alert.show(parent: nil, title: "Error", message: error!.localizedDescription)
                return
            }
            
            guard let placeMark = response?.mapItems[0].placemark else {
                return
            }
            print("placeMark : \(placeMark)")
            
            let param: [String: Any] = ["lat": placeMark.coordinate.latitude.description,
                                        "lon": placeMark.coordinate.longitude.description]
            
            API.init(session: Session.default)
                .request(API.WEATHER,
                         method: .get,
                         parameters: param,
                         encoding: URLEncoding.default,
                         headers: nil,
                         interceptor: nil,
                         requestModifier: nil) { json in
                    
                    //print("addLocation: \(json)")
                
                    // CoreData 저장 델리게이트 SaveLocationDelegate
                    self.saveDelegate?
                        .requestSave(
                            vo: LocationVO(
                                currentArea: false,
                                city: placeMark.title ?? json["name"].stringValue,
                                code: json["id"].stringValue,
                                longitude: json["coord"]["lon"].stringValue,
                                latitude: json["coord"]["lat"].stringValue,
                                recent_temp: json["main"]["temp"].intValue,
                                timezone: json["timezone"].int64Value
                            )
                        )
                    
                    self.dismiss(animated: true, completion: nil)
                }
        }
    }
}

extension LocationAdditionVC: UISearchBarDelegate {
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

extension LocationAdditionVC: MKLocalSearchCompleterDelegate {
    
  // 자동완성 완료시 결과를 받는 method
  func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        searchResultTable.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print(error)
        print(error.localizedDescription)
        Alert.show(parent: nil, title: "Error", message: error.localizedDescription)
    }
}

extension LocationAdditionVC: UITableViewDataSource {
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

extension LocationAdditionVC: UITableViewDelegate {
    
  // 선택된 위치의 정보 가져오기
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedResult = searchResults[indexPath.row]
        manupulateResult(completion: selectedResult)
    }
}

extension LocationAdditionVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.searchBar.resignFirstResponder()
    }
}
