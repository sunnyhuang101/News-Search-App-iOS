# iOS News Search App 

(CSCI571-Web Technologies final project) <br>
Implemented an iOS mobile news app that demonstrated news of different categories and created a personalized bookmark for users to save articles and to share on their own social media<br><br>
**Skills: Node.js, Swift, Google Cloud App Engine, Xcode,JSON, CocoaPods, Model-View-Controller (MVC) design, OpenWeather API, Guardian API, Bing Autosuggest, Google Trends API** <br>
### Features
##### Home Tab
- Home Tab includes a search bar, a subview to show weather, and a table of top news cells sorted from most recent published date
- Weather subview shows weather information based on user location
- Search bar shows some autosuggestions after user enter some words and the result page shows related news articles according to the keyword
<p>
	<img src="./imgs/hometab.png" width="250px" />
	<img src="./imgs/autosuggest.png" width="250px" />
	<img src="./imgs/searchresult.png" width="250px" />
</p>



##### Detailed Article

- Users can click on any news cell to read the detail article
- Displaying a spinner when loading different scenes
- Clicking on the Twitter icon on top-right to share news on users' own social medias
 <p>
	<img src="./imgs/click.png" width="250px" />
	<img src="./imgs/spinner.png" width="250px" />
	<img src="./imgs/twitter.png" width="250px" />
</p>

##### Personalized Bookmark
- Clicking the bookmark icon on top-right to add/remove articles to/from users' Bookmark Tabs
- Users can also long press a cell in Home Tab to add/remove articles to/from Bookmark Tabs and share on Twitter
- Adding articles to Bookmark Tab allows users to read articles more conveniently
<p>
	<img src="./imgs/bookmarked.png" width="250px" />
	<img src="./imgs/longpress.png" width="250px" />
	<img src="./imgs/bookmark.png" width="250px" />
</p>

##### Headlines Tab/Trending Tab
- Headlines Tab shows top news of different categories including world, business, politics, sports, technology and science
- Trending Tab shows the search frequency of a particular term over time. Users can enter keywords to search trending of different terms
<p>
	<img src="./imgs/category.png" width="250px" />
	<img src="./imgs/trending.png" width="250px" />
</p>
