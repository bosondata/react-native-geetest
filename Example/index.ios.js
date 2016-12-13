/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, { Component } from 'react';
import {
  AppRegistry,
  StyleSheet,
  Text,
  View,
  TouchableOpacity,
  DeviceEventEmitter
} from 'react-native';

import Geetest from 'react-native-geetest';


export default class Example extends Component {

  componentWillMount() {
    Geetest.setChallengeURL('http://api.apiapp.cc/gtcap/start-mobile-captcha/');
    Geetest.setValidateURL('http://api.apiapp.cc/gtcap/gt-server-validate/');
  }

  componentDidMount() {
    this._handleGeetestValidation = this._handleGeetestValidation.bind(this);
    DeviceEventEmitter.addListener('GeetestValidationFinished', this._handleGeetestValidation);
  }

  componentWillUnmount() {
    DeviceEventEmitter.removeListener('GeetestValidationFinished', this._handleGeetestValidation);
  }


  _handleGeetestValidation(result) {
    alert('Validation result: ' + result);
  }

  render() {
    return (
      <View style={styles.container}>
        <Text style={styles.welcome}>
          Welcome to react-native-geetest!
        </Text>
        <TouchableOpacity onPress={() => {
          Geetest.request().then(() => {
            // alert('success');
          }).catch(() => {
            // alert('failure');
          });
        }}>
          <View style={{borderWidth: 1, borderColor: '#CCCCCC', padding: 10}}>
            <Text>Trigger Geetest</Text>
          </View>
        </TouchableOpacity>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  }
});

AppRegistry.registerComponent('Example', () => Example);
