# CovidCmr

Data source of cases: https://github.com/novelcovid/api

A project experimenting with LiveView, and a little of WebScraping.

## Architecture

This project does not have a DB, it relies only on GenServer(processes) as state.

- The contribution section is a GET request to a website, parsing the website to find content related to the contributions.
- The contaminations section is 2 GET requests to an API in other to get the statistics for the world and CMR.

I use 2 GenServers, attached to a supervisor for Fault Tolerance. If it crashes, it automatically restarts

## Real Time with No JS
I did not write a single line of JS on this project. The updates are server side. This is made possible by LiveView, and Elixir/Erlang.

## Next Goals

