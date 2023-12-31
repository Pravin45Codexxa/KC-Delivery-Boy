import 'package:deliveryboy/Helper/String.dart';
import 'package:intl/intl.dart';

class Order_Model {
  String? id,
      name,
      mobile,
      latitude,
      longitude,
      delCharge,
      walBal,
      promo,
      promoDis,
      payMethod,
      total,
      returnInitiated,
      returnCompleted,
      subTotal,
      payable,
      address,
      taxAmt,
      taxPer,
      orderDate,
      dateTime,
      isCancleable,
      isReturnable,
      isAlrCancelled,
      isAlrReturned,
      rtnReqSubmitted,
      activeStatus,
      otp,
      deliveryBoyId,
      deliveryContact,
      maskingNumber,
      invoice,
      delDate,
      delTime,
      cname,
      type,
      cdate,
      order_status,
      amount,
      cashReceived,
      message,
      priority,
      pickupLocation,
      store_name,
      store_email,
      store_phone,
      store_address,
      store_address_2,
      store_city,
      store_state,
      store_country,
      store_pin_code,
      store_latitude,
      store_longitude;


  @override
  String toString() {
    return 'Order_Model{deliveryBoyId: $deliveryBoyId, deliveryContact: $deliveryContact, maskingNumber: $maskingNumber}';
  } // @override
  // String toString() {
  //   return 'Order_Model{id: $id, name: $name, mobile: $mobile, latitude: $latitude, longitude: $longitude, delCharge: $delCharge, walBal: $walBal, promo: $promo, promoDis: $promoDis, payMethod: $payMethod, total: $total, returnInitiated: $returnInitiated, returnCompleted: $returnCompleted, subTotal: $subTotal, payable: $payable, address: $address, taxAmt: $taxAmt, taxPer: $taxPer, orderDate: $orderDate, dateTime: $dateTime, isCancleable: $isCancleable, isReturnable: $isReturnable, isAlrCancelled: $isAlrCancelled, isAlrReturned: $isAlrReturned, rtnReqSubmitted: $rtnReqSubmitted, activeStatus: $activeStatus, otp: $otp, deliveryBoyId: $deliveryBoyId, invoice: $invoice, delDate: $delDate, delTime: $delTime, cname: $cname, type: $type, cdate: $cdate, return_status: $order_status, amount: $amount, cashReceived: $cashReceived, message: $message, priority: $priority, pickupLocation: $pickupLocation, store_name: $store_name, store_email: $store_email, store_phone: $store_phone, store_address: $store_address, store_address_2: $store_address_2, store_city: $store_city, store_state: $store_state, store_country: $store_country, store_pin_code: $store_pin_code, store_latitude: $store_latitude, store_longitude: $store_longitude, itemList: $itemList, listStatus: $listStatus, listDate: $listDate, deliveryContact: $deliveryContact, maskingNumber: $maskingNumber}';
  // }

  List<OrderItem>? itemList = [];
  List<String?>? listStatus = [];
  List<String?>? listDate = [];

  bool get isReturnApproved => itemList?.any((element) => element.status == 'return_request_approved') ?? false;

  Order_Model({
    this.id,
    this.name,
    this.mobile,
    this.delCharge,
    this.walBal,
    this.promo,
    this.promoDis,
    this.payMethod,
    this.total,
    this.subTotal,
    this.payable,
    this.address,
    this.order_status,
    this.taxPer,
    this.taxAmt,
    this.orderDate,
    this.dateTime,
    this.itemList,
    this.listStatus,
    this.listDate,
    this.isReturnable,
    this.isCancleable,
    this.isAlrCancelled,
    this.isAlrReturned,
    this.returnInitiated,
    this.returnCompleted,
    this.rtnReqSubmitted,
    this.activeStatus,
    this.otp,
    this.invoice,
    this.latitude,
    this.longitude,
    this.delDate,
    this.delTime,
    this.deliveryBoyId,
    this.deliveryContact,
    this.maskingNumber,
    this.cname,
    this.type,
    this.cdate,
    this.amount,
    this.cashReceived,
    this.message,
    this.pickupLocation,
    this.priority,
    this.store_name,
    this.store_email,
    this.store_phone,
    this.store_address,
    this.store_address_2,
    this.store_city,
    this.store_state,
    this.store_country,
    this.store_pin_code,
    this.store_latitude,
    this.store_longitude,
  });

