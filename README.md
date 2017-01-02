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

## Link - iOS

### Manually

* Right click on Libraries, select **Add files to "…"** and select `node_modules/react-native-geetest/RNGeetest.xcodeproj`

* Select your project and under **Build Phases -> Link Binary With Libraries**, press the + and select `libRNGeetest.a`

### With `react-native link`

```bash
$ react-native link
```


## Link - Android

Add to `android/settings.gradle`:

```
include ':geetest-sdk'
project(':geetest-sdk').projectDir = new File(rootProject.projectDir, '../node_modules/react-native-geetest/android/gtsdk/sdk')
include ':react-native-geetest'
project(':react-native-geetest').projectDir = new File(rootProject.projectDir, '../node_modules/react-native-geetest/android')
```

Add the compile project line to `android/app/build.gradle` (inside `dependencies`):

```
dependencies {
    // ... other content ... 
    compile project(':react-native-geetest')
}
```

Inside `MainApplication.java` (normally somewhere here android/app/src/main/java/com/<your-app-name>/MainApplication.java)
 add `import import com.riskstorm.geetest.GeetestPackage;` and `new GeetestPackage()` like in the example below

 ```
 import com.riskstorm.geetest.GeetestPackage;

 /* ... other content ... */

   @Override
    protected List<ReactPackage> getPackages() {
      return Arrays.<ReactPackage>asList(
          new MainReactPackage(),
          new GeetestPackage()
      );
    }
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

Also you can listen to `GeetestValidationFinished` event using `DeviceEventEmitter`,
please view details in the Example project.

## License

MIT
