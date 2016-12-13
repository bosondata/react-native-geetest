/**
 * @providesModule RNGeetest
 */
import { NativeModules, Platform } from 'react-native';
const { RNGeetest } = NativeModules;

function setDebugMode(debugMode) {
  RNGeetest.setDebugMode(debugMode);
}

function request() {
  return RNGeetest.request();
}

function setPresentType(type) {
  if (Platform.OS === 'ios') {
    RNGeetest.setPresentType(type);
  }
}

function setChallengeURL(url) {
  RNGeetest.setChallengeURL(url);
}

function setValidateURL(url) {
  RNGeetest.setValidateURL(url);
}

export default {
  setDebugMode,
  setPresentType,
  setChallengeURL,
  setValidateURL,
  request
};
