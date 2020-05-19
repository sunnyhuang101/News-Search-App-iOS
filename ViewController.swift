//
//  ViewController.swift
//  CSCI571_HW9
//
//  Created by mmlab on 4/16/20.
//  Copyright © 2020 csci571. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import Foundation
import SwiftSpinner
import XLPagerTabStrip
import Toast_Swift
import SwiftyJSON

class  searchResultsController:  UITableViewController, UISearchResultsUpdating, UISearchBarDelegate{
       
    @IBOutlet var tableSearch: UITableView!
    var testSearchCell = [String]() //["amazon", "amazon prime", "amazon fresh", "zoom"]
       var filterSearchCell = [String]()
       var searching = false
    var searchPage:SearchResultPageController!
    override func viewDidLoad() {
           super.viewDidLoad()
             tableSearch.tableFooterView = UIView()
        searchPage = (storyboard!.instantiateViewController(withIdentifier: "searchPage") as? SearchResultPageController)!
            
        

       }
    override func viewWillAppear(_ animated: Bool) {
              super.viewWillAppear(animated)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count >= 3{
            getAutosuggest(query: searchText) { (resArr) in
            self.filterSearchCell = self.testSearchCell.filter({$0.lowercased().prefix(searchText.count)==searchText.lowercased()})
            self.searching = true
            self.tableSearch.reloadData()
            
            }
        }
          // print(searchText)
           
            
    }
    func getAutosuggest(query:String, completionhandler:@escaping ([AnyObject]) -> ()){
        let headers: HTTPHeaders = [
         "Ocp-Apim-Subscription-Key": "8bf9828e27564e9b9b81e35c1da78cb1"
        ]

        Alamofire.request("https://api.cognitive.microsoft.com/bing/v7.0/suggestions?q=\(query)",headers:headers).validate()
            .responseJSON { response in
                switch response.result {
                   case .success(let value):
                       var json = JSON(value)
                        var resultsRaw = json["suggestionGroups"][0]["searchSuggestions"]
                       for item in resultsRaw{
                        var content = item.1["displayText"].string
                        self.testSearchCell.append(content!)
                       }
                        completionhandler([])
                   case .failure(let error):
                       print(error)
                   }
             
                
            }
        
        
    }
    /***
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

         tableSearch.reloadData()
        if let text = searchBar.text {
            for string in testSearchCell {
                if string.contains(text) {
                    filterSearchCell.append(string)
                }
            }
        }

       tableSearch.reloadData()
    }**/
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
           searching = false
           searchBar.text = ""
        //filterSearchCell.removeAll()
           tableSearch.reloadData()
           
       }
    /***
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
         filterSearchCell.removeAll()
        tableSearch.reloadData()

        return true
    }
    **/
    override func numberOfSections(in tableView: UITableView) -> Int {
           // #warning Incomplete implementation, return the number of sections
           return 1
       }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
              if searching{
                return self.filterSearchCell.count
               }
               else{
                   return self.testSearchCell.count
              }
        }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
   
          if ( tableView.dequeueReusableCell(withIdentifier: "cellSearch") != nil ){
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellSearch")
            if searching{
                cell?.textLabel?.text = filterSearchCell[indexPath.row]
                return cell!
           }
            else{
               cell?.textLabel?.text = testSearchCell[indexPath.row]
               return cell!
            }
        }
          else{
            return UITableViewCell()
               
        }
        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.presentingViewController?.navigationController?.pushViewController(searchPage, animated: true)
        searchPage.keyword = (tableSearch.cellForRow(at: indexPath)?.textLabel!.text)!
         self.mySpinner()
      }
    
      func mySpinner() {
                
              SwiftSpinner.show(duration: 3.0, title: "Loading Search results..", animated: true)
                
           }
       
    
}


class HomeViewController: UIViewController, CLLocationManagerDelegate, UISearchControllerDelegate {
    private let refreshControl = UIRefreshControl()
    //let searchBar = UISearchBar()
    var searchController : UISearchController!//UISearchController(searchResultsController: searchResultsController)
     var resultsTableViewController: searchResultsController?
    let tableHeaderView = UIView()
    @IBOutlet weak var tblList: UITableView!
    //@IBOutlet weak var tableSearch: UITableView!
    // var tblList =  UITableView()
    
    var cards: [Card] = []
    var weatherImg = UIImageView()
    var weatherCity = UILabel()
    
    var weatherState = UILabel()
    var weatherTemp = UILabel()
     var weatherDescrip = UILabel()
    var selectedCell = CardCell()
   
    
    private var locationManager:CLLocationManager?
    let stateCodes = ["AL","AK","AZ","AR","CA","CO","CT","DE","DC","FL","GA","HI","ID","IL","IN","IA","KS","KY","LA","ME","MD","MA","MI","MN","MS","MO","MT","NE","NV","NH","NJ","NM","NY","NC","ND","OH","OK","OR","PA","RI","SC","SD","TN","TX","UT","VT","VA","WA","WV","WI","WY"]
    let stateNames = ["Alabama","Alaska","Arizona","Arkansas","California","Colorado","Connecticut","Delaware","District of Columbia","Florida","Georgia","Hawaii","Idaho","Illinois","Indiana","Iowa","Kansas","Kentucky","Louisiana","Maine","Maryland","Massachusetts","Michigan","Minnesota","Mississippi","Missouri","Montana","Nebraska","Nevada","New Hampshire","New Jersey","New Mexico","New York","North Carolina","North Dakota","Ohio","Oklahoma","Oregon","Pennsylvania","Rhode Island","South Carolina","South Dakota","Tennessee","Texas","Utah","Vermont","Virginia","Washington","West Virginia","Wisconsin","Wyoming"]
   
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mySpinner()
        // Do any additional setup after loading the view.
          //let interaction = UIContextMenuInteraction(delegate: self)
         navigationController?.navigationBar.prefersLargeTitles = true
        resultsTableViewController = storyboard!.instantiateViewController(withIdentifier: "resultsTableViewController") as? searchResultsController

