## Testing

Run unit and funtional tests with:
`npm test`

## Travis CI

Note that running the functional tests in TravisCI require
credentials for the Conversation Service and a Conversation
workspace ID.
[Travis Environment Variables](https://docs.travis-ci.com/user/environment-variables/#Defining-encrypted-variables-in-.travis.yml)

With travis installed via

 `gem install travis`

 encrypt with:

`travis encrypt WORKSPACE_ID=<your_ID> --add .travis.yml`

`travis encrypt CONVERSATION_USERNAME=<your_user> --add .travis.yml`

`travis encrypt CONVERSATION_PASSWORD=<your_passwd> --add .travis.yml`

