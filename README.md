# Full Text Search in Rails

Instructions for how to run this repository locally and load the article data can be found below.

## Local Development

This repository works best in Docker using Docker Compose. To start the application, run `docker-compose up`, which will start the DB (Postgres) and Web (Rails) containers.

## Loading Article Data

Data can be loaded by running a rake task via the `docker-compose run web bundle exec rake article:data` command. It will load a few pages of data from GitHub's recent job postings along with data from Hacker News.