        //searchController.obscuresBackgroundDuringPresentation = false
       setSearchTable()
        navigationController!.navigationBar.sizeToFit()
        //navigationItem.hidesSearchBarWhenScrolling = false
        //tableSearch.tableFooterView = UIView()
        getNews() { (resArr) in
           for item in resArr{
            var cardImg = UIImage(named: "the_guardian_icon.png")!
            var imgName = "the_guardian_icon.png"
            if item["img"] as! String != ""{
                let urlString = item["img"] as! String
                let url = NSURL(string: urlString)! as URL
                if let imageData: NSData = NSData(contentsOf: url){
                    cardImg = UIImage(data: imageData as Data)!
                    imgName = item["img"] as! String
                }
            }
           let defaults = UserDefaults.standard
            var savedCards = defaults.object(forKey: "SavedCards") as? [String] ?? [String]()
            var savedNews = defaults.object(forKey: "SavedNews") as? [Any] ?? [Any]()
            var bookmarkImage = UIImage()
            //defaults.removeObject(forKey: "SavedCards")
            //defaults.removeObject(forKey: "SavedNews")
           
            if savedCards.contains(item["articleId"] as! String){
               bookmarkImage = UIImage(systemName: "bookmark.fill")!
              
            }
            else {
              bookmarkImage = UIImage(systemName: "bookmark")!
            }
            //let sectionStr = item["section"] as! String
            self.cards.append(Card(image: cardImg, title: item["title"] as! String, time: item["time"] as! String, section:  item["section"] as! String, bookmark: bookmarkImage, articleId: item["articleId"] as! String, imgName: imgName, date: item["date"] as! String))
            }
            
            self.tblList.reloadData()
            
        }
        setTable()
        getUserLocation()
        
        
    }
    func mySpinner() {
             
           SwiftSpinner.show(duration: 3.0, title: "Loading Home Page..", animated: true)
             
        }
    func setSearchTable(){
        searchController = UISearchController(searchResultsController: resultsTableViewController)
        //self.definesPresentationContext = true
        navigationItem.searchController = searchController
        searchController.delegate = self
        searchController.searchResultsUpdater = resultsTableViewController
    }
    
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
        
      navigationController?.navigationBar.prefersLargeTitles = true
         //searchController.obscuresBackgroundDuringPresentation = true
        //tblList.isHidden = false
        //tableSearch.isHidden = true
       self.tblList.reloadData()
        if tblList.indexPathForSelectedRow != nil{
        let defaults = UserDefaults.standard
         var savedCards = defaults.object(forKey: "SavedCards") as? [String] ?? [String]()
       //  var savedNews = defaults.object(forKey: "SavedNews") as? [Any] ?? [Any]()
         var bookmarkImage = UIImage()
           
           //print(savedCards)
           // print(savedNews)
            
          if savedCards.contains(self.selectedCell.newsArticleId){
            bookmarkImage = UIImage(systemName: "bookmark.fill")!
         }
         else {
           bookmarkImage = UIImage(systemName: "bookmark")!
         }
         
          self.selectedCell.newsBookmarkView.image = bookmarkImage
             //self.tblList.reloadData()
        }
        
      
    }
    
 
    /*
    func tableView(_ tableView: UITableView,
    contextMenuConfigurationForRowAt indexPath: IndexPath,
    point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in

            // "puppers" is the array backing the collection view
            return self.makeContextMenu(for: cards[indexPath.section])
        })
    }*/
   
     
    func setTable(){
        //view.addSubview(tblList)
        tblList.delegate = self
        tblList.dataSource = self
        tblList.rowHeight = 150
        tblList.backgroundColor = UIColor.white
        tblList.sectionFooterHeight = 2
        tblList.sectionHeaderHeight = 2
        //tblList.clipsToBounds = true
        //tblList.register(UITableViewCell.self, forCellReuseIdentifier: "CardCell")
        tblList.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshNewsData(_:)), for: .valueChanged)
        
        tblList.register(CardCell.self, forCellReuseIdentifier: "CardCell")
        
        searchController.searchBar.frame = CGRect(x: 0, y: 0, width: 390, height: 70)
        searchController.searchBar.delegate = resultsTableViewController
        //searchController.searchBar.searchBarStyle = UISearchBar.Style.default
        searchController.searchBar.placeholder = " Enter keyword.."
        //searchController.searchBar.sizeToFit()
        //tableHeaderView.translatesAutoresizingMaskIntoConstraints = true
        tableHeaderView.frame = CGRect(x: 0, y: 0, width: 414, height: 150)
        tableHeaderView.addSubview(searchController.searchBar)
        
        
        tableHeaderView.addSubview(weatherImg)
    
        tblList.tableHeaderView = tableHeaderView
        //tblList.pin(to: view)
       
    }
    @objc private func refreshNewsData(_ sender: Any) {
        // Fetch Weather Data
        getNews() { (resArr) in
            self.cards.removeAll()
           for item in resArr{
           var cardImg = UIImage(named: "the_guardian_icon.png")!
             var imgName = "the_guardian_icon.png"
            if item["img"] as! String != ""{
                let urlString = item["img"] as! String
                let url = NSURL(string: urlString)! as URL
                if let imageData: NSData = NSData(contentsOf: url){
                    cardImg = UIImage(data: imageData as Data)!
                    imgName = item["img"] as! String
                }
            }
            let defaults = UserDefaults.standard
            var savedCards = defaults.object(forKey: "SavedCards") as? [String] ?? [String]()
            var bookmarkImage = UIImage()
            if savedCards.contains(item["articleId"] as! String){
               bookmarkImage = UIImage(systemName: "bookmark.fill")!
              
            }
            else {
              bookmarkImage = UIImage(systemName: "bookmark")!
            }
            //let sectionStr = item["section"] as! String
            self.cards.append(Card(image: cardImg, title: item["title"] as! String, time: item["time"] as! String, section: item["section"] as! String, bookmark: bookmarkImage, articleId: item["articleId"] as! String, imgName: imgName, date: item["date"] as! String))
            }
             
           self.refreshControl.endRefreshing()
          
            self.tblList.reloadData()
        }
    }
    func getNews(completionhandler:@escaping ([AnyObject]) -> ()){
        //var CardArr = [Card]()
        
        
        Alamofire.request("https://hw9104062222.wl.r.appspot.com/getNews")
           // .responseJSON(completionHandler: { response in
            .responseJSON { response in
            if response.result.isSuccess {
               
                let responseArr = response.value as! [AnyObject]
               //print(responseArr)
               completionhandler(responseArr)
                
            } else {
                print("error: \(String(describing: response.error))")
               
                }
            }
        
        
    }
    
    func getWeather(city:String)-> Void{
            Alamofire.request("https://api.openweathermap.org/data/2.5/weather?q=\(city)&units=metric&appid=96543121ec75025ad299e85a4b0df25e").responseJSON(completionHandler: { response in
                   if response.result.isSuccess {
                       // convert data to dictionary array
                       if let result = response.value as? [String: AnyObject ] {
                      
                        let temp = result["main"]?["temp"] as? Double
                        let descripArr = result["weather"] as? [[String:Any]]
                        let descrip = descripArr![0]["main"] as? String
                        let tempInt = Int(round(temp!))
                        
                        self.weatherTemp.text = "\(tempInt)°C"
                        self.weatherDescrip.adjustsFontSizeToFitWidth = true
                        self.weatherDescrip.text = descrip
                        
                        let weatherMap = [
                            "Clouds" : "cloudy_weather.jpg",
                            "Clear" : "clear_weather.jpg",
                            "Snow" : "snowy_weather.jpg",
                            "Rain" : "rainy_weather.jpg",
                            "Thunderstorm" : "thunder_weather.jpg"
                        ]
                        
                        self.weatherImg.layer.cornerRadius = self.weatherImg.frame.width/32.0
                        self.weatherImg.layer.masksToBounds = true
                        //self.weatherImg.frame = CGRect(x: 0, y: self.searchController.searchBar.frame.origin.y + 70, width: 390, height: 130)
                        self.weatherImg.frame = CGRect(x: 0, y: 0, width: 390, height: 130)
                        
                        self.weatherCity.frame = CGRect(x: 30, y:  0, width: 200, height: 70)
                        self.weatherCity.font = UIFont(name:"HelveticaNeue-Medium", size: 22.0)
                        self.weatherCity.textColor = UIColor.white
                       
                        self.weatherTemp.frame = CGRect(x: 300, y:  0, width: 70, height: 70)
                       self.weatherTemp.font = UIFont(name:"HelveticaNeue-Medium", size: 22.0)
                       self.weatherTemp.textColor = UIColor.white
                        
                        self.weatherDescrip.frame = CGRect(x: 300, y:  70, width: 70, height: 50)
                        self.weatherDescrip.font = UIFont(name:"HelveticaNeue-Medium", size: 13.0)
                        self.weatherDescrip.textColor = UIColor.white
                        
                        self.weatherState.frame = CGRect(x: 30, y:  70, width: 120, height: 50)
                        self.weatherState.font = UIFont(name:"HelveticaNeue-Medium", size: 18.0)
                        self.weatherState.textColor = UIColor.white
                        
                        self.weatherImg.addSubview(self.weatherCity)
                        self.weatherImg.addSubview(self.weatherTemp)
                        self.weatherImg.addSubview(self.weatherDescrip)
                        self.weatherImg.addSubview(self.weatherState)
                        
                        let weatherKey = weatherMap[descrip!] != nil
                        if weatherKey{
                            let weatherValue = weatherMap[descrip!]
                            self.weatherImg.image = UIImage(named: weatherValue!)
                            
                        }
                        else{
                            self.weatherImg.image = UIImage(named: "sunny_weather.jpg")
                        }
                        
                        
                            
                       }
                   } else {
                    print("error: \(String(describing: response.error))")
                   }
               })
    }
    func getUserLocation() {
        locationManager = CLLocationManager()
        locationManager?.requestAlwaysAuthorization()
        locationManager?.startUpdatingLocation() //getting the location data from the device GPS.
        locationManager?.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
           
            //print("Lat : \(location.coordinate.latitude) \nLng : \(location.coordinate.longitude)")
            lookUpCurrentLocation { geoLoc in
               // print(geoLoc?.administrativeArea ?? "unknown Geo location")
                //print("hey")
                let cityName = geoLoc?.locality!.replacingOccurrences(of: " ", with: "%20") ?? "Los%20Angeles"
                self.getWeather(city: cityName)
                
            }
        }
    }
    func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?) -> Void ) {
        // Use the last reported location.
        if let lastLocation = locationManager?.location {
            let geocoder = CLGeocoder()
            
            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(lastLocation, completionHandler: { (placemarks, error) in
                if error == nil {
                    let firstLocation = placemarks?[0]
                    let stateIdx = self.stateCodes.firstIndex(of: (firstLocation?.administrativeArea)!)
                    
                    self.weatherState.text = self.stateNames[stateIdx!]
                    self.weatherCity.adjustsFontSizeToFitWidth = true
                    self.weatherCity.text = firstLocation?.locality
                    
                    completionHandler(firstLocation)
                }
                else {
                    // An error occurred during geocoding.
                    completionHandler(nil)
                }
            })
        }
        else {
            // No location was available.
            completionHandler(nil)
        }
    }


}

