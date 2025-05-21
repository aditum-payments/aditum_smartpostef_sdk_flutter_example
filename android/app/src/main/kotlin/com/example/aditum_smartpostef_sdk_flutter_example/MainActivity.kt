package com.example.aditum_smartpostef_sdk_flutter_example

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.os.Bundle
import br.com.aditum.IAditumSdkService
import br.com.aditum.data.v2.IPaymentCallback
import br.com.aditum.data.v2.enums.AbecsCommands
import br.com.aditum.data.v2.enums.InstallmentType
import br.com.aditum.data.v2.enums.PayOperationType
import br.com.aditum.data.v2.enums.PaymentType
import br.com.aditum.data.v2.enums.PaymentType.Pix
import br.com.aditum.data.v2.enums.PrintStatus
import br.com.aditum.data.v2.enums.TransactionStatus
import br.com.aditum.data.v2.model.PinpadMessages
import br.com.aditum.data.v2.model.callbacks.GetClearDataFinishedCallback
import br.com.aditum.data.v2.model.callbacks.GetClearDataRequest
import br.com.aditum.data.v2.model.callbacks.GetMenuSelectionFinishedCallback
import br.com.aditum.data.v2.model.callbacks.GetMenuSelectionRequest
import br.com.aditum.data.v2.model.cancelation.CancelationRequest
import br.com.aditum.data.v2.model.cancelation.CancelationResponse
import br.com.aditum.data.v2.model.cancelation.CancelationResponseCallback
import br.com.aditum.data.v2.model.deactivation.DeactivationResponseCallback
import br.com.aditum.data.v2.model.init.InitRequest
import br.com.aditum.data.v2.model.init.InitResponse
import br.com.aditum.data.v2.model.init.InitResponseCallback
import br.com.aditum.data.v2.model.payment.PaymentRequest
import br.com.aditum.data.v2.model.payment.PaymentResponse
import br.com.aditum.data.v2.model.payment.PaymentResponseCallback
import br.com.aditum.data.v2.model.transactions.ConfirmTransactionCallback
import br.com.aditum.device.callbacks.IPrintStatusCallback
import com.google.gson.Gson
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.UUID
import kotlin.concurrent.thread
import kotlin.io.encoding.ExperimentalEncodingApi


class MainActivity: FlutterActivity()
{
    // After adding All Dependencies, 
    //you can access objects of classes declared .aar File
    public val TAG : String = MainActivity::class.simpleName as String

