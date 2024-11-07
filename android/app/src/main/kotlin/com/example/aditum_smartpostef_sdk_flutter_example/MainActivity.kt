package com.example.aditum_smartpostef_sdk_flutter_example

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

import br.com.aditum.data.v2.enums.AbecsCommands
import br.com.aditum.data.v2.model.init.InitRequest
import br.com.aditum.data.v2.model.init.InitResponse
import br.com.aditum.data.v2.model.init.InitResponseCallback
import br.com.aditum.data.v2.model.PinpadMessages
import br.com.aditum.data.v2.model.callbacks.GetClearDataRequest
import br.com.aditum.data.v2.model.callbacks.GetClearDataFinishedCallback
import br.com.aditum.data.v2.model.callbacks.GetMenuSelectionRequest
import br.com.aditum.data.v2.model.callbacks.GetMenuSelectionFinishedCallback
import br.com.aditum.data.v2.enums.TransactionStatus
import br.com.aditum.IAditumSdkService
import br.com.aditum.data.v2.IPaymentCallback

import io.flutter.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlin.concurrent.thread

class MainActivity: FlutterActivity()
{
    // After adding All Dependencies, 
    //you can access objects of classes declared .aar File
    public val TAG = MainActivity::class.simpleName

    private lateinit var mPaymentApplication: PaymentApplication;

    private val CHANNEL = "br.com.aditum.payment";


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
            when (call.method) {
                "init" -> {
                    // Lógica para o método "init"
                    this.init();
                    result.success("Init successful")
                }
                "pay" -> {
                    // Lógica para o método "pay"
                    result.success("Payment successful")
                }
                "confirm" -> {
                    // Lógica para o método "confirm"
                    result.success("Confirmation successful")
                }
                "cancelation" -> {
                    // Lógica para o método "cancelation"
                    result.success("Cancellation successful")
                }
                "print" -> {
                    // Lógica para o método "print"
                    result.success("Print successful")
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        mPaymentApplication = application as PaymentApplication
        mPaymentApplication.serviceConnectionListener = mServiceConnected
        mPaymentApplication.startAditumSdkService()
    }

    private val mServiceConnected = object : PaymentApplication.OnServiceConnectionListener {
        override fun onServiceConnection(serviceConnected: Boolean) {
            if (TAG != null) {
                Log.d(TAG, "onServiceConnection - serviceConnected: $serviceConnected")
            }
            if (serviceConnected) {
                mPaymentApplication.communicationService?.registerPaymentCallback(mPaymentCallback)
            }
        }
    }

    private val mPaymentCallback = object : IPaymentCallback.Stub() {
        override fun notification(message: String?, transactionStatus: TransactionStatus?, command: AbecsCommands?) {}

        override fun pinNotification(message: String, length: Int) {}

        override fun startGetClearData(clearDataRequest: GetClearDataRequest?, finished: GetClearDataFinishedCallback?) {}

        override fun startGetMenuSelection(menuSelectionRequest: GetMenuSelectionRequest?, finished: GetMenuSelectionFinishedCallback?) {}

        override fun qrCodeGenerated(qrCode: String, expirationTime: Int) {}
    }

    private fun init() {
        mPaymentApplication.communicationService?.let { communicationService: IAditumSdkService ->
            val pinpadMessages = PinpadMessages()
            pinpadMessages.mainMessage = "Payment Example"

            val initRequest = InitRequest()
            initRequest.pinpadMessages = pinpadMessages
            initRequest.activationCode = "291153668"
            initRequest.applicationName = "PaymentExample"
            initRequest.applicationVersion = "1.0.0"
            initRequest.applicationToken = "mk_Zftn0TUy8UOCph7Ss3yl6A"
            communicationService.init(initRequest, mInitResponseCallback)
        } ?: run {
            mPaymentApplication.startAditumSdkService()
        }
    }

    private val mInitResponseCallback = object : InitResponseCallback.Stub() {
        override fun onResponse(initResponse: InitResponse?) {
            initResponse?.let {
                if (TAG != null) {
                    Log.d(TAG, "onResponse - initResponse: $initResponse")
                }
                if (initResponse.initialized) {
                    getMertchantData()
                } else {
                    NotificationMessage.showMessageBox(this@MainActivity, "Error", "onResponse - initResponse: $initResponse")
                }
            } ?: run {
                NotificationMessage.showMessageBox(this@MainActivity, "Error", "onResponse - initResponse is null")
            }
        }
    }

    private fun getMertchantData() {
        if (TAG != null) {
            Log.d(TAG, "getMertchantData")
        }
        thread {
            mPaymentApplication.communicationService?.let { communicationService: IAditumSdkService ->
                mPaymentApplication.merchantData = communicationService.getMerchantData()
            } ?: run {
                NotificationMessage.showMessageBox(this, "Error", "Communication service not available. Trying to recreate communication with service.")
            }
        }
    }

    private fun pay() {

    }


}