extension HomeViewController: UISearchBarDelegate{
    /**
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        tblList.isHidden = true
        //tableSearch.isHidden = false
        //filterSearchCell = testSearchCell.filter({$0.lowercased().prefix(searchText.count)==searchText.lowercased()})
        //searching = true
         //searchController.obscuresBackgroundDuringPresentation = false
       
        //tableSearch.reloadData()
        //print(searchText)
       
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        tableSearch.reloadData()
        tblList.isHidden = false
        tableSearch.isHidden = true
        
    }
 **/
}
    


extension HomeViewController: UITableViewDelegate, UITableViewDataSource{
    @objc func imageTapped(gesture: MyGesture) {
        // if the tapped view is a UIImageView then set it to imageview
        if (gesture.view as? UIImageView) != nil {
     
          let defaults = UserDefaults.standard
          var savedCards = defaults.object(forKey: "SavedCards") as? [String] ?? [String]()
           var savedNews = defaults.object(forKey: "SavedNews") as? [Any] ?? [Any]()
          
            if savedCards.count == 0 || (savedCards.count > 0 && savedCards.contains(gesture.articleId) == false){
              savedCards.append(gesture.articleId)
              defaults.set(savedCards, forKey: "SavedCards")
                savedNews.append(["articleId": gesture.cell.newsArticleId, "img": gesture.cell.imgName, "title":gesture.cell.newsTitleLabel.text, "date":gesture.cell.date, "section":gesture.cell.section])
              defaults.set(savedNews, forKey: "SavedNews")
             gesture.cell.newsBookmarkView.image = UIImage(systemName: "bookmark.fill")
             
              self.view.makeToast("Article Bookmarked. Check out the Bookmarks tab to view", duration: 3.0, position: .bottom)
          }
          else if  savedCards.count > 0 && savedCards.contains(gesture.cell.newsArticleId){
              var idx = 0
               for i in 0..<savedCards.count {
                  if savedCards[i] == gesture.cell.newsArticleId{
                      idx = i
                      break
                  }
              }
              savedCards.remove(at: idx)
              savedNews.remove(at: idx)
              defaults.set(savedCards, forKey: "SavedCards")
              defaults.set(savedNews, forKey: "SavedNews")
             gesture.cell.newsBookmarkView.image = UIImage(systemName: "bookmark")
            self.view.makeToast("Article Removed from Bookmarks", duration: 3.0, position: .bottom)
          }
         
          
        }
    }
    
