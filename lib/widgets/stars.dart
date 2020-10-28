import 'package:flutter/material.dart';

class StarsWidget extends StatelessWidget {
  final int numberOfStars;

  const StarsWidget({Key key, this.numberOfStars}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (numberOfStars == 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star,
            color: Colors.grey.withOpacity(0.4),
          ),
          Icon(
            Icons.star,
            color: Colors.grey.withOpacity(0.4),
          ),
          Icon(
            Icons.star,
            color: Colors.grey.withOpacity(0.4),
          ),
          Icon(
            Icons.star,
            color: Colors.grey.withOpacity(0.4),
          ),
          Icon(
            Icons.star,
            color: Colors.grey.withOpacity(0.4),
          )
        ],
      );
    } else if (numberOfStars == 1) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.star,
            color: Colors.amber,
          ),
          Icon(
            Icons.star,
            color: Colors.grey.withOpacity(0.4),
          ),
          Icon(
            Icons.star,
            color: Colors.grey.withOpacity(0.4),
          ),
          Icon(
            Icons.star,
            color: Colors.grey.withOpacity(0.4),
          ),
          Icon(
            Icons.star,
            color: Colors.grey.withOpacity(0.4),
          )
        ],
      );
    } else if (numberOfStars == 2) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star, color: Colors.amber),
          Icon(
            Icons.star,
            color: Colors.amber,
          ),
          Icon(
            Icons.star,
            color: Colors.grey.withOpacity(0.4),
          ),
          Icon(
            Icons.star,
            color: Colors.grey.withOpacity(0.4),
          ),
          Icon(
            Icons.star,
            color: Colors.grey.withOpacity(0.4),
          )
        ],
      );
    } else if (numberOfStars == 3) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star, color: Colors.amber),
          Icon(
            Icons.star,
            color: Colors.amber,
          ),
          Icon(Icons.star, color: Colors.amber),
          Icon(
            Icons.star,
            color: Colors.grey.withOpacity(0.4),
          ),
          Icon(
            Icons.star,
            color: Colors.grey.withOpacity(0.4),
          )
        ],
      );
    } else if (numberOfStars == 4) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star, color: Colors.amber),
          Icon(
            Icons.star,
            color: Colors.amber,
          ),
          Icon(Icons.star, color: Colors.amber),
          Icon(Icons.star, color: Colors.amber),
          Icon(
            Icons.star,
            color: Colors.grey.withOpacity(0.4),
          )
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star, color: Colors.amber),
          Icon(
            Icons.star,
            color: Colors.amber,
          ),
          Icon(Icons.star, color: Colors.amber),
          Icon(Icons.star, color: Colors.amber),
          Icon(Icons.star, color: Colors.amber)
        ],
      );
    }
  }
}
