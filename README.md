
# XKCD Comics Viewer

A native iOS app for browsing, searching, and saving XKCD comics, built for the Shortcut coding challenge.

## Features Implemented

### Core Functionality
- **Paginated browsing** of all XKCD comics (20 per page, latest first)
- **Search** by comic number or title
- **Favorites** with offline image caching via SwiftData persistence
- **Comic details** with full image, alt-text, date, and explainxkcd.com integration
- **Native sharing** via iOS ShareSheet (from detail view or swipe actions)
- **Pull-to-refresh** and smooth page navigation

### User Experience
- Swipe actions for quick favorite/unfavorite and sharing
- Dedicated favorites tab with delete gestures
- Responsive layout for all iPhone sizes (Tested on iPhone SE and 17 Pro Max)
- Clean, readable interface with styling inspired by the actual XKCD website: Blue background, white stacks with a thin black border
- Removed support for Vision and Mac
- Made supported orientation only Portrait

## Architecture & Project Structure

### MVVM
- **Models/** 
- **Services/** 
- **ViewModels/** 
- **Views/** 

## Tech Stack

- SwiftUI
- SwiftData (local storage)
- MVVM architecture
- Async/await networking

## Requirements

- iOS 17.6+
- Xcode 15.0+