   func tableView(_ tableView: UITableView,
   contextMenuConfigurationForRowAt indexPath: IndexPath,
   point: CGPoint) -> UIContextMenuConfiguration? {
       return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in

              // "puppers" is the array backing the collection view
       
        return self.makeContextMenu(elem: self.cards[indexPath.section], idx:indexPath)
          })
   }
   
    func makeContextMenu(elem:Card, idx: IndexPath) -> UIMenu {
        let defaults = UserDefaults.standard
       var savedCards = defaults.object(forKey: "SavedCards") as? [String] ?? [String]()
         var savedNews = defaults.object(forKey: "SavedNews") as? [Any] ?? [Any]()
       var bookmarkImage = UIImage()
        if savedCards.contains(elem.articleId){
          bookmarkImage = UIImage(systemName: "bookmark.fill")!
         
       }
       else {
         bookmarkImage = UIImage(systemName: "bookmark")!
       }
       // Create a UIAction for sharing
        let share = UIAction(title: "Share with Twitter", image: UIImage(named: "twitter.png")) { action in
                  // Show system share sheet
            let share = "https://theguardian.com/\(elem.articleId)"
            let twitterURL = "https://twitter.com/intent/tweet?text=Check%20out%20this%20Article!&url=\(share)&hashtags=CSCI571_NewsApp"
         
              let url = NSURL(string: twitterURL)
               UIApplication.shared.open(url! as URL)
              }

       let bookmark = UIAction(title: "Bookmark", image: bookmarkImage) { action in
           // Show system share sheet
        
         var bookmarkImageMenu = UIImage()
        if savedCards.count == 0 || (savedCards.count > 0 && savedCards.contains(elem.articleId) == false){
            savedCards.append(elem.articleId)
            defaults.set(savedCards, forKey: "SavedCards")
            savedNews.append(["articleId": elem.articleId, "img": elem.imgName, "title":elem.title, "date":elem.date, "section":elem.section])
            defaults.set(savedNews, forKey: "SavedNews")
            bookmarkImageMenu = UIImage(systemName: "bookmark.fill")!
             self.view.makeToast("Article Bookmarked. Check out the Bookmarks tab to view", duration: 3.0, position: .bottom)
            //let testJson:[Any] = [["article-id": "456", "img": "try2", "date" : "somedate"],["article-id": "123", "img": "try", "date" : "somedate"] ]
            //defaults.set(testJson, forKey: "SavedJson")
            
        }
        else if  savedCards.count > 0 && savedCards.contains(elem.articleId){
            var idx = 0
             for i in 0..<savedCards.count {
                if savedCards[i] == elem.articleId{
                    idx = i
                    break
                }
            }
            savedCards.remove(at: idx)
            defaults.set(savedCards, forKey: "SavedCards")
             savedNews.remove(at: idx)
            defaults.set(savedNews, forKey: "SavedNews")
             bookmarkImageMenu = UIImage(systemName: "bookmark")!
              self.view.makeToast("Article Removed from Bookmarks", duration: 3.0, position: .bottom)
            /*
            var SavedJson = defaults.object(forKey: "SavedJson") as? [Any] ?? [Any]()
            for json in SavedJson{
                var jsonItem = json as! [String : String]
                if jsonItem["article-id"] == "123" {
                    print(jsonItem)
                    break
                }
                    
            }
             */
           
        }
        var cell = self.tblList.cellForRow(at: idx) as! CardCell
        cell.newsBookmarkView.image = bookmarkImageMenu
        
       }

       // Create and return a UIMenu with the share action
    
       return UIMenu(title: "Menu", children: [share, bookmark])
   }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "showdetail", sender: self)
        
        self.selectedCell = tblList.cellForRow(at: indexPath) as! CardCell
        
      
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destination = segue.destination as? DetailedViewController{
            destination.card = self.cards[(tblList.indexPathForSelectedRow?.section)!]
        }
        let backItem = UIBarButtonItem()
       backItem.title = ""
       navigationItem.backBarButtonItem = backItem
        
       
        //navigationItem.title = self.cards[(tblList.indexPathForSelectedRow?.section)!].title
        
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
             // if tableView == tblList{
              return self.cards.count
           // }
            /**  else{
               
                 return 1
            }**/
        }
   func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       let headerView = UIView()
       headerView.backgroundColor = UIColor.clear
       return headerView
   }
    //func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
      //  return 1
    //}
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         //if tableView == tblList{
            return 1
        //}
            /***
         else{
            if searching{
                return self.filterSearchCell.count
            }
            else{
                return self.testSearchCell.count
            }
        }**/
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //guard
        if tableView == tblList{
            if ( tableView.dequeueReusableCell(withIdentifier: "CardCell") != nil ){
            let cell = tableView.dequeueReusableCell(withIdentifier: "CardCell") as! CardCell
                cell.backgroundColor = UIColor(hex:0xecebed)
                cell.layer.borderWidth = 1
                var borderColor = UIColor(red: 205.0/255.0, green: 206.0/255.0, blue: 205.0/255.0, alpha: 1.0)
                cell.layer.borderColor = borderColor.cgColor
                cell.layer.cornerRadius = 8
                cell.clipsToBounds = true
            let card = cards[indexPath.section]
            
            cell.set(card: card)
           // cell.textLabel?.text = //"Section \(indexPath.section) Row \(indexPath.row)"
            let defaults = UserDefaults.standard
          var savedCards = defaults.object(forKey: "SavedCards") as? [String] ?? [String]()
            var savedNews = defaults.object(forKey: "SavedNews") as? [Any] ?? [Any]()
          var bookmarkImage = UIImage()
                if savedCards.contains(card.articleId){
             bookmarkImage = UIImage(systemName: "bookmark.fill")!
            
          }
          else {
            bookmarkImage = UIImage(systemName: "bookmark")!
          }
            let tapGesture = MyGesture(target: self, action: #selector(imageTapped(gesture:)))
            cell.newsBookmarkView.addGestureRecognizer(tapGesture)
            cell.newsBookmarkView.isUserInteractionEnabled = true
            cell.newsBookmarkView.image = bookmarkImage
             tapGesture.articleId = cell.newsArticleId
            tapGesture.cell = cell
            return cell
            }
            else{
                return UITableViewCell()
            }
        }
        /***
    if tableView == tableSearch {
          if ( tableView.dequeueReusableCell(withIdentifier: "cellSearch") != nil ){
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellSearch")
            if searching{
                cell?.textLabel?.text = filterSearchCell[indexPath.row]
                return cell!
            }
            else{
                cell?.textLabel?.text = testSearchCell[indexPath.row]
                return cell!
            }
        }
          else{
            return UITableViewCell()
               
        }
        
    }**/
     return UITableViewCell()
    
    }
    
    
}
extension UIColor {

