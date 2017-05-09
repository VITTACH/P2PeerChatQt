package org.qtproject.example.vittachpeer;

import com.google.firebase.iid.FirebaseInstanceId;
import com.google.firebase.iid.FirebaseInstanceIdService;

public class MyFirebaseInstanceIDService extends FirebaseInstanceIdService {

    @Override
    public void onTokenRefresh() {
        String refreshedToken = FirebaseInstanceId.getInstance().getToken();
        String logStr="Refreshed token: "+refreshedToken;

        sendRegistrationToServer(refreshedToken);
    }

    private void sendRegistrationToServer(String token) {
        String logStr="FCM registration token: " + token;
    }
}