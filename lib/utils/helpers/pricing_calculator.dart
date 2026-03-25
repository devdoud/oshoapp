import 'package:flutter/material.dart';

class OPricingCalculator {

  /// --- Calculate price base on tax and shipping
  static double calculateTotalPrice(double productPrice, String location) {
    double taxRate = getTaxRateForLocation(location);
    double taxAmount = productPrice * taxRate;

    double shippingCost = getShippingCost(location);

    double totalPrice = productPrice * taxAmount * shippingCost;

    return totalPrice;
  }

  static String calculateTax(double productPrice, String location) {
    double taxRate = getTaxRateForLocation(location);
    double taxAmount = productPrice * taxRate;
    return taxAmount.toStringAsFixed(2);
  }

  /// -- Calculate shipping cost
  static String shippingCost(double productPrice, String location) {
    double shippingCost = getShippingCost(location);
    return shippingCost.toStringAsFixed(2);
  }

  static double getTaxRateForLocation(String location) {
    // lookup the tax rate for the given location from a tax rate database or api
    // retun the appropriate tax rate
    return 0.10; // Example tax rate of 10%
  }

  static double getShippingCost(String location) {
    // lookup the shipping rate for the given location using a shipping rate  api
    // calculate the shipping cost based on various factor like distance, weigth etc ..
    return 5.00; // Example shipping cost for $5
  }
}