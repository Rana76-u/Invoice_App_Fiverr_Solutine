import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

List<XFile> productImages = [];
List<String> descriptions = [];
List<String> brandNames = [];
List<String> sizes = [];
List<double> units = [];
List<double> rates = [];

XFile? shopSupplierImage;
TextEditingController shippingMarkController = TextEditingController();