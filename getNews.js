const express = require('express');
const router = express.Router();
const fetch = require('node-fetch');

router.get('/', (req, res, next) => {
//const tag = req.params.tag;


url = 'https://content.guardianapis.com/search?orderby=newest&show-fields=starRating,headline,thumbnail,short-url&api-key=a0eeb4bf-da3a-4020-b5a6-4949c35c7b02';

fetch(url)
  .then((response) => {
    return response.json(); 
  }).then((jsonData) => {
  	data_list = [];
  	let monthDict = {
  		"01":"Jan",
  		"02":"Feb",
  		"03":"Mar",
  		"04":"Apr",
  		"05":"May",
  		"06":"Jun",
  		"07":"Jul",
  		"08":"Aug",
  		"09":"Sep",
  		"10":"Oct",
  		"11":"Nov",
  		"12":"Dec"
  	};
  	var i;
  	var count = 0;
  	for(i=0; i < jsonData.response.results.length; i++){
  		if (count == 10 ) break;
  		var img;
  		var title;
  		var time;
  		var section;
  		var articleId;

  		 var date;
  		if (jsonData.response.results[i].webTitle != undefined && jsonData.response.results[i].webPublicationDate != undefined && jsonData.response.results[i].sectionName != undefined && jsonData.response.results[i].id != undefined){
        //console.log(jsonData.response.results[i]);
  			if (jsonData.response.results[i].fields != undefined && jsonData.response.results[i].fields.thumbnail != undefined){
  				img = jsonData.response.results[i].fields.thumbnail;
  			}
  			else{
  				img = "";
  			}

  			title = jsonData.response.results[i].webTitle;

  			//if (title.length > 200){
  				//title = title.substring(0, 200) + "...";
  			//}

  			//var local = new Date().toLocaleString().split(':').join('/').split(' ').join('/').split('/');
  			
  			//var today= new Date(parseInt(local[2]), parseInt(local[0])-1,parseInt(local[1]),parseInt(local[3]), parseInt(local[4]), parseInt(local[5]));
  			var today = new Date();
  		
  			
  			var newsToday= jsonData.response.results[i].webPublicationDate;
        var newsDate = new Date(newsToday);
  			//var newsHours =  newsToday.substring(11,13);
  			//var newsMinutes = newsToday.substring(14,16);
  			//var newsSeconds = newsToday.substring(17,19);
  			
  			//newsDate.setHours(newsHours, newsMinutes, newsSeconds);
  		
  			
  			var diff = Math.abs(today - newsDate);
        //console.log(diff)
  			if ((diff/3600000) > 1){
  				//hours
  				time = parseInt(diff/3600000).toString() + "h ago";
  			}
  			else if ((diff/60000) > 1 ){
  				time = parseInt(diff/60000).toString() + "m ago";
  			}
  			else{
  				time = parseInt(diff/1000).toString() + "s ago";
  			}
  			date = newsToday.substring(8,10) + " " + monthDict[newsToday.substring(5,7)] + " "+ newsToday.substring(0,4);
  			/*
  			if ((curHours - newsHours) >= 2 || ((curHours-newsHours) == 1 && (curMinutes - newsMinutes) >= 0)){
  				time = (curHours - newsHours).toString() + "h ago";
  			}
  			else if ((curMinutes - newsMinutes) >= 2 || ){
  				time = (curMinutes - newsMinutes).toString() + "m ago";
  			}
			*/

			section = jsonData.response.results[i].sectionName;
			articleId = jsonData.response.results[i].id;
  			 data_list.push({
  			 	'img':img,
  			 	'title':title,
  			 	'time':time,
  			 	'section':section,
  			 	'articleId':articleId,
  			 	'date':date
  			 });

  			 count+=1;
  		}



  	}

    res.send(data_list);
  }).catch((err) => {
    console.log('錯誤:', err);
});
});
module.exports = router;
  	