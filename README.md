# Random Anime Finder in Elm

Author: Brandon Le

Contributions:

* Instructor Casamento for help on the randomize mechanism and general Elm help
* [Help with random from Augustin82 and wolfadex](https://discourse.elm-lang.org/t/convert-random-int-to-string-for-use-in-url-builder/7081/3)
* [Http error to string by bdukes](https://stackoverflow.com/questions/56442885/error-when-convert-http-error-to-string-with-tostring-in-elm-0-19)

## Key takeaways

## Limitations

* Currently "random" is not really random because it is initialized from a seed. This leads to the same "random" sequence of anime being suggested everytime. Further work to replace `Random.step` with `Random.generate` is required.
* Issues from the API/inexperience with the API:
  * There are gaps in the Anime ID range which cause issues with fetching data. Future work may use a list of values for the random range that are valid rather than just an arbitrary range. In addition, a solution may already exist that has not been implemented here.
* 