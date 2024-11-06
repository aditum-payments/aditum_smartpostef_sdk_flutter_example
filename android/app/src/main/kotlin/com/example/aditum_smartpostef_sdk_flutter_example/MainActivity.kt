package com.example.aditum_smartpostef_sdk_flutter_example

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity()
{
    // After adding All Dependencies, 
    //you can access objects of classes declared .aar File

    private lateinit var mPaymentApplication: PaymentApplication;
  
    private val CHANNEL = "br.com.aditum/payment";

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
            if (call.method == "init") {
                init()
            } else if(call.method == "pay") {

            }else {
                result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        mPaymentApplication = application as PaymentApplication
        mPaymentApplication.serviceConnectionListener = mServiceConnected
        mPaymentApplication.startAditumSdkService()
    }

    private fun init() {
        mPaymentApplication.communicationService?.let { communicationService: IAditumSdkService ->
            val pinpadMessages = PinpadMessages()
            pinpadMessages.mainMessage = "Payment Example"

            val initRequest = InitRequest()
            initRequest.pinpadMessages = pinpadMessages
            initRequest.activationCode = activationCode
            initRequest.applicationName = "PaymentExample"
            initRequest.applicationVersion = "1.0.0"
            initRequest.applicationToken = "mk_Lfq9yMzRoYaHjowfxLvoyi"
            communicationService.init(initRequest, mInitResponseCallback)
        } ?: run {
            NotificationMessage.showMessageBox(this, "Error", "Communication service not available. Trying to recreate communication with service.")
            mPaymentApplication.startAditumSdkService()
        }
    }

    private fun pay() {

    }


}