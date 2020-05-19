//
//  SearchResultPageController.swift
//  CSCI571_HW9
//
//  Created by mmlab on 5/4/20.
//  Copyright © 2020 csci571. All rights reserved.
//

import UIKit
import Alamofire
import SwiftSpinner
import Toast_Swift

class SearchResultPageController: UIViewController ,UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableResult: UITableView!
     var cards: [Card] = []
    var keyword : String = ""
     var selectedCell = CardCell()
       override func viewDidLoad() {
           super.viewDidLoad()

           setTable()
              getSearch() { (resArr) in
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
                 self.tableResult.reloadData()
            }
       }
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
          navigationController?.navigationBar.prefersLargeTitles = true
       getSearch() { (resArr) in
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
                self.cards.append(Card(image: cardImg, title: item["title"] as! String, time: item["time"] as! String, section:  item["section"] as! String, bookmark: bookmarkImage, articleId: item["articleId"] as! String, imgName: imgName, date: item["date"] as! String))
                }
                self.tableResult.reloadData()
           }
               // self.mySpinner()
            
        }
    func mySpinner() {
           
         SwiftSpinner.show(duration: 3.0, title: "Loading Search results..", animated: true)
           
      }
    func getSearch(completionhandler:@escaping ([AnyObject]) -> ()){
    
            
            Alamofire.request("https://hw9104062222.wl.r.appspot.com/getSearch/\(keyword)")
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
    
     
    
        func numberOfSections(in tableView: UITableView) -> Int {
                        return self.cards.count
        }
    
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return 1
       }
       func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
           
           return 1
       }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
           let headerView = UIView()
           headerView.backgroundColor = UIColor.clear
           return headerView
       }
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
            let cell = self.tableResult.cellForRow(at: idx) as! CardCell
                       cell.newsBookmarkView.image = bookmarkImageMenu
          }
      
          // Create and return a UIMenu with the share action
          return UIMenu(title: "Menu", children: [share, bookmark])
      }
       
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if let destination = segue.destination as? DetailedViewController{
                destination.card = self.cards[(tableResult.indexPathForSelectedRow?.section)!]
            }
         
        }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            performSegue(withIdentifier: "showdetail", sender: self)
           self.selectedCell = tableResult.cellForRow(at: indexPath) as! CardCell
       }

    func setTable(){
                tableResult.delegate = self
                tableResult.dataSource = self
                tableResult.rowHeight = 150
                tableResult.backgroundColor = UIColor.white
               tableResult.sectionFooterHeight = 2
                tableResult.sectionHeaderHeight = 5
           
                tableResult.register(CardCell.self, forCellReuseIdentifier: "CardCell")

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
