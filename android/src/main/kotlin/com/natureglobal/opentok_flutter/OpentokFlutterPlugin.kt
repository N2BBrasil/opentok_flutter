package com.natureglobal.opentok_flutter

import android.content.Context
import android.media.AudioDeviceInfo
import android.media.AudioManager
import android.opengl.GLSurfaceView
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.ViewGroup
import com.opentok.android.AudioDeviceManager
import com.opentok.android.BaseAudioDevice
import com.opentok.android.BaseVideoRenderer
import com.opentok.android.OpentokError
import com.opentok.android.Publisher
import com.opentok.android.PublisherKit
import com.opentok.android.Session
import com.opentok.android.Stream
import com.opentok.android.Subscriber
import com.opentok.android.SubscriberKit
import io.flutter.embedding.engine.plugins.FlutterPlugin


/** OpentokFlutterPlugin */
class OpentokFlutterPlugin : FlutterPlugin, OpenTok.OpenTokHostApi {
    private lateinit var openTokPlatform: OpenTok.OpenTokPlatformApi
    private lateinit var audioManager: AudioManager

    private var context: Context? = null

    private var communicationDeviceChangedListener: AudioManager.OnCommunicationDeviceChangedListener? =
        null

    private var session: Session? = null
    private var publisher: Publisher? = null
    private var subscriber: Subscriber? = null

    private lateinit var opentokVideoPlatformView: OpentokVideoPlatformView

    // region Lifecycle methods
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        flutterPluginBinding.platformViewRegistry.registerViewFactory(
            "opentok-video-container", OpentokVideoFactory()
        )

        context = flutterPluginBinding.applicationContext
        opentokVideoPlatformView = OpentokVideoFactory.getViewInstance(context)
        audioManager = context!!.getSystemService(Context.AUDIO_SERVICE) as AudioManager

        OpenTok.OpenTokHostApi.setup(flutterPluginBinding.binaryMessenger, this)
        openTokPlatform = OpenTok.OpenTokPlatformApi(flutterPluginBinding.binaryMessenger)


        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            communicationDeviceChangedListener =
                AudioManager.OnCommunicationDeviceChangedListener { device -> // Handle changes
                    if (device != null) {
                        println("AudioManager.OnCommunicationDeviceChangedListener: ${device.type}")
                        notifyAudioOutputDeviceChanged(getOutputDevice(device))
                    }
                }

