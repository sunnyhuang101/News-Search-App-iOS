const googleTrends = require('google-trends-api');
const express = require('express');
const router = express.Router();

router.get('/:term', (req, res, next) => {
	const term = req.params.term;
	var date = new Date('2019-06-01')
	
	googleTrends.interestOverTime({keyword: term,  startTime: date})
	.then(function(response){
		var results = JSON.parse(response)
		data_list = []
		
	  //console.log('These results are awesome', results);
	  if (results != undefined && results.default != undefined && results.default.timelineData != undefined ){
	  	var i;
	  	var dataArr = results.default.timelineData

	  	for(i = 0; i < dataArr.length; i++){
	  		data_list.push(dataArr[i].value[0])
	  	}

	  }

	    res.send(data_list);
	})
	.catch(function(err){
	  console.error('there was an error', err);
	});

});
module.exports = router;