/**
 * @providesModule RNGeetest
 */
import { NativeModules, Platform } from 'react-native';
const { RNGeetest } = NativeModules;

let _challengeURL = null;
let _validateURL = null;

function setDebugMode(debugMode) {
  RNGeetest.setDebugMode(debugMode);
}

function request(challengeURL, validateURL) {
  return RNGeetest.request(challengeURL || _challengeURL, validateURL || _validateURL);
}

function setPresentType(type) {
  if (Platform.OS === 'ios') {
    RNGeetest.setPresentType(type);
  }
}

function setChallengeURL(url) {
  _challengeURL = url;
}

function setValidateURL(url) {
  _validateURL = url;
}

export default {
  setDebugMode,
  setPresentType,
  setChallengeURL,
  setValidateURL,
  request
};
