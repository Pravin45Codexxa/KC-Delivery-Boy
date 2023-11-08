import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../Helper/AppBtn.dart';
import '../Helper/Color.dart';
import '../Helper/Constant.dart';
import '../Helper/Session.dart';
import '../Helper/String.dart';
import '../Model/Order_Model.dart';

class OrderDetail extends StatefulWidget {
  final Order_Model? model;
  final Function? updateHome;

  const OrderDetail({
    Key? key,
    this.model,
    this.updateHome,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StateOrder();
  }
}

class StateOrder extends State<OrderDetail> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController controller = ScrollController();
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  bool _isNetworkAvail = true;
  List<String> statusList = [
    PLACED,
    PROCESSED,
    SHIPED,
    DELIVERD,
    CANCLED,
  ];
  bool? _isCancleable, _isReturnable;
  final bool _isLoading = true;
  bool _isProgress = false;
  String? curStatus;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  TextEditingController? otpC;
  File imageFile = File("");
  String otps = "";

  Future<File?> _getFromCamera() async {
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      if(mounted){
        setState(() {
          imageFile = File(pickedFile.path);
        });
      }

    }

  }


  @override
  void initState() {
    super.initState();

    curStatus = widget.model!.activeStatus;
    for (int i = 0; i < widget.model!.itemList!.length; i++) {
      widget.model!.itemList![i].curSelected =
          widget.model!.itemList![i].status;
    }

    if (widget.model!.payMethod == "Bank Transfer") {

      statusList.removeWhere((element) => element == PLACED);
    }

    buttonController = AnimationController(
      duration: const Duration(
        milliseconds: 2000,
      ),
      vsync: this,
    );
    buttonSqueezeanimation = Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(
      CurvedAnimation(
        parent: buttonController!,
        curve: const Interval(
          0.0,
          0.150,
        ),
      ),
    );
  }

  @override
  void dispose() {
    buttonController!.dispose();
    super.dispose();
  }

  Future<void> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled catch (_) {}
  }

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            noIntImage(),
            noIntText(context),
            noIntDec(context),
            AppBtn(
              title: getTranslated(context, TRY_AGAIN_INT_LBL)!,
              btnAnim: buttonSqueezeanimation,
              btnCntrl: buttonController,
              onBtnSelected: () async {
                _playAnimation();

                Future.delayed(const Duration(seconds: 2)).then(
                      (_) async {
                    _isNetworkAvail = await isNetworkAvailable();
                    if (_isNetworkAvail) {
                      Navigator.pushReplacement(
                        context,
                        CupertinoPageRoute(
                          builder: (BuildContext context) => super.widget,
                        ),
                      );
                    } else {
                      await buttonController!.reverse();
                      if(mounted) {
                        setState(
                            () {},
                      );
                      }
                    }
                  },
                );
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;

    Order_Model model = widget.model!;
    String? pDate, prDate, sDate, dDate, cDate, rDate;

    if (model.listStatus!.contains(PLACED)) {
      pDate = model.listDate![model.listStatus!.indexOf(
        PLACED,
      )];

      if (pDate != "") {
        List d = pDate!.split(" ");
        pDate = d[0] + "\n" + d[1];
      }
    }
    if (model.listStatus!.contains(PROCESSED)) {
      prDate = model.listDate![model.listStatus!.indexOf(PROCESSED)];
      if (prDate != "") {
        List d = prDate!.split(" ");
        prDate = d[0] + "\n" + d[1];
      }
    }
    if (model.listStatus!.contains(SHIPED)) {
      sDate = model.listDate![model.listStatus!.indexOf(SHIPED)];
      if (sDate != "") {
        List d = sDate!.split(" ");
        sDate = d[0] + "\n" + d[1];
      }
    }
    if (model.listStatus!.contains(DELIVERD)) {
      dDate = model.listDate![model.listStatus!.indexOf(DELIVERD)];
      if (dDate != "") {
        List d = dDate!.split(" ");
        dDate = d[0] + "\n" + d[1];
      }
    }
    if (model.listStatus!.contains(CANCLED)) {
      cDate = model.listDate![model.listStatus!.indexOf(CANCLED)];
      if (cDate != "") {
        List d = cDate!.split(" ");
        cDate = d[0] + "\n" + d[1];
      }
    }
    if (model.listStatus!.contains(RETURNED)) {
      rDate = model.listDate![model.listStatus!.indexOf(RETURNED)];
      if (rDate != "") {
        List d = rDate!.split(" ");
        rDate = d[0] + "\n" + d[1];
      }
    }

    _isCancleable = model.isCancleable == "1" ? true : false;
    _isReturnable = model.isReturnable == "1" ? true : false;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.lightWhite,
      appBar: getAppBar(
        getTranslated(context, ORDER_DETAIL)!,
        context,
      ),
      body: _isNetworkAvail
          ? Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Card(
                          elevation: 0,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${getTranslated(context, ORDER_ID_LBL)!} - ${model.id!}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .lightfontColor2,
                                  ),
                                ),
                                Text(
                                  "${getTranslated(context, ORDER_DATE)!} - ${model.orderDate!}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .lightfontColor2,
                                  ),
                                ),
                                Text(
                                  "${getTranslated(context, PAYMENT_MTHD)!} - ${model.payMethod!}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .lightfontColor2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        model.delDate != "" && model.delDate!.isNotEmpty
                            ? Card(
                          elevation: 0,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              "${getTranslated(context, PREFER_DATE_TIME)!}: ${model.delDate!} - ${model.delTime!}",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .lightfontColor2,
                              ),
                            ),
                          ),
                        )
                            : Container(),
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: model.itemList!.length,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, i) {
                            OrderItem orderItem = model.itemList![i];
                            return productItem(orderItem, model, i);
                          },
                        ),
                        pickupLocation(),
                        shippingDetails(),
                        priceDetails(),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: DropdownButtonFormField(
                          dropdownColor:
                              Theme.of(context).colorScheme.lightWhite,
                          isDense: true,
                          iconEnabledColor:
                              Theme.of(context).colorScheme.fontColor,
                          hint: Text(
                            getTranslated(context, UpdateStatus)!,
                            style: Theme.of(this.context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .fontColor,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            isDense: true,
                            fillColor:
                                Theme.of(context).colorScheme.lightWhite,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context)
                                    .colorScheme
                                    .fontColor,
                              ),
                            ),
                          ),
                          value: [
                            'return_request_pending',
                            'return_request_approved',
                            'return_request_decline'
                          ].contains(widget.model!.activeStatus)
                              ? widget.model!.activeStatus
                              : null,
                          onChanged: (dynamic newValue) {
                            if(mounted) {
                              setState(
                              () {
                                curStatus = newValue;
                                colors.darkFontColor;
                              },
                            );
                            }
                          },
                          items: [...statusList].map(
                            (String st) {
                              return DropdownMenuItem<String>(
                                value: st,
                                child: Text(
                                  capitalize(st),
                                  style: Theme.of(this.context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              );
                            },
                          ).toList(),
                        ),
                      ),
                    ),
                    RawMaterialButton(
                      constraints: const BoxConstraints.expand(
                          width: 42, height: 42),
                      onPressed: () {
                        if (model.otp != "" &&
                            model.otp!.isNotEmpty &&
                            model.otp != "0" &&
                            curStatus == DELIVERD) {
                          otpDialog(
                            curStatus,
                            model.otp,
                            model.id,
                            false,
                            0,
                          );
                        } else {
                          updateOrder(
                            curStatus,
                            updateOrderApi,
                            model.id,
                            false,
                            0,
                          );
                        }
                      },
                      elevation: 2.0,
                      fillColor: Theme.of(context).colorScheme.fontColor,
                      padding: const EdgeInsets.only(left: 5),
                      shape: const CircleBorder(),
                      child: Align(
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.send,
                          size: 20,
                          color: Theme.of(context).colorScheme.white,
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          showCircularProgress(
              _isProgress, Theme.of(context).colorScheme.primary),
        ],
      )
          : noInternet(context),
    );
  }

  otpDialog(
      String? curSelected,
      String? otp,
      String? id,
      bool item,
      int index,
      ) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, StateSetter setInnerState) {
              return AlertDialog(
                contentPadding: const EdgeInsets.all(0.0),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(
                      5.0,
                    ),
                  ),
                ),
                content: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          20.0,
                          20.0,
                          0,
                          2.0,
                        ),
                        child: Text(
                          OTP_LBL,
                          style: Theme.of(this.context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                            color: Theme.of(context).colorScheme.fontColor,
                          ),
                        ),
                      ),
                      const Divider(),
                      Form(
                        key: _formkey,
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                20.0,
                                0,
                                20.0,
                                0,
                              ),
                              child: TextFormField(
                                style: TextStyle(
                                    color: Theme.of(context).colorScheme.fontColor),
                                keyboardType: TextInputType.number,
                                validator: (String? value) {
                                  otps = value!;
                                  print("$otps otps");
                                  if (value.isEmpty) {
                                    return getTranslated(context, FIELD_REQUIRED);
                                  } else if (value.trim() != otp) {
                                    return getTranslated(context, OTPERROR)!;
                                  } else {
                                    return null;
                                  }
                                },
                                autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                                decoration: InputDecoration(
                                  hintText: getTranslated(context, OTP_ENTER)!,
                                  hintStyle: Theme.of(this.context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .lightfontColor,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                controller: otpC,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(top: 20, left: 10, right: 10),
                        child: Row(
                            children: <Widget>[
                              Expanded(
                                  child: Divider()
                              ),

                              Text("OR"),

                              Expanded(
                                  child: Divider()
                              ),
                            ]
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                await _getFromCamera().then((value) {
                                  Navigator.pop(context);

                                  var durtaion = new Duration(seconds: 3);

                                  try{
                                    return Timer(durtaion,  otpDialog(curSelected, otp, id, item, index));
                                  }catch(e){
                                    print("eeeeeeee  $e");
                                  }

                                });
                              },
                              child: imageFile.path.isNotEmpty ? Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      offset: Offset(0, 0),
                                      blurRadius: 10,
                                    )
                                  ],
                                ),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image(image: FileImage(File(imageFile.path)),)),
                              ) :
                              Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      offset: Offset(0, 0),
                                      blurRadius: 10,
                                    )
                                  ],
                                ),
                                child: Icon(Icons.camera_alt,
                                  size: 50,
                                  color: colors.primary1,),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                      getTranslated(context, CANCEL)!,
                      style: Theme.of(this.context).textTheme.titleSmall!.copyWith(
                        color: Theme.of(context).colorScheme.lightfontColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      imageFile = File("");
                    },
                  ),
                  TextButton(
                    child: Text(
                      getTranslated(context, SEND_LBL)!,
                      style: Theme.of(this.context).textTheme.titleSmall!.copyWith(
                        color: Theme.of(context).colorScheme.fontColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      final form = _formkey.currentState!;

                      if(otps.isNotEmpty){
                        if (form.validate()) {
                          form.save();
                          if(mounted) {
                            setState(
                                  () {
                                Navigator.pop(context);
                              },
                            );
                          }
                          updateOrder(
                            curSelected,
                            updateOrderApi,
                            id,
                            item,
                            index,
                          );
                        }
                      }
                      else{
                        if(imageFile.path.isNotEmpty){
                          if(mounted) {
                            setState(
                                  () {
                                Navigator.pop(context);
                              },
                            );
                          }
                          updateOrder(
                            curSelected,
                            updateOrderApi,
                            id,
                            item,
                            index,
                          );
                        }
                      }


                     /* final form = _formkey.currentState!;
                      if (form.validate()) {
                        form.save();
                        if(mounted)
                        setState(
                              () {
                            Navigator.pop(context);
                          },
                        );
                        updateOrder(
                          curSelected,
                          updateOrderApi,
                          id,
                          item,
                          index,
                        );
                      }*/


                    },
                  ),
                ],
              );
            });
      },
    );
  }

  _launchMap(lat, lng) async {
    var url = '';

    if (Platform.isAndroid) {
      url =
      "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving&dir_action=navigate";
    } else {
      url =
      "http://maps.apple.com/?saddr=&daddr=$lat,$lng&directionsmode=driving&dir_action=navigate";
    }
    await launch(url);
  }

  priceDetails() {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          0,
          15.0,
          0,
          15.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 15.0,
                right: 15.0,
              ),
              child: Text(
                getTranslated(context, PRICE_DETAIL)!,
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Theme.of(context).colorScheme.fontColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(
                left: 15.0,
                right: 15.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${getTranslated(context, PRICE_LBL)!} :",
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: Theme.of(context).colorScheme.lightfontColor2,
                    ),
                  ),
                  Text(
                    getPriceFormat(
                      context,
                      double.parse(
                        widget.model!.subTotal!,
                      ),
                    )!,
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: Theme.of(context).colorScheme.lightfontColor2,
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${getTranslated(context, DELIVERY_CHARGE_LBL)!} :",
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: Theme.of(context).colorScheme.lightfontColor2,
                    ),
                  ),
                  Text(
                    getPriceFormat(
                      context,
                      double.parse(
                        widget.model!.delCharge!,
                      ),
                    )!,
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: Theme.of(context).colorScheme.lightfontColor2,
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 15.0,
                right: 15.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${getTranslated(context, TAXPER)!} (${widget.model!.taxPer!}) :",
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: Theme.of(context).colorScheme.lightfontColor2,
                    ),
                  ),
                  Text(
                    getPriceFormat(
                      context,
                      double.parse(
                        widget.model!.taxAmt!,
                      ),
                    )!,
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: Theme.of(context).colorScheme.lightfontColor2,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 15.0,
                right: 15.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${getTranslated(context, PROMO_CODE_DIS_LBL)!} :",
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: Theme.of(context).colorScheme.lightfontColor2,
                    ),
                  ),
                  Text(
                    "-${getPriceFormat(
                      context,
                      double.parse(
                        widget.model!.promoDis!,
                      ),
                    )!}",
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: Theme.of(context).colorScheme.lightfontColor2,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 15.0,
                right: 15.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${getTranslated(
                      context,
                      WALLET_BAL,
                    )!} :",
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: Theme.of(context).colorScheme.lightfontColor2,
                    ),
                  ),
                  Text(
                    "-${getPriceFormat(context, double.parse(widget.model!.walBal!))!}",
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: Theme.of(context).colorScheme.lightfontColor2,
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${getTranslated(context, TOTAL_PRICE)!} :",
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: Theme.of(context).colorScheme.lightfontColor2,
                    ),
                  ),
                  Text(
                    getPriceFormat(
                        context, double.parse(widget.model!.total!))!,
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: Theme.of(context).colorScheme.lightfontColor2,
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${getTranslated(context, TOTAL_AMOUNT)!} :",
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: Theme.of(context).colorScheme.lightfontColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    getPriceFormat(
                      context,
                      double.parse(widget.model!.payable!),
                    )!,
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: Theme.of(context).colorScheme.lightfontColor,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  shippingDetails() {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          0,
          15.0,
          0,
          15.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 15.0,
                right: 15.0,
              ),
              child: Row(
                children: [
                  Text(
                    getTranslated(context, SHIPPING_DETAIL)!,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).colorScheme.fontColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    height: 30,
                    child: IconButton(
                      icon: Icon(
                        Icons.location_on,
                        color: Theme.of(context).colorScheme.fontColor,
                      ),
                      onPressed: () {
                        _launchMap(
                          widget.model!.latitude,
                          widget.model!.longitude,
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(
                left: 15.0,
                right: 15.0,
              ),
              child: Text(
                widget.model!.name != "" && widget.model!.name!.isNotEmpty
                    ? " ${capitalize(widget.model!.name!)}"
                    : " ",
              ),
            ),
            widget.model!.address!.isNotEmpty
                ? Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 15.0, vertical: 3),
              child: Text(
                widget.model!.address!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.lightfontColor2,
                ),
              ),
            )
                : Container(),
            /*widget.model!.mobile!.isNotEmpty
                ? InkWell(
                    onTap: _launchCaller,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15.0,
                        vertical: 5,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.call,
                            size: 15,
                            color: Theme.of(context).colorScheme.fontColor,
                          ),
                          Text(
                            " ${widget.model!.mobile!}",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.fontColor,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(),*/
          ],
        ),
      ),
    );
  }

  pickupLocation() {
    return widget.model?.store_name != null
        ? Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          0,
          15.0,
          0,
          15.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 15.0,
                right: 15.0,
              ),
              child: Row(
                children: [
                  Text(
                    'Pickup location',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(
                      color: Theme.of(context).colorScheme.fontColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (widget.model?.store_latitude != null)
                    SizedBox(
                      height: 30,
                      child: IconButton(
                        icon: Icon(
                          Icons.location_on,
                          color: Theme.of(context).colorScheme.fontColor,
                        ),
                        onPressed: () {
                          _launchMap(
                            widget.model!.store_latitude,
                            widget.model!.store_longitude,
                          );
                        },
                      ),
                    )
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.only(
                left: 15.0,
                right: 15.0,
              ),
              child: Text(
                " ${capitalize(widget.model!.store_name ?? "no name")}",
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 15.0, vertical: 3),
              child: Text(
                "${widget.model!.store_address}",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.lightfontColor2,
                ),
              ),
            ),
            widget.model!.store_phone != null
                ? InkWell(
              onTap: _launchCaller,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                  vertical: 5,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.call,
                      size: 15,
                      color:
                      Theme.of(context).colorScheme.fontColor,
                    ),
                    Text(
                      " ${widget.model!.store_phone}",
                      style: TextStyle(
                        color:
                        Theme.of(context).colorScheme.fontColor,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            )
                : Container(),
          ],
        ),
      ),
    )
        : SizedBox.shrink();
  }

  productItem(
      OrderItem orderItem,
      Order_Model model,
      int i,
      ) {
    List? att, val;
    if (orderItem.attr_name!.isNotEmpty) {
      att = orderItem.attr_name!.split(',');
      val = orderItem.varient_values!.split(',');
    }

    final isReturnable = orderItem.status == 'return_request_approved' || orderItem.status == 'returned';
    final status = [...statusList, if(isReturnable) RETURNED];

    print("status $status");


    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: FadeInImage(
                    fadeInDuration: const Duration(milliseconds: 150),
                    image: NetworkImage(orderItem.image!),
                    height: 90.0,
                    width: 90.0,
                    placeholder: placeHolder(90),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          orderItem.name ?? '',
                          style:
                          Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .lightfontColor,
                            fontWeight: FontWeight.normal,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        orderItem.attr_name!.isNotEmpty
                            ? ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: att!.length,
                          itemBuilder: (context, index) {
                            return Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    att![index].trim() + ":",
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .lightfontColor2,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                  const EdgeInsets.only(left: 5.0),
                                  child: Text(
                                    val![index],
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .lightfontColor,
                                    ),
                                  ),
                                )
                              ],
                            );
                          },
                        )
                            : Container(),
                        Row(
                          children: [
                            Text(
                              "${getTranslated(context, QUANTITY_LBL)!}:",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .lightfontColor2,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: Text(
                                orderItem.qty!,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .lightfontColor,
                                ),
                              ),
                            )
                          ],
                        ),
                        if(orderItem.status == 'return_request_approved' ||
                            orderItem.status == 'return_request_pending' ||
                            orderItem.status == 'return_request_decline')
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 2,
                                    child: Text(
                                      "${getTranslated(context, 'ACTIVE_STATUS_LBL')!}:",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall!
                                          .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .lightfontColor,
                                      ),
                                    )),
                                Expanded(
                                  flex: 3,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 5.0),
                                    child: Text(
                                          () {
                                        if (capitalize(orderItem.status!) ==
                                            "Received") {
                                          return getTranslated(
                                              context, "received")!;
                                        } else if (capitalize(
                                            orderItem.status!) ==
                                            "Processed") {
                                          return getTranslated(
                                              context, "processed")!;
                                        } else if (capitalize(
                                            orderItem.status!) ==
                                            "Shipped") {
                                          return getTranslated(
                                              context, "shipped")!;
                                        } else if (capitalize(
                                            orderItem.status!) ==
                                            "Delivered") {
                                          return getTranslated(
                                              context, "delivered")!;
                                        } else if (capitalize(
                                            orderItem.status!) ==
                                            "Returned") {
                                          return getTranslated(
                                              context, "returned")!;
                                        } else if (capitalize(
                                            orderItem.status!) ==
                                            "Cancelled") {
                                          return getTranslated(
                                              context, "cancelled")!;
                                        } else if (capitalize(
                                            orderItem.status!) ==
                                            "Return_request_pending") {
                                          return getTranslated(context,
                                              "RETURN_REQUEST_PENDING_LBL")!;
                                        } else if (capitalize(
                                            orderItem.status!) ==
                                            "Return_request_approved") {
                                          return 'approved';
                                          // return getTranslated(context,
                                          //     RETURN_REQUEST_APPROVE_LBL)!;
                                        } else if (capitalize(
                                            orderItem.status!) ==
                                            "Return_request_decline") {
                                          return getTranslated(context,
                                              "RETURN_REQUEST_DECLINE_LBL")!;
                                        }
                                        return capitalize(orderItem.status! == "return_request_approved" ? "Pickup" : orderItem.status!);
                                      }(),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall!
                                          .copyWith(
                                          color: /*Theme.of(context)
                                                  .colorScheme
                                                  .fontColor*/Colors.pinkAccent),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        Text(
                          getPriceFormat(
                            context,
                            double.parse(orderItem.price!),
                          )!,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
                              color:
                              Theme.of(context).colorScheme.fontColor),
                        ),
                        Padding(
                          padding:
                          const EdgeInsets.symmetric(vertical: 10.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding:
                                  const EdgeInsets.only(right: 8.0),
                                  child: DropdownButtonFormField(
                                    dropdownColor: Theme.of(context)
                                        .colorScheme
                                        .lightWhite,
                                    isDense: true,
                                    iconEnabledColor: Theme.of(context)
                                        .colorScheme
                                        .fontColor,
                                    //iconSize: 40,
                                    hint: Text(
                                      getTranslated(
                                          context, UpdateStatus)!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall!
                                          .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    decoration: InputDecoration(
                                      filled: true,
                                      isDense: true,
                                      fillColor: Theme.of(context)
                                          .colorScheme
                                          .lightWhite,
                                      contentPadding:
                                      const EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 10,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .fontColor,
                                        ),
                                      ),
                                    ),
                                    value:
                                    (orderItem.status ==
                                        'return_request_approved' ||
                                        orderItem.status ==
                                            'return_request_pending' ||
                                        orderItem.status ==
                                            'return_request_decline')
                                        ? null
                                        : orderItem.status,
                                    onChanged: (dynamic newValue) {
                                      if(mounted) {
                                        setState(
                                            () {
                                          orderItem.curSelected =
                                              newValue;
                                        },
                                      );
                                      }
                                    },
                                    items: status.map(
                                          (String st) {
                                        return DropdownMenuItem<String>(
                                          value: st,
                                          child: Text(
                                            capitalize(st),
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall!
                                                .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .fontColor,
                                              fontWeight:
                                              FontWeight.bold,
                                            ),
                                          ),
                                        );
                                      },
                                    ).toList(),
                                  ),
                                ),
                              ),
                              RawMaterialButton(
                                constraints: const BoxConstraints.expand(
                                  width: 42,
                                  height: 42,
                                ),
                                onPressed: () {
                                  if (model.otp != "" &&
                                      model.otp!.isNotEmpty &&
                                      model.otp != "0" &&
                                      orderItem.curSelected == DELIVERD) {
                                    otpDialog(
                                      orderItem.curSelected,
                                      model.otp,
                                      model.id,
                                      true,
                                      i,
                                    );
                                  } else {
                                    updateOrder(
                                      orderItem.curSelected,
                                      updateOrderApi,
                                      model.id,
                                      true,
                                      i,
                                    );
                                  }
                                },
                                elevation: 2.0,
                                fillColor: Theme.of(context)
                                    .colorScheme
                                    .fontColor,
                                padding: const EdgeInsets.only(left: 5),
                                shape: const CircleBorder(),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.send,
                                    size: 20,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .white,
                                  ),
                                ),
                              )
                            ],
                          ),
                        )

                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Future<void> updateOrder(
  //     String? status,
  //     Uri api,
  //     String? id,
  //     bool item,
  //     int index,
  //     ) async {
  //   _isNetworkAvail = await isNetworkAvailable();
  //   if (_isNetworkAvail) {
  //     try {
  //       if(mounted) {
  //         setState(
  //             () {
  //           _isProgress = true;
  //         },
  //       );
  //       }
  //
  //       var parameter = <String, String>{
  //         ORDERID: id!,
  //         STATUS: status!,
  //         DEL_BOY_ID: CUR_USERID!,
  //       };
  //       if (item) parameter[ORDERITEMID] = widget.model!.itemList![index].id!;
  //       print(
  //           'response body ${parameter} $headers ${item ? updateOrderItemApi : updateOrderApi}');
  //       final req = MultipartRequest('post', updateOrderApi);
  //       req.fields.addAll(parameter);
  //       req.headers.addAll(headers);
  //       if(imageFile.path.isNotEmpty) {
  //         req.files.add(MultipartFile('image', imageFile.openRead(), imageFile.lengthSync(),
  //           filename: imageFile.path.split('/').last));
  //       }
  //
  //       final res = await req.send();
  //
  //       final getRes = await res.stream.bytesToString();
  //
  //     /*  Response response = await post(
  //           item ? updateOrderItemApi : updateOrderApi,
  //           body: parameter,
  //           headers: headers)
  //           .timeout(
  //         const Duration(seconds: timeOut),
  //       );
  //       print('response body ${response.body}');*/
  //       var getdata = json.decode(getRes);
  //
  //       bool error = getdata["error"];
  //       String msg = getdata["message"];
  //       setSnackbar(msg);
  //       if (!error) {
  //         if (item) {
  //           widget.model!.itemList![index].status = status;
  //         } else {
  //           widget.model!.activeStatus = status;
  //         }
  //       }
  //       if(mounted) {
  //         setState(
  //             () {
  //           _isProgress = false;
  //         },
  //       );
  //       }
  //     } on TimeoutException catch (_) {
  //       setSnackbar(
  //         getTranslated(context, somethingMSg)!,
  //       );
  //     }
  //   } else {
  //     if(mounted) {
  //       setState(
  //           () {
  //         _isNetworkAvail = false;
  //       },
  //     );
  //     }
  //   }
  // }

  Future<void> updateOrder(
      String? status,
      Uri api,
      String? id,
      bool item,
      int index,
      ) async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        setState(
              () {
            _isProgress = true;
          },
        );

        var parameter = <String, String>{
          ORDERID: id!,
          STATUS: status!,
          DEL_BOY_ID: CUR_USERID!,
        };
        if (item) parameter[ORDERITEMID] = widget.model!.itemList![index].id!;
        print(
            'response body ${parameter} $headers ${item ? updateOrderItemApi : updateOrderApi}');


        if(imageFile.path.isNotEmpty) {
        final req = MultipartRequest('post', updateOrderApi);
        req.fields.addAll(parameter);
        req.headers.addAll(headers);

          req.files.add(MultipartFile('image', imageFile.openRead(), imageFile.lengthSync(),
              filename: imageFile.path.split('/').last));

        final res = await req.send();

        final getRes = await res.stream.bytesToString();

        var getdata = json.decode(getRes);

        bool error = getdata["error"];
        String msg = getdata["message"];
        setSnackbar(msg);
        if (!error) {
          if (item) {
            widget.model!.itemList![index].status = status;
          } else {
            widget.model!.activeStatus = status;
          }
        }
        if(mounted) {
          setState(
                () {
              _isProgress = false;
            },
          );
        }
        }
        else{
          Response response = await post(
              item ? updateOrderItemApi : updateOrderApi,
              body: parameter,
              headers: headers)
              .timeout(
            const Duration(seconds: timeOut),
          );
          print('response body ${response.body}');
          var getdata = json.decode(response.body);

          bool error = getdata["error"];
          String msg = getdata["message"];
          setSnackbar(msg);
          if (!error) {
            if (item) {
              widget.model!.itemList![index].status = status;
            } else {
              widget.model!.activeStatus = status;
            }
          }

          setState(
                () {
              _isProgress = false;
            },
          );
        }


      } on TimeoutException catch (_) {
        setSnackbar(
          getTranslated(context, somethingMSg)!,
        );
      }
    } else {
      setState(
            () {
          _isNetworkAvail = false;
        },
      );
    }
  }


  _launchCaller() async {
    var url = "tel:${widget.model!.mobile}";
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
      /*awaitingPayment launch $url;
      String waiting = null;
      Uri.dataFromString(HttpHeaders.userAgentHeader);
      dashedTextConfiguration;
      noIntText(Uri.dataFromBytes(Response.bytes(bodyBytes, orderId)));
      textDirectionToAxisDirection(order curStatus);
      statusList flexible statement;
      AsyncSnapshot.withData(ORDER_DELIVERED, CASH_RECEIVED);
      STATUS = ACTIVE_STATUS;
      HttpRequest != false;
      DataTableSource = User;
      ClipboardStatus = deliverd;
      if status != true;*/
    } else {
      throw 'Could not launch $url';
    }
  }

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).colorScheme.fontColor),
        ),
        backgroundColor: Theme.of(context).colorScheme.white,
        elevation: 1.0,
      ),
    );
  }
}