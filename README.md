# OpenXJS
[![Dependency Status](https://gemnasium.com/softgames/openxjs.png)](https://gemnasium.com/softgames/openxjs)

## Usage

```javascript
var openXJS = new OpenXJS({deliveryUrl: "http://your.openx.server/openx/www/delivery/"});
```

### Display ads
Fill elments with ids `banner1` and `banner2` with content from OpenX zone 1 and 2.

```javascript
openXJS.displayAds({banner1: 1, banner2: 2}, targetingParameters, callback);
```

### Receive ad codes
Receive ad codes from OpenX zone 1 and 2.

```javascript
openXJS.receiveAdCodes({banner1: 1, banner2: 2}, targetingParameters, callback);
```

```javascript
// Response
{
  banner1: "code to display ad from zone 1",
  banner2: "code to display ad from zone 2"
}
```

## Test

```
make test
```

### Cloud tests
1. Setup [Sauce Connect](https://saucelabs.com/connect)
2. Enter your sauce credentials into `test/auth/sauce.json` in the following format:
```
{"username": "my-user", "key": "my-key"}
```
3. Run `node support/mocha-cloud.js`

## Contributing

openxjs is maintained by [Softgames](http://github.com/softgames)

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
