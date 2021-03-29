# IIIF CloudFront tests

These tests ensure that the expected routes work in each environment.

It is advisable when making infrastructure changes via terraform to apply first in `test`, then `stage` and `prod` running these test scripts at the appropriate environment and ensuring they pass before moving to the next environment.

## Running these tests

```
# Install dependencies if you've not before
pip install -r requirements.txt

# "test", "stage" and "prod" are valid envs, if you omit --env the default is "prod"
./rewrite_tests.py --env test
```

### Docker

You can run these tests using docker:

```
# From this directory
docker build . -t iiiftests && docker run -t iiiftests --env stage
```

In addition you can run them using docker-compose (as in CI):

```
# From the project root
docker-compose run --rm iiif_tests --env stage
```
