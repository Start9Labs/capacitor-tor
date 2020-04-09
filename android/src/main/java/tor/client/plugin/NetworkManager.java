package tor.client.plugin;

import io.reactivex.rxjava3.core.Observable;
import io.reactivex.rxjava3.core.Observer;
import io.reactivex.rxjava3.subjects.PublishSubject;

public class NetworkManager {
    private static NetworkManager instance = null;

    private NetworkManager() {

    }

    public static NetworkManager getInstance() {
        if (instance == null) {
            instance = new NetworkManager();
        }
        return instance;
    }

    private PublishSubject<Boolean> onlineSubject = PublishSubject.create();

    public Observable<Boolean> onlineSignal() {
        return onlineSubject;
    }

    Observer<Boolean> onlineObserver() {
        return onlineSubject;
    }
}