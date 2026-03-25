import 'package:flutter/material.dart';

class ModelVariant extends StatelessWidget {
  final bool isSelected;
  final String image;

  const ModelVariant({
    super.key,
    required this.isSelected,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container( 
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            border: isSelected
                ? Border.all(color: Colors.green, width: 4)
                : Border.all(color: Colors.grey.shade200, width: 2),
            shape: BoxShape.circle,
            image: DecorationImage(
              image: AssetImage(image),
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (isSelected)
          Positioned(
            top: 4,
            right: 1,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, color: Colors.white, size: 12,),
            ),
          ),
      ],
    );
  }
}