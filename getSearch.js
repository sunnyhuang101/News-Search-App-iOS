const express = require('express');
const router = express.Router();
const fetch = require('node-fetch');

router.get('/:keyword', (req, res, next) => {
	const keyword = req.params.keyword;
	url = 'https://content.guardianapis.com/search?q='+keyword+'&api-key=a0eeb4bf-da3a-4020-b5a6-4949c35c7b02&show-blocks=all'
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
    			if (jsonData.response.results[i].blocks != undefined && jsonData.response.results[i].blocks.main != undefined &&  jsonData.response.results[i].blocks.main.elements != undefined &&  jsonData.response.results[i].blocks.main.elements[0].assets != undefined && jsonData.response.results[i].blocks.main.elements[0].assets[0]!=undefined && jsonData.response.results[i].blocks.main.elements[0].assets[0].file != undefined  ){
            img = jsonData.response.results[i].blocks.main.elements[0].assets[0].file;
          }
          else{
            img = "";
          }
          title = jsonData.response.results[i].webTitle;
          var today = new Date();
          var newsToday= jsonData.response.results[i].webPublicationDate;
          var newsDate = new Date(newsToday);
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