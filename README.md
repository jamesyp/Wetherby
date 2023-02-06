# README

Wetherby takes an address and gives you the weather.

Enter a street address, city, and two-letter state code. Wetherby uses Google's address validation API to validate the address and get a zip code, convert it to a lat/long point, and passes the lat/long to the National Weather Service API for a running weekly forecast. Weather results are cached by zip code for 30 minutes, and address validation results are cached permanently. The forecast will show a disk icon if the weather data is from the cache. Just one page at the root `localhost:3000/` and it probably only works in a development environment.

It requires a `config/master.key` for decrypting the Google address API key. [Let me know](mailto:jamesyp@gmail.com) if you're supposed to have it.

Wetherby uses a light interactor pattern (`app/interactors`) to encapsulate its API calls, and makes requests using the HTTParty gem. The user only needs to enter street address, city, and two-letter state code, but not zip code. Since zip code is the cache key for weather results, I decided to retrieve it rather than let it be user-entered.

Tests are in RSpec, but there aren't any request/controller specs or other integration-y specs 😅, and a couple GitHub actions to run RSpec and Rubocop for PRs and merges. The app spins up the default SQLite server but doesn't have any database models. Error handling and user-facing validation & messaging could be greatly improved.

Styling by [Water.css](https://watercss.kognise.dev/).