# Screen Developer Guide
#### By: Mason Wolters - 4/6/2015
#### Feel free to ask questions: woltersm@umich.edu

## Project Directory
- `/Screen_iOS_App`
	- Contains all iOS code for building iPhone application (Xcode Project)
- `/ScreenCloudCode`
	- Contains all server-side code that is deployed to Parse. 
- `/Screen_Design`
	- Contains some screens designed in Photoshop/Sketch
- `/Screen_UI_Images`
	- Contains all UI assets (Icons, logos, etc.)
- `/Screen_API_Codebase`
	- Contains all the custom interfaces from the iOS app for the different APIs (Objective-C code). Can be used to reference the general structure of the API usage/database structure.
- `/Screen_Docs
	- Contains assets for documentation
- `/Screen_Passwords.pdf`
	- Contains account passwords and API keys (Password protected PDF)

## Development Environment Setup
- Install cocoapods: 
	- Open terminal and run: 
	- `sudo gem install cocoapods`
- Install Parse Command Line Tool
	- Open terminal and run: 
	- `curl -s https://www.parse.com/downloads/cloud_code/installer.sh | sudo /bin/bash`

## Building the iOS App
- You must run cocoapods in the iOS directory by doing the following:
- Open terminal and `cd` into `/Screen_iOS_App`
- Run: `pod install`
- Now you can open `Screen.xcworkspace` using Xcode and build the app (Don’t use `Screen.xcodeproj` as it won’t build)
- Storyboard: Change the view class in Interface Builder to “Compact Width | Regular Height” to see all the views in the storyboard

## Deploying Server Code
- Refer to [Parse Cloud Code Guide](https://parse.com/docs/cloud_code_guide#cloud_code) for details.
- The general file structure is:
	- `/ScreenCloudCode/cloud`
		- Parse cloud code files: default file is `main.js`, refer to cloud code guide
	- `/ScreenCloudCode/config`
		- Server configuration files 
	- `/ScreenCloudCode/public`
		- Publicly hosted files: root domain deaults to `index.html`
- To deploy to parse:
	- Open terminal and `cd` into `/ScreenCloudCode`
	- Run: `parse deploy`
	- This updates all the server code on parse with your local version

## APIs Used

#### Parse
- Usage: custom backend to store User data
- Main interface: `/Screen_API_Codebase/Parse/ParseHelper.h`

#### The Movie Database (TMDB)
- Usage: provides all of the movie data
- Main interface: `/Screen_API_Codebase/TheMovieDatabase/TMDBHelper.h`

#### Gracenote OnConnect
- Usage: provides showtimes and online video availability
- Main interface: `/Screen_API_Codebase/OnConnect/OnConnectHelper.h`

#### Rotten Tomatoes
- Usage: retrieve Rotten Tomatoes ratings for movies
- Main interface: `/Screen_API_Codebase/RottenTomatoes/RottenTomatoesHelper.h`

#### Google Places
- Usage: retrieve information about theaters (ratings), as well as location input auto complete
- Main interface: `/Screen_API_Codebase/GooglePlaces/GooglePlacesHelper.h`

## Backend Structure and Custom Endpoints
- Familiarize yourself with [Parse](https://www.parse.com/docs) if you aren’t already. The backend is pretty simple and only consists of 3 classes on Parse. Here’s an overview of the structure:
![db](/Screen_Docs/Screen_Database_Model.png)

### Classes

#### User
- `objectId` (String)
- `username` (String)
- `password` (String)
- `movies` (Relation<Movie>) : Watchlist for User
- `fbId` (String) : Facebook Id of user. Set when user logs into Facebook
- `lowercaseName` (String) : Used for searching users. Set when account is created
- `name` (String) : Name of user
- `sentFriendRequests` (Relation<User>) : Users that friend requests have been sent to
- `friendRequests` (Relation<User>) : Users that have requested to be friends
- `friends` (Relation<User>) : Users that this user is friends with
- `pictureThumbnail` (File) : Thumbnail for profile picture if set
- `seen` (Relation<Movie>) : Movies this user has seen
- `ratings` (JSON) : Movie ratings for user (max 5) in the form: `{tmdbId: rating}` i.e. `{“4536”: 4.5}`
- `hasBeenAlerted` (Array<String>) : Used to alert user when movies on their watchlist begin playing nearby. Add tmdbId to this when adding to watchlist if the movie is playing nearby
- `hasExisted` (Boolean) : Internal use
- `picture` (File) : Full-res profile picture
- `twitterId` (String) : Twitter id of user
- `twitterImageUrl` (String) : URL of Twitter profile image

#### Movie
This essentially mirrors the Movie objects from the TMDB API and acts as a cache of that. Save one of these every time a users adds a movie to their watchlist. If the save succeeds, it means that there was not a matching movie already. If the save fails, then this movie already existed in Parse so just continue.
- `objectId` (String)
- `adult` (String)
- `backdropPath` (String)
- `budget` (String)
- `homepage` (String)
- `imdbId` (String) : IMDB id of this movie
- `originalTitle` (String) : Original (non-translated) title
- `overview` (String) : Brief summary
- `popularity` (String) : From TMDB API; not used
- `posterPath` (String) : Path to retrieve poster image (Use TMDB API to retrieve)
- `releaseDate` (String) : “2015-04-06”
- `runtime` (String) : Length of movie in minutes
- `title` (String) : Title of movie
- `tmdbId` (String) : TMDB id of movie
- `users` (Relation<User>) : All users that have this movie on their watchlist
- `userCount` (Number) : Number of users that have this movie on their watchlist. Must be incremented whenever a user adds/removes this movie from their watchlist.
- `seenCount`	 (Number) : Number of users that have seen this movie. Must be incremented whenever a user adds/removes this movie as seen.
- `usersSeen` (Number) : All users that have marked this movie as seen

#### MovieLocation
Make one of these every time a user adds a movie to their watchlist so we can track the most popular movies based on location.
- `objectId` (String)
- `movieId` (String) : objectId of movie
- `location` (GeoPoint) : Location of user when they added this movie to their watchlist.
- `user` (Pointer<User>) : User who added movie to watchlist
- `movie` (Pointer<Movie>) : Movie added to watchlist

### Custom Parse Cloud Functions

- `topMoviesForArea`
	- Description: Returns array of most popular movies in area (Most on watchlists)
	- Input: `latitude`, `longitude`, `radius` in meters 
		- `{latitude: “21.4567”, longitude: “34.5678”, radius: “5000”}`
	- Output: `[{count: “5”, movieId: “asdf345”, movie: Movie}, …]`
- `requestMovie`
	- Description: Emails tchear@gmail.com the requested movie
	- Input: `title`, `description`, `user`
	- Output: success/error
- `friendRequestUser`
	- Description: Send friend request from logged in user to userId
	- Input: `userId`
	- Output: success/error
- `acceptFriendRequest`
	- Description: accepts friend request for currently logged in user from userId
	- Input: `userId`
	- Output: success/error
- `authenticateTheaterUser`
	- Description: makes sure user has elevated privileges to access location data (User is part of Theater role)
	- Input: `userId`
	- Output: returns `true` if currently logged in user has rights to access MovieLocation data
