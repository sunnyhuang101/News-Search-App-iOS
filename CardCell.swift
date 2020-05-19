//
//  CardCell.swift
//  CSCI571_HW9
//
//  Created by mmlab on 4/19/20.
//  Copyright © 2020 csci571. All rights reserved.
//

import UIKit
import Toast_Swift

class CardCell: UITableViewCell {
    

    
    
    var newsImageView = UIImageView()
    var newsTitleLabel = UILabel()
    var newsSectionLabel = UILabel()
    var newsTimeLabel = UILabel()
    var newsBookmarkView = UIImageView()
    var newsArticleId = String()
    
    var imgName = String()
    var date = String()
    var section = String()
   
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(CardCell.imageTapped(gesture:)))
        
        //newsBookmarkView.addGestureRecognizer(tapGesture)
        //newsBookmarkView.isUserInteractionEnabled = true
        
        addSubview(newsImageView)
        addSubview(newsTitleLabel)
        addSubview(newsTimeLabel)
        addSubview(newsSectionLabel)
        addSubview(newsBookmarkView)
        
        configureImg()
        configureTitle()
        configureTime()
        configureSection()
        
        setImgConstraints()
        setTitleConstraints()
        setTimeConstraints()
        setSectionConstraints()
        setBookmarkConstraints()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    /*
    @objc func imageTapped(gesture: UIGestureRecognizer) {
          // if the tapped view is a UIImageView then set it to imageview
          if (gesture.view as? UIImageView) != nil {
       
            let defaults = UserDefaults.standard
            var savedCards = defaults.object(forKey: "SavedCards") as? [String] ?? [String]()
             var savedNews = defaults.object(forKey: "SavedNews") as? [Any] ?? [Any]()
            
            if savedCards.count == 0 || (savedCards.count > 0 && savedCards.contains(newsArticleId) == false){
                savedCards.append(newsArticleId)
                defaults.set(savedCards, forKey: "SavedCards")
                savedNews.append(["articleId": newsArticleId, "img": self.imgName, "title":newsTitleLabel.text, "date":self.date, "section":section])
                defaults.set(savedNews, forKey: "SavedNews")
                newsBookmarkView.image = UIImage(systemName: "bookmark.fill")
               
               
            }
            else if  savedCards.count > 0 && savedCards.contains(newsArticleId){
                var idx = 0
                 for i in 0..<savedCards.count {
                    if savedCards[i] == newsArticleId{
                        idx = i
                        break
                    }
                }
                savedCards.remove(at: idx)
                savedNews.remove(at: idx)
                defaults.set(savedCards, forKey: "SavedCards")
                defaults.set(savedNews, forKey: "SavedNews")
                 newsBookmarkView.image = UIImage(systemName: "bookmark")
            }
           
            
          }
      }*/
    func set(card: Card){
        newsImageView.image = card.image
        newsTitleLabel.text = card.title
        //let sectionStr = item["section"] as! String
        newsSectionLabel.text = "| \(card.section)"//card.section
        newsTimeLabel.text = card.time
        //newsBookmarkView.image = card.bookmark
        newsArticleId = card.articleId
        
        self.imgName = card.imgName
        self.date = card.date
        self.section = card.section
    }
    func configureImg(){
        newsImageView.layer.cornerRadius = 10
        newsImageView.clipsToBounds = true
    }
    func configureTitle(){
        newsTitleLabel.numberOfLines = 4
        newsTitleLabel.adjustsFontSizeToFitWidth = false
        newsTitleLabel.lineBreakMode =  NSLineBreakMode.byTruncatingTail
        newsTitleLabel.font = UIFont(name:"HelveticaNeue-Bold", size: 17.0)
       
    }
    func configureTime(){
        newsTimeLabel.font = newsTimeLabel.font.withSize(14)
    }
    func configureSection(){
        newsSectionLabel.font = newsSectionLabel.font.withSize(14)
    }
    
    func setImgConstraints(){
        newsImageView.translatesAutoresizingMaskIntoConstraints = false
        newsImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        newsImageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        newsImageView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        newsImageView.widthAnchor.constraint(equalTo: heightAnchor).isActive = true
        //newsImageView.widthAnchor.constraint(equalTo: newsImageView.heightAnchor, multiplier: 16/9).isActive = true
        
    }
    func setBookmarkConstraints(){
        newsBookmarkView.translatesAutoresizingMaskIntoConstraints = false
         newsBookmarkView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        newsBookmarkView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15).isActive = true
        newsBookmarkView.heightAnchor.constraint(equalToConstant: 18).isActive = true
        newsBookmarkView.widthAnchor.constraint(equalToConstant: 14).isActive = true
        //newsBookmarkView.leadingAnchor.constraint(equalTo: newsImageView.trailingAnchor, constant:20).isActive = true
    }
    
    func setTitleConstraints(){
        newsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        //newsTitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        newsTitleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        newsTitleLabel.leadingAnchor.constraint(equalTo: newsImageView.trailingAnchor, constant:20).isActive = true
        newsTitleLabel.heightAnchor.constraint(equalToConstant: 80).isActive = true
        newsTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12).isActive = true
    }
    func setTimeConstraints(){
        newsTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        newsTimeLabel.leadingAnchor.constraint(equalTo: newsImageView.trailingAnchor, constant:20).isActive = true
         newsTimeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
    }
    func setSectionConstraints(){
         newsSectionLabel.translatesAutoresizingMaskIntoConstraints = false
        newsSectionLabel.leadingAnchor.constraint(equalTo: newsImageView.trailingAnchor, constant:100).isActive = true
         newsSectionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
    }
}
