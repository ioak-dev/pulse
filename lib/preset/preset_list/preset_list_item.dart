import 'package:endurance/database/model/preset.dart';
import 'package:flutter/material.dart';

class PresetListItem extends StatelessWidget {
  PresetListItem({Key? key, required this.preset}) : super(key: key);

  Preset preset;

  handleClick(context) {
    print(preset);
    Navigator.pushNamed(context, '/preset/view', arguments: {'id': preset.id});
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        alignment: Alignment.centerLeft,
        padding:
            const EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 20),
        child: Column(
          children: [
            Align(
                alignment: Alignment.topLeft,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        preset.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text("${10}s", textAlign: TextAlign.start)
                    ])),
            Align(
                alignment: Alignment.topLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text("10 acts, 5 rests")],
                ))
          ],
        ),
      ),
      onTap: () {
        handleClick(context);
      },
    );
  }
}
