//
//  DetailedViewController.swift
//  CSCI571_HW9
//
//  Created by mmlab on 4/21/20.
//  Copyright © 2020 csci571. All rights reserved.
//

import UIKit
import Alamofire
import SwiftSpinner
import Toast_Swift

class DetailedViewController: UIViewController {
   // @IBOutlet weak var testingLable: UILabel!
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var detailTitle: UILabel!
    @IBOutlet weak var detailImg: UIImageView!
    @IBOutlet weak var detailSection: UILabel!
    @IBOutlet weak var viewBtn: UIButton!
    @IBOutlet weak var detailDate: UILabel!
    @IBOutlet weak var detailDescrip: UILabel!
    @IBOutlet weak var navController: UINavigationItem!
     var detailArticleId = String()
    var bookmarkImage = UIImage()
    var twitterImage =  UIImage()
    var bookmarkButton = UIBarButtonItem()
    var twitterButton = UIBarButtonItem()
    @IBAction func openFullArticle(_ sender: UIButton) {
        let url = NSURL(string: fullURL!)
        UIApplication.shared.open(url! as URL)
    }
    var card:Card?
    var fullURL:String?
    var imgName:String?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
         navigationController?.navigationBar.prefersLargeTitles = false
        // Do any additional setup after loading the view.
         //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(DetailedViewController.imageTapped(gesture:)))
        getArticle() { (resArr) in
            let date = resArr[0]["date"] as!String
            let description = resArr[0]["description"] as!String
            
            self.detailArticleId = self.card!.articleId
            self.detailImg.image = self.card?.image
            self.detailTitle.text = self.card?.title
            self.detailSection.text = self.card?.section
            self.detailDate.text = date
            self.detailDescrip.attributedText = description.htmlToAttributedString
            self.viewBtn.setTitle("View Full Article", for: .normal)
            self.viewBtn.titleLabel?.font = UIFont(name: "Arial-MT", size: 27)
            self.fullURL = resArr[0]["webURL"] as!String
            self.navController.title = self.card?.title
            self.imgName = self.card?.imgName
            let defaults = UserDefaults.standard
            var savedCards = defaults.object(forKey: "SavedCards") as? [String] ?? [String]()
            if savedCards.contains(self.detailArticleId){
               self.bookmarkImage = UIImage(systemName: "bookmark.fill")!
              
            }
            else {
              self.bookmarkImage = UIImage(systemName: "bookmark")!
            }
            
            
            self.bookmarkButton = UIBarButtonItem(image: self.bookmarkImage, style: .bordered, target: self, action: #selector(self.didTapBookmarkButton(sender:)))
            self.twitterImage    = UIImage(named: "twitter.png")!
            self.twitterButton = UIBarButtonItem(image: self.twitterImage, style: .bordered, target: self, action: #selector(self.didTapTwitterkButton(sender:)))
            self.navController.rightBarButtonItems = [self.twitterButton, self.bookmarkButton]
            //self.setImgConstraints()
            
            //self.setTitleConstraints()
            self.configureTitle()
            
            //self.setSectionDateConstraints()
            self.configureSectionDate()
            self.configureDescrip()
        }
    }
    @objc func didTapBookmarkButton(sender: AnyObject){
        let defaults = UserDefaults.standard
         var savedCards = defaults.object(forKey: "SavedCards") as? [String] ?? [String]()
         var savedNews = defaults.object(forKey: "SavedNews") as? [Any] ?? [Any]()
        
         if savedCards.count == 0 || (savedCards.count > 0 && savedCards.contains(detailArticleId) == false){
             savedCards.append(detailArticleId)
             defaults.set(savedCards, forKey: "SavedCards")
            savedNews.append(["articleId":detailArticleId, "img":imgName, "title":detailTitle.text, "date":detailDate.text, "section":detailSection.text])
            defaults.set(savedNews, forKey: "SavedNews")
            self.bookmarkImage = UIImage(systemName: "bookmark.fill")!
            
           self.view.makeToast("Article Bookmarked. Check out the Bookmarks tab to view", duration: 3.0, position: .bottom)
         }
         else if  savedCards.count > 0 && savedCards.contains(detailArticleId){
             var idx = 0
              for i in 0..<savedCards.count {
                 if savedCards[i] == detailArticleId{
                     idx = i
                     break
                 }
             }
             savedCards.remove(at: idx)
            savedNews.remove(at: idx)
             defaults.set(savedCards, forKey: "SavedCards")
             defaults.set(savedNews, forKey: "SavedNews")
              self.bookmarkImage = UIImage(systemName: "bookmark")!
            self.view.makeToast("Article Removed from Bookmarks", duration: 3.0, position: .bottom)
         }
        self.bookmarkButton = UIBarButtonItem(image: self.bookmarkImage, style: .bordered, target: self, action: #selector(self.didTapBookmarkButton(sender:)))
        self.navController.rightBarButtonItems = [self.twitterButton, self.bookmarkButton]
        
        
    }
    @objc func didTapTwitterkButton(sender: AnyObject){
        
        let twitterURL = "https://twitter.com/intent/tweet?text=Check%20out%20this%20Article!&url=\(fullURL!)&hashtags=CSCI571_NewsApp"
        //let escapedShareString = shareString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!

           let url = NSURL(string: twitterURL)
            UIApplication.shared.open(url! as URL)
       }

    
    override func viewWillAppear(_ animated: Bool) {
              super.viewWillAppear(animated)
              self.mySpinner()
   navigationItem.largeTitleDisplayMode = .never
      //  navigationController?.navigationBar.prefersLargeTitles = false
   
      }
    /*
    override func viewWillDisappear(_ animated: Bool) {
              super.viewWillDisappear(animated)
             
   //navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = true
   
      }
   */
     func mySpinner() {
        
       SwiftSpinner.show(duration: 3.0, title: "Loading Detailed Article..", animated: true)
        
   }
  
    
    func configureDescrip(){
        self.detailDescrip.numberOfLines = 30
        self.detailDescrip.font = detailDescrip.font.withSize(18)
    }
    func setSectionDateConstraints(){
        self.detailSection.topAnchor.constraint(equalTo: detailTitle.bottomAnchor, constant: 20).isActive = true
        self.detailDate.topAnchor.constraint(equalTo: detailTitle.bottomAnchor, constant: 20).isActive = true
    }
    func configureSectionDate(){
        self.detailSection.sizeToFit()
        var sdColor = UIColor(red: 206.0/255.0, green: 205.0/255.0, blue: 206.0/255.0, alpha: 1.0)
        detailDate.textColor = sdColor
        detailSection.textColor = sdColor
        
    }
    func setImgConstraints(){
        self.detailImg.topAnchor.constraint(equalTo: firstView.bottomAnchor, constant: 5).isActive = true
        self.detailImg.widthAnchor.constraint(equalTo: firstView.widthAnchor).isActive = true
         self.detailImg.leadingAnchor.constraint(equalTo: firstView.leadingAnchor).isActive = true
    }
    
    func configureTitle(){
        //self.detailTitle.sizeToFit()
        self.detailTitle.numberOfLines = 0
        self.detailTitle.textAlignment = .center
        self.detailTitle.font = UIFont(name:"HelveticaNeue-Bold", size: 18.0)
        
    }
    func setTitleConstraints(){
        self.detailTitle.topAnchor.constraint(equalTo: self.detailImg.bottomAnchor, constant: 5).isActive = true
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func getArticle(completionhandler:@escaping ([AnyObject]) -> ()){
           //var CardArr = [Card]()
           
            Alamofire.request("https://hw9104062222.wl.r.appspot.com/getArticle/"+card!.articleId.replacingOccurrences(of: "/", with: "%2F"))
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

}
extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
