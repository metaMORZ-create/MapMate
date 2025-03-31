import 'package:e_commerce_app/models/shoe.dart';
import 'package:flutter/material.dart';

class Cart extends ChangeNotifier{
  // list of shoes for sale
  List<Shoe> shoeShop = [
    Shoe(
      name: "Super Schuh",
      price: "200",
      imagePath: "lib/images/shoe1.png",
      description: "Dieser Schuh ist wirklich super",
    ),
    Shoe(
      name: "Hammer Schuh",
      price: "150",
      imagePath: "lib/images/shoe2.png",
      description: "Dieser Schuh ist wirklich hammer",
    ),
    Shoe(
      name: "Guter Schuh",
      price: "125",
      imagePath: "lib/images/shoe3.png",
      description: "Dieser Schuh ist wirklich Guter",
    ),
    Shoe(
      name: "Okayer Schuh",
      price: "100",
      imagePath: "lib/images/shoe4.png",
      description: "Dieser Schuh ist wirklich okay",
    ),
    Shoe(
      name: "Schlechter Schuh",
      price: "50",
      imagePath: "lib/images/shoe5.png",
      description: "Dieser Schuh ist wirklich schlecht",
    ),
  ];

  // list of items in user cart
  List<Shoe> userCart = [];

  // get list of shoes for sale
  List<Shoe> getShoeList() {
    return shoeShop;
  }

  // get cart
  List<Shoe> getUserCart() {
    return userCart;
  }

  //add items to cart
  void addItemToCart(Shoe shoe) {
    userCart.add(shoe);
    notifyListeners();
  }

  //remove items from cart
  void removeItemToCart(Shoe shoe) {
    userCart.remove(shoe);
    notifyListeners();
  }
}
