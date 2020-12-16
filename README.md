# CovidCmr

Data source of cases: https://github.com/novelcovid/api

A project experimenting with LiveView, and a little of WebScraping.

## Architecture

For the Covid Stats and Countries infos it relies only on GenServer(processes) as state. They are in charge of fetching and updating their data.

- The contribution section is a GET request to a website, parsing the website to find content related to the contributions.
- The contaminations section is 2 GET requests to an API in other to get the statistics for the world and CMR.
- A last request to an API to get countries informations.

I use 2 GenServers, attached to a supervisor for Fault Tolerance. If it crashes, it automatically restarts

## Real Time with No JS
I did not write a single line of JS on this project. The updates are server side. This is made possible by LiveView, and Elixir/Erlang.

## Next Goals
- Build a filtering and sorting functionalities for the cases.
- Continue to improve the UI