    convenience init(hex: Int) {
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )

        self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }

}



class HeadlinesViewController:ButtonBarPagerTabStripViewController,UISearchBarDelegate, UISearchControllerDelegate{
    //let refreshControl = UIRefreshControl()
   //let searchBar = UISearchBar()
   //let tableHeaderView = UIView()
    //@IBOutlet weak var headlinesTable: UITableView!
    //let headlinesTable = UITableView()
     //var cards: [Card] = []
    @IBOutlet weak var myButtonBar: ButtonBarView!
    var searchController : UISearchController!
    var resultsTableViewController: searchResultsController?
    override func viewDidLoad() {
         setTab()
        super.viewDidLoad()
        
        //self.edgesForExtendedLayout = UIRectEdge()
        //self.edgesForExtendedLayout = []
       //navigationController?.navigationBar.prefersLargeTitles = true
        //navigationController?.navigationItem.largeTitleDisplayMode = .always
        //avigationController?.navigationBar.prefersLargeTitles = true
        resultsTableViewController = storyboard!.instantiateViewController(withIdentifier: "resultsTableViewController") as? searchResultsController
        setSearchTable()
       // searchController.searchBar.addSubview(myButtonBar)
        
        
    }
    func setSearchTable(){
          searchController = UISearchController(searchResultsController: resultsTableViewController)
          //self.definesPresentationContext = true
          navigationItem.searchController = searchController
          searchController.delegate = self
          searchController.searchResultsUpdater = resultsTableViewController
        searchController.searchBar.frame = CGRect(x: 0, y: 0, width: 390, height: 70)
        searchController.searchBar.delegate = resultsTableViewController
        //searchController.searchBar.searchBarStyle = UISearchBar.Style.default
        searchController.searchBar.placeholder = " Enter keyword.."
      }
     override public func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let child_1 = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(identifier: "TableOne")
        let child_2 = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(identifier: "TableTwo")
        let child_3 = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(identifier: "TableThree")
        let child_4 = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(identifier: "TableFour")
        let child_5 = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(identifier: "TableFive")
        let child_6 = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(identifier: "TableSix")
        
