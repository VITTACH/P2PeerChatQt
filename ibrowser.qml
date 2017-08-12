import QtQuick   2.0
import QtWebView 1.1

import "js/URLQuery.js" as URLQuery

WebView {
    url: loader.urlLink
    anchors.fill:parent

    property var authRegExpVK: {
        /^https:\/\/oauth.vk.com\/blank.html/;
    }
    property var authRegExpFB: {
        /^https:\/\/www.facebook.com\/connect\/login_success.html/;
    }

    function successAuth(site) {
        loader.urlLink="about:blank"
        busyIndicator.visible = true
        loader.loginByVk()
    }

    onLoadingChanged: {
        var result=URLQuery.parseParams(loadRequest.url.toString())

        if(authRegExpVK.test(loadRequest.url.toString())) {
            loader.userId = result.user_id
            loader.aToken = result.access_token
            successAuth("VK")
        }
        else
        if(authRegExpFB.test(loadRequest.url.toString())) {
            loader.aToken = result.access_token
            successAuth("FB")
        }
    }
}
