const http = require('http');
const fetch = require('node-fetch');
const cors = require('cors');
const express = require('express');
const app = express();
const newsRoute = require('./api/getNews');
const articleRoute = require('./api/getArticle');
const sectionRoute = require('./api/getSection');
const trendingRoute = require('./api/getTrending');
const searchRoute = require('./api/getSearch');

app.use('/getNews', newsRoute);
app.use('/getArticle', articleRoute)
app.use('/getSection', sectionRoute)
app.use('/getTrending', trendingRoute)
app.use('/getSearch', searchRoute)

const port = process.env.PORT|| 5000;

const server = http.createServer(app);

server.listen(port);