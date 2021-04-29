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
            
            print("response: \(response)")
            guard let placeMark = response?.mapItems[0].placemark else {
                return
            }
            print("placeMark : \(placeMark)")
            
            let param: [String: Any] = ["lat": placeMark.coordinate.latitude.description,
                                        "lon": placeMark.coordinate.longitude.description,
                                        "appid": "0367480f207592a2a18d028adaac65d2",
                                        "lang": _COUNTRY,
                                        "units": fahrenheitOrCelsius.pameter] //imperial - Fahrenheit
            
            API.init(session: Session.default)
                .request("https://api.openweathermap.org/data/2.5/weather",
                         method: .get,
                         parameters: param,
                         encoding: URLEncoding.default,
                         headers: nil,
                         interceptor: nil,
                         requestModifier: nil) { json in
                    
                    print("addLocation: \(json)")
                
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

extension AddLocationVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.searchBar.resignFirstResponder()
    }
}