    private val gson: Gson = Gson()

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
                    this.init(call, result);
                }
                "pay" -> {
                    this.pay(call, result);
                }
                "confirm" -> {
                    this.confirm(call, result);
                }
                "cancelation" -> {
                    this.cancel(call, result);
                }
                "print" -> {
                    this.print(call, result)
                }
                "deactivate" -> {
                    this.deactivate(call, result)
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
            Log.d(TAG, "onServiceConnection - serviceConnected: $serviceConnected")
            if (serviceConnected) {
                mPaymentApplication.communicationService?.registerPaymentCallback(mPaymentCallback)
            }
        }
    }

    private fun init(call: MethodCall, result: MethodChannel.Result) {
        mPaymentApplication.communicationService?.let { communicationService: IAditumSdkService ->
            val pinpadMessages = PinpadMessages()
            pinpadMessages.mainMessage = "BRADESCO"

            val activationCode = call.argument<String>("activationCode")

            val initRequest = InitRequest()
            initRequest.pinpadMessages = pinpadMessages
            initRequest.activationCode = activationCode
            initRequest.applicationName = "pdv top"
            initRequest.applicationVersion = "1.0.0"
            initRequest.applicationToken = "1123"
            mInitResponseCallback.result = result;
            communicationService.init(initRequest, mInitResponseCallback)
        } ?: run {
            mPaymentApplication.startAditumSdkService()
        }
    }

    private val mInitResponseCallback = object : InitResponseCallback.Stub() {
        override fun onResponse(initResponse: InitResponse?) {
            initResponse?.let {
                if (initResponse.initialized) {
                    getMerchantData(result)
                }
            } ?: run {
                Log.e(TAG, "onResponse - initResponse is null");
                result?.success(false);
            }
        }

        var result: MethodChannel.Result? = null;
    }

    private fun getMerchantData(result: MethodChannel.Result?) {
        Log.d(TAG, "getMertchantData")
        thread {
            mPaymentApplication.communicationService?.let { communicationService: IAditumSdkService ->
                mPaymentApplication.merchantData = communicationService.getMerchantData()
                result?.success(gson.toJson(mPaymentApplication.merchantData));
            } ?: run {
                Log.e(TAG, "Communication service not available.")
                result?.success(false);
            }
        }
    }

    private fun pay(
        call: MethodCall,
        result: MethodChannel.Result
    ) {

        val amount: Int = call.argument<Int>("amount") ?: 500
        
        val merchantChargeId: String = call.argument<String>("merchantChargeId") ?: UUID.randomUUID().toString()

        var operationType = PayOperationType.Authorization

        val paymentRequest = PaymentRequest(
            operationType = operationType,
            amount = amount.toLong(),
            merchantChargeId = merchantChargeId,
            currency = 986,
            allowContactless = true,
            manualEntry = false,
        )

        thread {
            mPaymentApplication.communicationService?.let { communicationService: IAditumSdkService ->
                mPaymentApplication.merchantData = communicationService.merchantData
                Log.d(TAG, "CommunicationService: $communicationService")
                mPayResponseCallback.result = result;
                thread { communicationService.pay(paymentRequest, mPayResponseCallback) }
            } ?: run {
                Log.e(TAG, "Communication service not available.")
                result.success(false);
            }
        }
    }

    private val mPayResponseCallback = object : PaymentResponseCallback.Stub() {
        override fun onResponse(paymentResponse: PaymentResponse?) {
            Log.d(TAG, "onResponse - paymentResponse: $paymentResponse")

            paymentResponse?.let {
                result?.success(gson.toJson(paymentResponse));
            } ?: run {
                Log.e(TAG, "onResponse - paymentResponse is null");
                result?.success(null);
            }
        }
        var result: MethodChannel.Result? = null;
    }

    private val mConfirmResponseCallback = object : ConfirmTransactionCallback.Stub() {
        override fun onResponse(confirmed: Boolean) {
            result?.success(confirmed)
        }
        var result: MethodChannel.Result? = null;
    }

    private fun confirm(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        mPaymentApplication.communicationService?.let { communicationService: IAditumSdkService ->
            thread { 
                val nsu = call.argument<String>("nsu");
                mConfirmResponseCallback.result = result;
                communicationService.confirmTransaction(nsu, mConfirmResponseCallback) 
            }
        } ?: run {
            result.success(false);
        }
    }

    private val mCancelationResponseCallback = object : CancelationResponseCallback.Stub() {
        override fun onResponse(cancelationResponse: CancelationResponse?) {
            Log.d(TAG, "onResponse - cancelationResponse: $cancelationResponse")
            val isCanceled = cancelationResponse?.canceled ?: false;
            result?.success(isCanceled);
        }
        
        var result: MethodChannel.Result? = null;
    }

    private fun cancel(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        mPaymentApplication.communicationService?.let { mAditumSdkService: IAditumSdkService ->
            var nsu: String? = call.argument<String>("nsu");
            var isReversal: Boolean? = call.argument<Boolean>("isReversal");
            if(nsu != null && isReversal != null) {
                val mCancelationRequest = CancelationRequest(nsu, isReversal);
                mCancelationResponseCallback.result = result;
                thread { mAditumSdkService.cancel(mCancelationRequest, mCancelationResponseCallback) }
            } else {
                result.success(false);
            }

        } ?: run {
            Log.e(TAG, "Communication service not available.")
        }
    }

    @OptIn(ExperimentalEncodingApi::class)
    private fun print(call: MethodCall, result: MethodChannel.Result){
        mPaymentApplication.communicationService?.let { communicationService: IAditumSdkService ->

            var receiptImage: String = call.argument<String>("nsu")  as String;
            val bitmap = createImage(384, 50, Color.BLACK, receiptImage);
                thread {communicationService.deviceSdk.printerSdk.print(bitmap, mPrintStatusCallback)}
        } ?: run {
            result.success(false);
        }
    }

    fun createImage(width: Int, height: Int, color: Int, name: String?): Bitmap {
        val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        val paint = Paint()
        paint.color = Color.BLACK
        paint.style = Paint.Style.FILL;
        paint.textSize = 32f
        canvas.drawColor(Color.WHITE);
        canvas.drawText(name!!, 0f, 25f, paint)

        return bitmap
    }

    private val mPrintStatusCallback = object : IPrintStatusCallback.Stub() {
        override fun finished(status: PrintStatus) {
            Log.d(TAG, "onPrintStatus - printResponse: $status")
            result?.success(status == PrintStatus.Ok);
        }

        var result: MethodChannel.Result? = null;
    }

    private fun deactivate(call: MethodCall, result: MethodChannel.Result) {
        mPaymentApplication.communicationService?.let { communicationService: IAditumSdkService ->

            thread {communicationService.deactivate(mDeactivationCallback)}
        } ?: run {
            result.success(false);
        }
    }

    private val mDeactivationCallback = object : DeactivationResponseCallback.Stub() {
        override fun onResponse(status: Boolean) {
            Log.d(TAG, "onDeactivationResponse - deactivationResponse: $status")
            result?.success(status);
        }

        var result: MethodChannel.Result? = null;
    }

    private val mPaymentCallback = object : IPaymentCallback.Stub() {
        override fun notification(message: String?, transactionStatus: TransactionStatus?, command: AbecsCommands?) {}

        override fun pinNotification(message: String, length: Int) {}

        override fun startGetClearData(clearDataRequest: GetClearDataRequest?, finished: GetClearDataFinishedCallback?) {}

        override fun startGetMenuSelection(menuSelectionRequest: GetMenuSelectionRequest?, finished: GetMenuSelectionFinishedCallback?) {}

        override fun qrCodeGenerated(qrCode: String, expirationTime: Int) {}
    }

}