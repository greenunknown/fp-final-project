# Random Anime Finder in Elm

[![Netlify Status](https://api.netlify.com/api/v1/badges/cf0bdd88-a996-4bdc-a235-015e521429e6/deploy-status)](https://app.netlify.com/sites/elastic-johnson-128b0c/deploys)

Author: Brandon Le

Contributions:

* Instructor Casamento for help on the randomize mechanism and general Elm help
* [Help with random from Augustin82 and wolfadex](https://discourse.elm-lang.org/t/convert-random-int-to-string-for-use-in-url-builder/7081/3)
* [Http error to string by bdukes](https://stackoverflow.com/questions/56442885/error-when-convert-http-error-to-string-with-tostring-in-elm-0-19)

## Project Description

An Elm web app that randomly selects an anime from the Kitsu API to show you. You get a title, a picture, and a description of the show. You might get unlucky (or lucky depending on how you look at it) and find a "sadness" page when the random number gods give you a number with no anime associated with it! The "random" mechanism is currently deterministic so the same sequence will be delivered to you.

The `src/Main.elm` file is where most of my efforts were put whereas the other `.elm` files were experiments.

### Build Instructions

* Make sure to install elm first: [https://guide.elm-lang.org/install/](https://guide.elm-lang.org/install/)

1. In the top-level directory (the one above `src`), run: `elm make src/Main.elm --optimize`. This will create an `index.html` file which will be the web app.
2. Serve the web app or open it in a browser.

## Key Takeaways

* I learned:
  * How HTTP works in Elm
  * How to decode JSON data from an API
  * How to work with random numbers in a deterministic way (`Random.step`)
* I tried to:
  * Work with better random numbers with `Random.generate`
  * Implement an anime search function
  * Deploy my Elm web app on Netlify

## Limitations

* Currently "random" is not really random because it is initialized from a seed. This leads to the same "random" sequence of anime being suggested everytime. Further work to replace `Random.step` with `Random.generate` is required.
* Issues from the API/inexperience with the API:
  * There are gaps in the Anime ID range which cause issues with fetching data. Future work may use a list of values for the random range that are valid rather than just an arbitrary range. In addition, a solution may already exist that has not been implemented here.
* Hosting: The app is not currently hosted anywhere. This is because I could not get it to build and run on Netlify on my own. Future work would include integrated my app into the elm-spa framework to not only build my app and deploy, but also have an integrated workspace. I did not do this for my project because I wanted to learn from the basics rather than tackle them and a framework at the same time.

## Resources I Used

### Learning Elm

* [guide.elm-lang.org](https://guide.elm-lang.org/)
* [elmprogramming.com][https://elmprogramming.com/]
* [Elm crash course - Building unbreakable webapps fast](https://www.youtube.com/watch?v=kEitFAY7Gc8) 
* [Elm Packages](https://package.elm-lang.org/)

### API

* [Kitsu](https://hummingbird-me.github.io/api-docs/)
* [Jikan](https://jikan.docs.apiary.io/#reference/0/character)