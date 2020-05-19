const express = require('express');
const router = express.Router();
const fetch = require('node-fetch');

router.get('/:articleId', (req, res, next) => {
const articleId = req.params.articleId.split("%2F").join("/");

url = 'https://content.guardianapis.com/'+articleId+'?api-key=a0eeb4bf-da3a-4020-b5a6-4949c35c7b02&show-blocks=all'
fetch(url)
  .then((response) => {
    return response.json(); 
  }).then((jsonData) => {
  	//console.log(url);
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

  	var dateRaw = jsonData.response.content.webPublicationDate;
  	var date = dateRaw.substring(8,10) + " " + monthDict[dateRaw.substring(5,7)] + " "+ dateRaw.substring(0,4);
  	var bodyArr = jsonData.response.content.blocks.body;
  	var description = "";
  	var webURL = jsonData.response.content.webUrl
  	var i;
  	for(i = 0; i < bodyArr.length; i++){
  		description += bodyArr[i].bodyHtml;
  	}
  
  	data_list.push({
  		"date":date,
  		"description":description,
  		"webURL":webURL
  	});

  res.send(data_list);
  }).catch((err) => {
    console.log('錯誤:', err);
  	
});
});

module.exports = router;