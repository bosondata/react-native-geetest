# react-native-geetest

Geetest binding for react-native

## Installation

For npm:

```bash
$ npm install --save react-native-geetest
```

For Yarn:

```bash
$ yarn add react-native-geetest
```

## Link

### Manually

* Right click on Libraries, select **Add files to "…"** and select `node_modules/react-native-geetest/RNGeetest.xcodeproj`

* Select your project and under **Build Phases -> Link Binary With Libraries**, press the + and select `libRNGeetest.a`

### With `react-native link`

```bash
$ react-native link
```


## Usage

```javascript
import Geetest from 'react-native-geetest'

Geetest.setChallengeURL('Your challenger URL');
Geetest.setValidateURL('Your validate URL');

Geetest.request().then(() => {
  alert('success');
}).catch(() => {
  alert('failure');
});
```

## Todo

- [ ] Android support
- [ ] Better documentation