        return [child_1, child_2, child_3,child_4,child_5,child_6]
      }
        
        func setTab(){
            settings.style.selectedBarHeight = 4.0
            settings.style.selectedBarBackgroundColor =  UIColor(red: 33.0/255.0, green: 125.0/255.0, blue: 237.0/255.0, alpha: 1.0)
            settings.style.buttonBarBackgroundColor = .white
            settings.style.buttonBarItemBackgroundColor = .white
            settings.style.buttonBarItemFont = UIFont.systemFont(ofSize: 16, weight: .regular) //.boldSystemFont(ofSize: 17)
            settings.style.buttonBarMinimumLineSpacing = 3
            settings.style.buttonBarItemTitleColor = .white
            //self.settings.style.buttonBarItemsShouldFillAvailiableWidth = true
            settings.style.buttonBarLeftContentInset = 5
            settings.style.buttonBarRightContentInset = 5
            settings.style.buttonBarHeight=70
            
            changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .gray
                newCell?.label.textColor = UIColor(red: 91.0/255.0, green: 154.0/255.0, blue: 229.0/255.0, alpha: 1.0)
        }
            
    }
  

}
/*
extension HeadlinesViewController: UITableViewDelegate, UITableViewDataSource{
    
   func tableView(_ tableView: UITableView,
   contextMenuConfigurationForRowAt indexPath: IndexPath,
   point: CGPoint) -> UIContextMenuConfiguration? {
       return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in

              // "puppers" is the array backing the collection view
              return self.makeContextMenu(for: self.cards[indexPath.section])
          })
   }
   
    func makeContextMenu(for:Card) -> UIMenu {

       // Create a UIAction for sharing
        let share = UIAction(title: "Share with Twitter", image: UIImage(named: "twitter.png")) { action in
                  // Show system share sheet
              }

       let bookmark = UIAction(title: "Bookmark", image: UIImage(systemName: "bookmark")) { action in
           // Show system share sheet
       }

       // Create and return a UIMenu with the share action
       return UIMenu(title: "Menu", children: [share, bookmark])
   }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "showdetail", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DetailedViewController{
            destination.card = self.cards[(headlinesTable.indexPathForSelectedRow?.section)!]
        }
        let backItem = UIBarButtonItem()
       backItem.title = ""
       navigationItem.backBarButtonItem = backItem
       
        //navigationItem.title = self.cards[(tblList.indexPathForSelectedRow?.section)!].title
        
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
              return self.cards.count
          }
   func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       let headerView = UIView()
       headerView.backgroundColor = UIColor.clear
       return headerView
   }
  
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //guard
        
        if ( tableView.dequeueReusableCell(withIdentifier: "CardCell") != nil ){
        let cell = tableView.dequeueReusableCell(withIdentifier: "CardCell") as! CardCell
            cell.backgroundColor = UIColor(hex:0xecebed)
            cell.layer.borderWidth = 1
            var borderColor = UIColor(red: 205.0/255.0, green: 206.0/255.0, blue: 205.0/255.0, alpha: 1.0)
            cell.layer.borderColor = borderColor.cgColor
            cell.layer.cornerRadius = 8
            cell.clipsToBounds = true
        let card = cards[indexPath.section]
        cell.set(card: card)
       // cell.textLabel?.text = //"Section \(indexPath.section) Row \(indexPath.row)"
        
        return cell
        }
        else{
            return UITableViewCell()
        }
    }
    
    
}
extension HeadlinesViewController: UISearchBarDelegate{
    
}
    */
