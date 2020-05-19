//
//  TabTableTableViewController.swift
//  CSCI571_HW9
//
//  Created by mmlab on 4/23/20.
//  Copyright © 2020 csci571. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import Alamofire
import SwiftSpinner
import Toast_Swift

class TabTableTableViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
   var selectedCell = CardCell()
     @IBOutlet weak var tableW: UITableView!
  
       func mySpinner() {
          
        SwiftSpinner.show(duration: 3.0, title: "Loading \(sec.uppercased()) Headlines..", animated: true)
          
     }
   
   
    private let refreshControl2 = UIRefreshControl()
    var sec : String = ""
    var cards: [Card] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        sec = self.restorationIdentifier!
                setTable()
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
           var bookmarkImage = UIImage()
           if savedCards.contains(item["articleId"] as! String){
              bookmarkImage = UIImage(systemName: "bookmark.fill")!
             
           }
           else {
             bookmarkImage = UIImage(systemName: "bookmark")!
           }
            //let sectionStr = item["section"] as! String
            self.cards.append(Card(image: cardImg, title: item["title"] as! String, time: item["time"] as! String, section:  item["section"] as! String, bookmark: bookmarkImage, articleId: item["articleId"] as! String, imgName: imgName, date: item["date"] as! String))
            }
            self.tableW.reloadData()
        }
      
    }
    override func viewWillAppear(_ animated: Bool) {
                  super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
        self.tableW.reloadData()
          if tableW.indexPathForSelectedRow != nil{
          let defaults = UserDefaults.standard
              let savedCards = defaults.object(forKey: "SavedCards") as? [String] ?? [String]()
           var bookmarkImage = UIImage()
            if savedCards.contains(self.selectedCell.newsArticleId){
              bookmarkImage = UIImage(systemName: "bookmark.fill")!
           }
           else {
             bookmarkImage = UIImage(systemName: "bookmark")!
           }
           
            self.selectedCell.newsBookmarkView.image = bookmarkImage
          }
                  self.mySpinner()
          
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
                
              self.refreshControl2.endRefreshing()
               
               self.tableW.reloadData()
           }
       }
    func getNews(completionhandler:@escaping ([AnyObject]) -> ()){
   
           
           Alamofire.request("https://hw9104062222.wl.r.appspot.com/getSection/\(sec)")
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
       

    // MARK: - Table view data source
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           //tableView.deselectRow(at: indexPath, animated: true)
           performSegue(withIdentifier: "showdetail", sender: self)
          self.selectedCell = tableW.cellForRow(at: indexPath) as! CardCell
       }
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if let destination = segue.destination as? DetailedViewController{
               destination.card = self.cards[(tableW.indexPathForSelectedRow?.section)!]
           }
           let backItem = UIBarButtonItem()
          backItem.title = ""
          navigationItem.backBarButtonItem = backItem
          
           //navigationItem.title = self.cards[(tblList.indexPathForSelectedRow?.section)!].title
           
           
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
           let share = UIAction(title: "Share with Twitter", image: UIImage(named: "twitter.png")) { action in

                             // Show system share sheet
                   let shareurl = "https://theguardian.com/\(elem.articleId)"
                   let twitterURL = "https://twitter.com/intent/tweet?text=Check%20out%20this%20Article!&url=\(shareurl)&hashtags=CSCI571_NewsApp"
                
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
                savedNews.remove(at: idx)
                   defaults.set(savedCards, forKey: "SavedCards")
                 defaults.set(savedNews, forKey: "SavedNews")
                    bookmarkImageMenu = UIImage(systemName: "bookmark")!
                    self.view.makeToast("Article Removed from Bookmarks", duration: 3.0, position: .bottom)
               }
            var cell = self.tableW.cellForRow(at: idx) as! CardCell
                       cell.newsBookmarkView.image = bookmarkImageMenu
          }
      
          // Create and return a UIMenu with the share action
          return UIMenu(title: "Menu", children: [share, bookmark])
      }
       
    
  

     func numberOfSections(in tableView: UITableView) -> Int {
                 return self.cards.count
             }
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return 1
      }
     func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
   
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //guard
        
        if ( tableView.dequeueReusableCell(withIdentifier: "CardCell") != nil ){
        let cell = tableView.dequeueReusableCell(withIdentifier: "CardCell") as! CardCell
            cell.backgroundColor = UIColor(hex:0xecebed)
            cell.layer.borderWidth = 1
            let borderColor = UIColor(red: 205.0/255.0, green: 206.0/255.0, blue: 205.0/255.0, alpha: 1.0)
            cell.layer.borderColor = borderColor.cgColor
            cell.layer.cornerRadius = 8
            cell.clipsToBounds = true
        let card = cards[indexPath.section]
        cell.set(card: card)
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
    
    func setTable(){
             tableW.delegate = self
             tableW.dataSource = self
             tableW.rowHeight = 150
             tableW.backgroundColor = UIColor.white
            tableW.sectionFooterHeight = 2
             tableW.sectionHeaderHeight = 5
          // tableW.contentInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
            tableW.refreshControl = refreshControl2
             refreshControl2.addTarget(self, action: #selector(refreshNewsData(_:)), for: .valueChanged)
             tableW.register(CardCell.self, forCellReuseIdentifier: "CardCell")

             //searchBar.frame = CGRect(x: 12, y: 0, width: 390, height: 70)
            // searchBar.delegate = self
             //searchBar.searchBarStyle = UISearchBar.Style.default
             //searchBar.placeholder = " Enter keyword.."
             //searchBar.sizeToFit()
             
             //tableHeaderView.frame = CGRect(x: 0, y: 0, width: 414, height: 220)
             //tableHeaderView.addSubview(searchBar)
            
             //tableW.tableHeaderView = tableHeaderView
            
         }
    
}
class MyPolitics: TabTableTableViewController, IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "POLITICS")
    }
}
class MyBusiness: TabTableTableViewController, IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "BUSINESS")
    }
}
class MyWorld: TabTableTableViewController, IndicatorInfoProvider{
    //override func viewDidLoad() {
      //  super.viewDidLoad()
      //edgesForExtendedLayout
    //}
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "WORLD")
    }
}
class MySports: TabTableTableViewController, IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "SPORTS")
    }
}
class MyTechnology: TabTableTableViewController, IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "TECHNOLOGY")
    }
}
class MyScience: TabTableTableViewController, IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "SCIENCE")
    }
}

/*
extension TabTableTableViewController : IndicatorInfoProvider{
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: sec.uppercased())
    }
}
*/
