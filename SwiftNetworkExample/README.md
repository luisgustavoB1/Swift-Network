# SwiftNetwork Example

A minimal iOS demo app that uses **SwiftNetwork** and **SwiftNetworkCombine** via a local package dependency. It shows async/await, Combine, and error handling with real and mock-friendly APIs.

## How to run

1. Open the **workspace** from the repository root so the app can resolve the package:

   ```bash
   open SwiftNetwork.xcworkspace
   ```

2. Select the **SwiftNetworkExample** scheme and run on a simulator or device.

## What it demonstrates

- **JSONPlaceholder** (no API key): GET /posts, GET /users, POST /posts, and a Combine demo (GET /posts/:id). Works out of the box.
- **Home (TMDB)**: Movie lists (Popular, Top Rated, Upcoming, Now Playing) using The Movie DB API. Requires a TMDB API key (see below).

## Configuring the TMDB API key

The Home section reads the API key from **Info.plist**.

1. Get a free API key at [themoviedb.org/settings/api](https://www.themoviedb.org/settings/api).
2. In Xcode: select the **SwiftNetworkExample** target → **Info** tab → under **Custom iOS Target Properties**, find **TMDB_API_KEY** and set your key as the value.
3. Or edit **Info.plist** and set the `TMDB_API_KEY` string to your key.

If the key is missing or empty, the Home section will not load data (e.g. 401). **Do not commit your real API key** to the repo; use a local override or leave it empty in version control.

## Project layout

- The app lives in **SwiftNetworkExample/** at the repository root.
- It depends on the SwiftNetwork package via a relative path (`..` to the repo root).
- The workspace (**SwiftNetwork.xcworkspace**) includes both the example app and the SwiftNetwork package.
