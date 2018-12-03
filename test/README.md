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

`travis encrypt WORKSPACE_ID=<your_ID>`

For Username and password based credentials:

`travis encrypt ASSISTANT_USERNAME=<your_user>`

`travis encrypt ASSISTANT_PASSWORD=<your_passwd>`

for IAM key based credentials:

`travis encrypt ASSISTANT_IAM_APIKEY=<your_IAM_key>`


>Note that using `--add .travis.yml` can lead to extra input that may cause problems. For best results, add the encryted credentials to the file manually. It should look similar to this:
```
env:
  global:
  - secure: QuNIqRtw4o9m3WwfQKQwOJQSGDxaDpfr/TubNw6TjZcwyjFs/wiRH2/uUPHjTIKzi15SUY3AV8yCt2jNe7hdWU+/V0YbQyLiE+FTblahblahblahblah8bcLXUj3a2cBvqTPR7alMuLfE5a1cw9kEmKcIUjMoFBJCYhLddyjLNhatpP7tYlZUrJuSeIGzkB2OO7dGvif9ABAvijpYUfDppc9rA7wDMD61WR4prH0GrIWiVHzHpHTDymGtMhkxKVt0Txb66HyEOu26q7fpNzBh65+EVavdRSEDpFjdrjrouu/1HyajpZYz/SwHuIQ41FngqU03/A50OAs5BE7Ga1sTYupW4sNUtzEMxNDlJTkY/m5Ap+5VtvLWYnNzMbKYcIc2LlTPTBbPzcb5XAN3orWU5hjt/GotqNxF9rxXrsbFQPHPHyq+HXzqX+iRzy1lRDTyju5KE6eFn/9bbI4eRtkvYwzUp3yTc7IeqBNBiIcyt0rBtYV7OQSeAbWnwjXVUWd8xI9aBrO/nyR5E2sAhwm6e8vGb46ypKN9Y89khOrF6/GCgko/yEpbUh+DgM9BPqsF0qsuwP9X8WnXXlikQyalHagwniDxsQMJ3FwiMxl6Crf3ZJBZyd4c+aTxXP92v6j9gneeqv6N1Jiwupj511rBmK6VKZA=
  - secure: XadYdFYhjETHNDvJrsmPP/2tpt76H9MwaxP0GInkM2Y6fX/jbDJh+CRDNVzwsn0D3H4AT8SgEHpVpjXvTM9fU4NZ7+u3GQ+lt0zLtMDgvkvWWCT+3KSblahblahblahblahblahXa4rHvxdgVbXz2vSV9RjCmPItoCEzrQdzZHiYdgoeFIZ3Z1L4jBt1Ev16YFnPzGDv6fwASsyjqytwZ+50kh4m3cfo3gWErxcphIdq7u7tn7kyRAhUdaP7BXzUtGkw+xPzQNk1NEuT05CukNgC5tvGQPTTYMucaZqqz2zUq2NRqa4wuunkVbh2UW2qwfROwaljMyY19V/ttEpIzLpU9zBdK7vqeHh0Gb20sevMCt0qt+yD9poSDmb84ceEhRgLKVZlCm2QgfP+8r+XS2cueyW3ZRi48+8nWGJT2958EK6Ew0KJYLIz5cFNMDRgjUMHk+KH/J7pKjJsnF4TWQ8Ixsi1dXm/PdQ8y7xiddt24eDQO8nfzCfjGKfNux8cAxRFYNQ+lYd1kMvI1T/3WOtPI4UtjyqU2TBbihX8resm3BxPsrEhZ3kAJ6pSDJ55t9Qrx6bvfrjU7k+NKXGN5aPTP+7pW4VeewF+PKffKWFbirtz/xsm2xghq44q1zeWGRqN9ngMEsgttXFsgrMQ4=
```