import Charts
class TrendingViewController: UIViewController , UITextFieldDelegate{
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var myTextField: UITextField!
    
    @IBOutlet weak var chartView: LineChartView!
    var term:String = "Coronavirus"
  
    
    
    override func viewDidLoad() {
       
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        topLabel.text = "Enter Search Term"
        myTextField.placeholder = "Enter Search term"
        //myTextField.addTarget(self, action: #selector(TrendingViewController.textFieldDidEndEditing(_:)), for: UIControl.Event.editingChanged)
     myTextField.delegate = self
        callGetTrending()
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        //textField code

        myTextField.resignFirstResponder()  //if desired
        term = myTextField.text ?? "Coronavirus"
        callGetTrending()
        return true
    }

    
    /*
    @objc func textFieldDidEndEditing(_ textField: UITextField) {
    print("123")
   }*/
    func callGetTrending(){
        getTrending() { (resArr) in
           var values: [ChartDataEntry] = []
           for i in 0..<resArr.count {
               let dataEntry = ChartDataEntry(x: Double(i), y: resArr[i] as! Double)
             values.append(dataEntry)
           }
           let set1 = LineChartDataSet(entries:values, label:"Trending Chart for \(self.term)")
           set1.setColor(UIColor(red: 33.0/255.0, green: 125.0/255.0, blue: 237.0/255.0, alpha: 1.0))
           set1.setCircleColor(UIColor(red: 33.0/255.0, green: 125.0/255.0, blue: 237.0/255.0, alpha: 1.0))
            set1.drawCircleHoleEnabled = false
            set1.circleRadius = 5
           let data = LineChartData(dataSet: set1)
           self.chartView.data = data
        }
    }
   
    
     func getTrending(completionhandler:@escaping ([AnyObject]) -> ()){
           //var CardArr = [Card]()
           
           
           Alamofire.request("https://hw9104062222.wl.r.appspot.com/getTrending/\(term)")
              // .responseJSON(completionHandler: { response in
               .responseJSON { response in
               if response.result.isSuccess {
                  
                   let responseArr = response.value as! [AnyObject]
                 
                  completionhandler(responseArr)
                   
               } else {
                   print("error: \(String(describing: response.error))")
                  
                   }
               }
           
           
       }

}



class BookmarksViewController: UIViewController {
   
    @IBOutlet weak var collectionView: UICollectionView!
    var savedCards = [String]()
    var savedNews = [Any]()
    var cards: [Card] = []
    var article = String()
    var selectedNews = [String:String]()
     var noBook = UILabel()
    override func viewDidLoad() {
           super.viewDidLoad()
        showNoBookmarks()
        collectionView.dataSource = self
        collectionView.delegate = self
      //navigationController?.navigationBar.prefersLargeTitles = true
       var layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
       
       
        
        
        let defaults = UserDefaults.standard
        savedCards = defaults.object(forKey: "SavedCards") as? [String] ?? [String]()
        savedNews = defaults.object(forKey: "SavedNews") as? [Any] ?? [Any]()
        
       
    }
    override func viewWillAppear(_ animated: Bool) {
             super.viewWillAppear(animated)
        //navigationController!.navigationBar.isTranslucent = false
        //navigationController!.navigationBar.backgroundColor = .white
        //navigationController?.navigationItem.largeTitleDisplayMode = .automatic
        navigationController?.navigationBar.prefersLargeTitles = true
          let defaults = UserDefaults.standard
        savedCards = defaults.object(forKey: "SavedCards") as? [String] ?? [String]()
        savedNews = defaults.object(forKey: "SavedNews") as? [Any] ?? [Any]()
        self.collectionView.reloadData()
    }
  /*
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillAppear(_ animated: Bool) {
              super.viewWillAppear(animated)
     
        for i in 0..<savedCards.count {
         print(savedCards[i])
      }
    }
    
    */


}
extension BookmarksViewController: UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func showNoBookmarks(){
      
   
    noBook.text = "No bookmarks added."
        self.collectionView.addSubview(noBook)
       noBook.adjustsFontSizeToFitWidth = false
      
          noBook.translatesAutoresizingMaskIntoConstraints = false
           noBook.textAlignment = .center
        noBook.centerYAnchor.constraint(equalTo: self.collectionView.centerYAnchor).isActive = true
        noBook.centerXAnchor.constraint(equalTo: self.collectionView.centerXAnchor).isActive = true
       
