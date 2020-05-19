//
//  CollectionViewCell.swift
//  CSCI571_HW9
//
//  Created by mmlab on 4/26/20.
//  Copyright © 2020 csci571. All rights reserved.
//

import UIKit
import Toast_Swift

class CollectionViewCell: UICollectionViewCell {
    //@IBOutlet weak var myImg: UIImageView!
    //@IBOutlet weak var myLabel: UILabel!
    var myImg = UIImageView()
    var myTitle = UILabel()
    var myDate = UILabel()
    var mySection = UILabel()
    var bookmark = UIImageView()
    var articleId = String()
 // var bookmark = UIButton()
    func configureBookmark(){
        
        //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(CollectionViewCell.imageTapped(gesture:)))
        
       // bookmark.addGestureRecognizer(tapGesture)
       //bookmark.isUserInteractionEnabled = true
        contentView.addSubview(bookmark)
       bookmark.translatesAutoresizingMaskIntoConstraints = false
        bookmark.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        bookmark.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15).isActive = true
      bookmark.heightAnchor.constraint(equalToConstant: 18).isActive = true
      bookmark.widthAnchor.constraint(equalToConstant: 14).isActive = true
    }
    @objc func imageTapped(gesture: UIGestureRecognizer) {
            // if the tapped view is a UIImageView then set it to imageview
            if (gesture.view as? UIImageView) != nil {
              let defaults = UserDefaults.standard
              var savedCards = defaults.object(forKey: "SavedCards") as? [String] ?? [String]()
               var savedNews = defaults.object(forKey: "SavedNews") as? [Any] ?? [Any]()
                var idx = 0
                   for i in 0..<savedCards.count {
                    if savedCards[i] == self.articleId{
                          idx = i
                          break
                      }
                  }
                  savedCards.remove(at: idx)
                  savedNews.remove(at: idx)
                  defaults.set(savedCards, forKey: "SavedCards")
                  defaults.set(savedNews, forKey: "SavedNews")
                
              }
             
        }
    
    func configureDate(){
        contentView.addSubview(myDate)
         myDate.font = myDate.font.withSize(14)
        myDate.translatesAutoresizingMaskIntoConstraints = false
       myDate.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant:5).isActive = true
        myDate.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true

    }
    func configureSection(){
        contentView.addSubview(mySection)
         mySection.font = mySection.font.withSize(14)
        mySection.translatesAutoresizingMaskIntoConstraints = false
       mySection.leadingAnchor.constraint(equalTo: myDate.trailingAnchor, constant:20).isActive = true
        mySection.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
    }
    func configureTitle(){
        contentView.addSubview(myTitle)
        myTitle.numberOfLines = 3
        myTitle.adjustsFontSizeToFitWidth = false
     myTitle.lineBreakMode =  NSLineBreakMode.byTruncatingTail
       myTitle.font = UIFont(name:"HelveticaNeue-Bold", size: 17.0)
       myTitle.translatesAutoresizingMaskIntoConstraints = false
        myTitle.textAlignment = .center
        myTitle.topAnchor.constraint(equalTo: myImg.bottomAnchor, constant: 5).isActive = true
        myTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant:5).isActive = true
    //myTitle.heightAnchor.constraint(equalToConstant: 80).isActive = true
        myTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5).isActive = true
    }
    func configureImg(){
        contentView.addSubview(myImg)
        //myImg.layer.cornerRadius = 10
        myImg.clipsToBounds = true
         myImg.translatesAutoresizingMaskIntoConstraints = false
         myImg.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        myImg.heightAnchor.constraint(equalTo: contentView.heightAnchor, constant: -120).isActive = true
        myImg.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
    }
    
   
}