            audioManager.addOnCommunicationDeviceChangedListener(
                context!!.mainExecutor,
                communicationDeviceChangedListener!!,
            )
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        OpenTok.OpenTokHostApi.setup(binding.binaryMessenger, null)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            if (communicationDeviceChangedListener != null) {
                audioManager.removeOnCommunicationDeviceChangedListener(
                    communicationDeviceChangedListener!!
                )
            }
        }

        context = null
    }
    // endregion

    // region Opentok flutter plugin methods
    override fun initSession(config: OpenTok.OpenTokConfig) {
        notifyConnectionStateChange(OpenTok.ConnectionState.WAIT)

        session = Session.Builder(context, config.apiKey, config.sessionId).build()
        session?.setSessionListener(sessionListener)
        session?.connect(config.token)
    }

    override fun endSession() {
        session?.disconnect()
    }

    override fun toggleCamera() {
        publisher?.cycleCamera()
    }

    override fun toggleAudio(enabled: Boolean) {
        publisher?.publishAudio = enabled
    }

    override fun toggleVideo(enabled: Boolean) {
        publisher?.publishVideo = enabled
    }

    override fun onPause() {
        try {
            AudioDeviceManager.getAudioDevice().stopCapturer()
            session?.onPause()
            Log.i("OpenTok Flutter", "AudioDeviceManager.getAudioDevice().stopCapturer")
        } catch (ex: Exception) {
            Log.e("OpenTok Flutter", ex.message ?: "Error on pause", ex.cause)
        }
    }

    override fun onResume() {
        try {
            AudioDeviceManager.getAudioDevice().startCapturer()
            session?.onResume()
            Log.i("OpenTok Flutter", "AudioDeviceManager.getAudioDevice().startCapturer")
        } catch (ex: Exception) {
            Log.e("OpenTok Flutter", ex.message ?: "Error on resume", ex.cause)
        }
    }

    override fun onStop() {
        publisher?.onStop()
    }

    override fun getConnectionId(): String {
        return session!!.connection!!.connectionId
    }

    private fun getOutputDevice(deviceInfo: AudioDeviceInfo? = null): OpenTok.AudioOutputDevice {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            when ((deviceInfo ?: audioManager.communicationDevice!!).type) {
                AudioDeviceInfo.TYPE_BUILTIN_SPEAKER -> {
                    OpenTok.AudioOutputDevice.SPEAKER
                }

                AudioDeviceInfo.TYPE_WIRED_HEADSET -> {
                    OpenTok.AudioOutputDevice.HEADPHONE
                }

                AudioDeviceInfo.TYPE_BLUETOOTH_A2DP, AudioDeviceInfo.TYPE_BLUETOOTH_SCO -> {
                    OpenTok.AudioOutputDevice.BLUETOOTH
                }

                else -> {
                    OpenTok.AudioOutputDevice.RECEIVER
                }
            }
        } else {
            if (audioManager.isSpeakerphoneOn) {
                OpenTok.AudioOutputDevice.SPEAKER
            } else if (isBluetoothHeadsetOn() && AudioDeviceManager.getAudioDevice().bluetoothState.equals(BaseAudioDevice.BluetoothState.Connected)) {
                OpenTok.AudioOutputDevice.BLUETOOTH
            } else if (isHeadsetOn()) {
                OpenTok.AudioOutputDevice.HEADPHONE

            } else {
                OpenTok.AudioOutputDevice.RECEIVER
            }
        }
    }

    override fun listAvailableOutputDevices(): List<String> {
        val availableOutputs: MutableList<OpenTok.AudioOutputDevice> = ArrayList()

        availableOutputs.add(OpenTok.AudioOutputDevice.RECEIVER)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val devices = audioManager.getDevices(AudioManager.GET_DEVICES_OUTPUTS)

            for (device in devices) {
                when (device.type) {
                    AudioDeviceInfo.TYPE_BUILTIN_SPEAKER -> {
                        availableOutputs.add(OpenTok.AudioOutputDevice.SPEAKER)

                    }

                    AudioDeviceInfo.TYPE_WIRED_HEADSET -> {
                        availableOutputs.add(OpenTok.AudioOutputDevice.HEADPHONE)
                    }

                    AudioDeviceInfo.TYPE_BLUETOOTH_A2DP, AudioDeviceInfo.TYPE_BLUETOOTH_SCO -> {
                        availableOutputs.add(OpenTok.AudioOutputDevice.BLUETOOTH)
                    }
                }
            }
        } else {
            if (isBluetoothHeadsetOn()) {
                availableOutputs.add(OpenTok.AudioOutputDevice.BLUETOOTH)
            } else if (isHeadsetOn()) {
                availableOutputs.add(OpenTok.AudioOutputDevice.HEADPHONE)
            }

            availableOutputs.add(OpenTok.AudioOutputDevice.SPEAKER)
        }

        return availableOutputs.map { device -> device.name }
    }

    override fun setOutputDevice(device: OpenTok.AudioOutputDevice) {
        val baseAudioDevice = AudioDeviceManager.getAudioDevice()

        if (getOutputDevice() == OpenTok.AudioOutputDevice.BLUETOOTH) {
            audioManager.stopBluetoothSco()
            audioManager.isBluetoothScoOn = false
        }

        when (device) {
            OpenTok.AudioOutputDevice.SPEAKER -> {
                audioManager.mode = AudioManager.MODE_NORMAL
                baseAudioDevice.outputMode = BaseAudioDevice.OutputMode.SpeakerPhone

                notifyAudioOutputDeviceChanged(OpenTok.AudioOutputDevice.SPEAKER)
            }

            OpenTok.AudioOutputDevice.RECEIVER -> {
                audioManager.mode = AudioManager.MODE_IN_COMMUNICATION
                baseAudioDevice.outputMode = BaseAudioDevice.OutputMode.Handset

                notifyAudioOutputDeviceChanged(OpenTok.AudioOutputDevice.RECEIVER)
            }

            OpenTok.AudioOutputDevice.BLUETOOTH -> {
                audioManager.mode = AudioManager.MODE_NORMAL
                baseAudioDevice.outputMode = null

                audioManager.startBluetoothSco()
                audioManager.isBluetoothScoOn = true
                audioManager.isSpeakerphoneOn = false

                notifyAudioOutputDeviceChanged(OpenTok.AudioOutputDevice.BLUETOOTH)
            }

            OpenTok.AudioOutputDevice.HEADPHONE -> {
                audioManager.mode = AudioManager.MODE_NORMAL
                baseAudioDevice.outputMode = null

                audioManager.isSpeakerphoneOn = false

                notifyAudioOutputDeviceChanged(OpenTok.AudioOutputDevice.HEADPHONE)
            }
        }
    }


    // region Opentok callbacks
    private val sessionListener: Session.SessionListener = object : Session.SessionListener {
        override fun onConnected(session: Session) {
            publisher = Publisher.Builder(context).build().apply {
                setPublisherListener(publisherListener)

                renderer?.setStyle(
                    BaseVideoRenderer.STYLE_VIDEO_SCALE, BaseVideoRenderer.STYLE_VIDEO_FILL
                )

                view.layoutParams = ViewGroup.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT
                )
                opentokVideoPlatformView.publisherContainer.addView(view)

                if (view is GLSurfaceView) {
                    (view as GLSurfaceView).setZOrderOnTop(true)
                }
            }

            notifyConnectionStateChange(OpenTok.ConnectionState.LOGGED_IN)
            notifyAudioOutputDeviceChanged(getOutputDevice())

            session.publish(publisher)
        }

        override fun onDisconnected(session: Session) {
            notifyConnectionStateChange(OpenTok.ConnectionState.LOGGED_OUT)
        }

        override fun onStreamReceived(session: Session, stream: Stream) {
            if (subscriber != null) return
            // If the incoming stream is the same as publisher then ignore.
            if (stream.streamId.equals(publisher?.stream?.streamId)) return

            subscriber = Subscriber.Builder(context, stream).build().also {
                it.renderer?.setStyle(
                    BaseVideoRenderer.STYLE_VIDEO_SCALE, BaseVideoRenderer.STYLE_VIDEO_FIT
                )
                it.setSubscriberListener(subscriberListener)
                it.setVideoListener(subscriberVideoListener)
            }

            session.subscribe(subscriber)
            opentokVideoPlatformView.subscriberContainer.addView(subscriber?.view)
            notifyConnectionStateChange(OpenTok.ConnectionState.ON_CALL)
        }

        override fun onStreamDropped(session: Session, stream: Stream) {
            if (subscriber != null) {
                cleanUpSubscriber()
                notifyConnectionStateChange(OpenTok.ConnectionState.SUBSCRIBER_DISCONNECT)
            }
        }

        override fun onError(session: Session, opentokError: OpentokError) {
            notifyConnectionStateChange(OpenTok.ConnectionState.ERROR, opentokError.message)
        }
    }

    private val publisherListener: PublisherKit.PublisherListener =
        object : PublisherKit.PublisherListener {
            override fun onStreamCreated(publisherKit: PublisherKit, stream: Stream) {}

            override fun onStreamDestroyed(publisherKit: PublisherKit, stream: Stream) {
                cleanUpSubscriber()
                cleanUpPublisher()
            }

            override fun onError(publisherKit: PublisherKit, opentokError: OpentokError) {
                notifyConnectionStateChange(OpenTok.ConnectionState.ERROR, opentokError.message)
                cleanUpPublisher()
            }
        }

    private val subscriberVideoListener: SubscriberKit.VideoListener =
        object : SubscriberKit.VideoListener {
            override fun onVideoDataReceived(p0: SubscriberKit?) {
                notifySubscriberCameraStateUpdate(OpenTok.CameraState.ON)
            }

            override fun onVideoDisabled(p0: SubscriberKit?, p1: String?) {
                notifySubscriberCameraStateUpdate(OpenTok.CameraState.OFF)
            }

            override fun onVideoEnabled(p0: SubscriberKit?, p1: String?) {
                notifySubscriberCameraStateUpdate(OpenTok.CameraState.ON)
            }

            override fun onVideoDisableWarning(p0: SubscriberKit?) {
                println("onVideoDisableWarning")
            }

            override fun onVideoDisableWarningLifted(p0: SubscriberKit?) {
                println("onVideoDisableWarningLifted")
            }
        }

    private val subscriberListener: SubscriberKit.SubscriberListener =
        object : SubscriberKit.SubscriberListener {
            override fun onConnected(subscriberKit: SubscriberKit) {}

            override fun onDisconnected(subscriberKit: SubscriberKit) {
                notifyConnectionStateChange(OpenTok.ConnectionState.LOGGED_OUT)
            }

            override fun onError(subscriberKit: SubscriberKit, opentokError: OpentokError) {
                notifyConnectionStateChange(OpenTok.ConnectionState.ERROR, opentokError.message)
            }
        }
    // endregion

    // region Private methods
    private fun notifyConnectionStateChange(
        state: OpenTok.ConnectionState, errorDescription: String? = null
    ) {
        val connectionStateCallback: OpenTok.ConnectionStateCallback =
            OpenTok.ConnectionStateCallback.Builder().setState(state)
                .setErrorDescription(errorDescription).build()
        Handler(Looper.getMainLooper()).post {
            openTokPlatform.onStateUpdate(connectionStateCallback) {}
        }
    }

    private fun notifySubscriberCameraStateUpdate(state: OpenTok.CameraState) {
        val cameraStateCallback: OpenTok.CameraStateCallback =
            OpenTok.CameraStateCallback.Builder().setState(state).build()
        Handler(Looper.getMainLooper()).post {
            openTokPlatform.onSubscriberCameraStateUpdate(cameraStateCallback) {}
        }
    }

    private fun notifyAudioOutputDeviceChanged(device: OpenTok.AudioOutputDevice) {
        val audioOutputDeviceChangedCallback: OpenTok.AudioOutputDeviceCallback =
            OpenTok.AudioOutputDeviceCallback.Builder().setDevice(device).build()
        Handler(Looper.getMainLooper()).post {
            openTokPlatform.onOutputDeviceUpdate(audioOutputDeviceChangedCallback) {}
        }
    }

    private fun cleanUpPublisher() {
        opentokVideoPlatformView.publisherContainer.removeAllViews()
        if (publisher != null) {
            session?.unpublish(publisher)
            // OnStop method is called to release the hardware resource (e.g. camera, microphone)
            publisher?.onStop()
            publisher = null
        }
    }

    private fun cleanUpSubscriber() {
        opentokVideoPlatformView.subscriberContainer.removeAllViews()
        if (subscriber != null) {
            session?.unsubscribe(subscriber)
            subscriber = null
        }
    }

    private fun isBluetoothHeadsetOn(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val device = audioManager.communicationDevice

            device?.type == AudioDeviceInfo.TYPE_BLUETOOTH_A2DP || device?.type == AudioDeviceInfo.TYPE_BLUETOOTH_SCO
        } else {
            audioManager.isBluetoothScoOn || audioManager.isBluetoothA2dpOn
        }

    }

    private fun isHeadsetOn(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val device = audioManager.communicationDevice

            device?.type == AudioDeviceInfo.TYPE_WIRED_HEADSET
        } else {
            audioManager.isWiredHeadsetOn;
        }
    }
    // endregion
}