  factory Order_Model.fromJson(Map<String, dynamic> parsedJson) {
    List<OrderItem> itemList = [];
    var order =
        parsedJson[ORDER_ITEMS] == null ? [] : parsedJson[ORDER_ITEMS] as List;
    if (order.isEmpty) {
      order = [];
    } else {
      itemList = order.map((data) => OrderItem.fromJson(data)).toList();
    }
    String date = parsedJson[DATE_ADDED] ?? "";

    date = date.isNotEmpty
        ? DateFormat('dd-MM-yyyy').format(DateTime.parse(date))
        : date;
    List<String?> lStatus = [];
    List<String?> lDate = [];

    var allSttus = parsedJson[STATUS] ?? [];
    for (var curStatus in allSttus) {
      lStatus.add(curStatus[0]);
      lDate.add(curStatus[1]);
    }

    return Order_Model(
      id: parsedJson[ID] ?? "",
      name: parsedJson[USERNAME] ?? "",
      mobile: parsedJson[MOBILE] ?? "",
      delCharge: parsedJson[DEL_CHARGE] ?? "",
      walBal: parsedJson[WAL_BAL] ?? "",
      promo: parsedJson[PROMOCODE] ?? "",
      promoDis: parsedJson[PROMO_DIS] ?? "",
      payMethod: parsedJson[PAYMENT_METHOD] ?? "",
      total: parsedJson[FINAL_TOTAL] ?? "",
      subTotal: parsedJson[TOTAL] ?? "",
      payable: parsedJson[TOTAL_PAYABLE] ?? "",
      address: parsedJson[ADDRESS] ?? "",
      taxAmt: parsedJson[TOTAL_TAX_AMT] ?? "",
      taxPer: parsedJson[TOTAL_TAX_PER] ?? "",
      dateTime: parsedJson[DATE_ADDED] ?? "",
      isCancleable: parsedJson[ISCANCLEABLE] ?? "",
      isReturnable: parsedJson[ISRETURNABLE] ?? "",
      isAlrCancelled: parsedJson[ISALRCANCLE] ?? "",
      isAlrReturned: parsedJson[ISALRRETURN] ?? "",
      rtnReqSubmitted: parsedJson[ISRTNREQSUBMITTED] ?? "",
      orderDate: date,
      itemList: itemList,
      listStatus: lStatus,
      listDate: lDate,
      activeStatus: parsedJson[ACTIVE_STATUS] ?? "",
      otp: parsedJson[OTP] ?? "",
      latitude: parsedJson[LATITUDE] ?? "",
      longitude: parsedJson[LONGITUDE] ?? "",
      delDate: parsedJson[DEL_DATE] ?? "",
      delTime: parsedJson[DEL_TIME] != "" ? parsedJson[DEL_TIME] : '',
      deliveryBoyId: parsedJson[DELIVERY_BOY_ID] ?? "",
      deliveryContact: parsedJson['delivery_contact'],
      maskingNumber: parsedJson['masking_number'],
      cname: parsedJson[NAME] ?? "",
      type: parsedJson[TYPE] ?? "",
      cdate: parsedJson[DATE_DEL] ?? "",
      amount: parsedJson[AMOUNT] ?? "",
      cashReceived: parsedJson[CASH_RECEIVED] ?? "",
      message: parsedJson[MESSAGE] ?? "",
      pickupLocation: parsedJson['pickup_location'] ?? "not assigned",
      priority: parsedJson['priority'] ?? "not assigned",
      store_name: parsedJson['store_name'],
      store_email: parsedJson['store_email'],
      store_phone: parsedJson['store_phone'],
      store_address: parsedJson['store_address'],
      store_address_2: parsedJson['store_address_2'],
      store_city: parsedJson['store_city'],
      store_state: parsedJson['store_state'],
      store_country: parsedJson['store_country'],
      store_pin_code: parsedJson['store_pin_code'],
      store_latitude: parsedJson['store_latitude'],
      store_longitude: parsedJson['store_longitude'],
    );
  }
}

class OrderItem {
  String? id,
      name,
      qty,
      price,
      subTotal,
      status,
      image,
      varientId,
      isCancle,
      isReturn,
      isAlrCancelled,
      isAlrReturned,
      rtnReqSubmitted,
      varient_values,
      attr_name,
      productId,
      curSelected;

  List<String?>? listStatus = [];
  List<String?>? listDate = [];

  @override
  String toString() {
    return 'OrderItem{id: $id, name: $name, status: $status, productId: $productId}';
  }

  OrderItem(
      {this.qty,
      this.id,
      this.name,
      this.price,
      this.subTotal,
      this.status,
      this.image,
      this.varientId,
      this.listDate,
      this.listStatus,
      this.isCancle,
      this.isReturn,
      this.isAlrReturned,
      this.isAlrCancelled,
      this.rtnReqSubmitted,
      this.attr_name,
      this.productId,
      this.varient_values,
      this.curSelected});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    List<String?> lStatus = [];
    List<String?> lDate = [];

    var allSttus = json[STATUS];
    for (var curStatus in allSttus) {
      lStatus.add(curStatus[0]);
      lDate.add(curStatus[1]);
    }
    return OrderItem(
      id: json[ID] ?? "",
      qty: json[QUANTITY] ?? "",
      name: json[NAME] ?? "",
      image: json[IMAGE] ?? "",
      price: json[PRICE] ?? "",
      subTotal: json[SUB_TOTAL] ?? "",
      varientId: json[PRODUCT_VARIENT_ID] ?? "",
      listStatus: lStatus,
      status: json[ACTIVE_STATUS],
      curSelected: json[ACTIVE_STATUS],
      listDate: lDate,
      isCancle: json[ISCANCLEABLE] ?? "",
      isReturn: json[ISRETURNABLE] ?? "",
      isAlrCancelled: json[ISALRCANCLE] ?? "",
      isAlrReturned: json[ISALRRETURN] ?? "",
      rtnReqSubmitted: json[ISRTNREQSUBMITTED] ?? "",
      attr_name: json[ATTR_NAME] ?? "",
      productId: json[PRODUCT_ID] ?? "",
      varient_values: json[VARIENT_VALUE] ?? "",
    );
  }
}
