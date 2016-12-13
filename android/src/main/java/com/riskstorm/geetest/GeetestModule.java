package com.riskstorm.geetest;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import java.util.HashMap;
import java.util.Map;

import android.os.AsyncTask;
import android.content.Context;
import android.content.DialogInterface;
import android.util.Log;

import org.json.JSONObject;
import com.geetest.android.sdk.Geetest;
import com.geetest.android.sdk.GtDialog;
import com.geetest.android.sdk.GtDialog.GtListener;

public class GeetestModule extends ReactContextBaseJavaModule {

  private Boolean debug = false;
  private String challengeURL;
  private String validateURL;
  private GtAppDlgTask mGtAppDlgTask;
  private Geetest captcha;
  private Promise mPromise;

  public GeetestModule(ReactApplicationContext reactContext) {
    super(reactContext);
  }

  @Override
  public String getName() {
    return "RNGeetest";
  }

  @Override
  public Map<String, Object> getConstants() {
    final Map<String, Object> constants = new HashMap<>();
    return constants;
  }

  private void sendValidationEvent(Boolean success) {
      getReactApplicationContext()
        .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
        .emit("GeetestValidationFinished", success);
  }

  @ReactMethod
  public void setDebugMode(Boolean debug) {
    this.debug = debug;
  }

  @ReactMethod
  public void setChallengeURL(String url) {
    this.challengeURL = url;
  }

  @ReactMethod
  public void setValidateURL(String url) {
    this.validateURL = url;
  }

  @ReactMethod
  public void request(Promise promise) {
    mPromise = promise;
    Geetest _captcha = new Geetest(this.challengeURL, this.validateURL);
    captcha = _captcha;
    captcha.setTimeout(30000);

    captcha.setGeetestListener(new Geetest.GeetestListener() {
        @Override
        public void readContentTimeout() {
            mGtAppDlgTask.cancel(true);
            Log.e("geetest", "read content time out");
        }

        @Override
        public void submitPostDataTimeout() {
            //TODO 提交二次验证超时
            Log.e("geetest", "submit error");
        }
    });

    GtAppDlgTask gtAppDlgTask = new GtAppDlgTask();
    mGtAppDlgTask = gtAppDlgTask;
    mGtAppDlgTask.execute();
  }

  class GtAppDlgTask extends AsyncTask<Void, Void, Boolean> {

      @Override
      protected Boolean doInBackground(Void... params) {
          Log.i("geetest", "geetest checking server");
          return captcha.checkServer();
      }

      @Override
      protected void onPostExecute(Boolean result) {
          if (result) {
              // 根据captcha.getSuccess()的返回值 自动推送正常或者离线验证
              if (captcha.getSuccess()) {
                  Log.i("geetest", "captcha get success");
                  openGtTest(getCurrentActivity(), captcha.getGt(), captcha.getChallenge(), captcha.getSuccess());
              } else {
                  // TODO 从API_1获得极验服务宕机或不可用通知, 使用备用验证或静态验证
                  // 静态验证依旧调用上面的openGtTest(_, _, _), 服务器会根据getSuccess()的返回值, 自动切换
                  // openGtTest(getCurrentActivity(), captcha.getGt(), captcha.getChallenge(), captcha.getSuccess());
                  Log.e("geetest", "Geetest Server is Down.");

                  // 执行此处网站主的备用验证码方案
              }

          } else {
              Log.e("geetest", "Can't Get Data from API_1");
          }
      }
  }

  public void openGtTest(Context ctx, String id, String challenge, boolean success) {
      Log.i("geetest", "open geetest");
      GtDialog dialog = new GtDialog(ctx, id, challenge, success);
      // 启用debug可以在webview上看到验证过程的一些数据
      dialog.setDebug(this.debug);

      dialog.setOnCancelListener(new DialogInterface.OnCancelListener() {
          @Override
          public void onCancel(DialogInterface dialog) {
              // 取消验证
              Log.i("geetest", "user close the geetest.");
              mPromise.reject("400", "cancel");
              sendValidationEvent(false);
          }
      });

      dialog.setGtListener(new GtListener() {

          @Override
          public void gtResult(boolean success, String result) {
              if (success) {
                  try {
                      JSONObject res_json = new JSONObject(result);
                      Map<String, String> params = new HashMap<String, String>();
                      params.put("geetest_challenge", res_json.getString("geetest_challenge"));
                      params.put("geetest_validate", res_json.getString("geetest_validate"));
                      params.put("geetest_seccode", res_json.getString("geetest_seccode"));
                      captcha.submitPostData(params, "utf-8");
                      // 验证通过, 获取二次验证响应, 根据响应判断验证是否通过完整验证
                      mPromise.resolve(null);
                      sendValidationEvent(true);
                  } catch (Exception e) {
                      e.printStackTrace();
                  }

              } else {
                  // TODO 验证失败
              }
          }

          @Override
          public void gtCallClose() {
          }

          @Override
          public void gtCallReady(Boolean status) {
              if (status) {
                  //TODO 验证加载完成
                  Log.i("geetest", "geetest finish load");
              } else {
                  //TODO 验证加载超时,未准备完成
                  Log.e("geetest", "there's a network jam");
              }
          }

          @Override
          public void gtError() {
            Log.e("geetest", "Fatal Error Did Occur.");
          }
      });
    }
}