           //noBook.trailingAnchor.constraint(equalTo: railingAnchor, constant: -5).isActive = true
         
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
           performSegue(withIdentifier: "showdetail", sender: self)
           collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .bottom)
         
       }
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
             if let destination = segue.destination as? DetailedViewController{
              let index = collectionView.indexPathsForSelectedItems?.first
               destination.card = cards[index!.item]
                self.article = cards[index!.item].articleId
                //self.selectedNews = ["articleId": cards[index!.item].articleId, "img": cards[index!.item].imgName, "title":cards[index!.item].title, "date":cards[index!.item].date, "section":cards[index!.item].section]
                
             }
             let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
       
             
             
         }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
         {
            //return CGSize(width: 90, height:200)
            return CGSize(width: ((self.collectionView.frame.size.width-30)/2), height: (self.collectionView.frame.size.height/2.5))
         }
 
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           let defaults = UserDefaults.standard
        cards = []
           savedCards = defaults.object(forKey: "SavedCards") as? [String] ?? [String]()
        if savedCards.count == 0{
            noBook.isHidden = false
        }
        else{
            noBook.isHidden = true
        }
           return savedCards.count
          }
          
      func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! CollectionViewCell
       //cell.frame.size = CGSize(width: (self.collectionView.frame.size.width-30)/2, height: self.collectionView.frame.size.height/2.5)
        //cards = []
        let defaults = UserDefaults.standard
        savedCards = defaults.object(forKey: "SavedCards") as? [String] ?? [String]()
        savedNews = defaults.object(forKey: "SavedNews") as? [Any] ?? [Any]()
        cell.configureImg()
        cell.configureTitle()
       
        cell.configureDate()
        cell.configureSection()
       cell.configureBookmark()
       
        var jsonItem = savedNews[indexPath.item] as! [String : String]
        cell.myTitle.text = jsonItem["title"] //"jejellojellojellojellojellojellojellojellojellojellojellojellojellojellojellojellojellojellollo"//savedCards[indexPath.item]
        var cardImg = UIImage()
        if jsonItem["img"]! != "the_guardian_icon.png"{
            let urlString = jsonItem["img"]!
            let url = NSURL(string: urlString)! as URL
            if let imageData: NSData = NSData(contentsOf: url){
                cardImg = UIImage(data: imageData as Data)!
                
            }
        }
        else{
            cardImg = UIImage(named: "the_guardian_icon.png")!
        }
        cell.myImg.image = cardImg//UIImage(named: "the_guardian_icon.png")
        
        let mySub = jsonItem["date"] as! NSString
        cell.myDate.text = mySub.substring(to: 6)
        //cell.myDate.text = jsonItem["date"]
        cell.mySection.text = "| \(jsonItem["section"]!)"//jsonItem["section"]
        cell.bookmark.image = UIImage(systemName: "bookmark.fill")
        //cell.bookmark.setImage(UIImage(systemName: "bookmark.fill"), for:  UIControl.State.normal)
        cell.articleId = jsonItem["articleId"]!
        //cards[indexPath.item] = Card(image: cardImg, title: jsonItem["title"]!, time: jsonItem["date"]!, section: jsonItem["section"]!, bookmark: cell.bookmark.image!, articleId: savedCards[indexPath.item], imgName: jsonItem["img"]!, date: jsonItem["date"]!)
        cards.append(Card(image: cardImg, title: jsonItem["title"]!, time: jsonItem["date"]!, section: jsonItem["section"]!, bookmark: cell.bookmark.image!, articleId: savedCards[indexPath.item], imgName: jsonItem["img"]!, date: jsonItem["date"]!))
       cell.backgroundColor = UIColor(hex:0xecebed)
       cell.layer.borderWidth = 2
       var borderColor = UIColor(red: 205.0/255.0, green: 206.0/255.0, blue: 205.0/255.0, alpha: 1.0)
       cell.layer.borderColor = borderColor.cgColor
       cell.layer.cornerRadius = 8
       
       cell.clipsToBounds = true
    
        let tapGesture = MyGesture(target: self, action: #selector(CollectionViewCell.imageTapped(gesture:)))
        //cell.bookmark.addTarget(self, action: #selector(handleRegister(sender:)), for: .touchUpInside)
        cell.bookmark.addGestureRecognizer(tapGesture)
        cell.bookmark.isUserInteractionEnabled = true
        tapGesture.articleId = cell.articleId
        
        
        
       return cell
      }
    /*@objc func handleRegister(sender: UIButton){
        self.collectionView.reloadData()
    }*/
    @objc func imageTapped(gesture: MyGesture) {
               // if the tapped view is a UIImageView then set it to imageview
       // DispatchQueue.main.async {
        self.view.makeToast("Article Removed from Bookmarks", duration: 3.0, position: .bottom)
               if (gesture.view as? UIImageView) != nil {
         
                 let defaults = UserDefaults.standard
                 var savedCards = defaults.object(forKey: "SavedCards") as? [String] ?? [String]()
                  var savedNews = defaults.object(forKey: "SavedNews") as? [Any] ?? [Any]()
                //print(self.article)
                var idx = savedCards.firstIndex(of: gesture.articleId)!
                savedCards.remove(at:idx)
                
                savedNews.remove(at: idx)
                     defaults.set(savedCards, forKey: "SavedCards")
                     defaults.set(savedNews, forKey: "SavedNews")
                //let ind = collectionView!.indexPathsForSelectedItems?.first
               
                //self.collectionView.deleteItems(at: self.collectionView!.indexPathsForSelectedItems!)
        
                self.collectionView.reloadData()
                
                //}
             
                 }
                
           
    }
    
    
}
class MyGesture: UITapGestureRecognizer {
    var articleId = String()
    var cell = CardCell()
}
/*
extension BookmarksViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
      {
         return CGSize(width: 100.0, height: 200.0)
      }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //savedCards = defaults.object(forKey: "SavedCards") as? [String] ?? [String]()
        return 2
        //return savedCards.count
       }
       
   func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! CollectionViewCell
    cell.myLabel.text = "jello"//savedCards[indexPath.item]
    cell.myImg.image = UIImage(named: "twitter.png")
    cell.backgroundColor = .red
    return cell
   }
    
       
}
 */
